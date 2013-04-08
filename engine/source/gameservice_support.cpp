#include <iostream>
#include <string>
#include "gameservice_support.h"
#include "gameservice_util.h"
#include "util.h"
#include "sysdb.h"

using namespace libgameservice;

typedef struct _CallbackDataStruct
{
    UserData* user_data;
    int lua_callback_ref;
    _CallbackDataStruct( UserData* ud, int cb_ref ) :
        user_data( ud ), lua_callback_ref( cb_ref ) { }
} CallbackDataStruct;

static int invoke_lua_callback( lua_State* L, CallbackDataStruct* cb_data, int nargs , int nresults )
{

    int lua_callback_ref = cb_data != NULL ? cb_data->lua_callback_ref : LUA_REFNIL;
    UserData* ud = cb_data ? cb_data->user_data : NULL;

    LSG;

    // This will push the callback (or nil) onto the stack

    lua_rawgeti( L, LUA_REGISTRYINDEX, lua_callback_ref );

    if ( lua_callback_ref != LUA_REFNIL && lua_callback_ref != LUA_NOREF )
    {
        luaL_unref( L, LUA_REGISTRYINDEX, lua_callback_ref );
    }


    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , nargs + 1 );

        LSG_CHECK( -nargs );

        return 0;
    }

    {
        // Move function to just before the arguments

        lua_insert( L , - ( nargs + 1 ) );

        // Push self


        if ( ! ud )
        {
            lua_pop( L , nargs + 1 );

            LSG_CHECK( -( nargs + 1 ) );

            return 0;
        }

        ud->push_proxy();

        // Move self to just before the arguments (and right after the function)

        lua_insert( L , - ( nargs + 1 ) );

        lua_call( L , nargs + 1 , nresults );
    }

    LSG_CHECK( nresults - nargs );

    return 1;
}


static std::string stateToStr( GameServiceSupport::State state )
{
    switch ( state )
    {
        case GameServiceSupport::LOGIN_SUCCESSFUL:
            return "LOGIN_SUCCESSFUL";

        case GameServiceSupport::LOGIN_IN_PROGRESS:
            return "LOGIN_IN_PROGRESS";

        case GameServiceSupport::LOGIN_FAILED:
            return "LOGIN_FAILED";

        case GameServiceSupport::NO_CONNECTION:
            return "NO_CONNECTION";

        case GameServiceSupport::APP_OPEN:
            return "APP_OPEN";

        case GameServiceSupport::APP_OPENING:
            return "APP_OPENING";

        case GameServiceSupport::APP_CLOSING:
            return "APP_CLOSING";

        default:
            return "UNKNOWN";
    }
}

class MonitorLoginAction : public Action
{

public:
    MonitorLoginAction( GameServiceSupport* game_service )
        : game_service_( game_service )
    {
        //  std::cout << "Inside MonitorLoginAction constructor" << std::endl;
    }
    ~MonitorLoginAction()
    {
        //  std::cout << "Inside MonitorLoginAction destructor" << std::endl;
    }
protected:
    bool run()
    {
        //  std::cout << "Inside MonitorLoginAction." << std::endl;
        if ( game_service_->state() == GameServiceSupport::LOGIN_IN_PROGRESS )
        {
            game_service_->DoCallbacks();

            if ( game_service_->state() != GameServiceSupport::LOGIN_IN_PROGRESS )
            {
                std::cout << "Login completed. current state:" << stateToStr( game_service_->state() ) << std::endl;
                return false;
            }
        }
        else
        {
            //      std::cout << "Login completed. current state:" << stateToStr(game_service_->state()) << std::endl;
        }

        return true;
    }

private:
    GameServiceSupport* game_service_;
};

class DoCallbacksAction : public Action
{
public:
    DoCallbacksAction( GameServiceSupport* game_service )
        : game_service_( game_service )
    {
        //      std::cout << "Inside DoCallbacksAction constructor" << std::endl;
    }
    ~DoCallbacksAction()
    {
        //  std::cout << "Inside DoCallbacksAction destructor" << std::endl;
    }
protected:
    bool run()
    {
        //  std::cout << "Inside DoCallbacksAction" << std::endl;
        game_service_->DoCallbacks();
        return false;
    }

private:
    GameServiceSupport* game_service_;
};

