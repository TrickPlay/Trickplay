#ifndef _TRICKPLAY_WEBGL_H
#define _TRICKPLAY_WEBGL_H

//-----------------------------------------------------------------------------

#define GL_GLEXT_PROTOTYPES

#include "tp-clutter.h"

//-----------------------------------------------------------------------------

#if defined(CLUTTER_WINDOWING_GLX)

	#include <GL/glx.h>
	#include <clutter/x11/clutter-x11.h>

#elif defined(CLUTTER_WINDOWING_EGL)

	#include <EGL/egl.h>
	#include <clutter/egl/clutter-egl.h>

#elif defined(CLUTTER_WINDOWING_OSX)

    #import <AppKit/AppKit.h>

#else

	#error "CANNOT BUILD WEBGL FOR THIS YET"

#endif

//=============================================================================

#define GL_UNPACK_FLIP_Y_WEBGL                  0x9240
#define GL_UNPACK_PREMULTIPLY_ALPHA_WEBGL       0x9241
#define GL_CONTEXT_LOST_WEBGL                   0x9242
#define GL_UNPACK_COLORSPACE_CONVERSION_WEBGL   0x9243
#define GL_BROWSER_DEFAULT_WEBGL                0x9244

//=============================================================================

#include "common.h"
#include "typed_array.h"

namespace WebGL
{
	//.........................................................................
	// Clamps a value

	inline GLclampf clamp( GLclampf value , GLclampf min , GLclampf max )
	{
		return value < min ? min : value > max ? max : value;
	}

	//.........................................................................
	// Gets a typed array from the Lua stack or converts a Lua table to a
	// typed array. Checks the type, length and length multiple.

	TypedArray * get_valid_array( lua_State * L , int index , FreeLater & free_later , TypedArray::Type type , int multiple );

	//.........................................................................
	// Returns the size of a texel given the format and type. Returns 0 if the
	// combination is not valid.

	int get_texel_size( GLenum format , GLenum type );

	//.........................................................................
	// Class that we bolt onto an actor. Maintains all of our GL state.

	class Context
	{
	public:

		static Context * get( ClutterActor * actor , bool detach = false );

		void acquire()
		{
			if ( ! acquisitions++ )
			{
				context_op( SWITCH_TO_MY_CONTEXT );
			}
		}

		void release()
		{
			if ( ! --acquisitions )
			{
				context_op( SWITCH_TO_CLUTTER_CONTEXT );
			}
		}

		inline bool is_current() const
		{
			return acquisitions != 0;
		}

		void bind_framebuffer( GLenum target , GLuint buffer )
		{
			if ( target != GL_FRAMEBUFFER )
			{
				return;
			}

			// When it is zero, we bind to our framebuffer, so
			// that drawing continues to happen to it

			if ( buffer == 0 )
			{
				glBindFramebuffer( target , framebuffer );
			}
			else if ( user_framebuffers.find( buffer ) != user_framebuffers.end() )
			{
				glBindFramebuffer( target , buffer );
			}
		}

		GLuint create_buffer();
		GLuint create_framebuffer();
		GLuint create_renderbuffer();
		GLuint create_texture();
		GLuint create_program();
		GLuint create_shader( GLenum shader_type );

		void delete_buffer( GLuint n );
		void delete_framebuffer( GLuint n );
		void delete_renderbuffer( GLuint n );
		void delete_texture( GLuint n );
		void delete_program( GLuint n );
		void delete_shader( GLuint n );

	    bool            unpack_flip_y;
	    bool            unpack_premultiply_alpha;
	    unsigned long   unpack_colorspace_conversion;
	    bool			have_depth;
	    bool			have_stencil;

	private:

		Context( ClutterActor * actor );

		virtual ~Context();

#if defined(CLUTTER_WINDOWING_GLX)

	    typedef GLXContext ContextType;

#elif defined(CLUTTER_WINDOWING_EGL)

	    typedef EGLContext ContextType;

#elif defined(CLUTTER_WINDOWING_OSX)

        typedef NSOpenGLContext *ContextType;

#else

#error "NOT FINISHED YET"

#endif

	    enum Operation { CREATE_CONTEXT , SWITCH_TO_CLUTTER_CONTEXT , SWITCH_TO_MY_CONTEXT , DESTROY_MY_CONTEXT };

	    void context_op( Operation op );

	    enum FBOTry { FBO_TRY_DEPTH_STENCIL = 0x01 , FBO_TRY_DEPTH = 0x02 , FBO_TRY_STENCIL = 0x04 };

	    bool try_create_fbo( GLsizei width , GLsizei height , int flags );

	    typedef std::set< GLuint> GLuintSet;

	    guint			acquisitions;

	    ContextType		my_context;

	    GLuint			texture;
		GLenum			texture_target;
	    GLuint          framebuffer;
	    GLuintSet       renderbuffers;

	    GLuintSet		user_buffers;
	    GLuintSet		user_framebuffers;
	    GLuintSet		user_renderbuffers;
	    GLuintSet		user_textures;
	    GLuintSet		user_programs;
	    GLuintSet		user_shaders;
	};

}

//=============================================================================
// webgl_canvas
//=============================================================================
/*
    We had to implement our own actor for one main reason: ClutterTexture
    assumes that textures are upside down and the WebGL FBO color buffer is
    not, so we created a new actor that is just like a texture but uses
    different texture coordinates.

    As a bonus, we get 2 additional things:

    1) The context is part of the new actor's private data structure and is
       therefore much cheaper to get on every call.

    2) The actor shows up as WebGLCanvas in /ui output.

*/

G_BEGIN_DECLS

#define TRICKPLAY_TYPE_WEBGL_CANVAS               (trickplay_webgl_canvas_get_type ())
#define TRICKPLAY_WEBGL_CANVAS(obj)               (G_TYPE_CHECK_INSTANCE_CAST ((obj), TRICKPLAY_TYPE_WEBGL_CANVAS, TrickplayWebGLCanvas))
#define TRICKPLAY_WEBGL_CANVAS_CLASS(klass)       (G_TYPE_CHECK_CLASS_CAST ((klass), TRICKPLAY_TYPE_WEBGL_CANVAS, TrickplayWebGLCanvasClass))
#define TRICKPLAY_IS_WEBGL_CANVAS(obj)            (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TRICKPLAY_TYPE_WEBGL_CANVAS))
#define TRICKPLAY_IS_WEBGL_CANVAS_CLASS(klass)    (G_TYPE_CHECK_CLASS_TYPE ((klass), TRICKPLAY_TYPE_WEBGL_CANVAS))
#define TRICKPLAY_WEBGL_CANVAS_GET_CLASS(obj)     (G_TYPE_INSTANCE_GET_CLASS ((obj), TRICKPLAY_TYPE_WEBGL_CANVAS, TrickplayWebGLCanvasClass))

typedef struct _TrickplayWebGLCanvas             TrickplayWebGLCanvas;
typedef struct _TrickplayWebGLCanvasClass        TrickplayWebGLCanvasClass;
typedef struct _TrickplayWebGLCanvasPrivate      TrickplayWebGLCanvasPrivate;

struct _TrickplayWebGLCanvas
{
	ClutterTexture parent_instance;
	TrickplayWebGLCanvasPrivate *priv;
};

struct _TrickplayWebGLCanvasClass
{
	ClutterTextureClass parent_class;
};

GType trickplay_webgl_canvas_get_type( void ) G_GNUC_CONST;

ClutterActor * trickplay_webgl_canvas_new();

G_END_DECLS

#endif // _TRICKPLAY_WEBGL_H
