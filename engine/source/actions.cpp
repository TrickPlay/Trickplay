
#include "actions.h"
#include "context.h"
#include "app.h"
#include "util.h"

//=============================================================================

#define TP_LOG_DOMAIN   "ACTIONS"
#define TP_LOG_ON       true
#define TP_LOG2_ON      false

#include "log.h"

//=============================================================================

Actions::Actions( TPContext* _context )
    :
    context( _context )
{
}

//.............................................................................

bool Actions::launch_action(
        const char* caller,
        const char* app_id,
        const char* action_name,
        const char* uri,
        const char* type,
        const char* parameters,
        SystemDatabase::AppActionMap& matches )
{
    // Caller can not be NULL - all of the others can.

    g_assert( caller );

    tplog( "LAUNCH ACTION WITH : app = '%s' : action = '%s' : uri = '%s' : type = '%s'", app_id, action_name, uri, type );

    if ( ! app_id && ! action_name && ! uri && ! type )
    {
        tplog( "  ALL LAUNCH CRITERIA ARE NULL" );

        return false;
    }

    matches.clear();

    SystemDatabase::AppActionMap actions = context->get_db()->get_app_actions_for_current_profile();

    // If no app id was provided, we need to find one that matches the action/uri
    // and type.

    for ( SystemDatabase::AppActionMap::const_iterator it = actions.begin(); it != actions.end(); ++it )
    {
        const App::Action::Map& app_actions( it->second );

        // If an app id was provided and it does not match this app, skip the rest

        if ( app_id && String( app_id ) != it->first )
        {
            continue;
        }

        // Skip my own actions

        if ( it->first == caller )
        {
            continue;
        }

        // Iterate over all the actions for this app to see if they match

        for ( App::Action::Map::const_iterator ait = app_actions.begin(); ait != app_actions.end(); ++ait )
        {

            tplog2( "    COMPARE TO : app = '%s' : action = '%s' : uri = '%s' : type = '%s'",
                    it->first.c_str(),
                    ait->first.c_str(),
                    ait->second.uri.c_str(), ait->second.type.c_str() );

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

            tplog( "  MATCHES : app = '%s' : action = '%s' : uri = '%s' : type = '%s'",
                    it->first.c_str(),
                    ait->first.c_str(),
                    ait->second.uri.c_str(), ait->second.type.c_str() );

            matches[ it->first ][ ait->first ] = ait->second;
        }
    }

    String app_to_launch;
    String action_to_launch;

    // Now check the matches.

    if ( matches.empty() )
    {
        // There are no matches

        tplog( "  NO MATCHES" );

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

        tplog( "  MULTIPLE MATCHES" );

        return false;
    }

    // At this point, we should have a single app id and action name

    g_assert( ! app_to_launch.empty() );
    g_assert( ! action_to_launch.empty() );

    tplog( "  WILL LAUNCH : app = '%s' : action = '%s'", app_to_launch.c_str(), action_to_launch.c_str() );

    App::LaunchInfo launch( caller, action_to_launch, uri, type, parameters );

    return TP_RUN_OK == context->launch_app( app_to_launch.c_str(), launch );
}

//.............................................................................

bool Actions::match_pattern( const char* source, const String& pattern )
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