class OpenAppAction : public Action
{
public:
    OpenAppAction( GameServiceSupport* game_service, const AppId& app_id, void* cb_data )
        : game_service_( game_service ), app_id_( app_id ), cb_data_( cb_data )
    {
        //      std::cout << "Inside OpenAppAction constructor" << std::endl;
    }
    ~OpenAppAction()
    {
        //      std::cout << "Inside OpenAppAction destructor" << std::endl;
    }
protected:
    bool run()
    {
        //  std::cout << "Inside OpenAppAction" << std::endl;
        if ( game_service_->state() == GameServiceSupport::LOGIN_IN_PROGRESS
                || game_service_->state() == GameServiceSupport::INITIALIZING
                || game_service_->state() == GameServiceSupport::INIT_COMPLETED )
        {
            return true;
        }
        else if ( game_service_->state() == GameServiceSupport::LOGIN_SUCCESSFUL )
        {
            //  std::cout << "Inside OpenAppAction. Login was successful. initiating OpenApp" << std::endl;
            game_service_->state_ = GameServiceSupport::APP_OPENING;
            game_service_->delegate_->OpenApp( app_id_, cb_data_ );
        }
        else
        {
            ResponseStatus rs( libgameservice::NOT_CONNECTED, "Not connected to gameservice server" );
            game_service_->OnOpenAppResponse( rs, app_id_, cb_data_ );
        }

        return false;
    }

private:
    GameServiceSupport* game_service_;
    AppId app_id_;
    void* cb_data_;
};

GameServiceSupport::GameServiceSupport( TPContext* context )
    : tpcontext_( context ), state_( NO_CONNECTION ), login_after_register_flag_( false ), user_id_()
{

    init();
}

void GameServiceSupport::init()
{

    state_ = INITIALIZING;
    SystemDatabase* db = tpcontext_->get_db();

    int current_profile_id = db->get_current_profile().id;
    int first_profile_id = db->get_int( TP_DB_FIRST_PROFILE_ID, -1 );

    // we only support one profile for now
    if ( first_profile_id != current_profile_id )
    {
        return;
    }

    delegate_ = newGameServiceAsyncImpl( this );

    user_id_ = db->get_string( GAMESERVICE_USER_ID_KEY, "" );
    String password = db->get_string( GAMESERVICE_PASSWORD_KEY, "" );

    // retrieve domain, host and port information from the configuration
    String domain = tpcontext_->get( TP_GAMESERVICE_DOMAIN );
    String host = tpcontext_->get( TP_GAMESERVICE_HOST );
    int port = tpcontext_->get_int( TP_GAMESERVICE_PORT, 5222 );

    if ( user_id_.empty() )
    {
        login_after_register_flag_ = true;
        // create a new account
        user_id_ = Util::make_v1_uuid();

        if ( user_id_.empty() )
        {
            std::cout << "Failed to create default gameservice user account. "
                    << "Trickplay system uuid is NULL." << std::endl;
            return;
        }

        password = Util::make_v1_uuid();
        AccountInfo ainfo( user_id_, user_id_, password, user_id_ + "@" + domain );
        RegisterAccount( ainfo, domain, host, port );
    }
    else
    {
        state_ = INIT_COMPLETED;
        Login( user_id_, password, domain, host, port );
    }

    /*
    std::string user_id("p2");
    std::string password("saywhat");
    std::string domain("internal.trickplay.com");
    //xcs.set_resource("desktop");
    //xcs.set_use_tls(true);
    std::string host("127.0.0.1");
    int port = 5222;

    init();

    */
}



StatusCode GameServiceSupport::RegisterAccount( const AccountInfo& account_info, const std::string& domain, const std::string& host, int port )
{
    delegate_->RegisterAccount( account_info, domain, host, port, NULL );
    return OK;
}

StatusCode GameServiceSupport::Login( const std::string& user_id, const std::string& password, const std::string& domain, const std::string& host, int port )
{
    // set up a idle handler to monitor Login state

    // Don't allow login if user is already logged in or if a login action is in progress
    if ( state_ > INIT_COMPLETED )
    {
        return INVALID_STATE;
    }

    state_ = LOGIN_IN_PROGRESS;
    ::Action::post( new MonitorLoginAction( this ) );
    return delegate_->Login( user_id, password, domain, host, port );
}


StatusCode GameServiceSupport::OpenApp( const AppId& app_id )
{
    if ( state_ == APP_OPEN )
    {
        return libgameservice::APP_ALREADY_OPEN;
    }

    if ( state_ <= NO_CONNECTION )
    {
        return libgameservice::NOT_CONNECTED;
    }

    //if (state_ > LOGIN_SUCCESSFUL)
    //return libgameservice::FAILED;

    ::Action::post( new OpenAppAction( this, app_id, NULL ) );
    return OK;
    //return delegate_->OpenApp(app_id);
}

