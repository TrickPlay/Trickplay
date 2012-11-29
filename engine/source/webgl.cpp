
#include "webgl.h"

//=============================================================================

#define TP_LOG_DOMAIN   "WEBGL"
#define TP_LOG_ON       false
#define TP_LOG2_ON      false

#include "log.h"

//=============================================================================

#ifndef GL_STENCIL_INDEX8
#define GL_STENCIL_INDEX8       0x8D48
#endif
#ifndef GL_DEPTH_STENCIL
#define GL_DEPTH_STENCIL        0x84F9
#endif
#ifndef GL_STENCIL_ATTACHMENT
#define GL_STENCIL_ATTACHMENT	0x8D00
#endif
#ifndef GL_DEPTH_ATTACHMENT
#define GL_DEPTH_ATTACHMENT     0x8D00
#endif
#ifndef GL_DEPTH_COMPONENT16
#define GL_DEPTH_COMPONENT16    0x81A5
#endif

//=============================================================================
// webgl_canvas
//=============================================================================

G_DEFINE_TYPE (TrickplayWebGLCanvas,trickplay_webgl_canvas,CLUTTER_TYPE_TEXTURE);

#define TRICKPLAY_WEBGL_CANVAS_GET_PRIVATE(obj) (G_TYPE_INSTANCE_GET_PRIVATE ((obj), TRICKPLAY_TYPE_WEBGL_CANVAS, TrickplayWebGLCanvasPrivate))

//.............................................................................

struct _TrickplayWebGLCanvasPrivate
{
    WebGL::Context * context;
};

//.............................................................................
// Copied from ClutterTexture's paint, but using different texture coordinates.

static void trickplay_webgl_canvas_paint (ClutterActor *self)
{
  ClutterTexture *texture = CLUTTER_TEXTURE (self);
  guint8 paint_opacity = clutter_actor_get_paint_opacity (self);

  CoglMaterial * material = ( CoglMaterial * ) clutter_texture_get_cogl_material( texture );

  cogl_material_set_color4ub (material,
			      paint_opacity,
                              paint_opacity,
                              paint_opacity,
                              paint_opacity);

  cogl_set_source (material);

  ClutterActorBox box;

  clutter_actor_get_allocation_box (self, &box);

  cogl_rectangle_with_texture_coords ( 0 , 0 , box.x2 - box.x1 , box.y2 - box.y1 ,
			              0, 1, 1, 0);
}

//.............................................................................

static void trickplay_webgl_canvas_finalize (GObject *object)
{
  WebGL::Context::get( CLUTTER_ACTOR( object ) , true );

  G_OBJECT_CLASS (trickplay_webgl_canvas_parent_class)->finalize (object);
}

//.............................................................................

static void trickplay_webgl_canvas_class_init (TrickplayWebGLCanvasClass *klass)
{
  GObjectClass *gobject_class = G_OBJECT_CLASS (klass);
  ClutterActorClass *actor_class = CLUTTER_ACTOR_CLASS (klass);

  gobject_class->finalize     = trickplay_webgl_canvas_finalize;

  actor_class->paint        = trickplay_webgl_canvas_paint;

  g_type_class_add_private (gobject_class, sizeof (TrickplayWebGLCanvasPrivate));
}

//.............................................................................

static void trickplay_webgl_canvas_init (TrickplayWebGLCanvas *self)
{
  self->priv = TRICKPLAY_WEBGL_CANVAS_GET_PRIVATE (self);
}

//.............................................................................

ClutterActor * trickplay_webgl_canvas_new ()
{
  return CLUTTER_ACTOR( g_object_new (TRICKPLAY_TYPE_WEBGL_CANVAS,NULL) );
}

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
    g_assert( TRICKPLAY_IS_WEBGL_CANVAS( actor ) );

    TrickplayWebGLCanvasPrivate * priv = TRICKPLAY_WEBGL_CANVAS( actor )->priv;

    if ( detach )
    {
        if ( priv->context )
        {
            delete priv->context;
            priv->context = 0;
        }

        return 0;
    }

    if ( ! priv->context )
    {
        priv->context = new WebGL::Context( actor );
    }

    return priv->context;
}

//.............................................................................

Context::Context( ClutterActor * actor )
:
	unpack_flip_y( false ),
    unpack_premultiply_alpha( false ),
    unpack_colorspace_conversion( GL_BROWSER_DEFAULT_WEBGL ),
    have_depth( false ),
    have_stencil( false ),
    acquisitions( 0 ),
    texture( 0 ),
    texture_target( 0 ),
    framebuffer( 0 )
{
	g_assert( CLUTTER_IS_TEXTURE( actor ) );

	// Make sure we are in the clutter context

	context_op( SWITCH_TO_CLUTTER_CONTEXT );

	// Get the Clutter GL texture id and target

#ifdef CLUTTER_VERSION_1_10

    CoglTexture * th = COGL_TEXTURE( clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) ) );

