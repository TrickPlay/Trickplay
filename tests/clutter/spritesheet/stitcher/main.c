#include <gio/gio.h>
#include <magick/MagickCore.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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
        "                 spritesheets (if they fit within the maximum output size)\n"
        "\n"
        "   -i [filter]   Filter which files to include. Name filters can use the\n"
        "                 wildcards * (zero or more chars) and ? (one char).\n"
        "                 Multiple space-seperated name filters can be passed.\n"
        "      [int]      One integer size filter can be passed, such as 256, to\n"
        "                 prevent large images from being included in a spritesheet.\n"
        "\n"
        "   -m            Divide sprites among multiple spritesheets if they don't fit\n"
        "                 within the maximum dimensions\n"
        "\n"
        "   -o [path]     Set the path of the output files, which will have\n"
        "                 sequential numbers and a .png or .json extension appended.\n"
        "      [int]      Pass an integer like 4096 to set the maximum .png size\n"
        "\n"
        "   -r            Recursively include subdirectories.\n"
        "\n"
        "Ex: stitcher assets/ui -i *.png nav/bg-?.jpg 256 -o sprites/ui 1024 -bcr\n", msg );
	exit( 0 );
}

char * base_path = NULL,
     * outputPath = NULL;

typedef struct Page {
    int width,
        height,
        area;
    float coverage;
} Page;
Page current,
     minimum = { 0, 0, 0, 0 },
     best    = { 0, 0, 0, 0 };

GFile        * base;
GPtrArray    * input_patterns;
GSequence    * items,
             * leaves_sorted_by_area;
GHashTable   * leaves_of_width,
             * leaves_of_height;

int input_size_limit  = 4096,
    output_size_limit = 4096;
	
gboolean allow_multiple_sheets = FALSE,
         copy_large_images     = FALSE,
         add_buffer_pixels     = FALSE,
         recursive             = FALSE;

typedef struct Item {
  int x, y, w, h, area;
  char * id,
       * path;
  gboolean placed;
} Item;

Item * item_new ( char * path )
{
    Item * item = malloc( sizeof( Item ) );
    item->id = path;
    GString * str = g_string_new( base_path );
    g_string_append( str, "/" );
    g_string_append( str, path );
    item->path = g_string_free( str, FALSE );
    item->placed = FALSE;
    
    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo * inputInfo = AcquireImageInfo();
    CopyMagickString( inputInfo->filename, item->path, MaxTextExtent );
    Image * tempImage = PingImage( inputInfo, exception );
    
    if ( exception->severity != UndefinedException )
        return NULL;
    
    item->x = 0;
    item->y = 0;
    item->w = (int) tempImage->columns + (add_buffer_pixels ? 2 : 0);
    item->h = (int) tempImage->rows + (add_buffer_pixels ? 2 : 0);
    item->area = item->w * item->h;
    minimum.area += item->area;
    minimum.width = MAX(minimum.width, item->w);
    minimum.height = MAX(minimum.height, item->h);
    
    DestroyImage(tempImage);
    DestroyExceptionInfo(exception);
    
    return item;
}

gint item_compare_area ( gconstpointer a, gconstpointer b, gpointer user_data )
{
    Item * aa = (Item *) a, * bb = (Item *) b;
    return MAX( bb->w, bb->h ) - MAX( aa->w, aa->h );
}

