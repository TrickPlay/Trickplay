#include <glib.h>
#include <json-glib/json-glib.h>
#include "main.h"
#include "leaf.h"
#include "item.h"

Output * output_new()
{
    Output * output      = malloc( sizeof( Output ) );
    
    output->minimum  = (Page) { 0, 0, 0 };
    output->smallest = (Page) { 0, 0, 0 };
    
    output->large_images = g_ptr_array_new_with_free_func( g_free );
    output->images       = g_ptr_array_new_with_free_func( (GDestroyNotify) DestroyImage );
    output->infos        = g_ptr_array_new_with_free_func( (GDestroyNotify) DestroyImageInfo );
    output->subsheets    = g_ptr_array_new_with_free_func( g_free );
    output->items        = g_sequence_new( (GDestroyNotify) item_free );
    return output;
}

void output_free( Output * output )
{
    g_ptr_array_free( output->images, TRUE );
    g_ptr_array_free( output->infos, TRUE );
    g_ptr_array_free( output->large_images, TRUE );
    g_ptr_array_free( output->subsheets, TRUE );
    g_sequence_free ( output->items );
    free( output );
}

unsigned int gcf( unsigned int a, unsigned int b )
{
    unsigned int t;
    if ( b > a )
    {
        t = b;
        b = a;
        a = t;
    }
    while ( b != 0 )
    {
        t = b;
        b = a % b;
        a = t;
    }
    return a;
}

void output_add_item ( Output * output, Item * item, Options * options )
{
    if ( item != NULL )
    {
        if ( item->w <= options->input_size_limit && item->h <= options->input_size_limit )
            g_sequence_insert_sorted( output->items, item, item_compare, NULL );
        else if ( options->copy_large_images &&
                  options->allow_multiple_sheets &&
                  item->w <= options->output_size_limit &&
                  item->h <= options->output_size_limit )
            g_ptr_array_add( output->large_images, item );
        
        output->minimum.area   += item->area;
        output->minimum.width   = MAX( output->minimum.width,   item->w );
        output->minimum.height  = MAX( output->minimum.height,  item->h );
        output->smallest.width  = MIN( output->smallest.width,  item->w );
        output->smallest.height = MIN( output->smallest.height, item->w );
        
        output->size_step = output->size_step ? item->w : gcf( item->w, output->size_step );
    }
}

