#ifndef _TXMPP_CONFIG_H_
#define _TXMPP_CONFIG_H_

#ifndef FEATURE_ENABLE_SSL
#cmakedefine FEATURE_ENABLE_SSL 1
#endif

#ifndef HAVE_OPENSSL_SSL_H
#cmakedefine HAVE_OPENSSL_SSL_H 1
#endif

#ifndef POSIX 
#cmakedefine POSIX 1
#endif

#ifndef SSL_USE_OPENSSL
#cmakedefine SSL_USE_OPENSSL 1
#endif

#ifndef USE_SSLSTREAM
#cmakedefine USE_SSLSTREAM 1
#endif

#ifndef OSX
#cmakedefine OSX 1
#endif

#ifndef LINUX
#cmakedefine LINUX 1
#endif

#ifndef _DEBUG
#cmakedefine _DEBUG
#endif

#endif /* _TXMPP_CONFIG_H_ */