void load ( GFile * file )
{
    GFileInfo * info = g_file_query_info( file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );
    GFileType type = g_file_info_get_file_type( info );
    
    if ( type == G_FILE_TYPE_DIRECTORY )
    {
        if ( file != base && !recursive )
            return;
        
        GFileEnumerator * children = g_file_enumerate_children( file ,"standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );
        GFileInfo * childInfo;
        GFile * child;
        
        while ( ( childInfo = g_file_enumerator_next_file( children, NULL, NULL ) ) != NULL )
        {
            child = g_file_get_child( file, g_file_info_get_name( childInfo ) );
            load( child );
            g_object_unref( child );
            g_object_unref( childInfo );
        }
        
        g_file_enumerator_close( children, NULL, NULL );
        g_object_unref( children );
        
    } else if ( file == base )
    {
        fprintf( stderr,"Error: input path is not a directory.\n" );
        exit( 1 );
        
    } else if ( type == G_FILE_TYPE_REGULAR )
    {
        char * path = g_file_get_relative_path( base,file );
        int i;
        for ( i = 0; i < input_patterns->len; i++ )
            if ( g_pattern_match_string( g_ptr_array_index(input_patterns, i), path ) )
                break;
        
        if ( i == 0 || i < input_patterns->len ) {
            Item * item = item_new( path );
            if ( item != NULL )
                if ( item->w < input_size_limit && item->h < input_size_limit )
                    g_sequence_insert_sorted( items, item, item_compare_area, NULL );
        }
    }
}

GSequence * get_sequence ( GHashTable * table, int key )
{
    gpointer ptr = GINT_TO_POINTER( key + 1 );
    
    GSequence * seq = g_hash_table_lookup( table, ptr );
    if ( seq == NULL )
        g_hash_table_insert( table, ptr, ( seq = g_sequence_new( NULL ) ) );
    
    return seq;
}

#define AREA GINT_TO_POINTER(1)
#define WIDTH GINT_TO_POINTER(2)
#define HEIGHT GINT_TO_POINTER(3)

typedef struct Leaf {
    int x, y, w, h, area;
} Leaf;

int leaf_compare ( gconstpointer a, gconstpointer b, gpointer user_data )
{
    Leaf * aa = (Leaf *) a, * bb = (Leaf *) b;
    return user_data == AREA   ? aa->area - bb->area :
           user_data == WIDTH  ? aa->w    - bb->w    :
           user_data == HEIGHT ? aa->h    - bb->h    : 0;
}

void g_sequence_remove_sorted ( GSequence * seq, gpointer data, GCompareDataFunc cmp_func, gpointer cmp_data )
{
    gpointer found;
    GSequenceIter * sj, * si = g_sequence_lookup( seq, data, cmp_func, cmp_data );
    if ( si == NULL )
        return;
    
    sj = si;
    while ( !g_sequence_iter_is_end( sj ) )
    {
        found = g_sequence_get( sj );
        if ( found == data )
            return g_sequence_remove( sj );
        else if ( cmp_func( found, data, cmp_data ) != 0 )
            break;
        sj = g_sequence_iter_next( sj );
    }
    
    sj = si;
    while ( !g_sequence_iter_is_begin( sj ) )
    {
        sj = g_sequence_iter_prev( sj );
        found = g_sequence_get( sj );
        if ( found == data )
            return g_sequence_remove( sj );
        else if ( cmp_func( found, data, cmp_data ) != 0 )
            break;
    }
}

Leaf * leaf_new ( int x, int y, int w, int h )
{
    Leaf * leaf = malloc( sizeof( Leaf ) );
    leaf->x = x;
    leaf->y = y;
    leaf->w = w;
    leaf->h = h;
    leaf->area = w * h;
    
    g_sequence_insert_sorted( leaves_sorted_by_area, leaf, leaf_compare, AREA );
    g_sequence_insert_sorted( get_sequence( leaves_of_width,  leaf->w ), leaf, leaf_compare, WIDTH  );
    g_sequence_insert_sorted( get_sequence( leaves_of_height, leaf->h ), leaf, leaf_compare, HEIGHT );
    
    return leaf;
}

void leaf_cut ( Leaf * leaf, int w, int h )
{
    gboolean b = leaf->w - w > leaf->h - h;
    if ( leaf->w - w > ( add_buffer_pixels ? 2 : 0 ) )
        leaf_new( leaf->x + w, leaf->y, leaf->w - w, b ? leaf->h : h );
    if ( leaf->h - h > ( add_buffer_pixels ? 2 : 0 ) )
        leaf_new( leaf->x, leaf->y + h, b ? w : leaf->w, leaf->h - h );
    
    g_sequence_remove_sorted( leaves_sorted_by_area, leaf, leaf_compare, AREA );
    g_sequence_remove_sorted( get_sequence( leaves_of_width,  leaf->w ), leaf, leaf_compare, WIDTH  );
    g_sequence_remove_sorted( get_sequence( leaves_of_height, leaf->h ), leaf, leaf_compare, HEIGHT );
    
    free( leaf );
}

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
    leaves_of_width  = g_hash_table_new_full( g_direct_hash, g_direct_equal, NULL, (GDestroyNotify) g_sequence_free );
    leaves_of_height = g_hash_table_new_full( g_direct_hash, g_direct_equal, NULL, (GDestroyNotify) g_sequence_free );
    leaf_new( 0, 0, MAX( width, minimum.width ), output_size_limit * ( allow_multiple_sheets ? 1 : 2 ) );
    
    GSequenceIter * i = g_sequence_get_begin_iter( items );
    while ( !g_sequence_iter_is_end( i ) )
    {
        Item * item = (Item *) g_sequence_get( i );
        Leaf * leaf;
        GSequenceIter * si;
        
        if ( item->placed == TRUE )
        {
            i = g_sequence_iter_next( i );
            continue;
        }
        
        /* among leaves exactly as wide as the item, looks for the first leaf tall enough to hold it
         * else, among leaves exactly as tall as the item, looks for the first leaf wide enough to hold it
         * else, starting with the first leaf larger than the item, looks for the first leaf that can hold it
         */
        
        si = g_sequence_search( get_sequence( leaves_of_width, item->w ), item, leaf_compare, HEIGHT );
        if ( g_sequence_iter_is_end( si ) )
            si = g_sequence_search( get_sequence( leaves_of_height, item->h ), item, leaf_compare, WIDTH );
          
        if ( !g_sequence_iter_is_end( si ) )
        {
            f++;
            insert_item(item, g_sequence_get(si), finalize);
        }
        else
        {
            si = g_sequence_search( leaves_sorted_by_area, item, leaf_compare, AREA );
            gboolean found = FALSE;
            while ( !g_sequence_iter_is_end( si ) )
            {
                leaf = g_sequence_get( si );
                if ( leaf->w > item->w && leaf->h > item->h )
                {
                    f++;
                    insert_item( item, leaf, finalize );
                    found = TRUE;
                    break;
                }
                si = g_sequence_iter_next( si );
            }
            if ( !found )
            {
                if ( allow_multiple_sheets )
                    nf++;
                else
                    return FOUND_NONE;
            }
        }
        i = g_sequence_iter_next( i );
    }
    
    // save this layout if it's the best so far
  
	if ( current.height <= output_size_limit ) {
		if ( allow_multiple_sheets )
        {
            if ( best.coverage == 0 || current.coverage > best.coverage )
                best = current;
		}
        else if ( best.area == 0 || current.area < best.area || 
				( current.area == best.area &&
                  current.width + current.height <= best.width + best.height ) )
			best = current;
	}
  
    // collect garbage
    
    g_sequence_foreach(leaves_sorted_by_area, (GFunc) free, NULL );
    g_hash_table_destroy( leaves_of_width  );
    g_hash_table_destroy( leaves_of_height );
    g_sequence_free( leaves_sorted_by_area );
		
	return f > 0 ? ( nf == 0 ? FOUND_ALL: FOUND_SOME ) : FOUND_NONE;
}

