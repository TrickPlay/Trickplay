#include <gio/gio.h>
#include <json-glib/json-glib.h>
#include <magick/MagickCore.h>
#include <string.h>
#include "output.h"
#include "leaf.h"
#include "item.h"

Output * output_new()
{
    Output * output      = malloc( sizeof( Output ) );

    output->large_items  = g_ptr_array_new_with_free_func( g_free );
    output->images       = g_ptr_array_new_with_free_func( (GDestroyNotify) DestroyImage );
    output->infos        = g_ptr_array_new_with_free_func( (GDestroyNotify) DestroyImageInfo );
    output->subsheets    = g_ptr_array_new_with_free_func( g_free );
    output->items        = g_sequence_new( (GDestroyNotify) item_free );
    output->url_regex    = g_regex_new( "^(https?|ftp)://", G_REGEX_CASELESS, 0, NULL );
    
    return output;
}

void output_free( Output * output )
{
    g_ptr_array_free( output->images, TRUE );
    g_ptr_array_free( output->infos, TRUE );
    g_ptr_array_free( output->large_items, TRUE );
    g_ptr_array_free( output->subsheets, TRUE );
    g_sequence_free ( output->items );
    g_regex_unref( output->url_regex );

    free( output );
}

void output_add_subsheet( Output * output, const char * json, Image * image, Options * options )
{
    char * path = g_strdup_printf( "%s-%i.png", options->output_path, output->images->len ),
         * base = g_path_get_basename( path );
    
    ImageInfo * info = AcquireImageInfo();
    CopyMagickString( info->filename,  path,  MaxTextExtent );
    CopyMagickString( info->magick,    "png", MaxTextExtent );
    CopyMagickString( image->filename, path,  MaxTextExtent );
    
    g_ptr_array_add( output->images, image );
    g_ptr_array_add( output->infos,  info );
    g_ptr_array_add( output->subsheets, g_strdup_printf( "{\n  \"sprites\": [%s\n  ],\n  \"img\": \"%s\"\n}", json, base ) );
    
    fprintf( stdout, "-> %s\n", path );
    
    free( path );
    free( base );
}

void output_add_image( Output * output, const char * id, Image * image, Options * options )
{
    if ( image )
    {
        if ( image->rows <= options->input_size_limit && image->columns <= options->input_size_limit )
        {
            Item * item = item_new_with_source( id, image, options );
            g_sequence_insert_sorted( output->items, item, item_compare, NULL );
        }
        else if ( image->rows <= options->output_size_limit && image->columns <= options->output_size_limit )
        {
            fprintf( stdout, "Segregated %s ", id );
            
            char * json = g_strdup_printf( "\n    { \"x\": 0, \"y\": 0, \"w\": %i, \"h\": %i, \"id\": \"%s\" }",
                (int) image->columns, (int) image->rows, id );
                 
            output_add_subsheet( output, json, image, options );
            free( json );
        }
        else
        {
            fprintf( stderr, "Image %s is larger than maximum texture size.", id );
        }
    }
}

void output_add_file ( Output * output, GFile * file, GFile * root, const char * root_path, Options * options )
{
    GFileInfo * info = g_file_query_info( file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );

    if ( !info )
    {
        fprintf( stderr, "Could not open %s.\n", g_file_get_path( file ) );
        g_object_unref( file );
        return;
    }

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
                g_object_unref( child );
            }

            g_file_enumerator_close( children, NULL, NULL );
            g_object_unref( children );
        }
    }
    else if ( type == G_FILE_TYPE_REGULAR )
    {
        char * id  = ( file != root )
                   ? g_file_get_relative_path( root, file )
                   : g_path_get_basename( root_path );

        if ( file == root || options_allows_id( options, id ) )
            if ( options_take_unique_id( options, id ) )
            {
                char * path = ( file != root ) ? g_build_filename( root_path, id, NULL ) : strdup( id );
                
                ExceptionInfo * exception = AcquireExceptionInfo();
                ImageInfo * input_info = AcquireImageInfo();
                CopyMagickString( input_info->filename, path, MaxTextExtent );
                Image * source = ReadImage( input_info, exception );

                if ( exception->severity == UndefinedException )
                {
                    output_add_image( output, id, source, options );
                }
                
                DestroyImageInfo( input_info );
                DestroyExceptionInfo( exception );
                free( path );
            }
            
        free( id );
    }

    g_object_unref( info );
}

