/*
 * jpeg_utils.h
 *
 *  Created on: Aug 2, 2011
 *      Author: bkorlipara
 */

#ifndef _TRICKPLAY_JPEG_UTILS_H
#define _TRICKPLAY_JPEG_UTILS_H

namespace JPEGUtils
{
//.........................................................................

int get_exif_orientation( const char* filename );

//.........................................................................

int get_exif_orientation( const unsigned char* data , unsigned int size );

//.........................................................................

class Rotator
{
public:

    Rotator( int orientation , unsigned int width , unsigned int height , unsigned int depth );

    virtual ~Rotator();

    inline unsigned int get_transformed_location( unsigned int x , unsigned int y ) const
    {
        switch ( orientation )
        {
            case 2: return ( ( y * width + width - x ) - 1 ) * depth;

            case 3: return ( ( ( height - y  - 1 ) * width + width - x ) - 1 ) * depth;

            case 4: return ( ( height - y - 1 ) * width + x ) * depth;

            case 5: return ( x * height + y ) * depth;

            case 6: return ( ( x * height + height - y ) - 1 ) * depth ;

            case 7: return ( ( ( width - x - 1 ) * height + height - y ) - 1 ) * depth;

            case 8: return ( ( width - x - 1 ) * height + y ) * depth;
        }

        return ( y * width + x ) * depth;
    }

    inline unsigned int get_transformed_height() const
    {
        return orientation <= 4 ? height : width;
    }

    inline unsigned int get_transformed_width() const
    {
        return orientation <= 4 ? width : height;
    }

private:

    Rotator();

    const int           orientation;
    const unsigned int  width;
    const unsigned int  height;
    const unsigned int  depth;
};
};

#endif // _TRICKPLAY_JPEG_UTILS_H
