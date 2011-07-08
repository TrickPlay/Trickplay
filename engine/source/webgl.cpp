
#include "webgl.h"

//=============================================================================

#define TP_LOG_DOMAIN   "WEBGL"
#define TP_LOG_ON       true
#define TP_LOG2_ON      true

#include "log.h"

//=============================================================================

namespace WebGL
{

//.............................................................................

TypedArray * get_valid_array( lua_State * L , int index , FreeLater & free_later , TypedArray::Type type , int multiple )
{
    TypedArray * array = 0;

    if ( lua_istable( L , index ) )
    {
        array = TypedArray::from_lua_table( L , index , type );
        free_later( array , TypedArray::destroy );
    }
    else
    {
        array = TypedArray::from_lua( L , index );
    }

    if ( ! array )
    {
        luaL_error( L , "Invalid argument. Expecting either a typed array or a lua table." );
        return 0;
    }

    if ( array->get_type() != type )
    {
        luaL_error( L , "Invalid type of array" );
        return 0;
    }

    if ( array->get_length() == 0 )
    {
        luaL_error( L , "Array must not be empty" );
        return 0;
    }

    if ( multiple > 1 && ( ( array->get_length() % multiple ) != 0 ) )
    {
        luaL_error( L , "Array must have multiple of %d length" , multiple );
        return 0;
    }

    return array;
}

//.............................................................................

int get_texel_size( GLenum format , GLenum type )
{
    if (type == GL_UNSIGNED_BYTE )
    {
        switch ( format )
        {
            case GL_ALPHA:
            case GL_LUMINANCE:
                return 1;
            case GL_LUMINANCE_ALPHA:
                return 2;
            case GL_RGB:
                return 3;
            case GL_RGBA:
                return 4;
        }
    }
    else
    {
        switch ( type )
        {
            case GL_UNSIGNED_SHORT_4_4_4_4:
            case GL_UNSIGNED_SHORT_5_5_5_1:

                if ( format == GL_RGBA )
                {
                    return 2;
                }
                break;

            case GL_UNSIGNED_SHORT_5_6_5:

                if ( format == GL_RGB )
                {
                    return 2;
                }
                break;
        }
    }

    return 0;
}

//.............................................................................

Context * Context::get( ClutterActor * actor , bool detach )
{
	g_assert( actor );

	static const gchar * key = "tp-webgl-context";

	static GQuark quark = 0;

	if ( ! quark )
	{
		quark = g_quark_from_static_string( key );
	}

	if ( detach )
	{
		g_object_set_qdata( G_OBJECT( actor ) , quark , NULL );
		return 0;
	}

	Context * context = ( Context * ) g_object_get_qdata( G_OBJECT( actor ) , quark );

	if ( ! context )
	{
		context = new Context( actor );

		g_object_set_qdata_full( G_OBJECT( actor ) , quark , context , ( GDestroyNotify ) destroy );
	}

	return context;
}

//.............................................................................

Context::Context( ClutterActor * actor )
:
	unpack_flip_y( false ),
    unpack_premultiply_alpha( false ),
    unpack_colorspace_conversion( GL_BROWSER_DEFAULT_WEBGL ),
    acquisitions( 0 ),
    before_stage_paint_handler( 0 ),
    texture( 0 ),
    texture_target( 0 ),
    framebuffer( 0 ),
    depthbuffer( 0 )

{
	g_assert( CLUTTER_IS_TEXTURE( actor ) );

	// Make sure we are in the clutter context

	context_op( SWITCH_TO_CLUTTER_CONTEXT );

	// Get the Clutter GL texture id and target

	CoglHandle th = clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) );

	if ( ! cogl_texture_get_gl_texture( th , & texture , & texture_target ) )
	{
		tpwarn( "FAILED TO GET GL TEXTURE HANDLE" );
	}

	// Now, create our context and switch to it

	context_op( CREATE_CONTEXT );

	context_op( SWITCH_TO_MY_CONTEXT );

	// Get the width and height of the actor

	gfloat width;
	gfloat height;

	clutter_actor_get_size( actor , & width , & height );

	// Create the depth buffer

	glGenRenderbuffers( 1 , & depthbuffer );

    glBindRenderbuffer( GL_RENDERBUFFER , depthbuffer );

    glRenderbufferStorage( GL_RENDERBUFFER , GL_DEPTH_COMPONENT16 , width , height );

    // Create the framebuffer

	glGenFramebuffers( 1 , & framebuffer );

    glBindFramebuffer( GL_FRAMEBUFFER , framebuffer );

    // Attach the depth buffer

    glFramebufferRenderbuffer( GL_FRAMEBUFFER , GL_DEPTH_ATTACHMENT , GL_RENDERBUFFER , depthbuffer );

    // Attach the texture as the color buffer

    glFramebufferTexture2D( GL_FRAMEBUFFER , GL_COLOR_ATTACHMENT0 , texture_target , texture , 0 );

    if ( GL_FRAMEBUFFER_COMPLETE != glCheckFramebufferStatus( GL_FRAMEBUFFER ) )
    {
        tpwarn( "FRAMEBUFFER IS NOT COMPLETE" );
    }
    else
    {
        tplog2( "FRAMEBUFFER IS READY" );
    }

    context_op( SWITCH_TO_CLUTTER_CONTEXT );
}

