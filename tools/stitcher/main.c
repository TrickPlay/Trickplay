#include <gio/gio.h>
#include <magick/MagickCore.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// help message

void error( char * msg ) {
	fprintf( stderr, "%s\n"
        "Usage: stitcher /path/to/directory [-bcmr] [-i *] [-o *] \n"
        "Flags:\n"
        "   -h            Show this help and exit.\n"
        "\n"
        "   -b            Place buffer pixels around sprite edges. Add this flag if\n"
        "                 scaled sprites are having issues around their borders.\n"
        "\n"
        "   -c            Copy files that fail the size filter over as single-image\n"
        "                 spritesheets (if they fit within the maximum output size).\n"
        "                 This option must be used in conjunction with -m.\n"
        "\n"
        "   -i [filter]   Filter which files to include. Name filters can use the\n"
        "                 wildcards * (zero or more chars) and ? (one char).\n"
        "                 Multiple space-seperated name filters can be passed.\n"
        "                 Files will be included if they match at least one filter.\n"
        "      [int]      One integer size filter can be passed, such as 256, to\n"
        "                 prevent large images from being included in a spritesheet.\n"
        "\n"
        "   -m            Divide sprites among multiple spritesheets if they don't fit\n"
        "                 within the maximum dimensions\n"
        "                 (NOTE: -m is not yet supported on the TrickPlay side.)\n"
        "\n"
        "   -o [path]     Set the path of the output files, which will have\n"
        "                 sequential numbers and a .png or .json extension appended.\n"
        "      [int]      Pass an integer like 4096 to set the maximum .png size.\n"
        "\n"
        "   -r            Recursively include subdirectories.\n", msg );
	exit( 0 );
}

// options

char * input_path  = NULL,
     * output_path = NULL;

int input_size_limit  = 4096,
    output_size_limit = 4096,
    output_size_step  = 0;
	
gboolean allow_multiple_sheets = FALSE,
         copy_large_images     = FALSE,
         add_buffer_pixels     = FALSE,
         recursive             = FALSE;

// globals

GPtrArray * large_images;
GSequence * items,
          * leaves_sorted_by_area;

typedef struct Page {
    int width,
        height,
        area;
    float coverage;
} Page;
Page current,
     smallest,
     minimum  = { 0, 0, 0, 0 },
     best     = { 0, 0, 0, 0 };

#include "item.c"
#include "leaf.c"

void insert_item ( Item * item, Leaf * leaf, gboolean finalize )
{
    int covered = (int) ( current.coverage * (float) current.area );
    current.width  = MAX( current.width,  leaf->x + item->w );
    current.height = MAX( current.height, leaf->y + item->h );
    current.area = current.width * current.height;
    current.coverage = (float) ( covered + item->w * item->h ) / (float) current.area;
    
    item->x = leaf->x;
    item->y = leaf->y;
    item->placed = finalize;
    leaf_cut( leaf, item->w, item->h );
}

enum {
    FOUND_NONE,
    FOUND_SOME,
    FOUND_ALL
};

int recalculate_layout ( int width, gboolean finalize )
{
    current = (Page) { 0, 0, 0, 0 };
    int f = 0, nf = 0;
    
    leaves_sorted_by_area = g_sequence_new( NULL );
    leaf_new( 0, 0, MAX( width, minimum.width ), output_size_limit * ( allow_multiple_sheets ? 1 : 2 ) );
    
    GSequenceIter * i = g_sequence_get_begin_iter( items );
    while ( !g_sequence_iter_is_end( i ) )
    {
        Item * item = (Item *) g_sequence_get( i );
        GSequenceIter * si;
        
        if ( item->placed == TRUE )
        {
            i = g_sequence_iter_next( i );
            continue;
        }
        
        // searches for a leaf with the best shape-match that expands the height of the page the least
        
        int growth, close_growth = 0, fallback_growth = 0;
        Leaf * leaf     = NULL,
             * found    = NULL,
             * best     = NULL,
             * close    = NULL,
             * fallback = NULL;
        
        si = g_sequence_search( leaves_sorted_by_area, item, leaf_compare, AREA );
        while ( !g_sequence_iter_is_end( si ) )
        {
            leaf = g_sequence_get( si );
            if ( leaf->w >= item->w && leaf->h >= item->h ) {
                growth = MAX( current.height, leaf->y + item->h ) - current.height;
                if ( leaf->w == item->w || leaf->h == item->h )
                {
                    if ( growth == 0 )
                    {
                        found = leaf;
                        break;
                    }
                    else if ( growth < close_growth || close_growth == 0 )
                    {
                        close = leaf;
                        close_growth = growth;
                    }
                }
                else
                {
                    if ( growth == 0 )
                        best = leaf;
                    else if ( growth < fallback_growth || fallback_growth == 0 )
                    {
                        fallback = leaf;
                        fallback_growth = growth;
                    }
                }
            }
            si = g_sequence_iter_next( si );
        }
        
        if ( found != NULL ||
           ( found = best ) != NULL ||
           ( found = close ) != NULL ||
           ( found = fallback ) != NULL ) {
            f++;
            insert_item( item, found, finalize );
        }
        else
        {
            if ( allow_multiple_sheets )
                nf++;
            else
                return FOUND_NONE;
        }
        
        i = g_sequence_iter_next( i );
    }
    
    // save this layout if it's the best so far
  
	if ( current.height <= output_size_limit ) {
		if ( allow_multiple_sheets )
        {
            if ( best.coverage == 0 || pow(current.coverage, 4.0) * current.area > pow(best.coverage, 4.0) * best.area )
                best = current;
		}
        else if ( best.area == 0 || current.area < best.area || 
				( current.area == best.area &&
                  current.width + current.height <= best.width + best.height ) )
			best = current;
	}
  
    // collect garbage
    
    g_sequence_foreach(leaves_sorted_by_area, (GFunc) free, NULL );
    g_sequence_free( leaves_sorted_by_area );
		
	return f > 0 ? ( nf == 0 ? FOUND_ALL: FOUND_SOME ) : FOUND_NONE;
}

