#ifndef _TRICKPLAY_PHYSICS_H
#define _TRICKPLAY_PHYSICS_H

#include "Box2D/Box2D.h"
#include "clutter/clutter.h"

#include "common.h"
#include "user_data.h"

namespace Physics
{
    class Body;

    //=========================================================================

    class World : private b2ContactListener
    {
    public:

        //.........................................................................

        World( lua_State * L , ClutterActor * screen , float32 pixels_per_meter );

        //.........................................................................

        ~World();

        //.........................................................................

        inline int get_next_handle()
        {
            return next_handle++;
        }

        inline gpointer get_next_handle_as_pointer()
        {
            return GINT_TO_POINTER( get_next_handle() );
        }

        inline b2World * get_world()
        {
            return & world;
        }

        //.........................................................................

        void start( int velocity_iterations , int position_iterations );

        void stop();

        void step( float32 time_step , int velocity_iterations , int position_iterations );

        //.........................................................................

        inline static float32 degrees_to_radians( float32 degrees )
        {
            return degrees * ( G_PI / 180.0f );
        }

        inline static float32 radians_to_degrees( float32 radians )
        {
            return radians / ( G_PI / 180.0f );
        }

        inline float32 world_to_screen( float32 coordinate ) const
        {
            return coordinate * ppm;
        }

        inline float32 screen_to_world( float32 coordinate ) const
        {
            return coordinate / ppm;
        }

        //.........................................................................
        // Properties is the stack index of a Lua table

        int create_body( int properties , lua_CFunction constructor );

        //.........................................................................

        b2FixtureDef create_fixture_def( int properties );

        //.........................................................................

        float32   ppm;  // Pixels per meter

    private:

        //.........................................................................
        // b2ContactListener methods

        virtual void BeginContact( b2Contact * contact );

        virtual void EndContact( b2Contact * contact );

        virtual void PreSolve( b2Contact * contact , const b2Manifold * oldManifold );

        virtual void PostSolve( b2Contact * contact , const b2ContactImpulse * impulse );

        //.........................................................................

        static gboolean on_idle( gpointer me );

        //.........................................................................

        lua_State *     L;

        b2World         world;

        int             next_handle;

        int             velocity_iterations;
        int             position_iterations;

        guint           idle_source;
        GTimer *        timer;

        ClutterActor *  screen;
    };

    //=========================================================================

    class Body
    {
    public:

        Body( World * world , b2Body * body , ClutterActor * actor );

        ~Body();

        //.....................................................................
        // Ensure the body is still good

        inline void check( lua_State * L )
        {
            if ( ! body )
            {
                luaL_error( L , "Body has been destroyed" );
            }
        }

        //.....................................................................
        // Called when the b2Body is destroyed - to invalidate me

        static void body_destroyed( b2Body * body );

        //.....................................................................
        // With my Lua proxy on the top of the stack, we create a handle to
        // keep it alive.

        void create_ud_handle( lua_State * L );

        //.....................................................................
        // Getters from various places.

        static Body * get_from_actor( ClutterActor * actor );

        static Body * get_from_body( b2Body * body );

        static Body * get_from_lua( lua_State * L , int index );

        //.....................................................................
        // Synchronizes the actor's position from the body

        void synchronize_actor();

        static void synchronize_actor( b2Body * body );

        //.....................................................................
        // Synchronizes the body's position from the actor

        void synchronize_body();

        //.....................................................................

        World *             world;
        b2Body *            body;
        ClutterActor *      actor;
        int                 handle;

    private:

        //.....................................................................
        // The key we use to attach me to the actor

        static GQuark get_actor_body_quark();

        //.....................................................................
        // When the actor is destroyed

        static void destroy_actor_body( Body * self );

        //.....................................................................
        // Signal handler when the 'mapped' property of the actor changes. It
        // makes the body active when the actor is mapped and inactive when it
        // is not. It also synchronizes the body from the actor when the latter
        // is mapped.

        static void actor_mapped_notify( GObject * gobject , GParamSpec * , Body * self );

        //.....................................................................
        // The user data handle that keeps us alive in Lua as long as the actor
        // is alive.

        UserData::Handle *  ud_handle;

        //.....................................................................
        // Signal handler for mapped

        gulong              mapped_handler;
    };
};

#endif // _TRICKPLAY_PHYSICS_H
