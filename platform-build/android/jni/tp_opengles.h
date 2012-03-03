#if !defined( _TP_OPENGLS_H_ )
#define _TP_OPENGLS_H_

#include <malloc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <EGL/egl.h>
#include <GLES2/gl2.h>
#include "esutil.h"


#ifdef __cplusplus
extern "C" {
#endif

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

/******************************************************************************

 This function should be implemented by TrickPlay's OEM vendors. The
 implementation is expected to initialize the platform and, optionally, return
 the EGL display and native window. It should return 0 if initialization is
 successful or non-zero if there is a problem.

*/

int tp_pre_egl_initialize( EGLNativeDisplayType * display , EGLNativeWindowType * window );

/******************************************************************************

 This function should be implemented by TrickPlay's OEM vendors. The
 implementation should cleanup and/or release any resources which have been
 allocated during the call to tp_pre_egl_initialize.

*/

void tp_post_egl_terminate( void );

/*****************************************************************************/

void pretty_print_string_attrib(const char * a_name, const char* a_val);
void pretty_print_int_attrib(const char * a_name, int a_val);
void pretty_print_boolean_attrib(const char * a_name, int a_val);
void print_gl_properties(void);
GLuint load_shader(GLenum shaderType, const char *shaderSrc);
int init_gl_state(ApplicationContext* app_context);
void terminate_gl_state(ApplicationContext* app_context);
void display(ApplicationContext* app_context);
int init_egl(ApplicationContext* app_context, EGLNativeDisplayType display_type, EGLNativeWindowType egl_win);

int main(int argc, char** argv);

#ifdef __cplusplus
}
#endif

#endif //_TP_OPENGLS_H_
