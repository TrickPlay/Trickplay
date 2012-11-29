#include "status.h"

#include <jid.h>
#include <constants.h>

using namespace txmpp;

namespace libgameservice {

std::string Status::QuietStatus() const
{
   Jid jid_(jid_str_);
   if (jid_.resource().find("Psi") != std::string::npos) {
     if (status_ == "Online" ||
         status_.find("Auto Status") != std::string::npos)
       return STR_EMPTY;
   }
   if (jid_.resource().find("Gaim") != std::string::npos) {
     if (status_ == "Sorry, I ran out for a bit!")
       return STR_EMPTY;
   }
   return TrimStatus(status_);
}

}
