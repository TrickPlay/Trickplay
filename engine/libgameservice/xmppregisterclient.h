#ifndef _TXMPP_XMPPREGISTERCLIENT_H_
#define _TXMPP_XMPPREGISTERCLIENT_H_

#ifndef NO_CONFIG_H
#include "config.h"
#endif

#include <string>
#include "basicdefs.h"
#include "sigslot.h"
#include "xmppengineimpl_register.h"
#include "xmppasyncsocket.h"
#include "xmppclientsettings.h"
#include "task.h"

namespace txmpp {

class XmppRegisterTask;

// Just some non-colliding number.  Could have picked "1".
#define XMPP_REGISTER_CLIENT_TASK_CODE 0x366c1e48

/////////////////////////////////////////////////////////////////////
//
// XMPPREGISTERCLIENT
//
/////////////////////////////////////////////////////////////////////
//
// See Task first.  XmppRegisterClient is a parent task for XmppTasks.
//
// XmppClient is a task which is designed to be the parent task for
// all tasks that depend on a single Xmpp connection.  If you want to,
// for example, listen for subscription requests forever, then your
// listener should be a task that is a child of the XmppClient that owns
// the connection you are using.  XmppClient has all the utility methods
// that basically drill through to XmppEngine.
//
// XmppClient is just a wrapper for XmppEngine, and if I were writing it
// all over again, I would make XmppClient == XmppEngine.  Why?
// XmppEngine needs tasks too, for example it has an XmppLoginTask which
// should just be the same kind of Task instead of an XmppEngine specific
// thing.  It would help do certain things like GAIA auth cleaner.
//
/////////////////////////////////////////////////////////////////////

class XmppRegisterClient : public Task, public has_slots<>
{
public:
  explicit XmppRegisterClient(TaskParent * parent);
  ~XmppRegisterClient();

  XmppReturnStatus Connect(const XmppClientSettings & settings,
                           const std::string & lang,
                           XmppAsyncSocket * socket);

  virtual TaskParent* GetParent(int code);
  virtual int ProcessStart();
  virtual int ProcessResponse();
  XmppReturnStatus Disconnect();

  signal1<XmppEngine::State> SignalStateChange;
  XmppEngine::State GetState();
  XmppEngine::Error GetError(int *subcode);

  // When there is a <stream:error> stanza, return the stanza
  // so that they can be handled.
  const XmlElement *GetStreamError();



  signal2<const char *, int> SignalLogInput;
  signal2<const char *, int> SignalLogOutput;

  XmppReturnStatus SendStanza(const XmlElement *stanza);
private:
  friend class XmppRegisterTask;

  std::string NextId();
  XmppReturnStatus SendRaw(const std::string & text);
  XmppReturnStatus SendStanzaError(const XmlElement * pelOriginal,
                       XmppStanzaError code,
                       const std::string & text);

  XmppEngine* engine();

  const Jid& jid();

  void OnConnectDone();

  // managed tasks and dispatching
  void AddXmppTask(XmppRegisterTask *, XmppEngine::HandlerLevel);
  void RemoveXmppTask(XmppRegisterTask *);

  signal0<> SignalDisconnected;

  // Internal state management
  enum {
    STATE_START_XMPP_CONNECT = STATE_NEXT,
  };
  int Process(int state) {
    switch (state) {
      case STATE_START_XMPP_CONNECT: return ProcessStartXmppConnect();
      default: return Task::Process(state);
    }
  }

  std::string GetStateName(int state) const {
    switch (state) {
      case STATE_START_XMPP_CONNECT:  return "START_XMPP_CONNECT";
      default: return Task::GetStateName(state);
    }
  }

  int ProcessStartXmppConnect();
  void EnsureClosed();

  class Private;
  friend class Private;
  scoped_ptr<Private> d_;

  bool delivering_signal_;
  bool valid_;
};

}  // namespace txmpp

#endif  // _TXMPP_XMPPREGISTERCLIENT_H_
