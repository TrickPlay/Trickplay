#include <iostream>
#include <fstream>
#include <sstream>

#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/pem.h>

#include <openssl/ssl.h>

#include "signature.h"
#include "util.h"

void fail( const gchar* format, ... )
{
    va_list args;
    va_start( args, format );
    gchar* s = g_strdup_vprintf( format, args );
    va_end( args );

    String result( s );
    g_free( s );

    throw result;
}

//-----------------------------------------------------------------------------

bool verify_certificate( X509* cert )
{
    g_assert( cert );

    static const char* ca_certs[] =
    {
        // This is the TrickPlay App Signing CA (self signed)

        "-----BEGIN CERTIFICATE-----\n"
        "MIICnzCCAggCCQCYvWYB237yhjANBgkqhkiG9w0BAQUFADCBkzELMAkGA1UEBhMC\n"
        "VVMxEzARBgNVBAgTCkNhbGlmb3JuaWExEjAQBgNVBAcTCVBhbG8gQWx0bzEXMBUG\n"
        "A1UEChMOVHJpY2tQbGF5IEluYy4xITAfBgNVBAMTGFRyaWNrUGxheSBBcHAgU2ln\n"
        "bmluZyBDQTEfMB0GCSqGSIb3DQEJARYQaXRAdHJpY2twbGF5LmNvbTAeFw0xMDA1\n"
        "MzExOTA1NTNaFw0yMDA1MjgxOTA1NTNaMIGTMQswCQYDVQQGEwJVUzETMBEGA1UE\n"
        "CBMKQ2FsaWZvcm5pYTESMBAGA1UEBxMJUGFsbyBBbHRvMRcwFQYDVQQKEw5Ucmlj\n"
        "a1BsYXkgSW5jLjEhMB8GA1UEAxMYVHJpY2tQbGF5IEFwcCBTaWduaW5nIENBMR8w\n"
        "HQYJKoZIhvcNAQkBFhBpdEB0cmlja3BsYXkuY29tMIGfMA0GCSqGSIb3DQEBAQUA\n"
        "A4GNADCBiQKBgQDdV72r8+UfEuK1KmNbTxfriK+o0IqB6ssyiET2Qj7v9GRSWIqM\n"
        "bYI06lT/ZchNzyQS9Em6I/XGiFyHVt1anIfjE2ncDxzLjHbZkx+3rRAiK17fQGea\n"
        "hlsibjVY08Z1qLNIEwIxlXZF+ThoxV9CNtszE81uqX68Z1x6VdKZrdV0jwIDAQAB\n"
        "MA0GCSqGSIb3DQEBBQUAA4GBAAc2H82jJInmASfvju7ygjDpYZ/G9vgHUwFor/Uz\n"
        "j7QZeujfIHSAZ2qnQppyvOi2SIj46fYcHkwHOZGBrE1LLf19tj719DFdC9Ho2WSf\n"
        "kWLGm3zUwKIqjS1mQGKPDV4H4SbBlQ9Hn8O/ZUi1dCXUpHVMlUoo78O1s2xrLq1K\n"
        "pgki\n"
        "-----END CERTIFICATE-----\n"
        ,
        NULL
    };

    bool result = false;

    X509_STORE* store = X509_STORE_new();

    try
    {
        if ( ! store )
        {
            fail( "FAILED TO CREATE CERTIFICATE STORE" );
        }

        // Add all of our CA certs to the store

        for ( const char * * pem = ca_certs; *pem; ++pem )
        {
            BIO* bio = BIO_new_mem_buf( ( void* ) *pem, strlen( *pem ) );

            if ( ! bio )
            {
                fail( "FAILED TO CREATE BIO FOR CA CERTIFICATE" );
            }

            X509* ca = PEM_read_bio_X509( bio, NULL, NULL, NULL );

            BIO_free( bio );

            if ( ! ca )
            {
                fail( "FAILED TO LOAD CA CERTIFICATE" );
            }

            if ( ! X509_STORE_add_cert( store, ca ) )
            {
                X509_free( ca );

                fail( "FAILED TO ADD CA CERTIFICATE TO STORE" );
            }

            X509_free( ca );
        }

        // Now create the context we will use to validate the incoming
        // certificate and validate it.

        // TODO: To customize the validation, we will have to add a verify
        // callback.
        //
        // We will need to account for the system time not being correct
        // and cert validation failing because of it.

        X509_STORE_CTX* ctx = X509_STORE_CTX_new();

        if ( ! ctx )
        {
            fail( "FAILED TO CREATE CERTIFICATE STORE CONTEXT" );
        }

        X509_STORE_CTX_init( ctx, store, cert, NULL );

        int verification_result = X509_verify_cert( ctx );

        X509_STORE_CTX_cleanup( ctx );

        X509_STORE_CTX_free( ctx );

        result = verification_result != 0;
    }
    catch ( const String& e )
    {
        g_warning( "FAILED TO VALIDATE CERTIFICATE : %s", e.c_str() );
    }

    if ( store )
    {
        X509_STORE_free( store );
    }

    return result;
}

