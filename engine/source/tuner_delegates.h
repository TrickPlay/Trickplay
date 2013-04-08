#ifndef _TRICKPLAY_TUNER_DELEGATES_H
#define _TRICKPLAY_TUNER_DELEGATES_H

#include "tuner_list.h"
#include "user_data.h"

class TunerListDelegate;

//=============================================================================

class TunerDelegate : public Tuner::Delegate
{
public:

    TunerDelegate( lua_State* _LS , Tuner* _tuner , TunerListDelegate* _list );

    ~TunerDelegate();

    inline Tuner* get_tuner()
    {
        return tuner;
    }

    //---------------------------------------------------
    // Delegate functions

    void channel_changed( const String& new_channel_uri );

private:

    lua_State*              L;
    Tuner*                  tuner;

};

//=============================================================================

class TunerListDelegate : public TunerList::Delegate
{
public:

    TunerListDelegate( lua_State* l );
    ~TunerListDelegate();

    void push_connected();

private:

    lua_State*      L;
    TunerList*      list;

    typedef std::map< TunerDelegate* , UserData::Handle* > ProxyMap;

    ProxyMap            proxies;
};

//=============================================================================

#endif // _TRICKPLAY_TUNER_DELEGATES_H
