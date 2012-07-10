#include <constants.h>

#include "receivetask.h"

namespace libgameservice {

bool ReceiveTask::HandleStanza(const XmlElement* stanza) {
  if (WantsStanza(stanza)) {
    QueueStanza(stanza);
    return true;
  }

  return false;
}

int ReceiveTask::ProcessStart() {
  const XmlElement* stanza = NextStanza();
  if (stanza == NULL)
    return STATE_BLOCKED;

  ReceiveStanza(stanza);
  return STATE_START;
}

}  // namespace libgameservice
