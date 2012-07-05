
#include "xmppconnecttask.h"

#include <iostream>
#include "base64.h"
#include "common.h"
#include "xmlelement.h"
#include "constants.h"
#include "jid.h"
#include "saslmechanism.h"

namespace txmpp {

#ifdef _DEBUG
const ConstantLabel XmppLoginTask::CONNECTTASK_STATES[] = {
  KLABEL(CONNECTSTATE_INIT),
  KLABEL(CONNECTSTATE_STREAMSTART_SENT),
  KLABEL(CONNECTSTATE_STARTED_XMPP),
  KLABEL(CONNECTSTATE_TLS_INIT),
  KLABEL(CONNECTSTATE_AUTH_INIT),
  KLABEL(CONNECTSTATE_BIND_INIT),
  KLABEL(CONNECTSTATE_TLS_REQUESTED),
  KLABEL(CONNECTSTATE_SASL_RUNNING),
  KLABEL(CONNECTSTATE_BIND_REQUESTED),
  KLABEL(CONNECTSTATE_SESSION_REQUESTED),
  KLABEL(CONNECTSTATE_DONE),
  LASTLABEL
};
#endif  // _DEBUG

XmppConnectTask::XmppConnectTask(XmppEngineImplRegister * pctx) :
  pctx_(pctx),
  state_(CONNECTSTATE_INIT),
  pelStanza_(NULL),
  isStart_(false),
  iqId_(STR_EMPTY),
  pelFeatures_(NULL),
  streamId_(STR_EMPTY),
  pvecQueuedStanzas_(new std::vector<XmlElement *>()) {
}

XmppConnectTask::~XmppConnectTask() {
  for (size_t i = 0; i < pvecQueuedStanzas_->size(); i += 1)
    delete (*pvecQueuedStanzas_)[i];
}

void
XmppConnectTask::IncomingStanza(const XmlElement *element, bool isStart) {
  pelStanza_ = element;
  isStart_ = isStart;
  Advance();
  pelStanza_ = NULL;
  isStart_ = false;
}

const XmlElement *
XmppConnectTask::NextStanza() {
  const XmlElement * result = pelStanza_;
  pelStanza_ = NULL;
  return result;
}

bool
XmppConnectTask::Advance() {

  for (;;) {

    const XmlElement * element = NULL;

#if _DEBUG
    LOG(LS_VERBOSE) << "XmppConnectTask::Advance - "
      << ErrorName(state_, CONNECTTASK_STATES);
#endif  // _DEBUG

    switch (state_) {

      case CONNECTSTATE_INIT: {
        pctx_->RaiseReset();
        pelFeatures_.reset(NULL);


        pctx_->InternalSendStart();
        state_ = CONNECTSTATE_STREAMSTART_SENT;
        break;
      }

      case CONNECTSTATE_STREAMSTART_SENT: {
        if (NULL == (element = NextStanza()))
          return true;

        if (!isStart_ || !HandleStartStream(element))
          return Failure(XmppEngine::ERROR_VERSION);

        state_ = CONNECTSTATE_STARTED_XMPP;
        return true;
      }

      case CONNECTSTATE_STARTED_XMPP: {
        if (NULL == (element = NextStanza()))
          return true;

        if (!HandleFeatures(element))
          return Failure(XmppEngine::ERROR_VERSION);

        // Use TLS if forced, or if available
        if (pctx_->tls_needed_ || GetFeature(QN_TLS_STARTTLS) != NULL) {
          state_ = CONNECTSTATE_TLS_INIT;
          continue;
        }

        pctx_->SignalConnected(Jid(element->Attr(QN_FROM)));
        FlushQueuedStanzas();
        state_ = CONNECTSTATE_DONE;
        return true;
      }

      case CONNECTSTATE_TLS_INIT: {
        const XmlElement * pelTls = GetFeature(QN_TLS_STARTTLS);
        if (!pelTls)
          return Failure(XmppEngine::ERROR_TLS);

        XmlElement el(QN_TLS_STARTTLS, true);
        pctx_->InternalSendStanza(&el);
        state_ = CONNECTSTATE_TLS_REQUESTED;
        continue;
      }

      case CONNECTSTATE_TLS_REQUESTED: {
        if (NULL == (element = NextStanza()))
          return true;
        if (element->Name() != QN_TLS_PROCEED)
          return Failure(XmppEngine::ERROR_TLS);

        // The proper domain to verify against is the real underlying
        // domain - i.e., the domain that owns the JID.  Our XmppEngineImpl
        // also allows matching against a proxy domain instead, if it is told
        // to do so - see the implementation of XmppEngineImpl::StartTls and
        // XmppEngine::SetTlsServerDomain to see how you can use that feature
        pctx_->StartTls();
        pctx_->tls_needed_ = false;
        state_ = CONNECTSTATE_INIT;
        continue;
      }


      case CONNECTSTATE_DONE:
        return false;
    }
  }
}

bool
XmppConnectTask::HandleStartStream(const XmlElement *element) {

  if (element->Name() != QN_STREAM_STREAM)
    return false;

  if (element->Attr(QN_XMLNS) != "jabber:client")
    return false;

  if (element->Attr(QN_VERSION) != "1.0")
    return false;

  if (!element->HasAttr(QN_ID))
    return false;

  streamId_ = element->Attr(QN_ID);

  return true;
}

bool
XmppConnectTask::HandleFeatures(const XmlElement *element) {
  if (element->Name() != QN_STREAM_FEATURES)
    return false;

  pelFeatures_.reset(new XmlElement(*element));
  return true;
}

const XmlElement *
XmppConnectTask::GetFeature(const QName & name) {
  return pelFeatures_->FirstNamed(name);
}

bool
XmppConnectTask::Failure(XmppEngine::Error reason) {
  state_ = CONNECTSTATE_DONE;
  pctx_->SignalError(reason, 0);
  return false;
}

void
XmppConnectTask::OutgoingStanza(const XmlElement * element) {
  XmlElement * pelCopy = new XmlElement(*element);
  pvecQueuedStanzas_->push_back(pelCopy);
}

void
XmppConnectTask::FlushQueuedStanzas() {
  for (size_t i = 0; i < pvecQueuedStanzas_->size(); i += 1) {
    pctx_->InternalSendStanza((*pvecQueuedStanzas_)[i]);
    delete (*pvecQueuedStanzas_)[i];
  }
  pvecQueuedStanzas_->clear();
}

}  // namespace txmpp
