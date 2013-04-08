#ifndef _TRICKPLAY_DESKTOP_CONTROLLER_H
#define _TRICKPLAY_DESKTOP_CONTROLLER_H

#ifdef TP_CLUTTER_BACKEND_EGL

#define install_desktop_controller(context) while(0){}

#else

void install_desktop_controller( TPContext* context );

#endif

#endif // _TRICKPLAY_DESKTOP_CONTROLLER_H
