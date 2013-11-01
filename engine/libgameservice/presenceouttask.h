#ifndef _PRESENCEOUTTASK_H_
#define _PRESENCEOUTTASK_H_

#include <xmppengine.h>
#include <xmpptask.h>

#include "status.h"

using namespace txmpp;

namespace libgameservice {

class PresenceOutTask : public txmpp::XmppTask {
public:
  explicit PresenceOutTask(txmpp::TaskParent* parent)
      : XmppTask(parent) {}
  virtual ~PresenceOutTask() {}

  XmppReturnStatus Send(const GameStatus & s);
  XmppReturnStatus SendDirected(const Jid & j, const GameStatus & s);
  XmppReturnStatus SendProbe(const Jid& jid);

  virtual int ProcessStart();
private:
  XmlElement * TranslateStatus(const GameStatus & s);
};

}

#endif