//-----------------------------------------------------------------------------
// Returns the SHA1 fingerprint of the certificate in upper case hex.


bool get_certificate_fingerprint( X509* cert, String& fingerprint )
{
    g_assert( cert );

    unsigned char buffer[ EVP_MAX_MD_SIZE ];

    unsigned int fingerprint_size = 0;

    if ( ! X509_digest( cert, EVP_sha1(), buffer, &fingerprint_size ) )
    {
        return false;
    }

    char hex[ 4 ];

    fingerprint.clear();

    fingerprint.reserve( fingerprint_size * 2 );

    for ( unsigned int i = 0; i < fingerprint_size; ++i )
    {

        // WARNING: Fingerprints will be incorrect if sprintf is broken

        sprintf( hex, "%2.2X", buffer[ i ] );

        fingerprint += hex;
    }

    return true;
}

//-----------------------------------------------------------------------------

bool get_certificate_subject_name( X509* cert, String& subject_name )
{
    g_assert( cert );

    bool result = false;

    X509_NAME* name = X509_get_subject_name( cert );

    if ( name )
    {
        BIO* bio = BIO_new( BIO_s_mem() );

        if ( bio )
        {
            if ( X509_NAME_print_ex( bio, name, 0, XN_FLAG_ONELINE | ASN1_STRFLGS_UTF8_CONVERT | ASN1_STRFLGS_ESC_CTRL ) )
            {
                subject_name.clear();

                char buffer[ 512 ];

                while ( true )
                {
                    int read = BIO_read( bio, buffer, 512 );

                    if ( read <= 0 )
                    {
                        break;
                    }

                    subject_name += String( buffer, read );
                }

                result = true;
            }

            BIO_free( bio );
        }
    }

    return result;
}

//-----------------------------------------------------------------------------
// Get the signature at the end of the stream and put its info in info.
//
// TRUE - Means there was one valid signature
// FALSE - Means there was no signature
//
// Any failure will throw a String exception.

