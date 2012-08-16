#include <constants.h>

#include "xmppmugconstants.h"


namespace libgameservice {


const std::string NS_IQ_REGISTER("jabber:iq:register");

const std::string NS_MUG("http://jabber.org/protocol/mug");
const std::string NS_MUG_USER("http://jabber.org/protocol/mug#user");
const std::string NS_MUG_OWNER("http://jabber.org/protocol/mug#owner");
const std::string NS_MUG_TURNBASED("http://jabber.org/protocol/mug/generic-turn-based-game");

const txmpp::QName QN_IQ_REGISTER_QUERY(true, NS_IQ_REGISTER, "query");
const txmpp::QName QN_IQ_REGISTER_REGISTERED_TAG(true, NS_IQ_REGISTER, "registered");
const txmpp::QName QN_IQ_REGISTER_USERNAME_TAG(true, NS_IQ_REGISTER, "username");
const txmpp::QName QN_IQ_REGISTER_PASSWORD_TAG(true, NS_IQ_REGISTER, "password");
const txmpp::QName QN_IQ_REGISTER_EMAIL_TAG(true, NS_IQ_REGISTER, "email");
const txmpp::QName QN_IQ_REGISTER_NAME_TAG(true, NS_IQ_REGISTER, "name");


const txmpp::QName QN_MUG_QUERY(true, NS_MUG, "query");
const txmpp::QName QN_MUG_GAME(true, NS_MUG, "game");
const txmpp::QName QN_MUG_OWNER_REGISTER_APP(true, NS_MUG_OWNER, "registerapp");

const txmpp::QName QN_MUG_OWNER_REGISTER_GAME(true, NS_MUG_OWNER, "registergame");

const txmpp::QName QN_MUG_OWNER_APP_TAG(true, NS_MUG_OWNER, "app");
const txmpp::QName QN_MUG_OWNER_NAME_TAG(true, NS_MUG_OWNER, "name");
const txmpp::QName QN_MUG_OWNER_VERSION_TAG(true, NS_MUG_OWNER, "version");


const txmpp::QName QN_MUG_OWNER_DESCRIPTION_TAG(true, NS_MUG_OWNER, "description");
const txmpp::QName QN_MUG_OWNER_CATEGORY_TAG(true, NS_MUG_OWNER, "category");
const txmpp::QName QN_MUG_OWNER_GAMETYPE_TAG(true, NS_MUG_OWNER, "gameType");
const txmpp::QName QN_MUG_OWNER_TURNPOLICY_TAG(true, NS_MUG_OWNER, "turnPolicy");
const txmpp::QName QN_MUG_OWNER_ROLES_TAG(true, NS_MUG_OWNER, "roles");
const txmpp::QName QN_MUG_OWNER_ROLE_TAG(true, NS_MUG_OWNER, "role");
const txmpp::QName QN_MUG_OWNER_CANNOTSTART_TAG(true, NS_MUG_OWNER, "cannotStart");
const txmpp::QName QN_MUG_OWNER_FIRSTROLE_TAG(true, NS_MUG_OWNER, "firstRole");
const txmpp::QName QN_MUG_OWNER_JOINAFTERSTART_TAG(true, NS_MUG_OWNER, "joinAfterStart");
const txmpp::QName QN_MUG_OWNER_MINPLAYERSFORSTART_TAG(true, NS_MUG_OWNER, "minPlayersForStart");
const txmpp::QName QN_MUG_OWNER_MAXDURATIONPERTURN_TAG(true, NS_MUG_OWNER, "maxDurationPerTurn");
const txmpp::QName QN_MUG_OWNER_ABORTWHENPLAYERLEAVES_TAG(true, NS_MUG_OWNER, "abortWhenPlayerLeaves");

const txmpp::QName QN_NAME_ATTR(true, txmpp::XmlConstants::str_empty(), "name");
const txmpp::QName QN_VERSION_ATTR(true, txmpp::XmlConstants::str_empty(), "version");
const txmpp::QName QN_APPID_ATTR(true, txmpp::XmlConstants::str_empty(), "appId");
const txmpp::QName QN_GAMEID_ATTR(true, txmpp::XmlConstants::str_empty(), "gameId");
const txmpp::QName QN_ROLE_ATTR(true, txmpp::XmlConstants::str_empty(), "role");
const txmpp::QName QN_NICK_ATTR(true, txmpp::XmlConstants::str_empty(), "nick");
const txmpp::QName QN_AFFILIATION_ATTR(true, txmpp::XmlConstants::str_empty(), "affiliation");
const txmpp::QName QN_JID_ATTR(true, txmpp::XmlConstants::str_empty(), "jid");
const txmpp::QName QN_CODE_ATTR(true, txmpp::XmlConstants::str_empty(), "code");
const txmpp::QName QN_MATCHID_ATTR(true, txmpp::XmlConstants::str_empty(), "matchId");


const txmpp::QName QN_MUG_APP_TAG(true, NS_MUG, "app");
const txmpp::QName QN_MUG_ASSIGNMATCH_TAG(true, NS_MUG, "matchrequest");
const txmpp::QName QN_MUG_NEWMATCH_TAG(true, NS_MUG, "newmatch");
const txmpp::QName QN_MUG_FREEROLE_TAG(true, NS_MUG, "freerole");
const txmpp::QName QN_MUG_ROLE_TAG(true, NS_MUG, "role");
const txmpp::QName QN_MUG_NICKNAME_TAG(true, NS_MUG, "nickname");
const txmpp::QName QN_MUG_ITEM_TAG(true, NS_MUG, "item");
const txmpp::QName QN_MUG_GAMEPRESENCE_TAG(true, NS_MUG, "game");
const txmpp::QName QN_MUG_STATUS_TAG(true, NS_MUG, "status");
const txmpp::QName QN_MUG_INROOMID_TAG(true, NS_MUG, "inRoomId");

const txmpp::QName QN_MUG_MATCHDATA_TAG(true, NS_MUG, "matchdata");
const txmpp::QName QN_MUG_USERDATA_TAG(true, NS_MUG, "userdata");
const txmpp::QName QN_MUG_MATCH_TAG(true, NS_MUG, "match");
const txmpp::QName QN_MUG_OPAQUE_TAG(true, NS_MUG, "opaque");

const txmpp::QName QN_MUG_TURNBASED_STATE_TAG(true, NS_MUG_TURNBASED, "state");
const txmpp::QName QN_MUG_TURNBASED_FIRST_TAG(true, NS_MUG_TURNBASED, "first");
const txmpp::QName QN_MUG_TURNBASED_OPAQUE_TAG(true, NS_MUG_TURNBASED, "opaque");
const txmpp::QName QN_MUG_TURNBASED_ROLES_TAG(true, NS_MUG_TURNBASED, "roles");
const txmpp::QName QN_MUG_TURNBASED_ROLE_TAG(true, NS_MUG_TURNBASED, "role");
const txmpp::QName QN_MUG_TURNBASED_NEXT_TAG(true, NS_MUG_TURNBASED, "next");
const txmpp::QName QN_MUG_TURNBASED_LAST_TAG(true, NS_MUG_TURNBASED, "last");
const txmpp::QName QN_MUG_TURNBASED_TERMINATED_TAG(true, NS_MUG_TURNBASED, "terminated");


const txmpp::QName QN_MUG_USER_START_TAG(true, NS_MUG_USER, "start");
const txmpp::QName QN_MUG_USER_LEAVE_TAG(true, NS_MUG_USER, "leave");
const txmpp::QName QN_MUG_USER_TURN_TAG(true, NS_MUG_USER, "turn");
const txmpp::QName QN_MUG_USER_NEWSTATE_TAG(true, NS_MUG_USER, "newstate");
const txmpp::QName QN_MUG_USER_TERMINATE_TAG(true, NS_MUG_USER, "terminate");
const txmpp::QName QN_MUG_USER_NEXT_TAG(true, NS_MUG_USER, "next");
const txmpp::QName QN_MUG_USER_ONLY_UPDATE_TAG(true, NS_MUG_USER, "only-update");

const std::string NS_XDATA("jabber:x:data");
const txmpp::QName QN_XDATA_X(true, NS_XDATA, "x");
const txmpp::QName QN_XDATA_FIELD(true, NS_XDATA, "field");
const txmpp::QName QN_XDATA_VALUE(true, NS_XDATA, "value");
const txmpp::QName QN_XDATA_REQUIRED(true, NS_XDATA, "required");


}
