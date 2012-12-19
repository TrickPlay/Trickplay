#include <gio/gio.h>
#include <json-glib/json-glib.h>
#include <magick/MagickCore.h>
#include <string.h>
#include "state.h"
#include "leaf.h"
#include "item.h"

State * state_new()
{
    State * state       = malloc( sizeof( State ) );

    state->progress     = progress_new();
    state->import_chunk = progress_new_chunk( state->progress, 20.0 );
    state->layout_chunk = progress_new_chunk( state->progress, 40.0 );
    state->export_chunk = progress_new_chunk( state->progress, 40.0 );
    
    state->segregated   = g_ptr_array_new_with_free_func( (GDestroyNotify) item_free );
    state->images       = g_ptr_array_new_with_free_func( (GDestroyNotify) DestroyImage );
    state->infos        = g_ptr_array_new_with_free_func( (GDestroyNotify) DestroyImageInfo );
    state->subsheets    = g_ptr_array_new_with_free_func( g_free );
    state->items        = g_sequence_new( (GDestroyNotify) item_free );
    state->unique       = g_hash_table_new_full( g_str_hash, g_str_equal, g_free, NULL );
    state->url_regex    = g_regex_new( "^(https?|ftp)://", G_REGEX_CASELESS, 0, NULL );
    
    return state;
}

void state_free( State * state )
{
    g_ptr_array_free( state->images, TRUE );
    g_ptr_array_free( state->infos, TRUE );
    g_ptr_array_free( state->segregated, TRUE );
    g_ptr_array_free( state->subsheets, TRUE );
    g_sequence_free ( state->items );
    g_hash_table_destroy( state->unique );
    g_regex_unref( state->url_regex );
    
    progress_free( state->progress );

    free( state );
}

void state_add_subsheet( State * state, const char * json, Image * image, Options * options )
{
    char * path = g_strdup_printf( "%s-%i.png", options->output_path, state->images->len ),
         * base = g_path_get_basename( path );
    
    ImageInfo * info = AcquireImageInfo();
    CopyMagickString( info->filename,  path,  MaxTextExtent );
    CopyMagickString( info->magick,    "png", MaxTextExtent );
    CopyMagickString( image->filename, path,  MaxTextExtent );
    
    g_ptr_array_add( state->images, image );
    g_ptr_array_add( state->infos,  info );
    g_ptr_array_add( state->subsheets, g_strdup_printf( "{\n  \"sprites\": [%s\n  ],\n  \"img\": \"%s\"\n}", json, base ) );
    
    free( path );
    free( base );
}

Item * state_add_image( State * state, const char * id, Image * image, Options * options )
{
    if ( image )
    {
        if ( image->columns <= options->output_size_limit && image->rows <= options->output_size_limit )
        {
            Item * item = item_new_with_source( id, image ),
                 * parent = g_hash_table_lookup( state->unique, item->checksum );
                 
            if ( options->de_duplicate && parent )
            {
                item_add_child( parent, item );
            }
            else
            {
                if ( image->columns <= options->input_size_limit && image->rows <= options->input_size_limit )
                {
                    g_sequence_insert_sorted( state->items, item, item_compare, NULL );
                }
                else
                {
                    fprintf( stdout, "Segregated %s\n", id );
                    g_ptr_array_add( state->segregated, item );
                }
                
                g_hash_table_insert( state->unique, item->checksum, item );
            }
            
            return item;
        }
        else
        {
            fprintf( stderr, "Image %s (%i x %i) is larger than the maximum texture size (%i x %i).",
                id, (int) image->columns, (int) image->rows, options->output_size_limit, options->output_size_limit );
        }
    }
    
    return NULL;
}

void state_add_file ( State * state, GFile * file, GFile * root, const char * root_path, Options * options )
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
                state_add_file( state, child, root, root_path, options );
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
                    state_add_image( state, id, source, options );
                }
                
                DestroyImageInfo( input_info );
                DestroyExceptionInfo( exception );
                free( path );
            }
            
        free( id );
    }

    g_object_unref( info );
}

void state_merge_json ( State * state, const char * path, Options * options )
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

        if ( g_regex_match( state->url_regex, img, 0, NULL ) )
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
                g_ptr_array_add( state->subsheets, g_strdup_printf(
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
            
            gboolean destroy_source_image = TRUE;
            GQueue * queue = g_queue_new();

            for ( guint j = 0; j < lj; j++ )
            {
                JsonObject * sprite = json_array_get_object_element( sprites, j );
                char * id = (char *) json_object_get_string_member( sprite, "id" );

                if ( options_take_unique_id( options, id ) )
                {
                    int w = json_object_get_int_member( sprite, "w" ),
                        h = json_object_get_int_member( sprite, "h" ),
                        x = json_object_get_int_member( sprite, "x" ),
                        y = json_object_get_int_member( sprite, "y" );
                       
                    Leaf * parent;
                    
                    while ( ( parent = g_queue_peek_head( queue ) ) && (
                        x < parent->x || parent->x + parent->w < x + w ||
                        y < parent->y || parent->y + parent->h < y + h ) )
                    {
                        free( parent );
                        g_queue_pop_head( queue );
                    }
                    
                    Leaf * leaf = leaf_new( (unsigned) x, (unsigned) y, (unsigned) w, (unsigned) h );
                    g_queue_push_head( queue, leaf );
                    
                    if ( parent )
                    {
                        leaf->item = item_add_child_new( parent->item, id, x - parent->x, y - parent->y, w, h );
                    }
                    else
                    {
                        if ( x == 0 && y == 0 && w == source_image->columns && h == source_image->rows )
                        {
                            destroy_source_image = FALSE;
                            leaf->item = state_add_image( state, id, source_image, options );
                        }
                        else
                        {
                            RectangleInfo rect = { (size_t) w, (size_t) h, (size_t) x, (size_t) y };
                            leaf->item = state_add_image( state, id, ExcerptImage( source_image, &rect, exception ), options );
                        }
                    }
                }
            }

            g_queue_free( queue );

            if ( destroy_source_image ) DestroyImage( source_image );
            DestroyImageInfo( source_info );
            DestroyExceptionInfo( exception );
        }
    }

    g_object_unref( json );
}

