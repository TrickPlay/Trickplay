#ifndef _ESUTIL_H_
#define _ESUTIL_H_
#include <EGL/egl.h>

#ifdef __cplusplus
extern "C" {
#endif

    typedef struct { float m[4][4]; } ESMatrix;

    /* Matrix manipulation functions - useful for ES2, which doesn't have them built in */
    void esTranslate( ESMatrix* result, float tx, float ty, float tz );
    void esScale( ESMatrix* result, float sx, float sy, float sz );
    void esMatrixMultiply( ESMatrix* result, ESMatrix* srcA, ESMatrix* srcB );
    int  esInverse( ESMatrix* in, ESMatrix* out );
    void esRotate( ESMatrix* result, float angle, float x, float y, float z );
    void esMatrixLoadIdentity( ESMatrix* result );
    void esFrustum( ESMatrix* result, float left, float right, float bottom, float top, float nearZ, float farZ );
    void esPerspective( ESMatrix* result, float fovy, float aspect, float zNear, float zFar );
    void esOrtho( ESMatrix* result, float left, float right, float bottom, float top, float nearZ, float farZ );
    const char* esErrorToName( EGLint errorId );

#ifdef __cplusplus
}
#endif

#endif /* _ESUTIL_H_ */
