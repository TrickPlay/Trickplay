
#include "physics.h"
#include "app.h"
#include "clutter_util.h"
#include "lb.h"
#include "util.h"

//-----------------------------------------------------------------------------
#define TP_LOG_DOMAIN   "PHYSICS"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"
//.............................................................................

namespace Physics
{

World::World( lua_State* _LS , ClutterActor* _screen , float32 _pixels_per_meter )
    :
    ppm( _pixels_per_meter ),
    z_for_y( false ),
    global_callbacks( 0 ),
    L( _LS ),
    world( b2Vec2( 0.0f , 10.0f ) ),
    next_handle( 1 ),
    velocity_iterations( 6 ),
    position_iterations( 2 ),
    idle_source( 0 ),
    repaint_source( 0 ),
    timer( g_timer_new() ),
    screen( CLUTTER_ACTOR( g_object_ref( _screen ) ) ),
    debug_draw( 0 )
{
    world.SetContactListener( this );
}

//.............................................................................

World::~World()
{
    clear_debug();

    // Remove the collision listener so we don't get callbacks while
    // destroying the world.

    world.SetContactListener( 0 );

    // Stop our idle source and destroy the timer

    stop();

    g_timer_destroy( timer );

    // Destroy the body wrappers

    for ( b2Body* body = world.GetBodyList(); body; )
    {
        b2Body* next = body->GetNext();

        Body::body_destroyed( body );

        body = next;
    }

    // Let go of the screen

    g_object_unref( screen );
}

//.............................................................................

void World::start( int _velocity_iterations , int _position_iterations )
{
    if ( idle_source )
    {
        return;
    }

    repaint_source = clutter_threads_add_repaint_func( on_idle , this, NULL );
    idle_source = clutter_threads_add_idle( on_idle, this );

    g_timer_start( timer );

    velocity_iterations = _velocity_iterations;
    position_iterations = _position_iterations;
}

//.............................................................................

void World::stop()
{
    if ( ! idle_source )
    {
        return;
    }

    clutter_threads_remove_repaint_func( repaint_source );
    g_source_remove( idle_source );

    idle_source = 0;
    repaint_source = 0;
}

//.............................................................................

void World::step( float32 time_step , int _velocity_iterations , int _position_iterations )
{
    // Bodies that we could not destroy/activate/de-activate during a callback are taken care of here.
    // We only destroy a few at a time.

    if ( ! to_deactivate.empty() )
    {
        for ( int i = 0; ! to_deactivate.empty() && i < 5; ++i )
        {
            to_deactivate.front()->SetActive( false );

            to_deactivate.pop_front();
        }
    }

    if ( ! to_activate.empty() )
    {
        for ( int i = 0; ! to_activate.empty() && i < 5; ++i )
        {
            to_activate.front()->SetActive( true );

            to_activate.pop_front();
        }
    }

    if ( ! to_destroy.empty() )
    {
        for ( int i = 0; ! to_destroy.empty() && i < 5; ++i )
        {
            world.DestroyBody( to_destroy.front() );

            to_destroy.pop_front();
        }
    }

    world.Step( time_step , _velocity_iterations , _position_iterations );

    for ( b2Body* body = world.GetBodyList(); body; body = body->GetNext() )
    {
        if ( ! body->IsAwake() || ! body->IsActive() )
        {
            continue;
        }

        Body::synchronize_actor( body );
    }
}

//.............................................................................

void World::idle()
{
    static gdouble sixty = 1.0 / 60.0;

    gdouble seconds = g_timer_elapsed( timer , NULL );

    if ( seconds < sixty )
    {
        return;
    }

    int iterations = seconds / sixty;

    g_timer_start( timer );

    UserData* ud = UserData::get_from_client( this );

    for ( int i = 0; i < iterations; ++i )
    {
        step( sixty , velocity_iterations , position_iterations );

        if ( ud )
        {
            lua_pushnumber( L , sixty );
            lua_pushinteger( L , i );

            ud->invoke_callbacks( "on_step" , 2 , 0 );
        }
    }
}

//.............................................................................

gboolean World::on_idle( gpointer me )
{
    ( ( World* ) me )->idle();

    return TRUE;
}

//.............................................................................

int World::create_body( int element , int properties , const char* metatable )
{
    luaL_checktype( L , element , LUA_TUSERDATA );
    luaL_checktype( L , properties , LUA_TTABLE );

    g_assert( metatable );

    //.........................................................................
    // Get the actor/source

    ClutterActor* actor = ClutterUtil::user_data_to_actor( L , element );

    if ( ! actor )
    {
        return luaL_error( L , "Invalid or missing UIElement" );
    }

    //.........................................................................
    // The body defintion

    b2BodyDef bd;

    //.........................................................................
    // Get the width and height of the actor

    gfloat width;
    gfloat height;

    clutter_actor_get_size( actor , & width , & height );

    if(width * height < FLT_EPSILON)
    {
        g_critical("CANNOT CREATE PHYSICS BODY ON UIELEMENT THAT IS SO SMALL AT %s", Util::where_am_i_lua(L).c_str());
        return 0;
    }

    //.........................................................................
    // Move the anchor point to the center of the actor. This doesn't change
    // its position relative to its parent.

    clutter_actor_move_anchor_point( actor , width / 2.0f , height / 2.0f );

    //.........................................................................
    // Get the screen position of the actor's anchor point, convert it to world
    // coordinates and set it in the body definition.

    gfloat x;
    gfloat y;

    clutter_actor_get_position( actor , & x , & y );

    bd.position.x = screen_to_world( x );
    bd.position.y = screen_to_world( y );

    //.........................................................................
    // Populate the rotation of the body from the actor's z rotation.

    bd.angle = degrees_to_radians( clutter_actor_get_rotation( actor , CLUTTER_Z_AXIS , 0 , 0 , 0 ) );

    //.........................................................................
    // Set the body type - dynamic by default

    bd.type = b2_dynamicBody;

    //.........................................................................
    // Ready to create the body

    b2Body* body = world.CreateBody( & bd );

    if ( ! body )
    {
        tpwarn( "FAILED TO CREATE PHYSICS BODY" );
        return 0;
    }

    //.........................................................................
    // The properties table can also have default fixture attributes, so
    // we create a fixture def using the same table.

    b2FixtureDef fd = create_fixture_def( properties );

    //.........................................................................
    // If the user did not pass a shape for the fixture, we create a default
    // polygon.

    b2PolygonShape box;

    if ( ! fd.shape )
    {
        box.SetAsBox( screen_to_world( width / 2.0f ) , screen_to_world( height / 2.0f ) );

        fd.shape = & box;
    }

    //.........................................................................
    // Set the handle for the fixture

    fd.userData = get_next_handle_as_pointer();

    //.........................................................................
    // Create the fixture

    body->CreateFixture( & fd );

    //.........................................................................
    // Create the body wrapper for it. This sets up all the relationships and
    // user data pointers.

    ( void )new Body( this , body , actor );

    //.........................................................................
    // The body is attached to the actor and is ready to go. We get the actor
    // and change its metatable

    lb_chain( L , element , metatable );

    lua_pushvalue( L , element );

    return 1;
}

//.............................................................................

b2FixtureDef World::create_fixture_def( int properties )
{
    b2FixtureDef fd;

    //.........................................................................
    // Friction

    lua_getfield( L , properties , "friction" );

    if ( ! lua_isnil( L , -1 ) )
    {
        fd.friction = lua_tonumber( L , -1 );
    }

    lua_pop( L , 1 );

    //.........................................................................
    // Restitution aka bounce

    lua_getfield( L , properties , "restitution" );

    if ( ! lua_isnil( L , -1 ) )
    {
        fd.restitution = lua_tonumber( L , -1 );
    }

    lua_pop( L , 1 );

    lua_getfield( L , properties , "bounce" );

    if ( ! lua_isnil( L , -1 ) )
    {
        fd.restitution = lua_tonumber( L , -1 );
    }

    lua_pop( L , 1 );

    //.........................................................................
    // Density

    lua_getfield( L , properties , "density" );

    if ( ! lua_isnil( L , -1 ) )
    {
        fd.density = lua_tonumber( L , -1 );
    }

    lua_pop( L , 1 );

    //.........................................................................
    // Sensor

    lua_getfield( L , properties , "sensor" );

    if ( ! lua_isnil( L , -1 ) )
    {
        fd.isSensor = lua_toboolean( L , -1 );
    }

    lua_pop( L , 1 );

    //.........................................................................
    // Collision filter

    lua_getfield( L , properties , "filter" );

    if ( lua_istable( L , -1 ) )
    {
        int f = lua_gettop( L );

        lua_getfield( L , f , "group" );

        if ( ! lua_isnil( L , -1 ) )
        {
            fd.filter.groupIndex = lua_tointeger( L , -1 );
        }

        lua_pop( L , 1 );

        lua_getfield( L , f , "category" );

        if ( lua_isnumber( L , -1 ) )
        {
            fd.filter.categoryBits = 1 << lua_tointeger( L , -1 );
        }
        else if ( lua_istable( L , -1 ) )
        {
            fd.filter.categoryBits = 0;

            int t = lua_gettop( L );

            lua_pushnil( L );

            while ( lua_next( L , t ) )
            {
                if ( lua_isnumber( L , -1 ) )
                {
                    // Check in range
                    lua_Integer cat = lua_tointeger( L, -1 );

                    if ( cat < 0 || cat > 15 )
                    {
                        tpwarn( "ATTEMPT TO SET CATEGORY %d ON A FIXTURE'S FILTER NOT ALLOWED.  MUST BE 0 <= CATEGORY <= 15", cat );
                    }
                    else
                    {
                        fd.filter.categoryBits |= 1 << cat;
                    }
                }

                lua_pop( L , 1 );
            }
        }

        // Guarantee that a fixture always has a non-zero category
        if ( 0 == fd.filter.categoryBits ) { fd.filter.categoryBits = 1; }

        lua_pop( L , 1 );

        lua_getfield( L , f , "mask" );

        if ( lua_isnumber( L , -1 ) )
        {
            fd.filter.maskBits = 1 << lua_tointeger( L , -1 );
        }
        else if ( lua_istable( L , -1 ) )
        {
            fd.filter.maskBits = 0;

            int t = lua_gettop( L );

            lua_pushnil( L );

            while ( lua_next( L , t ) )
            {
                if ( lua_isnumber( L , -1 ) )
                {
                    // Check in range
                    lua_Integer cat = lua_tointeger( L, -1 );

                    if ( cat < 0 || cat > 15 )
                    {
                        tpwarn( "ATTEMPT TO SET MASK %d ON A FIXTURE'S FILTER NOT ALLOWED.  MUST BE 0 <= MASK <= 15", cat );
                    }
                    else
                    {
                        fd.filter.maskBits |= 1 << cat;
                    }
                }

                lua_pop( L , 1 );
            }
        }

        lua_pop( L , 1 );
    }

    lua_pop( L , 1 );

    //.........................................................................
    // Shape

    lua_getfield( L , properties , "shape" );

    if ( lua_isuserdata( L , -1 ) )
    {
        lb_check_udata_type( L , -1 , "Shape" );

        fd.shape = ( b2Shape* ) UserData::get_client( L , lua_gettop( L ) );
    }

    lua_pop( L , 1 );

    return fd;
}

//.............................................................................

void World::push_contact( b2Contact* contact )
{
    g_assert( contact );

    b2WorldManifold wm;

    contact->GetWorldManifold( & wm );

    b2Fixture* fa = contact->GetFixtureA();
    b2Fixture* fb = contact->GetFixtureB();

    int fixture_a_handle = fa ? GPOINTER_TO_INT( fa->GetUserData() ) : 0;
    int fixture_b_handle = fb ? GPOINTER_TO_INT( fb->GetUserData() ) : 0;

    b2Body* ba = fa ? fa->GetBody() : 0;
    b2Body* bb = fb ? fb->GetBody() : 0;

    Body* ia = ba ? Body::get( ba ) : 0;
    Body* ib = bb ? Body::get( bb ) : 0;

    int body_a_handle = ia ? ia->handle : 0;
    int body_b_handle = ib ? ib->handle : 0;

    lua_newtable( L );
    int t = lua_gettop( L );

    lua_createtable( L , 2 , 0 );
    lua_pushnumber( L , world_to_screen( wm.points[ 0 ].x ) );
    lua_rawseti( L , -2  , 1 );
    lua_pushnumber( L , world_to_screen( wm.points[ 0 ].y ) );
    lua_rawseti( L , -2  , 2 );
    lua_setfield( L , t , "point" );

    lua_createtable( L , 2 , 0 );
    lua_pushinteger( L , fixture_a_handle );
    lua_rawseti( L , -2 , 1 );
    lua_pushinteger( L , fixture_b_handle );
    lua_rawseti( L , -2 , 2 );
    lua_setfield( L , t , "fixtures" );

    lua_createtable( L , 2 , 0 );
    lua_pushinteger( L , fixture_b_handle );
    lua_rawseti( L , -2 , fixture_a_handle );
    lua_pushinteger( L , fixture_a_handle );
    lua_rawseti( L , -2 , fixture_b_handle );
    lua_setfield( L , t , "other_fixture" );

    lua_createtable( L , 2 , 0 );
    lua_pushinteger( L , body_a_handle );
    lua_rawseti( L , -2 , 1 );
    lua_pushinteger( L , body_b_handle );
    lua_rawseti( L , -2 , 2 );
    lua_setfield( L , t , "bodies" );

    lua_createtable( L , 2 , 0 );
    lua_pushinteger( L , body_b_handle );
    lua_rawseti( L , -2 , body_a_handle );
    lua_pushinteger( L , body_a_handle );
    lua_rawseti( L , -2 , body_b_handle );
    lua_setfield( L , t , "other_body" );

    lua_pushboolean( L , contact->IsTouching() );
    lua_setfield( L , t , "touching" );

    lua_pushboolean( L , contact->IsEnabled() );
    lua_setfield( L , t , "enabled" );
}

//.............................................................................

void World::push_contact_list( b2Contact* contact )
{
    if ( ! contact )
    {
        lua_pushnil( L );
        return;
    }

    lua_newtable( L );

    int i = 1;

    for ( b2Contact* c = contact; c ; c = c->GetNext() , ++i )
    {
        push_contact( c );
        lua_rawseti( L , -2 , i );
    }
}

//.............................................................................

void World::push_contact_list( b2ContactEdge* contact_edge )
{
    if ( ! contact_edge )
    {
        lua_pushnil( L );
        return;
    }

    lua_newtable( L );

    int i = 1;

    for ( b2ContactEdge* e = contact_edge; e ; e = e->next , ++i )
    {
        push_contact( e->contact );
        lua_rawseti( L , -2 , i );
    }
}

//.............................................................................
// Sets or clears a bit in 'global_callbacks' corresponding to the callback
// passed in. This lets us know quickly whether that global callback is
// wanted by the Lua proxy for the world.

void World::attach_global_callback( ContactCallback callback , bool attach )
{
    if ( ! attach )
    {
        global_callbacks &= ! guint8( callback );
    }
    else
    {
        global_callbacks |= guint8( callback );
    }
}

//.............................................................................
// Given a body, a callback type and whether to attach or detach the callback,
// we update our body callback map.

void World::attach_body_callback( Body* body , ContactCallback callback , bool attach )
{
    g_assert( body );

    if ( ! body->body )
    {
        return;
    }

    // See if we already have an entry for this b2Body in the map

    BodyCallbackMap::iterator it = body_callbacks.find( body->body );

    // Not found

    if ( it == body_callbacks.end() )
    {
        if ( ! attach )
        {
            // We are being asked to detach a callback that is not there

            return;
        }
        else
        {
            // Otherwise, this is the only callback for this body so far,
            // so we insert a new b2Body/mask pair into the map.

            body_callbacks.insert( std::make_pair( body->body , guint8( callback ) ) );
        }
    }
    else
    {
        if ( ! attach )
        {
            // Clear the bit for this callback

            it->second &= ! guint8( callback );

            // If it has no other callbacks attached, we can remove it from
            // the map completely.

            if ( it->second == 0 )
            {
                body_callbacks.erase( it );
            }
        }
        else
        {
            // Set the bit for this callback

            it->second |= guint8( callback );
        }
    }
}

//.............................................................................
// Removes the entry for this b2Body from the callbacks map

void World::detach_body_callbacks( b2Body* body )
{
    if ( body )
    {
        BodyCallbackMap::iterator it = body_callbacks.find( body );

        if ( it != body_callbacks.end() )
        {
            body_callbacks.erase( it );
        }
    }
}

//.............................................................................
// If this b2Body is all good and wants this type of callback, we add its
// Body * to the list.

void World::add_contact_callback_body( b2Body* body , ContactCallback callback , BodyList& list )
{
    if ( ! body )
    {
        return;
    }

    // Look for the b2Body in our map

    BodyCallbackMap::iterator it( body_callbacks.find( body ) );

    // If it is there

    if ( it != body_callbacks.end() )
    {
        // See if it wants this callback

        if ( it->second & callback )
        {
            // If so and its Body is valid, add it to the list

            if ( Body* b = Body::get( body ) )
            {
                list.push_back( b );
            }
        }
    }
}

//.............................................................................
// Creates a list of Body * for the two bodies in the contact, as long as they
// want the callback and they are in good shape.

World::BodyList World::get_contact_callback_bodies( b2Contact* contact , ContactCallback callback )
{
    std::list<Physics::Body*> result;

    add_contact_callback_body( contact->GetFixtureA()->GetBody() , callback , result );

    add_contact_callback_body( contact->GetFixtureB()->GetBody() , callback , result );

    return result;
}

//.............................................................................
// Given a contact, callback and callback name, invokes all the right callbacks.

void World::invoke_contact_callback( b2Contact* contact , ContactCallback callback , const char* name )
{
    // Get a list of bodies that want this callback. The list will
    // have either 0, 1 or 2.

    BodyList bodies( get_contact_callback_bodies( contact , callback ) );

    // If the list of bodies is empty and no one wants the global
    // callback, we bail right here

    if ( ( !( global_callbacks & callback ) ) && bodies.empty() )
    {
        return;
    }

    // We push the contact once and then push its value for each call

    push_contact( contact );

    int c = lua_gettop( L );

    // Body callbacks

    if ( ! bodies.empty() )
    {
        for ( BodyList::const_iterator it = bodies.begin(); it != bodies.end(); ++it )
        {
            lua_pushvalue( L , c );

            UserData::invoke_callbacks( G_OBJECT( ( *it )->actor ) , name , 1 , 0 , L );

            if ( callback == PRE_SOLVE_CONTACT )
            {
                lua_getfield( L , c , "enabled" );
                contact->SetEnabled( lua_toboolean( L , -1 ) );
                lua_pop( L , 1 );
            }
        }
    }

    // Now the global world callback

    if ( global_callbacks & callback )
    {
        lua_pushvalue( L , c );
        UserData::invoke_callbacks( this , name , 1 , 0 , L );

        if ( callback == PRE_SOLVE_CONTACT )
        {
            lua_getfield( L , c , "enabled" );
            contact->SetEnabled( lua_toboolean( L , -1 ) );
            lua_pop( L , 1 );
        }
    }

    lua_pop( L , 1 );
}

//.............................................................................

void World::destroy_body_later( b2Body* body )
{
    g_assert( body );

    to_destroy.push_back( body );
}

//.............................................................................

void World::deactivate_body_later( b2Body* body )
{
    g_assert( body );

    to_deactivate.push_back( body );
}

//.............................................................................

void World::activate_body_later( b2Body* body )
{
    g_assert( body );

    to_activate.push_back( body );
}

//=============================================================================
// ContactListener callbacks

void World::BeginContact( b2Contact* contact )
{
    invoke_contact_callback( contact , BEGIN_CONTACT , "on_begin_contact" );
}

//.............................................................................

void World::EndContact( b2Contact* contact )
{
    invoke_contact_callback( contact , END_CONTACT , "on_end_contact" );
}

//.............................................................................

void World::PreSolve( b2Contact* contact , const b2Manifold* oldManifold )
{
    invoke_contact_callback( contact , PRE_SOLVE_CONTACT , "on_pre_solve_contact" );
}

//.............................................................................

void World::PostSolve( b2Contact* contact , const b2ContactImpulse* impulse )
{
    // TODO : should we pass the impulse too?

    invoke_contact_callback( contact , POST_SOLVE_CONTACT , "on_post_solve_contact" );
}

//=========================================================================
// DebugDraw callbacks

void World::DrawPolygon( const b2Vec2* vertices, int32 vertexCount, const b2Color& color )
{
    g_assert( debug_cairo );

    cairo_new_path( debug_cairo );

    for ( int i = 0; i < vertexCount; ++i )
    {
        const b2Vec2& v( vertices[ i ] );

        cairo_line_to( debug_cairo , v.x , v.y );
    }

    cairo_close_path( debug_cairo );
    cairo_set_source_rgba( debug_cairo , color.r , color.g , color.b , 1 );
    cairo_set_line_width( debug_cairo , 1 / ppm );
    cairo_stroke( debug_cairo );
}

void World::DrawSolidPolygon( const b2Vec2* vertices, int32 vertexCount, const b2Color& color )
{
    g_assert( debug_cairo );

    cairo_new_path( debug_cairo );

    for ( int i = 0; i < vertexCount; ++i )
    {
        const b2Vec2& v( vertices[ i ] );

        cairo_line_to( debug_cairo , v.x , v.y );
    }

    cairo_close_path( debug_cairo );
    cairo_set_source_rgba( debug_cairo , color.r , color.g , color.b , 1 );
    cairo_fill( debug_cairo );
}

void World::DrawCircle( const b2Vec2& center, float32 radius, const b2Color& color )
{
    g_assert( debug_cairo );

    cairo_new_path( debug_cairo );
    cairo_set_source_rgba( debug_cairo , color.r , color.g , color.b , 1 );
    cairo_arc( debug_cairo , center.x , center.y , radius , 0 , 2 * G_PI );
    cairo_set_line_width( debug_cairo , 1 / ppm );
    cairo_stroke( debug_cairo );
}

void World::DrawSolidCircle( const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color )
{
    g_assert( debug_cairo );

    cairo_new_path( debug_cairo );
    cairo_set_source_rgba( debug_cairo , color.r , color.g , color.b , 1 );
    cairo_arc( debug_cairo , center.x , center.y , radius , 0 , 2 * G_PI );
    cairo_fill( debug_cairo );
}

void World::DrawSegment( const b2Vec2& p1, const b2Vec2& p2, const b2Color& color )
{
    g_assert( debug_cairo );

    cairo_new_path( debug_cairo );
    cairo_set_source_rgba( debug_cairo , color.r , color.g , color.b , 1 );
    cairo_set_line_width( debug_cairo , 1 / ppm );
    cairo_move_to( debug_cairo , p1.x , p1.y );
    cairo_line_to( debug_cairo , p2.x , p2.y );
    cairo_stroke( debug_cairo );
}

void World::DrawTransform( const b2Transform& xf )
{
#if 0

    g_assert( debug_cairo );

    cairo_save( debug_cairo );

    cairo_move_to( debug_cairo , xf.position.x , xf.position.y );

    cairo_rotate( debug_cairo , xf.GetAngle() );

    cairo_line_to( debug_cairo , xf.position.x + 100 / ppm , xf.position.y );

    cairo_set_line_width( debug_cairo , 1 / ppm );
    cairo_stroke( debug_cairo );
    cairo_restore( debug_cairo );
#endif
}

//=========================================================================

gboolean World::on_debug_draw( ClutterCairoTexture* texture , cairo_t* cr , World* world )
{
    world->debug_cairo = cr;

    cairo_scale( cr , world->ppm , world->ppm );

    world->b2Draw::SetFlags(
            b2Draw::e_shapeBit
            | b2Draw::e_jointBit
            | b2Draw::e_aabbBit
            | b2Draw::e_pairBit
            | b2Draw::e_centerOfMassBit
    );

    world->world.SetDebugDraw( world );

    world->world.DrawDebugData();

    world->world.SetDebugDraw( 0 );

    world->debug_cairo = 0;

    return TRUE;
}

//.............................................................................

void World::draw_debug( int opacity )
{
    if ( ! debug_draw )
    {
        gfloat w;
        gfloat h;

        clutter_actor_get_size( screen , & w , & h );

        debug_draw = clutter_cairo_texture_new( w , h );

        gdouble sx;
        gdouble sy;

        clutter_actor_get_scale( screen , & sx , & sy );

        clutter_actor_set_scale( debug_draw , sx , sy );

        ClutterActor* parent = clutter_actor_get_parent( screen );

        clutter_actor_add_child( parent, debug_draw );

        g_object_ref( G_OBJECT( debug_draw ) );
    }
    else
    {
        clutter_cairo_texture_clear( CLUTTER_CAIRO_TEXTURE( debug_draw ) );
    }

    clutter_actor_set_child_above_sibling( clutter_actor_get_parent( screen ), debug_draw, NULL );

    clutter_actor_set_opacity( debug_draw , opacity );

    gulong handler = g_signal_connect( debug_draw , "draw" , GCallback( on_debug_draw ) , this );

    clutter_cairo_texture_invalidate( CLUTTER_CAIRO_TEXTURE( debug_draw ) );

    g_signal_handler_disconnect( debug_draw , handler );
}

//.............................................................................

void World::clear_debug()
{
    if ( ! debug_draw )
    {
        return;
    }

    g_assert( CLUTTER_IS_ACTOR( debug_draw ) );

    ClutterActor* parent = clutter_actor_get_parent( debug_draw );

    if ( parent )
    {
        clutter_actor_remove_child( parent, debug_draw );
    }

    g_object_unref( G_OBJECT( debug_draw ) );

    debug_draw = 0;
}

//.............................................................................
// This wrapper is attached to the actor and is owned by the actor.

Body::Body( World* _world , b2Body* _body , ClutterActor* _actor )
    :
    world( _world ),
    body( _body ),
    actor( _actor ),
    mapped_handler( 0 )
{
    g_assert( world );
    g_assert( body );
    g_assert( actor );

    handle = world->get_next_handle();

    // Give a pointer to the b2Body

    body->SetUserData( this );

    // Give a pointer to the actor

    g_object_set_qdata_full( G_OBJECT( actor ) , get_actor_body_quark() , this , ( GDestroyNotify ) destroy_actor_body );

    // Set the active state of the body based on whether the actor is mapped

    body->SetActive( CLUTTER_ACTOR_IS_MAPPED( actor ) );

    // Attach a signal handler to be notified when the actor's mapped property changes

    mapped_handler = g_signal_connect_after( G_OBJECT( actor ) , "notify::mapped" , ( GCallback ) actor_mapped_notify , this );


    tplog( "CREATED BODY %d : %p : b2body %p : actor %p" , handle , this , body , actor );
}

//.............................................................................
// We may get destroyed before the actor, when the Lua state is closing

Body::~Body()
{
    tplog( "DESTROYING BODY %d : %p : b2body %p : actor %p" , handle , this , body , actor );

    if ( body )
    {
        // Remove any callbacks for this body

        world->detach_body_callbacks( body );

        // Nullify the body's user data

        body->SetUserData( 0 );

        // b2Bodies cannot be destroyed during callbacks. So, if an actor is
        // collected during a collision callback, for example, the call to destroy the
        // associated b2Body will fail. To get around this, we tell the
        // world to destroy the body later.

        if ( body->GetWorld()->IsLocked() )
        {
            world->destroy_body_later( body );
        }
        else
        {
            body->GetWorld()->DestroyBody( body );
        }

        body = 0;
    }

    g_assert( actor );

    if ( g_signal_handler_is_connected( G_OBJECT( actor ) , mapped_handler ) )
    {
        g_signal_handler_disconnect( G_OBJECT( actor ) , mapped_handler );
    }

    mapped_handler = 0;

    actor = 0;
}

//.............................................................................
// The b2Body may get destroyed when the world is destroyed...:)

void Body::body_destroyed( b2Body* body )
{
    tplog( "B2BODY BEING DESTROYED" );

    if ( Body* self = Body::get( body ) )
    {
        tplog( "CLEARING B2BODY %d : %p : b2body %p : actor %p" , self->handle , self , self->body , self->actor );

        if ( self->actor )
        {
            // This will end up calling destroy_actor_body below

            g_object_set_qdata( G_OBJECT( self->actor ) , get_actor_body_quark() , 0 );
        }
    }
}

//.............................................................................
// The actor is being destroyed - that means that the b2Body will be destroyed
// as well. This structure loses its body and actor members.

void Body::destroy_actor_body( Body* self )
{
    delete self;
}

//.............................................................................

Body* Body::get( ClutterActor* actor )
{
    return ! actor ? 0 : ( Body* ) g_object_get_qdata( G_OBJECT( actor ) , get_actor_body_quark() );
}

//.............................................................................

Body* Body::get( b2Body* body )
{
    return ! body ? 0 : ( Body* ) body->GetUserData();
}

//.............................................................................

Body* Body::get_from_lua( lua_State* L , int index )
{
    return get( CLUTTER_ACTOR( UserData::get( L , index )->get_master() ) );
}

//.............................................................................

void Body::synchronize_actor()
{
    if ( actor && body )
    {
        const b2Vec2& pos( body->GetPosition() );

        if ( world->z_for_y )
        {
            clutter_actor_set_x( actor , world->world_to_screen( pos.x ) );
            clutter_actor_set_depth( actor , - world->world_to_screen( pos.y ) );

            clutter_actor_set_rotation( actor , CLUTTER_Y_AXIS , World::radians_to_degrees( body->GetAngle() ) , 0 , 0 , 0 );
        }
        else
        {
            clutter_actor_set_position( actor , world->world_to_screen( pos.x ) , world->world_to_screen( pos.y ) );

            clutter_actor_set_rotation( actor , CLUTTER_Z_AXIS , World::radians_to_degrees( body->GetAngle() ) , 0 , 0 , 0 );
        }
    }
}

//.............................................................................

void Body::synchronize_actor( b2Body* body )
{
    if ( Body* b = Body::get( body ) )
    {
        b->synchronize_actor();
    }
}

//.............................................................................

void Body::synchronize_body()
{
    if ( actor && body )
    {
        gfloat x;
        gfloat y;
        float32 angle;

        if ( world->z_for_y )
        {
            x = clutter_actor_get_x( actor );
            y = -clutter_actor_get_depth( actor );
            angle = clutter_actor_get_rotation( actor , CLUTTER_Y_AXIS , 0 , 0 , 0 );
        }
        else
        {
            clutter_actor_get_position( actor , & x , & y );

            angle = clutter_actor_get_rotation( actor , CLUTTER_Z_AXIS , 0 , 0 , 0 );
        }

        x = world->screen_to_world( x );
        y = world->screen_to_world( y );

        angle = World::degrees_to_radians( angle );

        body->SetTransform( b2Vec2( x , y ) , angle );
    }
}

//.............................................................................

void Body::actor_mapped_notify( GObject* , GParamSpec* , Body* self )
{
    if ( self->actor && self->body )
    {
        bool mapped = CLUTTER_ACTOR_IS_MAPPED( self->actor );


        if ( !self->body->GetWorld()->IsLocked() )
        {
            self->body->SetActive( mapped );
        }
        else
        {
            if ( mapped )
            {
                self->world->activate_body_later( self->body );
            }
            else
            {
                self->world->deactivate_body_later( self->body );
            }
        }

        // The actor is back on the screen, we update the body's position

        if ( mapped )
        {
            self->synchronize_body();
        }
    }
}

//.............................................................................

AABBQuery::AABBQuery( lua_State* _LS )
    :
    L( _LS )
{
    lua_newtable( L );
}


bool AABBQuery::ReportFixture( b2Fixture* fixture )
{
    int fixture_handle = GPOINTER_TO_INT( fixture->GetUserData() );
    int body_handle = 0;

    if ( Body* body = Body::get( fixture->GetBody() ) )
    {
        body_handle = body->handle;
    }

    lua_pushinteger( L , body_handle );
    lua_rawseti( L , -2 , fixture_handle );

    return true;
}

}; // Physics