void state_load_inputs( State * state, Options * options )
{
    // load regular inputs

    for ( unsigned i = 0; i < options->input_paths->len; i++ )
    {
        char * path = (char *) g_ptr_array_index( options->input_paths, i );
        if ( g_regex_match( state->url_regex, path, 0, NULL ) )
        {
            char * id = g_path_get_basename( path );
            if ( options_take_unique_id( options, id ) )
            {
                g_ptr_array_add( state->subsheets, g_strdup_printf("{\n  \"sprites\": ["
                    "\n    { \"x\": 0, \"y\": 0, \"w\": -1, \"h\": -1, \"id\": \"%s\" }"
                    "\n  ],\n  \"img\": \"%s\"\n}", id, path ) );
            }
            
            free( id );
        }
        else
        {
            GFile * root = g_file_new_for_commandline_arg( path );
            state_add_file( state, root, root, path, options );
            g_object_unref( root );
        }
    }

    // load the json files of spritesheets to merge

    for ( unsigned i = 0; i < options->json_to_merge->len; i++ )
    {
        state_merge_json ( state, (char *) g_ptr_array_index( options->json_to_merge, i ), options );
    }
}

void image_composite_leaf( Image * dest, Leaf * leaf, Options * options )
{
    Item * item = leaf->item;
    
    unsigned bp = options->add_buffer_pixels ? 1 : 0;
    CompositeImage( dest, ReplaceCompositeOp , item->source, leaf->x + bp, leaf->y + bp );

    // composite the sprite's buffer pixels onto image

    if ( options->add_buffer_pixels )
    {
        RectangleInfo rects[8] =
            {
                { 1,            item->h - 0,            0,           0 },
                { 1,            item->h - 0,  item->w - 1,           0 },
                { item->w - 0,            1,            0,           0 },
                { item->w - 0,            1,            0, item->h - 1 },
                { 1,                      1,            0,           0 },
                { 1,                      1,  item->w - 1,           0 },
                { 1,                      1,            0, item->h - 1 },
                { 1,                      1,  item->w - 1, item->h - 1 }
            };
        
        int points[16] =
            {
                0, 1,
                item->w + 1, 1,
                1, 0,
                1, item->h + 1,
                0, 0,
                item->w + 1, 0,
                0, item->h + 1,
                item->w + 1, item->h + 1
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

void state_add_layout ( State * state, Layout * layout, Options * options )
{
    ExceptionInfo * exception = AcquireExceptionInfo();
    Image         * image  = AcquireImage( NULL );
    SetImageExtent ( image, layout->width, layout->height );
    SetImageOpacity( image, QuantumRange );
    
    fprintf( stdout,"Page match (%i x %i pixels, %.4g%% coverage)\n",
             layout->width, layout->height, 100.0f * layout->coverage );

    // composite output png

    unsigned bp = options->add_buffer_pixels ? 1 : 0;
    unsigned i = layout->places->len;
    char ** sprites = g_new0( char *, i + 1 );

    while ( i-- )
    {
        Leaf * leaf = (Leaf *) g_ptr_array_index( layout->places, i );
        sprites[i] = item_to_string( leaf->item, leaf->x + bp, leaf->y + bp, 0 );

        image_composite_leaf( image, leaf, options );
        g_sequence_remove_sorted( state->items, leaf->item, item_compare, NULL );
    }

    // append to json

    char * json = g_strjoinv( ",", sprites );
    state_add_subsheet( state, json, image, options );

    // collect garbage
    
    free( json );
    g_strfreev( sprites );

    DestroyExceptionInfo( exception );
}

void state_export_files ( State * state, Options * options )
{
    for ( unsigned i = state->segregated->len; i--; )
    {
        Item * item = (Item *) g_ptr_array_index( state->segregated, i );
        char * json = item_to_string( item, 0, 0, 0 );
        state_add_subsheet( state, json, item->source, options );
        item->source = NULL;
        
        free( json );
    }
    
    for ( unsigned i = state->images->len; i--; )
    {
        WriteImage( (ImageInfo *) g_ptr_array_index( state->infos, i ),
                    (Image     *) g_ptr_array_index( state->images, i ) );
    }
    
    g_ptr_array_set_size( state->subsheets, (int) state->subsheets->len + 1 );
    char * json = g_strdup_printf( "[%s]", g_strjoinv( ",\n", (char **) state->subsheets->pdata ) );

    if ( json )
    {
        char * path = g_strdup_printf( "%s.json", options->output_path );
        g_file_set_contents( path, json, strlen( json ), NULL );

        fprintf( stdout, "Output map to %s\n", path );
        free( path );
    }
    
    free( json );
}
