#include "notify.h"

//-----------------------------------------------------------------------------

void Notify::add_notification_handler( const char* subject, TPNotificationHandler handler, void* data )
{
    handlers.insert( std::make_pair( String( subject ), HandlerClosure( handler, data ) ) );
}

//-----------------------------------------------------------------------------

void Notify::remove_notification_handler( const char* subject, TPNotificationHandler handler, void* data )
{
    std::pair<HandlerMultiMap::iterator, HandlerMultiMap::iterator>
    range = handlers.equal_range( String( subject ) );

    for ( HandlerMultiMap::iterator it = range.first; it != range.second; )
    {
        if ( it->second.first == handler && it->second.second == data )
        {
            handlers.erase( it++ );
        }
        else
        {
            ++it;
        }
    }
}

//-----------------------------------------------------------------------------

void Notify::notify( TPContext* context , const char* subject )
{
    std::pair<HandlerMultiMap::const_iterator, HandlerMultiMap::const_iterator>
    range = handlers.equal_range( String( subject ) );

    for ( HandlerMultiMap::const_iterator it = range.first; it != range.second; ++it )
    {
        it->second.first( context , subject, it->second.second );
    }

    range = handlers.equal_range( String( "*" ) );

    for ( HandlerMultiMap::const_iterator it = range.first; it != range.second; ++it )
    {
        it->second.first( context , subject, it->second.second );
    }
}