void output_merge_json ( Output * output, const char * path, Options * options )
{
    JsonParser * json = json_parser_new();

    if ( !json_parser_load_from_file( json, path, NULL ) )
    {
        fprintf( stderr, "Could not load JSON file of spritesheet %s.\n", path );
        exit( 1 );
    }

    JsonNode * root = json_parser_get_root( json );

    if ( !JSON_NODE_HOLDS_ARRAY( root ) )
    {
        fprintf( stderr, "Could not parse JSON file of spritesheet %s.\n", path );
        exit( 1 );
    }

    JsonArray * maps = json_node_get_array( root );

    guint li = json_array_get_length( maps );
    for ( guint i = 0; i < li; i++ )
    {
        JsonObject * map = json_array_get_object_element( maps, i );

        const char * img = json_object_get_string_member( map, "img" );
        JsonArray * sprites = json_object_get_array_member( map, "sprites" );
        guint lj = json_array_get_length( sprites );

        if ( g_regex_match( output->url_regex, img, 0, NULL ) )
        {
            GPtrArray * array = g_ptr_array_new_with_free_func( g_free );

            for ( guint j = lj; j--; )
            {
                JsonObject * sprite = json_array_get_object_element( sprites, j );
                const char * id = json_object_get_string_member( sprite, "id" );
                if ( options_take_unique_id( options, id ) )
                {
                    g_ptr_array_add( array, g_strdup_printf(
                        "\n    { \"x\": %li, \"y\": %li, \"w\": %li, \"h\": %li, \"id\": \"%s\" }",
                        json_object_get_int_member( sprite, "x" ),
                        json_object_get_int_member( sprite, "y" ),
                        json_object_get_int_member( sprite, "w" ),
                        json_object_get_int_member( sprite, "h" ), id ) );
                }
            }

            if ( array->len )
            {
                g_ptr_array_set_size( array, array->len + 1 );
                g_ptr_array_add( output->subsheets, g_strdup_printf(
                    "{\n  \"sprites\": [%s\n  ],\n  \"img\": \"%s\"\n}",
                    g_strjoinv( ",\n", (char **) array->pdata ), img ) );
            }

            g_ptr_array_free( array, TRUE );
        }
        else
        {
            char * source = g_build_filename( g_path_get_dirname( path ), img, NULL );

            ExceptionInfo * exception = AcquireExceptionInfo();
            ImageInfo * source_info = AcquireImageInfo();
            CopyMagickString( source_info->filename, source, MaxTextExtent );
            Image * source_image = ReadImage( source_info, exception );

            if ( exception->severity != UndefinedException )
            {
                fprintf( stderr, "Could not load source image %s in spritesheet %s.\n", source, path );
                exit( 1 );
            }
            
            free( source );

            for ( guint j = 0; j < lj; j++ )
            {
                JsonObject * sprite = json_array_get_object_element( sprites, j );
                char * id = (char *) json_object_get_string_member( sprite, "id" );

                if ( options_take_unique_id( options, id ) )
                {
                    // add de-duplication handling
                    
                    int w = json_object_get_int_member( sprite, "w" ),
                        h = json_object_get_int_member( sprite, "h" ),
                        x = json_object_get_int_member( sprite, "x" ),
                        y = json_object_get_int_member( sprite, "y" );
                        
                    if ( x == 0 && y == 0 && w == source_image->columns && h == source_image->rows && lj == 1 )
                    {
                        output_add_image( output, id, source_image, options );
                        source_image = NULL;
                        break;
                    }
                    else
                    {
                        RectangleInfo rect = { (size_t) w, (size_t) h, (size_t) x, (size_t) y };
                        output_add_image( output, id, ExcerptImage( source_image, &rect, exception ), options );
                    }
                }
            }

            if ( source_image ) DestroyImage( source_image );
            DestroyImageInfo( source_info );
            DestroyExceptionInfo( exception );
        }
    }

    g_object_unref( json );
}