void export_image( char * jsonPath, char * pngPath )
{
    ExceptionInfo * exception   = AcquireExceptionInfo();
    ImageInfo     * outputInfo  = AcquireImageInfo();
    Image         * outputImage = AcquireImage( outputInfo );
    SetImageExtent ( outputImage, best.width, best.height );
    SetImageOpacity( outputImage, QuantumRange );
    
    GString * str = g_string_new( "{\n\t\"sprites\": [" );
    gchar ** sprites = calloc( g_sequence_get_length( items ) + 1, sizeof( gchar * ) );
      
    int i = 0, j;
    GSequenceIter *sj, * si = g_sequence_get_begin_iter( items );
    while ( !g_sequence_iter_is_end( si ) )
    {
        Item * item = g_sequence_get( si );
        
        if ( item->placed == FALSE )
        {
            si = g_sequence_iter_next( si );
            continue;
        }
        
        // write json
      
        sprites[i++] = g_strdup_printf( "\n\t\t{ \"x\": %i, \"y\": %i, \"w\": %i,"
                                        " \"h\": %i, \"id\": \"%s\" }",
                                        item->x, item->y, item->w, item->h, item->id );
        
          // composite sprite onto output image
        
        ImageInfo * tempInfo = AcquireImageInfo();
        CopyMagickString( tempInfo->filename, item->path, MaxTextExtent );
        Image * tempImage = ReadImage( tempInfo, exception );
            
        CompositeImage( outputImage, ReplaceCompositeOp , tempImage,
                       item->x + ( add_buffer_pixels ? 1 : 0 ),
                       item->y + ( add_buffer_pixels ? 1 : 0 ) );
        
          // composite the sprite's buffer pixels onto image
        
        if ( add_buffer_pixels == TRUE )
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
            
            for (j = 0; j < 8; j++)
            {
                Image * excerptImage = ExcerptImage( tempImage, &rects[j], exception );
                CompositeImage( outputImage, ReplaceCompositeOp , excerptImage,
                                item->x + points[j * 2],
                                item->y + points[j * 2 + 1] );
                DestroyImage( excerptImage );
            }
        }
        
        DestroyImage( tempImage );
        DestroyImageInfo( tempInfo );
        
        // drop this sprite so other sheets don't worry about it
        
        sj = g_sequence_iter_next( si );
        g_sequence_remove( si );
        si = sj;
    }
    
    // collect and write out the json
    
    g_string_append( str, g_strjoinv( ",", sprites ) );
    g_string_append( str, g_strdup_printf( "\n\t],\n\t\"img\": \"%s\"\n}", pngPath ) );
    
    GFile *json = g_file_new_for_path( jsonPath );
    g_file_replace_contents  ( json, str->str, str->len, NULL, FALSE,
                               G_FILE_CREATE_NONE, NULL, NULL, NULL );
    g_string_free( str, TRUE );
    
    // write out the png
      
    CopyMagickString( outputInfo->filename,  pngPath, MaxTextExtent );
    CopyMagickString( outputInfo->magick,    "png",   MaxTextExtent );
    CopyMagickString( outputImage->filename, pngPath, MaxTextExtent );
    WriteImage( outputInfo, outputImage );
    
    fprintf( stderr, "Output map to %s and image to %s\n", jsonPath, pngPath );
    
    // collect garbage
    
    DestroyExceptionInfo( exception );
    DestroyImageInfo( outputInfo );
    DestroyImage( outputImage );
}

