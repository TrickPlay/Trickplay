#include <iostream>

#include <constants.h>
#include <logging.h>
#include <xmppclient.h>

#include "xmppmugconstants.h"
#include "xmpptasks.h"

namespace libgameservice {

extern const txmpp::Jid getMugServiceJid();


//const txmpp::Jid JID_MUG_SERVICE("mug.internal.trickplay.com");
static MatchStatus extractMatchStatus(const txmpp::XmlElement* statusElement)
{
	MatchStatus status = unknown;
	if ( statusElement != NULL ) {
		std::string status_str( statusElement->BodyText() );
		status = stringToMatchStatus( status_str );
	}
	return status;
}


static MatchState extractMatchState(const txmpp::XmlElement* stateElement)
{
	MatchState match_state;

	if (stateElement == NULL) {
		return match_state;
	}


	const txmpp::XmlElement* tmpElement = stateElement->FirstNamed(QN_MUG_TURNBASED_FIRST_TAG);
	if (tmpElement != NULL)
		match_state.set_first(tmpElement->BodyText());
	tmpElement = stateElement->FirstNamed(QN_MUG_TURNBASED_OPAQUE_TAG);
	if (tmpElement != NULL)
		match_state.set_opaque(tmpElement->BodyText());

	tmpElement = stateElement->FirstNamed(QN_MUG_TURNBASED_NEXT_TAG);
	if (tmpElement != NULL)
		match_state.set_next(tmpElement->BodyText());

	tmpElement = stateElement->FirstNamed(QN_MUG_TURNBASED_LAST_TAG);
	if (tmpElement != NULL)
		match_state.set_last(tmpElement->BodyText());

	tmpElement = stateElement->FirstNamed(
			QN_MUG_TURNBASED_TERMINATED_TAG);
	match_state.set_terminate(tmpElement != NULL);

	tmpElement = stateElement->FirstNamed(QN_MUG_TURNBASED_ROLES_TAG);
	if (tmpElement != NULL) {
		tmpElement = tmpElement->FirstNamed(QN_MUG_TURNBASED_ROLE_TAG);
		while (tmpElement != NULL) {
			match_state.players().push_back(tmpElement->BodyText());
			tmpElement = tmpElement->NextNamed(QN_MUG_TURNBASED_ROLE_TAG);
		}
	}
	return match_state;
}


// MUG message listener

MUGMessageListenerTask::MUGMessageListenerTask(txmpp::TaskParent *parent) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_TYPE) {

	//txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE) {

	//	std::cout << "Inside MUGMessageListenerTask constructor" << std::endl;
}

MUGMessageListenerTask::~MUGMessageListenerTask() {
}

int MUGMessageListenerTask::ProcessStart() {
	return STATE_RESPONSE;
}

int MUGMessageListenerTask::ProcessResponse() {

	const txmpp::XmlElement* stanza = NextStanza();
	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	txmpp::Jid from(stanza->Attr(txmpp::QN_FROM));
	std::string match_id(from.BareJid().Str());
	Participant participant(Participant::parseParticipant(from.resource()));

	const txmpp::XmlElement *childElement = stanza->FirstElement();
	if (childElement == NULL) {
	//	std::cout << "MUGMessageListenerTask::ProcessResponse. childElement is NULL" << std::endl;
		return STATE_RESPONSE;
	} else {
		//std::cout << "MUGMessageListenerTask::ProcessResponse. childElement:" << childElement->Str() << std::endl;
	}
	if (QN_MUG_USER_START_TAG == childElement->Name()) {
		SignalStart(match_id, participant);
	} else if (QN_MUG_USER_LEAVE_TAG == childElement->Name()) {
		SignalLeave(match_id, participant);
	} else { // must be turn tag
		// extract newstate, terminate and next
	//	std::cout << "MUGMessageListenerTask::ProcessResponse. received a turn message" << std::endl;
		Turn turn;
		const txmpp::XmlElement* tmpElement = childElement->FirstNamed(QN_MUG_USER_NEWSTATE_TAG);
		if (tmpElement != NULL)
			turn.set_new_state(tmpElement->BodyText());
		tmpElement = childElement->FirstNamed(QN_MUG_USER_TERMINATE_TAG);
		turn.set_terminate(tmpElement != NULL);

		tmpElement = childElement->FirstNamed(QN_MUG_USER_NEXT_TAG);
		if (tmpElement != NULL)
			turn.set_next_turn(tmpElement->BodyText());

		SignalTurn(match_id, participant, turn);
	}


	return STATE_RESPONSE;
}

bool MUGMessageListenerTask::HandleStanza(const txmpp::XmlElement *stanza) {
//	std::cout << "Inside MUGMessageListenerTask::HandleStanza. " <<  std::endl;

	if (txmpp::QN_MESSAGE == stanza->Name() && stanza->HasAttr(txmpp::QN_FROM)) {
		if (stanza->FirstNamed(txmpp::QN_ERROR) != NULL)
			return false;

		// start or leave or turn messages are accepted
		const txmpp::XmlElement* nextElement = stanza->FirstElement();
		if (nextElement == NULL)
			return false;
		txmpp::QName elementName(nextElement->Name());
		if (elementName == QN_MUG_USER_START_TAG ||
				elementName == QN_MUG_USER_LEAVE_TAG ||
				elementName == QN_MUG_USER_TURN_TAG) {
			QueueStanza(stanza);
			return true;
		}
	}

	return false;
}

