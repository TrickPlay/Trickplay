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

#include "libexif/exif-data.h"

#include "jpeg_utils.h"
#include "common.h"

namespace JPEGUtils
{

//.............................................................................

static int get_exif_orientation( ExifData* exif_data )
{
    if ( ! exif_data->ifd[ EXIF_IFD_0 ] )
    {
        return 0;
    }

    ExifEntry* entry = exif_content_get_entry( exif_data->ifd[ EXIF_IFD_0 ] , EXIF_TAG_ORIENTATION );

    if ( ! entry )
    {
        return 0;
    }

    if ( ! entry->data || ! entry->size || entry->components != 1 )
    {
        return 0;
    }

    int result = 0;

    switch ( entry->format )
    {
        case EXIF_FORMAT_SHORT:
            result = exif_get_short( entry->data , exif_data_get_byte_order( exif_data ) );
            break;

        case EXIF_FORMAT_SSHORT:
            result = exif_get_sshort( entry->data , exif_data_get_byte_order( exif_data ) );
            break;

        default:
            break;
    }

    if ( result <= 0 || result > 8 )
    {
        return 0;
    }

    return result;
}

//.............................................................................

int get_exif_orientation( const char* filename )
{
    if ( ExifData* exif_data = exif_data_new_from_file( filename ) )
    {
        int result = get_exif_orientation( exif_data );

        exif_data_unref( exif_data );

        return result;
    }

    return 0;
}

//.............................................................................

int get_exif_orientation( const unsigned char* data , unsigned int size )
{
    if ( ExifData* exif_data = exif_data_new_from_data( data , size ) )
    {
        int result = get_exif_orientation( exif_data );

        exif_data_unref( exif_data );

        return result;
    }

    return 0;
}

//.............................................................................

Rotator::Rotator( int _orientation , unsigned int _width , unsigned int _height , unsigned int _depth )
    :
    orientation( _orientation ),
    width( _width ),
    height( _height ),
    depth( _depth )
{}

//.............................................................................

Rotator::Rotator()
    :
    orientation( 0 ),
    width( 0 ),
    height( 0 ),
    depth( 0 )
{}

//.............................................................................

Rotator::~Rotator()
{}

}
