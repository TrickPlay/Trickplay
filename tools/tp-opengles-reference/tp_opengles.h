#include <EGL/egl.h>

#ifdef __cplusplus
extern "C" {
#endif

    /******************************************************************************

     This function should be implemented by TrickPlay's OEM vendors. The
     implementation is expected to initialize the platform and, optionally, return
     the EGL display and native window. It should return 0 if initialization is
     successful or non-zero if there is a problem.

    */

    int tp_pre_egl_initialize( EGLNativeDisplayType* display , EGLNativeWindowType* window );

    /******************************************************************************

     This function should be implemented by TrickPlay's OEM vendors. The
     implementation should cleanup and/or release any resources which have been
     allocated during the call to tp_pre_egl_initialize.

    */

    void tp_post_egl_terminate( void );

    /*****************************************************************************/

#ifdef __cplusplus
}
#endif
