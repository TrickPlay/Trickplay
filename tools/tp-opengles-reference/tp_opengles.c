#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>

#include <EGL/egl.h>
#include <GLES2/gl2.h>

#include "tp_opengles.h"
#include "esutil.h"

/*****************************************************************************/

#define CHECKER_BOARD_IMAGE_WIDTH   64
#define CHECKER_BOARD_IMAGE_HEIGHT  CHECKER_BOARD_IMAGE_WIDTH

/*****************************************************************************/

typedef struct
{
    EGLint      width;
    EGLint      height;

    ESMatrix    projection_matrix;
    ESMatrix    modelview_matrix;
    ESMatrix    mvp_matrix;

    GLint       mvp_matrix_loc;
    GLint       position_loc;
    GLint       texture_coordinate_loc;
    GLint       sampler_loc;

    GLuint      texture;

    GLint       program;

    GLuint      vbo[2];

    GLsizei     number_of_elements;

} ApplicationContext;

/*****************************************************************************/
static void pretty_print_string_attrib( const char* a_name, const char* a_val )
{
    fprintf( stdout, "%-36s%s\n", a_name, a_val );
}

/*****************************************************************************/
static void pretty_print_int_attrib( const char* a_name, int a_val )
{
    fprintf( stdout, "%-36s%d\n", a_name, a_val );
}

/*****************************************************************************/
static void pretty_print_boolean_attrib( const char* a_name, int a_val )
{
    fprintf( stdout, "%-36s%s\n", a_name, a_val ? "TRUE" : "FALSE" );
}

/*****************************************************************************/