StatusCode GameServiceSupport::CloseApp()
{
    if ( state_ <= NO_CONNECTION )
    {
        return libgameservice::NOT_CONNECTED;
    }

    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    return delegate_->CloseApp( NULL );
}

StatusCode GameServiceSupport::ListGames( UserData* ud, int lua_callback_ref )
{
    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->ListGames( cb_data );
}

StatusCode GameServiceSupport::RegisterApp( const AppId& app )
{
    return delegate_->RegisterApp( app, NULL );
}

StatusCode GameServiceSupport::RegisterGame( UserData* ud, const Game& game, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->RegisterGame( game, cb_data );
}

StatusCode GameServiceSupport::StartMatch( UserData* ud, const std::string& match_id, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->StartMatch( match_id, cb_data );
}

StatusCode GameServiceSupport::LeaveMatch( UserData* ud, const std::string& match_id, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->LeaveMatch( match_id, cb_data );
}

StatusCode GameServiceSupport::JoinMatch( UserData* ud, const std::string& match_id, const std::string& nick,
        bool acquire_role, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->JoinMatch( match_id, nick, acquire_role, cb_data );
}

StatusCode GameServiceSupport::JoinMatch( UserData* ud, const std::string& match_id, const std::string& nick,
        const std::string& role, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->JoinMatch( match_id, nick, role, cb_data );
}

StatusCode GameServiceSupport::AssignMatch( UserData* ud, const MatchRequest& match_request, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->AssignMatch( match_request, cb_data );
}

StatusCode GameServiceSupport::GetMatchData( UserData* ud, const GameId& game_id, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->GetMatchData( game_id, cb_data );
}

StatusCode GameServiceSupport::GetUserGameData( UserData* ud, const GameId& game_id, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->GetUserGameData( game_id, cb_data );
}

StatusCode GameServiceSupport::UpdateUserGameData( UserData* ud, const GameId& game_id, const std::string& opaque, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->UpdateUserGameData( game_id, opaque, cb_data );
}


StatusCode GameServiceSupport::SendTurn( UserData* ud, const std::string& match_id, const Turn& turn_data, int lua_callback_ref )
{
    if ( state_ != APP_OPEN )
    {
        return libgameservice::APP_NOT_OPEN;
    }

    CallbackDataStruct* cb_data = new CallbackDataStruct( ud, lua_callback_ref );
    return delegate_->SendTurn( match_id, turn_data, cb_data );
}

/* Call this from the thread you want to receive callbacks on. Typically, this will be called
 * after your WakeupMainThread() notify function is called.
 *
 */
bool GameServiceSupport::DoCallbacks( unsigned int wait_millis )
{
    return delegate_->DoCallbacks( wait_millis );
}

void GameServiceSupport::OnStateChange( ConnectionState state )
{
    if ( state == GameServiceClientNotify::STATE_OPEN )
    {
        state_ = LOGIN_SUCCESSFUL;
        notify( tpcontext_ , TP_NOTIFICATION_GAMESERVICE_LOGIN_SUCCESSFUL );
    }
    else if ( state == GameServiceClientNotify::STATE_CLOSED )
    {
        if ( state_ == LOGIN_IN_PROGRESS )
        {
            state_ = LOGIN_FAILED;
            notify( tpcontext_ , TP_NOTIFICATION_GAMESERVICE_LOGIN_FAILED );
        }
        else
        {
            state_ = NO_CONNECTION;
        }
    }

    std::cout << "State change: " << state << std::endl;
}

void GameServiceSupport::OnXmppOutput( const std::string& output )
{
    std::cout << ">>>>>>>>" << std::endl << output << std::endl
            << ">>>>>>>>" << std::endl;
}

void GameServiceSupport::OnXmppInput( const std::string& input )
{
    std::cout << "<<<<<<<<" << std::endl << input << std::endl
            << "<<<<<<<<" << std::endl;
}

