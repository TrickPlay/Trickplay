#include <assert.h>
#include <iostream>
#include <vector>
#include "../../messagehandler.h"
#include "../../sigslot.h"
#include "../../messagequeue.h"
#include "../../thread.h"
#include "../../physicalsocketserver.h"

#include "../../prexmppauthimpl.h"
#include "../../xmppasyncsocketimpl.h"

#include "gameserviceclient.h"
#include "presenceouttask.h"
#include "presencepushtask.h"
#include "xmpppump.h"
#include "xmpptasks.h"

namespace libgameservice {

enum {
	MSG_START,

	// main thread to worker
	MSG_LOGIN,
	MSG_DISCONNECT,
	MSG_SEND_PRESENCE,
	MSG_REGISTER_APP,
	MSG_REGISTER_GAME,
	MSG_OPEN_APP,
	MSG_CLOSE_APP,
	MSG_ASSIGN_MATCH,
	MSG_JOIN_MATCH,
	MSG_START_MATCH,
	MSG_LEAVE_MATCH,
	MSG_TURN,
	MSG_SEND_APP_PRESENCE,
	MSG_LIST_GAMES,

	// worker thread to main thread
	MSG_STATE_CHANGE,
	MSG_STATUS_UPDATE,
	MSG_STATUS_ERROR,
	MSG_REGISTER_APP_RESPONSE,
	MSG_REGISTER_GAME_RESPONSE,
	MSG_OPEN_APP_RESPONSE,
	MSG_CLOSE_APP_RESPONSE,
	MSG_LIST_GAMES_RESPONSE,
	MSG_ASSIGN_MATCH_RESPONSE,
	MSG_JOIN_MATCH_RESPONSE,
	MSG_START_MATCH_RESPONSE,
	MSG_LEAVE_MATCH_RESPONSE,
	MSG_TURN_RESPONSE,
	MSG_HANDLE_START,
	MSG_HANDLE_LEAVE,
	MSG_HANDLE_TURN,
	MSG_HANDLE_JOIN,
	MSG_HANDLE_NICK_CHANGE,
	MSG_HANDLE_UNAVAILABLE,
	MSG_HANDLE_MATCH_STATE,
	MSG_XMPP_INPUT,
	MSG_XMPP_OUTPUT
};

class GameServiceClientWorker: public txmpp::MessageHandler,
		public XmppPumpNotify,
		public txmpp::has_slots<> {
public:
	GameServiceClientWorker(GameServiceClient *gsc,
			GameServiceClientNotify *notify) :
		worker_thread_(NULL), gsc_(gsc), notify_(notify), ppt_(NULL),
				presence_listener_task_(NULL), message_listener_task_(NULL),
				is_test_login_(false) {

		main_thread_.reset(new txmpp::AutoThread());

		pump_.reset(new XmppPump(this));

		pump_->client()->SignalLogInput.connect(this,
				&GameServiceClientWorker::OnInputDebug);

		pump_->client()->SignalLogOutput.connect(this,
				&GameServiceClientWorker::OnOutputDebug);

	}

	~GameServiceClientWorker() {
		if (worker_thread_) {
			worker_thread_->Send(this, MSG_DISCONNECT);
			delete worker_thread_;
		}
	}

	virtual void OnMessage(txmpp::Message *msg) {
		switch (msg->message_id) {
		case MSG_START:
			LoginW();
			break;
		case MSG_DISCONNECT:
			DisconnectW();
			break;
		case MSG_SEND_PRESENCE:
			SendPresenceW(static_cast<SendPresenceData*> (msg->pdata)->s_);
			delete msg->pdata;
			break;
		case MSG_REGISTER_APP:
			SendRegisterAppW(static_cast<AppData*> (msg->pdata)->app_id_);
			delete msg->pdata;
			break;
		case MSG_REGISTER_GAME:
			SendRegisterGameW(static_cast<RegisterGameData*> (msg->pdata)->game_);
			delete msg->pdata;
			break;
		case MSG_LIST_GAMES:
			SendListGamesW();
			break;
		case MSG_OPEN_APP:
			SendOpenAppW(static_cast<AppData*> (msg->pdata)->app_id_);
			delete msg->pdata;
			break;
		case MSG_CLOSE_APP:
			SendCloseAppW(static_cast<AppData*> (msg->pdata)->app_id_);
			delete msg->pdata;
			break;
		case MSG_ASSIGN_MATCH:
		{
			AssignMatchData* amd = static_cast<AssignMatchData*> (msg->pdata);
			SendAssignMatchW(amd->match_request_, amd->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_JOIN_MATCH:
		{
			JoinMatchData* jmd = static_cast<JoinMatchData*> (msg->pdata);
			SendJoinMatchW(jmd->join_match_request_, jmd->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_START_MATCH:
		{
			StartMatchData* smd = static_cast<StartMatchData*> (msg->pdata);
			SendStartMatchW(smd->match_id_, smd->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_LEAVE_MATCH:
		{
			LeaveMatchData* lmd = static_cast<LeaveMatchData*> (msg->pdata);
			SendLeaveMatchW(lmd->match_id_, lmd->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_TURN:
		{
			TurnData* td = static_cast<TurnData*> (msg->pdata);
			SendTurnW(td->match_id_, td->turn_, td->cb_data_);
			delete msg->pdata;
		}
			break;

		case MSG_STATUS_UPDATE:
			OnStatusUpdateW(static_cast<SendPresenceData*> (msg->pdata)->s_);
			delete msg->pdata;
			break;
		case MSG_STATUS_ERROR:
			OnStatusErrorW(static_cast<StatusErrorData*> (msg->pdata)->stanza_);
			delete msg->pdata;
			break;
		case MSG_STATE_CHANGE:
			OnStateChangeW(static_cast<StateChangeData*> (msg->pdata)->s_);
			delete msg->pdata;
			break;
		case MSG_XMPP_OUTPUT:
			OnOutputDebugW(static_cast<StringData*> (msg->pdata)->s_);
			delete msg->pdata;
			break;
		case MSG_XMPP_INPUT:
			OnInputDebugW(static_cast<StringData*> (msg->pdata)->s_);
			delete msg->pdata;
			break;
		case MSG_REGISTER_APP_RESPONSE: {
			AppResponseData* objptr =
					static_cast<AppResponseData*> (msg->pdata);
			OnRegisterAppResponseW(objptr->rs_, objptr->app_id_);
			delete msg->pdata;
		}
			break;
		case MSG_REGISTER_GAME_RESPONSE: {
			RegisterGameResponseData* objptr =
					static_cast<RegisterGameResponseData*> (msg->pdata);
			OnRegisterGameResponseW(objptr->rs_, objptr->game_);
			delete msg->pdata;
		}
			break;
		case MSG_LIST_GAMES_RESPONSE: {
			ListOfGamesResponseData* objptr =
					static_cast<ListOfGamesResponseData*> (msg->pdata);
			OnListGamesResponseW(objptr->rs_, objptr->game_id_vector_);
			delete msg->pdata;
		}
			break;
		case MSG_OPEN_APP_RESPONSE: {
			AppResponseData* objptr =
					static_cast<AppResponseData*> (msg->pdata);
			OnOpenAppResponseW(objptr->rs_, objptr->app_id_);
			delete msg->pdata;
		}
			break;
		case MSG_CLOSE_APP_RESPONSE: {
			AppResponseData* objptr =
					static_cast<AppResponseData*> (msg->pdata);
			OnCloseAppResponseW(objptr->rs_, objptr->app_id_);
			delete msg->pdata;
		}
			break;
		case MSG_ASSIGN_MATCH_RESPONSE: {
			AssignMatchResponseData* objptr =
					static_cast<AssignMatchResponseData*> (msg->pdata);
			OnAssignMatchResponseW(objptr->rs_, objptr->match_request_, objptr->match_id_, objptr->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_JOIN_MATCH_RESPONSE: {
			JoinMatchResponseData* objptr =
					static_cast<JoinMatchResponseData*> (msg->pdata);
			OnJoinMatchResponseW(objptr->rs_, objptr->match_id_, objptr->participant_, objptr->item_, objptr->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_START_MATCH_RESPONSE: {
			StartMatchResponseData* objptr =
					static_cast<StartMatchResponseData*> (msg->pdata);
			OnStartMatchResponseW(objptr->rs_, objptr->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_LEAVE_MATCH_RESPONSE: {
			LeaveMatchResponseData* objptr =
					static_cast<LeaveMatchResponseData*> (msg->pdata);
			OnLeaveMatchResponseW(objptr->rs_, objptr->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_TURN_RESPONSE: {
			TurnResponseData* objptr =
					static_cast<TurnResponseData*> (msg->pdata);
			OnTurnResponseW(objptr->rs_, objptr->cb_data_);
			delete msg->pdata;
		}
			break;
		case MSG_HANDLE_START: {
			IncomingStartMessageData* objptr =
					static_cast<IncomingStartMessageData*> (msg->pdata);
			OnStartW(objptr->match_id_, objptr->participant_);
			delete msg->pdata;
		}
			break;
		case MSG_HANDLE_LEAVE: {
			IncomingLeaveMessageData* objptr =
					static_cast<IncomingLeaveMessageData*> (msg->pdata);
			OnLeaveW(objptr->match_id_, objptr->participant_);
			delete msg->pdata;
		}
			break;
		case MSG_HANDLE_TURN: {
			IncomingTurnMessageData* objptr =
					static_cast<IncomingTurnMessageData*> (msg->pdata);
			OnTurnW(objptr->match_id_, objptr->participant_, objptr->turn_);
			delete msg->pdata;
		}
			break;
		case MSG_HANDLE_UNAVAILABLE: {
			IncomingUnavailableMessageData* objptr =
					static_cast<IncomingUnavailableMessageData*> (msg->pdata);
			OnUnavailableW(objptr->match_id_, objptr->participant_);
			delete msg->pdata;
		}
			break;
		case MSG_HANDLE_NICK_CHANGE: {
			IncomingNickChangeMessageData* objptr =
					static_cast<IncomingNickChangeMessageData*> (msg->pdata);
			OnNickChangeW(objptr->match_id_, objptr->participant_, objptr->new_nick_);
			delete msg->pdata;
		}
			break;
		case MSG_HANDLE_JOIN: {
			IncomingJoinMessageData* objptr =
					static_cast<IncomingJoinMessageData*> (msg->pdata);
			OnJoinW(objptr->match_id_, objptr->participant_, objptr->item_);
			delete msg->pdata;
		}
			break;
		case MSG_HANDLE_MATCH_STATE: {
			IncomingMatchStateMessageData* objptr =
					static_cast<IncomingMatchStateMessageData*> (msg->pdata);
			OnMatchStateW(objptr->match_id_, objptr->match_status_, objptr->match_state_);
			delete msg->pdata;
		}
			break;
		}
	}

	void Login(const txmpp::XmppClientSettings & xcs) {

		xcs_.set_user(xcs.user());
		xcs_.set_auth_cookie(xcs.auth_cookie());
		xcs_.set_pass(xcs.pass());

		xcs_.set_host(xcs.host());
		xcs_.set_resource(xcs.resource());
		xcs_.set_server(xcs.server());
		xcs_.set_use_tls(xcs.use_tls());
		xcs_.set_allow_plain(xcs.allow_plain());

		worker_thread_ = new txmpp::Thread(&pss_);
		worker_thread_->Start();
		worker_thread_->Send(this, MSG_START);
	}

	void SendPresence(const Status & s) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_SEND_PRESENCE, new SendPresenceData(s));
	}

	void RegisterApp(const AppId & app_id) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_REGISTER_APP, new AppData(app_id));
	}

	void RegisterGame(const Game & game) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_REGISTER_GAME, new RegisterGameData(game));
	}

	void ListGames() {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_LIST_GAMES, NULL);
	}

	void OpenApp(const AppId& app_id) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_OPEN_APP, new AppData(app_id));
	}

	void CloseApp(const AppId& app_id) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_CLOSE_APP, new AppData(app_id));
	}

	void AssignMatch(const MatchRequest& match_request, void* cb_data) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_ASSIGN_MATCH, new AssignMatchData(match_request, cb_data));
	}

	void JoinMatch(const JoinMatchRequest& match_request, void* cb_data) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_JOIN_MATCH, new JoinMatchData(match_request, cb_data));
	}

	void StartMatch(const std::string& match_id, void* cb_data) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_START_MATCH, new StartMatchData(match_id, cb_data));
	}