char * json_item ( Item * item )
{
    int a = add_buffer_pixels ? 1 : 0;
    return g_strdup_printf(
        "\n\t\t{ \"x\": %i, \"y\": %i, \"w\": %i, \"h\": %i, \"id\": \"%s\" }",
        item->x + a, item->y + a, item->w - 2*a, item->h - 2*a, item->id );
}

void composite_item( Image * dest, Item * item, ExceptionInfo * exception )
{
    ImageInfo * temp_info = AcquireImageInfo();
    CopyMagickString( temp_info->filename, item->path, MaxTextExtent );
    Image * temp_image = ReadImage( temp_info, exception );
        
    CompositeImage( dest, ReplaceCompositeOp , temp_image,
                   item->x + ( add_buffer_pixels ? 1 : 0 ),
                   item->y + ( add_buffer_pixels ? 1 : 0 ) );
    
    // composite the sprite's buffer pixels onto image
    
    if ( add_buffer_pixels )
    {
        RectangleInfo rects[8] =
            { { 1, item->h - 2,  0, 0 },
              { 1, item->h - 2,  item->w - 3, 0 },
              { item->w - 2, 1,  0, 0 },
              { item->w - 2, 1,  0, item->h - 3 },
              { 1, 1,  0, 0 },
              { 1, 1,  item->w - 3, 0 },
              { 1, 1,  0, item->h - 3 },
              { 1, 1,  item->w - 3, item->h - 3 } };
        int points[16] =
            { 0, 1,  item->w - 1, 1,  1, 0,            1, item->h - 1,
              0, 0,  item->w - 1, 0,  0, item->h - 1,  item->w - 1, item->h - 1 };
        
        int j;
        for (j = 0; j < 8; j++)
        {
            Image * excerpt_image = ExcerptImage( temp_image, &rects[j], exception );
            CompositeImage( dest, ReplaceCompositeOp , excerpt_image,
                            item->x + points[j * 2],
                            item->y + points[j * 2 + 1] );
            DestroyImage( excerpt_image );
        }
    }
    
    DestroyImage( temp_image );
    DestroyImageInfo( temp_info );
}

GString * export_image( char * png_path )
{
    ExceptionInfo * exception   = AcquireExceptionInfo();
    ImageInfo     * output_info  = AcquireImageInfo();
    Image         * output_image = AcquireImage( output_info );
    SetImageExtent ( output_image, best.width, best.height );
    SetImageOpacity( output_image, QuantumRange );
    
    GString * str = g_string_new( "{\n\t\"sprites\": [" );
    gchar ** sprites = calloc( g_sequence_get_length( items ) + 1, sizeof( gchar * ) );
      
    int i = 0;
    GSequenceIter *sj, * si = g_sequence_get_begin_iter( items );
    while ( !g_sequence_iter_is_end( si ) )
    {
        Item * item = g_sequence_get( si );
        
        if ( item->placed == FALSE )
        {
            si = g_sequence_iter_next( si );
            continue;
        }
        
        sprites[i++] = json_item( item );
        composite_item( output_image, item, exception );
        
        sj = g_sequence_iter_next( si );
        g_sequence_remove( si );
        si = sj;
    }
    
    // aggregate json
    
    g_string_append( str, g_strjoinv( ",", sprites ) );
    g_string_append( str, g_strdup_printf( "\n\t],\n\t\"img\": \"%s\"\n}", png_path ) );
    
    // write out the png
      
    CopyMagickString( output_info->filename,  png_path, MaxTextExtent );
    CopyMagickString( output_info->magick,    "png",   MaxTextExtent );
    CopyMagickString( output_image->filename, png_path, MaxTextExtent );
    WriteImage( output_info, output_image );
    
    fprintf( stderr, "%s\n", png_path );
    
    // collect garbage
    
    DestroyExceptionInfo( exception );
    DestroyImageInfo( output_info );
    DestroyImage( output_image );
    
    return str;
}

