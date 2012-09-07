#ifndef _TXMPP_XMPPREGISTERTASK_H_
#define _TXMPP_XMPPREGISTERTASK_H_

#ifndef NO_CONFIG_H
#include "config.h"
#endif

#include <string>
#include <deque>
#include "sigslot.h"
#include "xmppengine.h"
#include "task.h"

namespace txmpp {

/////////////////////////////////////////////////////////////////////
//
// XMPPREGISTERTASK
//
/////////////////////////////////////////////////////////////////////
//
// See Task and XmppRegisterClient first.
//
// XmppRegisterTask is a task that is designed to go underneath XmppRegisterClient and be
// useful there.  It has a way of finding its XmppRegisterClient parent so you
// can have it nested arbitrarily deep under an XmppRegisterClient and it can
// still find the XMPP services.
//
// Tasks register themselves to listen to particular kinds of stanzas
// that are sent out by the client.  Rather than processing stanzas
// right away, they should decide if they own the sent stanza,
// and if so, queue it and Wake() the task, or if a stanza does not belong
// to you, return false right away so the next XmppTask can take a crack.
// This technique (synchronous recognize, but asynchronous processing)
// allows you to have arbitrary logic for recognizing stanzas yet still,
// for example, disconnect a client while processing a stanza -
// without reentrancy problems.
//
/////////////////////////////////////////////////////////////////////

class XmppRegisterClient;

class XmppRegisterTask :
  public Task,
  public XmppStanzaHandler,
  public has_slots<>
{
 public:
	  XmppRegisterTask(TaskParent* parent,
           XmppEngine::HandlerLevel level = XmppEngine::HL_NONE);
  virtual ~XmppRegisterTask();

  virtual XmppRegisterClient* GetClient() const { return client_; }
  std::string task_id() const { return id_; }
  void set_task_id(std::string id) { id_ = id; }

#ifdef _DEBUG
  void set_debug_force_timeout(const bool f) { debug_force_timeout_ = f; }
#endif

 protected:
  friend class XmppClient;

  XmppReturnStatus SendStanza(const XmlElement* stanza);
  XmppReturnStatus SetResult(const std::string& code);
  XmppReturnStatus SendStanzaError(const XmlElement* element_original,
                                   XmppStanzaError code,
                                   const std::string& text);

  virtual void Stop();
  virtual bool HandleStanza(const XmlElement* stanza) { return false; }
  virtual void OnDisconnect();
  virtual int ProcessReponse() { return STATE_DONE; }

  virtual void QueueStanza(const XmlElement* stanza);
  const XmlElement* NextStanza();

  bool MatchStanzaFrom(const XmlElement* stanza, const Jid& match_jid);

  bool MatchResponseIq(const XmlElement* stanza, const Jid& to,
                       const std::string& task_id);

  static bool MatchRequestIq(const XmlElement* stanza, const std::string& type,
                             const QName& qn);
  static XmlElement *MakeIqResult(const XmlElement* query);
  static XmlElement *MakeIq(const std::string& type,
                            const Jid& to, const std::string& task_id);

  // Returns true if the task is under the specified rate limit and updates the
  // rate limit accordingly
  bool VerifyTaskRateLimit(const std::string task_name, int max_count,
                           int per_x_seconds);

private:
  void StopImpl();

  XmppRegisterClient* client_;
  std::deque<XmlElement*> stanza_queue_;
  scoped_ptr<XmlElement> next_stanza_;
  std::string id_;

#ifdef _DEBUG
  bool debug_force_timeout_;
#endif
};

}  // namespace txmpp

#endif  // _TXMPP_XMPPREGISTERTASK_H_