#else

    CoglHandle th = clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor ) );

#endif

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

	// Try to create the frame buffer in different ways until one
	// succeeds (or all fail).

	const int try_flags[] =
	{

#if defined(CLUTTER_WINDOWING_GLX) || defined(CLUTTER_WINDOWING_OSX)

        FBO_TRY_DEPTH_STENCIL ,

#endif
        FBO_TRY_DEPTH | FBO_TRY_STENCIL ,
        FBO_TRY_DEPTH ,
        FBO_TRY_STENCIL ,
        0
	};

	for ( size_t i = 0; i < sizeof( try_flags ) / sizeof( int ); ++i )
	{
		if ( try_create_fbo( width , height , try_flags[ i ] ) )
		{
			break;
		}
	}

	if ( ! framebuffer )
	{
		tpwarn( "UNABLE TO CREATE FRAMEBUFFER" );
	}
	else
	{
		tplog2( "FRAMEBUFFER READY : DEPTH = %s : STENCIL = %s" , have_depth ? "YES" : "NO" , have_stencil ? "YES" : "NO" );
	}

    context_op( SWITCH_TO_CLUTTER_CONTEXT );
}

//.............................................................................

Context::~Context()
{
	context_op( SWITCH_TO_MY_CONTEXT );

	glBindFramebuffer( GL_FRAMEBUFFER , 0 );

	tplog2( "DESTROYING FRAMEBUFFER %u" , framebuffer );
	glDeleteFramebuffers( 1 , & framebuffer );

	GLuintSet::const_iterator it;

	for ( it = renderbuffers.begin(); it != renderbuffers.end(); ++it )
	{
		tplog2( "DESTROYING RENDERBUFFER %u" , * it );
		glDeleteBuffers( 1 , & * it );
	}

	//.........................................................................
	// Delete all the user objects

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
// I copied this idea from Cogl.

bool Context::try_create_fbo( GLsizei width , GLsizei height , int flags )
{
	tplog2( "CREATING FRAMEBUFFER" );

	GLuint 		fbo;
	GLuintSet 	rb;

	bool h_depth = false;
	bool h_stencil = false;

	glGenFramebuffers( 1 , & fbo );

	glBindFramebuffer( GL_FRAMEBUFFER , fbo );

	glFramebufferTexture2D( GL_FRAMEBUFFER , GL_COLOR_ATTACHMENT0 , texture_target , texture , 0 );

	if ( flags & FBO_TRY_DEPTH_STENCIL )
	{
		tplog2( "  CREATING DEPTH/STENCIL RENDERBUFFERS" );

		GLuint depth_stencil_rb;

		glGenRenderbuffers( 1 , & depth_stencil_rb );
		glBindRenderbuffer( GL_RENDERBUFFER , depth_stencil_rb );
		glRenderbufferStorage( GL_RENDERBUFFER , GL_DEPTH_STENCIL , width , height );
		glBindRenderbuffer( GL_RENDERBUFFER , 0 );
	    glFramebufferRenderbuffer( GL_FRAMEBUFFER , GL_STENCIL_ATTACHMENT , GL_RENDERBUFFER, depth_stencil_rb );
	    glFramebufferRenderbuffer( GL_FRAMEBUFFER , GL_DEPTH_ATTACHMENT , GL_RENDERBUFFER , depth_stencil_rb );

	    rb.insert( depth_stencil_rb );

	    h_depth = true;
	    h_stencil = true;
	}

	if ( flags & FBO_TRY_DEPTH )
	{
		tplog2( "  CREATING DEPTH RENDERBUFFER" );

		GLuint depth_rb;

		glGenRenderbuffers( 1 , & depth_rb );
	    glBindRenderbuffer( GL_RENDERBUFFER , depth_rb );
	    glRenderbufferStorage( GL_RENDERBUFFER , GL_DEPTH_COMPONENT16 , width , height );
	    glBindRenderbuffer( GL_RENDERBUFFER , 0 );
	    glFramebufferRenderbuffer( GL_FRAMEBUFFER , GL_DEPTH_ATTACHMENT , GL_RENDERBUFFER , depth_rb );

	    rb.insert( depth_rb );

	    h_depth = true;
	}

	if ( flags & FBO_TRY_STENCIL )
	{
		tplog2( "  CREATING STENCIL RENDERBUFFER" );

		GLuint stencil_rb;

	    glGenRenderbuffers( 1 , & stencil_rb );
	    glBindRenderbuffer( GL_RENDERBUFFER , stencil_rb );
	    glRenderbufferStorage( GL_RENDERBUFFER , GL_STENCIL_INDEX8 , width , height );
	    glBindRenderbuffer( GL_RENDERBUFFER , 0 );
	    glFramebufferRenderbuffer( GL_FRAMEBUFFER , GL_STENCIL_ATTACHMENT , GL_RENDERBUFFER , stencil_rb );

	    rb.insert( stencil_rb );

	    h_stencil = true;
	}

	if ( GL_FRAMEBUFFER_COMPLETE != glCheckFramebufferStatus( GL_FRAMEBUFFER ) )
	{
		glBindFramebuffer( GL_FRAMEBUFFER , 0 );

		tplog2( "  DESTROYING FRAMEBUFFER %u" , fbo );
		glDeleteFramebuffers( 1 , & fbo );

		for ( GLuintSet::const_iterator it = rb.begin(); it != rb.end(); ++it )
		{
			tplog2( "  DESTROYING RENDERBUFFER %u" , *it );
			glDeleteRenderbuffers( 1 , & * it );
		}

		tplog2( "* FRAMEBUFFER IS NOT COMPLETE" );

		return false;
	}

	tplog2( "* FRAMEBUFFER IS COMPLETE" );

	framebuffer = fbo;
	renderbuffers.insert( rb.begin() , rb.end() );
	have_depth = h_depth;
	have_stencil = h_stencil;

	return true;
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
			break;
		}

		case DESTROY_MY_CONTEXT:
		{
			glXDestroyContext( clutter_display , my_context );
			break;
		}
    }

