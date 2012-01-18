
var next_id = 100

var objects = {}

var generate_event = null

function post_event( event )
{
    if ( generate_event )
    {
        setTimeout( generate_event , 1 , event );
    }
}

function create_object( type , properties )
{
    var object = {};
    
    object.id = next_id;
    object.type = type;
    object.properties = properties
    
    object.speak = function(  )
    {
        var what = arguments[ 0 ];
        var when = arguments[ 1 ];

        post_event( { "id" : this.id , "event" : "on_speak" , "args" : [ what ] } );
        
        return what + " (I SAID IT)";
    };
    
    if ( type == "Group" )
    {
        object.children = [];
        
        object.add = function( )
        {
            for ( var i = 0; i < arguments.length; ++i )
            {
                var child = objects[ arguments[ i ] ];
                
                if ( child )
                {
                    this.children.push( child );
                }
            }
        };
        
        object.remove = function()
        {
            for ( var i = 0; i < arguments.length; ++i )
            {
                var child = objects[ arguments[ i ] ];
                
                if ( child )
                {
                    for ( var j = 0; j < this.children.length; ++j )
                    {
                        if ( this.children[ j ] == child )
                        {
                            this.children.splice( j , 1 );
                            break;
                        }
                    }
                    
                }
            }                
        };
        
        object.clear = function()
        {
            this.children = [];    
        };
        
        object.find_child = function( name )
        {
            for ( var i = 0; i < this.children.length; ++i )
            {
                var child = this.children[ i ];
                
                if ( child.properties.name == name )
                {
                    return { "id" : child.id , "type" : child.type };                    
                }
            }
            
            return null
        };
        
        object.get_children = function( )
        {
            var result = [];
            
            for ( var i = 0; i < this.children.length; ++i )
            {
                var child = this.children[ i ];
                
                result.push( { "id" : child.id , "type" : child.type } )
            }
            
            return result
        };
        
        object.set_children = function( children )
        {
            this.children = []
            
            for ( var i = 0; i < children.length; ++i )
            {
                var child = objects[ children[ i ] ]
                
                if ( child )
                {
                    this.children.push( child )
                }
            }
        };
    }
    
    
    objects[ next_id ] = object
    
    var result = { "id" : next_id };
    
    next_id++;
    
    return result;
}

function object_set( id , properties )
{
    var object = objects[ id ];
    
    if ( object )
    {
        for ( var prop in properties )
        {
            object.properties[ prop ] = properties[ prop ];
        }
    }
    
    return {}
}

function object_get( id , properties )
{
    var object = objects[ id ];
    
    var result = { "properties" : {} }
    
    if ( object )
    {
        for ( var prop in properties )
        {
            result.properties[ prop ] = object.properties[ prop ];
        }
    }
    
    return result
}

function object_delete( id , properties )
{
    var object = objects[ id ];
    
    if ( object )
    {
        for ( var prop in properties )
        {
            delete object.properties[ prop ];
        }
    }
    
    return {}
}

function object_call( id , function_name , args )
{
    var object = objects[ id ];
    
    var result = null
    
    if ( object )
    {
        var f = object[ function_name ];
        
        if ( f )
        {
            if ( ! ( args instanceof Array ) )
            {
                args = [];
            }
            
            result = f.apply( object , args );
        }
    }
    
    return { "result" : result };
}

function process_request( response , path , body )
{
    console.log( "  < " + body );
    
    var payload = JSON.parse( body );
    var result = null
    
    if ( path == '/create' )
    {
        result = create_object( payload.type , payload.properties )
    }
    else if ( path == '/set' )
    {
        result = object_set( payload.id , payload.properties );
    }
    else if ( path == '/get' )
    {
        result = object_get( payload.id , payload.properties );
    }
    else if ( path == '/delete' )
    {
        result = object_delete( payload.id , payload.properties );
    }
    else if ( path == '/call' )
    {
        result = object_call( payload.id , payload.call , payload.args );
    }

    if ( result == null )
    {
        console.log( "RESPONSE IS NULL" );
        response.writeHead( 404 );
        response.end();
    }
    else
    {
        console.log( "  > " + JSON.stringify( result ) );
        response.writeHead( 200 , { 'Content-Type' : 'application/json' } );
        response.end( JSON.stringify( result ) );
    }
}

function handle_request( req , res )
{
    var url = require( 'url' ).parse( req.url )
    var path = url.pathname
    
    console.log( path );
    
    if ( req.method == 'POST' )
    {
        var body = '';
        
        req.on( 'data' , function( data ) { body += data; } );
        req.on( 'end' , function() { process_request( res , path , body ) } );
    }
    else if ( req.method == 'GET' && path == '/events' )
    {
        // Make sure this connection does not timeout
        
        res.connection.setTimeout( 0 );
        
        // In this case, we keep the response open and install a new
        // generate_event function that writes the JSON chunk to the response.
        
        generate_event = function( event )
        {
            event = JSON.stringify( event )
            
            console.log( "event" );
            console.log( "  > " + event );
            
            res.write( event + "\n" );
        };
            
        // We also watch for the connection closing and reset the generate_event
        // function to one that does nothing.
            
        function disconnect()
        {
            console.log( "* EVENTS DISCONNECTED" );
            generate_event = null;
        }
        
        res.connection.on( 'close' , disconnect );        
    }
    else
    {
        res.writeHead( 404 );
        res.end();
    }
}

var http = require('http');

http.createServer( handle_request ).listen( 1337 , "127.0.0.1" );

console.log( 'READY' );