void output_load_inputs( Output * output, Options * options )
{
    // load regular inputs

    for ( unsigned i = 0; i < options->input_paths->len; i++ )
    {
        char * path = (char *) g_ptr_array_index( options->input_paths, i );
        if ( g_regex_match( output->url_regex, path, 0, NULL ) )
        {
            char * id = g_path_get_basename( path );
            if ( options_take_unique_id( options, id ) )
            {
                g_ptr_array_add( output->subsheets, g_strdup_printf("{\n  \"sprites\": ["
                    "\n    { \"x\": 0, \"y\": 0, \"w\": -1, \"h\": -1, \"id\": \"%s\" }"
                    "\n  ],\n  \"img\": \"%s\"\n}", id, path ) );
            }
            
            free( id );
        }
        else
        {
            GFile * root = g_file_new_for_commandline_arg( path );
            output_add_file( output, root, root, path, options );
            g_object_unref( root );
        }
    }

    // load the json files of spritesheets to merge

    for ( unsigned i = 0; i < options->json_to_merge->len; i++ )
    {
        output_merge_json ( output, (char *) g_ptr_array_index( options->json_to_merge, i ), options );
    }
}

void image_composite_leaf( Image * dest, Leaf * leaf, Options * options )
{
    Item * item = leaf->item;
    
    if ( !item->source )
    {
        g_message( "!item->source");
    }
    
    unsigned int bp = options->add_buffer_pixels ? 1 : 0;
    CompositeImage( dest, ReplaceCompositeOp , item->source, leaf->x + bp, leaf->y + bp );

    // composite the sprite's buffer pixels onto image

    if ( options->add_buffer_pixels )
    {
        RectangleInfo rects[8] =
            {
                { 1,            item->h - 2,            0,           0 },
                { 1,            item->h - 2,  item->w - 3,           0 },
                { item->w - 2,            1,            0,           0 },
                { item->w - 2,            1,            0, item->h - 3 },
                { 1,                      1,            0,           0 },
                { 1,                      1,  item->w - 3,           0 },
                { 1,                      1,            0, item->h - 3 },
                { 1,                      1,  item->w - 3, item->h - 3 }
            };
        int points[16] =
            {
                0, 1,
                item->w - 1, 1,
                1, 0,
                1, item->h - 1,
                0, 0,
                item->w - 1, 0,
                0, item->h - 1,
                item->w - 1, item->h - 1
            };
            
        ExceptionInfo * exception = AcquireExceptionInfo();

        for ( unsigned j = 0; j < 8; j++ )
        {
            Image * excerpt_image = ExcerptImage( item->source, &rects[j], exception );
            CompositeImage( dest, ReplaceCompositeOp, excerpt_image,
                            leaf->x + points[j * 2],
                            leaf->y + points[j * 2 + 1] );
            DestroyImage( excerpt_image );
        }
        
        DestroyExceptionInfo( exception );
    }

}

void output_add_layout ( Output * output, Layout * layout, Options * options )
{
    ExceptionInfo * exception = AcquireExceptionInfo();
    Image         * image  = AcquireImage( NULL );
    SetImageExtent ( image, layout->width, layout->height );
    SetImageOpacity( image, QuantumRange );
    
    fprintf( stdout,"Page match (%i x %i pixels, %.4g%% coverage) ",
             layout->width, layout->height, 100.0f * layout->coverage );

    // composite output png

    unsigned int i = layout->places->len;
    char ** sprites = g_new0( char *, i + 1 ); //calloc( i + 1, sizeof( gchar * ) );

    while ( i-- )
    {
        Leaf * leaf = (Leaf *) g_ptr_array_index( layout->places, i );
        sprites[i] = leaf_tostring( leaf, options );

        image_composite_leaf( image, leaf, options );
        g_sequence_remove_sorted( output->items, leaf->item, item_compare, NULL );
    }

    // append to json

    char * json = g_strjoinv( ",", sprites );
    output_add_subsheet( output, json, image, options );

    // collect garbage
    
    free( json );
    g_strfreev( sprites );

    DestroyExceptionInfo( exception );
}

void output_export_files ( Output * output, Options * options )
{
    for ( unsigned i = output->images->len; i--; )
    {
        WriteImage( (ImageInfo *) g_ptr_array_index( output->infos, i ),
                    (Image     *) g_ptr_array_index( output->images, i ) );
    }
    
    g_ptr_array_set_size( output->subsheets, (int) output->subsheets->len + 1 );
    char * json = g_strdup_printf( "[%s]", g_strjoinv( ",\n", (char **) output->subsheets->pdata ) );

    if ( json )
    {
        char * path = g_strdup_printf( "%s.json", options->output_path );
        g_file_set_contents( path, json, strlen( json ), NULL );

        fprintf( stdout, "Output map to %s\n", path );
        free( path );
    }
    
    free( json );
}
