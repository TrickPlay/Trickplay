#include <magick/MagickCore.h>
#include <string.h>

int main(int ,char **argv)
{
    MagickCoreGenesis(*argv, MagickTrue);

    ExceptionInfo *exception;

    Image *image, *images;

    ImageInfo *image_info;


    image_info=AcquireImageInfo();
    CopyMagickString(image_info->filename, argv[1], MaxTextExtent);
    exception=AcquireExceptionInfo();
    images=ReadImage(image_info,exception);

    if (exception->severity != UndefinedException)
    {
        CatchException(exception);
    }
    if (images == (Image *) NULL)
    {
        exit(1);
    }

    while ((image=RemoveFirstImageFromList(&images)) != (Image *) NULL)
    {
        const char *prop = GetImageProperty(image, "label");
        if(prop)
        {
            printf("Image (%s): %lu x %lu @ (%lu,%lu) - %s\n", prop, image->page.width, image->page.height, image->page.x, image->page.y, (NoCompositeOp==image->compose)?"HIDDEN":"SHOWN" );

            CopyMagickString(image->filename, prop, MaxTextExtent );
            ConcatenateMagickString(image->filename, ".png", MaxTextExtent );
            ImageInfo *output_info = AcquireImageInfo();
            CopyMagickString(output_info->filename, image->filename, MaxTextExtent);
            // Set the file-type, just in case
            CopyMagickString(output_info->magick, "png", MaxTextExtent);
            if(!WriteImage(output_info, image))
            {
                printf("WRITE FAILED FOR %s", output_info->filename);
            }
            DestroyImageInfo(output_info);
        }

        DestroyImage(image);
    }

    exception=DestroyExceptionInfo(exception);
    image_info=DestroyImageInfo(image_info);
    MagickCoreTerminus();
}
