#ifndef _TRICKPLAY_PLUGINS_H
#define _TRICKPLAY_PLUGINS_H

/*-----------------------------------------------------------------------------*/

	typedef struct TPPluginInfo TPPluginInfo;

    struct TPPluginInfo
    {
        char            name[64];
        char            version[64];
        char			reserved[256];
        int             resident;
        void *          user_data;
    };

/*-----------------------------------------------------------------------------*/
/*
	Called when the TrickPlay context runs for the first time.
*/

    typedef
    void
    (*TPPluginInitialize)(

            TPPluginInfo *	info,
            const char *    config);

/*-----------------------------------------------------------------------------*/
/*
    Called when the TrickPlay context is destroyed.
*/

    typedef
	void
	(*TPPluginShutdown)(

			void * 		user_data);

/*-----------------------------------------------------------------------------*/

#define TP_PLUGIN_INITIALIZE       "tp_plugin_initialize"
#define TP_PLUGIN_SHUTDOWN         "tp_plugin_shutdown"

/*-----------------------------------------------------------------------------*/

#endif /* _TRICKPLAY_PLUGINS_H */
