// LibjinglePlus is a class that connects to a XmppServer, creates
// some common tasks, and emits signals when things change

#ifndef _GAMESERVICECLIENT_H_
#define _GAMESERVICECLIENT_H_

#include <basicdefs.h>

#include <xmppengine.h>
#include <scoped_ptr.h>
#include <xmppclientsettings.h>

#include "libgameservice.h"
#include "game.h"
#include "status.h"
#include "matchrequest.h"
#include "matchstate.h"
#include "turn.h"
#include "participant.h"
#include "item.h"

namespace libgameservice {

class GameServiceClientWorker;

class GameServiceClientNotify {
private:
	txmpp::XmppEngine::State state_;

protected:
	void set_state(txmpp::XmppEngine::State state) {
		state_ = state;
	}

public:
	GameServiceClientNotify() : state_(txmpp::XmppEngine::STATE_NONE) { }

	txmpp::XmppEngine::State state() const {
		return state_;
	}

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

	virtual void OnStateChange(txmpp::XmppEngine::State state) = 0;


	/* Presence */
	/* Called when someone's Status is updated */
	virtual void OnStatusUpdate(const Status &status) = 0;

	/* Called when a status update results in an error */
	virtual void OnStatusError(const txmpp::XmlElement &stanza) = 0;

	virtual void OnRegisterAppResponse(const ResponseStatus& rs,
			const AppId& app_id) = 0;

	virtual void OnRegisterGameResponse(const ResponseStatus& rs,
			const Game& game) = 0;

	virtual void OnListGamesResponse(const ResponseStatus& rs,
			const std::vector<GameId>& game_id_vector) = 0;

	virtual void OnOpenAppResponse(const ResponseStatus& rs,
			const AppId& app_id) = 0;

	virtual void OnCloseAppResponse(const ResponseStatus& rs,
			const AppId& app_id) = 0;

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

class GameServiceClient {
public:
	/* Provide the constructor with your interface. */
	GameServiceClient(GameServiceClientNotify * notify);
	~GameServiceClient();

	/* Logs in and starts doing stuff
	 *
	 */
	StatusCode Login(const txmpp::XmppClientSettings & xcs);

	StatusCode SendPresence(const Status & s);
	// void OpenApp(const std::string &appId);

	const AppId & CurrentApp() const {
		return current_app_;
	}
	;

	bool IsAppOpen() const {
		return current_app_.is_valid();
	}

	StatusCode OpenApp(const AppId& app_id);

	StatusCode CloseApp();

	StatusCode ListGames();

	StatusCode RegisterApp(const AppId & app);

	StatusCode RegisterGame(const Game & game);

	StatusCode StartMatch(const std::string& match_id, void* cb_data);

	StatusCode LeaveMatch(const std::string& match_id, void* cb_data);

	StatusCode JoinMatch(const std::string& match_id, const std::string& nick,
			bool acquire_role, void* cb_data);

	StatusCode JoinMatch(const std::string& match_id, const std::string& nick,
			const std::string& role, void* cb_data);

	StatusCode AssignMatch(const MatchRequest& match_request, void* cb_data);

	StatusCode GetMatchData(const GameId& game_id);

	StatusCode SendTurn(const std::string& match_id, const std::string& state,
			bool terminate, void* cb_data);

	/* Call this from the thread you want to receive callbacks on. Typically, this will be called
	 * after your WakeupMainThread() notify function is called.
	 *
	 */
	bool DoCallbacks(uint wait_millis = 0);

private:

	GameServiceClientWorker * worker_;
	AppId current_app_;
};

}
#endif  // _GAMESERVICECLIENT_H_