/**
 * MUG presence handler
 */

MUGPresenceListenerTask::MUGPresenceListenerTask(txmpp::TaskParent *parent) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_TYPE) {
	//std::cout << "Inside MUGPresenceListenerTask constructor" << std::endl;
}

MUGPresenceListenerTask::~MUGPresenceListenerTask() {
}

int MUGPresenceListenerTask::ProcessStart() {
	return STATE_RESPONSE;
}

int MUGPresenceListenerTask::ProcessResponse() {

	//std::cout << "Received a presence packet. processing it" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();
	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	txmpp::Jid from(stanza->Attr(txmpp::QN_FROM));
	std::string match_id(from.BareJid().Str());
	Participant participant(Participant::parseParticipant(from.resource()));

	const txmpp::XmlElement *gameElement = stanza->FirstNamed(QN_MUG_GAMEPRESENCE_TAG);
	if (gameElement == NULL) {
	//	std::cout << "invalid stanza: " << stanza->Str() << ". skipping it" << std::endl;
		return STATE_RESPONSE;
	}

	if (stanza->HasAttr(txmpp::QN_TYPE) && txmpp::STR_UNAVAILABLE == stanza->Attr(txmpp::QN_TYPE)) {
			SignalUnavailable(match_id, participant);
	} else {
		const txmpp::XmlElement* itemElement = gameElement->FirstNamed(
				QN_MUG_ITEM_TAG);
		if (itemElement != NULL) {
			if (itemElement->HasAttr(QN_NICK_ATTR)) {
				std::string nick(itemElement->Attr(QN_NICK_ATTR));
				SignalNicknameChange(match_id, participant, nick);
			} else {
				Item item;
				item.set_role(itemElement->Attr(QN_ROLE_ATTR));
				item.set_affiliation(
						stringToAffiliation(
								itemElement->Attr(QN_AFFILIATION_ATTR)));
				item.set_jid(itemElement->Attr(QN_JID_ATTR));
				SignalJoin(match_id, participant, item);
			}
		} else { // match state update

			const txmpp::XmlElement* tmpElement = gameElement->FirstNamed(QN_MUG_STATUS_TAG);
			MatchStatus status = extractMatchStatus( tmpElement );

			const txmpp::XmlElement* stateElement = gameElement->FirstNamed(QN_MUG_TURNBASED_STATE_TAG);

			if (!isValidMatchStatus(status) || stateElement == NULL) {
		//		std::cout << "invalid match state. stanza:" << stanza->Str() << ". skipping it" << std::endl;
				return STATE_RESPONSE;
			}


			MatchState match_state = extractMatchState( stateElement );


			SignalMatchState(match_id, status, match_state);

		}
	}

	return STATE_RESPONSE;
}

bool MUGPresenceListenerTask::HandleStanza(const txmpp::XmlElement *stanza) {

//	std::cout << "Inside MUGPresenceListenerTask::HandleStanza. " <<  std::endl;
	if (txmpp::QN_PRESENCE == stanza->Name()  && stanza->HasAttr(txmpp::QN_FROM)) {
		if (stanza->FirstNamed(txmpp::QN_ERROR) != NULL)
			return false;

		// make sure the presence stanza child is QN_MUG_GAMEPRESENCE_TAG
		const txmpp::XmlElement* nextElement = stanza->FirstNamed(QN_MUG_GAMEPRESENCE_TAG);
		if (nextElement == NULL)
			return false;
		else {
			QueueStanza(stanza);
			return true;
		}
	}

	return false;
}


// ListGames task
ListGamesTask::ListGamesTask(txmpp::TaskParent *parent, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), cb_data_(cb_data) {

//	std::cout << "Inside ListGamesTask constructor" << std::endl;
}

ListGamesTask::~ListGamesTask() {
}

int ListGamesTask::ProcessStart() {

	//std::cout << "ListGameTask taskid is " << task_id() << std::endl;

	// set_task_id(GetClient()->NextId());

	txmpp::scoped_ptr<txmpp::XmlElement> disco_info_iq(
			MakeIq("get", getMugServiceJid(), task_id()));
	txmpp::XmlElement *query =
			new txmpp::XmlElement(txmpp::QN_DISCO_INFO_QUERY);
	disco_info_iq->AddElement(query);

	SendStanza(disco_info_iq.get());

	return STATE_RESPONSE;
}

