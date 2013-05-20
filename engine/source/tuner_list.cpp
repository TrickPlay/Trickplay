#include "tuner_list.h"
#include "clutter_util.h"
#include "context.h"
#include "log.h"

//==============================================================================
// This is the structure we give the outside world. To them, it is opaque.
// It has a pointer to a Tuner instance, the associated TunerList
// and a marker, which points to itself. The marker lets us do sanity checks
// to ensure the outside doesn't pass garbage.

struct TPTuner
{
    TPTuner( Tuner* _tuner, TunerList* _list )
        :
        tuner( _tuner ),
        list( _list ),
        marker( this )
    {
        check( this );
    }

    inline static void check( TPTuner* tuner )
    {
        g_assert( tuner );
        g_assert( tuner->list );
        g_assert( tuner->tuner );

        // An assertion here means that either the controller is garbage or
        // it has already been disconnected.

        g_assert( tuner->marker == tuner );
    }

    Tuner*         tuner;
    TunerList*     list;
    TPTuner*       marker;
};

//.............................................................................

Tuner::Tuner( TunerList* _list, TPContext* _context , const char* _name, TPChannelChangeCallback _tune_channel_cb, TPTunerSetViewportGeometry _set_viewport_cb, void* _data )
    :
    tp_tuner( new TPTuner( this, _list ) ),
    name( _name ),
    tune_channel_cb( _tune_channel_cb ),
    set_viewport_cb(_set_viewport_cb),
    data( _data )
{
    // If the outside world did not provide a function to execute commands,
    // we set our own which always fails.

    if ( ! tune_channel_cb )
    {
        tune_channel_cb = default_tune_channel_cb;
    }

    if( !set_viewport_cb )
    {
        set_viewport_cb = default_set_viewport_cb;
    }
}

//.............................................................................

Tuner::~Tuner()
{
    delete tp_tuner;
}

//.............................................................................

int Tuner::default_tune_channel_cb( TPTuner* tuner, const char*, void* )
{
    // Failure
    return 1;
}
//.............................................................................

int Tuner::default_set_viewport_cb( TPTuner* tuner, int, int, int, int, void* )
{
    // Failure
    return 1;
}

//.............................................................................

TPTuner* Tuner::get_tp_tuner()
{
    return tp_tuner;
}

//.............................................................................

String Tuner::get_name() const
{
    return name;
}

//.............................................................................

int Tuner::tune_channel( const char* new_channel_uri )
{
    return tune_channel_cb( tp_tuner, new_channel_uri, data );
}

//.............................................................................

int Tuner::set_viewport( int left, int top, int width, int height )
{
    return set_viewport_cb( tp_tuner, left, top, width, height, data );
}

//.............................................................................

void Tuner::add_delegate( Delegate* delegate )
{
    delegates.insert( delegate );
}

//.............................................................................

void Tuner::remove_delegate( Delegate* delegate )
{
    delegates.erase( delegate );
}


//.............................................................................

void tp_tuner_channel_changed( TPTuner* tuner, const char* new_channel )
{
    g_debug( "SOMEONE TOLD US THE CHANNEL CHANGED ON %p TO %s", tuner, new_channel );
    return;
}


TPTuner* TunerList::add_tuner( TPContext* context , const char* name, TPChannelChangeCallback tune_channel_cb, TPTunerSetViewportGeometry set_viewport_cb, void* data )
{
    g_assert( name );
    g_assert( tune_channel_cb );
    g_assert( set_viewport_cb );

    Tuner* tuner = new Tuner( this , context , name , tune_channel_cb, set_viewport_cb, data );

    TPTuner* result = tuner->get_tp_tuner();

    tuners.insert( result );

    return result;
}

void TunerList::remove_tuner( TPTuner* tuner )
{
    TPTuner::check( tuner );

    tuners.erase( tuner );
    tuner->tuner->unref();
}

//-----------------------------------------------------------------------------

TunerList::TunerList()
{
}

//.............................................................................

TunerList::~TunerList()
{
    for ( TPTunerSet::iterator it = tuners.begin(); it != tuners.end(); ++it )
    {
        ( *it )->tuner->unref();
    }
}

//.............................................................................

void TunerList::add_delegate( Delegate* delegate )
{
    delegates.insert( delegate );
}

//.............................................................................

void TunerList::remove_delegate( Delegate* delegate )
{
    delegates.erase( delegate );
}



TunerList::TunerSet TunerList::get_tuners()
{
    TunerSet result;

    for ( TPTunerSet::iterator it = tuners.begin(); it != tuners.end(); ++it )
    {
        Tuner* tuner = ( *it )->tuner;

        result.insert( tuner );
    }

    return result;
}

