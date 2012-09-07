#include "xmppregisterclient.h"

#include "xmppregistertask.h"
#include "constants.h"
#include "sigslot.h"
#include "saslplainmechanism.h"
#include "prexmppauth.h"
#include "scoped_ptr.h"
#include "plainsaslhandler.h"

namespace txmpp {

TaskParent* XmppRegisterClient::GetParent(int code) {
  if (code == XMPP_REGISTER_CLIENT_TASK_CODE)
    return this;
  else
    return Task::GetParent(code);
}

class XmppRegisterClient::Private :
    public has_slots<>,
    public XmppSessionHandler,
    public XmppOutputHandler {
public:

  Private(XmppRegisterClient * client) :
    client_(client),
    socket_(NULL),
    engine_(NULL),
    proxy_port_(0),
    pre_engine_error_(XmppEngine::ERROR_NONE),
    pre_engine_subcode_(0),
    signal_closed_(false),
    allow_plain_(false) {}

  // the owner
  XmppRegisterClient * const client_;

  // the two main objects
  scoped_ptr<XmppAsyncSocket> socket_;
  scoped_ptr<XmppEngine> engine_;
  scoped_ptr<PreXmppAuth> pre_auth_;
  CryptString pass_;
  std::string auth_cookie_;
  SocketAddress server_;
  std::string proxy_host_;
  int proxy_port_;
  XmppEngine::Error pre_engine_error_;
  int pre_engine_subcode_;
  CaptchaChallenge captcha_challenge_;
  bool signal_closed_;
  bool allow_plain_;

  // implementations of interfaces
  void OnStateChange(int state);
  void WriteOutput(const char * bytes, size_t len);
  void StartTls(const std::string & domainname);
  void CloseConnection();

  // slots for socket signals
  void OnSocketConnected();
  void OnSocketRead();
  void OnSocketClosed();
};

XmppReturnStatus
XmppRegisterClient::Connect(const XmppClientSettings & settings, const std::string & lang, XmppAsyncSocket * socket) {
  if (socket == NULL)
    return XMPP_RETURN_BADARGUMENT;
  if (d_->socket_.get() != NULL)
    return XMPP_RETURN_BADSTATE;

  d_->socket_.reset(socket);

  d_->socket_->SignalConnected.connect(d_.get(), &Private::OnSocketConnected);
  d_->socket_->SignalRead.connect(d_.get(), &Private::OnSocketRead);
  d_->socket_->SignalClosed.connect(d_.get(), &Private::OnSocketClosed);

  d_->engine_.reset(new XmppEngineImplRegister());
  d_->engine_->SetSessionHandler(d_.get());
  d_->engine_->SetOutputHandler(d_.get());

  d_->engine_->SetUseTls(settings.use_tls());

  //
  // The talk.google.com server expects you to use "gmail.com" in the
  // stream, and expects the domain certificate to be "gmail.com" as well.
  // For all other servers, we leave the strings empty, which causes
  // the jid's domain to be used.  "foo@example.com" -> stream to="example.com"
  // tls certificate for "example.com"
  //
  // This is only true when using Gaia auth, so let's say if there's no preauth,
  // we should use the actual server name
  std::string server_name = settings.server().IPAsString();
  if ((server_name == STR_TALK_GOOGLE_COM ||
      server_name == STR_TALKX_L_GOOGLE_COM)) {
    d_->engine_->SetTlsServer(STR_GMAIL_COM, STR_GMAIL_COM);
  } else if (!settings.host().empty()) {
	  d_->engine_->SetTlsServer(settings.host(), settings.host());
  }

  // Set language
  d_->engine_->SetLanguage(lang);

  d_->server_ = settings.server();
  d_->proxy_host_ = settings.proxy_host();
  d_->proxy_port_ = settings.proxy_port();
  d_->allow_plain_ = settings.allow_plain();

  return XMPP_RETURN_OK;
}

XmppEngine::State
XmppRegisterClient::GetState() {
  if (d_->engine_.get() == NULL)
    return XmppEngine::STATE_NONE;
  return d_->engine_->GetState();
}

XmppEngine::Error
XmppRegisterClient::GetError(int *subcode) {
  if (subcode) {
    *subcode = 0;
  }
  if (d_->engine_.get() == NULL)
    return XmppEngine::ERROR_NONE;
  if (d_->pre_engine_error_ != XmppEngine::ERROR_NONE) {
    if (subcode) {
      *subcode = d_->pre_engine_subcode_;
    }
    return d_->pre_engine_error_;
  }
  return d_->engine_->GetError(subcode);
}

const XmlElement *
XmppRegisterClient::GetStreamError() {
  if (d_->engine_.get() == NULL) {
    return NULL;
  }
  return d_->engine_->GetStreamError();
}

int
XmppRegisterClient::ProcessStart() {
  return STATE_START_XMPP_CONNECT;
}

void
XmppRegisterClient::OnConnectDone() {
  Wake();
}

int
XmppRegisterClient::ProcessStartXmppConnect() {
  // Done with pre-connect tasks - connect!
  if (!d_->socket_->Connect(d_->server_)) {
    EnsureClosed();
    return STATE_ERROR;
  }

  return STATE_RESPONSE;
}

int
XmppRegisterClient::ProcessResponse() {
  // Hang around while we are connected.
  if (!delivering_signal_ && (d_->engine_.get() == NULL ||
    d_->engine_->GetState() == XmppEngine::STATE_CLOSED))
    return STATE_DONE;
  return STATE_BLOCKED;
}

XmppReturnStatus
XmppRegisterClient::Disconnect() {
  if (d_->socket_.get() == NULL)
    return XMPP_RETURN_BADSTATE;
  d_->engine_->Disconnect();
  d_->socket_.reset(NULL);
  return XMPP_RETURN_OK;
}

XmppRegisterClient::XmppRegisterClient(TaskParent * parent)
    : Task(parent),
      delivering_signal_(false),
      valid_(false) {
  d_.reset(new Private(this));
  valid_ = true;
}

XmppRegisterClient::~XmppRegisterClient() {
  valid_ = false;
}


const Jid &
XmppRegisterClient::jid() {
  return d_->engine_->FullJid();
}

std::string
XmppRegisterClient::NextId() {
  return d_->engine_->NextId();
}

XmppReturnStatus
XmppRegisterClient::SendStanza(const XmlElement * stanza) {
  return d_->engine_->SendStanza(stanza);
}

XmppReturnStatus
XmppRegisterClient::SendStanzaError(const XmlElement * old_stanza, XmppStanzaError xse, const std::string & message) {
  return d_->engine_->SendStanzaError(old_stanza, xse, message);
}

XmppReturnStatus
XmppRegisterClient::SendRaw(const std::string & text) {
  return d_->engine_->SendRaw(text);
}

XmppEngine*
XmppRegisterClient::engine() {
  return d_->engine_.get();
}

void
XmppRegisterClient::Private::OnSocketConnected() {
  engine_->Connect();
}

void
XmppRegisterClient::Private::OnSocketRead() {
  char bytes[4096];
  size_t bytes_read;
  for (;;) {
    if (!socket_->Read(bytes, sizeof(bytes), &bytes_read)) {
      // TODO: deal with error information
      return;
    }

    if (bytes_read == 0)
      return;

//#ifdef _DEBUG
    client_->SignalLogInput(bytes, bytes_read);
//#endif

    engine_->HandleInput(bytes, bytes_read);
  }
}

void
XmppRegisterClient::Private::OnSocketClosed() {
  int code = socket_->GetError();
  engine_->ConnectionClosed(code);
}

void
XmppRegisterClient::Private::OnStateChange(int state) {
  if (state == XmppEngine::STATE_CLOSED) {
    client_->EnsureClosed();
  }
  else {
    client_->SignalStateChange((XmppEngine::State)state);
  }
  client_->Wake();
}

void
XmppRegisterClient::Private::WriteOutput(const char * bytes, size_t len) {

//#ifdef _DEBUG
  client_->SignalLogOutput(bytes, len);
//#endif

  socket_->Write(bytes, len);
  // TODO: deal with error information
}

void
XmppRegisterClient::Private::StartTls(const std::string & domain) {
#if defined(FEATURE_ENABLE_SSL)
  socket_->StartTls(domain);
#endif
}

void
XmppRegisterClient::Private::CloseConnection() {
  socket_->Close();
}

void
XmppRegisterClient::AddXmppTask(XmppRegisterTask * task, XmppEngine::HandlerLevel level) {
  d_->engine_->AddStanzaHandler(task, level);
}

void
XmppRegisterClient::RemoveXmppTask(XmppRegisterTask * task) {
  d_->engine_->RemoveStanzaHandler(task);
}

void
XmppRegisterClient::EnsureClosed() {
  if (!d_->signal_closed_) {
    d_->signal_closed_ = true;
    delivering_signal_ = true;
    SignalStateChange(XmppEngine::STATE_CLOSED);
    delivering_signal_ = false;
  }
}

}  // namespace txmpp