bool get_signature( std::istream& stream, gsize skip_trailing_bytes, Signature::Info& info, gsize& size )
{
    g_assert( stream.good() );

    static const char* TP_SIGN_MARKER = "tp-sign";

    static int TP_SIGN_MARKER_LENGTH = strlen( TP_SIGN_MARKER );

    // Determine the size of the stream

    stream.seekg( - std::streamoff( skip_trailing_bytes ) , std::ios_base::end );

    goffset stream_size = stream.tellg();

    if ( stream_size < 0 )
    {
        fail( "FAILED TO DETERMINE STREAM SIZE" );
    }

    if ( stream_size <= goffset( TP_SIGN_MARKER_LENGTH + 1 ) )
    {
        // There is not enough data in the stream to have a signature

        return false;
    }

    // Read the signature marker and the signature version byte

    char marker[ TP_SIGN_MARKER_LENGTH + 1 ];

    stream.seekg( - std::streamoff( TP_SIGN_MARKER_LENGTH + 1 + skip_trailing_bytes ), std::ios_base::end );

    stream.read( marker, TP_SIGN_MARKER_LENGTH + 1 );

    if ( stream.fail() || stream.gcount() != TP_SIGN_MARKER_LENGTH + 1 )
    {
        fail( "FAILED TO READ SIGNATURE MARKER" );
    }

    if ( strncmp( marker, TP_SIGN_MARKER, TP_SIGN_MARKER_LENGTH ) )
    {
        // The marker doesn't match, so there is no signature

        return false;
    }

    char signature_version = marker[ TP_SIGN_MARKER_LENGTH ];

    if ( signature_version != 1 )
    {
        fail( "INVALID SIGNATURE VERSION %d", signature_version );
    }

    // Now read the 2 32 bit lengths

    guint32 sizes[ 2 ];

    stream.seekg( - std::streamoff( TP_SIGN_MARKER_LENGTH + 1 + 8 + skip_trailing_bytes ), std::ios_base::end );

    stream.read( ( char* ) sizes, 8 );

    if ( stream.fail() || stream.gcount() != 8 )
    {
        fail( "FAILED TO READ SIGNATURE LENGTH" );
    }

    guint32 signature_size = GUINT32_FROM_LE( sizes[ 0 ] );

    guint32 cert_size = GUINT32_FROM_LE( sizes[ 1 ] );

    goffset data_size = stream_size - ( TP_SIGN_MARKER_LENGTH + 1 + 8 + cert_size + signature_size );

    //    g_debug( "SIGNATURE IS %u BYTES : CERT IS %u BYTES : DATA IS %" G_GOFFSET_FORMAT " BYTES", signature_size, cert_size, data_size );

    if ( data_size < 0 )
    {
        fail( "INCORRECT SIGNATURE OR CERTIFICATE LENGTH" );
    }

    // Back-up to read the signature and cert

    if ( stream.tellg() < signature_size + cert_size + 8 )
    {
        fail( "EARLY END OF STREAM" );
    }

    stream.seekg( - std::streamoff( signature_size + cert_size + 8 ), std::ios_base::cur );

    // Read the signature

    char signature[ signature_size + 1 ];

    stream.read( signature, signature_size );

    if ( stream.fail() || stream.gcount() != std::streamsize( signature_size ) )
    {
        fail( "FAILED TO READ SIGNATURE" );
    }

    signature[ signature_size ] = 0;

    // Read the cert

    char cert_pem[ cert_size + 1 ];

    stream.read( cert_pem, cert_size );

    if ( stream.fail() || stream.gcount() != std::streamsize( cert_size ) )
    {
        fail( "FAILED TO READ PEM CERTIFICATE" );
    }

    cert_pem[ cert_size ] = 0;

    // Now, create a BIO to read the cert and get its public key

    BIO* cert_bio = BIO_new_mem_buf( cert_pem, cert_size );

    if ( ! cert_bio )
    {
        fail( "FAILED TO CREATE BIO FOR CERTIFICATE" );
    }

    X509* cert = PEM_read_bio_X509( cert_bio, NULL, NULL, NULL );

    BIO_free( cert_bio );

    if ( ! cert )
    {
        fail( "FAILED TO READ X509 CERTIFICATE" );
    }

    // Verify that the certificate is valid

    if ( ! verify_certificate( cert ) )
    {
        X509_free( cert );
        fail( "CERTIFICATE IS INVALID" );
    }

    // Get the certificate's fingerprint

    String fingerprint;

    if ( ! get_certificate_fingerprint( cert, fingerprint ) )
    {
        X509_free( cert );
        fail( "FAILED TO GET CERTIFICATE FINGERPRINT" );
    }

    // Get the certificate's subject name

    String subject_name;

    if ( ! get_certificate_subject_name( cert, subject_name ) )
    {
        X509_free( cert );
        fail( "FAILED TO GET CERTIFICATE SUBJECT NAME" );
    }

    // Get the public key

    EVP_PKEY* public_key = X509_get_pubkey( cert );

    X509_free( cert );

    if ( ! public_key )
    {
        fail( "FAILED TO GET CERTIFICATE PUBLIC KEY" );
    }

    // We are ready to verify the signature

    EVP_MD_CTX evp_ctx;

    if ( ! EVP_VerifyInit( &evp_ctx, EVP_sha1() ) )
    {
        EVP_MD_CTX_cleanup( &evp_ctx );
        EVP_PKEY_free( public_key );

        fail( "FAILED TO INITIALIZE SIGNATURE VERIFICATION" );
    }

    // Backup to the beginning of the stream

    stream.seekg( 0, std::ios_base::beg );

    std::streamsize data_left = data_size;

    static std::streamsize BUFFER_SIZE = 1024;

    char buffer[ BUFFER_SIZE ];

    // Pass each chunk of data to EVP_VerifyUpdate

    while ( data_left > 0 )
    {
        std::streamsize to_read = std::min( data_left , BUFFER_SIZE );

        stream.read( buffer, to_read );

        if ( stream.gcount() != to_read )
        {
            EVP_MD_CTX_cleanup( &evp_ctx );
            EVP_PKEY_free( public_key );

            fail( "FAILED TO READ STREAM CONTENTS" );
        }

        if ( ! EVP_VerifyUpdate( &evp_ctx, buffer, to_read ) )
        {
            EVP_MD_CTX_cleanup( &evp_ctx );
            EVP_PKEY_free( public_key );

            fail( "FAILED TO UPDATE SIGNATURE VERIFICATION" );
        }

        data_left -= to_read;
    }

    int verification_result = EVP_VerifyFinal( &evp_ctx, ( unsigned char* ) signature, signature_size, public_key );

    EVP_MD_CTX_cleanup( &evp_ctx );
    EVP_PKEY_free( public_key );

    if ( verification_result != 1 )
    {
        fail( "SIGNATURE IS NOT CORRECT : %d", verification_result );
    }

    // Now, we know that the signature is correct.

    // Set the fingerprint and subject name

    info.fingerprint = fingerprint;
    info.subject_name = subject_name;

    g_debug( "SIGNATURE IS GOOD" );
    g_debug( "  FINGERPRINT  : %s", info.fingerprint.c_str() );
    g_debug( "  SUBJECT NAME : %s", info.subject_name.c_str() );

    // This is the total size of the signature block, so that the
    // caller can call us again skipping this and get the next/inner
    // signature

    size = TP_SIGN_MARKER_LENGTH + 1 + 8 + signature_size + cert_size;

    return true;
}

