#ifndef _TRICKPLAY_PLUGIN_H
#define _TRICKPLAY_PLUGIN_H

#include "gmodule.h"

#include "trickplay/plugins/plugins.h"

#include "common.h"


namespace TrickPlay
{

class Plugin
{
public:

    typedef std::list< Plugin* > List;

    static Plugin::List scan( TPContext* context , const String& prefix , const StringList& symbols );

    virtual ~Plugin();

    gpointer get_symbol( const String& name ) const;

    String name() const;

    String version() const;

    gpointer user_data() const;

private:

    typedef std::map< String , gpointer> GPointerMap;

    Plugin( GModule* module , const GPointerMap& symbols );

    Plugin()
    {}

    Plugin( const Plugin& other )
    {}

    static gpointer get_symbol( GModule* module , const char* name );

    GModule*            module;
    TPPluginShutdown    shutdown;
    TPPluginInfo        info;
    GPointerMap         symbols;

};

}

#endif // _TRICKPLAY_PLUGIN_H
