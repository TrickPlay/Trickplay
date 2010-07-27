#include "lb2.h"
#include "profiler.h"
//*****************************************************************************

#include "app.h"

#include "glib.h"
#include "glib-object.h"

/*
 You can create a timer in two ways:

 Timer( interval , callback )
 Timer{ interval = interval , callback = callback }

 If the callback is provided during the constructor, the
 timer will start ticking immediately, otherwise, you
 have to set the callback later and call "start".

 If you change the interval to <= 0, remove the callback, call stop
 or return false from the callback, the timer will stop ticking.
 */

class timer
{
public:

    timer( );
    ~timer();
    static gboolean timer_fired( gpointer data );
    void start( UserData * ud );
    void stop();
    void set_interval( UserData * ud , lua_Number new_interval );
    lua_Number get_interval() const;
    void cancel();

private:

    GSource * source;
    lua_Number interval;
};

static const char * TIMER_METATABLE = "TIMER_METATABLE";

#if 0
int wrap_Timer( lua_State*L, timer* self )
{
    int result = lb_wrap( L, self, TIMER_METATABLE );
    if ( result )
        PROFILER_CREATED("Timer",self);
    return result;
}
#endif


int new_Timer( lua_State*L )
{
    PROFILER(__FUNCTION__);
    UserData * __ud__ = UserData::make( L );
    luaL_getmetatable(L,TIMER_METATABLE);
    lua_setmetatable( L, -2 );

    lua_Number interval( lb_optnumber(L,1,0) );
    int on_timer( lb_optfunction(L,2,0) );
    //*****************************************************************************

    timer * self = lb_construct( timer , new timer );

    if ( lua_gettop( L ) == 2 && lua_istable(L,-2) )
    {
        lua_pushvalue( L, -2 );
        lb_set_props_from_table( L );
        lua_pop(L,1);
    }
    else
    {
        if ( interval > 0 )
        {
            self->set_interval( __ud__ , interval );
        }

        if ( on_timer )
        {
            lua_pushvalue( L, on_timer );
            lb_set_callback( L, self, "on_timer" );
            lua_pop(L,1);
        }
    }

    if ( lb_callback_attached( L, self, "on_timer", -1 ) )
    {
        self->start( __ud__ );
    }

//    lb_store_weak_ref( L, lua_gettop( L ), *self );

    lb_check_initialized();

    PROFILER_CREATED("Timer",self);

    return 1;
}

int delete_Timer( lua_State*L )
{
    PROFILER(__FUNCTION__);
    timer* self( lb_get_self(L,timer*) );
    PROFILER_DESTROYED("Timer",self);
    //*****************************************************************************

    delete self;

    lb_finalize_user_data( L );

    return 0;
}



int Timer_start( lua_State*L )
{
    PROFILER(__FUNCTION__);
    luaL_checktype( L, 1, LUA_TUSERDATA);
    timer* self( lb_get_self(L,timer*) );
    //*****************************************************************************

    if ( lb_callback_attached( L, self, "on_timer", 1 ) )
        self->start( UserData::get( L ) );
    return 0;
}

int Timer_stop( lua_State*L )
{
    PROFILER(__FUNCTION__);
    luaL_checktype( L, 1, LUA_TUSERDATA);
    timer* self( lb_get_self(L,timer*) );
    //*****************************************************************************
    self->stop();
    return 0;
}


int get_Timer_interval( lua_State*L )
{
    PROFILER(__FUNCTION__);
    timer* self( lb_get_self(L,timer*) );
    lua_Number interval;
    //*****************************************************************************
    interval = self->get_interval();
    lua_pushnumber( L, interval );
    return 1;
}

int set_Timer_interval( lua_State*L )
{
    PROFILER(__FUNCTION__);
    timer* self( lb_get_self(L,timer*) );
    lua_Number interval( luaL_checknumber( L, 2 ) );
    //*****************************************************************************
    self->set_interval( UserData::get( L ) , interval );
    return 0;
}

int get_Timer_on_timer( lua_State*L )
{
    return lb_get_callback( L, lb_get_self(L,timer*), "on_timer", 0 );
}