int ListGamesTask::ProcessResponse() {

	//	std::cout << "Inside ListGamesTask::ProcessResponse()" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	std::vector<GameId> game_id_vector;
	const txmpp::XmlElement* discoInfoResponse = stanza->FirstNamed(txmpp::QN_DISCO_INFO_QUERY);
	if (discoInfoResponse != NULL) {
		const txmpp::XmlElement* featureElement = discoInfoResponse->FirstNamed(txmpp::QN_DISCO_FEATURE);
		while (NULL != featureElement) {
			const std::string& var = featureElement->Attr(txmpp::QN_VAR);
			//std::cout << "feature:" << var << std::endl;
			GameId gid(GameId::parseGameId(var));
			if (gid.is_valid()) {
				game_id_vector.push_back(gid);
			}

			featureElement = featureElement->NextNamed(txmpp::QN_DISCO_FEATURE);
		}
	}
	//std::cout << "game_id_vector.size()=" << game_id_vector.size() << std::endl;
	//std::cout << "emitting SignalListOfGames()" << std::endl;
	ResponseStatus rs;
	SignalListOfGames.emit(rs, game_id_vector, cb_data_);
//	std::cout << "Discover Info IQ query results follow: " << std::endl;
//	std::cout << stanza->Str() << std::endl;

	return STATE_DONE;
}

bool ListGamesTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "ListGamesTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;

	if (MatchResponseIq(stanza, getMugServiceJid(), task_id())) {
		QueueStanza(stanza);
		return true;
	}

	return false;
}

// RegisterApp task
RegisterAppTask::RegisterAppTask(txmpp::TaskParent *parent, const AppId & app_id, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), app_id_(app_id), cb_data_(cb_data) {

	//std::cout << "Inside RegisterAppTask constructor" << std::endl;
}

RegisterAppTask::~RegisterAppTask() {
}

int RegisterAppTask::ProcessStart() {

	//std::cout << "RegisterAppTask taskid is " << task_id() << std::endl;

	txmpp::scoped_ptr<txmpp::XmlElement> iqStanza(
			MakeIq("set", getMugServiceJid(), task_id()));
	txmpp::XmlElement *registerAppElement = new txmpp::XmlElement(
			QN_MUG_OWNER_REGISTER_APP);
	txmpp::XmlElement *nameElement = new txmpp::XmlElement(
			QN_MUG_OWNER_NAME_TAG);
	nameElement->AddText(app_id_.name());
	registerAppElement->AddElement(nameElement);
	txmpp::XmlElement *versionElement = new txmpp::XmlElement(
			QN_MUG_OWNER_VERSION_TAG);
	versionElement->AddText(intToString(app_id_.version()));
	registerAppElement->AddElement(versionElement);

	iqStanza->AddElement(registerAppElement);

	SendStanza(iqStanza.get());

	return STATE_RESPONSE;
}

int RegisterAppTask::ProcessResponse() {

	//	std::cout << "Inside ListGamesTask::ProcessResponse()" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	//std::cout << "RegisterApp results follow: " << std::endl;
	//std::cout << stanza->Str() << std::endl;
	bool got_error = false;
	if (stanza->FirstNamed(txmpp::QN_ERROR) != NULL) {
		got_error = true;
	}

	//const txmpp::XmlElement* discoInfoResponse = stanza->FirstNamed(txmpp::QN_DISCO_INFO_QUERY);
	ResponseStatus rs(got_error?FAILED:OK, "");

	SignalDone(rs, app_id_, cb_data_);

	return STATE_DONE;
}

bool RegisterAppTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "ListGamesTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;

	if (MatchResponseIq(stanza, getMugServiceJid(), task_id())) {
		QueueStanza(stanza);
		return true;
	}

	return false;
}

// RegisterGame task
RegisterGameTask::RegisterGameTask(txmpp::TaskParent *parent, const Game & game, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), game_(game), cb_data_(cb_data) {

	//std::cout << "Inside RegisterGameTask constructor" << std::endl;
}

RegisterGameTask::~RegisterGameTask() {
}