void GameServiceSupport::OnRegisterAccountResponse( const ResponseStatus& rs,
        const AccountInfo& account_info, void* cb_data )
{
    /*
    std::cout << "OnRegisterAccountResponse(). status_code:" << statusToString(
                rs.status_code()) << ", account_info:" << account_info.Str() << std::endl;
                */

    if ( rs.status_code() == OK )
    {
        if ( state_ == INITIALIZING )
        {
            state_ = INIT_COMPLETED;
        }

        if ( login_after_register_flag_ )
        {
            login_after_register_flag_ = false;

            SystemDatabase* db = tpcontext_->get_db();
            String user_id = db->get_string( GAMESERVICE_USER_ID_KEY, "" );

            if ( user_id.empty() )
            {
                user_id = account_info.user_id();
                db->set( GAMESERVICE_USER_ID_KEY, account_info.user_id() );
                db->set( GAMESERVICE_PASSWORD_KEY, account_info.password() );
            }

            if ( state_ <= INIT_COMPLETED )
            {
                // retrieve domain, host and port information from the configuration
                String domain = tpcontext_->get( TP_GAMESERVICE_DOMAIN );
                String host = tpcontext_->get( TP_GAMESERVICE_HOST );
                int port = tpcontext_->get_int( TP_GAMESERVICE_PORT, 5222 );

                Login( account_info.user_id(), account_info.password(), domain, host, port );
            }
        }
    }
    else
    {
        if ( state_ == INITIALIZING )
        {
            state_ = INIT_FAILED;
        }
    }
}

void GameServiceSupport::OnRegisterAppResponse( const ResponseStatus& rs, const AppId& app_id, void* cb_data )
{
    /*  std::cout << "OnRegisterAppResponse(). status_code:" << statusToString(
                rs.status_code()) << ", app_id:" << app_id.AsID() << std::endl;
                */
}

void GameServiceSupport::OnRegisterGameResponse( const ResponseStatus& rs, const Game& game, void* cb_data )
{

    /*
     *
     std::cout << "OnRegisterGameResponse(). status_code:"
            << statusToString(rs.status_code()) << ", game_id:"
            << game.game_id().AsID() << std::endl;
    */


    lua_State* L = get_lua_state();

    TPGameServiceUtil::push_response_status_arg( L, rs );

    invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );

    delete( CallbackDataStruct* )cb_data;

}

void GameServiceSupport::OnListGamesResponse( const ResponseStatus& rs,
        const std::vector<GameId>& game_id_vector, void* cb_data )
{
    std::cout << "OnListGamesResponse(). status_code:" << statusToString(
            rs.status_code() ) << std::endl;
    std::vector<GameId>::const_iterator iter;

    for ( iter = game_id_vector.begin(); iter < game_id_vector.end(); iter++ )
    {
        std::cout << "game_id.Str()=" << ( *iter ).Str() << std::endl;
        std::cout << "game_id.AsID()=" << ( *iter ).AsID() << std::endl;
    }

    delete( CallbackDataStruct* )cb_data;
}

void GameServiceSupport::OnOpenAppResponse( const ResponseStatus& rs, const AppId& app_id, void* cb_data )
{
    /*
    std::cout << "OnOpenAppResponse(). status_code:" << statusToString(
            rs.status_code()) << ", app_id:" << app_id.AsID() << std::endl;
    */
    lua_State* L = get_lua_state();

    if ( rs.status_code() == OK )
    {
        state_ = APP_OPEN;
        app_id_ = app_id;

        TPGameServiceUtil::push_app_id_arg( L, app_id );

        lb_invoke_callbacks( L, this, "GAMESERVICE_METATABLE", "on_ready", 1, 0 );

        // call the on_ready lua callback
    }
    else
    {
        // call the on_error lua callback
        state_ = LOGIN_SUCCESSFUL;

        TPGameServiceUtil::push_response_status_arg( L, rs );

        lb_invoke_callbacks( L, this, "GAMESERVICE_METATABLE", "on_error", 1, 0 );
    }
}

void GameServiceSupport::OnCloseAppResponse( const ResponseStatus& rs, const AppId& app_id, void* cb_data )
{
    /*std::cout << "OnCloseAppResponse(). status_code:" << statusToString(
            rs.status_code()) << ", app_id:" << app_id.AsID() << std::endl;
            */
    if ( rs.status_code() == OK )
    {
        state_ = LOGIN_SUCCESSFUL;
    }
    else
    {
        state_ = APP_OPEN;
    }
}

/*
 * pushes following arguments onto lua stack on success:
 * [ response_status, match_request, match_id ]
 *
 * pushes following arguments onto lua stack on failure
 * [ response_status ]
 */
