/*
 * jpeg_exif_orient.cpp
 *
 *  Created on: Aug 1, 2011
 *      Author: bkorlipara
 */

/*
 * The Exif orientation value gives the orientation of the camera
 * relative to the scene when the image was captured.  The relation
 * of the '0th row' and '0th column' to visual position is shown as
 * below.
 *
 * Value | 0th Row     | 0th Column
 * ------+-------------+-----------
 *   1   | top         | left side
 *   2   | top         | right side
 *   3   | bottom      | right side
 *   4   | bottom      | left side
 *   5   | left side   | top
 *   6   | right side  | top
 *   7   | right side  | bottom
 *   8   | left side   | bottom
 *
 * For convenience, here is what the letter F would look like if it were
 * tagged correctly and displayed by a program that ignores the orientation
 * tag:
 *
 *   1        2       3      4         5            6           7          8
 *
 * 888888  888888      88  88      8888888888  88                  88  8888888888
 * 88          88      88  88      88  88      88  88          88  88      88  88
 * 8888      8888    8888  8888    88          8888888888  8888888888          88
 * 88          88      88  88
 * 88          88  888888  888888
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "jpeg_utils.h"

namespace TPJPEGUtils {

class Reader {
public:
	virtual bool read_1_byte( unsigned char * c ) = 0;
	virtual bool read_2_bytes( unsigned short * s ) = 0;
	virtual bool seek( unsigned short numbytes ) = 0;

	virtual bool is_valid( void )
	{
		return true;
	}

};

class FileReader : public Reader {
private:
	FILE* myfile;
public :
	FileReader( const char* filename )
	{
		  myfile = fopen( filename, "rb" );
	}

	~FileReader()
	{
		if ( is_valid() )
			fclose( myfile );
	}

	bool is_valid(void)
	{
		return myfile != NULL;
	}

	bool read_1_byte ( unsigned char * c )
	{
	  int val;

	  if ( !is_valid() )
	  {
		  return false;
	  }

	  val = getc( myfile );
	  if (val == EOF)
	  {
	    return false;
	  }
	  else
	  {
		  *c = val;
	  }

	  return true;
	}

	/* Read 2 bytes, convert to unsigned int */
	/* All 2-byte quantities in JPEG markers are MSB first */
	bool read_2_bytes ( unsigned short * s )
	{
	  int c1;
	  int c2;

	  if ( !is_valid() )
	  {
		  return false;
	  }

	  c1 = getc( myfile );

	  if ( c1 == EOF )
	  {
		  return false;
	  }
	  c2 = getc( myfile );
	  if ( c2 == EOF )
	  {
		  return false;
	  }
	  *s = (( c1 << 8 ) + c2 );
	  return true;
	}

	bool seek ( unsigned short numbytes )
	{
		return is_valid() && 0 == fseek( myfile, numbytes, SEEK_CUR );
	}
};

class MemoryReader : public Reader {

private:
	guchar * base;
	gsize size;
	gsize current;

public :
	MemoryReader( guchar * memptr, gsize sz ) :
		base( memptr ), size( sz ), current( 0 )
	{
	}

	bool is_valid()
	{
		return base != NULL && current < size;
	}

	bool read_1_byte ( unsigned char * c )
	{
	  if ( !is_valid() )
	  {
		  return false;
	  }
	  *c = base[current++];
	  return true;
	}

	/* Read 2 bytes, convert to unsigned int */
	/* All 2-byte quantities in JPEG markers are MSB first */
	bool read_2_bytes ( unsigned short * s )
	{
	  unsigned c1;
	  unsigned c2;
	  if ( !is_valid() )
	  {
		  return false;
	  }

	  c1 = base[ current++ ];
	  if ( !is_valid() )
	  {
		return false;
	  }
	  c2 = base[ current++ ];
	  *s = ( ( c1 << 8 ) + c2 );
	  return true;
	}

	bool seek ( unsigned short numbytes )
	{
		bool retval = is_valid() && ( current + numbytes ) <= size;
		if ( retval )
			current += numbytes;
		return retval;
	}
};

static bool move_to_exif_marker( Reader & rdr )
{
	/* Read marker and check if it is Exif APP1 */
	int i;
	unsigned char marker[2];
	unsigned short length;
	while(1)
	{
	  for (i = 0; i < 2; i++)
	  {
		  if ( !rdr.read_1_byte( &marker[i] ) )
		  {
			  return false;
		  }
	  }

	  if ( marker[0] != 0xFF )
	  {
		  return false;
	  }

	  if ( marker[1] != 0xE1 && marker[1] != 0xDA )
	  {
	    	if ( !rdr.read_2_bytes( &length ) || length < 2 )
	    	{
	    		return false;
	    	}
	    	/* move file pointer to the location of the next marker */
	    	if ( !rdr.seek( length - 2 ) )
	    	{
	    		return false;
	    	}
	  }
	  else if ( marker[1] == 0xDA )
	  {
		  /* found Start of stream marker. implies no EXIF marker in this file */
		  return false;
	  }
	  else /* found exif marker */
	  {
		  return true;
	  }
	}

	return false;
}