static void print_gl_properties( void )
{
    GLboolean shaderCompiler;
    GLint numBinaryFormats;
    GLint maxVertexUniformVectors;
    GLint maxFragmentUniformVectors;
    GLint maxVertexAttribs;
    GLint maxCombinedTextureImageUnits;
    GLint maxCubeMapTextureSize;
    GLint maxVertexTextureImageUnits;
    GLint maxRenderBufferSize;
    GLint maxTextureImageUnits;
    GLint maxTextureSize;
    GLint maxVaryingVectors;
    GLint maxViewPortDimensions[2];
    char allextensions[1024];
    char dimensions_str[32];
    char* pch;
    int is_first_iteration = 1;

    /* Print some OpenGL vendor information */

    pretty_print_string_attrib( "GL_VERSION", ( const char* ) glGetString( GL_VERSION ) );
    pretty_print_string_attrib( "GL_VENDOR", ( const char* )glGetString( GL_VENDOR ) );
    pretty_print_string_attrib( "GL_RENDERER", ( const char* )glGetString( GL_RENDERER ) );
    pretty_print_string_attrib( "GL_SHADING_LANGUAGE_VERSION", ( const char* )glGetString( GL_SHADING_LANGUAGE_VERSION ) );
    strncpy( allextensions, ( const char* )glGetString( GL_EXTENSIONS ), 1023 );
    allextensions[1023] = '\0';
    pch = strtok( allextensions, " " );

    while ( pch != NULL )
    {
        if ( is_first_iteration )
        {
            pretty_print_string_attrib( "GL_EXTENSIONS", pch );
            is_first_iteration = 0;
        }
        else
        {
            pretty_print_string_attrib( " ", pch );
        }

        pch = strtok( NULL, " " );
    }


    /* Determine if a shader compiler is available */
    glGetBooleanv( GL_SHADER_COMPILER, &shaderCompiler );
    pretty_print_boolean_attrib( "GL_SHADER_COMPILER", shaderCompiler );
    /* Determine binary formats available */
    glGetIntegerv( GL_NUM_SHADER_BINARY_FORMATS, &numBinaryFormats );
    pretty_print_int_attrib( "GL_NUM_SHADER_BINARY_FORMATS", numBinaryFormats );

    glGetIntegerv( GL_MAX_VERTEX_UNIFORM_VECTORS, &maxVertexUniformVectors );
    pretty_print_int_attrib( "GL_MAX_VERTEX_UNIFORM_VECTORS", maxVertexUniformVectors );
    glGetIntegerv( GL_MAX_VERTEX_ATTRIBS, &maxVertexAttribs );
    pretty_print_int_attrib( "GL_MAX_VERTEX_ATTRIBS", maxVertexAttribs );

    glGetIntegerv( GL_MAX_FRAGMENT_UNIFORM_VECTORS, &maxFragmentUniformVectors );
    pretty_print_int_attrib( "GL_MAX_FRAGMENT_UNIFORM_VECTORS", maxFragmentUniformVectors );

    glGetIntegerv( GL_MAX_VARYING_VECTORS, &maxVaryingVectors );
    pretty_print_int_attrib( "GL_MAX_VARYING_VECTORS", maxVaryingVectors );

    glGetIntegerv( GL_MAX_TEXTURE_IMAGE_UNITS, &maxTextureImageUnits );
    pretty_print_int_attrib( "GL_MAX_TEXTURE_IMAGE_UNITS", maxTextureImageUnits );
    glGetIntegerv( GL_MAX_TEXTURE_SIZE, &maxTextureSize );
    pretty_print_int_attrib( "GL_MAX_TEXTURE_SIZE", maxTextureSize );
    glGetIntegerv( GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &maxCombinedTextureImageUnits );
    pretty_print_int_attrib( "GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS", maxCombinedTextureImageUnits );
    glGetIntegerv( GL_MAX_CUBE_MAP_TEXTURE_SIZE, &maxCubeMapTextureSize );
    pretty_print_int_attrib( "GL_MAX_CUBE_MAP_TEXTURE_SIZE", maxCubeMapTextureSize );
    glGetIntegerv( GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS, &maxVertexTextureImageUnits );
    pretty_print_int_attrib( "GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS", maxVertexTextureImageUnits );

    glGetIntegerv( GL_MAX_RENDERBUFFER_SIZE, &maxRenderBufferSize );
    pretty_print_int_attrib( "GL_MAX_RENDERBUFFER_SIZE", maxRenderBufferSize );

    glGetIntegerv( GL_MAX_VIEWPORT_DIMS, maxViewPortDimensions );
    sprintf( dimensions_str, "%dx%d", maxViewPortDimensions[0], maxViewPortDimensions[1] );
    pretty_print_string_attrib( "GL_MAX_VIEWPORT_DIMS", dimensions_str );
}

/*****************************************************************************/

static GLuint load_shader( GLenum shaderType, const char* shaderSrc )
{
    GLuint shader;
    GLint compiled;

    shader = glCreateShader( shaderType );

    if ( shader == 0 )
    {
        return 0;
    }

    glShaderSource( shader, 1, &shaderSrc, NULL );

    glCompileShader( shader );

    glGetShaderiv( shader, GL_COMPILE_STATUS, &compiled );

    if ( !compiled )
    {
        GLint infoLen = 0;
        glGetShaderiv( shader, GL_INFO_LOG_LENGTH, &infoLen );

        if ( infoLen > 1 )
        {
            char* infoLog = ( char* ) malloc( sizeof( char ) * infoLen );
            glGetShaderInfoLog( shader, infoLen, NULL, infoLog );
            fprintf( stderr, "Error compiling shader:\n%s\n", infoLog );
            free( infoLog );
        }
        else
        {
            fprintf( stderr, "Unknown error during %s shader compilation\n",
                    shaderType == GL_VERTEX_SHADER ? "VERTEX" : "FRAGMENT" );
        }

        glDeleteShader( shader );
        return 0;
    }

    return shader;
}

/*****************************************************************************/

