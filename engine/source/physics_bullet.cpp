
#include "physics_bullet.h"

namespace Bullet
{

//=============================================================================
// This one transfers the position of an actor to and from the world.

class ActorMotionState : public btMotionState
{
public:

	ActorMotionState( ClutterActor * _actor )
	:
		actor( _actor )
	{
		g_assert( actor );
		g_object_ref( actor );
	}

	virtual ~ActorMotionState()
	{
		g_object_unref( actor );
	}

	virtual void getWorldTransform(	btTransform & transform ) const
	{
		// From actor to world
	}


	virtual void setWorldTransform(	const btTransform & transform )
	{
		// From world to actor
	}


private:

	ClutterActor * actor;
};

//=============================================================================


World::World( lua_State * L , float _pixels_per_meter )
{
	App * app = App::get( L );

	lsp = app->ref_lua_state_proxy();

	pixels_per_meter = _pixels_per_meter;

	collision_configuration = new btDefaultCollisionConfiguration();

	dispatcher = new btCollisionDispatcher( collision_configuration );

	pair_cache = new btDbvtBroadphase();

	solver = new btSequentialImpulseConstraintSolver();

	world = new btDiscreteDynamicsWorld( dispatcher , pair_cache , solver , collision_configuration );

	world->setGravity( btVector3( 0 , 10 , 0 ) );
}

World::~World()
{
	lsp->unref();

	// TODO: get rid of bodies

	delete world;

	delete solver;

	delete pair_cache;

	delete dispatcher;

	delete collision_configuration;
}



}
