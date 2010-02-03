#!/usr/bin/env python

import sys
import os
import pprint
from optparse import OptionParser

line = 1
file_name = None
module = None
initializers = []
globals = []
options = None

def parse( source ):
    
    global line
    global file_name
    global options
    
    operators = [ "[[" , "]]" , "(" , "," , ")" , "{" , "}" , ";" , "=" , "#" , "/*" , "*/"]
    
    def skip_white_space( i ):

        global line                
                
        while ( ( i + 1 ) < len( source ) ) and ( source[ i : i + 1 ].isspace() ):
            
            if source[ i : i + 1 ] == "\n":
                
                line += 1

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
    
    lines = []
    
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
                
            if options.lines:
                line_directive = '#line %d "%s"\n' % ( line , file_name )
            else:
                line_directive = "\n"
            
            token = line_directive + source[ i : j ]
            
            line -= 1
            
            for c in token:
                if c == "\n":
                    line += 1
                    
            i = j + 2
            
            is_code = True
            
        elif token == "/*":
            
            j = source.find( "*/" , i )
            
            for c in token:
                if c == "\n":
                    line += 1
                    
            i = j + 2
            
            continue
            
        elif token == "#":
            
            while i < len(source):
                
                if source[i:i+1] == "\n":
                    
                    i += 1
                    break
                
                i += 1 
                
            line += 1
            
            continue
            
        # Now look for "marker" tokens
        
        if token == "{":
            
            if len( tokens ) == 1:
                
                if tokens[ 0 ] != "globals":
                    
                    sys.exit( "Band bind" )
                    
                else:
                    
                    output.append( dict(
                        type = tokens[ 0 ] ,
                        name = "<<<NONE>>>" ,
                        udata = None ,
                        inherits = None ,
                        properties = [] ,
                        functions = [] )
                    )
                    
            else:
                    
                if len( tokens ) < 3:
                    
                    sys.exit( "Bad bind" )
                                                    
                if tokens[ 0 ] not in ( "class" , "global" , "interface" ):
                    
                    sys.exit( "Invalid type " + tokens[ 0 ] )
                    
                inherits = None
                
                t = 3
                
                while t < len( tokens ):
                    
                    if tokens[ t ] != ",":
                    
                        if inherits is None:
                            
                            inherits = []
                        
                        inherits.append( tokens[ t ] )
                    
                    t += 1
                    
                # This is to remove the #line directive we added earlier.
                # It does not belong in the type
                
                udata = "\n".join(tokens[2].splitlines()[1:])
                    
                output.append( dict(
                    type = tokens[ 0 ] ,
                    name = tokens[ 1 ] ,
                    udata = udata ,
                    inherits = inherits ,
                    properties = [] ,
                    functions = [] )
                )
            
            tokens = []
            
        elif token == ";":
            
            # See if it is a function, property or module
            
            if ( len( tokens ) == 2 ) and ( tokens[ 0 ] == "module" ):
                
                output.append( dict( type = "module" , name = tokens[ 1 ] ) )
                
                tokens = []
            
            elif ( len( tokens ) >= 3 ) and ( tokens[ 1 ] == "(" or tokens[ 2 ] == "(" ):
                                
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
                            
                            del params[ 0 : 3 ]
                            
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
            
            if len(tokens) > 0:
                sys.exit( "Something missing" );
                
            tokens = []
                                
        elif is_code and len( tokens ) == 0:
            
            output.append( dict( type = "code" , code = token ) )
            
        else:
            
            tokens.append( token )
    
    return output
    
    
