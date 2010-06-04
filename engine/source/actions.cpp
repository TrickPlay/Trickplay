
#include "actions.h"
#include "context.h"
#include "app.h"

//=============================================================================
// I'm playing with this class - I'll move it when I'm happy with it

class DebugLog
{
public:

    DebugLog( bool _on ) : on( _on ) {}

    inline void operator()( const gchar * format, ...)
    {
        if ( on )
        {
            va_list args;
            va_start( args, format );
            g_logv( G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG, format, args );
            va_end( args );
        }
    }

private:

    bool on;
};

//=============================================================================

DebugLog actions_debug( true );

//=============================================================================

Actions::Actions( TPContext * _context )
:
    context( _context )
{
}

//.............................................................................

bool Actions::launch_action(
        const char * caller,
        const char * app_id,
        const char * action_name,
        const char * uri,
        const char * type,
        const char * parameters,
        SystemDatabase::AppActionMap & matches )
{
    // Caller can not be NULL - all of the others can.

    g_assert( caller );

    actions_debug( "LAUNCH ACTION WITH : app = '%s' : action = '%s' : uri = '%s' : type = '%s'", app_id, action_name, uri, type );

    if ( ! app_id && ! action_name && ! uri && ! type )
    {
        actions_debug( "  ALL LAUNCH CRITERIA ARE NULL" );

        return false;
    }

    String app_to_launch;
    String action_to_launch;
    String uri_to_launch( uri ? uri : "" );
    String type_to_launch( type ? type : "" );
    String parameters_to_launch( parameters ? parameters : "" );

    matches.clear();

    SystemDatabase::AppActionMap actions = context->get_db()->get_app_actions_for_current_profile();

    // If no app id was provided, we need to find one that matches the action/uri
    // and type.

    for ( SystemDatabase::AppActionMap::const_iterator it = actions.begin(); it != actions.end(); ++it )
    {
        const App::Action::Map & app_actions( it->second );

        // If an app id was provided and it does not match this app, skip the rest

        if ( app_id && String( app_id ) != it->first )
        {
            continue;
        }

        // Iterate over all the actions for this app to see if they match

        for ( App::Action::Map::const_iterator ait = app_actions.begin(); ait != app_actions.end(); ++ait )
        {
#if 0
            actions_debug( "    COMPARE TO : app = '%s' : action = '%s' : uri = '%s' : type = '%s'",
                    it->first.c_str(),
                    ait->first.c_str(),
                    ait->second.uri.c_str(), ait->second.type.c_str() );
#endif
            // If an action was given, and it does not match, skip other checks

            if ( action_name && String( action_name ) != ait->first )
            {
                continue;
            }

            // If the uri or type don't match, skip

            if ( ! match_pattern( uri , ait->second.uri ) || ! match_pattern( type, ait->second.type ) )
            {
                continue;
            }

            // We have a match

            actions_debug( "  MATCHES : app = '%s' : action = '%s' : uri = '%s' : type = '%s'",
                    it->first.c_str(),
                    ait->first.c_str(),
                    ait->second.uri.c_str(), ait->second.type.c_str() );

            matches[ it->first ][ ait->first ] = ait->second;
        }
    }

    // Now check the matches.

    if ( matches.empty() )
    {
        // There are no matches

        actions_debug( "  NO MATCHES" );

        return false;
    }
    else if ( matches.size() == 1 && matches.begin()->second.size() == 1 )
    {
        // There is only one, so it must be the right one

        app_to_launch = matches.begin()->first;
        action_to_launch = matches.begin()->second.begin()->first;

        matches.clear();
    }
    else
    {
        // There are multiple matches. We return false and the list
        // of matches.

        actions_debug( "  MULTIPLE MATCHES" );

        return false;
    }

    // At this point, we should have a single app id and action name

    g_assert( ! app_to_launch.empty() );
    g_assert( ! action_to_launch.empty() );

    actions_debug( "  WILL LAUNCH : app = '%s' : action = '%s'", app_to_launch.c_str(), action_to_launch.c_str() );

    // TODO: populate a launch info structure that has the caller, action, uri, type and parameters
    // Launch the app with that information.

    return false;
}

//.............................................................................

bool Actions::match_pattern( const char * source, const String & pattern )
{
    bool result = false;

    if ( ! source )
    {
        if ( pattern.empty() )
        {
            result = true;
        }
        else
        {
            result = match_pattern( "", pattern );
        }
    }
    else if ( strlen( source ) == 0 && pattern.empty() )
    {
        result = true;
    }
    else
    {
        if ( pattern.empty() )
        {
            result = false;
        }
        else
        {
            result = g_regex_match_simple( pattern.c_str(), source, GRegexCompileFlags( 0 ), GRegexMatchFlags( 0 ) );
        }
    }

    return result;
}

//.............................................................................

