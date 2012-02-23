#include <valarray>

#include <BulletCollision/CollisionShapes/btBox2dShape.h>
#include <BulletDynamics/ConstraintSolver/btGeneric6DofConstraint.h>

#include "physics_bullet.h"
#include "clutter_util.h"
#include "lb.h"

extern int new_PBShape( lua_State * L );
extern int new_PBBody3d( lua_State * L );
extern int invoke_PBBody3d_on_get_transform(lua_State*L, btRigidBody *  self,int nargs,int nresults);
extern int invoke_PBBody3d_on_set_transform(lua_State*L, btRigidBody *  self,int nargs,int nresults);


namespace Bullet
{

//=============================================================================
// This one transfers the position of an actor to and from the world.

#define DEG(x) (180 / G_PI * (x))
#define RAD(x) (G_PI / 180 * (x))

class ActorMotionState : public btMotionState
{
public:

	ActorMotionState( World * _world , ClutterActor * _actor )
	:
		world( _world ),
		actor( _actor )
	{
		g_assert( actor );
		g_object_ref( actor );
	}

	virtual ~ActorMotionState()
	{
		g_object_unref( actor );
	}

	// Lifted from clutter-bullet

	virtual void getWorldTransform(	btTransform & transform ) const
	{
		// From actor to world

		float scale = world->get_ppm();

		CoglMatrix a;
		ClutterVertex x;
		gfloat w;
		gdouble rx, ry, rz;

		clutter_actor_get_size( actor , & x.x , & x.y );
		clutter_actor_get_transformation_matrix( actor , & a );

		x.x /= 2;
		x.y /= 2;
		x.z = 0;
		w = 1;

		cogl_matrix_transform_point( & a , & x.x , & x.y , & x.z , & w );

		g_object_get(actor,
				"rotation-angle-x" , & rx ,
				"rotation-angle-y" , & ry ,
				"rotation-angle-z" , & rz , ( const char * ) 0 );

		transform.setOrigin( btVector3( x.x , x.y , x.z ) / ( w * scale ) );
		transform.getBasis().setEulerZYX( RAD( rx ) , RAD( ry ) , RAD ( rz ) );
	}

	// Lifted from clutter-bullet

	virtual void setWorldTransform(	const btTransform & transform )
	{
		// From world to actor

		float scale = world->get_ppm();

		CoglMatrix a;
		ClutterVertex x, dx;
		gdouble rx, ry, rz;
		gfloat w;

		get_euler_angles(&transform.getBasis(), &rx, &ry, &rz);

		g_object_set(actor, "rotation-angle-x", DEG (rx), "rotation-angle-y",
				DEG (ry), "rotation-angle-z", DEG (rz), NULL);

		clutter_actor_get_size(actor, &x.x, &x.y);
		clutter_actor_get_transformation_matrix(actor, &a);

		x.x /= 2;
		x.y /= 2;
		x.z = 0;
		w = 1;

		cogl_matrix_transform_point(&a, &x.x, &x.y, &x.z, &w);

		dx.x = scale * transform.getOrigin().x() - x.x / w;
		dx.y = scale * transform.getOrigin().y() - x.y / w;
		dx.z = scale * transform.getOrigin().z() - x.z / w;

		clutter_actor_move_by(actor, dx.x, dx.y);
		clutter_actor_set_depth(actor, clutter_actor_get_depth(actor) + dx.z);

	}

	// Lifted from clutter-bullet

	static void get_euler_angles( const btMatrix3x3 * a , gdouble * x , gdouble * y , gdouble * z )
	{
	  if ((*a)[2][0] <= -1)
	  {
	    *x = std::atan2 ((*a)[0][1], (*a)[0][2]);
	    *y = M_PI / 2;
	    *z = 0;
	  }
	  else if ((*a)[2][0] < 1)
	  {
	    *x = std::atan2 ((*a)[2][1], (*a)[2][2]);
	    *y = std::asin (-(*a)[2][0]);
	    *z = std::atan2 ((*a)[1][0], (*a)[0][0]);
	  }
	  else
	  {
	    *x = std::atan2 (-(*a)[0][1], -(*a)[0][2]);
	    *y = -M_PI / 2;
	    *z = 0;
	  }
	}

private:

