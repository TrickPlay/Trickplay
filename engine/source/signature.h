#ifndef _TRICKPLAY_SIGNATURE_H
#define _TRICKPLAY_SIGNATURE_H

#include <iostream>

#include "common.h"

namespace Signature
{
struct Info
{
    typedef std::list< Info > List;

    String  fingerprint;
    String  subject_name;
};

// A TRUE result means that either the file has no signatures, or that all
// signatures are OK. TRUE with an empty list, means no signatures.
//
// FALSE means that something went wrong checking the signatures, or that
// at least one of them is invalid.

bool get_signatures( const gchar* filename, Info::List& signatures, gsize* signature_length = NULL );

bool get_signatures( gpointer data, gsize size, Info::List& signatures, gsize* signature_length = NULL );

bool get_signatures( std::istream& stream, Info::List& signatures, gsize* signature_length = NULL );
};

#endif // _TRICKPLAY_SIGNATURE_H