int set_Timer_on_timer( lua_State*L )
{
    timer* self( lb_get_self(L,timer*) );
    int on_timer( !lb_set_callback( L, self, "on_timer" ) );
    //*****************************************************************************

    if ( !on_timer )
        self->stop();
    return 0;
}

int invoke_Timer_on_timer( lua_State*L, timer* self, int nargs, int nresults )
{
    return lb_invoke_callback( L, self, TIMER_METATABLE, "on_timer", nargs,
            nresults );
}

void detach_Timer( lua_State*L, timer* self )
{
}

int timer_sref( lua_State * L )
{
//    g_object_ref( UserData::get( L )->master );

    return 0;
}

int timer_sunref( lua_State * L )
{
//    g_object_unref( UserData::get( L )->master );

    return 0;
}

int timer_dc( lua_State * L )
{
    UserData::dump_cb( L , 1 );

    return 0;
}

void luaopen_Timer( lua_State*L )
{
    luaL_newmetatable( L, TIMER_METATABLE );
    lua_pushstring( L, "type" );
    lua_pushstring( L, "Timer" );
    lua_rawset( L, -3 );
    const luaL_Reg meta_methods[] =
    {
    { "__gc", delete_Timer },
    { "__newindex", lb_newindex },
    { "__index", lb_index },
    { "start", Timer_start },
    { "stop", Timer_stop },
    { "sref" , timer_sref },
    { "sunref" , timer_sunref },
    { "dc" , timer_dc },
    { NULL, NULL } };
    luaL_register( L, NULL, meta_methods );
    lua_pushstring( L, "__getters__" );
    lua_newtable(L);
    const luaL_Reg getters[] =
    {
    { "interval", get_Timer_interval },
    { "on_timer", get_Timer_on_timer },
    { NULL, NULL } };
    luaL_register( L, NULL, getters );
    lua_rawset( L, -3 );
    lua_pushstring( L, "__setters__" );
    lua_newtable(L);
    const luaL_Reg setters[] =
    {
    { "interval", set_Timer_interval },
    { "on_timer", set_Timer_on_timer },
    { NULL, NULL } };
    luaL_register( L, NULL, setters );
    lua_rawset( L, -3 );
    lua_pop(L,1);
    lua_pushcfunction(L,new_Timer);
    lua_setglobal(L,"Timer");
}
//*****************************************************************************

timer::timer( )
:
    source( NULL ),
    interval( 0 )
{
}

timer::~timer()
{
    cancel();
}

void timer::start( UserData * ud )
{
    if ( source )
        return;

    if ( interval <= 0 )
        return;

    source = g_timeout_source_new( interval * 1000 );

    g_source_set_callback( source, timer_fired, UserData::Handle::make( ud , this ), UserData::Handle::destroy );
    g_source_attach( source, g_main_context_default() );
}

void timer::stop()
{
    if ( !source )
        return;

    g_source_destroy( source );
    g_source_unref( source );
    source = NULL;
}

void timer::set_interval( UserData * ud , lua_Number new_interval )
{
    if ( new_interval == interval )
        return;

    interval = new_interval;

    if ( source )
    {
        stop();
        start( ud );
    }
}

lua_Number timer::get_interval() const
{
    return interval;
}

void timer::cancel()
{
    stop();
}

gboolean timer::timer_fired( gpointer _handle )
{
    UserData::Handle * handle = UserData::Handle::get( _handle );

    lua_State * L = handle->get_lua_state();

    g_assert( L );

    timer * self = ( timer* ) handle->get_user();

    if ( ! handle->invoke_callback( "on_timer" , 1 ) )
    {
        self->cancel();
        return FALSE;
    }

    if ( lua_isboolean(L,-1) && !lua_toboolean( L, -1 ) )
    {
        self->cancel();
        lua_pop(L,1);
        return FALSE;
    }
    lua_pop(L,1);
    return TRUE;
}

void luaopen_timer( lua_State*L )
{
    luaopen_Timer( L );
}
