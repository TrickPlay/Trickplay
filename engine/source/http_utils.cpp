/*
 * http_utils.cpp
 *
 *  Created on: Apr 4, 2011
 */
#include "http_utils.h"
#include "util.h"

void dump_headers(const HttpServer::Request& request)
{
	StringMap header_map = request.get_headers( );
	StringMap::iterator it;
	g_info(" dumping request headers >>>> ");
	for (it = header_map.begin(); it != header_map.end(); it++) {
		g_info( ( it->first + ": " + it->second ).c_str( ) );
	}
}

void dump_parameters(const HttpServer::Request& request)
{
	StringMap parameter_map = request.get_parameters( );
	StringMap::iterator it;
	g_info(" dumping request parameters >>>> ");
	for (it = parameter_map.begin(); it != parameter_map.end(); it++) {
		g_info( ( it->first + "=" + it->second ).c_str( ) );
	}
}

