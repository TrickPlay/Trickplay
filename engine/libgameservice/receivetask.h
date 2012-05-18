#ifndef _XMPP_RECEIVETASK_H_
#define _XMPP_RECEIVETASK_H_

#include <xmpptask.h>
#include <taskparent.h>
#include <xmlelement.h>

using namespace txmpp;

namespace libgameservice {

// A base class for receiving stanzas.  Override WantsStanza to
// indicate that a stanza should be received and ReceiveStanza to
// process it.  Once started, ReceiveStanza will be called for all
// stanzas that return true when passed to WantsStanza. This saves
// you from having to remember how to setup the queueing and the task
// states, etc.
class ReceiveTask : public txmpp::XmppTask {
 public:
  explicit ReceiveTask(TaskParent* parent) :
      XmppTask(parent, XmppEngine::HL_TYPE) {}
  virtual int ProcessStart();

 protected:
  virtual bool HandleStanza(const XmlElement* stanza);

  // Return true if the stanza should be received.
  virtual bool WantsStanza(const XmlElement* stanza) = 0;
  // Process the received stanza.
  virtual void ReceiveStanza(const XmlElement* stanza) = 0;
};

}  // namespace libgameservice

#endif  // _XMPP_RECEIVETASK_H_