static int get_exif_orientation( Reader& rdr )
{
	unsigned char exif_data[65536L];
	unsigned short length;
	int is_motorola; /* Flag for byte order */
	unsigned short offset;
	unsigned short number_of_tags;
	unsigned short tagnum;
	int orientation = 0;
	unsigned int i;

	if ( !rdr.is_valid() )
	{
		return 0;
	}

	/* Read File head, check for JPEG SOI + Exif APP1 */
	for (i = 0; i < 2; i++)
	{
		if ( !rdr.read_1_byte( &exif_data[i] ) )
		{
			return 0;
		}
	}

	if ( exif_data[0] != 0xFF ||
	   exif_data[1] != 0xD8 )
	{
		return 0;
	}

	if ( !move_to_exif_marker( rdr ) )
	{
		return 0;
	}

	/* Get the marker parameter length count */
	if ( !rdr.read_2_bytes( &length ) )
	{
		return 0;
	}

	/* Length includes itself, so must be at least 2 */
	/* Following Exif data length must be at least 6 */
	if ( length < 8 )
	{
		return 0;
	}
	length -= 8;

	/* Read Exif head, check for "Exif" */
	for ( i = 0; i < 6; i++ )
	{
		if ( !rdr.read_1_byte( &exif_data[i] ) )
		{
			return 0;
		}
	}
	if ( exif_data[0] != 0x45 ||
	   exif_data[1] != 0x78 ||
	   exif_data[2] != 0x69 ||
	   exif_data[3] != 0x66 ||
	   exif_data[4] != 0 ||
	   exif_data[5] != 0 )
	{
		return 0;
	}
	/* Read Exif body */
	for ( i = 0; i < length; i++ )
	{
		if ( !rdr.read_1_byte( &exif_data[i] ) )
		{
			return 0;
		}
	}

	if ( length < 12 )
	{
		return 0; /* Length of an IFD entry */
	}

  /* Discover byte order */
	if ( exif_data[0] == 0x49 && exif_data[1] == 0x49 )
	{
		is_motorola = 0;
	}
	else if ( exif_data[0] == 0x4D && exif_data[1] == 0x4D )
	{
		is_motorola = 1;
	}
	else
	{
		return 0;
	}

  /* Check Tag Mark */
	if ( is_motorola )
	{
		if ( exif_data[2] != 0 )
		{
			return 0;
		}
		if ( exif_data[3] != 0x2A )
		{
			return 0;
		}
	}
	else
	{
		if ( exif_data[3] != 0 )
		{
			return 0;
		}
		if ( exif_data[2] != 0x2A )
		{
			return 0;
		}
	}

	/* Get first IFD offset (offset to IFD0) */
	if ( is_motorola )
	{
		if ( exif_data[4] != 0 )
		{
			return 0;
		}
		if ( exif_data[5] != 0 )
		{
			return 0;
		}
		offset = exif_data[6];
		offset <<= 8;
		offset += exif_data[7];
	}
	else
	{
		if ( exif_data[7] != 0 )
		{
			return 0;
		}
		if ( exif_data[6] != 0 )
		{
			return 0;
		}
		offset = exif_data[5];
		offset <<= 8;
		offset += exif_data[4];
	}
	if ( offset > length - 2 )
	{
		return 0; /* check end of data segment */
	}

	/* Get the number of directory entries contained in this IFD */
	if ( is_motorola )
	{
		number_of_tags = exif_data[offset];
		number_of_tags <<= 8;
		number_of_tags += exif_data[offset+1];
	}
	else
	{
		number_of_tags = exif_data[offset+1];
		number_of_tags <<= 8;
		number_of_tags += exif_data[offset];
	}
	if ( number_of_tags == 0 )
	{
		  return 0;
	}
	offset += 2;

  /* Search for Orientation Tag in IFD0 */
	for ( ; ; )
	{
		if ( offset > length - 12 )
		{
			return 0; /* check end of data segment */
		}
		/* Get Tag number */
		if ( is_motorola )
		{
			tagnum = exif_data[offset];
			tagnum <<= 8;
			tagnum += exif_data[offset+1];
		}
		else
		{
			tagnum = exif_data[offset+1];
			tagnum <<= 8;
			tagnum += exif_data[offset];
		}
		if ( tagnum == 0x0112 )
		{
			break; /* found Orientation Tag */
		}
		if ( --number_of_tags == 0 )
		{
			return 0;
		}
		offset += 12;
	}

  /* Get the Orientation value */
	if ( is_motorola )
	{
		if ( exif_data[offset + 8] != 0 )
		{
			return 0;
		}
		orientation = exif_data[offset + 9];
	}
	else
	{
		if ( exif_data[offset + 9] != 0 )
		{
			return 0;
		}
		orientation = exif_data[offset + 8];
	}

	if ( orientation > 8 )
	{
	  return 0;
	}

	return orientation;
}

int get_exif_orientation( const char* filename )
{
	FileReader rdr( filename );
	return get_exif_orientation( rdr );
}

int get_exif_orientation( guchar* imagedata, gsize sz )
{
	MemoryReader rdr( imagedata, sz );
	return get_exif_orientation( rdr );
}

}