	World *			world;
	ClutterActor * 	actor;
};

//=============================================================================


World::World( lua_State * L , float _pixels_per_meter )
{
	App * app = App::get( L );

	lsp = app->ref_lua_state_proxy();

	ppm = _pixels_per_meter;

	collision_configuration = new btDefaultCollisionConfiguration();

	dispatcher = new btCollisionDispatcher( collision_configuration );

	pair_cache = new btDbvtBroadphase();

	solver = new btSequentialImpulseConstraintSolver();

	world = new btDiscreteDynamicsWorld( dispatcher , pair_cache , solver , collision_configuration );

	world->setGravity( btVector3( 0 , 10 , 0 ) );
}

//-----------------------------------------------------------------------------

World::~World()
{
	int i;

	// Remove and delete constraints

	for ( i = world->getNumConstraints() - 1; i >= 0 ; --i )
	{
		btTypedConstraint * constraint = world->getConstraint( i );
		world->removeConstraint( constraint );
		delete constraint;
	}

	// Remove and delete bodies and their motion states

	for ( i = world->getNumCollisionObjects() - 1; i >=0 ; --i )
	{
		btCollisionObject * obj = world->getCollisionObjectArray()[ i ];
		btRigidBody * body = btRigidBody::upcast( obj );
		if ( body && body->getMotionState() )
		{
			delete body->getMotionState();
		}
		world->removeCollisionObject( obj );
		delete obj;
	}

	// Delete shapes

	for ( i = 0; i < shapes.size(); ++i )
	{
		btCollisionShape * shape = shapes[ i ];
		delete shape;
	}

	shapes.clear();

	delete world;

	delete solver;

	delete pair_cache;

	delete dispatcher;

	delete collision_configuration;

	lsp->unref();
}

//-----------------------------------------------------------------------------

int World::create_body( int element , int properties , const char * metatable )
{
	lua_State * L = lsp->get_lua_state();

    luaL_checktype( L , element , LUA_TUSERDATA );
    luaL_checktype( L , properties , LUA_TTABLE );

    g_assert( metatable );

    //.........................................................................
    // Get the actor/source

    ClutterActor * actor = ClutterUtil::user_data_to_actor( L , element );

    if ( ! actor )
    {
        return luaL_error( L , "Invalid or missing UIElement" );
    }

    //.........................................................................
    // Get the width and height of the actor

    gfloat width;
    gfloat height;

    clutter_actor_get_size( actor , & width , & height );

    //.........................................................................
    // Default the depth of the body to 1 meter.

    gfloat depth = ppm;

    // TODO: 'dp' sucks. We can't use 'depth' because that is the Z position
    // of the actor. We need something better.

    lua_getfield( L , properties , "dp" );
    if ( lua_isnumber( L , -1 ) )
    {
    	depth = lua_tonumber( L , -1 );
    }
    lua_pop( L , 1 );

    //.........................................................................
    // Create a default shape for it

    float hw = screen_to_world( width / 2.0 );
    float hh = screen_to_world( height / 2.0) ;
    float hd = screen_to_world( depth / 2.0 );

    btCollisionShape * shape = new btBoxShape( btVector3( hw , hh , hd ) );

    // Save the shape so we can delete it later

    shapes.push_back( shape );

    //.........................................................................
    // Default mass to 1 unless it is specified in the properties

    btScalar mass( 1.0f );

    lua_getfield( L , properties , "mass" );
    if ( lua_isnumber( L , -1 ) )
    {
    	mass = lua_tonumber( L , -1 );
    }
    lua_pop( L , 1 );

    btVector3 local_inertia( 0 , 0 , 0 );

    if ( mass != 0.0f )
    {
    	shape->calculateLocalInertia( mass , local_inertia );
    }

    //.........................................................................
    // Create the motion state for the body

    ActorMotionState * motion_state = new ActorMotionState( this , actor );

    //.........................................................................
    // Info to construct the body

	btRigidBody::btRigidBodyConstructionInfo cinfo( mass , motion_state , shape , local_inertia );

    //.........................................................................

	lua_getfield( L , properties , "bounce" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_restitution = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	lua_getfield( L , properties , "restitution" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_restitution = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	lua_getfield( L , properties , "friction" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_friction = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	lua_getfield( L , properties , "linear_damping" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_linearDamping = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	lua_getfield( L , properties , "angular_damping" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_angularDamping = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	//.........................................................................

	btRigidBody * body = new btRigidBody( cinfo );

	world->addRigidBody( body );

	// This constraint keeps the body from rotating around X and Y and from
	// moving along Z. It helps to simulate 2D objects.

	// TODO: This should be optional, but a sensible default.

	if ( mass != 0.0f )
	{
		btTransform frameB;
		frameB.setIdentity();
		btGeneric6DofConstraint* pGen6Dof = new btGeneric6DofConstraint( *body , frameB , false );
		world->addConstraint( pGen6Dof );

		pGen6Dof->setAngularLowerLimit(btVector3(0,0,1));
		pGen6Dof->setAngularUpperLimit(btVector3(0,0,0));

		pGen6Dof->setLinearLowerLimit(btVector3(1, 1, 0));
		pGen6Dof->setLinearUpperLimit(btVector3(0, 0, 0));
	}

	//.........................................................................
    // The body is attached to the actor and is ready to go. We get the actor
    // and change its meta table.

    lb_chain( L , element , metatable );

    lua_pushvalue( L , element );

    return 1;
}

//-----------------------------------------------------------------------------

int World::create_body_3d( int properties )
{
	lua_State * L = lsp->get_lua_state();

    luaL_checktype( L , properties , LUA_TTABLE );

    //.........................................................................
    // Get the shape

    lua_getfield( L , properties , "shape" );

    if ( lua_isnil( L , -1 ) )
    {
    	return luaL_error( L , "Missing shape for body" );
    }

    UserData * ud = UserData::get_check( L , lua_gettop( L ) );

    if ( ! ud )
    {
    	return luaL_error( L , "Invalid shape for body" );
    }

    btCollisionShape * shape = ( btCollisionShape * ) ud->get_client();

    lua_pop( L , 1 );

    //.........................................................................

    lua_getfield( L , properties , "transform" );

    if ( lua_isnil( L , -1 ) )
    {
    	return luaL_error( L , "Missing body transform" );
    }

    ud = UserData::get_check( L , lua_gettop( L ) );

    if ( ! ud )
    {
    	return luaL_error( L , "Invalid body transform" );
    }

    CoglMatrix * matrix = ( CoglMatrix * ) ud->get_client();

    btTransform transform;

    transform.setFromOpenGLMatrix( & matrix->xx );

    lua_pop( L , 1 );

    //.........................................................................
    // Default mass to 1 unless it is specified in the properties

    btScalar mass( 1.0f );

    lua_getfield( L , properties , "mass" );
    if ( lua_isnumber( L , -1 ) )
    {
    	mass = lua_tonumber( L , -1 );
    }
    lua_pop( L , 1 );

    btVector3 local_inertia( 0 , 0 , 0 );

    if ( mass != 0.0f )
    {
    	shape->calculateLocalInertia( mass , local_inertia );
    }

    //.........................................................................
    // Info to construct the body

	btRigidBody::btRigidBodyConstructionInfo cinfo( mass , new btDefaultMotionState( transform ) , shape , local_inertia );

    //.........................................................................

	lua_getfield( L , properties , "bounce" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_restitution = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	lua_getfield( L , properties , "restitution" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_restitution = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	lua_getfield( L , properties , "friction" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_friction = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	lua_getfield( L , properties , "linear_damping" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_linearDamping = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	lua_getfield( L , properties , "angular_damping" );
	if ( lua_isnumber( L , -1 ) )
	{
		cinfo.m_angularDamping = lua_tonumber( L , -1 );
	}
	lua_pop( L , 1 );

	//.........................................................................

	btRigidBody * body = new btRigidBody( cinfo );

	world->addRigidBody( body );

	//.........................................................................

	lua_pushlightuserdata( L , body );
	new_PBBody3d( L );
	lua_remove( L , -2 );

	lua_pushvalue( L , properties );
	lb_set_props_from_table( L );
	lua_pop( L , 1 );

    return 1;
}


//-----------------------------------------------------------------------------

int World::create_shape( btCollisionShape * shape )
{
	g_assert( shape );

	lua_State * L = lsp->get_lua_state();

	if ( 0 == L )
	{
		delete shape;
		return 0;
	}

	lua_pushlightuserdata( L , shape );

	new_PBShape( L );

	lua_remove( L , -2 );

	shapes.push_back( shape );

	return 1;
}

//-----------------------------------------------------------------------------

void World::step( float time_step , int max_sub_steps , float fixed_time_step )
{
	world->stepSimulation( time_step , max_sub_steps , fixed_time_step );
}

//-----------------------------------------------------------------------------

} // namespace Bullet