void export_json ( char * json_path, GString * str )
{
    GFile *json = g_file_new_for_path( json_path );
    g_file_replace_contents  ( json, str->str, str->len, NULL, FALSE,
                               G_FILE_CREATE_NONE, NULL, NULL, NULL );
    g_string_free( str, TRUE );
    
    fprintf( stderr, "Output map to %s\n", json_path );
}

enum {
    DEFAULT,
    SET_INPUT  = 'i',
    SET_OUTPUT = 'o'
};

void handle_arguments ( int argc, char ** argv, GPtrArray * input_patterns )
{
    int i, j, l, state = DEFAULT;
    char * arg;
    
    for ( i = 1; i < argc; i++ )
    {
        arg = argv[i];
        l = strlen( arg );
        if ( (char) arg[0] == '-' )
            for ( j = 1; j < l; j++ )
                switch( (char) arg[j] )
                {
                    case 'i':
                    case 'o':
                        state = arg[j];
                        break;
                    
                    case 'b':
                        add_buffer_pixels = TRUE;
                        state = DEFAULT;
                        break;
                    
                    case 'c':
                        copy_large_images = TRUE;
                        state = DEFAULT;
                        break;
                    
                    case 'm':
                        allow_multiple_sheets = TRUE;
                        state = DEFAULT;
                        break;
                    
                    case 'r':
                        recursive = TRUE;
                        state = DEFAULT;
                        break;
                    
                    case 'h':
                        error("Help & Examples:\n\n"
        "stitcher assets/ui\n"
        "       Will pick up all of the images in the directory assets/ui and create two\n"
        "       files, assets/ui.png (one PNG of all the input images packed together) and\n"
        "       assets/ui.json, a JSON map to each of the packed images. Load this map into\n"
        "       TrickPlay as:\n"
        "           ui = SpriteSheet { map = 'assets/ui.json' }\n"
        "       Then create sprites from it:\n"
        "           sprite = Sprite { sheet = ui, id = 'button-press.png' }\n"
        "       Sprites behave just as if they were loaded from the original image.\n"
        "\n"
        "stitcher assets/ui -i *.png nav/bg-?.jpg 256\n"
        "       Load all PNGs, but only JPGs whose filenames match nav/bg-?.jpg, and filter\n"
        "       out images bigger than 256 pixels on a side.\n"
        "\n"
        "stitcher assets/ui -o sprites/ui 512 -m\n"
        "       Output the JSON map as sprites/ui.json. In addition, spritesheets created\n"
        "       will not be larger than 512 x 512 pixels; instead, extra images will flow\n"
        "       to second and third spritesheets. \n"
        "       (NOTE: -m is not yet supported on the TrickPlay side.)\n"
        "\n"
        "stitcher assets/ui -i 256 -o 512 -bcm\n"
        "       -b creates a 1-pixel buffer around each sprite to prevent scaling problems,\n"
        "       while -c copies over all images that fail the input size filter, 256, as\n"
        "       stand-alone single-image spritesheets.\n");
                        break;
                    
                    default:
                        error( g_strdup_printf( "Error: unknown flag '-%s'\n", (char *) &arg[j] ) );
                        break;
                }
        else
            switch( state )
            {
                case SET_INPUT:
                    for ( j = 0; j < l; j++ )
                        if ( !g_ascii_isdigit( arg[j] ) )
                            break;
                    if ( j == l )
                        input_size_limit = (int) strtol( arg, NULL, 10 );
                    else
                        g_ptr_array_add( input_patterns, g_pattern_spec_new( arg ) );
                    break;
                
                case SET_OUTPUT:
                    for ( j = 0; j < l; j++ )
                        if ( !g_ascii_isdigit( arg[j] ) )
                            break;
                    if ( j == l )
                        output_size_limit = (int) strtol( arg, NULL, 10 );
                    else
                        output_path = arg;
                    break;
                
                default:
                    if ( i == 1 )
                        input_path = arg;
                    else
                        error( "Error: ambiguous input path\n" );
                    break;
            }
    }
}