static int init_gl_state( ApplicationContext* app_context )
{
    /* The shaders */
    const char* vShaderStr =

            "uniform mat4   u_mvpMatrix;               \n"
            "attribute vec4 a_position;                \n"
            "attribute vec2 a_texCoord;                \n"
            "varying vec2   v_texCoord;                \n"
            "                                          \n"
            "void main()                               \n"
            "{                                         \n"
            "  gl_Position = u_mvpMatrix * a_position; \n"
            "  v_texCoord = a_texCoord;                \n"
            "}                                         \n";

    const char* fShaderStr_highp =

            "precision highp float;                             \n"
            "varying vec2 v_texCoord;                           \n"
            "uniform sampler2D s_texture;                       \n"
            "                                                   \n"
            "void main()                                        \n"
            "{                                                  \n"
            "  gl_FragColor = texture2D(s_texture, v_texCoord); \n"
            "}                                                  \n";

    const char* fShaderStr_mediump =

            "precision mediump float;                           \n"
            "varying vec2 v_texCoord;                           \n"
            "uniform sampler2D s_texture;                       \n"
            "                                                   \n"
            "void main()                                        \n"
            "{                                                  \n"
            "  gl_FragColor = texture2D(s_texture, v_texCoord); \n"
            "}                                                  \n";

    GLuint v;
    GLuint f;
    GLint linked;

    GLubyte checker_board_image[CHECKER_BOARD_IMAGE_HEIGHT][CHECKER_BOARD_IMAGE_WIDTH][4];
    int i;
    int j;
    int c;

    const GLfloat checker_board[] =
    {
        -1.0f , -1.0f , 0.0f , 0.0f , 0.0f ,
        -1.0f ,  1.0f , 0.0f , 0.0f , 1.0f ,
        1.0f ,  1.0f , 0.0f , 1.0f , 1.0f ,
        1.0f , -1.0f , 0.0f , 1.0f , 0.0f
    };

    const GLushort checker_board_idx[] =
    {
        1 , 0 , 2 , 3
    };

    glClearDepthf( 1.0f );
    glClearColor( 0.0f, 0.0f, 0.0f, 0.0f ); /* Black transparent background */

    glEnable( GL_DEPTH_TEST );
    glEnable( GL_CULL_FACE );

    glGenBuffers( 2, app_context->vbo );
    glBindBuffer( GL_ARRAY_BUFFER, app_context->vbo[0] );
    glBufferData( GL_ARRAY_BUFFER, sizeof( checker_board ), checker_board, GL_STATIC_DRAW );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, app_context->vbo[1] );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof( checker_board_idx ), checker_board_idx, GL_STATIC_DRAW );
    app_context->number_of_elements = sizeof( checker_board_idx ) / sizeof( GLushort );

    v = load_shader( GL_VERTEX_SHADER, vShaderStr );

    if ( !v )
    {
        return 0;
    }

    fprintf( stdout, "Vertex shader compilation successful\n" );

    f = load_shader( GL_FRAGMENT_SHADER, fShaderStr_highp );

    if ( !f )
    {
        fprintf( stderr, "Failed to load Fragment Shader that uses highp precision. Trying mediump\n" );

        f = load_shader( GL_FRAGMENT_SHADER, fShaderStr_mediump );

        if ( !f )
        {
            glDeleteShader( v );
            return 0;
        }
    }

    fprintf( stdout, "Fragment shader compilation successful\n" );

    app_context->program = glCreateProgram();
    glAttachShader( app_context->program, v );
    glAttachShader( app_context->program, f );

    glLinkProgram( app_context->program );

    glGetProgramiv( app_context->program, GL_LINK_STATUS, &linked );

    if ( !linked )
    {
        GLint infoLen = 0;
        glGetProgramiv( app_context->program, GL_INFO_LOG_LENGTH, &infoLen );

        if ( infoLen > 1 )
        {
            char* infoLog = ( char* ) malloc( sizeof( char ) * infoLen );
            glGetProgramInfoLog( app_context->program, infoLen, NULL, infoLog );
            fprintf( stderr, "Error linking program:\n%s\n", infoLog );
            free( infoLog );
        }
        else
        {
            fprintf( stderr, "Failed to link program, no log\n" );
        }

        glDeleteShader( f );
        glDeleteShader( v );
        glDeleteProgram( app_context->program );
        return 0;
    }

    fprintf( stdout, "Linking compiled vertex and fragment shaders successful. Created program object\n" );

    app_context->position_loc = glGetAttribLocation( app_context->program, "a_position" );
    app_context->texture_coordinate_loc = glGetAttribLocation( app_context->program, "a_texCoord" );

    app_context->sampler_loc = glGetUniformLocation( app_context->program, "s_texture" );
    app_context->mvp_matrix_loc = glGetUniformLocation( app_context->program, "u_mvpMatrix" );

    esMatrixLoadIdentity( &app_context->projection_matrix );
    esMatrixLoadIdentity( &app_context->modelview_matrix );
    esMatrixLoadIdentity( &app_context->mvp_matrix );

    glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );

    glGenTextures( 1, &app_context->texture );

    glBindTexture( GL_TEXTURE_2D, app_context->texture );

    /* create an image for checker board */

    for ( i = 0; i < CHECKER_BOARD_IMAGE_HEIGHT; ++i )
    {
        for ( j = 0; j < CHECKER_BOARD_IMAGE_WIDTH; ++j )
        {
            c = ( ( ( i & 0x8 ) == 0 ) ^ ( ( j & 0x8 ) == 0 ) ) * 255;
            checker_board_image[i][j][0] = ( GLubyte )( c | 255 );
            checker_board_image[i][j][1] = ( GLubyte ) c;
            checker_board_image[i][j][2] = ( GLubyte )( c & 255 );
            checker_board_image[i][j][3] = ( GLubyte )( c & 255 );
        }
    }

    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );

    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, CHECKER_BOARD_IMAGE_WIDTH, CHECKER_BOARD_IMAGE_HEIGHT,
            0, GL_RGBA, GL_UNSIGNED_BYTE, checker_board_image );

    glViewport( 0, 0, app_context->width, app_context->height );

    esPerspective( &app_context->projection_matrix, 45.0f, ( float )app_context->width / ( float )app_context->height, 1, 30 );

    esMatrixLoadIdentity( &app_context->modelview_matrix );
    esTranslate( &app_context->modelview_matrix, 0, 0, -3.6 );

    return 1;
}

