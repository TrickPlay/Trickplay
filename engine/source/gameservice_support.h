#ifndef _GAMESERVICE_SUPPORT_H_
#define _GAMESERVICE_SUPPORT_H_

#include "gameserviceclient.h"
#include "context.h"
#include "lua.h"
#include "lb.h"
#include "user_data.h"

using namespace libgameservice;
class OpenAppAction;

extern int invoke_gameservice_on_ready( lua_State* L, GameServiceSupport* self, int nargs, int nresults );
extern int invoke_gameservice_on_error( lua_State* L, GameServiceSupport* self, int nargs, int nresults );
extern int invoke_gameservice_on_turn_received( lua_State* L, GameServiceSupport* self, int nargs, int nresults );
extern int invoke_gameservice_on_match_started( lua_State* L, GameServiceSupport* self, int nargs, int nresults );
extern int invoke_gameservice_on_participant_joined( lua_State* L, GameServiceSupport* self, int nargs, int nresults );
extern int invoke_gameservice_on_participant_left( lua_State* L, GameServiceSupport* self, int nargs, int nresults );
extern int invoke_gameservice_on_match_updated( lua_State* L, GameServiceSupport* self, int nargs, int nresults );


#define TP_NOTIFICATION_GAMESERVICE_LOGIN_SUCCESSFUL    "gameservice-login-successful"
#define TP_NOTIFICATION_GAMESERVICE_LOGIN_FAILED        "gameservice-login-failed"
#define TP_NOTIFICATION_GAMESERVICE_APP_READY           "gameservice-app-ready"
#define TP_NOTIFICATION_GAMESERVICE_APP_ERROR           "gameservice-app-error"

#define GAMESERVICE_USER_ID_KEY                         "com.trickplay.gameservice.user_id"
#define GAMESERVICE_PASSWORD_KEY                        "com.trickplay.gameservice.password"

class GameServiceSupport : public GameServiceClientNotify, public Notify
{

public:

    enum State
    {
        LOGIN_FAILED = 0,
        INIT_FAILED,
        NO_CONNECTION,
        INITIALIZING,
        INIT_COMPLETED,
        LOGIN_IN_PROGRESS,
        LOGIN_SUCCESSFUL,
        APP_OPENING,
        APP_OPEN,
        APP_CLOSING,
    };

    GameServiceSupport( TPContext* context );

    State state() const { return state_; }

    const std::string& GetUserId() const { return user_id_; }

    virtual StatusCode RegisterAccount( const AccountInfo& account_info, const std::string& domain, const std::string& host, int port );

    virtual StatusCode Login( const std::string& user_id, const std::string& password, const std::string& domain, const std::string& host, int port );

    virtual StatusCode OpenApp( const AppId& app_id );

    virtual StatusCode CloseApp();

    virtual StatusCode ListGames( UserData* ud, int lua_callback_ref );

    virtual StatusCode RegisterApp( const AppId& app );

    virtual StatusCode RegisterGame( UserData* ud, const Game& game, int lua_callback_ref );

    virtual StatusCode StartMatch( UserData* ud, const std::string& match_id, int lua_callback_ref );

    virtual StatusCode LeaveMatch( UserData* ud, const std::string& match_id, int lua_callback_ref );

    virtual StatusCode JoinMatch( UserData* ud, const std::string& match_id, const std::string& nick,
            bool acquire_role, int lua_callback_ref );

    virtual StatusCode JoinMatch( UserData* ud, const std::string& match_id, const std::string& nick,
            const std::string& role, int lua_callback_ref );

    virtual StatusCode AssignMatch( UserData* ud, const MatchRequest& match_request, int lua_callback_ref );

    virtual StatusCode GetMatchData( UserData* ud, const GameId& game_id, int lua_callback_ref );

    virtual StatusCode GetUserGameData( UserData* ud, const GameId& game_id, int lua_callback_ref );

