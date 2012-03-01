
#include <jni.h>
#include <android/log.h>

#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define  LOG_TAG    "ECT_CORES"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)


#include "tp_opengles.h"
#include "esutil.h"

extern "C" {
    JNIEXPORT void JNICALL Java_com_android_gl2jni_GL2JNILib_init(JNIEnv * env, jobject obj,  jint width, jint height);
    JNIEXPORT void JNICALL Java_com_android_gl2jni_GL2JNILib_step(JNIEnv * env, jobject obj);
};

EGLNativeDisplayType display_type  = EGL_DEFAULT_DISPLAY;
EGLNativeWindowType  native_window = 0;

EGLDisplay eglDisplay;

int frame_count = 0;
ApplicationContext app_context;

JNIEXPORT void JNICALL Java_com_android_gl2jni_GL2JNILib_init(JNIEnv * env, jobject obj,  jint width, jint height)
{

    memset(&app_context, 0, sizeof(ApplicationContext));

    app_context.width  = width;
    app_context.height = height;

    __android_log_print(ANDROID_LOG_INFO, "ECT_CORES",  "Width(%d) Height(%d)", width, height );

    /* Call the custom pre-initialization function */
    if (0 != tp_pre_egl_initialize(&display_type, &native_window))
    {
    	__android_log_print(ANDROID_LOG_INFO, "ECT_CORES",  "tp_pre_egl_initializate() failed. fatal error\n");
        return ;
    }

//    /* Initialise EGL */

//    if (!init_egl(&app_context, display_type, native_window))
//    {
//        //EGLint err = eglGetError();
//        __android_log_print(ANDROID_LOG_INFO, "ECT_CORES",  "EGL initialization failed. \n" );
//        return ;
//    }

    /* print GL system properties */

    print_gl_properties();

    /* Setup the local OpenGL state for this demo */
    if (!init_gl_state(&app_context))
    {
    	__android_log_print(ANDROID_LOG_INFO, "ECT_CORES",  " ECT - init fail");
        return ;
    }
}

JNIEXPORT void JNICALL Java_com_android_gl2jni_GL2JNILib_step(JNIEnv * env, jobject obj)
{
	display( & app_context );
	frame_count++;
}