void output_add_file ( Output * output, GFile * file, GFile * root, const char * root_path, Options * options )
{
    GFileInfo * info = g_file_query_info( file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );
    GFileType type = g_file_info_get_file_type( info );

    if ( type == G_FILE_TYPE_DIRECTORY )
    {
        if ( file == root || options->recursive )
        {
            GFileEnumerator * children = g_file_enumerate_children( file,
                        "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );
            
            GFileInfo * child_info;
            while (( child_info = g_file_enumerator_next_file( children, NULL, NULL ) ))
            {
                GFile * child = g_file_get_child( file, g_file_info_get_name( child_info ) );
                output_add_file( output, child, root, root_path, options );
                g_object_unref( child_info );
            }
    
            g_file_enumerator_close( children, NULL, NULL );
            g_object_unref( children );
        }
        
        g_object_unref( file );
    }
    else if ( type == G_FILE_TYPE_REGULAR )
    {
        char * id  = ( file != root )
                   ? g_file_get_relative_path( root, file )
                   : g_path_get_basename( root_path );

        if ( file == root || options_allows_id( options, id ) )
            if ( options_take_unique_id( options, id ) )
            {
                const char * dir = ( file != root ) ? root_path : NULL;
                output_add_item( output, item_new_from_file( id, dir, file, options ), options );
            }
    }

    g_object_unref( info );
}

void output_merge_json ( Output * output, const char * path, Options * options )
{
    JsonParser * json = json_parser_new();
    gboolean loaded = json_parser_load_from_file( json, path, NULL );
    if ( !loaded )
    {
        error( g_strdup_printf( "Error: could not load spritesheet %s as json.\n", path ) );
        exit(1);
    }

    JsonObject * root = json_node_get_object( json_parser_get_root( json ) );

    char * img = g_build_filename( g_path_get_dirname( path ),
        json_object_get_string_member( root, "img" ), NULL );

    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo * source_info = AcquireImageInfo();
    CopyMagickString( source_info->filename, img, MaxTextExtent );
    Image * source_image = ReadImage( source_info, exception );

    if ( exception->severity != UndefinedException )
    {
        fprintf( stderr, "Could not load source image of spritesheet %s, %s.\n", path, img );
        exit( 1 );
    }

    JsonArray * sprites = json_object_get_array_member( root, "sprites" );
    int length = json_array_get_length( sprites );

    int i;

    for ( i = 0; i < length; i++ )
    {
        JsonObject * sprite = json_array_get_object_element( sprites, i );
        char * id = (char *) json_object_get_string_member( sprite, "id" );

        if ( options_take_unique_id( options, id ) )
        {
            RectangleInfo rect = {
                json_object_get_int_member( sprite, "w" ),
                json_object_get_int_member( sprite, "h" ),
                json_object_get_int_member( sprite, "x" ),
                json_object_get_int_member( sprite, "y" )
            };

            Item * item = item_new( id );
            item_set_source( item, ExcerptImage( source_image, &rect, exception ), options );
            output_add_item( output, item, options );
        }
    }

    DestroyImage( source_image );
    DestroyImageInfo( source_info );
    DestroyExceptionInfo( exception );
    g_object_unref( json );
}

void output_load_inputs( Output * output, Options * options )
{
    if ( options->input_paths->len == 0 )
        error( "Error: no input paths given\n" );

    if ( output->path == NULL )
         output->path = g_ptr_array_index( options->input_paths, 0 );
    
    unsigned int i, length = options->input_paths->len;
    output->smallest = (Page) { options->output_size_limit, options->output_size_limit, 0 };

    // load regular inputs

    for ( i = 0; i < length; i++ )
    {
        char  * path = (char *) g_ptr_array_index( options->input_paths, i );
        GFile * root = g_file_new_for_commandline_arg( path );
        output_add_file( output, root, root, path, options );
    }

    // load the json files of spritesheets to merge
    
    length = options->json_to_merge->len;
    for ( i = 0; i < length; i++ )
    {
        output_merge_json ( output, (char *) g_ptr_array_index( options->json_to_merge, i ), options );
    }

    if ( output->minimum.width > options->output_size_limit || output->minimum.height > options->output_size_limit )
    {
        fprintf( stderr, "Error: largest input file (%i x %i) won't fit within "
                         "output dimensions (%i x %i).\n",
                 output->minimum.width, output->minimum.height, options->output_size_limit, options->output_size_limit );
        exit( 0 );
    }
}

void image_composite_leaf( Image * dest, Leaf * leaf, Options * options )
{
    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo     * temp_info = AcquireImageInfo();
    Image         * temp_image;

    if ( leaf->item->path )
    {
        CopyMagickString( temp_info->filename, leaf->item->path, MaxTextExtent );
        temp_image = ReadImage( temp_info, exception );
    }
    else
    {
        temp_image = leaf->item->source;
    }
    
    if ( temp_image )
    {
        unsigned int bp = options->add_buffer_pixels ? 1 : 0;
        CompositeImage( dest, ReplaceCompositeOp , temp_image, leaf->x + bp, leaf->y + bp );
    
        // composite the sprite's buffer pixels onto image
    
        if ( options->add_buffer_pixels )
        {
            Item * item = leaf->item;
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
                CompositeImage( dest, ReplaceCompositeOp, excerpt_image,
                                leaf->x + points[j * 2],
                                leaf->y + points[j * 2 + 1] );
                DestroyImage( excerpt_image );
            }
        }
    }
    
    if ( leaf->item->path )
        DestroyImage( temp_image );
    DestroyImageInfo( temp_info );
    DestroyExceptionInfo( exception );
}

