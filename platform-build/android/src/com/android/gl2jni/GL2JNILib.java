
package com.android.gl2jni;

// Wrapper for native library

public class GL2JNILib {

     static {
         System.loadLibrary("android");
         System.loadLibrary("GLESv2");
         System.loadLibrary("EGL");

         System.loadLibrary("iconv");
         System.loadLibrary("intl");
         System.loadLibrary("exif-tp");
         System.loadLibrary("expat");
         System.loadLibrary("xml2");
         System.loadLibrary("ffi");
         System.loadLibrary("glib-2.0");
         System.loadLibrary("gthread-2.0");
         System.loadLibrary("gobject-2.0");
         System.loadLibrary("gmodule-2.0");
         System.loadLibrary("gio-2.0");
         System.loadLibrary("sqlite3");
         System.loadLibrary("cares");
         System.loadLibrary("curl");
         System.loadLibrary("freetype");
         System.loadLibrary("fontconfig");
         System.loadLibrary("pixman-1");
         System.loadLibrary("png15");
         System.loadLibrary("cairo");
         System.loadLibrary("cairo-gobject");
         System.loadLibrary("pango-1.0");
         System.loadLibrary("pangoft2-1.0");
         System.loadLibrary("pangocairo-1.0");
         System.loadLibrary("jpeg");
         System.loadLibrary("tiff");
         System.loadLibrary("tiffxx");
         System.loadLibrary("gif");
         System.loadLibrary("json-glib-1.0");
         System.loadLibrary("atk-1.0");
         System.loadLibrary("cogl");
         System.loadLibrary("cogl-pango");
         System.loadLibrary("clutter-eglnative-1.0");
         System.loadLibrary("avahi-common");
         System.loadLibrary("avahi-core");
         System.loadLibrary("avahi-glib");
         System.loadLibrary("ixml");
         System.loadLibrary("threadutil");
         System.loadLibrary("upnp");
         System.loadLibrary("uriparser");
         System.loadLibrary("uuid");
         System.loadLibrary("sndfile");
         System.loadLibrary("soup-2.4");
         System.loadLibrary("clutteralphamode");
         System.loadLibrary("tplua");

         System.loadLibrary("gl2jni");
     }

    /**
     * @param width the current view width
     * @param height the current view height
     */
     public static native void init(int width, int height);
     public static native void step();
}
