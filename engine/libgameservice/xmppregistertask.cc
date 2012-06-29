#include "xmppregistertask.h"

#include "xmppregisterclient.h"
#include "xmppengine.h"
#include "constants.h"
#include "ratelimitmanager.h"

namespace txmpp {

RateLimitManager task_rate_manager;

XmppRegisterTask::XmppRegisterTask(TaskParent* parent, XmppEngine::HandlerLevel level)
    : Task(parent), client_(NULL) {
#ifdef _DEBUG
  debug_force_timeout_ = false;
#endif

  XmppRegisterClient* client =
      static_cast<XmppRegisterClient*>(parent->GetParent(XMPP_REGISTER_CLIENT_TASK_CODE));
  client_ = client;
  id_ = client->NextId();
  client->AddXmppTask(this, level);
  client->SignalDisconnected.connect(this, &XmppRegisterTask::OnDisconnect);
}

XmppRegisterTask::~XmppRegisterTask() {
  StopImpl();
}

void XmppRegisterTask::StopImpl() {
  while (NextStanza() != NULL) {}
  if (client_) {
    client_->RemoveXmppTask(this);
    client_->SignalDisconnected.disconnect(this);
    client_ = NULL;
  }
}

XmppReturnStatus XmppRegisterTask::SendStanza(const XmlElement* stanza) {
  if (client_ == NULL)
    return XMPP_RETURN_BADSTATE;
  return client_->SendStanza(stanza);
}

XmppReturnStatus XmppRegisterTask::SendStanzaError(const XmlElement* element_original,
                                           XmppStanzaError code,
                                           const std::string& text) {
  if (client_ == NULL)
    return XMPP_RETURN_BADSTATE;
  return client_->SendStanzaError(element_original, code, text);
}

void XmppRegisterTask::Stop() {
  StopImpl();
  Task::Stop();
}

void XmppRegisterTask::OnDisconnect() {
  Error();
}

void XmppRegisterTask::QueueStanza(const XmlElement* stanza) {
#ifdef _DEBUG
  if (debug_force_timeout_)
    return;
#endif

  stanza_queue_.push_back(new XmlElement(*stanza));
  Wake();
}

const XmlElement* XmppRegisterTask::NextStanza() {
  XmlElement* result = NULL;
  if (!stanza_queue_.empty()) {
    result = stanza_queue_.front();
    stanza_queue_.pop_front();
  }
  next_stanza_.reset(result);
  return result;
}

XmlElement* XmppRegisterTask::MakeIq(const std::string& type,
                             const txmpp::Jid& to,
                             const std::string& id) {
  XmlElement* result = new XmlElement(QN_IQ);
  if (!type.empty())
    result->AddAttr(QN_TYPE, type);
  if (to != JID_EMPTY)
    result->AddAttr(QN_TO, to.Str());
  if (!id.empty())
    result->AddAttr(QN_ID, id);
  return result;
}

XmlElement* XmppRegisterTask::MakeIqResult(const XmlElement * query) {
  XmlElement* result = new XmlElement(QN_IQ);
  result->AddAttr(QN_TYPE, STR_RESULT);
  if (query->HasAttr(QN_FROM)) {
    result->AddAttr(QN_TO, query->Attr(QN_FROM));
  }
  result->AddAttr(QN_ID, query->Attr(QN_ID));
  return result;
}

bool XmppRegisterTask::MatchResponseIq(const XmlElement* stanza,
                               const Jid& to,
                               const std::string& id) {
  if (stanza->Name() != QN_IQ)
    return false;

  if (stanza->Attr(QN_ID) != id)
    return false;

  return MatchStanzaFrom(stanza, to);
}


bool XmppRegisterTask::MatchStanzaFrom(const XmlElement* stanza,
                               const Jid& to) {
  Jid from(stanza->Attr(QN_FROM));
  if (from == to)
    return true;

  // We address the server as "", check if we are doing so here.
  if (to != JID_EMPTY)
    return false;

  // It is legal for the server to identify itself with "domain" or
  // "myself@domain"
  Jid me = client_->jid();
  return (from == Jid(me.domain())) || (from == me.BareJid());
}

bool XmppRegisterTask::MatchRequestIq(const XmlElement* stanza,
                              const std::string& type,
                              const QName& qn) {
  if (stanza->Name() != QN_IQ)
    return false;

  if (stanza->Attr(QN_TYPE) != type)
    return false;

  if (stanza->FirstNamed(qn) == NULL)
    return false;

  return true;
}

bool XmppRegisterTask::VerifyTaskRateLimit(const std::string task_name, int max_count,
                                   int per_x_seconds) {
  return task_rate_manager.VerifyRateLimit(task_name, max_count, 
                                           per_x_seconds);
}

}  // namespace txmpp
