// LibjinglePlus is a class that connects to a XmppServer, creates
// some common tasks, and emits signals when things change

#ifndef _GAMESERVICECLIENT_H_
#define _GAMESERVICECLIENT_H_

#include "libgameservice.h"
#include "game.h"
#include "status.h"
#include "matchrequest.h"
#include "matchstate.h"
#include "turn.h"
#include "participant.h"
#include "item.h"
#include "accountinfo.h"
#include "matchdata.h"
#include "usergamedata.h"

namespace libgameservice {

class GameServiceClientNotify {
public:
	enum ConnectionState {
		STATE_NONE = 0,
		STATE_START,
		STATE_OPENING,
		STATE_OPEN,
		STATE_CLOSED,
	};

	virtual ~GameServiceClientNotify() {
	}

	/* GameServiceClient works on its own thread. It will call WakeupMainThread
	 * when it has something to report. The main thread should then wake up,
	 * and call DoCallbacks on the GameServiceClient object.
	 *
	 * This function gets called from GameServiceClient's worker thread. All other
	 * methods in GameServiceClinetNotify get called from the thread you call
	 * DoCallbacks() on.
	 */
	virtual void WakeupMainThread() = 0;

	virtual void OnStateChange(ConnectionState state) = 0;


	/* Presence */
	/* Called when someone's GameStatus is updated */
	virtual void OnStatusUpdate(const GameStatus &status) = 0;

	/* Called when a status update results in an error */
	virtual void OnStatusError(const std::string &error_string) = 0;

	virtual void OnRegisterAccountResponse(const ResponseStatus& rs,
			const AccountInfo& account_info, void* cb_data) = 0;

	virtual void OnRegisterAppResponse(const ResponseStatus& rs,
			const AppId& app_id, void* cb_data) = 0;

	virtual void OnRegisterGameResponse(const ResponseStatus& rs,
			const Game& game, void* cb_data) = 0;

	virtual void OnListGamesResponse(const ResponseStatus& rs,
			const std::vector<GameId>& game_id_vector, void* cb_data) = 0;

	virtual void OnOpenAppResponse(const ResponseStatus& rs,
			const AppId& app_id, void* cb_data) = 0;

	virtual void OnCloseAppResponse(const ResponseStatus& rs,
			const AppId& app_id, void* cb_data) = 0;

	virtual void OnAssignMatchResponse(const ResponseStatus& rs,
			const MatchRequest& match_request, const std::string& match_id,
			void* cb_data) = 0;

	virtual void OnJoinMatchResponse(const ResponseStatus& rs,
			const std::string& match_id, const Participant& from,
			const Item& item, void* cb_data) = 0;

	virtual void OnJoin(const std::string& match_id, const Participant& from,
			const Item& item) = 0;

	virtual void
			OnStartMatchResponse(const ResponseStatus& rs, void* cb_data) = 0;

	virtual void
			OnStart(const std::string& match_id, const Participant& from) = 0;

	virtual void
			OnLeaveMatchResponse(const ResponseStatus& rs, void* cb_data) = 0;

	virtual void OnLeave(const std::string& match_id,
			const Participant& participant) = 0;

	virtual void OnTurnResponse(const ResponseStatus& rs, void* cb_data) = 0;

	virtual void OnGetMatchDataResponse(const ResponseStatus& rs, const MatchData& match_data, void* cb_data) = 0;

	virtual void OnGetUserGameDataResponse(const ResponseStatus& rs, const UserGameData& user_data, void* cb_data) = 0;

	virtual void OnUpdateUserGameDataResponse(const ResponseStatus& rs, const UserGameData& user_data, void* cb_data) = 0;

	virtual void OnTurn(const std::string& match_id, const Participant& from,
			const Turn& turn_message) = 0;

	virtual void OnUnavailable(const std::string& match_id,
			const Participant& from) = 0;

	virtual void OnNicknameChange(const std::string& match_id,
			const Participant& participant, const std::string& new_nickname) = 0;

	virtual void OnCurrentMatchState(const std::string& match_id,
			const MatchStatus& status, const MatchState& match_state) = 0;

	/* Called when XMPP is being sent or received. Used for debugging */
	virtual void OnXmppOutput(const std::string &output) = 0;
	virtual void OnXmppInput(const std::string &input) = 0;
};

class GameServiceAsyncInterface {

public:

	virtual StatusCode RegisterAccount(const AccountInfo& account_info, const std::string& domain, const std::string& host, int port, void* cb_data) = 0;

	virtual StatusCode Login(const std::string& user_id, const std::string& password, const std::string& domain, const std::string& host, int port) = 0;

	virtual StatusCode OpenApp(const AppId& app_id, void* cb_data) = 0;

	virtual StatusCode CloseApp(void* cb_data) = 0;

	virtual StatusCode ListGames(void* cb_data) = 0;

	virtual StatusCode RegisterApp(const AppId & app, void* cb_data) = 0;

	virtual StatusCode RegisterGame(const Game & game, void* cb_data) = 0;

	virtual StatusCode StartMatch(const std::string& match_id, void* cb_data) = 0;

	virtual StatusCode LeaveMatch(const std::string& match_id, void* cb_data) = 0;

	virtual StatusCode JoinMatch(const std::string& match_id, const std::string& nick,
			bool acquire_role, void* cb_data) = 0;

	virtual StatusCode JoinMatch(const std::string& match_id, const std::string& nick,
			const std::string& role, void* cb_data) = 0;

	virtual StatusCode AssignMatch(const MatchRequest& match_request, void* cb_data) = 0;

	virtual StatusCode GetMatchData(const GameId& game_id, void* cb_data) = 0;

	virtual StatusCode GetUserGameData(const GameId& game_id, void* cb_data) = 0;

	virtual StatusCode UpdateUserGameData(const GameId& game_id, const std::string& opaque, void* cb_data) = 0;

	virtual StatusCode SendTurn(const std::string& match_id, const Turn& turn_data, void* cb_data) = 0;

	/* Call this from the thread you want to receive callbacks on. Typically, this will be called
	 * after your WakeupMainThread() notify function is called.
	 *
	 */
	virtual bool DoCallbacks(unsigned int wait_millis = 0) = 0;

};


extern GameServiceAsyncInterface * newGameServiceAsyncImpl(GameServiceClientNotify *notify);

}
#endif  // _GAMESERVICECLIENT_H_
