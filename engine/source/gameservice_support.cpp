#include <iostream>
#include <string>
#include "gameservice_support.h"
#include "gameservice_util.h"
#include "util.h"

using namespace libgameservice;

static std::string stateToStr(GameServiceSupport::State state) {
	switch(state) {
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

class MonitorLoginAction : public Action {

public:
	MonitorLoginAction(GameServiceSupport * game_service)
	: game_service_(game_service) {
		std::cout << "Inside MonitorLoginAction constructor" << std::endl;
	}
	~MonitorLoginAction() {
		std::cout << "Inside MonitorLoginAction destructor" << std::endl;
	}
protected:
	bool run() {
	//	std::cout << "Inside MonitorLoginAction." << std::endl;
		if (game_service_->state() == GameServiceSupport::LOGIN_IN_PROGRESS) {
			game_service_->DoCallbacks();
			if (game_service_->state() != GameServiceSupport::LOGIN_IN_PROGRESS) {
				std::cout << "Login completed. current state:" << stateToStr(game_service_->state()) << std::endl;
				return false;
			}
		} else {
			std::cout << "Login completed. current state:" << stateToStr(game_service_->state()) << std::endl;
		}
		return true;
	}

private:
	GameServiceSupport * game_service_;
};

class DoCallbacksAction : public Action {
public:
	DoCallbacksAction(GameServiceSupport * game_service)
	: game_service_(game_service) {
		std::cout << "Inside DoCallbacksAction constructor" << std::endl;
	}
	~DoCallbacksAction() {
		std::cout << "Inside DoCallbacksAction destructor" << std::endl;
	}
protected:
	bool run() {
		std::cout << "Inside DoCallbacksAction" << std::endl;
		game_service_->DoCallbacks();
		return false;
	}

private:
	GameServiceSupport * game_service_;
};

class OpenAppAction : public Action {
public:
	OpenAppAction(GameServiceSupport * game_service, const AppId& app_id)
	: game_service_(game_service), app_id_(app_id) {
//		std::cout << "Inside OpenAppAction constructor" << std::endl;
	}
	~OpenAppAction() {
//		std::cout << "Inside OpenAppAction destructor" << std::endl;
	}
protected:
	bool run() {
	//	std::cout << "Inside OpenAppAction" << std::endl;
		if (game_service_->state() == GameServiceSupport::LOGIN_IN_PROGRESS)
			return true;
		else if (game_service_->state() == GameServiceSupport::LOGIN_SUCCESSFUL) {
			std::cout << "Inside OpenAppAction. Login was successful. initiating OpenApp" << std::endl;
			game_service_->state_ = GameServiceSupport::APP_OPENING;
			game_service_->delegate_->OpenApp(app_id_);
		} else {
			ResponseStatus rs(libgameservice::NOT_CONNECTED, "Not connected to gameservice server");
			game_service_->OnOpenAppResponse(rs, app_id_);
		}
		return false;
	}

private:
	GameServiceSupport * game_service_;
	AppId app_id_;
};

GameServiceSupport::GameServiceSupport(TPContext * context)
: tpcontext_(context), state_(NO_CONNECTION) {
	delegate_ = newGameServiceAsyncImpl(this);


	std::string user_id("p2");
	std::string password("saywhat");
	std::string domain("internal.trickplay.com");
	//xcs.set_resource("desktop");
	//xcs.set_use_tls(true);
	std::string host("127.0.0.1");
	int port = 5222;

	Login(user_id, password, domain, host, port);

}

StatusCode GameServiceSupport::Login(const std::string& user_id, const std::string& password, const std::string& domain, const std::string& host, int port) {
	// set up a idle handler to monitor Login state

	state_ = LOGIN_IN_PROGRESS;
	::Action::post(new MonitorLoginAction( this ));
	return delegate_->Login(user_id, password, domain, host, port);
}


StatusCode GameServiceSupport::OpenApp(const AppId& app_id) {
	if (state_ == APP_OPEN)
		return libgameservice::APP_ALREADY_OPEN;

	if (state_ == LOGIN_FAILED || state_ == NO_CONNECTION)
		return libgameservice::NOT_CONNECTED;

	if (state_ != LOGIN_SUCCESSFUL && state_ != LOGIN_IN_PROGRESS)
		return libgameservice::FAILED;

	::Action::post(new OpenAppAction(this, app_id));
	return OK;
	//return delegate_->OpenApp(app_id);
}

StatusCode GameServiceSupport::CloseApp() {
	if (state_ == LOGIN_FAILED || state_ == NO_CONNECTION)
			return libgameservice::NOT_CONNECTED;

	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;

	return delegate_->CloseApp();
}

StatusCode GameServiceSupport::ListGames() {
	return delegate_->ListGames();
}

StatusCode GameServiceSupport::RegisterApp(const AppId & app) {
	return delegate_->RegisterApp(app);
}

StatusCode GameServiceSupport::RegisterGame(const Game & game) {
	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;
	return delegate_->RegisterGame(game);
}

StatusCode GameServiceSupport::StartMatch(const std::string& match_id, void* cb_data) {
	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;
	return delegate_->StartMatch(match_id, cb_data);
}

StatusCode GameServiceSupport::LeaveMatch(const std::string& match_id, void* cb_data) {
	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;
	return delegate_->LeaveMatch(match_id, cb_data);
}

StatusCode GameServiceSupport::JoinMatch(const std::string& match_id, const std::string& nick,
		bool acquire_role, void* cb_data) {
	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;
	return delegate_->JoinMatch(match_id, nick, acquire_role, cb_data);
}

StatusCode GameServiceSupport::JoinMatch(const std::string& match_id, const std::string& nick,
		const std::string& role, void* cb_data) {
	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;
	return delegate_->JoinMatch(match_id, nick, role, cb_data);
}

StatusCode GameServiceSupport::AssignMatch(const MatchRequest& match_request, void* cb_data) {
	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;
	return delegate_->AssignMatch(match_request, cb_data);
}

StatusCode GameServiceSupport::GetMatchData(const GameId& game_id) {
	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;
	return delegate_->GetMatchData(game_id);
}

StatusCode GameServiceSupport::SendTurn(const std::string& match_id, const std::string& state,
		bool terminate, void* cb_data) {
	if (state_ != APP_OPEN)
		return libgameservice::APP_NOT_OPEN;
	return delegate_->SendTurn(match_id, state, terminate, cb_data);
}

/* Call this from the thread you want to receive callbacks on. Typically, this will be called
 * after your WakeupMainThread() notify function is called.
 *
 */
bool GameServiceSupport::DoCallbacks(unsigned int wait_millis) {
	return delegate_->DoCallbacks(wait_millis);
}

void GameServiceSupport::OnStateChange(ConnectionState state) {
	if (state == GameServiceClientNotify::STATE_OPEN) {
		state_ = LOGIN_SUCCESSFUL;
		notify( tpcontext_ , TP_NOTIFICATION_GAMESERVICE_LOGIN_SUCCESSFUL );
	}
	else if (state == GameServiceClientNotify::STATE_CLOSED) {
		if (state_ == LOGIN_IN_PROGRESS) {
			state_ = LOGIN_FAILED;
			notify( tpcontext_ , TP_NOTIFICATION_GAMESERVICE_LOGIN_FAILED );
		}
		else
			state_ = NO_CONNECTION;
	}
	std::cout << "State change: " << state << std::endl;
}

void GameServiceSupport::OnXmppOutput(const std::string &output) {
	std::cout << ">>>>>>>>" << std::endl << output << std::endl
			<< ">>>>>>>>" << std::endl;
}

void GameServiceSupport::OnXmppInput(const std::string &input) {
	std::cout << "<<<<<<<<" << std::endl << input << std::endl
			<< "<<<<<<<<" << std::endl;
}

void GameServiceSupport::OnRegisterAppResponse(const ResponseStatus& rs, const AppId& app_id) {
	std::cout << "OnRegisterAppResponse(). status_code:" << statusToString(
			rs.status_code()) << ", app_id:" << app_id.AsID() << std::endl;
}

void GameServiceSupport::OnRegisterGameResponse(const ResponseStatus& rs, const Game& game) {
	std::cout << "OnRegisterGameResponse(). status_code:"
			<< statusToString(rs.status_code()) << ", game_id:"
			<< game.game_id().AsID() << std::endl;
}

void GameServiceSupport::OnListGamesResponse(const ResponseStatus& rs,
		const std::vector<GameId>& game_id_vector) {
	std::cout << "OnListGamesResponse(). status_code:" << statusToString(
			rs.status_code()) << std::endl;
	std::vector<GameId>::const_iterator iter;
	for (iter = game_id_vector.begin(); iter < game_id_vector.end(); iter++) {
		std::cout << "game_id.Str()=" << (*iter).Str() << std::endl;
		std::cout << "game_id.AsID()=" << (*iter).AsID() << std::endl;
	}
}

void GameServiceSupport::OnOpenAppResponse(const ResponseStatus& rs, const AppId& app_id) {
	std::cout << "OnOpenAppResponse(). status_code:" << statusToString(
			rs.status_code()) << ", app_id:" << app_id.AsID() << std::endl;

	lua_State* L = get_lua_state();

	if (rs.status_code() == OK) {
		state_ = APP_OPEN;
		app_id_ = app_id;


		TPGameServiceUtil::push_app_id_arg( L, app_id );

		invoke_gameservice_on_ready( L, this, 1, 0 );

		// call the on_ready lua callback
	} else {
		// call the on_error lua callback
		state_ = LOGIN_SUCCESSFUL;

		TPGameServiceUtil::push_response_status_arg( L, rs );

		invoke_gameservice_on_error( L, this, 1, 0 );
	}
}

void GameServiceSupport::OnCloseAppResponse(const ResponseStatus& rs, const AppId& app_id) {
	std::cout << "OnCloseAppResponse(). status_code:" << statusToString(
			rs.status_code()) << ", app_id:" << app_id.AsID() << std::endl;
	if (rs.status_code() == OK) {
		state_ = LOGIN_SUCCESSFUL;
	} else {
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
void GameServiceSupport::OnAssignMatchResponse(const ResponseStatus& rs,
		const MatchRequest& match_request, const std::string& match_id, void* cb_data) {

	std::cout << "OnAssignMatchResponse(). status_code:"
			<< statusToString( rs.status_code() )
			<< ", match_request:" << match_request.Str()
			<< ", match_id:"
			<< match_id
			<< std::endl;

		lua_State* L = get_lua_state();

		TPGameServiceUtil::push_response_status_arg( L, rs );


		if (rs.status_code() == OK) {

			TPGameServiceUtil::push_match_request_arg( L, match_request );

			TPGameServiceUtil::push_string_arg( L, match_id );

			invoke_gameservice_on_assign_match_completed( L, this, 3, 0 );

		} else {
			invoke_gameservice_on_assign_match_completed( L, this, 1, 0 );
		}
}

void GameServiceSupport::OnStartMatchResponse(const ResponseStatus& rs, void* cb_data) {
	std::cout << "OnStartMatchResponse(). status_code:"
			<< statusToString( rs.status_code() )
			<< std::endl;

		lua_State* L = get_lua_state();

		TPGameServiceUtil::push_response_status_arg( L, rs );

		invoke_gameservice_on_start_match_completed( L, this, 1, 0 );
}

void GameServiceSupport::OnTurnResponse(const ResponseStatus& rs, void* cb_data) {
	std::cout << "OnTurnResponse(). status_code:"
			<< statusToString( rs.status_code() )
			<< std::endl;

		lua_State* L = get_lua_state();

		TPGameServiceUtil::push_response_status_arg( L, rs );

		invoke_gameservice_on_send_turn_completed( L, this, 1, 0 );
}

/*
 * pushes following arguments onto lua stack on success:
 * [ response_status, match_id, from, item ]
 *
 * pushes following arguments onto lua stack on failure
 * [ response_status ]
 */
void GameServiceSupport::OnJoinMatchResponse(const ResponseStatus& rs,
		const std::string& match_id, const Participant& from,
		const Item& item, void* cb_data) {

	std::cout << "OnJoinMatchResponse(). status_code:"
			<< statusToString( rs.status_code() )
			<< ", match_id:"
			<< match_id
			<< ", participant:"
			<< from.Str()
			<< ", item:"
			<< item.Str()
			<< std::endl;

		lua_State* L = get_lua_state();

		TPGameServiceUtil::push_response_status_arg( L, rs );


		if (rs.status_code() == OK) {

			TPGameServiceUtil::push_string_arg( L, match_id );

			TPGameServiceUtil::push_participant_arg( L, from );

			TPGameServiceUtil::push_item_arg( L, item );

			invoke_gameservice_on_join_match_completed( L, this, 4, 0 );

		} else {
			invoke_gameservice_on_join_match_completed( L, this, 1, 0 );
		}
}

void GameServiceSupport::OnLeaveMatchResponse(const ResponseStatus& rs, void* cb_data) {
	std::cout << "OnLeaveMatchResponse(). status_code:"
			<< statusToString( rs.status_code() )
			<< ". no lua callback "
			<< std::endl;

	//	lua_State* L = get_lua_state();

//		TPGameServiceUtil::push_response_status_arg( L, rs );

	//	invoke_gameservice_on_( L, this, 1, 0 );

}

void GameServiceSupport::OnStart(const std::string& match_id, const Participant& from) {
	std::cout << "OnStart()."
			<< "match_id:"
			<< match_id
			<< ", from:"
			<< from.Str()
			<< std::endl;

		lua_State* L = get_lua_state();


		TPGameServiceUtil::push_string_arg( L, match_id );

		TPGameServiceUtil::push_participant_arg( L, from );

		invoke_gameservice_on_match_started( L, this, 2, 0 );
}

void GameServiceSupport::OnTurn(const std::string& match_id, const Participant& from,
		const Turn& turn_message) {
	std::cout << "OnTurn()."
			<< "match_id:"
			<< match_id
			<< ", from:"
			<< from.Str()
			<< std::endl;

		lua_State* L = get_lua_state();


		TPGameServiceUtil::push_string_arg( L, match_id );

		TPGameServiceUtil::push_participant_arg( L, from );

		TPGameServiceUtil::push_turn_arg( L, turn_message);

		invoke_gameservice_on_turn_received( L, this, 3, 0 );
}

void GameServiceSupport::OnJoin(const std::string& match_id, const Participant& from,
		const Item& item) {
	std::cout << "OnJoin()."
			<< "match_id:"
			<< match_id
			<< ", from:"
			<< from.Str()
			<< ", item:"
			<< item.Str()
			<< std::endl;

		lua_State* L = get_lua_state();


		TPGameServiceUtil::push_string_arg( L, match_id );

		TPGameServiceUtil::push_participant_arg( L, from );

		TPGameServiceUtil::push_item_arg( L, item);

		invoke_gameservice_on_participant_joined( L, this, 3, 0 );

}

void GameServiceSupport::OnLeave(const std::string& match_id, const Participant& participant) {
	std::cout << "OnLeave()."
			<< "match_id:"
			<< match_id
			<< ", participant:"
			<< participant.Str()
			<< std::endl;

		lua_State* L = get_lua_state();


		TPGameServiceUtil::push_string_arg( L, match_id );

		TPGameServiceUtil::push_participant_arg( L, participant );

		invoke_gameservice_on_participant_left( L, this, 2, 0);
}

void GameServiceSupport::OnUnavailable(const std::string& match_id,
		const Participant& participant) {
	std::cout << "OnUnavailable()."
			<< "match_id:"
			<< match_id
			<< ", participant:"
			<< participant.Str()
			<< ". no lua callback"
			<< std::endl;
}

void GameServiceSupport::OnNicknameChange(const std::string& match_id,
		const Participant& participant, const std::string& new_nickname) {
	std::cout << "OnNicknameChange()."
				<< "match_id:"
				<< match_id
				<< ", participant:"
				<< participant.Str()
				<< ", new_nick:"
				<< new_nickname
				<< ". no lua callback"
				<< std::endl;
}

void GameServiceSupport::OnCurrentMatchState(const std::string& match_id,
		const MatchStatus& status, const MatchState& match_state) {
	std::cout << "OnCurrentMatchState()."
				<< "match_id:"
				<< match_id
				<< ", status:"
				<< libgameservice::matchStatusToString(status)
				<< std::endl;

	lua_State* L = get_lua_state();


	TPGameServiceUtil::push_string_arg( L, match_id );

	TPGameServiceUtil::push_match_status_arg( L, status );

	TPGameServiceUtil::push_match_state_arg( L, match_state );

	invoke_gameservice_on_match_updated( L, this, 3, 0);

}

void GameServiceSupport::OnStatusUpdate(const Status &status) {
	std::string from = status.jid();
	std::cout << from << " - " << status.status() << std::endl;
}

void GameServiceSupport::OnStatusError(const std::string &stanza) {
}

void GameServiceSupport::WakeupMainThread() {
	::Action::post(new DoCallbacksAction( this ));
}