/*****************************************************************************/

static void terminate_gl_state( ApplicationContext* app_context )
{
    glDeleteTextures( 1, &app_context->texture );
    glDeleteProgram( app_context->program );
    glDeleteBuffers( 2, app_context->vbo );
}

/*****************************************************************************/

static void display( ApplicationContext* app_context )
{
    esMatrixMultiply( &app_context->mvp_matrix, &app_context->modelview_matrix, &app_context->projection_matrix );

    glUniformMatrix4fv( app_context->mvp_matrix_loc, 1, GL_FALSE, ( GLfloat* )&app_context->mvp_matrix.m[0][0] );

    glClear( GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    glUseProgram( app_context->program );

    glBindBuffer( GL_ARRAY_BUFFER, app_context->vbo[0] );
    glVertexAttribPointer( app_context->position_loc, 3, GL_FLOAT, GL_FALSE, 5 * sizeof( GLfloat ), 0 );

    glVertexAttribPointer( app_context->texture_coordinate_loc, 2, GL_FLOAT, GL_FALSE, 5 * sizeof( GLfloat ), ( const GLvoid* )( 3 * sizeof( GLfloat ) ) );

    glEnableVertexAttribArray( app_context->position_loc );
    glEnableVertexAttribArray( app_context->texture_coordinate_loc );

    glActiveTexture( GL_TEXTURE0 );
    glBindTexture( GL_TEXTURE_2D, app_context->texture );

    glUniform1i( app_context->sampler_loc, 0 );

    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, app_context->vbo[1] );

    glDrawElements( GL_TRIANGLE_STRIP, app_context->number_of_elements, GL_UNSIGNED_SHORT, ( const GLvoid* )0 );

    eglSwapBuffers( eglGetCurrentDisplay(), eglGetCurrentSurface( EGL_READ ) );
}