int main ( int argc, char ** argv )
{
    g_type_init();
    GPtrArray * input_patterns = g_ptr_array_new_with_free_func( (GDestroyNotify) g_pattern_spec_free );
    large_images   = g_ptr_array_new_with_free_func( (GDestroyNotify) free );
    
    handle_arguments( argc, argv, input_patterns );
    
    if ( input_path == NULL )
        error( "Error: no input path given\n" );
    
    char * last_char = &input_path[strlen( input_path ) - 1];
    if ( * last_char == '/' )
         * last_char = '\0';
      
    if ( output_path == NULL )
         output_path = input_path;
    
    GFile * base = g_file_new_for_commandline_arg( input_path );
    if ( g_file_query_file_type( base, G_FILE_QUERY_INFO_NONE, NULL ) != G_FILE_TYPE_DIRECTORY )
    {
        fprintf( stderr, "Error: input path is not a directory\n" );
        exit( 0 );
    }
      
    MagickCoreGenesis( * argv, MagickTrue );
    
    // load the files
    
    items = g_sequence_new( (GDestroyNotify) free );
    smallest = (Page) { output_size_limit, output_size_limit, 0, 0 };
    load( base, base, input_patterns, recursive );
          
    if ( minimum.width > output_size_limit || minimum.height > output_size_limit )
    {
        fprintf( stderr, "Error: largest input file (%i x %i) won't fit within "
                         "output dimensions (%i x %i).\n",
                 minimum.width, minimum.height, output_size_limit, output_size_limit );
        exit( 0 );
    }
    
    char * json_path = g_strdup_printf( "%s.json", output_path );
    GString * json = g_string_new("");
    int status, i, j = 1;
    
    if ( allow_multiple_sheets )
    {
        g_string_append( json, "[" );
        
        // fit sprites into sheets in the densest way possible, until we run out of sprites
        
        while ( TRUE )
        {
            best = (Page) { 0, 0, 0, 0 };
    
            // iterate to find a good layout
            
            for ( i = minimum.width; i <= output_size_limit; i += output_size_step )
                recalculate_layout( i, FALSE );
            status = recalculate_layout( best.width, TRUE );
            
            if ( status == FOUND_NONE )
            {
                fprintf( stderr, "Failed to fit any more images.\n" );
                exit( 1 );
            }
            
            fprintf( stderr, "Page %i match (%i x %i pixels, %.4g%% coverage): ",
                     j, best.width, best.height, 100 * best.coverage );
            
            if ( j > 1 )
                g_string_append( json, ",\n" );
                
            GString * str = export_image( g_strdup_printf( "%s-%i.png",  output_path, j ) );
            g_string_append( json, g_string_free( str, FALSE ) );
            
            j++;
            if ( status == FOUND_ALL )
                break;
        }
        
        for ( i = 0; i < large_images->len; i++ )
        {
            Item  * item = g_ptr_array_index( large_images, i );
            char  * name = g_strrstr( item->id, "/" );
            if ( name == NULL )
                name = item->id;
            else
                name += 1; //g_strdup_printf( ".%s", name ); //
            fprintf( stderr, "Name is %s\n", name ); 
            GFile * dest = g_file_new_for_path( name );

            g_file_copy( item->file, dest, G_FILE_COPY_OVERWRITE, NULL, NULL, NULL, NULL );
            g_object_unref( dest );
            
            if ( i > 0 || j > 1 )
                g_string_append( json, ",\n" );
            int a = add_buffer_pixels ? 2 : 0;
            g_string_append( json, g_strdup_printf( "{\n\t\"sprites\": ["
                "\n\t\t{ \"x\": 0, \"y\": 0, \"w\": %i, \"h\": %i, \"id\": \"%s\" }"
                "\n\t],\n\t\"img\": \"%s\"\n}", item->w - a, item->h - a, item->id, name ) );
        }
        
        g_string_append( json, "]");
    }
    else
    {
        if ( minimum.area > output_size_limit * output_size_limit )
        {
            fprintf( stderr, "Error: total area of input files is larger than "
                             "output dimensions (%i x %i).\n",
                     output_size_limit, output_size_limit );
            exit( 0 );
        }
  
        // iterate to find the best layout
        
        int i;
        for ( i = minimum.width; i <= output_size_limit; i += output_size_step )
            recalculate_layout( i, FALSE );
            
        if ( !allow_multiple_sheets && best.area == 0 )
        {
            fprintf( stderr, "Error: can't fit all files within "
                             "output dimensions (%i x %i).\n",
                     output_size_limit, output_size_limit );
            exit( 0 );
        }
        
        recalculate_layout( best.width, TRUE );
        
        fprintf( stderr,"Page match (%i x %i pixels, %.4g%% coverage): ",
                 best.width, best.height, 100.0 * (gfloat) minimum.area / (gfloat) best.area );
        
        json = export_image( g_strdup_printf( "%s.png", output_path ) );
    }
    
    export_json( json_path, json );
    
    g_ptr_array_free( input_patterns, TRUE );
    g_sequence_free( items );
    
    MagickCoreTerminus();
    
    return 0;
}