
#include "tuner_delegates.h"

#include "context.h"
#include "bitmap.h"
#include "clutter_util.h"
#include "lb.h"

//=============================================================================

extern int new_Tuner( lua_State * );

//=============================================================================

TunerDelegate::TunerDelegate(lua_State * _LS,Tuner * _tuner,TunerListDelegate * _list)
:
    L(_LS),
    tuner(_tuner)
{
    tuner->ref();
    tuner->add_delegate(this);
}

//.........................................................................

TunerDelegate::~TunerDelegate()
{
    tuner->remove_delegate(this);
    tuner->unref();
}

//.........................................................................
// Delegate functions

void TunerDelegate::channel_changed(const String & new_channel_uri)
{
    lua_pushstring(L, new_channel_uri.c_str());
    lb_invoke_callbacks(L,this,"TUNER_METATABLE","on_channel_changed",1,0);
}

//.........................................................................

//=============================================================================

TunerListDelegate::TunerListDelegate(lua_State * l)
:
    L(l)
{
    list=App::get(L)->get_context()->get_tuner_list();
    list->add_delegate(this);
}

//.........................................................................

TunerListDelegate::~TunerListDelegate()
{
    list->remove_delegate(this);

    for ( ProxyMap::iterator it = proxies.begin(); it != proxies.end(); ++it )
    {
    	UserData::Handle::destroy( it->second );
    }
}


void TunerListDelegate::push_connected()
{
    lua_newtable(L);

    // These exist as Lua objects, so we should be able to find instances
    // for all of them. However, the proxies may not be connected

    int i=1;

    TunerList::TunerSet found;

    for(ProxyMap::iterator it=proxies.begin();it!=proxies.end();++it)
    {
        if (! it->first->get_tuner() )
            continue;

        UserData * ud = it->second->get_user_data();
        g_assert( ud );
        ud->push_proxy();

        lua_rawseti(L,-2,i++);

        found.insert(it->first->get_tuner());
    }

    // These may not exist as Lua objects but they are definitely connected

    // This should not happen any more - since we hold on to the Lua objects as
    // soon as they connect.

    TunerList::TunerSet tuners(list->get_tuners());

    for(TunerList::TunerSet::iterator it=tuners.begin();it!=tuners.end();++it)
    {
        if (found.find(*it)!=found.end())
        {
            continue;
        }

        TunerDelegate * d = new TunerDelegate(L,*it,this);

        lua_pushlightuserdata(L,d);

        new_Tuner(L);

        lua_remove(L,-2);

        proxies[ d ] = UserData::Handle::make( L , -1 );

        lua_rawseti(L,-2,i++);
    }
}