/*****************************************************************************/

static int init_egl( ApplicationContext* app_context, EGLNativeDisplayType display_type, EGLNativeWindowType egl_win )
{
    EGLDisplay egl_display      = 0;
    EGLSurface egl_surface      = 0;
    EGLContext egl_context      = 0;
    EGLConfig  egl_config;
    EGLint     major_version;
    EGLint     minor_version;
    int        config_count;
    const char *extensions;

    extensions = eglQueryString(egl_display, EGL_EXTENSIONS);
    if(extensions)
    {
        fprintf(stderr, "EGL Extensions: %s\n", extensions);
    } else {
        fprintf(stderr, "No EGL Extensions found\n");
    }


    egl_display = eglGetDisplay( display_type );

    if ( EGL_NO_DISPLAY == egl_display )
    {
        fprintf( stderr, "eglGetDisplay() failed\n" );
        return 0;
    }

    fprintf( stdout, "eglGetDisplay() successful\n" );

    if ( EGL_FALSE == eglInitialize( egl_display, &major_version, &minor_version ) )
    {
        fprintf( stderr, "eglInitialize() failed\n" );
        return 0;
    }

    fprintf( stdout, "eglInitialize() successful\n" );

    fprintf( stdout, "EGL version info: major=%d minor=%d\n", major_version, minor_version );

    if ( EGL_FALSE == eglGetConfigs( egl_display, NULL, 0, &config_count ) )
    {
        fprintf( stderr, "eglGetConfigs() failed\n" );
        return 0;
    }

    fprintf( stdout, "eglGetConfigs() successful. Supported configs=%d\n", config_count );

    EGLint  cfg_attribs[] =
    {
        /* NB: This must be the first attribute, since we may
         * try and fallback to no stencil buffer */
        EGL_STENCIL_SIZE,    0,
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

    if ( EGL_FALSE == eglChooseConfig( egl_display, cfg_attribs, &egl_config, 1, &config_count ) || ( config_count == 0 ) )
    {
        fprintf( stderr, "eglChooseConfig() failed\n" );
        return 0;
    }

    fprintf( stdout, "eglChooseConfig() successful.\n" );

    EGLint red_size;
    EGLint green_size;
    EGLint blue_size;
    EGLint alpha_size;
    EGLint depth_size;

    eglGetConfigAttrib( egl_display, egl_config, EGL_RED_SIZE,   &red_size );
    eglGetConfigAttrib( egl_display, egl_config, EGL_GREEN_SIZE, &green_size );
    eglGetConfigAttrib( egl_display, egl_config, EGL_BLUE_SIZE,  &blue_size );
    eglGetConfigAttrib( egl_display, egl_config, EGL_ALPHA_SIZE, &alpha_size );
    eglGetConfigAttrib( egl_display, egl_config, EGL_DEPTH_SIZE, &depth_size );

    fprintf( stdout, "Selected config: R=%d G=%d B=%d A=%d Depth=%d\n",
            red_size, green_size, blue_size, alpha_size, depth_size );

    egl_surface = eglCreateWindowSurface( egl_display, egl_config, egl_win, NULL );

    if ( EGL_NO_SURFACE == egl_surface )
    {
        fprintf( stderr, "eglCreateWindowSurface() failed\n" );
        return 0;
    }

    fprintf( stdout, "eglCreateWindowSurface() successful\n" );

    eglQuerySurface( egl_display, egl_surface, EGL_WIDTH, &app_context->width );
    eglQuerySurface( egl_display, egl_surface, EGL_HEIGHT, &app_context->height );

    fprintf( stdout, "EGL surface is %dx%d\n", app_context->width, app_context->height );

    if ( app_context->width <= 0 || app_context->width > 1920 )
    {
        fprintf( stderr, "Unsupported value for surface width=%d\n", app_context->width );
        return 0;
    }

    if ( app_context->height <= 0 || app_context->height > 1080 )
    {
        fprintf( stderr, "Unsupported value for surface height=%d\n", app_context->height );
        return 0;
    }

    EGLint ctx_attrib_list[3] =
    {
        EGL_CONTEXT_CLIENT_VERSION , 2 ,
        EGL_NONE
    };

    egl_context = eglCreateContext( egl_display, egl_config, EGL_NO_CONTEXT, ctx_attrib_list );

    if ( EGL_NO_CONTEXT == egl_context )
    {
        fprintf( stderr, "eglCreateContext() failed" );
        return 0;
    }

    fprintf( stdout, "eglCreateContext() successful\n" );

    if ( EGL_FALSE == eglMakeCurrent( egl_display, egl_surface, egl_surface, egl_context ) )
    {
        fprintf( stderr, "eglMakeCurrent() failed\n" );
        return 0;
    }

    fprintf( stdout, "eglMakeCurrent() successful\n" );

    if ( EGL_FALSE == eglSwapInterval( egl_display, 1 ) )
    {
        fprintf( stderr, "eglSwapInterval() failed\n" );
        return 0;
    }

    fprintf( stdout, "eglSwapInternal() successful\n" );

    return 1;
}

/*****************************************************************************/
static int running = 1;

static void
signal_int(int signum)
{
    running = 0;
}


int main( int argc, char** argv )
{
    struct sigaction sigint;

    EGLNativeDisplayType display_type  = EGL_DEFAULT_DISPLAY;
    EGLNativeWindowType  native_window = 0;

    EGLDisplay eglDisplay;

    int frame_count = 0;
    int max_frames;

    ApplicationContext app_context;

    if ( argc >= 2 )
    {
        max_frames = atoi( argv[1] );
    }
    else if ( argc == 1 )
    {
        max_frames = 10000;
    }
    else
    {
        fprintf( stdout, "Usage is:\n\t%s [max_frames]\n", argv[0] );
        fprintf( stdout, "\twhere\n" );
        fprintf( stdout, "\t'max_frames' is the maximum number of frames to show before terminating\n" );
        fprintf( stdout, "\tDefault value for 'max_frames' is 10000. Setting 'max_frames' to 0 will cause the program to run forever\n" );
        return 1;
    }

    memset( &app_context, 0, sizeof( ApplicationContext ) );

    /* Call the custom pre-initialization function */

    if ( 0 != tp_pre_egl_initialize( &display_type, &native_window ) )
    {
        fprintf( stderr, "tp_pre_egl_initializate() failed. fatal error\n" );
        return 2;
    }

    /* Initialise EGL */

    if ( !init_egl( &app_context, display_type, native_window ) )
    {
        EGLint err = eglGetError();
        fprintf( stderr, "EGL initialization failed. EGL error: id=0x%x name=%s\n",
                err, esErrorToName( err ) );
        return 3;
    }

    /* print GL system properties */

    print_gl_properties();


    /* Setup the local OpenGL state for this demo */

    if ( !init_gl_state( &app_context ) )
    {
        return 4;
    }

    sigint.sa_handler = signal_int;
    sigemptyset(&sigint.sa_mask);
    sigaction(SIGINT, &sigint, NULL);

    fprintf( stdout, "Press CTRL+C to terminate\n" );

    while ( running )
    {
        /* Draw the graphics and flush them to the screen */

        display( & app_context );

        ++frame_count;

        if ( max_frames > 0 && frame_count >= max_frames )
        {
            break;
        }
    }

    fprintf(stderr,"Shutting down...\n");
    /* Close the local state for this demo */

    terminate_gl_state( &app_context );

    /* Terminate EGL */

    eglDisplay = eglGetDisplay( display_type );
    eglMakeCurrent( eglDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT );
    eglTerminate( eglDisplay );

    /* Do post EGL cleanup */

    tp_post_egl_terminate();

    return 0;
}
