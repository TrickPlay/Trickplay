/*
 * jpeg_utils.h
 *
 *  Created on: Aug 2, 2011
 *      Author: bkorlipara
 */

#ifndef JPEG_UTILS_H_
#define JPEG_UTILS_H_

#include "glib.h"

namespace TPJPEGUtils
{
/**
 * This function operates on a jpeg file and returns the value of EXIF orientation tag
 * returns 0 if it fails to find the value for the orientation tag
 */
int get_exif_orientation(const char* filename);

/**
 * This function operates on a jpeg image file which is loaded into memory and returns the value of EXIF orientation tag
 * returns 0 if it fails to find the value for the orientation tag
 */
int get_exif_orientation(guchar* imagedata, gsize sz);
};

#endif /* JPEG_UTILS_H_ */