//.............................................................................

Context::~Context()
{
	context_op( SWITCH_TO_MY_CONTEXT );

	glBindFramebuffer( GL_FRAMEBUFFER , 0 );

	glDeleteFramebuffers( 1 , & framebuffer );

	glDeleteRenderbuffers( 1 , & depthbuffer );

	//.........................................................................
	// Delete all the user objects

	GLuintSet::const_iterator it;

	for ( it = user_buffers.begin(); it != user_buffers.end(); ++it )
	{
		tplog2( "DESTROYING USER BUFFER %u" , * it );
		glDeleteBuffers( 1 , & * it );
	}

	for ( it = user_framebuffers.begin(); it != user_framebuffers.end(); ++it )
	{
		tplog2( "DESTROYING USER FRAMEBUFFER %u" , * it );
		glDeleteFramebuffers( 1 , & * it );
	}

	for ( it = user_renderbuffers.begin(); it != user_renderbuffers.end(); ++it )
	{
		tplog2( "DESTROYING USER RENDERBUFFER %u" , * it );
		glDeleteRenderbuffers( 1 , & * it );
	}

	for ( it = user_textures.begin(); it != user_textures.end(); ++it )
	{
		tplog2( "DESTROYING USER TEXTURE %u" , * it );
		glDeleteTextures( 1 , & * it );
	}

	for ( it = user_programs.begin(); it != user_programs.end(); ++it )
	{
		tplog2( "DESTROYING USER PROGRAM %u" , * it );
		glDeleteProgram( * it );
	}

	for ( it = user_shaders.begin(); it != user_shaders.end(); ++it )
	{
		tplog2( "DESTROYING USER SHADER %u" , * it );
		glDeleteShader( * it );
	}


	//.........................................................................

	context_op( SWITCH_TO_CLUTTER_CONTEXT );

	context_op( DESTROY_MY_CONTEXT );

	tplog2( "CONTEXT DESTROYED" );
}

//.............................................................................

void Context::destroy( Context * context )
{
	delete context;
}

//.............................................................................

