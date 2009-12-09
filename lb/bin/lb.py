#!/usr/bin/env python

import sys
import os
import pprint

def parse( source ):
    
    operators = [ "[[" , "]]" , "(" , "," , ")" , "{" , "}" , ";" , "=" ]
    
    def skip_white_space( i ):
                
        while ( ( i + 1 ) < len( source ) ) and ( source[ i : i + 1 ].isspace() ):
            
            i += 1

        return i
    
            
    def get_operator( i ):
        
        for op in operators:
            
            if source.startswith( op , i ):
                
                return ( True , op )
                
        return ( False , None )
            
    def get_token( i ):
        
        is_op , op = get_operator( i )
        
        if is_op:
            
            return op
                
        j = i
        
        while j < len( source ):
            
            if source[ j : j + 1 ].isspace():
                
                break
            
            is_op , op = get_operator( j )
            
            if is_op:
                
                break
            
            j += 1
        
        return source[ i : j ]
        

    i = 0
        
    tokens = []
    
    output = []
    
    while i < len( source ):
        
        i = skip_white_space( i )
        
        if i >= len( source ):
            
            break
                          
        token = get_token( i )
        
        if len( token ) == 0:
            
            break
            
        i += len( token )

        # Check for code chunks
        
        is_code = False
        
        if token == "[[":
            
            j = source.find( "]]" , i )
            
            if j == -1:
                
                sys.exit( "Missing closing ]]" )
                
            token = source[ i : j ]
            
            i = j + 2
            
            is_code = True
    
        # Now look for "marker" tokens
        
        if token == "{":
            
            if len( tokens ) not in [ 3 , 4 ]:
                
                sys.exit( "Bad bind" )
                                                
            if tokens[ 0 ] not in ( "class" , "global" , "interface" ):
                
                sys.exit( "Invalid type " + tokens[ 0 ] )
                
            inherits = None
            
            if len( tokens ) == 4:
                
                inherits = tokens[ 3 ]
                
            output.append( dict(
                type = tokens[ 0 ] ,
                name = tokens[ 1 ] ,
                udata = tokens[ 2 ] ,
                inherits = inherits ,
                properties = [] ,
                functions = [] )
            )
            
            tokens = []
            
        elif token == ";":
            
            # See if it is a function or property
            
            if ( len( tokens ) >= 3 ) and ( tokens[ 1 ] == "(" or tokens[ 2 ] == "(" ):
                                
                if tokens[ 2 ] == "(":
                    
                    name = tokens[ 1 ]
                    type = tokens[ 0 ]
                    pstart = 3
                    
                else:
                    
                    name = tokens[ 0 ]
                    type = None
                    pstart = 2
                    
                if tokens[ -1 ] != ")":
                    
                    code = tokens[ -1 ]
                    params = tokens[ pstart : -2 ]
                    
                else:
                    
                    code = None
                    params = tokens[ pstart : -1 ]
                
                parameters = []
                
                while len( params ) >= 2:
                    
                    param_type = params[ 0 ]
                    param_name = params[ 1 ]
                    param_default = None
                    
                    del params[ 0 : 2 ]
                    
                    if len( params ) > 0:
                        
                        if params[ 0 ] == ",":
                            
                            del params[ 0 : 1 ]
                            
                        elif params[ 0 ] == "=":
                            
                            if len( params ) < 2:

                                sys.exit( "Missing default value for " + param_name + " in " + name )
                                
                            param_default = params[ 1 ]
                            
                            del params[ 0 : 2 ]
                            
                        else:
                            
                            sys.exit( "Invalid parameters for " + name )
                                                    
                    parameters.append( dict( type = param_type , name = param_name , default = param_default ) )
                                    
                if len( params ) != 0:
                    
                    sys.exit( "Invalid parameters for " + name )
                
                output[ -1 ][ "functions" ].append( dict( name = name , type = type , parameters = parameters , code = code ) )
                
            
            else:
        
                # A property
                
                read_only = False
                
                if len( tokens ) > 0 and tokens[ 0 ] == "readonly":
                    
                    read_only = True
                    
                    del tokens[ 0 : 1 ]
                    
                if len( tokens ) < 2:
                    
                    sys.exit( "Bad property" )
                    
                type = tokens[ 0 ]
                name = tokens[ 1 ]
                
                get_code = None
                set_code = None
                
                if len( tokens ) > 2:
                    
                    get_code = tokens[ 2 ]
                    
                if len( tokens ) > 3:
                
                    set_code = tokens[ 3 ]
                
                
                output[ -1 ][ "properties" ].append( dict( type = type , name = name , read_only = read_only , get_code = get_code , set_code = set_code ) )
                    
            tokens = []
            
        elif token == "}":
            
            tokens = []
                                
        elif is_code and len( tokens ) == 0:
            
            output.append( dict( type = "code" , code = token ) )
            
        else:
            
            tokens.append( token )
    
    return output
    
    
