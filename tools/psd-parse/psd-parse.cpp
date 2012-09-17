#include <magick/MagickCore.h>

int main(int argc,char **argv)
{
    MagickCoreGenesis(*argv, MagickTrue);

    ExceptionInfo
      *exception;

    Image
      *image,
      *images;

    ImageInfo
      *image_info;


    image_info=AcquireImageInfo();
    (void) CopyMagickString(image_info->filename,argv[1],MaxTextExtent);
    exception=AcquireExceptionInfo();
    images=ReadImage(image_info,exception);

    if (exception->severity != UndefinedException)
      CatchException(exception);
    if (images == (Image *) NULL)
      exit(1);

    unsigned int i=0;
    while ((image=RemoveFirstImageFromList(&images)) != (Image *) NULL)
    {
      const char *prop = GetImageProperty(image, "label");
      if(prop)
          printf("Image (%s): %lu x %lu @ (%lu,%lu) - %s\n", prop, image->page.width, image->page.height, image->page.x, image->page.y, (NoCompositeOp==image->compose)?"HIDDEN":"SHOWN" );
      DestroyImage(image);
    }

    exception=DestroyExceptionInfo(exception);
    image_info=DestroyImageInfo(image_info);
    MagickCoreTerminus();
}
