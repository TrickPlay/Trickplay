#include <cstdlib>

#include "FreeImage.h"

#include "common.h"
#include "images.h"

bool Images::load_texture_from_data(ClutterTexture * texture,const void * data,size_t length)
{
    // Wrap the data into a FreeImage memory stream. This does not copy the data
    
    FIMEMORY * mem=FreeImage_OpenMemory((BYTE*)data,length);
    
    if (!mem)
    {
	g_debug("FAILED TO OPEN FREEIMAGE MEMORY STREAM");
	return false;
    }
    
    // Get the image format and bail if it is unknown
    
    FREE_IMAGE_FORMAT format=FreeImage_GetFileTypeFromMemory(mem,0);
   
    if (format==FIF_UNKNOWN)
    {
	g_debug("UNKNOWN IMAGE FORMAT");
	FreeImage_CloseMemory(mem);
	return false;
    }

    // Load the image
    
    FIBITMAP * image=FreeImage_LoadFromMemory(format,mem,0);
    
    // Close the memory stream
    
    FreeImage_CloseMemory(mem);
    
    // Bail if the image is no good
    
    if (!image)
    {
	g_debug("FAILED TO LOAD IMAGE");
	return false;
    }
    
    // Convert it to either 24 or 32 bits (if it has transparency)
    
    unsigned int bpp=0;
    FIBITMAP * image2=NULL;
    
    if (!FreeImage_IsTransparent(image))
    {
	image2=FreeImage_ConvertTo24Bits(image);
	bpp=24;
    }
 
    // Use this as a fallback in case we tried to convert it to 24 bits and that
    // did not work.
    
    if (!image2)
    {
	image2=FreeImage_ConvertTo32Bits(image);
	bpp=32;
    }

    // Dump the old image
    
    FreeImage_Unload(image);
    
    // Bail if the conversion fails
    
    if (!image2)
    {
	g_debug("FAILED TO CONVERT IMAGE TO %u BITS",bpp);
	return false;
    }
    
    // Allocate a buffer and convert the image to raw bits
    
    int width  = FreeImage_GetWidth(image2);
    int height = FreeImage_GetHeight(image2);
    int pitch  = FreeImage_GetPitch(image2);
    
    unsigned char * pixels=(unsigned char *)malloc(height*pitch);
    
    FreeImage_ConvertToRawBits((BYTE*)pixels,image2,pitch,bpp,FI_RGBA_RED_MASK,FI_RGBA_GREEN_MASK,FI_RGBA_BLUE_MASK,TRUE);

    // Now, convert from BGR(A) to RGB(A) which is what GL wants
    
    unsigned char * line=pixels;
    unsigned char r,g,b;
    unsigned char * p;
    
    int depth=(bpp==32?4:3);
    
    for(int row=0;row<height;++row)
    {
	p=line;
	
	for(int col=0;col<width;++col)
	{
	    r=p[2];
	    g=p[1];
	    b=p[0];

	    p[0]=r;
	    p[1]=g;
	    p[2]=b;
	    
	    p+=depth;
	}	
	line+=pitch;
    }

    // Dump the image
    
    FreeImage_Unload(image2);    
    
    // Give it to clutter
    
    clutter_texture_set_from_rgb_data(
	texture,
	(const guchar *)pixels,
	depth==4,
	width,
	height,
	pitch,
	depth,
	CLUTTER_TEXTURE_NONE,NULL);
    
    // Free the pixels
    
    free(pixels);
    
    return true;
}

bool Images::load_texture_from_file(ClutterTexture * texture,const char * file_name)
{
    gchar * data=NULL;
    gsize length=0;

    if (!g_file_get_contents(file_name,&data,&length,NULL))
	return false;
    
    bool result=load_texture_from_data(texture,data,length);
    
    g_free(data);
    
    return result;
}
