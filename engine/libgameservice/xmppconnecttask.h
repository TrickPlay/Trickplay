/*
 * libjingle
 * Copyright 2004--2005, Google Inc.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _TXMPP_XMPPCONNECTTASLK_H_
#define _TXMPP_XMPPCONNECTTASLK_H_

#ifndef NO_CONFIG_H
#include "config.h"
#endif

#include <string>
#include <vector>
#include "jid.h"
#include "logging.h"
#include "scoped_ptr.h"
#include "xmppengineimpl_register.h"

namespace txmpp {

class XmlElement;
class XmppEngineImpl;
class SaslMechanism;

class XmppConnectTask {

public:
  XmppConnectTask(XmppEngineImplRegister *pctx);
  ~XmppConnectTask();

  bool IsDone()
    { return state_ == CONNECTSTATE_DONE; }
  void IncomingStanza(const XmlElement * element, bool isStart);
  void OutgoingStanza(const XmlElement *element);

private:
  enum ConnectTaskState {
    CONNECTSTATE_INIT = 0,
    CONNECTSTATE_STREAMSTART_SENT,
    CONNECTSTATE_STARTED_XMPP,
    CONNECTSTATE_TLS_INIT,
    CONNECTSTATE_TLS_REQUESTED,
    CONNECTSTATE_DONE,
  };

  const XmlElement * NextStanza();
  bool Advance();
  bool HandleStartStream(const XmlElement * element);
  bool HandleFeatures(const XmlElement * element);
  const XmlElement * GetFeature(const QName & name);
  bool Failure(XmppEngine::Error reason);
  void FlushQueuedStanzas();

  XmppEngineImplRegister * pctx_;
  ConnectTaskState state_;
  const XmlElement * pelStanza_;
  bool isStart_;
  std::string iqId_;
  scoped_ptr<XmlElement> pelFeatures_;
  std::string streamId_;
  scoped_ptr<std::vector<XmlElement *> > pvecQueuedStanzas_;


#ifdef _DEBUG
  static const ConstantLabel CONNECTTASK_STATES[];
#endif  // _DEBUG
};

}  // namespace txmpp

#endif  // _TXMPP_XMPPCONNECTTASLK_H_
