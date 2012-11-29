#ifndef _libgameservice_register_account_task_h_
#define _libgameservice_register_account_task_h_

#include <taskparent.h>
#include <qname.h>
#include <sigslot.h>

#include "xmppregistertask.h"
#include "libgameservice.h"
#include "accountinfo.h"

namespace libgameservice {

class RegisterAccountTask : public txmpp::XmppRegisterTask {
public:
	RegisterAccountTask(txmpp::TaskParent *parent, const  AccountInfo & account);
	virtual ~RegisterAccountTask();
	virtual int ProcessStart();
	virtual int ProcessResponse();
	bool HandleStanza(const txmpp::XmlElement *stanza);

	txmpp::signal1<const ResponseStatus&> SignalDone;
private:
	AccountInfo account_info_;
};

}

#endif //_libgameservice_register_account_task_h_