def emit( stuff , f ):
    
    def emit_code( code ):

        f.write( code[ "code" ] )
        f.write( "\n" )
    
    def emit_bind( bind ):
        
        ctype = {
            "int"       : "int",
            "double"    : "lua_Number",
            "bool"      : "bool",
            "integer"   : "lua_Integer",
            "long"      : "long",
            "string"    : "const char*"
        }
        
        lua_check = {
            "int"       : "luaL_checkint",
            "double"    : "luaL_checknumber",
            "bool"      : "lua_toboolean",
            "integer"   : "luaL_checkinteger",
            "long"      : "luaL_checklong",
            "string"    : "luaL_checkstring"
        }
        
        lua_opt  = {
            "int"       : "luaL_optint",
            "double"    : "luaL_optnumber",
            "bool"      : "luaL_optint",
            "integer"   : "luaL_optinteger",
            "long"      : "luaL_optlong",
            "string"    : "luaL_optstring"            
        }

        lua_push  = {
            "int"       : "lua_pushinteger",
            "double"    : "lua_pushnumber",
            "bool"      : "lua_pushboolean",
            "integer"   : "lua_pushinteger",
            "long"      : "lua_pushinteger",
            "string"    : "lua_pushstring"            
        }
        
        
        def declare_local( param , index ):
            
            type = param[ "type" ]
            
            result = "%s %s(" % ( ctype[ type ] , param[ "name" ] );
            
            if param.get( "default" ) is not None:
                
                result += "%s(L,%d,%s));" % ( lua_opt[ type ] , index , param[ "default"] )
                
            else:
                
                result += "%s(L,%d));" % ( lua_check[ type ] , index )
                
            return result
            
        def flow_code( code ):
            
            if code is not None:
                for line in code.strip().splitlines():
                    f.write( "  " + line.strip() + "\n" )
        
        bind_name = bind[ "name" ]
        bind_type = bind[ "type" ]
        udata_type = bind[ "udata" ]
        metatable_name = "%s_METATABLE" % ( bind_name.upper() , )
        
        constructors = []
        destructors = []
        
        #-----------------------------------------------------------------------
        # METATABLE
        #-----------------------------------------------------------------------
        
        f.write(
            '\nstatic const char * %s = "%s";\n'
            %
            ( metatable_name , metatable_name )
        )
        
        #-----------------------------------------------------------------------
        # FUNCTIONS        
        #-----------------------------------------------------------------------

        for func in bind[ "functions" ]:
            
            if func[ "name" ] == bind_name:
                
                # This is a constructor
                
                constructors.append( func )
                
                continue
            
            elif func[ "name" ] == "~" + bind_name:
                
                destructors.append( func )
                
                continue
            
                            
            f.write(
                "\n"
                "int %s_%s(lua_State*L)\n"
                "{\n"
                "  %s self(*((%s*)lua_touserdata(L,1)));\n"
                %
                ( bind_name , func[ "name" ] , udata_type , udata_type )
            )
            
            for index , param in enumerate( func[ "parameters" ] ):
                
                f.write(
                    "  %s\n"
                    %
                    ( declare_local( param , index + 2 )  , )
                )
                
            if func[ "type" ] is not None:
                
                f.write(
                    "  %s result;\n"
                    % ( ctype[ func[ "type" ] ] ,  )
                )
                
                
            if func[ "code" ] is not None:
                
                flow_code( func[ "code"] )
                
            else:
                
                # TODO - here we should invoke the function on self
                
                pass
                
            if func[ "type" ] is not None:
                
                f.write(
                    "  %s(L,result);\n"
                    "  return 1;\n"
                    %
                    ( lua_push[ func[ "type" ] ] , ) 
                )
                
            else:
                
                f.write( "  return 0;\n" )
                
            f.write( "}\n" )
            
        #-----------------------------------------------------------------------
        # CONSTRUCTORS
        #-----------------------------------------------------------------------
        
        if len( constructors ) > 1:
            
            sys.exit( "Cannot overload constructor for " + bind_name )
            
        for func in constructors:
            
            f.write(
                "\n"
                "int new_%s(lua_State*L)\n"
                "{\n"
                "  %s* self((%s*)lua_newuserdata(L,sizeof(%s)));\n"
                "  luaL_getmetatable(L,%s);\n"
	        "  lua_setmetatable(L,-2);\n"
                "\n"
                %
                ( bind_name , udata_type , udata_type , udata_type , metatable_name )
            )
            
            for index , param in enumerate( func[ "parameters" ] ):
                
                f.write(
                    "  %s\n"
                    %
                    ( declare_local( param , index + 1 )  , )
                )
                
            if func[ "code" ] is not None:
                
                flow_code( func[ "code" ] )
                
            else:
                
                # TODO - default constructor behavior
                
                pass
            
            f.write(
                "  return 1;\n"
            )
                
            
                
            f.write( "}\n" )
            
        #-----------------------------------------------------------------------
        # DESTRUCTORS
        #-----------------------------------------------------------------------

        if len( destructors ) > 1:
            
            sys.exit( "Cannot overload destructor for " + bind_name )
            
        for func in destructors:
            
            f.write(
                "\n"
                "int delete_%s(lua_State*L)\n"
                "{\n"
                "  %s self(*((%s*)lua_touserdata(L,1)));\n"
                %
                ( bind_name , udata_type , udata_type )
            )
                
            if func[ "code" ] is not None:
                
                flow_code( func[ "code" ] )
                
            else:
                
                # TODO - default destructor behavior
                
                pass
            
            f.write( "  return 0;\n}\n" )
            
        #-----------------------------------------------------------------------
        # PROPERTIES
        #-----------------------------------------------------------------------
        
        for prop in bind[ "properties" ]:
            
            prop_type = prop[ "type" ]
            
            f.write(
                "\n"
                "int get_%s_%s(lua_State*L)\n"
                "{\n"
                "  %s self(*((%s*)lua_touserdata(L,1)));\n"
                "\n"
                %
                ( bind_name , prop[ "name" ] , udata_type , udata_type )
            )
          
            if prop[ "get_code" ] is not None:
                
                if prop_type != "table":
                
                    f.write(
                        "  %s %s;\n"
                        % ( ctype[ prop_type ] , prop[ "name" ] )
                    )
                
                flow_code( prop[ "get_code" ] )

                if prop_type != "table":
                    
                    f.write(
                        "  %s(L,%s);\n"
                        %
                        ( lua_push[ prop[ "type" ] ] , prop[ "name" ] ) 
                    )
                    
                f.write(
                    "  return 1;\n"
                    "}\n"
                    
                )
                
            else:
                
                # TODO : default property getter
                
                pass
            
            if not prop[ "read_only" ]:
                
                f.write(
                    "\n"
                    "int set_%s_%s(lua_State*L)\n"
                    "{\n"
                    "  %s self(*((%s*)lua_touserdata(L,1)));\n"
                    "\n"
                    %
                    ( bind_name , prop[ "name" ] , udata_type , udata_type )
                )
              
                if prop[ "set_code" ] is not None:
                    
                    if prop_type != "table":
                        
                        f.write(
                            "  %s\n"
                            %
                            ( declare_local( prop , 2 )  , )
                        )
                    
                    flow_code( prop[ "set_code" ] )
                    
                    f.write(
                        "  return 0;\n"
                        "}\n"
                    )
                    
                else:
                    
                    # TODO : default property getter
                    
                    pass
                
            
        
        #-----------------------------------------------------------------------
        # INITIALIZER
        #-----------------------------------------------------------------------
        
        f.write(
            "\n"
            "void luaopen_%s(lua_State*L)\n"
            "{\n"
            %
            ( bind_name , )
        )
        
        # Create the metatable
        
        f.write(
            "  luaL_newmetatable(L,%s);\n"
            %
            metatable_name
        )

        f.write(
            "  const luaL_Reg meta_methods[]=\n"
            "  {\n"
        )
        
        if len( destructors ) > 0:
            
            f.write(
                '    {"__gc",delete_%s},\n'
                %
                bind_name
            )
        
        if len( bind[ "properties"  ] ) > 0 or bind[ "inherits" ] is not None:
            
            f.write(
                '    {"__newindex",lb_newindex},\n'
                '    {"__index",lb_index},\n'
            )
            
        for func in bind[ "functions" ]:
            if func in constructors:
                continue
            if func in destructors:
                continue
            f.write(
                '    {"%s",%s_%s},\n'
                %
                ( func["name"] , bind_name , func["name"] )
            )
                    
        f.write(
            "    {NULL,NULL}\n"
            "  };\n"
        )
        
        f.write(
            "  luaL_register(L,NULL,meta_methods);\n"
        )
        
        # If there are no properties, we set the __index metafield to point to
        # the metatable itself - the methods will be found there by Lua
        
        if len( bind[ "properties" ] ) == 0:
            
            if bind[ "inherits" ] is None:
                
                f.write(
                    '  lua_pushstring(L,"__index");\n'
                    "  lua_pushvalue(L,-2);\n"
                    "  lua_rawset(L,-3);\n"
                )
        
        # Otherwise, we have to create the getters and setters tables and
        # put them in the metatable
        
        else:
            
            f.write(
                '  lua_pushstring(L,"__getters__");\n'
                "  lua_newtable(L);\n"
                "  const luaL_Reg getters[]=\n"
                "  {\n"
            )
                            
            setters = []
            
            for prop in bind[ "properties" ]:
                f.write(
                    '    {"%s",get_%s_%s},\n'
                    %
                    ( prop["name"] , bind_name , prop["name"] )
                )
                if not prop["read_only"]:
                    setters.append( prop )
                        
            f.write(
                "    {NULL,NULL}\n"
                "  };\n"
                "  luaL_register(L,NULL,getters);\n"
                "  lua_rawset(L,-3);\n"
            )

            if len( setters ) > 0:
                
                f.write(
                    '  lua_pushstring(L,"__setters__");\n'
                    "  lua_newtable(L);\n"
                    "  const luaL_Reg setters[]=\n"
                    "  {\n"
                )
                                
                for prop in setters:
                    f.write(
                        '    {"%s",set_%s_%s},\n'
                        %
                        ( prop["name"] , bind_name , prop["name"] )
                    )
                            
                f.write(
                    "    {NULL,NULL}\n"
                    "  };\n"
                    "  luaL_register(L,NULL,setters);\n"
                    "  lua_rawset(L,-3);\n"
                )
                
        if bind[ "inherits" ] is not None:
            
            f.write(
                '  lb_inherit(L,"%s_METATABLE");\n'
                %
                bind[ "inherits" ].upper()
            )

        # Pop the metatable
        
        f.write(
            "  lua_pop(L,1);\n"
        )
        
        # This is a global singleton
        
        if bind_type == "global":
            
            # Call its constructor, which will leave the user data
            # on the stack
            
            f.write(
                "  new_%s(L);\n"
                '  lua_setglobal(L,"%s");\n'
                %
                ( bind_name , bind_name )
            )
        
        # Otherwise, it is a class
        
        elif bind_type == "class":
            
            if len( constructors ) == 0:
                
                sys.exit( "No constructor for " + bind_name )
                
            f.write(
                "  lua_pushcfunction(L,new_%s);\n"
                '  lua_setglobal(L,"%s");\n'
                %
                ( bind_name , bind_name )                
            )
            
        
        f.write( "}\n" )
        
        #-----------------------------------------------------------------------
        
    
    f.write( '#include "lb.h"\n' );

    for thing in stuff:
        
        if thing[ "type" ] == "code":
            
            emit_code( thing )
        
        elif thing[ "type" ] in [ "class" , "global" , "interface" ]:
            
            emit_bind( thing )
            
        else:
            
            sys.exit( "Unknown " + thing[ "type" ] )
        
        
if __name__ == "__main__":

    for f in sys.argv[1:]:
        
        output = open( os.path.splitext( os.path.basename( f ) )[ 0 ] + ".cpp" , "w")
        
        binding = parse( open( f ).read() )
        
#        pprint.pprint( binding )
        
        emit( binding , output )
        
        output.close()