int RegisterGameTask::ProcessStart() {

	//std::cout << "RegisterGameTask taskid is " << task_id() << std::endl;

	txmpp::scoped_ptr<txmpp::XmlElement> iqStanza(
			MakeIq("set", getMugServiceJid(), task_id()));
	txmpp::XmlElement *registerGameElement = new txmpp::XmlElement(
			QN_MUG_OWNER_REGISTER_GAME);
	txmpp::XmlElement *appElement = new txmpp::XmlElement(QN_MUG_OWNER_APP_TAG);
	appElement->AddAttr(QN_NAME_ATTR, game_.game_id().app_id().name());
	appElement->AddAttr(QN_VERSION_ATTR, intToString(game_.game_id().app_id().version()));
	registerGameElement->AddElement(appElement);

	txmpp::XmlElement *nameElement = new txmpp::XmlElement(
			QN_MUG_OWNER_NAME_TAG);
	nameElement->AddText(game_.game_id().name());
	registerGameElement->AddElement(nameElement);

	if (!game_.description().empty()) {
		txmpp::XmlElement *descriptionElement = new txmpp::XmlElement(
				QN_MUG_OWNER_DESCRIPTION_TAG);
		descriptionElement->AddText(game_.description());
		registerGameElement->AddElement(descriptionElement);
	}

	if (!(game_.category().empty())) {
		txmpp::XmlElement *categoryElement = new txmpp::XmlElement(
				QN_MUG_OWNER_CATEGORY_TAG);
		categoryElement->AddText(game_.category());
		registerGameElement->AddElement(categoryElement);
	}

	txmpp::XmlElement *gameTypeElement = new txmpp::XmlElement(
					QN_MUG_OWNER_GAMETYPE_TAG);
	gameTypeElement->AddText(Game::game_type_to_string(game_.game_type()));
	registerGameElement->AddElement(gameTypeElement);

	txmpp::XmlElement *turnPolicyElement = new txmpp::XmlElement(
						QN_MUG_OWNER_TURNPOLICY_TAG);
	turnPolicyElement->AddText(Game::turn_policy_to_string(game_.turn_policy()));
	registerGameElement->AddElement(turnPolicyElement);

	if (!game_.roles().empty()) {
		txmpp::XmlElement *rolesElement = new txmpp::XmlElement(
								QN_MUG_OWNER_ROLES_TAG);

		RoleVector::iterator it;
		for ( it=game_.roles().begin() ; it < game_.roles().end(); it++ ) {
			txmpp::XmlElement *roleElement = new txmpp::XmlElement(
					QN_MUG_OWNER_ROLE_TAG);
			roleElement->AddText((*it).name());

			if ((*it).cannot_start()) {
				txmpp::XmlElement *cannotStartElement = new txmpp::XmlElement(QN_MUG_OWNER_CANNOTSTART_TAG);
				roleElement->AddElement(cannotStartElement);
			}
			if ((*it).first_role()) {
				txmpp::XmlElement *firstRoleElement = new txmpp::XmlElement(
						QN_MUG_OWNER_FIRSTROLE_TAG);
				roleElement->AddElement(firstRoleElement);
			}

			rolesElement->AddElement(roleElement);
		}
		registerGameElement->AddElement(rolesElement);

		txmpp::XmlElement *joinAfterStartElement = new txmpp::XmlElement(
				QN_MUG_OWNER_JOINAFTERSTART_TAG);
		joinAfterStartElement->AddText(booleanToString(game_.join_after_start()));
		registerGameElement->AddElement(joinAfterStartElement);

		txmpp::XmlElement *minPlayersForStartElement = new txmpp::XmlElement(
				QN_MUG_OWNER_JOINAFTERSTART_TAG);
		minPlayersForStartElement->AddText(
				intToString(game_.min_players_for_start()));
		registerGameElement->AddElement(minPlayersForStartElement);

		if (game_.max_duration_per_turn() > 0) {
			txmpp::XmlElement *maxDurationPerElement = new txmpp::XmlElement(
					QN_MUG_OWNER_MAXDURATIONPERTURN_TAG);
			maxDurationPerElement->AddText(
					longToString(game_.max_duration_per_turn()));
			registerGameElement->AddElement(maxDurationPerElement);
		}

		txmpp::XmlElement *abortWhenPlayerLeavesElement =
				new txmpp::XmlElement(QN_MUG_OWNER_ABORTWHENPLAYERLEAVES_TAG);
		abortWhenPlayerLeavesElement->AddText(
				booleanToString(game_.abort_when_player_leaves()));
		registerGameElement->AddElement(abortWhenPlayerLeavesElement);
	}

	iqStanza->AddElement(registerGameElement);

	SendStanza(iqStanza.get());

	return STATE_RESPONSE;
}

int RegisterGameTask::ProcessResponse() {

	//	std::cout << "Inside ListGamesTask::ProcessResponse()" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	//std::cout << "RegisterGame results follow: " << std::endl;
	//std::cout << stanza->Str() << std::endl;

	bool got_error = false;
	if (stanza->FirstNamed(txmpp::QN_ERROR) != NULL) {
		got_error = true;
	}

	//const txmpp::XmlElement* discoInfoResponse = stanza->FirstNamed(txmpp::QN_DISCO_INFO_QUERY);
	ResponseStatus rs(got_error?FAILED:OK, "");


	SignalDone(rs, game_, cb_data_);

	return STATE_DONE;
}

bool RegisterGameTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "ListGamesTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;

	if (MatchResponseIq(stanza, getMugServiceJid(), task_id())) {
		QueueStanza(stanza);
		return true;
	}

	return false;
}

// OpenApp task
OpenAppTask::OpenAppTask(txmpp::TaskParent *parent, const AppId & app_id, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), app_id_(app_id), cb_data_(cb_data) {

	//std::cout << "Inside OpenAppTask constructor" << std::endl;
}

OpenAppTask::~OpenAppTask() {
}

int OpenAppTask::ProcessStart() {

	txmpp::scoped_ptr<txmpp::XmlElement> presence(new txmpp::XmlElement(txmpp::QN_PRESENCE));
	presence->AddAttr(txmpp::QN_TO, getMugServiceJid().Str());

	txmpp::XmlElement *appElement = new txmpp::XmlElement(
			QN_MUG_APP_TAG);
	appElement->AddAttr(QN_APPID_ATTR, app_id_.AsID());

	presence->AddElement(appElement);

	SendStanza(presence.get());

	return STATE_RESPONSE;
}

int OpenAppTask::ProcessResponse() {

	//const txmpp::XmlElement* discoInfoResponse = stanza->FirstNamed(txmpp::QN_DISCO_INFO_QUERY);
	ResponseStatus rs;

	SignalDone(rs, app_id_, cb_data_);

	return STATE_DONE;
}