void output_add_subsheet ( Output * output, Layout * layout, const char * png_path, Options * options )
{
    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo     * ss_info   = AcquireImageInfo();
    Image         * ss_image  = AcquireImage( ss_info );
    SetImageExtent ( ss_image, layout->width, layout->height );
    SetImageOpacity( ss_image, QuantumRange );
    
    fprintf( stderr,"Page match (%i x %i pixels, %.4g%% coverage): ",
             layout->width, layout->height, 100.0f * layout->coverage );
    
    // composite output png
    
    gchar ** sprites = calloc( layout->places->len + 1, sizeof( gchar * ) );
    
    unsigned int i, length = layout->places->len;
    for ( i = 0; i < length; i++ )
    {
        Leaf * leaf = (Leaf *) g_ptr_array_index( layout->places, i );
        sprites[i] = leaf_tostring( leaf, options );
        image_composite_leaf( ss_image, leaf, options );
        leaf->item->placed = TRUE;
    }
    
    // append to json
    
    g_ptr_array_add( output->subsheets, g_strdup_printf(
        "{\n\t\"sprites\": [%s\n\t],\n\t\"img\": \"%s\"\n}", 
        g_strjoinv( ",", sprites ), g_path_get_basename( png_path ) ) );
    
    // tell the image where to save
    
    CopyMagickString( ss_info->filename,  png_path, MaxTextExtent );
    CopyMagickString( ss_info->magick,    "png",    MaxTextExtent );
    CopyMagickString( ss_image->filename, png_path, MaxTextExtent );
    
    g_ptr_array_add( output->images, ss_image );
    g_ptr_array_add( output->infos,  ss_info );
    
    fprintf( stderr, "%s\n", png_path );
    
    // collect garbage
    
    DestroyExceptionInfo( exception );
}

void output_export_files ( Output * output, Options * options )
{
    unsigned int i, length = output->large_images->len;
    for ( i = 0; i < length; i++ )
    {
        Item  * item = g_ptr_array_index( output->large_images, i );
        GFile * dest = g_file_new_for_path( item->id );

        g_file_copy( item->file, dest, G_FILE_COPY_OVERWRITE, NULL, NULL, NULL, NULL );
        g_object_unref( dest );
        
        int a = options->add_buffer_pixels ? 2 : 0;
        g_ptr_array_add( output->subsheets, g_strdup_printf( "{\n\t\"sprites\": ["
            "\n\t\t{ \"x\": 0, \"y\": 0, \"w\": %i, \"h\": %i, \"id\": \"%s\" }"
            "\n\t],\n\t\"img\": \"%s\"\n}", item->w - a, item->h - a, item->id, item->id ) );
    }
    
    length = output->images->len;
    for ( i = 0; i < length; i++ )
    {
        WriteImage( (ImageInfo *) g_ptr_array_index( output->infos, i ),
                    (Image     *) g_ptr_array_index( output->images, i ) );
    }
    
    char  * json;
    g_ptr_array_set_size( output->subsheets, output->subsheets->len + 1 );
    if ( options->allow_multiple_sheets )
        json = g_strdup_printf( "[%s]", g_strjoinv( ",\n", (char **) output->subsheets->pdata ) );
    else
        json = output->subsheets->pdata[0];
        
    if ( json )
    {
        char  * path = g_strdup_printf( "%s.json", output->path );
        GFile * file = g_file_new_for_path( path );
        g_file_replace_contents( file, json, strlen( json ), NULL, FALSE,
                                 G_FILE_CREATE_NONE, NULL, NULL, NULL );
        
        fprintf( stderr, "Output map to %s\n", path );
        g_object_unref( file );
    }
}