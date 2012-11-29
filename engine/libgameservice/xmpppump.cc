#include <iostream>

#include <logging.h>
#include <prexmppauthimpl.h>

#include "xmpppump.h"
#include "xmpptasks.h"

namespace libgameservice {

XmppPump::XmppPump(XmppPumpNotify * notify) {
  state_ = txmpp::XmppEngine::STATE_NONE;
  notify_ = notify;
  client_ = new txmpp::XmppClient(this);  // NOTE: deleted by TaskRunner
}

void XmppPump::DoLogin(const txmpp::XmppClientSettings & xcs,
                       txmpp::XmppAsyncSocket* socket,
                       txmpp::PreXmppAuth* auth) {
  OnStateChange(txmpp::XmppEngine::STATE_START);
  if (!AllChildrenDone()) {
    client_->SignalStateChange.connect(this, &XmppPump::OnStateChange);
    if (client_->Connect(xcs, "", socket, auth) != txmpp::XMPP_RETURN_OK) {
      LOG(LS_ERROR) << "Failed to connect.";
    }
    client_->Start();
  }
}

void XmppPump::DoDisconnect() {
  if (!AllChildrenDone())
    client_->Disconnect();
  OnStateChange(txmpp::XmppEngine::STATE_CLOSED);
}

void XmppPump::OnStateChange(txmpp::XmppEngine::State state) {
  if (state_ == state)
    return;
  std::cout << "PREVIOUS STATE: " << state_ << std::endl;
  std::cout << "NEW STATE: " << state << std::endl;
  switch(state) {
    case txmpp::XmppEngine::STATE_OPEN: {
      // task_message, task_precence and task_iq are deleted by client_
      //
      // This accepts <message/> stanzas and prints the sender and message
      // to stdout
  //    XmppTaskMessage *task_message = new XmppTaskMessage(client_);
    //  task_message->Start();
      // This accepts <presence/> stanzas and prints whom they're from
      // to stdout
      //XmppTaskPresence *task_presence = new XmppTaskPresence(client_);
     // task_presence->Start();
      // This sends a privacy list request on Start and handles only its
      // response
     // XmppTaskIq *task_iq = new XmppTaskIq(client_);
     // task_iq->Start();
    	std::cout << "Inside XmppPump::OnStateChange(STATE_OPEN)" << std::endl;
      }
      break;
    case txmpp::XmppEngine::STATE_START:
    case txmpp::XmppEngine::STATE_OPENING:
      break;
    case txmpp::XmppEngine::STATE_CLOSED:
      std::cout << "Error: " << client_->GetError(NULL) << std::endl;
      break;
    case txmpp::XmppEngine::STATE_NONE:
      std::cout << "Error: new state is STATE_NONE" << std::endl;
      break;
  }
  state_ = state;
  if (notify_ != NULL)
    notify_->OnStateChange(state);
}

void XmppPump::WakeTasks() {
  txmpp::Thread::Current()->Post(this);
}

int64 XmppPump::CurrentTime() {
  return (int64)txmpp::Time();
}

void XmppPump::OnMessage(txmpp::Message *pmsg) {
  RunTasks();
}

txmpp::XmppReturnStatus XmppPump::SendStanza(const txmpp::XmlElement *stanza) {
  if (!AllChildrenDone())
    return client_->SendStanza(stanza);
  return txmpp::XMPP_RETURN_BADSTATE;
}


XmppRegisterPump::XmppRegisterPump(XmppPumpNotify * notify) {
  state_ = txmpp::XmppEngine::STATE_NONE;
  notify_ = notify;
  client_ = new txmpp::XmppRegisterClient(this);  // NOTE: deleted by TaskRunner
}

void XmppRegisterPump::DoConnect(const txmpp::XmppClientSettings & xcs,
                       txmpp::XmppAsyncSocket* socket) {
  OnStateChange(txmpp::XmppEngine::STATE_START);
  if (!AllChildrenDone()) {
    client_->SignalStateChange.connect(this, &XmppRegisterPump::OnStateChange);
    if (client_->Connect(xcs, "", socket) != txmpp::XMPP_RETURN_OK) {
      LOG(LS_ERROR) << "XmppRegisterPump::DoConnect(). Failed to connect.";
    }
    client_->Start();
  }
}

void XmppRegisterPump::DoDisconnect() {
  if (!AllChildrenDone())
    client_->Disconnect();
  OnStateChange(txmpp::XmppEngine::STATE_CLOSED);
}

void XmppRegisterPump::OnStateChange(txmpp::XmppEngine::State state) {
  if (state_ == state)
    return;
  std::cout << "XmppRegisterPump::OnStateChange(). PREVIOUS STATE: " << state_ << std::endl;
  std::cout << "XmppRegisterPump::OnStateChange(). NEW STATE: " << state << std::endl;
  switch(state) {
    case txmpp::XmppEngine::STATE_OPEN: {
      // task_message, task_precence and task_iq are deleted by client_
      //
      // This accepts <message/> stanzas and prints the sender and message
      // to stdout
  //    XmppTaskMessage *task_message = new XmppTaskMessage(client_);
    //  task_message->Start();
      // This accepts <presence/> stanzas and prints whom they're from
      // to stdout
      //XmppTaskPresence *task_presence = new XmppTaskPresence(client_);
     // task_presence->Start();
      // This sends a privacy list request on Start and handles only its
      // response
     // XmppTaskIq *task_iq = new XmppTaskIq(client_);
     // task_iq->Start();
    	std::cout << "Inside XmppRegisterPump::OnStateChange(STATE_OPEN)" << std::endl;
      }
      break;
    case txmpp::XmppEngine::STATE_START:
    case txmpp::XmppEngine::STATE_OPENING:
      break;
    case txmpp::XmppEngine::STATE_CLOSED:
      std::cout << "XmppRegisterPump::OnStateChange(). Error: " << client_->GetError(NULL) << std::endl;
      break;
    case txmpp::XmppEngine::STATE_NONE:
      std::cout << "Error: new state is STATE_NONE" << std::endl;
      break;
  }
  state_ = state;
  if (notify_ != NULL)
    notify_->OnStateChange(state);
}

void XmppRegisterPump::WakeTasks() {
  txmpp::Thread::Current()->Post(this);
}

int64 XmppRegisterPump::CurrentTime() {
  return (int64)txmpp::Time();
}

void XmppRegisterPump::OnMessage(txmpp::Message *pmsg) {
  RunTasks();
}

txmpp::XmppReturnStatus XmppRegisterPump::SendStanza(const txmpp::XmlElement *stanza) {
  if (!AllChildrenDone())
    return client_->SendStanza(stanza);
  return txmpp::XMPP_RETURN_BADSTATE;
}


}  // namespace libgameservice
