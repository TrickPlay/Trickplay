
#include <stdio.h>
#include <stdlib.h>
#include "jpeg_utils.h"
using namespace TPJPEGUtils;
//-----------------------------------------------------------------------------

int main( int argc, char * argv[ ] )
{
	if (argc != 2)
	{
		printf("Usage is:\n");
		printf("\tjpeg-find-orientation <jpeg_filename>\n");
		exit(-1);
	}

	printf("EXIF orientation=%d\n",get_exif_orientation(argv[1]));
}