// CloseApp task
CloseAppTask::CloseAppTask(txmpp::TaskParent *parent, const AppId & app_id, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), app_id_(app_id), cb_data_(cb_data) {

	//std::cout << "Inside CloseAppTask constructor" << std::endl;
}

CloseAppTask::~CloseAppTask() {
}

int CloseAppTask::ProcessStart() {

	txmpp::scoped_ptr<txmpp::XmlElement> presence(new txmpp::XmlElement(txmpp::QN_PRESENCE));
	presence->AddAttr(txmpp::QN_TO, getMugServiceJid().Str());
	presence->AddAttr(txmpp::QN_TYPE, txmpp::STR_UNAVAILABLE);
	txmpp::XmlElement *appElement = new txmpp::XmlElement(
			QN_MUG_APP_TAG);
	appElement->AddAttr(QN_APPID_ATTR, app_id_.AsID());

	presence->AddElement(appElement);

	SendStanza(presence.get());

	return STATE_RESPONSE;
}

int CloseAppTask::ProcessResponse() {

	//const txmpp::XmlElement* discoInfoResponse = stanza->FirstNamed(txmpp::QN_DISCO_INFO_QUERY);
	ResponseStatus rs;

	SignalDone(rs, app_id_, cb_data_);

	return STATE_DONE;
}

// AssignMatch task
AssignMatchTask::AssignMatchTask(txmpp::TaskParent *parent, const MatchRequest & match_request, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), match_request_(match_request), cb_data_(cb_data) {

	//std::cout << "Inside AssignMatchTask constructor" << std::endl;
}

AssignMatchTask::~AssignMatchTask() {
}

int AssignMatchTask::ProcessStart() {

	//std::cout << "AssignMatchTask taskid is " << task_id() << std::endl;

	txmpp::scoped_ptr<txmpp::XmlElement> iqStanza(
			MakeIq("set", getMugServiceJid(), task_id()));
	txmpp::XmlElement *matchRequestElement = new txmpp::XmlElement(
			QN_MUG_ASSIGNMATCH_TAG);
	matchRequestElement->AddAttr(QN_GAMEID_ATTR, match_request_.game_id());

	if (match_request_.new_match()) {
		matchRequestElement->AddElement(new txmpp::XmlElement(QN_MUG_NEWMATCH_TAG));
	}

	if (match_request_.free_role()) {
		matchRequestElement->AddElement(new txmpp::XmlElement(QN_MUG_FREEROLE_TAG));
	}
	if (!match_request_.role().empty()) {
		txmpp::XmlElement *roleElement = new txmpp::XmlElement(QN_MUG_ROLE_TAG);
		roleElement->AddText(match_request_.role());
		matchRequestElement->AddElement(roleElement);
	}
	if (!match_request_.nick().empty()) {
		txmpp::XmlElement *nickElement = new txmpp::XmlElement(QN_MUG_NICKNAME_TAG);
		nickElement->AddText(match_request_.nick());
		matchRequestElement->AddElement(nickElement);
	}

	iqStanza->AddElement(matchRequestElement);

	SendStanza(iqStanza.get());

	return STATE_RESPONSE;
}

int AssignMatchTask::ProcessResponse() {

	//	std::cout << "Inside ListGamesTask::ProcessResponse()" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	//std::cout << "AssignMatch results follow: " << std::endl;
	//std::cout << stanza->Str() << std::endl;

	bool got_error = false;
	if (stanza->FirstNamed(txmpp::QN_ERROR) != NULL) {
		got_error = true;
	}

	//const txmpp::XmlElement* discoInfoResponse = stanza->FirstNamed(txmpp::QN_DISCO_INFO_QUERY);
	ResponseStatus rs(got_error?FAILED:OK, "");


	SignalDone(rs, match_request_, from, cb_data_);

	return STATE_DONE;
}

bool AssignMatchTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "ListGamesTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;
	 txmpp::Jid from(stanza->Attr(txmpp::QN_FROM));

	if (stanza->Attr(txmpp::QN_ID) == task_id() && from.domain() == getMugServiceJid().domain()) {
		QueueStanza(stanza);
		return true;
	}

	return false;
}

// JoinMatch task
JoinMatchTask::JoinMatchTask(txmpp::TaskParent *parent, const JoinMatchRequest& match_request, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), join_match_request_(match_request), cb_data_(cb_data) {

	//std::cout << "Inside JoinMatchTask constructor" << std::endl;
}

JoinMatchTask::~JoinMatchTask() {
}

int JoinMatchTask::ProcessStart() {

	//std::cout << "JoinMatchTask taskid is " << task_id() << std::endl;

	txmpp::scoped_ptr<txmpp::XmlElement> presence(new txmpp::XmlElement(txmpp::QN_PRESENCE));
	presence->AddAttr(txmpp::QN_TO, join_match_request_.match_id() + "/" + join_match_request_.nick());

	txmpp::XmlElement *joinMatchElement = new txmpp::XmlElement(
			QN_MUG_GAMEPRESENCE_TAG);

	if (join_match_request_.free_role()) {
		joinMatchElement->AddElement(new txmpp::XmlElement(QN_MUG_ITEM_TAG));
	} else {
		if (!join_match_request_.role().empty()) {
			txmpp::XmlElement *itemElement = new txmpp::XmlElement(QN_MUG_ITEM_TAG);
			itemElement->AddAttr(QN_ROLE_ATTR, join_match_request_.role());
			joinMatchElement->AddElement(itemElement);
		}
	}

	presence->AddElement(joinMatchElement);

	SendStanza(presence.get());

	return STATE_RESPONSE;
}

