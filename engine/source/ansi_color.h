// ANSI color codes

#include <unistd.h>

#define ANSI_ESCAPE_PREFIX      "\033["

#define ANSI_COLOR_RESET        ANSI_ESCAPE_PREFIX "0m"

#define ANSI_COLOR_BOLD         ANSI_ESCAPE_PREFIX "1m"
#define ANSI_COLOR_NORMAL       ANSI_ESCAPE_PREFIX "22m"

#define ANSI_COLOR_NEGATIVE     ANSI_ESCAPE_PREFIX "7m"
#define ANSI_COLOR_POSITIVE     ANSI_ESCAPE_PREFIX "27m"

#define ANSI_COLOR_FG_BLACK     ANSI_ESCAPE_PREFIX "30m"
#define ANSI_COLOR_FG_RED       ANSI_ESCAPE_PREFIX "31m"
#define ANSI_COLOR_FG_GREEN     ANSI_ESCAPE_PREFIX "32m"
#define ANSI_COLOR_FG_YELLOW    ANSI_ESCAPE_PREFIX "33m"
#define ANSI_COLOR_FG_BLUE      ANSI_ESCAPE_PREFIX "34m"
#define ANSI_COLOR_FG_MAGENTA   ANSI_ESCAPE_PREFIX "35m"
#define ANSI_COLOR_FG_CYAN      ANSI_ESCAPE_PREFIX "36m"
#define ANSI_COLOR_FG_WHITE     ANSI_ESCAPE_PREFIX "37m"
#define ANSI_COLOR_FG_DEFAULT   ANSI_ESCAPE_PREFIX "39m"

#define ANSI_COLOR_BG_BLACK     ANSI_ESCAPE_PREFIX "40m"
#define ANSI_COLOR_BG_RED       ANSI_ESCAPE_PREFIX "41m"
#define ANSI_COLOR_BG_GREEN     ANSI_ESCAPE_PREFIX "42m"
#define ANSI_COLOR_BG_YELLOW    ANSI_ESCAPE_PREFIX "43m"
#define ANSI_COLOR_BG_BLUE      ANSI_ESCAPE_PREFIX "44m"
#define ANSI_COLOR_BG_MAGENTA   ANSI_ESCAPE_PREFIX "45m"
#define ANSI_COLOR_BG_CYAN      ANSI_ESCAPE_PREFIX "46m"
#define ANSI_COLOR_BG_WHITE     ANSI_ESCAPE_PREFIX "47m"
#define ANSI_COLOR_BG_DEFAULT   ANSI_ESCAPE_PREFIX "49m"

// Bit of a hack.  Right now we don't use color if the output is not a tty.  We should probably
// use a configuration variable instead to disable color.  Note that the isatty() thing is only checking
// stderr, and so if you redirect stderr, you won't get color on the telnet console, and vice-versa.

inline const char* _SAFE_ANSI_COLOR_RESET( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_RESET : ""; }
inline const char* _SAFE_ANSI_COLOR_BOLD( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BOLD : ""; }
inline const char* _SAFE_ANSI_COLOR_NORMAL( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_NORMAL : ""; }
inline const char* _SAFE_ANSI_COLOR_NEGATIVE( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_NEGATIVE : ""; }
inline const char* _SAFE_ANSI_COLOR_POSITIVE( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_POSITIVE : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_BLACK( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_BLACK : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_RED( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_RED : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_GREEN( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_GREEN : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_YELLOW( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_YELLOW : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_BLUE( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_BLUE : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_MAGENTA( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_MAGENTA : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_CYAN( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_CYAN : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_WHITE( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_WHITE : ""; }
inline const char* _SAFE_ANSI_COLOR_FG_DEFAULT( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_FG_DEFAULT : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_BLACK( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_BLACK : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_RED( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_RED : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_GREEN( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_GREEN : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_YELLOW( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_YELLOW : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_BLUE( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_BLUE : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_MAGENTA( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_MAGENTA : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_CYAN( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_CYAN : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_WHITE( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_WHITE : ""; }
inline const char* _SAFE_ANSI_COLOR_BG_DEFAULT( void ) { return isatty( STDERR_FILENO ) ? ANSI_COLOR_BG_DEFAULT : ""; }

#define SAFE_ANSI_COLOR_RESET       _SAFE_ANSI_COLOR_RESET()
#define SAFE_ANSI_COLOR_BOLD        _SAFE_ANSI_COLOR_BOLD()
#define SAFE_ANSI_COLOR_NORMAL      _SAFE_ANSI_COLOR_NORMAL()
#define SAFE_ANSI_COLOR_NEGATIVE    _SAFE_ANSI_COLOR_NEGATIVE()
#define SAFE_ANSI_COLOR_POSITIVE    _SAFE_ANSI_COLOR_POSITIVE()
#define SAFE_ANSI_COLOR_FG_BLACK    _SAFE_ANSI_COLOR_FG_BLACK()
#define SAFE_ANSI_COLOR_FG_RED      _SAFE_ANSI_COLOR_FG_RED()
#define SAFE_ANSI_COLOR_FG_GREEN    _SAFE_ANSI_COLOR_FG_GREEN()
#define SAFE_ANSI_COLOR_FG_YELLOW   _SAFE_ANSI_COLOR_FG_YELLOW()
#define SAFE_ANSI_COLOR_FG_BLUE     _SAFE_ANSI_COLOR_FG_BLUE()
#define SAFE_ANSI_COLOR_FG_MAGENTA  _SAFE_ANSI_COLOR_FG_MAGENTA()
#define SAFE_ANSI_COLOR_FG_CYAN     _SAFE_ANSI_COLOR_FG_CYAN()
#define SAFE_ANSI_COLOR_FG_WHITE    _SAFE_ANSI_COLOR_FG_WHITE()
#define SAFE_ANSI_COLOR_FG_DEFAULT  _SAFE_ANSI_COLOR_FG_DEFAULT()
#define SAFE_ANSI_COLOR_BG_BLACK    _SAFE_ANSI_COLOR_BG_BLACK()
#define SAFE_ANSI_COLOR_BG_RED      _SAFE_ANSI_COLOR_BG_RED()
#define SAFE_ANSI_COLOR_BG_GREEN    _SAFE_ANSI_COLOR_BG_GREEN()
#define SAFE_ANSI_COLOR_BG_YELLOW   _SAFE_ANSI_COLOR_BG_YELLOW()
#define SAFE_ANSI_COLOR_BG_BLUE     _SAFE_ANSI_COLOR_BG_BLUE()
#define SAFE_ANSI_COLOR_BG_MAGENTA  _SAFE_ANSI_COLOR_BG_MAGENTA()
#define SAFE_ANSI_COLOR_BG_CYAN     _SAFE_ANSI_COLOR_BG_CYAN()
#define SAFE_ANSI_COLOR_BG_WHITE    _SAFE_ANSI_COLOR_BG_WHITE()
#define SAFE_ANSI_COLOR_BG_DEFAULT  _SAFE_ANSI_COLOR_BG_DEFAULT()
