#ifndef _TRICKPLAY_WEBGL_H
#define _TRICKPLAY_WEBGL_H

//-----------------------------------------------------------------------------

#define GL_GLEXT_PROTOTYPES

#include <clutter/clutter.h>

//-----------------------------------------------------------------------------

#if defined(CLUTTER_WINDOWING_GLX)

	#include <GL/glx.h>
	#include <clutter/x11/clutter-x11.h>

#elif defined(CLUTTER_WINDOWING_EGL)

	#include <EGL/egl.h>

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

	private:

		Context( ClutterActor * actor );

		virtual ~Context();

		static void destroy( Context * context );

#if defined(CLUTTER_WINDOWING_GLX)

	    typedef GLXContext ContextType;

#elif defined(CLUTTER_WINDOWING_EGL)

	    typedef EGLContext ContextType;

#else

#error "NOT FINISHED YET"

#endif

	    enum Operation { CREATE_CONTEXT , SWITCH_TO_CLUTTER_CONTEXT , SWITCH_TO_MY_CONTEXT , DESTROY_MY_CONTEXT };

	    void context_op( Operation op );

	    static void before_stage_paint( ClutterActor * stage , Context * me );

	    guint			acquisitions;

	    ContextType		my_context;

	    gulong			before_stage_paint_handler;

	    GLuint			texture;
		GLenum			texture_target;
	    GLuint          framebuffer;
	    GLuint          depthbuffer;

	    typedef std::set< GLuint> GLuintSet;

	    GLuintSet		user_buffers;
	    GLuintSet		user_framebuffers;
	    GLuintSet		user_renderbuffers;
	    GLuintSet		user_textures;
	    GLuintSet		user_programs;
	    GLuintSet		user_shaders;
	};

}

#endif // _TRICKPLAY_WEBGL_H