//-----------------------------------------------------------------------------

bool Signature::get_signatures( std::istream& stream, Signature::Info::List& signatures, gsize* signature_length )
{
    signatures.clear();

    try
    {
        gsize skip_trailing_bytes = 0;

        gsize signature_size = 0;

        Info info;

        while ( get_signature( stream, skip_trailing_bytes, info, signature_size ) )
        {
            skip_trailing_bytes += signature_size;

            signatures.push_back( info );
        }

        if ( signature_length )
        {
            * signature_length = skip_trailing_bytes;
        }

        return true;
    }
    catch ( const String& e )
    {
        g_warning( "SIGNATURE VERIFICATION FAILED : %s", e.c_str() );
    }

    return false;
}

//-----------------------------------------------------------------------------

bool Signature::get_signatures( const gchar* filename, Signature::Info::List& signatures, gsize* signature_length )
{
    std::ifstream stream;

    stream.open( filename );

    if ( ! stream.good() )
    {
        g_warning( "FAILED TO OPEN FILE TO VERIFY SIGNATURE : %s", filename );

        return false;
    }

    bool result = get_signatures( stream, signatures, signature_length );

    stream.close();

    return result;
}

//-----------------------------------------------------------------------------

bool Signature::get_signatures( gpointer data, gsize size, Signature::Info::List& signatures, gsize* signature_length )
{
    imstream stream( ( char* ) data, size );

    return get_signatures( stream, signatures, signature_length );
}

//-----------------------------------------------------------------------------

