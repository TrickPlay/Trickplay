#ifndef _TRICKPLAY_PHYSICS_H
#define _TRICKPLAY_PHYSICS_H

#include "Box2D/Box2D.h"
#define CLUTTER_VERSION_MIN_REQUIRED CLUTTER_VERSION_CUR_STABLE
#include "clutter/clutter.h"
#include "cairo.h"

#include "common.h"
#include "user_data.h"

namespace Physics
{
    class Body;

    enum ContactCallback
    {
        BEGIN_CONTACT = 0x01,
        END_CONTACT = 0x02,
        PRE_SOLVE_CONTACT = 0x04,
        POST_SOLVE_CONTACT = 0x08
    };

    //=========================================================================

    class World : private b2ContactListener , private b2Draw
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

        inline bool running() const
        {
            return idle_source != 0;
        }

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
        // Element is the stack index of a UIElement, properties is the stack
        // index of a Lua table

        int create_body( int element , int properties , const char * metatable );

        //.........................................................................

        b2FixtureDef create_fixture_def( int properties );

        //.........................................................................

        void push_contact( b2Contact * contact );

        void push_contact_list( b2Contact * contact );

        void push_contact_list( b2ContactEdge * contact_edge );

        void attach_global_callback( ContactCallback callback , bool attach );


        void attach_body_callback( Body * body , ContactCallback callback , bool attach );

        void detach_body_callbacks( b2Body * body );

        //.........................................................................

        void destroy_body_later( b2Body * body );
        void deactivate_body_later( b2Body * body );
        void activate_body_later( b2Body * body );

        //.........................................................................

        void draw_debug( int opacity );

        void clear_debug();

        //.........................................................................

        float32   ppm;  // Pixels per meter

        bool z_for_y;

    private:

        //.........................................................................
        // b2ContactListener methods

        virtual void BeginContact( b2Contact * contact );

        virtual void EndContact( b2Contact * contact );

        virtual void PreSolve( b2Contact * contact , const b2Manifold * oldManifold );

        virtual void PostSolve( b2Contact * contact , const b2ContactImpulse * impulse );

        //.........................................................................
        // b2Draw methods

        virtual void DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);

        virtual void DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color);

        virtual void DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color);

        virtual void DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color);

        virtual void DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color);

        virtual void DrawTransform(const b2Transform& xf);

        //.........................................................................

        static gboolean on_idle( gpointer me );

        void idle();

        //.........................................................................

        guint8          global_callbacks;

        typedef std::map< b2Body * , guint8 > BodyCallbackMap;

        BodyCallbackMap body_callbacks;

        typedef std::list< Body * > BodyList;

        void add_contact_callback_body( b2Body * body , ContactCallback callback , BodyList & list );

        BodyList get_contact_callback_bodies( b2Contact * contact , ContactCallback callback );

        void invoke_contact_callback( b2Contact * contact , ContactCallback callback , const char * name );

        //.........................................................................

        static gboolean on_debug_draw( ClutterCairoTexture * texture , cairo_t * cr , World * world );

        //.........................................................................

        lua_State *     L;

        b2World         world;

        int             next_handle;

        int             velocity_iterations;
        int             position_iterations;

        guint           idle_source;
        guint           repaint_source;
        GTimer *        timer;

        ClutterActor *  screen;

        ClutterActor *  debug_draw;
        cairo_t *       debug_cairo;

        typedef std::list< b2Body * > b2BodyList;

        b2BodyList      to_destroy;
        b2BodyList      to_deactivate;
        b2BodyList      to_activate;

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
        // Getters from various places.

        static Body * get( ClutterActor * actor );

        static Body * get( b2Body * body );

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

        inline static GQuark get_actor_body_quark()
        {
            static const gchar * k = "tp-physics_body";

            static GQuark quark = g_quark_from_static_string( k );

            return quark;
        }

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

        gulong              mapped_handler;
    };

    //=========================================================================

    class AABBQuery : public b2QueryCallback
    {
    public:

        AABBQuery( lua_State * _LS );

        virtual bool ReportFixture( b2Fixture * fixture );

    private:

        lua_State * L;
    };

};

#endif // _TRICKPLAY_PHYSICS_H
