#ifndef _TRICKPLAY_TUNER_LIST_H
#define _TRICKPLAY_TUNER_LIST_H

#include "trickplay/tuner.h"
#include "common.h"
#include "util.h"

//-----------------------------------------------------------------------------

class TunerList;

//-----------------------------------------------------------------------------

class Tuner : public RefCounted
{
public:

    Tuner( TunerList* list, TPContext* context , const char* name, TPChannelChangeCallback cb, void* data );

    TPTuner* get_tp_tuner();

    String get_name() const;

    int tune_channel( const char* new_channel_uri );

    static int default_tune_channel( TPTuner* controller, const char*, void* );

    class Delegate
    {
    public:
        virtual ~Delegate() {}
    };

    void add_delegate( Delegate* delegate );

    void remove_delegate( Delegate* delegate );

protected:

    virtual ~Tuner();


private:
    TPTuner*       tp_tuner;

    String              name;

    TPChannelChangeCallback  cb;
    void*               data;

    //.........................................................................

    typedef std::set<Delegate*> DelegateSet;

    DelegateSet     delegates;
};


class TunerList
{
public:

    TunerList();

    virtual ~TunerList();

    TPTuner* add_tuner( TPContext* context , const char* name, TPChannelChangeCallback cb, void* data );

    void remove_tuner( TPTuner* tuner );

    class Delegate
    {
    public:
        virtual ~Delegate() {}
    };

    void add_delegate( Delegate* delegate );

    void remove_delegate( Delegate* delegate );

    typedef std::set<Tuner*> TunerSet;

    TunerSet get_tuners();

private:

    friend void tp_tuner_channel_changed( TPTuner* tuner, const char* new_channel );

    typedef std::set<TPTuner*> TPTunerSet;

    TPTunerSet tuners;

    typedef std::set<Delegate*> DelegateSet;

    DelegateSet         delegates;

};

#endif // _TRICKPLAY_CONTROLLER_LIST_H
