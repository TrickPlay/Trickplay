#ifndef _PRESENCEPUSHTASK_H_
#define _PRESENCEPUSHTASK_H_

#include <xmppengine.h>
#include <xmpptask.h>
#include <sigslot.h>

#include "status.h"

using namespace txmpp;

namespace libgameservice {

class PresencePushTask : public XmppTask {

public:
  PresencePushTask(Task * parent) : XmppTask(parent, XmppEngine::HL_TYPE) {}
  virtual int ProcessStart();
  txmpp::signal1<const GameStatus &>SignalStatusUpdate;
  txmpp::signal1<const XmlElement &> SignalStatusError;

protected:
  virtual bool HandleStanza(const XmlElement * stanza);
};


}

#endif