void GameServiceSupport::OnAssignMatchResponse( const ResponseStatus& rs,
        const MatchRequest& match_request, const std::string& match_id, void* cb_data )
{
    /*
        std::cout << "OnAssignMatchResponse(). status_code:"
                << statusToString( rs.status_code() )
                << ", match_request:" << match_request.Str()
                << ", match_id:"
                << match_id
                << std::endl;
                */

    lua_State* L = get_lua_state();

    TPGameServiceUtil::push_response_status_arg( L, rs );

    if ( rs.status_code() == OK )
    {

        TPGameServiceUtil::push_match_request_arg( L, match_request );

        TPGameServiceUtil::push_string_arg( L, match_id );

        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 3, 0 );

    }
    else
    {
        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );
    }

    delete( CallbackDataStruct* )cb_data;
}

void GameServiceSupport::OnStartMatchResponse( const ResponseStatus& rs, void* cb_data )
{
    /*
    std::cout << "OnStartMatchResponse(). status_code:"
            << statusToString( rs.status_code() )
            << std::endl;
    */

    lua_State* L = get_lua_state();

    TPGameServiceUtil::push_response_status_arg( L, rs );

    invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );
    delete( CallbackDataStruct* )cb_data;
}

void GameServiceSupport::OnTurnResponse( const ResponseStatus& rs, void* cb_data )
{
    /*std::cout << "OnTurnResponse(). status_code:"
            << statusToString( rs.status_code() )
            << std::endl;*/

    lua_State* L = get_lua_state();

    TPGameServiceUtil::push_response_status_arg( L, rs );

    invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );
    delete( CallbackDataStruct* )cb_data;
}

/*
 * pushes following arguments onto lua stack on success:
 * [ response_status, match_id, from, item ]
 *
 * pushes following arguments onto lua stack on failure
 * [ response_status ]
 */
void GameServiceSupport::OnJoinMatchResponse( const ResponseStatus& rs,
        const std::string& match_id, const Participant& from,
        const Item& item, void* cb_data )
{
    /*
        std::cout << "OnJoinMatchResponse(). status_code:"
                << statusToString( rs.status_code() )
                << ", match_id:"
                << match_id
                << ", participant:"
                << from.Str()
                << ", item:"
                << item.Str()
                << std::endl;
                */

    lua_State* L = get_lua_state();

    TPGameServiceUtil::push_response_status_arg( L, rs );

    if ( rs.status_code() == OK )
    {

        TPGameServiceUtil::push_string_arg( L, match_id );

        TPGameServiceUtil::push_participant_arg( L, from );

        TPGameServiceUtil::push_item_arg( L, item );

        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 4, 0 );

    }
    else
    {
        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );
    }

    delete( CallbackDataStruct* )cb_data;
}

void GameServiceSupport::OnLeaveMatchResponse( const ResponseStatus& rs, void* cb_data )
{
    /*
    std::cout << "OnLeaveMatchResponse(). status_code:"
            << statusToString( rs.status_code() )
            << ". no lua callback "
            << std::endl;
            */

    lua_State* L = get_lua_state();

    TPGameServiceUtil::push_response_status_arg( L, rs );

    invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );
    delete( CallbackDataStruct* )cb_data;
}

void GameServiceSupport::OnGetMatchDataResponse( const ResponseStatus& rs, const MatchData& match_data, void* cb_data )
{
    lua_State* L = get_lua_state();

    //std::cout << "Inside OnGetMatchDataResponse. number of match_infos = " << match_data.const_match_infos().size() << std::endl;
    TPGameServiceUtil::push_response_status_arg( L, rs );

    if ( rs.status_code() == OK )
    {

        //  std::cout << "Inside OnGetMatchDataResponse. pushing match_data into lua stack" << std::endl;

        TPGameServiceUtil::push_match_data_arg( L, match_data );

        //  std::cout << "Inside OnGetMatchDataResponse. finished pushing match_data into lua stack" << std::endl;

        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 2, 0 );

    }
    else
    {
        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );
    }

    delete( CallbackDataStruct* )cb_data;

}

void GameServiceSupport::OnGetUserGameDataResponse( const ResponseStatus& rs, const UserGameData& user_data, void* cb_data )
{
    lua_State* L = get_lua_state();

    TPGameServiceUtil::push_response_status_arg( L, rs );

    if ( rs.status_code() == OK )
    {

        TPGameServiceUtil::push_user_game_data_arg( L, user_data );

        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 2, 0 );

    }
    else
    {
        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );
    }

    delete( CallbackDataStruct* )cb_data;

}

