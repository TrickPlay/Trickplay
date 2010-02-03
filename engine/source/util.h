#ifndef UTIL_H
#define UTIL_H

#include <cstring>

#include "glib.h"

//-----------------------------------------------------------------------------

inline void g_info(const gchar * format,...)
{
    va_list args;
    va_start(args,format);
    g_logv(G_LOG_DOMAIN,G_LOG_LEVEL_INFO,format,args);
    va_end(args);        
}

//-----------------------------------------------------------------------------

namespace Util
{
    //-----------------------------------------------------------------------------
    // This is like an auto_ptr that uses g_free and cannot be copied
    
    class GFreeLater
    {
    public:
        
        GFreeLater(gpointer pointer) : p(pointer) {}
        ~GFreeLater() { g_free(p); }
    
    private:
        
        GFreeLater() {}
        GFreeLater(const GFreeLater &) {}
        
        gpointer p;
    };
    
    //-----------------------------------------------------------------------------
    
    class GStrFreevLater
    {
    public:
        
        GStrFreevLater(gchar**pointer) : p(pointer) {}
        ~GStrFreevLater() {g_strfreev(p);}
        
    private:
        
        GStrFreevLater() {}
        GStrFreevLater(const GStrFreevLater&) {}
        
        gchar ** p;
    };
    
    //-----------------------------------------------------------------------------
    
    class GMutexLock
    {
    public:
        
        GMutexLock(GMutex * mutex) : m(mutex) {g_mutex_lock(m);}
        ~GMutexLock() {g_mutex_unlock(m);}
    
    private:
        
        GMutexLock() {}
        GMutexLock(const GMutexLock &) {}
        
        GMutex * m;
    };
    
    //-----------------------------------------------------------------------------
    
    class GSRMutexLock
    {
    public:
        
        GSRMutexLock(GStaticRecMutex * mutex) : m(mutex) {g_static_rec_mutex_lock(m);}
        ~GSRMutexLock() {g_static_rec_mutex_unlock(m);}
    
    private:
        
        GSRMutexLock() {}
        GSRMutexLock(const GSRMutexLock &) {}
        
        GStaticRecMutex * m;
    };
    
    //-----------------------------------------------------------------------------
    // Converts a path using / to a platform path in place - modifies the string
    // passed in.
    
    inline gchar * path_to_native_path(gchar * path)
    {
        if (G_DIR_SEPARATOR=='/')
            return path;
        return g_strdelimit(path,"/",G_DIR_SEPARATOR);    
    }
    
    //-----------------------------------------------------------------------------
    // Given a root path and some other path, it makes the path relative and
    // appends it to the root. Return value must be destroyed with g_free.
    // Both root and path are converted to native paths.
    //
    // NOTE: if path contains any .. elements, this will abort. The assumption
    // is that root is trusted and path came from Lua - and cannot be trusted
    
    inline gchar * rebase_path(const gchar * root,const gchar * path)
    {
        if(strstr(path,".."))
            g_error("Invalid relative path '%s'",path);
    
        gchar * p = path_to_native_path(g_strdup(path));
        GFreeLater free_p(p);
        
        const gchar * last = g_path_is_absolute(p)?g_path_skip_root(p):p;
        
        gchar * first = path_to_native_path(g_strdup(root));
        GFreeLater free_first(first);
        
        return g_build_filename(first,last,NULL);
    }
    
    
}

#endif