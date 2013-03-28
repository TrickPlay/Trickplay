#ifndef _TRICKPLAY_ACTIONS_H
#define _TRICKPLAY_ACTIONS_H

#include "common.h"
#include "sysdb.h"

class Actions // lawsuit
{
public:

    Actions( TPContext* context );

    bool launch_action(
            const char* caller,
            const char* app_id,
            const char* action_name,
            const char* uri,
            const char* type,
            const char* parameters,
            SystemDatabase::AppActionMap& matches );

private:

    bool match_pattern( const char* source, const String& pattern );

    TPContext*                   context;
};


#endif // _TRICKPLAY_ACTIONS_H