int JoinMatchTask::ProcessResponse() {

	//std::cout << "Inside ListGamesTask::ProcessResponse()" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	txmpp::Jid fromJid(from);

	Participant p = Participant::parseParticipant(fromJid.resource());

	//std::cout << "JoinMatchTask::ProcessResponse. processing stanza: " << std::endl;
	//std::cout << stanza->Str() << std::endl;

	bool got_error = false;
	if (stanza->FirstNamed(txmpp::QN_ERROR) != NULL) {
		got_error = true;
	}

	//const txmpp::XmlElement* discoInfoResponse = stanza->FirstNamed(txmpp::QN_DISCO_INFO_QUERY);
	Item item;
	if (!got_error) {
		const txmpp::XmlElement* gameElement = stanza->FirstNamed(QN_MUG_GAMEPRESENCE_TAG);
		if (gameElement != NULL) {
			const txmpp::XmlElement* itemElement = NULL;

			if (NULL == (itemElement = gameElement->FirstNamed(QN_MUG_ITEM_TAG))) {
			/*	std::cout
						<< "JoinMatchTask::ProcessResponse. invalid stanza. failed to find <item> tag"
						<< std::endl; */
				got_error = true;
			} else {
				if (itemElement->HasAttr(QN_ROLE_ATTR))
					item.set_role(itemElement->Attr(QN_ROLE_ATTR));
				if (itemElement->HasAttr(QN_AFFILIATION_ATTR))
					item.set_affiliation(
							stringToAffiliation(
									itemElement->Attr(QN_AFFILIATION_ATTR)));
				if (itemElement->HasAttr(QN_JID_ATTR))
					item.set_jid(itemElement->Attr(QN_JID_ATTR));

			//	std::cout << "Item:" << item.Str() << std::endl;
			}
		}
	}
	ResponseStatus rs(got_error?FAILED:OK, "");

	SignalDone(rs, join_match_request_.match_id(), p, item, cb_data_);

	return STATE_DONE;
}

bool JoinMatchTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "JoinMatchTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;
	 txmpp::Jid from(stanza->Attr(txmpp::QN_FROM));

	if (stanza->Name() == txmpp::QN_PRESENCE && from.BareJid() == txmpp::Jid(join_match_request_.match_id())) {

		const txmpp::XmlElement* childElement = stanza->FirstNamed(QN_MUG_GAMEPRESENCE_TAG);
		if (childElement != NULL) {
			if (childElement->FirstNamed(QN_MUG_ITEM_TAG) != NULL
					&& childElement->FirstNamed(QN_MUG_STATUS_TAG) != NULL) {
			//	std::cout << "JoinMatchTask::HandleStanza. found element with <item> and <status> tags." << std::endl;
				const txmpp::XmlElement* statusElement = childElement->FirstNamed(QN_MUG_STATUS_TAG);
				//std::cout << "status:" << statusElement->Str() << std::endl;
				std::string code(statusElement->Attr(QN_CODE_ATTR));
				if (code == "110") {
					QueueStanza(stanza);
					return true;
				} else {
					//std::cout << "JoinMatchTask::HandleStanza. status.code is not 110. code:" << code << std::endl;
				}
			} else {
				//std::cout << "JoinMatchTask::HandleStanza. did not find <status> tag" << std::endl;
			}
		} else {
			//std::cout << "JoinMatchTask::HandleStanza. childElement does not have <game> tag" << std::endl;
		}
	}
	//std::cout << "JoinMatchTask::HandleStanza. finished processing" << std::endl;

	return false;
}

// StartMatch task
StartMatchTask::StartMatchTask(txmpp::TaskParent *parent, const std::string& match_id, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), match_id_(match_id), cb_data_(cb_data) {

	//std::cout << "Inside StartMatchTask constructor" << std::endl;
}

StartMatchTask::~StartMatchTask() {
}

int StartMatchTask::ProcessStart() {

	//std::cout << "StartMatchTask taskid is " << task_id() << std::endl;

	txmpp::scoped_ptr<txmpp::XmlElement> message(
					new txmpp::XmlElement(txmpp::QN_MESSAGE));
	message->SetAttr(txmpp::QN_TO, match_id_);

	txmpp::XmlElement *start = new txmpp::XmlElement(QN_MUG_USER_START_TAG);

	message->AddElement(start);

	SendStanza(message.get());

	SignalDone(ResponseStatus(), cb_data_);

	return STATE_DONE;
}



// LeaveMatch task
LeaveMatchTask::LeaveMatchTask(txmpp::TaskParent *parent, const std::string& match_id, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), match_id_(match_id), cb_data_(cb_data) {

	std::cout << "Inside LeaveMatchTask constructor" << std::endl;
}

LeaveMatchTask::~LeaveMatchTask() {
}