	void LeaveMatch(const std::string& match_id, void* cb_data) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_LEAVE_MATCH, new LeaveMatchData(match_id, cb_data));
	}

	void PostTurn(const std::string& match_id, const Turn& turn, void* cb_data) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		worker_thread_->Post(this, MSG_TURN, new TurnData(match_id, turn, cb_data));
	}

	bool DoCallbacks(uint wait_millis) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		bool dispatched = false;
		txmpp::Message m;
		while (main_thread_->Get(&m, wait_millis)) {
			main_thread_->Dispatch(&m);
			if (wait_millis != 0)
				wait_millis = 0;
			dispatched = true;
		}
		return dispatched;
	}

private:

	struct StringData: public txmpp::MessageData {
		StringData(std::string s) :
			s_(s) {
		}
		std::string s_;
	};

	void OnInputDebugW(const std::string &data) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnXmppInput(data);
	}

	void OnInputDebug(const char *data, int len) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_XMPP_INPUT,
				new StringData(std::string(data, len)));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnOutputDebugW(const std::string &data) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnXmppOutput(data);
	}

	void OnOutputDebug(const char *data, int len) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_XMPP_OUTPUT,
				new StringData(std::string(data, len)));
		if (notify_)
			notify_->WakeupMainThread();
	}

	struct StateChangeData: public txmpp::MessageData {
		StateChangeData(txmpp::XmppEngine::State state) :
			s_(state) {
		}
		txmpp::XmppEngine::State s_;
	};

	void OnStateChange(txmpp::XmppEngine::State state) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		switch (state) {
		case txmpp::XmppEngine::STATE_OPEN:
			//ppt_ = new PresencePushTask(pump_.get()->client());
			//ppt_->SignalStatusUpdate.connect(this,
					//&GameServiceClientWorker::OnStatusUpdate);
		//	ppt_->SignalStatusError.connect(this,
					//&GameServiceClientWorker::OnStatusError);
		//	ppt_->Start();

			//     rmt_ = new txmpp::ReceiveMessageTask(pump_.get()->client(), txmpp::XmppEngine::HL_ALL);
			//   rmt_->SignalIncomingMessage.connect(this, &GameServiceClientWorker::OnIncomingMessage);
			// rmt_->Start();
			message_listener_task_ = new MUGMessageListenerTask(pump_.get()->client());
			message_listener_task_->SignalStart.connect(this, &GameServiceClientWorker::OnStart);
			message_listener_task_->SignalLeave.connect(this, &GameServiceClientWorker::OnLeave);
			message_listener_task_->SignalTurn.connect(this, &GameServiceClientWorker::OnTurn);
			message_listener_task_->Start();

			presence_listener_task_ = new MUGPresenceListenerTask(pump_.get()->client());
			presence_listener_task_->SignalUnavailable.connect(this, &GameServiceClientWorker::OnUnavailable);
			presence_listener_task_->SignalNicknameChange.connect(this, &GameServiceClientWorker::OnNickChange);
			presence_listener_task_->SignalJoin.connect(this, &GameServiceClientWorker::OnJoin);
			presence_listener_task_->SignalMatchState.connect(this, &GameServiceClientWorker::OnMatchState);
			presence_listener_task_->Start();
			break;
		default:
			break;
		}
		main_thread_->Post(this, MSG_STATE_CHANGE, new StateChangeData(state));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnStateChangeW(txmpp::XmppEngine::State state) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnStateChange(state);
	}

	// incoming Start Message
	struct IncomingStartMessageData : public txmpp::MessageData {
		IncomingStartMessageData(const std::string& match_id, const Participant& p) :
					match_id_(match_id), participant_(p) {
				}
				std::string match_id_;
				Participant participant_;
	};

	void OnStart(const std::string& match_id, const Participant& participant) {
		assert(txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_HANDLE_START,
						new IncomingStartMessageData(match_id, participant));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnStartW(const std::string& match_id, const Participant& participant) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnStart(match_id, participant);
	}

	// incoming Leave message
	struct IncomingLeaveMessageData : public txmpp::MessageData {
			IncomingLeaveMessageData(const std::string& match_id, const Participant& p) :
						match_id_(match_id), participant_(p) {
					}
					std::string match_id_;
					Participant participant_;
		};

	void OnLeave(const std::string& match_id, const Participant& participant) {
		assert(txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_HANDLE_LEAVE,
						new IncomingLeaveMessageData(match_id, participant));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnLeaveW(const std::string& match_id, const Participant& participant) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnLeave (match_id, participant);
	}

	// incoming Turn message
	struct IncomingTurnMessageData : public txmpp::MessageData {
			IncomingTurnMessageData(const std::string& match_id, const Participant& p, const Turn& turn) :
						match_id_(match_id), participant_(p), turn_(turn) {
					}
					std::string match_id_;
					Participant participant_;
					Turn turn_;
		};

	void OnTurn(const std::string& match_id, const Participant& participant, const Turn& turn) {
		assert(txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_HANDLE_TURN,
						new IncomingTurnMessageData(match_id, participant, turn));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnTurnW(const std::string& match_id, const Participant& participant, const Turn& turn) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnTurn(match_id, participant, turn);
	}

	// incoming unavailable message
	struct IncomingUnavailableMessageData : public txmpp::MessageData {
				IncomingUnavailableMessageData(const std::string& match_id, const Participant& p) :
							match_id_(match_id), participant_(p) {
						}
						std::string match_id_;
						Participant participant_;
			};


	void OnUnavailable(const std::string& match_id, const Participant& participant) {
		assert(txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_HANDLE_UNAVAILABLE,
						new IncomingUnavailableMessageData(match_id, participant));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnUnavailableW(const std::string& match_id, const Participant& participant) {
			assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
			if (notify_)
				notify_->OnUnavailable(match_id, participant);
		}

	// incoming join message
	struct IncomingJoinMessageData : public txmpp::MessageData {
				IncomingJoinMessageData(const std::string& match_id, const Participant& p, const Item& item) :
							match_id_(match_id), participant_(p), item_(item) {
						}
						std::string match_id_;
						Participant participant_;
						Item item_;
			};

	void OnJoin(const std::string& match_id, const Participant& participant, const Item& item) {
		assert(txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_HANDLE_JOIN,
						new IncomingJoinMessageData(match_id, participant, item));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnJoinW(const std::string& match_id, const Participant& participant, const Item& item) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnJoin(match_id, participant, item);
	}

	// incoming nick change

	struct IncomingNickChangeMessageData : public txmpp::MessageData {
		IncomingNickChangeMessageData(const std::string& match_id, const Participant& p, const std::string& new_nick) :
								match_id_(match_id), participant_(p), new_nick_(new_nick) {
							}
							std::string match_id_;
							Participant participant_;
							std::string new_nick_;
				};


	void OnNickChange(const std::string& match_id, const Participant& participant, const std::string& new_nick) {
		assert(txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_HANDLE_NICK_CHANGE,
						new IncomingNickChangeMessageData(match_id, participant, new_nick));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnNickChangeW(const std::string& match_id, const Participant& participant, const std::string& new_nick) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnNicknameChange(match_id, participant, new_nick);
	}

	//incoming match state message
	struct IncomingMatchStateMessageData : public txmpp::MessageData {
		IncomingMatchStateMessageData(const std::string& match_id, const MatchStatus& status, const MatchState& state) :
								match_id_(match_id), match_status_(status), match_state_(state) {
							}
							std::string match_id_;
							MatchStatus match_status_;
							MatchState match_state_;
				};

	void OnMatchState(const std::string& match_id, const MatchStatus& match_status, const MatchState& match_state) {
		assert(txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_HANDLE_MATCH_STATE,
						new IncomingMatchStateMessageData(match_id, match_status, match_state));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnMatchStateW(const std::string& match_id, const MatchStatus& match_status, const MatchState& match_state) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnCurrentMatchState(match_id, match_status, match_state);
	}

//
	struct JidData: public txmpp::MessageData {
		JidData(const txmpp::Jid& jid) :
			jid_(jid) {
		}
		const txmpp::Jid jid_;
	};

	void OnStatusUpdateW(const Status &status) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnStatusUpdate(status);
	}

	void OnStatusUpdate(const Status &status) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_STATUS_UPDATE,
				new SendPresenceData(status));
		if (notify_)
			notify_->WakeupMainThread();
	}

	/* REGISTER APP */
	void SendRegisterAppW(const AppId & app_id) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		RegisterAppTask * rat = new RegisterAppTask(pump_.get()->client(), app_id);
		rat->SignalDone.connect(this,
				&GameServiceClientWorker::OnRegisterAppResponse);
		rat->Start();
	}

	struct AppData: public txmpp::MessageData {
		AppData(const AppId& app_id) :
			app_id_(app_id) {
		}
		AppId app_id_;
	};

	struct AppResponseData: public txmpp::MessageData {
		AppResponseData(const ResponseStatus& rs, const AppId& app_id) :
			rs_(rs), app_id_(app_id) {
		}
		ResponseStatus rs_;
		AppId app_id_;
	};

	void OnRegisterAppResponse(const ResponseStatus& rs, const AppId& app_id) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_REGISTER_APP_RESPONSE, new AppResponseData(rs, app_id));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnRegisterAppResponseW(const ResponseStatus& rs, const AppId& app_id) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnRegisterAppResponse(rs, app_id);
	}

	/* REGISTER GAME */
	void SendRegisterGameW(const Game & game) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		RegisterGameTask *rgt = new RegisterGameTask(pump_.get()->client(),
				game);
		rgt->SignalDone.connect(this,
				&GameServiceClientWorker::OnRegisterGameResponse);
		rgt->Start();
	}

	struct RegisterGameData: public txmpp::MessageData {
			RegisterGameData(const Game& game) :
				game_(game) {
			}
			Game game_;
		};

	struct RegisterGameResponseData: public txmpp::MessageData {
		RegisterGameResponseData(const ResponseStatus& rs, const Game& game) :
			rs_(rs), game_(game) {
		}
		ResponseStatus rs_;
		Game game_;
	};

	void OnRegisterGameResponse(const ResponseStatus& rs, const Game& game) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_REGISTER_GAME_RESPONSE, new RegisterGameResponseData(rs, game));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnRegisterGameResponseW(const ResponseStatus& rs, const Game& game) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnRegisterGameResponse(rs, game);
	}

	/* LIST GAMES */
	void SendListGamesW() {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		ListGamesTask *task = new ListGamesTask(pump_.get()->client());
		task->SignalListOfGames.connect(this,
				&GameServiceClientWorker::OnListGamesResponse);
		task->Start();
	}

	struct ListOfGamesResponseData: public txmpp::MessageData {
		ListOfGamesResponseData(const ResponseStatus& rs, const std::vector<GameId>& game_id_vector) :
				rs_(rs), game_id_vector_(game_id_vector) {
			}
			ResponseStatus rs_;
			std::vector<GameId> game_id_vector_;
		};

	void OnListGamesResponse(const ResponseStatus& rs, const std::vector<GameId>& game_id_vector) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		std::cout << "Inside OnListGamesResponse. called from worker thread. game_id_vector.size()=" << game_id_vector.size() << std::endl;
		main_thread_->Post(this, MSG_LIST_GAMES_RESPONSE, new ListOfGamesResponseData(rs, game_id_vector));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnListGamesResponseW(const ResponseStatus& rs, const std::vector<GameId>& game_id_vector) {
		assert (txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnListGamesResponse(rs, game_id_vector);
	}

	/* OPEN APP */
	void SendOpenAppW(const AppId & app_id) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		OpenAppTask * rat = new OpenAppTask(pump_.get()->client(), app_id);
		rat->SignalDone.connect(this,
				&GameServiceClientWorker::OnOpenAppResponse);
		rat->Start();
	}

	void OnOpenAppResponse(const ResponseStatus& rs, const AppId& app_id) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_OPEN_APP_RESPONSE, new AppResponseData(rs, app_id));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnOpenAppResponseW(const ResponseStatus& rs, const AppId& app_id) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnOpenAppResponse(rs, app_id);
	}

	/* CLOSE APP */
	void SendCloseAppW(const AppId & app_id) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		CloseAppTask * rat = new CloseAppTask(pump_.get()->client(), app_id);
		rat->SignalDone.connect(this,
				&GameServiceClientWorker::OnCloseAppResponse);
		rat->Start();
	}

	void OnCloseAppResponse(const ResponseStatus& rs, const AppId& app_id) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_CLOSE_APP_RESPONSE,
				new AppResponseData(rs, app_id));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnCloseAppResponseW(const ResponseStatus& rs, const AppId& app_id) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnCloseAppResponse(rs, app_id);
	}

	/* ASSIGN MATCH */
	void SendAssignMatchW(const MatchRequest& match_request, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		AssignMatchTask *task = new AssignMatchTask(pump_.get()->client(), match_request, cb_data);
		task->SignalDone.connect(this,
				&GameServiceClientWorker::OnAssignMatchResponse);
		task->Start();
	}

	struct AssignMatchData: public txmpp::MessageData {
		AssignMatchData(const MatchRequest& match_request, void* cb_data) :
					match_request_(match_request), cb_data_(cb_data) {
				}
				MatchRequest match_request_;
				void* cb_data_;
			};

	struct AssignMatchResponseData: public txmpp::MessageData {
			AssignMatchResponseData(const ResponseStatus& rs, const MatchRequest& match_request, const std::string& match_id, void* cb_data) :
						rs_(rs), match_request_(match_request), match_id_(match_id), cb_data_(cb_data) {
					}
					ResponseStatus rs_;
					MatchRequest match_request_;
					std::string match_id_;
					void* cb_data_;

				};

	void OnAssignMatchResponse(const ResponseStatus& rs, const MatchRequest& match_request, const std::string& match_id, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		std::cout << "Inside OnAssignMatchResponse. called from worker thread. match_id=" << match_id << std::endl;
		main_thread_->Post(this, MSG_ASSIGN_MATCH_RESPONSE, new AssignMatchResponseData(rs, match_request, match_id, cb_data));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnAssignMatchResponseW(const ResponseStatus& rs, const MatchRequest& match_request, const std::string& match_id, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnAssignMatchResponse(rs, match_request, match_id, cb_data);
	}

	/* JOIN MATCH */
	void SendJoinMatchW(const JoinMatchRequest& match_request, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		JoinMatchTask *task = new JoinMatchTask(pump_.get()->client(), match_request, cb_data);
		task->SignalDone.connect(this,
				&GameServiceClientWorker::OnJoinMatchResponse);
		task->Start();
	}

	struct JoinMatchData: public txmpp::MessageData {
		JoinMatchData(const JoinMatchRequest& match_request, void* cb_data) :
					join_match_request_(match_request), cb_data_(cb_data) {
				}
				JoinMatchRequest join_match_request_;
				void* cb_data_;
			};

	struct JoinMatchResponseData: public txmpp::MessageData {
			JoinMatchResponseData(const ResponseStatus& rs, const std::string& match_id, const Participant& p, const Item& item, void* cb_data) :
						rs_(rs), match_id_(match_id), participant_(p), item_(item), cb_data_(cb_data) {
					}
					ResponseStatus rs_;
					std::string match_id_;
					Participant participant_;
					Item item_;
					void* cb_data_;

				};

	void OnJoinMatchResponse(const ResponseStatus& rs, const std::string& match_id, const Participant& p, const Item& item, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		std::cout << "Inside OnJoinMatchResponse. called from worker thread. match_id=" << match_id << std::endl;
		main_thread_->Post(this, MSG_JOIN_MATCH_RESPONSE, new JoinMatchResponseData(rs, match_id, p, item, cb_data));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnJoinMatchResponseW(const ResponseStatus& rs, const std::string& match_id, const Participant& p, const Item& item, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnJoinMatchResponse(rs, match_id, p, item, cb_data);
	}

	/* START MATCH */
	void SendStartMatchW(const std::string& match_id, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		StartMatchTask *task = new StartMatchTask(pump_.get()->client(), match_id, cb_data);
		task->SignalDone.connect(this,
				&GameServiceClientWorker::OnStartMatchResponse);
		task->Start();
	}

	struct StartMatchData: public txmpp::MessageData {
		StartMatchData(const std::string& match_id, void* cb_data) :
					match_id_(match_id), cb_data_(cb_data) {
				}
				std::string match_id_;
				void* cb_data_;
			};

	struct StartMatchResponseData: public txmpp::MessageData {
			StartMatchResponseData(const ResponseStatus& rs, void* cb_data) :
						rs_(rs), cb_data_(cb_data) {
					}
					ResponseStatus rs_;
					void* cb_data_;

				};

	void OnStartMatchResponse(const ResponseStatus& rs, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		std::cout << "Inside OnStartMatchResponse. called from worker thread. "<< std::endl;
		main_thread_->Post(this, MSG_START_MATCH_RESPONSE, new StartMatchResponseData(rs, cb_data));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnStartMatchResponseW(const ResponseStatus& rs, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnStartMatchResponse(rs, cb_data);
	}

	/* Leave MATCH */
	void SendLeaveMatchW(const std::string& match_id, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		LeaveMatchTask *task = new LeaveMatchTask(pump_.get()->client(), match_id, cb_data);
		task->SignalDone.connect(this,
				&GameServiceClientWorker::OnLeaveMatchResponse);
		task->Start();
	}

	struct LeaveMatchData: public txmpp::MessageData {
		LeaveMatchData(const std::string& match_id, void* cb_data) :
					match_id_(match_id), cb_data_(cb_data) {
				}
				std::string match_id_;
				void* cb_data_;
			};

	struct LeaveMatchResponseData: public txmpp::MessageData {
			LeaveMatchResponseData(const ResponseStatus& rs, void* cb_data) :
						rs_(rs), cb_data_(cb_data) {
					}
					ResponseStatus rs_;
					void* cb_data_;

				};

	void OnLeaveMatchResponse(const ResponseStatus& rs, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		std::cout << "Inside OnLeaveMatchResponse. called from worker thread. " << std::endl;
		main_thread_->Post(this, MSG_LEAVE_MATCH_RESPONSE, new LeaveMatchResponseData(rs, cb_data));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnLeaveMatchResponseW(const ResponseStatus& rs, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnLeaveMatchResponse(rs, cb_data);
	}

	/* Turn */
	void SendTurnW(const std::string& match_id, const Turn& turn, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		TurnTask *task = new TurnTask(pump_.get()->client(), match_id, turn, cb_data);
		task->SignalDone.connect(this,
				&GameServiceClientWorker::OnTurnResponse);
		task->Start();
	}

	struct TurnData: public txmpp::MessageData {
		TurnData(const std::string& match_id, const Turn& turn, void* cb_data) :
					match_id_(match_id), turn_(turn), cb_data_(cb_data) {
				}
				std::string match_id_;
				Turn turn_;
				void* cb_data_;
			};

	struct TurnResponseData: public txmpp::MessageData {
			TurnResponseData(const ResponseStatus& rs, void* cb_data) :
						rs_(rs), cb_data_(cb_data) {
					}
					ResponseStatus rs_;
					void* cb_data_;

				};

	void OnTurnResponse(const ResponseStatus& rs, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		std::cout << "Inside OnTurnResponse. called from worker thread. " << std::endl;
		main_thread_->Post(this, MSG_TURN_RESPONSE, new TurnResponseData(rs, cb_data));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void OnTurnResponseW(const ResponseStatus& rs, void* cb_data) {
		assert (txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnTurnResponse(rs, cb_data);
	}

	struct StatusErrorData: txmpp::MessageData {
		StatusErrorData(const txmpp::XmlElement &stanza) :
			stanza_(stanza) {
		}
		txmpp::XmlElement stanza_;
	};

	void OnStatusErrorW(const txmpp::XmlElement &stanza) {
		assert(txmpp::ThreadManager::CurrentThread() != worker_thread_);
		if (notify_)
			notify_->OnStatusError(stanza);
	}

	void OnStatusError(const txmpp::XmlElement &stanza) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		main_thread_->Post(this, MSG_STATUS_ERROR, new StatusErrorData(stanza));
		if (notify_)
			notify_->WakeupMainThread();
	}

	void LoginW() {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		pump_->DoLogin(xcs_, new txmpp::XmppAsyncSocketImpl(true),
				new txmpp::PreXmppAuthImpl());
	}

	void DisconnectW() {
		assert(txmpp::ThreadManager::CurrentThread() == worker_thread_);
		pump_->DoDisconnect();
	}

	void SendPresenceW(const Status & s) {
		assert (txmpp::ThreadManager::CurrentThread() == worker_thread_);
		PresenceOutTask *pot = new PresenceOutTask(pump_.get()->client());
		pot->Send(s);
		pot->Start();
	}

	void OnXmppSocketClose(int error) {
		//    notify_->OnSocketClose(error);
	}

	struct SendPresenceData: public txmpp::MessageData {
		SendPresenceData(const Status &s) :
			s_(s) {
		}
		Status s_;
	};

	txmpp::scoped_ptr<txmpp::Thread> main_thread_;
	txmpp::Thread *worker_thread_;

	GameServiceClient *gsc_;
	GameServiceClientNotify *notify_;
	txmpp::XmppClientSettings xcs_;
	txmpp::PhysicalSocketServer pss_;
	PresencePushTask *ppt_;
	MUGPresenceListenerTask* presence_listener_task_;
	MUGMessageListenerTask* message_listener_task_;

	txmpp::scoped_ptr<XmppPump> pump_;

	bool is_test_login_;
};


GameServiceClient::GameServiceClient(GameServiceClientNotify *notify) {
	worker_ = new GameServiceClientWorker(this, notify);
}

GameServiceClient::~GameServiceClient() {
	delete worker_;
	worker_ = NULL;
}

StatusCode GameServiceClient::Login(const txmpp::XmppClientSettings & xcs) {
	worker_->Login(xcs);
	return OK;
}

StatusCode GameServiceClient::SendPresence(const Status & s) {
	worker_->SendPresence(s);
	return OK;
}

StatusCode GameServiceClient::RegisterApp(const AppId & app_id) {
	worker_->RegisterApp(app_id);
	return OK;
}

StatusCode GameServiceClient::RegisterGame(const Game & game) {
	worker_->RegisterGame(game);
	return OK;
}

StatusCode GameServiceClient::ListGames() {
	worker_->ListGames();
	return OK;
}

StatusCode GameServiceClient::OpenApp(const AppId& app_id) {
	if (IsAppOpen())
		return APP_OPEN;
	worker_->OpenApp(app_id);
	current_app_ = app_id;
	return OK;
}

StatusCode GameServiceClient::CloseApp() {
	if (!IsAppOpen())
		return APP_NOT_OPEN;
	worker_->CloseApp(current_app_);
	current_app_ = AppId();
	return OK;
}

StatusCode GameServiceClient::AssignMatch(const MatchRequest& match_request, void* cb_data) {
	if (!match_request.is_valid())
		return INVALID_MATCH_REQUEST;
	if (!IsAppOpen())
		return APP_NOT_OPEN;
	worker_->AssignMatch(match_request, cb_data);
	return OK;
}

StatusCode GameServiceClient::JoinMatch(const std::string& match_id, const std::string& nick, bool acquire_role, void* cb_data) {
	if (!IsAppOpen())
		return APP_NOT_OPEN;
	JoinMatchRequest match_request;
	match_request.set_match_id(match_id);
	match_request.set_nick(nick);
	match_request.set_free_role(acquire_role);
	worker_->JoinMatch(match_request, cb_data);
	return OK;
}

StatusCode GameServiceClient::JoinMatch(const std::string& match_id, const std::string& nick, const std::string& role, void* cb_data) {
	if (!IsAppOpen())
		return APP_NOT_OPEN;
	JoinMatchRequest match_request;
	match_request.set_match_id(match_id);
	match_request.set_nick(nick);
	match_request.set_role(role);
	worker_->JoinMatch(match_request, cb_data);
	return OK;
}

StatusCode GameServiceClient::StartMatch(const std::string& match_id, void* cb_data) {
	if (!IsAppOpen())
		return APP_NOT_OPEN;
	worker_->StartMatch(match_id, cb_data);
	return OK;
}

StatusCode GameServiceClient::LeaveMatch(const std::string& match_id, void* cb_data) {
	if (!IsAppOpen())
		return APP_NOT_OPEN;
	worker_->LeaveMatch(match_id, cb_data);
	return OK;
}

StatusCode GameServiceClient::SendTurn(const std::string& match_id, const std::string& state, bool terminate, void* cb_data) {
	if (!IsAppOpen())
		return APP_NOT_OPEN;

	Turn turn;
	turn.set_new_state(state);
	turn.set_terminate(terminate);
	worker_->PostTurn(match_id, turn, cb_data);
	return OK;
}

StatusCode GameServiceClient::GetMatchData(const GameId& game_id) {
	return OK;
}

bool GameServiceClient::DoCallbacks(uint wait_millis) {
	return worker_->DoCallbacks(wait_millis);
}

}
