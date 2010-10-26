
#include <EGL/egl.h>
#include <GLES2/gl2.h>

EGLAPI EGLint EGLAPIENTRY eglGetError(void) { return 0; }
EGLAPI EGLDisplay EGLAPIENTRY eglGetDisplay(EGLNativeDisplayType display_id)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglInitialize(EGLDisplay dpy, EGLint *major, EGLint *minor)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglTerminate(EGLDisplay dpy)  { return 0; }
EGLAPI const char * EGLAPIENTRY eglQueryString(EGLDisplay dpy, EGLint name)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglGetConfigs(EGLDisplay dpy, EGLConfig *configs,EGLint config_size, EGLint *num_config)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglChooseConfig(EGLDisplay dpy, const EGLint *attrib_list,EGLConfig *configs, EGLint config_size,EGLint *num_config)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglGetConfigAttrib(EGLDisplay dpy, EGLConfig config,EGLint attribute, EGLint *value)  { return 0; }
EGLAPI EGLSurface EGLAPIENTRY eglCreateWindowSurface(EGLDisplay dpy, EGLConfig config,EGLNativeWindowType win,const EGLint *attrib_list)  { return 0; }
EGLAPI EGLSurface EGLAPIENTRY eglCreatePbufferSurface(EGLDisplay dpy, EGLConfig config,const EGLint *attrib_list)  { return 0; }
EGLAPI EGLSurface EGLAPIENTRY eglCreatePixmapSurface(EGLDisplay dpy, EGLConfig config,EGLNativePixmapType pixmap,const EGLint *attrib_list)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglDestroySurface(EGLDisplay dpy, EGLSurface surface)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglQuerySurface(EGLDisplay dpy, EGLSurface surface,EGLint attribute, EGLint *value)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglBindAPI(EGLenum api)  { return 0; }
EGLAPI EGLenum EGLAPIENTRY eglQueryAPI(void)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglWaitClient(void)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglReleaseThread(void)  { return 0; }
EGLAPI EGLSurface EGLAPIENTRY eglCreatePbufferFromClientBuffer(EGLDisplay dpy, EGLenum buftype, EGLClientBuffer buffer,EGLConfig config, const EGLint *attrib_list)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglSurfaceAttrib(EGLDisplay dpy, EGLSurface surface,EGLint attribute, EGLint value)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglBindTexImage(EGLDisplay dpy, EGLSurface surface, EGLint buffer)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglReleaseTexImage(EGLDisplay dpy, EGLSurface surface, EGLint buffer)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglSwapInterval(EGLDisplay dpy, EGLint interval)  { return 0; }
EGLAPI EGLContext EGLAPIENTRY eglCreateContext(EGLDisplay dpy, EGLConfig config,EGLContext share_context,const EGLint *attrib_list)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglDestroyContext(EGLDisplay dpy, EGLContext ctx)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglMakeCurrent(EGLDisplay dpy, EGLSurface draw,EGLSurface read, EGLContext ctx)  { return 0; }
EGLAPI EGLContext EGLAPIENTRY eglGetCurrentContext(void)  { return 0; }
EGLAPI EGLSurface EGLAPIENTRY eglGetCurrentSurface(EGLint readdraw)  { return 0; }
EGLAPI EGLDisplay EGLAPIENTRY eglGetCurrentDisplay(void)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglQueryContext(EGLDisplay dpy, EGLContext ctx,EGLint attribute, EGLint *value)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglWaitGL(void)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglWaitNative(EGLint engine)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglSwapBuffers(EGLDisplay dpy, EGLSurface surface)  { return 0; }
EGLAPI EGLBoolean EGLAPIENTRY eglCopyBuffers(EGLDisplay dpy, EGLSurface surface,EGLNativePixmapType target)  { return 0; }
EGLAPI __eglMustCastToProperFunctionPointerType EGLAPIENTRY eglGetProcAddress(const char *procname)  { return 0; }