void GameServiceSupport::OnUpdateUserGameDataResponse( const ResponseStatus& rs, const UserGameData& user_data, void* cb_data )
{
    lua_State* L = get_lua_state();

    TPGameServiceUtil::push_response_status_arg( L, rs );

    if ( rs.status_code() == OK )
    {

        TPGameServiceUtil::push_user_game_data_arg( L, user_data );

        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 2, 0 );

    }
    else
    {
        invoke_lua_callback( L, ( CallbackDataStruct* )cb_data, 1, 0 );
    }

    delete( CallbackDataStruct* )cb_data;

}

void GameServiceSupport::OnStart( const std::string& match_id, const Participant& from )
{
    /*
    std::cout << "OnStart()."
            << "match_id:"
            << match_id
            << ", from:"
            << from.Str()
            << std::endl;
            */

    lua_State* L = get_lua_state();


    TPGameServiceUtil::push_string_arg( L, match_id );

    TPGameServiceUtil::push_participant_arg( L, from );

    lb_invoke_callbacks( L, this, "GAMESERVICE_METATABLE", "on_match_started", 2, 0 );
}

void GameServiceSupport::OnTurn( const std::string& match_id, const Participant& from,
        const Turn& turn_message )
{
    /*
    std::cout << "OnTurn()."
            << "match_id:"
            << match_id
            << ", from:"
            << from.Str()
            << std::endl;
            */

    lua_State* L = get_lua_state();


    TPGameServiceUtil::push_string_arg( L, match_id );

    TPGameServiceUtil::push_participant_arg( L, from );

    TPGameServiceUtil::push_turn_arg( L, turn_message );

    lb_invoke_callbacks( L, this, "GAMESERVICE_METATABLE", "on_turn_received", 3, 0 );
}

void GameServiceSupport::OnJoin( const std::string& match_id, const Participant& from,
        const Item& item )
{
    /*
    std::cout << "OnJoin()."
            << "match_id:"
            << match_id
            << ", from:"
            << from.Str()
            << ", item:"
            << item.Str()
            << std::endl;
            */

    lua_State* L = get_lua_state();


    TPGameServiceUtil::push_string_arg( L, match_id );

    TPGameServiceUtil::push_participant_arg( L, from );

    TPGameServiceUtil::push_item_arg( L, item );

    lb_invoke_callbacks( L, this, "GAMESERVICE_METATABLE", "on_participant_joined", 3, 0 );

}

void GameServiceSupport::OnLeave( const std::string& match_id, const Participant& participant )
{
    /*
    std::cout << "OnLeave()."
            << "match_id:"
            << match_id
            << ", participant:"
            << participant.Str()
            << std::endl;
    */
    lua_State* L = get_lua_state();


    TPGameServiceUtil::push_string_arg( L, match_id );

    TPGameServiceUtil::push_participant_arg( L, participant );

    lb_invoke_callbacks( L, this, "GAMESERVICE_METATABLE", "on_participant_left", 2, 0 );
}

void GameServiceSupport::OnUnavailable( const std::string& match_id,
        const Participant& participant )
{
    /*
    std::cout << "OnUnavailable()."
            << "match_id:"
            << match_id
            << ", participant:"
            << participant.Str()
            << ". no lua callback"
            << std::endl;
            */
}

void GameServiceSupport::OnNicknameChange( const std::string& match_id,
        const Participant& participant, const std::string& new_nickname )
{
    /*
    std::cout << "OnNicknameChange()."
                << "match_id:"
                << match_id
                << ", participant:"
                << participant.Str()
                << ", new_nick:"
                << new_nickname
                << ". no lua callback"
                << std::endl;
                */
}

void GameServiceSupport::OnCurrentMatchState( const std::string& match_id,
        const MatchStatus& status, const MatchState& match_state )
{
    /*
    std::cout << "OnCurrentMatchState()."
                << "match_id:"
                << match_id
                << ", status:"
                << libgameservice::matchStatusToString(status)
                << std::endl;
                */

    lua_State* L = get_lua_state();


    TPGameServiceUtil::push_string_arg( L, match_id );

    TPGameServiceUtil::push_match_status_arg( L, status );

    TPGameServiceUtil::push_match_state_arg( L, match_state );

    lb_invoke_callbacks( L, this, "GAMESERVICE_METATABLE", "on_match_updated", 3, 0 );

}

void GameServiceSupport::OnStatusUpdate( const Status& status )
{
    std::string from = status.jid();
    /*
    std::cout << from << " - " << status.status() << std::endl;
    */
}

void GameServiceSupport::OnStatusError( const std::string& stanza )
{
}

void GameServiceSupport::WakeupMainThread()
{
    ::Action::post( new DoCallbacksAction( this ) );
}