int LeaveMatchTask::ProcessStart() {

	//std::cout << "LeaveMatchTask taskid is " << task_id() << std::endl;

	txmpp::scoped_ptr<txmpp::XmlElement> message(
					new txmpp::XmlElement(txmpp::QN_MESSAGE));
	message->SetAttr(txmpp::QN_TO, match_id_);

	txmpp::XmlElement *leave = new txmpp::XmlElement(QN_MUG_USER_LEAVE_TAG);

	message->AddElement(leave);

	SendStanza(message.get());

	SignalDone(ResponseStatus(), cb_data_);

	return STATE_DONE;
}

// Turn task
TurnTask::TurnTask(txmpp::TaskParent *parent, const std::string& match_id, const Turn& turn, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), match_id_(match_id), turn_(turn), cb_data_(cb_data) {

	//std::cout << "Inside TurnTask constructor" << std::endl;
}

TurnTask::~TurnTask() {
}

int TurnTask::ProcessStart() {

	//std::cout << "TurnTask taskid is " << task_id() << std::endl;

	txmpp::scoped_ptr<txmpp::XmlElement> message(
					new txmpp::XmlElement(txmpp::QN_MESSAGE));
	message->SetAttr(txmpp::QN_TO, match_id_);

	txmpp::XmlElement *turnElement = new txmpp::XmlElement(QN_MUG_USER_TURN_TAG);

	txmpp::XmlElement *stateElement = new txmpp::XmlElement(QN_MUG_USER_NEWSTATE_TAG);
	stateElement->AddCDATAText(turn_.new_state().c_str(), turn_.new_state().size());
//	stateElement->AddText(turn_.new_state());
	turnElement->AddElement(stateElement);

	if (turn_.terminate()) {
		txmpp::XmlElement *terminateElement = new txmpp::XmlElement(QN_MUG_USER_TERMINATE_TAG);
		turnElement->AddElement(terminateElement);
	} else {
		if (!turn_.next_turn().empty()) {
			txmpp::XmlElement *nextElement = new txmpp::XmlElement(QN_MUG_USER_NEXT_TAG);
			nextElement->AddText(turn_.next_turn());
			turnElement->AddElement(nextElement);
		} else if (turn_.only_update()) {
			txmpp::XmlElement *onlyUpdateElement = new txmpp::XmlElement(QN_MUG_USER_ONLY_UPDATE_TAG);
			turnElement->AddElement(onlyUpdateElement);
		}
	}
	message->AddElement(turnElement);

	SendStanza(message.get());

	SignalDone(ResponseStatus(), cb_data_);

	return STATE_DONE;
}

// GetMatchData task
GetMatchDataTask::GetMatchDataTask(txmpp::TaskParent *parent, const std::string& game_id, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), game_id_(game_id), cb_data_(cb_data) {

//	std::cout << "Inside GetMatchDataTask constructor" << std::endl;
}

GetMatchDataTask::~GetMatchDataTask() {
}

int GetMatchDataTask::ProcessStart() {

	txmpp::scoped_ptr<txmpp::XmlElement> iqStanza(
			MakeIq("get", getMugServiceJid(), task_id()));
	txmpp::XmlElement *matchDataElement = new txmpp::XmlElement(
			QN_MUG_MATCHDATA_TAG);
	matchDataElement->AddAttr(QN_GAMEID_ATTR, game_id_);

	iqStanza->AddElement(matchDataElement);

	SendStanza(iqStanza.get());

	return STATE_RESPONSE;
}

int GetMatchDataTask::ProcessResponse() {

	//	std::cout << "Inside GetMatchDataTask::ProcessResponse()" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	MatchData matchdata;
	matchdata.set_game_id(game_id_);
	const txmpp::XmlElement* matchDataElement = stanza->FirstNamed(QN_MUG_MATCHDATA_TAG);
	if (matchDataElement != NULL) {
		const txmpp::XmlElement* matchElement = matchDataElement->FirstNamed(QN_MUG_MATCH_TAG);
		while( NULL != matchElement )
		{
			// extract match info from match element
			MatchInfo mi;

			mi.set_id(matchElement->Attr(QN_MATCHID_ATTR));
			const txmpp::XmlElement* statusElement = matchElement->FirstNamed(QN_MUG_STATUS_TAG);
			MatchStatus status = extractMatchStatus( statusElement );

			const txmpp::XmlElement* nicknameElement = matchElement->FirstNamed(QN_MUG_NICKNAME_TAG);
			if (nicknameElement != NULL)
				mi.set_nickname(nicknameElement->BodyText());

			const txmpp::XmlElement* inRoomIdElement = matchElement->FirstNamed(QN_MUG_INROOMID_TAG);
			if (inRoomIdElement != NULL)
				mi.set_in_room_id(inRoomIdElement->BodyText());

			const txmpp::XmlElement* stateElement = matchElement->FirstNamed(QN_MUG_TURNBASED_STATE_TAG);

			if (!isValidMatchStatus(status) || stateElement == NULL) {
				continue;
			}

			mi.set_status(status);

			mi.set_state( extractMatchState( stateElement ) );

			matchdata.match_infos().push_back(mi);

			// move to the next match element
			matchElement = matchElement->NextNamed(QN_MUG_MATCH_TAG);
		}
	}


	ResponseStatus rs;
	SignalDone.emit(rs, matchdata, cb_data_);

	return STATE_DONE;
}

