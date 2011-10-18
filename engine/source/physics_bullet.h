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

		World( lua_State * L , float pixels_per_meter );

		~World();

	private:

		LuaStateProxy *	lsp;

		float 			pixels_per_meter;

		btDispatcher *				dispatcher;
		btBroadphaseInterface *		pair_cache;
		btConstraintSolver *		solver;
		btCollisionConfiguration * 	collision_configuration;

		btDynamicsWorld *			world;

	};
};

#endif // _TRICKPLAY_PHYSICS_BULLET_H