def emit( stuff , f ):
    
    global globals
    
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
            "string"    : "const char*",
            "lstring"   : "const char*",
            "table"     : "int",
            "function"  : "int",
            "udata"     : "int",
        }
        
        lua_check = {
            "int"       : "luaL_checkint",
            "double"    : "luaL_checknumber",
            "bool"      : "lua_toboolean",
            "integer"   : "luaL_checkinteger",
            "long"      : "luaL_checklong",
            "string"    : "luaL_checkstring",
            "lstring"   : "luaL_checklstring",
            "table"     : "lb_checktable",
            "function"  : "lb_checkfunction",
            "udata"     : "lb_checkudata"
        }
        
        lua_opt  = {
            "int"       : "lb_optint",
            "double"    : "lb_optnumber",
            "bool"      : "lb_optint",
            "integer"   : "lb_optint",
            "long"      : "lb_optint",
            "string"    : "lb_optstring",
            "lstring"   : "lb_optlstring",
            "table"     : "lb_opttable",
            "function"  : "lb_optfunction",
            "udata"     : "lb_optudata"
            
        }

        lua_push  = {
            "int"       : "lua_pushinteger",
            "double"    : "lua_pushnumber",
            "bool"      : "lua_pushboolean",
            "integer"   : "lua_pushinteger",
            "long"      : "lua_pushinteger",
            "string"    : "lua_pushstring",
            "lstring"   : "lua_pushlstring",
            "table"     : "lua_pushvalue",
            "function"  : "lua_pushvalue",
            "udata"     : "lua_pushvalue"
        }
        
        
        def declare_local( param , index ):
            
            type = param[ "type" ]
            
            result = ""
            extra = ""
            
            if type == "lstring":
                
                result += "size_t %s_len=0;\n" % param[ "name" ]
                
                extra = ",&%s_len" % param[ "name" ]
                
            
            
            result += "%s %s(" % ( ctype[ type ] , param[ "name" ] )
            
            if param.get( "default" ) is not None:
                
                result += "%s(L,%d,%s%s));" % ( lua_opt[ type ] , index , param[ "default"] , extra )
                
            else:
                
                result += "%s(L,%d%s));" % ( lua_check[ type ] , index , extra )
                
                
            return result
        
        def write_push_result( type ):
            
            if type == "lstring":
                
                f.write(
                    "  if (!result)\n"
                    "    lua_pushnil(L);\n"
                    "  else\n"
                    "    %s(L,result,result_len);\n" % lua_push[ type ]
                )
                
            else:
                
                f.write( "  %s(L,result);\n" % lua_push[ type ] )
            
        def flow_code( code ):
            
            if code is not None:
                code = code.strip()
                for line in code.splitlines():
                    f.write( "  " + line.strip() + "\n" )
        
        bind_name = bind[ "name" ]
        bind_type = bind[ "type" ]
        udata_type = bind[ "udata" ]
        metatable_name = "%s_METATABLE" % ( bind_name.upper() , )
        
        constructors = []
        destructors = []
        
        #-----------------------------------------------------------------------
        # GLOBALS
        #-----------------------------------------------------------------------
                
        if bind_type == "globals":
            
            for func in bind[ "functions" ]:
                
                globals.append( func["name"] )
                                                
                f.write(
                    "\n"
                    "int global_%s(lua_State*L)\n"
                    "{\n"
                    %
                    func[ "name" ]
                )
                
                for index , param in enumerate( func[ "parameters" ] ):
                    
                    f.write(
                        "  %s\n"
                        %
                        ( declare_local( param , index + 1 )  , )
                    )
                    
                if func[ "type" ] not in [ None , "table" , "udata" , "multi" ]:
                    
                    f.write(
                        "  %s result;\n"
                        % ( ctype[ func[ "type" ] ] ,  )
                    )
                    
                    if func[ "type" ] == "lstring":
                        
                        f.write( "  size_t result_len=0;\n" )
                    
                if func[ "code" ] is not None:
                    
                    flow_code( func[ "code"] )
                    
                else:
                    
                    # TODO - here we should invoke the function on self
                    
                    pass
                    
                if func[ "type" ] == "multi":
                    
                    pass
                
                elif func[ "type" ] is None:
                    
                    f.write( "  return 0;\n" )
                    
                elif func[ "type" ] in [ "table" , "udata" ]:
                    
                    f.write( "  return 1;\n" );
            
                else:
                    
                    write_push_result( func[ "type" ] )
                    f.write( "  return 1;\n" )
                    
                f.write( "}\n" )
            
        else:
        
            #-----------------------------------------------------------------------
            # METATABLE
            #-----------------------------------------------------------------------
            
            f.write(
                '\nstatic const char * %s = "%s";\n'
                %
                ( metatable_name , metatable_name )
            )
            
            #-----------------------------------------------------------------------
            # WRAPPER
            #-----------------------------------------------------------------------
            
            f.write(
                "\n"
                "int wrap_%s(lua_State*L,%s self)\n"
                "{\n"
                %
                (bind_name,udata_type)
            )
            
            if options.instrument:
                
                f.write(
                    "  int result=lb_wrap(L,self,%s);\n"
                    "  if(result)\n"
                    '    g_debug("CREATED %s %%p",self);\n'
                    "  return result;\n"
                    "}\n"
                        %
                        (metatable_name , bind_name )
                )
            else:
                
                f.write(
                    "  return lb_wrap(L,self,%s);\n"
                    "}\n"
                    %
                    metatable_name
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
                    
                    # Destructor
                    
                    destructors.append( func )
                    
                    continue
                
                                
                f.write(
                    "\n"
                    "int %s_%s(lua_State*L)\n"
                    "{\n"
                    "  luaL_checktype(L,1,LUA_TUSERDATA);\n"
                    "  %s self(lb_get_self(L,%s));\n"
                    %
                    ( bind_name , func[ "name" ] , udata_type , udata_type )
                )
                
                for index , param in enumerate( func[ "parameters" ] ):
                    
                    f.write(
                        "  %s\n"
                        %
                        ( declare_local( param , index + 2 )  , )
                    )
                    
                if func[ "type" ] not in [ None , "table" , "udata" , "multi" ]:
                    
                    f.write(
                        "  %s result;\n"
                        % ( ctype[ func[ "type" ] ] ,  )
                    )
                    
                    if func[ "type" ] == "lstring":
                        
                        f.write( "  size_t result_len=0;\n" )
                    
                if func[ "code" ] is not None:
                    
                    flow_code( func[ "code"] )
                    
                else:
                    
                    # TODO - here we should invoke the function on self
                    
                    pass
                
                if func[ "type" ] == "multi":
                    
                    pass
                    
                elif func[ "type" ] is None:
                    
                    f.write( "  return 0;\n" )
                    
                elif func[ "type" ] in [ "table" , "udata" ]:
                    
                    f.write( "  return 1;\n" );
            
                else:
                    
                    write_push_result( func[ "type" ] )
                    f.write( "  return 1;\n" )
                    
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
                    "  %s* self(lb_new_self(L,%s));\n"
                    "  luaL_getmetatable(L,%s);\n"
                    "  lua_setmetatable(L,-2);\n"
                    "\n"
                    %
                    ( bind_name , udata_type , udata_type , metatable_name )
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
                
                f.write("  lb_store_weak_ref(L,lua_gettop(L),*self);\n");
                
                if options.instrument:
                    
                    f.write(
                        '  g_debug("CREATED %s %%p",*self);\n'
                        %
                        bind_name );
                
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
                    "  %s self(lb_get_self(L,%s));\n"
                    %
                    ( bind_name , udata_type , udata_type )
                )
                
                if options.instrument:
                    
                    f.write(
                        '  g_debug("DESTROYED %s %%p",self);\n'
                        %
                        bind_name );
                
                    
                if func[ "code" ] is not None:
                    
                    flow_code( func[ "code" ] )
                    
                else:
                    
                    # TODO - default destructor behavior
                    
                    pass
                
                f.write( "  return 0;\n}\n" )
            
                
            #-----------------------------------------------------------------------
            # PROPERTIES
            #-----------------------------------------------------------------------
            
            callbacks = []
            
            for prop in bind[ "properties" ]:
                
                prop_type = prop[ "type" ]
                
                if prop_type == "callback":
                    
                    callbacks.append( prop )
                    
                    continue
                
                f.write(
                    "\n"
                    "int get_%s_%s(lua_State*L)\n"
                    "{\n"
                    "  %s self(lb_get_self(L,%s));\n"
                    %
                    ( bind_name , prop[ "name" ] , udata_type , udata_type )
                )
              
                if prop[ "get_code" ] is not None:
                    
                    if prop_type not in( "table" , "function" , "udata" , "multi" ):
                    
                        f.write(
                            "  %s %s;\n"
                            % ( ctype[ prop_type ] , prop[ "name" ] )
                        )
                        
                        if prop_type == "lstring":
                            
                            f.write( "  size_t %s_len=0;\n" % prop[ "name" ] )
                    
                    flow_code( prop[ "get_code" ] )
    
                    if prop_type not in ( "table" , "function" , "udata" , "multi" ):
                        
                        if prop_type == "lstring":
                            
                            f.write(
                                "  if (!%s)\n"
                                "    lua_pushnil(L);\n"
                                "  else\n"
                                "    %s(L,%s,%s_len);\n"
                                %
                                ( prop["name"],lua_push[ prop[ "type" ] ] , prop[ "name" ] , prop[ "name" ] ) 
                            )                        
                            
                        else:
                            
                            f.write(
                                "  %s(L,%s);\n"
                                %
                                ( lua_push[ prop[ "type" ] ] , prop[ "name" ] ) 
                            )
                        
                    if prop_type not in ( "multi" ):
                        
                        f.write( "  return 1;\n" )
                        
                    f.write( "}\n" )
                        
                else:
                    
                    # TODO : default property getter
                    
                    pass
                
                if not prop[ "read_only" ]:
                    
                    f.write(
                        "\n"
                        "int set_%s_%s(lua_State*L)\n"
                        "{\n"
                        "  %s self(lb_get_self(L,%s));\n"
                        %
                        ( bind_name , prop[ "name" ] , udata_type , udata_type )
                    )
                  
                    if prop[ "set_code" ] is not None:
                        
                        if prop_type not in ( "table" , "function" , "udata" ):
                            
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
            # CALLBACKS
            #-----------------------------------------------------------------------
                
            for cb in callbacks:
    
                f.write(
                    "\n"
                    "int get_%s_%s(lua_State*L)\n"
                    "{\n"
                    '  return lb_get_callback(L,lb_get_self(L,%s),"%s",0);\n'
                    "}\n"
                    %
                    ( bind_name , cb[ "name" ] , udata_type , cb[ "name" ] )
                )
                
                f.write(
                    "\n"
                    "int set_%s_%s(lua_State*L)\n"
                    "{\n"
                    "  %s self(lb_get_self(L,%s));\n"
                    '  int %s(!lb_set_callback(L,self,"%s"));\n'
                    %
                    ( bind_name , cb[ "name" ] , udata_type , udata_type , cb[ "name" ] , cb[ "name" ] )
                )
                    
                flow_code( cb[ "get_code" ] );                
                    
                f.write(
                    "  return 0;\n"
                    "}\n"
                )                
                
                f.write(
                    "\n"
                    "int invoke_%s_%s(lua_State*L,%s self,int nargs,int nresults)\n"
                    "{\n"
                    '  return lb_invoke_callback(L,self,%s,"%s",nargs,nresults);\n'
                    "}\n"
                    %
                    ( bind_name , cb[ "name" ] , udata_type , metatable_name , cb[ "name" ] )
                )
                
            if len(callbacks) > 0:
                
                f.write(
                    "\n"
                    "void detach_%s(lua_State*L,%s self)\n"
                    "{\n"
                    "  lb_clear_callbacks(L,self,%s);\n"
                    "}\n"
                    %
                    (bind_name , udata_type , metatable_name )
                )
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
            
            initializers.append( bind_name );
            
            # Create the metatable
            
            f.write(
                "  luaL_newmetatable(L,%s);\n"
                '  lua_pushstring(L,"type");\n'
                '  lua_pushstring(L,"%s");\n'
                "  lua_rawset(L,-3);\n"
                %
                (metatable_name,bind_name)
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
            
            if len( bind[ "properties"  ] ) > 0 or ( bind[ "inherits" ] is not None ):
                
                if bind[ "inherits" ] is not None and "table" in bind[ "inherits" ] :
                
                    pass
                
                else:
                
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
                
                for inh in bind[ "inherits" ]:
                    
                    if inh != "table":
                        
                        f.write(
                            '  lb_inherit(L,"%s_METATABLE");\n'
                            %
                            inh.upper()
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
    
    module = None
    initializers  = []
    globals = []

    for thing in stuff:
        
        if thing[ "type" ] == "code":
            
            emit_code( thing )
        
        elif thing[ "type" ] in [ "class" , "global" , "interface" , "globals" ]:
            
            emit_bind( thing )
            
        elif thing[ "type" ] == "module":
            
            module = thing[ "name" ]
            
        else:
            
            sys.exit( "Unknown " + thing[ "type" ] )
            
    if ( module is not None ) and ( ( len( initializers ) > 0 ) or ( len(globals) >0 ) ):
        
        f.write(
            "\n"
            "void luaopen_%s(lua_State*L)\n"
            "{\n"            
            % module
        )
        
        for init in initializers:
            f.write(
                "  luaopen_%s(L);\n"
                % init
            )
            
        for g in globals:
            f.write(
                "  lua_pushcfunction(L,global_%s);\n"
                '  lua_setglobal(L,"%s");\n'
                %
                ( g , g )
            )
            
        f.write( "}\n" )
        
        
if __name__ == "__main__":
    
    parser = OptionParser()
    parser.add_option( "-l" , "--lines" , action="store_true" , default=False , help="Include #line directives" )
    parser.add_option( "-i" , "--instrument" , action="store_true" , default=False , help="Add instrumentation" )
    (options,args) = parser.parse_args()
    
    for file_name in args:
        
        output = open( os.path.basename( file_name ) + ".cpp" , "w")
        
        binding = parse( open( file_name ).read() )
        
#        pprint.pprint( binding )
        
        emit( binding , output )
        
        output.close()