bool GetMatchDataTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "GetMatchDataTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;

	if (MatchResponseIq(stanza, getMugServiceJid(), task_id())) {
		QueueStanza(stanza);
		return true;
	}

	return false;
}

// GetUserGameData task
GetUserGameDataTask::GetUserGameDataTask(txmpp::TaskParent *parent, const std::string& game_id, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), game_id_(game_id), cb_data_(cb_data) {

//	std::cout << "Inside GetUserGameDataTask constructor" << std::endl;
}

GetUserGameDataTask::~GetUserGameDataTask() {
}

int GetUserGameDataTask::ProcessStart() {

	txmpp::scoped_ptr<txmpp::XmlElement> iqStanza(
			MakeIq("get", getMugServiceJid(), task_id()));
	txmpp::XmlElement *userGameDataElement = new txmpp::XmlElement(
			QN_MUG_USERDATA_TAG);
	userGameDataElement->AddAttr(QN_GAMEID_ATTR, game_id_);

	iqStanza->AddElement(userGameDataElement);

	SendStanza(iqStanza.get());

	return STATE_RESPONSE;
}

int GetUserGameDataTask::ProcessResponse() {

	//	std::cout << "Inside GetUserGameDataTask::ProcessResponse()" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	UserGameData userdata;
	userdata.set_game_id(game_id_);
	const txmpp::XmlElement* userDataElement = stanza->FirstNamed(QN_MUG_USERDATA_TAG);
	if (userDataElement != NULL) {
		const txmpp::XmlElement* opaqueElement = userDataElement->FirstNamed(QN_MUG_OPAQUE_TAG);

		if (opaqueElement != NULL) {
			userdata.set_opaque(opaqueElement->BodyText());

			if (opaqueElement->HasAttr(QN_VERSION_ATTR)) {
				userdata.set_version(atoi(opaqueElement->Attr(QN_VERSION_ATTR).c_str()));
			}
			else
				userdata.set_version(-1);
		}
	}


	ResponseStatus rs;
	SignalDone.emit(rs, userdata, cb_data_);

	return STATE_DONE;
}

bool GetUserGameDataTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "GetUserGameDataTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;

	if (MatchResponseIq(stanza, getMugServiceJid(), task_id())) {
		QueueStanza(stanza);
		return true;
	}

	return false;
}


// UpdateUserGameData task
UpdateUserGameDataTask::UpdateUserGameDataTask(txmpp::TaskParent *parent, const std::string& game_id, const std::string& opaque, void* cb_data) :
	txmpp::XmppTask(parent, txmpp::XmppEngine::HL_SINGLE), game_id_(game_id), opaque_(opaque), cb_data_(cb_data) {

//	std::cout << "Inside UpdateUserGameDataTask constructor" << std::endl;
}

UpdateUserGameDataTask::~UpdateUserGameDataTask() {
}

int UpdateUserGameDataTask::ProcessStart() {

	txmpp::scoped_ptr<txmpp::XmlElement> iqStanza(
			MakeIq("set", getMugServiceJid(), task_id()));
	txmpp::XmlElement *userGameDataElement = new txmpp::XmlElement(
			QN_MUG_USERDATA_TAG);
	userGameDataElement->AddAttr(QN_GAMEID_ATTR, game_id_);

	txmpp::XmlElement *opaqueElement = new txmpp::XmlElement(
				QN_MUG_OPAQUE_TAG);
	opaqueElement->AddCDATAText(opaque_.c_str(), opaque_.size());

	userGameDataElement->AddElement(opaqueElement);

	iqStanza->AddElement(userGameDataElement);

	SendStanza(iqStanza.get());

	return STATE_RESPONSE;
}

int UpdateUserGameDataTask::ProcessResponse() {

	//	std::cout << "Inside UpdateUserGameDataTask::ProcessResponse()" << std::endl;

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	UserGameData userdata;
	userdata.set_game_id(game_id_);
	const txmpp::XmlElement* userDataElement = stanza->FirstNamed(QN_MUG_USERDATA_TAG);
	if (userDataElement != NULL) {
		const txmpp::XmlElement* opaqueElement = userDataElement->FirstNamed(QN_MUG_OPAQUE_TAG);

		if (opaqueElement != NULL) {
			userdata.set_opaque(opaqueElement->BodyText());

			if (opaqueElement->HasAttr(QN_VERSION_ATTR)) {
				userdata.set_version(atoi(opaqueElement->Attr(QN_VERSION_ATTR).c_str()));
			}
			else
				userdata.set_version(-1);
		}
	}


	ResponseStatus rs;
	SignalDone.emit(rs, userdata, cb_data_);

	return STATE_DONE;
}

bool UpdateUserGameDataTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "UpdateUserGameDataTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;

	if (MatchResponseIq(stanza, getMugServiceJid(), task_id())) {
		QueueStanza(stanza);
		return true;
	}

	return false;
}

} // namespace libgameservice
