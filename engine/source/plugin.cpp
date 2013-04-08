
#include "plugin.h"
#include "context.h"

//.............................................................................

#define TP_LOG_DOMAIN   "PLUGINS"
#define TP_LOG_ON       true
#define TP_LOG2_ON      false

#include "log.h"

//.............................................................................


namespace TrickPlay
{

gpointer Plugin::get_symbol( GModule* module , const char* name )
{
    g_assert( module );
    g_assert( name );

    gpointer result = 0;

    if ( ! g_module_symbol( module , name , & result ) )
    {
        tplog( "  MISSING SYMBOL '%s'" , name );
        return 0;
    }

    if ( ! result )
    {
        tplog( "  SYMBOL '%s' IS NULL" , name );
        return 0;
    }

    return result;
}

Plugin::List Plugin::scan( TPContext* context , const String& prefix , const StringList& symbols )
{
    Plugin::List result;

    if ( ! g_module_supported() )
    {
        tpwarn( "PLUGINS ARE NOT SUPPORTED ON THIS PLATFORM" );

        return result;
    }

    const gchar* plugins_path = context->get( TP_PLUGINS_PATH );

    if ( ! plugins_path )
    {
        tpwarn( "PLUGINS PATH IS NOT SET" );

        return result;
    }

    if ( ! g_file_test( plugins_path , G_FILE_TEST_IS_DIR ) )
    {
        return result;
    }

    GError* error = 0;

    GDir* dir = g_dir_open( plugins_path , 0 , & error );

    if ( ! dir )
    {
        tpwarn( "FAILED TO OPEN PLUGINS PATH '%s' : %s" , plugins_path , error->message );

        g_clear_error( & error );

        return result;
    }

    for ( const gchar* name = g_dir_read_name( dir ); name ; name = g_dir_read_name( dir ) )
    {
        if ( g_str_has_prefix( name , prefix.c_str() ) )
        {
            if ( ! g_str_has_suffix( name , ".config" ) )
            {
                gchar* file_name = g_build_filename( plugins_path , name , NULL );

                tplog( "FOUND PLUGIN %s" , file_name );

                GModule* module = g_module_open( file_name , G_MODULE_BIND_LOCAL );

                if ( 0 == module )
                {
                    tpwarn( "  FAILED TO OPEN : %s" , g_module_error() );
                }
                else
                {
                    tplog2( "  LOADED" );

                    StringList all_symbols( symbols );

                    all_symbols.push_front( TP_PLUGIN_SHUTDOWN );
                    all_symbols.push_front( TP_PLUGIN_INITIALIZE );

                    GPointerMap symbols_found;

                    for ( StringList::const_iterator it = all_symbols.begin(); it != all_symbols.end(); ++it )
                    {
                        const char* symbol_name = it->c_str();

                        if ( gpointer symbol = get_symbol( module , symbol_name ) )
                        {
                            tplog2( "  FOUND SYMBOL '%s'" , symbol_name );
                            symbols_found[ symbol_name ] = symbol;
                        }
                        else
                        {
                            break;
                        }
                    }

                    if ( symbols_found.size() != all_symbols.size() )
                    {
                        g_module_close( module );
                    }
                    else
                    {
                        result.push_back( new Plugin( module , symbols_found ) );
                    }
                }

                g_free( file_name );
            }
        }
    }

    g_dir_close( dir );

    return result;
}

Plugin::Plugin( GModule* _module , const GPointerMap& _symbols )
    :
    module( _module ),
    symbols( _symbols )
{
    g_assert( module );

    TPPluginInitialize initialize = ( TPPluginInitialize ) get_symbol( TP_PLUGIN_INITIALIZE );

    shutdown = ( TPPluginShutdown ) get_symbol( TP_PLUGIN_SHUTDOWN );

    g_assert( initialize );
    g_assert( shutdown );

    // Load the configuration file for this plugin, if it exists

    gchar* config = 0;

    if ( const gchar* file_name = g_module_name( module ) )
    {
        gchar* base_name = g_path_get_basename( file_name );

        if ( gchar* dot = g_strrstr( base_name , "." ) )
        {
            gchar* dir_name = g_path_get_dirname( file_name );

            String config_file_name;

            config_file_name = dir_name;
            config_file_name += G_DIR_SEPARATOR_S;
            config_file_name += String( base_name , dot - base_name );
            config_file_name += ".config";

            if ( g_file_get_contents( config_file_name.c_str() , & config , 0 , 0 ) )
            {
                tplog2( "  CONFIG LOADED" );
            }
            else
            {
                config = 0;
            }

            g_free( dir_name );
        }

        g_free( base_name );
    }

    // Now call its initialize function

    memset( & info , 0 , sizeof( info ) );

    tplog2( "  INITIALIZING..." );

    initialize( & info , config );

    g_free( config );

    tplog2( "  INITIALIZED" );

    info.name[ sizeof( info.name ) - 1 ] = 0;
    info.version[ sizeof( info.version ) - 1 ] = 0;

    tplog( "  NAME        : %s" , info.name );
    tplog( "  VERSION     : %s" , info.version );
    tplog( "  RESIDENT    : %s" , info.resident ? "YES" : "NO" );
    tplog( "  USER DATA   : %p" , info.user_data );

    if ( info.resident )
    {
        g_module_make_resident( module );
    }
}

Plugin::~Plugin()
{
    tplog2( "CLOSING '%s'..." , info.name );

    shutdown( info.user_data );

    tplog2( "CLOSED" );

    g_module_close( module );
}

gpointer Plugin::get_symbol( const String& name ) const
{
    GPointerMap::const_iterator it = symbols.find( name );

    return it == symbols.end() ? 0 : it->second;
}

String Plugin::name() const
{
    return info.name;
}

String Plugin::version() const
{
    return info.version;
}

gpointer Plugin::user_data() const
{
    return info.user_data;
}


}