void Context::context_op( Context::Operation op )
{
#if defined(CLUTTER_WINDOWING_GLX)

    static ContextType		clutter_context = 0;
    static Display	*		clutter_display = 0;
    static GLXDrawable		clutter_drawable;

    if ( ! clutter_context )
    {
    	clutter_context = glXGetCurrentContext();
    	clutter_display = glXGetCurrentDisplay();
    	clutter_drawable = glXGetCurrentDrawable();
    }

    switch( op )
    {
		case SWITCH_TO_MY_CONTEXT:
		{
			glXMakeCurrent( clutter_display , clutter_drawable , my_context );
		    glBindFramebuffer( GL_FRAMEBUFFER , framebuffer );
			break;
		}

		case SWITCH_TO_CLUTTER_CONTEXT:
		{
			glXMakeCurrent( clutter_display , clutter_drawable , clutter_context );
			break;
		}

		case CREATE_CONTEXT:
		{
			XVisualInfo * vi = clutter_x11_get_visual_info();
			my_context = glXCreateContext( clutter_display , vi , clutter_context , glXIsDirect( clutter_display , clutter_context ) );
			if ( ! my_context )
			{
				tpwarn( "FAILED TO CREATE GLXCONTEXT" );
			}
//			before_stage_paint_handler = g_signal_connect( clutter_stage_get_default() , "paint" , ( GCallback ) before_stage_paint , this );

			break;
		}

		case DESTROY_MY_CONTEXT:
		{
			glXDestroyContext( clutter_display , my_context );
//			g_signal_handler_disconnect( clutter_stage_get_default() , before_stage_paint_handler );
			break;
		}
    }

#elif defined(CLUTTER_WINDOWING_EGL)

	static ContextType		clutter_context = EGL_NO_CONTEXT
	static EGLDisplay		clutter_display = EGL_DEFAULT_DISPLAY;
	static EGLSurface		surface = EGL_NO_SURFACE;

#error "NOT FINISHED YET"

#endif
}

//.............................................................................

void Context::before_stage_paint( ClutterActor * stage , Context * me )
{
	me->context_op( SWITCH_TO_CLUTTER_CONTEXT );
}

//.............................................................................

GLuint Context::create_buffer()
{
	GLuint n = 0;

	glGenBuffers( 1 , & n );

	if ( n )
	{
		user_buffers.insert( n );
	}

	return n;
}

//.............................................................................

GLuint Context::create_framebuffer()
{
	GLuint n = 0;

	glGenFramebuffers( 1 , & n );

	if ( n )
	{
		user_framebuffers.insert( n );
	}

	return n;
}

//.............................................................................

GLuint Context::create_renderbuffer()
{
	GLuint n = 0;

	glGenRenderbuffers( 1 , & n );

	if ( n )
	{
		user_renderbuffers.insert( n );
	}

	return n;
}

//.............................................................................

GLuint Context::create_texture()
{
	GLuint n = 0;

	glGenTextures( 1 , & n );

	if ( n )
	{
		user_textures.insert( n );
	}

	return n;
}

//.............................................................................

GLuint Context::create_program()
{
	GLuint n = glCreateProgram();

	if ( n )
	{
		user_programs.insert( n );
	}

	return n;
}

//.............................................................................

GLuint Context::create_shader( GLenum shader_type )
{
	GLuint n = glCreateShader( shader_type );

	if ( n )
	{
		user_shaders.insert( n );
	}

	return n;
}

//.............................................................................

void Context::delete_buffer( GLuint n )
{
	if ( user_buffers.erase( n ) )
	{
		glDeleteBuffers( 1 , & n );
	}
}

//.............................................................................

void Context::delete_framebuffer( GLuint n )
{
	if ( user_framebuffers.erase( n ) )
	{
		glDeleteFramebuffers( 1 , & n );
	}
}

//.............................................................................

void Context::delete_renderbuffer( GLuint n )
{
	if ( user_renderbuffers.erase( n ) )
	{
		glDeleteRenderbuffers( 1 , & n );
	}
}

//.............................................................................

void Context::delete_texture( GLuint n )
{
	if ( user_textures.erase( n ) )
	{
		glDeleteTextures( 1 , & n );
	}
}

//.............................................................................

void Context::delete_program( GLuint n )
{
	if ( user_programs.erase( n ) )
	{
		glDeleteProgram( n );
	}
}

//.............................................................................

void Context::delete_shader( GLuint n )
{
	if ( user_shaders.erase( n ) )
	{
		glDeleteShader( n );
	}
}

//.............................................................................


}