GL_APICALL void         GL_APIENTRY glActiveTexture (GLenum texture){}
GL_APICALL void         GL_APIENTRY glAttachShader (GLuint program, GLuint shader){}
GL_APICALL void         GL_APIENTRY glBindAttribLocation (GLuint program, GLuint index, const GLchar* name){}
GL_APICALL void         GL_APIENTRY glBindBuffer (GLenum target, GLuint buffer){}
GL_APICALL void         GL_APIENTRY glBindFramebuffer (GLenum target, GLuint framebuffer){}
GL_APICALL void         GL_APIENTRY glBindRenderbuffer (GLenum target, GLuint renderbuffer){}
GL_APICALL void         GL_APIENTRY glBindTexture (GLenum target, GLuint texture){}
GL_APICALL void         GL_APIENTRY glBlendColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha){}
GL_APICALL void         GL_APIENTRY glBlendEquation ( GLenum mode ){}
GL_APICALL void         GL_APIENTRY glBlendEquationSeparate (GLenum modeRGB, GLenum modeAlpha){}
GL_APICALL void         GL_APIENTRY glBlendFunc (GLenum sfactor, GLenum dfactor){}
GL_APICALL void         GL_APIENTRY glBlendFuncSeparate (GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha){}
GL_APICALL void         GL_APIENTRY glBufferData (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage){}
GL_APICALL void         GL_APIENTRY glBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size, const GLvoid* data){}
GL_APICALL GLenum       GL_APIENTRY glCheckFramebufferStatus (GLenum target){return 0;}
GL_APICALL void         GL_APIENTRY glClear (GLbitfield mask){}
GL_APICALL void         GL_APIENTRY glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha){}
GL_APICALL void         GL_APIENTRY glClearDepthf (GLclampf depth){}
GL_APICALL void         GL_APIENTRY glClearStencil (GLint s){}
GL_APICALL void         GL_APIENTRY glColorMask (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha){}
GL_APICALL void         GL_APIENTRY glCompileShader (GLuint shader){}
GL_APICALL void         GL_APIENTRY glCompressedTexImage2D (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const GLvoid* data){}
GL_APICALL void         GL_APIENTRY glCompressedTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const GLvoid* data){}
GL_APICALL void         GL_APIENTRY glCopyTexImage2D (GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border){}
GL_APICALL void         GL_APIENTRY glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height){}
GL_APICALL GLuint       GL_APIENTRY glCreateProgram (void){return 0;}
GL_APICALL GLuint       GL_APIENTRY glCreateShader (GLenum type){return 0;}
GL_APICALL void         GL_APIENTRY glCullFace (GLenum mode){}
GL_APICALL void         GL_APIENTRY glDeleteBuffers (GLsizei n, const GLuint* buffers){}
GL_APICALL void         GL_APIENTRY glDeleteFramebuffers (GLsizei n, const GLuint* framebuffers){}
GL_APICALL void         GL_APIENTRY glDeleteProgram (GLuint program){}
GL_APICALL void         GL_APIENTRY glDeleteRenderbuffers (GLsizei n, const GLuint* renderbuffers){}
GL_APICALL void         GL_APIENTRY glDeleteShader (GLuint shader){}
GL_APICALL void         GL_APIENTRY glDeleteTextures (GLsizei n, const GLuint* textures){}
GL_APICALL void         GL_APIENTRY glDepthFunc (GLenum func){}
GL_APICALL void         GL_APIENTRY glDepthMask (GLboolean flag){}
GL_APICALL void         GL_APIENTRY glDepthRangef (GLclampf zNear, GLclampf zFar){}
GL_APICALL void         GL_APIENTRY glDetachShader (GLuint program, GLuint shader){}
GL_APICALL void         GL_APIENTRY glDisable (GLenum cap){}
GL_APICALL void         GL_APIENTRY glDisableVertexAttribArray (GLuint index){}
GL_APICALL void         GL_APIENTRY glDrawArrays (GLenum mode, GLint first, GLsizei count){}
GL_APICALL void         GL_APIENTRY glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices){}
GL_APICALL void         GL_APIENTRY glEnable (GLenum cap){}
GL_APICALL void         GL_APIENTRY glEnableVertexAttribArray (GLuint index){}
GL_APICALL void         GL_APIENTRY glFinish (void){}
GL_APICALL void         GL_APIENTRY glFlush (void){}
GL_APICALL void         GL_APIENTRY glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer){}
GL_APICALL void         GL_APIENTRY glFramebufferTexture2D (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level){}
GL_APICALL void         GL_APIENTRY glFrontFace (GLenum mode){}
GL_APICALL void         GL_APIENTRY glGenBuffers (GLsizei n, GLuint* buffers){}
GL_APICALL void         GL_APIENTRY glGenerateMipmap (GLenum target){}
GL_APICALL void         GL_APIENTRY glGenFramebuffers (GLsizei n, GLuint* framebuffers){}
GL_APICALL void         GL_APIENTRY glGenRenderbuffers (GLsizei n, GLuint* renderbuffers){}
GL_APICALL void         GL_APIENTRY glGenTextures (GLsizei n, GLuint* textures){}
GL_APICALL void         GL_APIENTRY glGetActiveAttrib (GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name){}
GL_APICALL void         GL_APIENTRY glGetActiveUniform (GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name){}
GL_APICALL void         GL_APIENTRY glGetAttachedShaders (GLuint program, GLsizei maxcount, GLsizei* count, GLuint* shaders){}
GL_APICALL int          GL_APIENTRY glGetAttribLocation (GLuint program, const GLchar* name){}
GL_APICALL void         GL_APIENTRY glGetBooleanv (GLenum pname, GLboolean* params){}
GL_APICALL void         GL_APIENTRY glGetBufferParameteriv (GLenum target, GLenum pname, GLint* params){}
GL_APICALL GLenum       GL_APIENTRY glGetError (void){return 0;}
GL_APICALL void         GL_APIENTRY glGetFloatv (GLenum pname, GLfloat* params){}
GL_APICALL void         GL_APIENTRY glGetFramebufferAttachmentParameteriv (GLenum target, GLenum attachment, GLenum pname, GLint* params){}
GL_APICALL void         GL_APIENTRY glGetIntegerv (GLenum pname, GLint* params){}
GL_APICALL void         GL_APIENTRY glGetProgramiv (GLuint program, GLenum pname, GLint* params){}
GL_APICALL void         GL_APIENTRY glGetProgramInfoLog (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog){}
GL_APICALL void         GL_APIENTRY glGetRenderbufferParameteriv (GLenum target, GLenum pname, GLint* params){}
GL_APICALL void         GL_APIENTRY glGetShaderiv (GLuint shader, GLenum pname, GLint* params){}
GL_APICALL void         GL_APIENTRY glGetShaderInfoLog (GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog){}
GL_APICALL void         GL_APIENTRY glGetShaderPrecisionFormat (GLenum shadertype, GLenum precisiontype, GLint* range, GLint* precision){}
GL_APICALL void         GL_APIENTRY glGetShaderSource (GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* source){}
GL_APICALL const GLubyte* GL_APIENTRY glGetString (GLenum name){return 0;}
GL_APICALL void         GL_APIENTRY glGetTexParameterfv (GLenum target, GLenum pname, GLfloat* params){}
GL_APICALL void         GL_APIENTRY glGetTexParameteriv (GLenum target, GLenum pname, GLint* params){}
GL_APICALL void         GL_APIENTRY glGetUniformfv (GLuint program, GLint location, GLfloat* params){}
GL_APICALL void         GL_APIENTRY glGetUniformiv (GLuint program, GLint location, GLint* params){}
GL_APICALL int          GL_APIENTRY glGetUniformLocation (GLuint program, const GLchar* name){return 0;}
GL_APICALL void         GL_APIENTRY glGetVertexAttribfv (GLuint index, GLenum pname, GLfloat* params){}
GL_APICALL void         GL_APIENTRY glGetVertexAttribiv (GLuint index, GLenum pname, GLint* params){}
GL_APICALL void         GL_APIENTRY glGetVertexAttribPointerv (GLuint index, GLenum pname, GLvoid** pointer){}
GL_APICALL void         GL_APIENTRY glHint (GLenum target, GLenum mode){}
GL_APICALL GLboolean    GL_APIENTRY glIsBuffer (GLuint buffer){return 0;}
GL_APICALL GLboolean    GL_APIENTRY glIsEnabled (GLenum cap){return 0;}
GL_APICALL GLboolean    GL_APIENTRY glIsFramebuffer (GLuint framebuffer){return 0;}
GL_APICALL GLboolean    GL_APIENTRY glIsProgram (GLuint program){return 0;}
GL_APICALL GLboolean    GL_APIENTRY glIsRenderbuffer (GLuint renderbuffer){return 0;}
GL_APICALL GLboolean    GL_APIENTRY glIsShader (GLuint shader){return 0;}
GL_APICALL GLboolean    GL_APIENTRY glIsTexture (GLuint texture){return 0;}
GL_APICALL void         GL_APIENTRY glLineWidth (GLfloat width){}
GL_APICALL void         GL_APIENTRY glLinkProgram (GLuint program){}
GL_APICALL void         GL_APIENTRY glPixelStorei (GLenum pname, GLint param){}
GL_APICALL void         GL_APIENTRY glPolygonOffset (GLfloat factor, GLfloat units){}
GL_APICALL void         GL_APIENTRY glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid* pixels){}
GL_APICALL void         GL_APIENTRY glReleaseShaderCompiler (void){}
GL_APICALL void         GL_APIENTRY glRenderbufferStorage (GLenum target, GLenum internalformat, GLsizei width, GLsizei height){}
GL_APICALL void         GL_APIENTRY glSampleCoverage (GLclampf value, GLboolean invert){}
GL_APICALL void         GL_APIENTRY glScissor (GLint x, GLint y, GLsizei width, GLsizei height){}
GL_APICALL void         GL_APIENTRY glShaderBinary (GLsizei n, const GLuint* shaders, GLenum binaryformat, const GLvoid* binary, GLsizei length){}
GL_APICALL void         GL_APIENTRY glShaderSource (GLuint shader, GLsizei count, const GLchar** string, const GLint* length){}
GL_APICALL void         GL_APIENTRY glStencilFunc (GLenum func, GLint ref, GLuint mask){}
GL_APICALL void         GL_APIENTRY glStencilFuncSeparate (GLenum face, GLenum func, GLint ref, GLuint mask){}
GL_APICALL void         GL_APIENTRY glStencilMask (GLuint mask){}
GL_APICALL void         GL_APIENTRY glStencilMaskSeparate (GLenum face, GLuint mask){}
GL_APICALL void         GL_APIENTRY glStencilOp (GLenum fail, GLenum zfail, GLenum zpass){}
GL_APICALL void         GL_APIENTRY glStencilOpSeparate (GLenum face, GLenum fail, GLenum zfail, GLenum zpass){}
GL_APICALL void         GL_APIENTRY glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels){}
GL_APICALL void         GL_APIENTRY glTexParameterf (GLenum target, GLenum pname, GLfloat param){}
GL_APICALL void         GL_APIENTRY glTexParameterfv (GLenum target, GLenum pname, const GLfloat* params){}
GL_APICALL void         GL_APIENTRY glTexParameteri (GLenum target, GLenum pname, GLint param){}
GL_APICALL void         GL_APIENTRY glTexParameteriv (GLenum target, GLenum pname, const GLint* params){}
GL_APICALL void         GL_APIENTRY glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid* pixels){}
GL_APICALL void         GL_APIENTRY glUniform1f (GLint location, GLfloat x){}
GL_APICALL void         GL_APIENTRY glUniform1fv (GLint location, GLsizei count, const GLfloat* v){}
GL_APICALL void         GL_APIENTRY glUniform1i (GLint location, GLint x){}
GL_APICALL void         GL_APIENTRY glUniform1iv (GLint location, GLsizei count, const GLint* v){}
GL_APICALL void         GL_APIENTRY glUniform2f (GLint location, GLfloat x, GLfloat y){}
GL_APICALL void         GL_APIENTRY glUniform2fv (GLint location, GLsizei count, const GLfloat* v){}
GL_APICALL void         GL_APIENTRY glUniform2i (GLint location, GLint x, GLint y){}
GL_APICALL void         GL_APIENTRY glUniform2iv (GLint location, GLsizei count, const GLint* v){}
GL_APICALL void         GL_APIENTRY glUniform3f (GLint location, GLfloat x, GLfloat y, GLfloat z){}
GL_APICALL void         GL_APIENTRY glUniform3fv (GLint location, GLsizei count, const GLfloat* v){}
GL_APICALL void         GL_APIENTRY glUniform3i (GLint location, GLint x, GLint y, GLint z){}
GL_APICALL void         GL_APIENTRY glUniform3iv (GLint location, GLsizei count, const GLint* v){}
GL_APICALL void         GL_APIENTRY glUniform4f (GLint location, GLfloat x, GLfloat y, GLfloat z, GLfloat w){}
GL_APICALL void         GL_APIENTRY glUniform4fv (GLint location, GLsizei count, const GLfloat* v){}
GL_APICALL void         GL_APIENTRY glUniform4i (GLint location, GLint x, GLint y, GLint z, GLint w){}
GL_APICALL void         GL_APIENTRY glUniform4iv (GLint location, GLsizei count, const GLint* v){}
GL_APICALL void         GL_APIENTRY glUniformMatrix2fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value){}
GL_APICALL void         GL_APIENTRY glUniformMatrix3fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value){}
GL_APICALL void         GL_APIENTRY glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value){}
GL_APICALL void         GL_APIENTRY glUseProgram (GLuint program){}
GL_APICALL void         GL_APIENTRY glValidateProgram (GLuint program){}
GL_APICALL void         GL_APIENTRY glVertexAttrib1f (GLuint indx, GLfloat x){}
GL_APICALL void         GL_APIENTRY glVertexAttrib1fv (GLuint indx, const GLfloat* values){}
GL_APICALL void         GL_APIENTRY glVertexAttrib2f (GLuint indx, GLfloat x, GLfloat y){}
GL_APICALL void         GL_APIENTRY glVertexAttrib2fv (GLuint indx, const GLfloat* values){}
GL_APICALL void         GL_APIENTRY glVertexAttrib3f (GLuint indx, GLfloat x, GLfloat y, GLfloat z){}
GL_APICALL void         GL_APIENTRY glVertexAttrib3fv (GLuint indx, const GLfloat* values){}
GL_APICALL void         GL_APIENTRY glVertexAttrib4f (GLuint indx, GLfloat x, GLfloat y, GLfloat z, GLfloat w){}
GL_APICALL void         GL_APIENTRY glVertexAttrib4fv (GLuint indx, const GLfloat* values){}
GL_APICALL void         GL_APIENTRY glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr){}
GL_APICALL void         GL_APIENTRY glViewport (GLint x, GLint y, GLsizei width, GLsizei height){}







