#ifndef _XMPPTASKS_H_
#define _XMPPTASKS_H_

#include <taskparent.h>
#include <xmpptask.h>
#include <qname.h>
#include <sigslot.h>

#include "libgameservice.h"
#include "game.h"
#include "matchstate.h"
#include "matchrequest.h"
#include "joinmatchrequest.h"
#include "participant.h"
#include "turn.h"
#include "item.h"

namespace libgameservice {

class MUGMessageListenerTask : public txmpp::XmppTask {
  public:
    explicit MUGMessageListenerTask(txmpp::TaskParent *parent);
    virtual ~MUGMessageListenerTask();
    virtual int ProcessStart();
    virtual int ProcessResponse();
    bool HandleStanza(const txmpp::XmlElement *stanza);

    txmpp::signal2<const std::string&, const Participant&> SignalStart;
    txmpp::signal2<const std::string&, const Participant&> SignalLeave;
    txmpp::signal3<const std::string&, const Participant&, const Turn&> SignalTurn;
};

class MUGPresenceListenerTask : public txmpp::XmppTask {
  public:
    explicit MUGPresenceListenerTask(txmpp::TaskParent *parent);
    virtual ~MUGPresenceListenerTask();
    virtual int ProcessStart();
    virtual int ProcessResponse();
    bool HandleStanza(const txmpp::XmlElement *stanza);

    txmpp::signal3<const std::string&, const Participant&, const Item&> SignalJoin;
    txmpp::signal2<const std::string&, const Participant&> SignalUnavailable;
    txmpp::signal3<const std::string&, const Participant&, const std::string&> SignalNicknameChange;
    txmpp::signal3<const std::string&, const MatchStatus&, const MatchState&> SignalMatchState;
};

class ListGamesTask : public txmpp::XmppTask {
	public:
		explicit ListGamesTask(txmpp::TaskParent *parent);
		virtual ~ListGamesTask();
		virtual int ProcessStart();
		virtual int ProcessResponse();
		bool HandleStanza(const txmpp::XmlElement *stanza);

		txmpp::signal2<const ResponseStatus&, const std::vector<GameId>&> SignalListOfGames;
	//	txmpp::signal1<
		private:

};

class RegisterAppTask : public txmpp::XmppTask {
public:
	RegisterAppTask(txmpp::TaskParent *parent, const AppId& app_id);
	virtual ~RegisterAppTask();
	virtual int ProcessStart();
	virtual int ProcessResponse();
	bool HandleStanza(const txmpp::XmlElement *stanza);

	txmpp::signal2<const ResponseStatus&, const AppId&> SignalDone;
private:
	AppId app_id_;
};

class RegisterGameTask : public txmpp::XmppTask {
public:
	RegisterGameTask(txmpp::TaskParent *parent, const Game& game);
	virtual ~RegisterGameTask();
	virtual int ProcessStart();
	virtual int ProcessResponse();
	bool HandleStanza(const txmpp::XmlElement *stanza);

	txmpp::signal2<const ResponseStatus&, const Game&> SignalDone;
private:
	Game game_;
};

class OpenAppTask : public txmpp::XmppTask {
public:
	OpenAppTask(txmpp::TaskParent *parent, const AppId& app_id);
	virtual ~OpenAppTask();
	virtual int ProcessStart();
	virtual int ProcessResponse();

	txmpp::signal2<const ResponseStatus&, const AppId&> SignalDone;
private:
	AppId app_id_;
};


class CloseAppTask : public txmpp::XmppTask {
public:
	CloseAppTask(txmpp::TaskParent *parent, const AppId& app_id);
	virtual ~CloseAppTask();
	virtual int ProcessStart();
	virtual int ProcessResponse();

	txmpp::signal2<const ResponseStatus&, const AppId&> SignalDone;
private:
	AppId app_id_;
};

class AssignMatchTask : public txmpp::XmppTask {
public:
	AssignMatchTask(txmpp::TaskParent *parent, const MatchRequest& match_request, void* cb_data);
	virtual ~AssignMatchTask();
	virtual int ProcessStart();
	virtual int ProcessResponse();
	bool HandleStanza(const txmpp::XmlElement *stanza);

	txmpp::signal4<const ResponseStatus&, const MatchRequest&, const std::string&, void*> SignalDone;

private:
	MatchRequest match_request_;
	void* cb_data_;
};

class JoinMatchTask : public txmpp::XmppTask {
public:
	JoinMatchTask(txmpp::TaskParent *parent, const JoinMatchRequest& match_request_, void* cb_data);
	virtual ~JoinMatchTask();
	virtual int ProcessStart();
	virtual int ProcessResponse();
	bool HandleStanza(const txmpp::XmlElement *stanza);

	txmpp::signal5<const ResponseStatus&, const std::string&, const Participant&, const Item&, void*> SignalDone;

private:
	JoinMatchRequest join_match_request_;
	void* cb_data_;
};

class StartMatchTask : public txmpp::XmppTask {
public:
	StartMatchTask(txmpp::TaskParent *parent, const std::string& match_id, void* cb_data);
	virtual ~StartMatchTask();
	virtual int ProcessStart();

	txmpp::signal2<const ResponseStatus&, void*> SignalDone;

private:
	std::string match_id_;
	void* cb_data_;
};

class LeaveMatchTask : public txmpp::XmppTask {
public:
	LeaveMatchTask(txmpp::TaskParent *parent, const std::string& match_id, void* cb_data);
	virtual ~LeaveMatchTask();
	virtual int ProcessStart();

	txmpp::signal2<const ResponseStatus&, void*> SignalDone;

private:
	std::string match_id_;
	void* cb_data_;
};

class TurnTask : public txmpp::XmppTask {
public:
	TurnTask(txmpp::TaskParent *parent, const std::string& match_id, const Turn& turn, void* cb_data);
	virtual ~TurnTask();
	virtual int ProcessStart();

	txmpp::signal2<const ResponseStatus&, void*> SignalDone;

private:
	std::string match_id_;
	Turn turn_;
	void* cb_data_;
};



}  // namespace libgameservice

#endif  // _XMPPTASKS_H_