    virtual StatusCode UpdateUserGameData( UserData* ud, const GameId& game_id, const std::string& opaque, int lua_callback_ref );

    virtual StatusCode SendTurn( UserData* ud, const std::string& match_id, const Turn& turn_data, int lua_callback_ref );

    /* Call this from the thread you want to receive callbacks on. Typically, this will be called
     * after your WakeupMainThread() notify function is called.
     *
     */
    virtual bool DoCallbacks( unsigned int wait_millis = 0 );


    /* The following methods will be called by the worker thread when one of the following 2 things happens:
     * 1. A previously requested GameService task completes
     * 2. A notification to the logged-in user is received from the GameService server.
     *
     * These methods shouldn't be by the App developers.
     */
    virtual void WakeupMainThread();

    virtual void OnStateChange( ConnectionState state );


    /* Presence */
    /* Called when someone's Status is updated */
    virtual void OnStatusUpdate( const Status& status );

    /* Called when a status update results in an error */
    virtual void OnStatusError( const std::string& error_string );

    virtual void OnRegisterAccountResponse( const ResponseStatus& rs,
            const AccountInfo& account_info, void* cb_data );

    virtual void OnRegisterAppResponse( const ResponseStatus& rs,
            const AppId& app_id, void* cb_data );

    virtual void OnRegisterGameResponse( const ResponseStatus& rs,
            const Game& game, void* cb_data );

    virtual void OnListGamesResponse( const ResponseStatus& rs,
            const std::vector<GameId>& game_id_vector, void* cb_data );

    virtual void OnOpenAppResponse( const ResponseStatus& rs,
            const AppId& app_id, void* cb_data );

    virtual void OnCloseAppResponse( const ResponseStatus& rs,
            const AppId& app_id, void* cb_data );

    virtual void OnAssignMatchResponse( const ResponseStatus& rs,
            const MatchRequest& match_request, const std::string& match_id,
            void* cb_data );

    virtual void OnJoinMatchResponse( const ResponseStatus& rs,
            const std::string& match_id, const Participant& from,
            const Item& item, void* cb_data );

    virtual void OnJoin( const std::string& match_id, const Participant& from,
            const Item& item );

    virtual void
    OnStartMatchResponse( const ResponseStatus& rs, void* cb_data );

    virtual void
    OnStart( const std::string& match_id, const Participant& from );

    virtual void
    OnLeaveMatchResponse( const ResponseStatus& rs, void* cb_data );

    virtual void OnLeave( const std::string& match_id,
            const Participant& participant );

    virtual void OnTurnResponse( const ResponseStatus& rs, void* cb_data );

    virtual void OnGetMatchDataResponse( const ResponseStatus& rs, const MatchData& match_data, void* cb_data );

    virtual void OnGetUserGameDataResponse( const ResponseStatus& rs, const UserGameData& user_data, void* cb_data );

    virtual void OnUpdateUserGameDataResponse( const ResponseStatus& rs, const UserGameData& user_data, void* cb_data );

    virtual void OnTurn( const std::string& match_id, const Participant& from,
            const Turn& turn_message );

    virtual void OnUnavailable( const std::string& match_id,
            const Participant& from );

    virtual void OnNicknameChange( const std::string& match_id,
            const Participant& participant, const std::string& new_nickname );

    virtual void OnCurrentMatchState( const std::string& match_id,
            const MatchStatus& status, const MatchState& match_state );

    /* Called when XMPP is being sent or received. Used for debugging */
    virtual void OnXmppOutput( const std::string& output );
    virtual void OnXmppInput( const std::string& input );

    friend class OpenAppAction;

private:
    void init();

    inline lua_State* get_lua_state()
    {
        return tpcontext_->get_current_app()->get_lua_state();
    }

    GameServiceAsyncInterface* delegate_;
    TPContext* tpcontext_;
    State state_;
    AppId app_id_;
    bool login_after_register_flag_;
    std::string user_id_;
};

#endif /* _GAMESERVICE_SUPPORT_H_ */