#elif defined(CLUTTER_WINDOWING_EGL)


	static ContextType		clutter_context = EGL_NO_CONTEXT;
	static EGLDisplay		clutter_display = EGL_DEFAULT_DISPLAY;
	static EGLSurface		clutter_read_surface = EGL_NO_SURFACE;
	static EGLSurface		clutter_draw_surface = EGL_NO_SURFACE;

    if ( clutter_context == EGL_NO_CONTEXT )
    {
    	clutter_context = eglGetCurrentContext();
    	clutter_display = eglGetCurrentDisplay();
    	clutter_read_surface = eglGetCurrentSurface(EGL_READ);
    	clutter_draw_surface = eglGetCurrentSurface(EGL_DRAW);
    }

    switch( op )
    {
		case SWITCH_TO_MY_CONTEXT:
		{
			eglMakeCurrent( clutter_display , clutter_draw_surface , clutter_read_surface , my_context );
		    glBindFramebuffer( GL_FRAMEBUFFER , framebuffer );
			break;
		}

		case SWITCH_TO_CLUTTER_CONTEXT:
		{
			eglMakeCurrent( clutter_display , clutter_draw_surface , clutter_read_surface , clutter_context );
			break;
		}

		case CREATE_CONTEXT:
		{
          EGLint cfg_attribs[] = {
              EGL_STENCIL_SIZE,    2,

              EGL_RED_SIZE,        1,
              EGL_GREEN_SIZE,      1,
              EGL_BLUE_SIZE,       1,
              EGL_ALPHA_SIZE,      1,

              EGL_DEPTH_SIZE,      1,

              EGL_BUFFER_SIZE,     EGL_DONT_CARE,

              EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,

              EGL_SURFACE_TYPE,    EGL_WINDOW_BIT,

              EGL_NONE
          };
          EGLint config_count = 0;
          EGLConfig config;

          const EGLint attribs[] = { EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE };

          EGLBoolean status = eglChooseConfig (clutter_display,
                                    cfg_attribs,
                                    &config, 1,
                                    &config_count);
          if (status != EGL_TRUE || config_count == 0)
            {
              tpwarn("UNABLE TO FIND A USABLE EGL CONFIGURATION");
              break;
            }

			my_context = eglCreateContext( clutter_display , config , clutter_context , attribs );

			if ( my_context == EGL_NO_CONTEXT )
			{
				tpwarn( "FAILED TO CREATE EGL CONTEXT" );
			}
			break;
		}

		case DESTROY_MY_CONTEXT:
		{
			eglDestroyContext( clutter_display , my_context );
			break;
		}
    }

#elif defined(CLUTTER_WINDOWING_OSX)

    static ContextType  clutter_context = 0;

    if ( clutter_context == 0 )
    {
        clutter_context = [NSOpenGLContext currentContext];
    }

    switch( op )
    {
		case SWITCH_TO_MY_CONTEXT:
		{
		    [my_context makeCurrentContext];
		    glBindFramebuffer( GL_FRAMEBUFFER , framebuffer );
		    break;
		}

		case SWITCH_TO_CLUTTER_CONTEXT:
        {
            glFlush();
            [clutter_context makeCurrentContext];
            break;
        }

		case CREATE_CONTEXT:
		{
            NSOpenGLPixelFormatAttribute attrs[] = {
                NSOpenGLPFADepthSize, 24,
                NSOpenGLPFAStencilSize, 8,
                0
            };

            NSOpenGLPixelFormat *pf =  [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];

            my_context = [[NSOpenGLContext alloc] initWithFormat:pf shareContext: clutter_context];

            [pf release];
            break;
		}

		case DESTROY_MY_CONTEXT:
		{
            [my_context release];
            my_context = 0;
		    break;
		}
    }

#else

    #error "This is not implemented"

#endif
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



