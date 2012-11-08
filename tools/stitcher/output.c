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
    
    output->size_step = 0;
    output->max_item_w = 0;
    output->item_area = 0;
    
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
        else if ( options->copy_large_items &&
                  options->allow_multiple_sheets &&
                  item->w <= options->output_size_limit &&
                  item->h <= options->output_size_limit )
            g_ptr_array_add( output->large_items, item );
            
        output->item_area += item->area;
        output->max_item_w = MAX( output->max_item_w,   item->w );
        output->size_step  = output->size_step ? gcf( item->w, output->size_step ) : item->w;
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
    
    if ( !json_parser_load_from_file( json, path, NULL ) )
    {
        fprintf( stderr, "Could not load/parse JSON file of spritesheet %s.\n", path );
        exit( 1 );
    }

    JsonNode * root = json_parser_get_root( json );
    
    if ( !JSON_NODE_HOLDS_ARRAY( root ) )
    {
        fprintf( stderr, "Could not load/parse JSON file of spritesheet %s.\n", path );
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
            GPtrArray * array = g_ptr_array_new();
            
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
                        json_object_get_int_member( sprite, "h" ),
                        json_object_get_string_member( sprite, "id" ) ) );
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
            img = g_build_filename( g_path_get_dirname( path ), img, NULL );
    
            ExceptionInfo * exception = AcquireExceptionInfo();
            ImageInfo * source_info = AcquireImageInfo();
            CopyMagickString( source_info->filename, img, MaxTextExtent );
            Image * source_image = ReadImage( source_info, exception );
        
            if ( exception->severity != UndefinedException )
            {
                fprintf( stderr, "Could not load source image %s in spritesheet %s.\n", img, path );
                exit( 1 );
            }
            
            for ( guint j = 0; j < lj; j++ )
            {
                JsonObject * sprite = json_array_get_object_element( sprites, j );
                char * id = (char *) json_object_get_string_member( sprite, "id" );
        
                if ( options_take_unique_id( options, id ) )
                {
                    RectangleInfo rect = {
                        (size_t)json_object_get_int_member( sprite, "w" ),
                        (size_t)json_object_get_int_member( sprite, "h" ),
                        (size_t)json_object_get_int_member( sprite, "x" ),
                        (size_t)json_object_get_int_member( sprite, "y" )
                    };
        
                    Item * item = item_new( id );
                    item_set_source( item, ExcerptImage( source_image, &rect, exception ), options );
                    output_add_item( output, item, options );
                }
            }
            
            DestroyImage( source_image );
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
        }
        else
        {
            GFile * root = g_file_new_for_commandline_arg( path );
            output_add_file( output, root, root, path, options );
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
    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo     * temp_info = AcquireImageInfo();
    Image         * temp_image;
    Item * item = leaf->item;

    if ( item->path )
    {
        CopyMagickString( temp_info->filename, item->path, MaxTextExtent );
        temp_image = ReadImage( temp_info, exception );
    }
    else
    {
        temp_image = item->source;
    }
    
    if ( temp_image )
    {
        unsigned int bp = options->add_buffer_pixels ? 1 : 0;
        CompositeImage( dest, ReplaceCompositeOp , temp_image, leaf->x + bp, leaf->y + bp );
    
        // composite the sprite's buffer pixels onto image
    
        if ( options->add_buffer_pixels )
        {
            RectangleInfo rects[8] =
                {
                    { 1,            item->h - 2,            0,           0 },
                  { 1, item->h - 2,  item->w - 3, 0 },
                  { item->w - 2, 1,  0, 0 },
                  { item->w - 2, 1,  0, item->h - 3 },
                  { 1, 1,  0, 0 },
                  { 1, 1,  item->w - 3, 0 },
                  { 1, 1,  0, item->h - 3 },
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
    
            for (unsigned j = 0; j < 8; j++)
            {
                Image * excerpt_image = ExcerptImage( temp_image, &rects[j], exception );
                CompositeImage( dest, ReplaceCompositeOp, excerpt_image,
                                leaf->x + points[j * 2],
                                leaf->y + points[j * 2 + 1] );
                DestroyImage( excerpt_image );
            }
        }
    }
    
    if ( item->path )
        DestroyImage( temp_image );
    DestroyImageInfo( temp_info );
    DestroyExceptionInfo( exception );
}

void output_add_layout ( Output * output, Layout * layout, Options * options )
{
    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo     * ss_info   = AcquireImageInfo();
    Image         * ss_image  = AcquireImage( ss_info );
    SetImageExtent ( ss_image, layout->width, layout->height );
    SetImageOpacity( ss_image, QuantumRange );
    
    fprintf( stdout,"Page match (%i x %i pixels, %.4g%% coverage): ",
             layout->width, layout->height, 100.0f * layout->coverage );
    
    // composite output png
    
    unsigned int i = layout->places->len;
    gchar ** sprites = calloc( i + 1, sizeof( gchar * ) );
    
    while ( i-- )
    {
        Leaf * leaf = (Leaf *) g_ptr_array_index( layout->places, i );
        sprites[i] = leaf_tostring( leaf, options );
        
        image_composite_leaf( ss_image, leaf, options );
        g_sequence_remove_sorted( output->items, leaf->item, item_compare, NULL );
    }
    
    // append to json
    
    char * path = g_strdup_printf( "%s-%i.png", options->output_path, output->images->len );
    
    g_ptr_array_add( output->subsheets, g_strdup_printf(
        "{\n  \"sprites\": [%s\n  ],\n  \"img\": \"%s\"\n}", 
        g_strjoinv( ",", sprites ), g_path_get_basename( path ) ) );
    
    // tell the image where to save
    
    CopyMagickString( ss_info->filename,  path,  MaxTextExtent );
    CopyMagickString( ss_info->magick,    "png", MaxTextExtent );
    CopyMagickString( ss_image->filename, path,  MaxTextExtent );
    
    g_ptr_array_add( output->images, ss_image );
    g_ptr_array_add( output->infos,  ss_info );
    
    fprintf( stdout, "%s\n", path );
    
    // collect garbage
    
    DestroyExceptionInfo( exception );
}

void output_export_files ( Output * output, Options * options )
{
    for ( unsigned i = output->large_items->len; i--; )
    {
        Item  * item = g_ptr_array_index( output->large_items, i );
        GFile * dest = g_file_new_for_path( item->id );

        g_file_copy( item->file, dest, G_FILE_COPY_OVERWRITE, NULL, NULL, NULL, NULL );
        g_object_unref( dest );
        
        unsigned a = options->add_buffer_pixels ? 2 : 0;
        g_ptr_array_add( output->subsheets, g_strdup_printf( "{\n  \"sprites\": ["
            "\n    { \"x\": 0, \"y\": 0, \"w\": %i, \"h\": %i, \"id\": \"%s\" }"
            "\n  ],\n  \"img\": \"%s\"\n}", item->w - a, item->h - a, item->id, item->id ) );
    }
    
    for ( unsigned i = output->images->len; i--; )
    {
        WriteImage( (ImageInfo *) g_ptr_array_index( output->infos, i ),
                    (Image     *) g_ptr_array_index( output->images, i ) );
    }
    
    char  * json;
    g_ptr_array_set_size( output->subsheets, (gint)output->subsheets->len + 1 );
    json = g_strdup_printf( "[%s]", g_strjoinv( ",\n", (char **) output->subsheets->pdata ) );
    
    if ( json )
    {
        char  * path = g_strdup_printf( "%s.json", options->output_path );
        GFile * file = g_file_new_for_path( path );
        g_file_replace_contents( file, json, strlen( json ), NULL, FALSE,
                                 G_FILE_CREATE_NONE, NULL, NULL, NULL );
        
        fprintf( stdout, "Output map to %s\n", path );
        g_object_unref( file );
    }
}