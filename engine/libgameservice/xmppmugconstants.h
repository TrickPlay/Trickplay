#ifndef _XMPPMUGCONSTANTS_H_
#define _XMPPMUGCONSTANTS_H_

#include <string>

#include <qname.h>

namespace libgameservice {

extern const std::string NS_MUG;
extern const std::string NS_MUG_USER;
extern const std::string NS_MUG_OWNER;
extern const std::string NS_MUG_TURNBASED;

extern const txmpp::QName QN_MUG_QUERY;
extern const txmpp::QName QN_MUG_GAME;

extern const txmpp::QName QN_MUG_OWNER_REGISTER_APP;
extern const txmpp::QName QN_MUG_OWNER_REGISTER_GAME;

extern const txmpp::QName QN_MUG_OWNER_APP_TAG;
extern const txmpp::QName QN_MUG_OWNER_NAME_TAG;
extern const txmpp::QName QN_MUG_OWNER_VERSION_TAG;

extern const txmpp::QName QN_NAME_ATTR;
extern const txmpp::QName QN_VERSION_ATTR;
extern const txmpp::QName QN_APPID_ATTR;
extern const txmpp::QName QN_GAMEID_ATTR;
extern const txmpp::QName QN_ROLE_ATTR;
extern const txmpp::QName QN_NICK_ATTR;
extern const txmpp::QName QN_AFFILIATION_ATTR;
extern const txmpp::QName QN_JID_ATTR;
extern const txmpp::QName QN_CODE_ATTR;

extern const txmpp::QName QN_MUG_OWNER_DESCRIPTION_TAG;
extern const txmpp::QName QN_MUG_OWNER_CATEGORY_TAG;
extern const txmpp::QName QN_MUG_OWNER_GAMETYPE_TAG;
extern const txmpp::QName QN_MUG_OWNER_TURNPOLICY_TAG;
extern const txmpp::QName QN_MUG_OWNER_ROLES_TAG;
extern const txmpp::QName QN_MUG_OWNER_ROLE_TAG;
extern const txmpp::QName QN_MUG_OWNER_CANNOTSTART_TAG;
extern const txmpp::QName QN_MUG_OWNER_FIRSTROLE_TAG;
extern const txmpp::QName QN_MUG_OWNER_JOINAFTERSTART_TAG;
extern const txmpp::QName QN_MUG_OWNER_MINPLAYERSFORSTART_TAG;
extern const txmpp::QName QN_MUG_OWNER_MAXDURATIONPERTURN_TAG;
extern const txmpp::QName QN_MUG_OWNER_ABORTWHENPLAYERLEAVES_TAG;

extern const txmpp::QName QN_MUG_APP_TAG;
extern const txmpp::QName QN_MUG_ASSIGNMATCH_TAG;
extern const txmpp::QName QN_MUG_NEWMATCH_TAG;
extern const txmpp::QName QN_MUG_FREEROLE_TAG;
extern const txmpp::QName QN_MUG_ROLE_TAG;
extern const txmpp::QName QN_MUG_NICK_TAG;
extern const txmpp::QName QN_MUG_ITEM_TAG;
extern const txmpp::QName QN_MUG_JOINMATCH_TAG;
extern const txmpp::QName QN_MUG_STATUS_TAG;
extern const txmpp::QName QN_MUG_GAMEPRESENCE_TAG;

extern const txmpp::QName QN_MUG_TURNBASED_STATE_TAG;
extern const txmpp::QName QN_MUG_TURNBASED_FIRST_TAG;
extern const txmpp::QName QN_MUG_TURNBASED_OPAQUE_TAG;
extern const txmpp::QName QN_MUG_TURNBASED_ROLES_TAG;
extern const txmpp::QName QN_MUG_TURNBASED_ROLE_TAG;
extern const txmpp::QName QN_MUG_TURNBASED_NEXT_TAG;
extern const txmpp::QName QN_MUG_TURNBASED_LAST_TAG;
extern const txmpp::QName QN_MUG_TURNBASED_TERMINATED_TAG;


extern const txmpp::QName QN_MUG_USER_START_TAG;
extern const txmpp::QName QN_MUG_USER_LEAVE_TAG;
extern const txmpp::QName QN_MUG_USER_TURN_TAG;
extern const txmpp::QName QN_MUG_USER_NEWSTATE_TAG;
extern const txmpp::QName QN_MUG_USER_TERMINATE_TAG;
extern const txmpp::QName QN_MUG_USER_NEXT_TAG;

}

#endif /* _XMPPMUGCONSTANTS_H_ */