enum {
    DEFAULT,
    SET_INPUT  = 'i',
    SET_OUTPUT = 'o'
};

void handle_arguments ( int argc, char ** argv )
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
                    
                    default:
                        fprintf(stderr, "Error: unknown flag '-%s'\n\n", (char *) &arg[j] );
                    case 'h':
                        error("");
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
                        outputPath = arg;
                    break;
                
                default:
                    if ( i == 1 )
                        base_path = arg;
                    else
                        error( "Error: ambiguous input path\n" );
                    break;
            }
    }
}

int main ( int argc, char ** argv )
{
    g_type_init();
    input_patterns = g_ptr_array_new_with_free_func( (GDestroyNotify) g_pattern_spec_free );
    
    handle_arguments( argc, argv );
    
    if ( base_path == NULL )
        error( "Error: no input path given\n" );
    
    char * last_char = &base_path[strlen( base_path ) - 1];
    if ( * last_char == '/' )
         * last_char = '\0';
      
    if ( outputPath == NULL )
         outputPath = base_path;
    
    base = g_file_new_for_commandline_arg( base_path );
    if ( g_file_query_file_type( base, G_FILE_QUERY_INFO_NONE, NULL ) == G_FILE_TYPE_UNKNOWN )
    {
        fprintf( stderr, "Error: input file does not exist\n" );
        exit( 0 );
    }
      
    MagickCoreGenesis( * argv, MagickTrue );
    
    // load the files
    
    items = g_sequence_new( (GDestroyNotify) free );
    load( base );
          
    if ( minimum.width > output_size_limit || minimum.height > output_size_limit )
    {
        fprintf( stderr, "Error: largest input file (%i x %i) won't fit within "
                         "output dimensions (%i x %i).\n",
                 minimum.width, minimum.height, output_size_limit, output_size_limit );
        exit( 0 );
    }
    
    int i, j;
    
    if ( allow_multiple_sheets )
    {
        int status;
        j = 1;
        
        // fit sprites into sheets in the densest way possible, until we run out of sprites
        
        while ( TRUE )
        {
            best = (Page) { 0, 0, 0, 0 };
    
            // iterate to find a good layout
            
            for ( i = minimum.width; i <= output_size_limit; i++ )
                recalculate_layout( i, FALSE );
            status = recalculate_layout( best.width, TRUE );
            
            if ( status == FOUND_NONE )
            {
                fprintf( stderr, "Failed to fit any more images.\n" );
                exit( 1 );
            }
            
            fprintf( stderr, "Page selected: (%i x %i), %f coverage.\n",
                     best.width, best.height, best.coverage );
            
            export_image( g_strdup_printf( "%s-%i.json", outputPath, j ),
                          g_strdup_printf( "%s-%i.png",  outputPath, j ) );
            
            if ( status == FOUND_ALL )
                break;
            j++;
        }
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
        
        for ( i = minimum.width; i <= output_size_limit; i++ )
            recalculate_layout( i, FALSE );
            
        if ( !allow_multiple_sheets && best.area == 0 )
        {
            fprintf( stderr, "Error: can't fit all files within "
                             "output dimensions (%i x %i).\n",
                     output_size_limit, output_size_limit );
            exit( 0 );
        }
        
        recalculate_layout( best.width, TRUE );
        
        fprintf( stderr,"Best match coverage: %i x %i pixels, %.4g%% match\n",
                 best.width, best.height, 100.0 * (gfloat) minimum.area / (gfloat) best.area );
        
        export_image( g_strdup_printf( "%s.json", outputPath ),
                      g_strdup_printf( "%s.png",  outputPath ) );
    }
    
    g_ptr_array_free( input_patterns, TRUE );
    g_sequence_free( items );
    
    MagickCoreTerminus();
    
    return 0;
}