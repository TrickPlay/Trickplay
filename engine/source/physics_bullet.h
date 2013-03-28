#ifndef _TRICKPLAY_PHYSICS_BULLET_H
#define _TRICKPLAY_PHYSICS_BULLET_H

#include "btBulletDynamicsCommon.h"

#include "common.h"
#include "app.h"

namespace Bullet
{
class World
{
public:

    World( lua_State* L , float pixels_per_meter );

    ~World();

    inline float world_to_screen( float coordinate ) const
    {
        return coordinate * ppm;
    }

    inline float screen_to_world( float coordinate ) const
    {
        return coordinate / ppm;
    }

    inline float get_ppm() const
    {
        return ppm;
    }

    btDynamicsWorld* get_world() const
    {
        return world;
    }

    int create_body( int element , int properties , const char* metatable );

    int create_body_3d( int properties );

#if 0
    int create_sensor( int properties );
#endif

    int create_shape( btCollisionShape* shape , lua_CFunction constructor );

    void step( float time_step , int max_sub_steps , float fixed_time_step );

    void get_contacts( double max_distance , btCollisionObject* co1 , btCollisionObject* co2 );

private:

    static void tick_callback( btDynamicsWorld* world , btScalar time );

    LuaStateProxy*              lsp;

    float                       ppm;

    btCollisionDispatcher*      dispatcher;
    btBroadphaseInterface*      pair_cache;
    btConstraintSolver*         solver;
    btCollisionConfiguration*  collision_configuration;

    btDynamicsWorld*            world;

    typedef btAlignedObjectArray< btCollisionShape* > ShapeArray;

    ShapeArray                  shapes;
};

//=========================================================================
// This is a structure we attach to collision objects that keeps
// track of whether it has been added to the world or not. It also
// contains the handle.
// Objects that are in the world, are destroyed when the world is
// destroyed. If they are not in the world, they are destroyed when
// their Lua object is gone.

class BodyData
{
public:

    static void set( World* _world , btCollisionObject* co )
    {
        g_assert( co );

        co->setUserPointer( new BodyData( _world ) );
    }

    static BodyData* get( btCollisionObject* co )
    {
        return reinterpret_cast< BodyData* >( co->getUserPointer() );
    }

    static void destroy_object( btCollisionObject* co , bool only_if_not_in_world )
    {
        g_assert( co );

        BodyData* self = get( co );

        if ( only_if_not_in_world && self->in_world )
        {
            return;
        }

        btRigidBody* rb = btRigidBody::upcast( co );

        if ( rb && rb->getMotionState() )
        {
            delete rb->getMotionState();
        }

        self->world->get_world()->removeCollisionObject( co );

        delete co;

        delete self;
    }

    static bool add_object( btCollisionObject* co )
    {
        g_assert( co );

        BodyData* self = get( co );

        if ( self->in_world )
        {
            return false;
        }

        if ( btRigidBody* rb = btRigidBody::upcast( co ) )
        {
            self->world->get_world()->addRigidBody( rb );
        }
        else
        {
            self->world->get_world()->addCollisionObject( co );
        }

        self->in_world = true;

        return true;
    }

    static bool remove_object( btCollisionObject* co )
    {
        g_assert( co );

        BodyData* self = get( co );

        if ( ! self->in_world )
        {
            return false;
        }

        self->world->get_world()->removeCollisionObject( co );

        self->in_world = false;

        return true;
    }

    int get_handle() const
    {
        return handle;
    }

    int is_in_world() const
    {
        return in_world;
    }

private:

    BodyData()
    {
        g_assert( false );
    }

    BodyData( World* _world )
        :
        world( _world ),
        in_world( false )
    {
        g_assert( world );

        static int next_handle = 1;

        handle = next_handle++;
    }

    ~BodyData()
    {
    }

    int     handle;
    World*  world;
    bool    in_world;
};
};

#endif // _TRICKPLAY_PHYSICS_BULLET_H
