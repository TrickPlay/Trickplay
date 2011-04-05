/*
 * http_utils.h
 *
 *  Created on: Apr 4, 2011
 *      Author: bkorlipara
 */

#ifndef HTTP_UTILS_H_
#define HTTP_UTILS_H_
#include "http_server.h"

extern void dump_headers(const HttpServer::Request& request);

extern void dump_parameters(const HttpServer::Request& request);

#endif /* HTTP_UTILS_H_ */
