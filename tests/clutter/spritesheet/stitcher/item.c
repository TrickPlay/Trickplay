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
    GString * str = g_string_new( input_path );
    g_string_append( str, "/" );
    g_string_append( str, path );
    item->path = g_string_free( str, FALSE );
    item->placed = FALSE;
    
    ExceptionInfo * exception = AcquireExceptionInfo();
    ImageInfo * input_info = AcquireImageInfo();
    CopyMagickString( input_info->filename, item->path, MaxTextExtent );
    Image * temp_image = PingImage( input_info, exception );
    
    if ( exception->severity != UndefinedException )
        return NULL;
    
    item->x = 0;
    item->y = 0;
    item->w = (int) temp_image->columns + ( add_buffer_pixels ? 2 : 0 );
    item->h = (int) temp_image->rows    + ( add_buffer_pixels ? 2 : 0 );
    item->area = item->w * item->h;
    
    minimum.area += item->area;
    minimum.width   = MAX( minimum.width,   item->w );
    minimum.height  = MAX( minimum.height,  item->h );
    smallest.width  = MIN( smallest.width,  item->w );
    smallest.height = MIN( smallest.height, item->w );
    
    DestroyImage( temp_image );
    DestroyExceptionInfo( exception );
    
    return item;
}

gint item_compare_area ( gconstpointer a, gconstpointer b, gpointer user_data )
{
    Item * aa = (Item *) a, * bb = (Item *) b;
    int m = MAX( bb->w, bb->h ) - MAX( aa->w, aa->h );
    return m != 0 ? m : MIN( bb->w, bb->h ) - MIN( aa->w, aa->h );
}

void load ( GFile * file, GFile * base, GPtrArray * input_patterns, int size_limit, gboolean recursive )
{
    GFileInfo * info = g_file_query_info( file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );
    GFileType type = g_file_info_get_file_type( info );
    
    if ( type == G_FILE_TYPE_DIRECTORY )
    {
        if ( file != base && !recursive )
            return;
        
        GFileEnumerator * children = g_file_enumerate_children( file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL );
        GFileInfo * child_info;
        GFile * child;
        
        while ( ( child_info = g_file_enumerator_next_file( children, NULL, NULL ) ) != NULL )
        {
            child = g_file_get_child( file, g_file_info_get_name( child_info ) );
            load( child, base, input_patterns, size_limit, recursive );
            g_object_unref( child );
            g_object_unref( child_info );
        }
        
        g_file_enumerator_close( children, NULL, NULL );
        g_object_unref( children );
        
    }
    else if ( type == G_FILE_TYPE_REGULAR )
    {
        char * path = g_file_get_relative_path( base, file );
        int i;
        for ( i = 0; i < input_patterns->len; i++ )
            if ( g_pattern_match_string( g_ptr_array_index(input_patterns, i), path ) )
                break;
        
        if ( i == 0 || i < input_patterns->len ) {
            Item * item = item_new( path );
            if ( item != NULL )
                if ( item->w < input_size_limit && item->h < size_limit )
                    g_sequence_insert_sorted( items, item, item_compare_area, NULL );
        }
    }
}