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

            for c in source[ i : j ]:
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
                        restricted = False ,
                        inherits = None ,
                        properties = [] ,
                        functions = [] ,
                        constants = [] )
                    )

            else:

            	restricted = False

                if len( tokens ) < 3:

                    sys.exit( "Bad bind" )

                if tokens[ 0 ] == "restricted":

                	restricted = True

                	del tokens[ 0 : 1 ]


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
                    restricted = restricted ,
                    inherits = inherits ,
                    properties = [] ,
                    functions = [] ,
                    constants = [] ,
                    typedefs = {} )
                )

            tokens = []

        elif token == ";":

            # See if it is a function, property or module

            if ( len( tokens ) == 2 ) and ( tokens[ 0 ] == "module" ):

                output.append( dict( type = "module" , name = tokens[ 1 ] ) )

                tokens = []

            elif ( len( tokens ) == 3 ) and ( tokens[ 0 ] == "typedef" ):

                output[ -1 ][ "typedefs" ][ tokens[ 2 ] ] = tokens[ 1 ]

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

                if len( params ) == 1 and params[0]== "..." :

                    pass

                elif len( params ) != 0:

                    sys.exit( "Invalid parameters for " + name )

                if type == "callback":

                    output[ -1 ][ "properties" ].append( dict( type = type , name = name , read_only = False , get_code = code , set_code = None ) )

                else:

                    output[ -1 ][ "functions" ].append( dict( name = name , type = type , parameters = parameters , code = code ) )

            elif ( len( tokens ) == 5) and ( tokens[0] == "const" ):

                # A constant

                output[ -1 ][ "constants" ].append( dict( name=tokens[2] , type=tokens[1] , value=tokens[4] ) )

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


def emit( stuff , f , header ):

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
            "any"       : "int"
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
            "udata"     : "lb_checkudata",
            "any"       : "lb_checkany"
        }

        lua_opt  = {
            "int"       : "lb_optint",
            "double"    : "lb_optnumber",
            "bool"      : "lb_optbool",
            "integer"   : "lb_optint",
            "long"      : "lb_optint",
            "string"    : "lb_optstring",
            "lstring"   : "lb_optlstring",
            "table"     : "lb_opttable",
            "function"  : "lb_optfunction",
            "udata"     : "lb_optudata",
            "any"       : "lb_optany"

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
            "udata"     : "lua_pushvalue",
            "any"       : "lua_pushvalue"
        }


        base_types= [
            "int",
            "double",
            "bool",
            "integer",
            "long",
            "string",
            "lstring",
            "table",
            "function",
            "udata",
            "callback",
            "multi",
            "any"
        ]

        def transform_type( type ):
            if type is None:
                return None
            elif type == "void":
                return None
            elif type in base_types:
                return type
            else:
                rt = bind[ "typedefs" ].get( type )
                if not rt is None:
                    return rt
                else:
                    return "udata"

        def declare_local( param , index ):

            type = transform_type( param[ "type" ] )

            result = ""
            extra = ""

            if type == "lstring":

                result += "size_t %s_len=0;\n" % param[ "name" ]

                extra = ",&%s_len" % param[ "name" ]



            result += "MIGHT_BE_UNUSED %s %s(" % ( ctype[ type ] , param[ "name" ] )

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

        def profiling_header(name):

            result = ""

            if options.tracing:
                result = result + "  g_debug(\"[TRACING] : %s\",__FUNCTION__);\n"

            if options.profiling:
                result = result + "  PROFILER(__FUNCTION__,PROFILER_CALLS_FROM_LUA);\n"

            return result

        bind_name = bind[ "name" ]
        bind_type = bind[ "type" ]
        udata_type = bind[ "udata" ]
        bind_restricted = bind[ "restricted" ]
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
                    "%s"
                    %
                    ( func[ "name" ] , profiling_header(func["name"]) )
                )


                for index , param in enumerate( func[ "parameters" ] ):

                    f.write(
                        "  %s\n"
                        %
                        ( declare_local( param , index + 1 )  , )
                    )

                func_type=transform_type(func[ "type" ])

                if func_type not in [ None , "table" , "udata" , "multi" , "any" ]:

                    f.write(
                        "  %s result;\n"
                        % ( ctype[ func_type ] ,  )
                    )

                    if func_type == "lstring":

                        f.write( "  size_t result_len=0;\n" )

                if func[ "code" ] is not None:

                    flow_code( func[ "code"] )

                else:

                    # TODO - here we should invoke the function on self

                    pass

                if func_type == "multi":

                    pass

                elif func_type is None:

                    f.write( "  return 0;\n" )

                elif func_type in [ "table" , "udata" , "any" ]:

                    f.write( "  return 1;\n" );

                else:

                    write_push_result( func_type )

                    f.write( "  return 1;\n" )

                f.write( "}\n" )

        else:

            #-----------------------------------------------------------------------
            # GETTER FROM UDATA
            #-----------------------------------------------------------------------
            
            header.write( '#define LB_GET_%s(L,i) ((%s)lb_get_udata_check(L,i,"%s"))\n' % ( bind_name.upper() , udata_type , bind_name ) )

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

            #f.write(
            #    "\n"
            #    "int wrap_%s(lua_State*L,%s self)\n"
            #    "{\n"
            #    %
            #    (bind_name,udata_type)
            #)
            #
            #if options.profiling:
            #
            #    f.write(
            #        "  int result=lb_wrap(L,self,%s);\n"
            #        "  if(result)\n"
            #        '    PROFILER_CREATED("%s",self);\n'
            #        "  return result;\n"
            #        "}\n"
            #            %
            #            (metatable_name , bind_name )
            #    )
            #else:
            #
            #    f.write(
            #        "  return lb_wrap(L,self,%s);\n"
            #        "}\n"
            #        %
            #        metatable_name
            #    )

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
                    "%s"
                    "  luaL_checktype(L,1,LUA_TUSERDATA);\n"
                    "  MIGHT_BE_UNUSED %s self(lb_get_self(L,%s));\n"
                    %
                    ( bind_name , func[ "name" ] , profiling_header("%s_%s"%(bind_name,func["name"])) , udata_type , udata_type )
                )


                for index , param in enumerate( func[ "parameters" ] ):

                    f.write(
                        "  %s\n"
                        %
                        ( declare_local( param , index + 2 )  , )
                    )

                func_type=transform_type(func[ "type" ])

                if func_type not in [ None , "table" , "udata" , "multi" , "any" ]:

                    f.write(
                        "  %s result;\n"
                        % ( ctype[ func_type ] ,  )
                    )

                    if func_type == "lstring":

                        f.write( "  size_t result_len=0;\n" )

                if func[ "code" ] is not None:

                    flow_code( func[ "code"] )

                else:

                    # TODO - here we should invoke the function on self

                    pass

                if func_type == "multi":

                    pass

                elif func_type is None:

                    f.write( "  return 0;\n" )

                elif func_type in [ "table" , "udata" , "any" ]:

                    f.write( "  return 1;\n" );

                else:

                    write_push_result( func_type )
                    f.write( "  return 1;\n" )

                f.write( "}\n" )

            #-----------------------------------------------------------------------
            # CONSTRUCTORS
            #-----------------------------------------------------------------------

            if len( constructors ) > 1:

                sys.exit( "Cannot overload constructor for " + bind_name )

	    elif len ( constructors ) == 0:

		constructors.append( dict( code = None , parameters = [] ) )

            for func in constructors:

                f.write(
                    "\n"
                    "int new_%s(lua_State*L)\n"
                    "{\n"
                    "%s"
                    %
                    ( bind_name , profiling_header("new_%s"%bind_name) )
                )

                for index , param in enumerate( func[ "parameters" ] ):

                    f.write(
                        "  %s\n"
                        %
                        ( declare_local( param , index + 1 )  , )
                    )

                f.write(

                    '  UserData * __ud__ = UserData::make( L , "%s" );\n'
                    "  luaL_getmetatable(L,%s);\n"
                    "  lua_setmetatable(L,-2);\n"
		            "  MIGHT_BE_UNUSED %s self=0;\n"
                    "\n"
                    %
                    ( bind_name , metatable_name, udata_type )
                )

                if func[ "code" ] is not None:

                    flow_code( func[ "code" ] )

                else:

		            f.write( "  lb_construct_empty();\n" )


                f.write("  lb_check_initialized();\n")

                if options.profiling:

                    f.write(
                        '  PROFILER_CREATED("%s",self);\n'
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

	    elif len( destructors ) == 0:

		destructors.append( dict( code = None ) )


            for func in destructors:

                f.write(
                    "\n"
                    "int delete_%s(lua_State*L)\n"
                    "{\n"
                    "%s"
                    "MIGHT_BE_UNUSED %s self(lb_get_self(L,%s));\n"
                    %
                    ( bind_name , profiling_header("delete_%s"%bind_name) , udata_type , udata_type )
                )

                if options.profiling:

                    f.write(
                        '  PROFILER_DESTROYED("%s",self);\n'
                        %
                        bind_name );


                if func[ "code" ] is not None:

                    flow_code( func[ "code" ] )

                else:

                    # TODO - default destructor behavior

                    pass

		f.write( "  lb_finalize_user_data(L);\n" )
                f.write( "  return 0;\n}\n" )


            #-----------------------------------------------------------------------
            # PROPERTIES
            #-----------------------------------------------------------------------

            callbacks = []

            for prop in bind[ "properties" ]:

                prop_type = transform_type(prop[ "type" ])

                if prop_type == "callback":

                    callbacks.append( prop )

                    continue

                f.write(
                    "\n"
                    "int get_%s_%s(lua_State*L)\n"
                    "{\n"
                    "%s"
                    "MIGHT_BE_UNUSED %s self(lb_get_self(L,%s));\n"
                    %
                    ( bind_name , prop[ "name" ] , profiling_header("get_%s_%s"%(bind_name,prop["name"])) , udata_type , udata_type )
                )

                if prop[ "get_code" ] is not None:

                    if prop_type not in( "table" , "function" , "udata" ):

                        f.write(
                            "  %s %s;\n"
                            % ( ctype[ prop_type ] , prop[ "name" ] )
                        )

                        if prop_type == "lstring":

                            f.write( "  size_t %s_len=0;\n" % prop[ "name" ] )

                    flow_code( prop[ "get_code" ] )

                    if prop_type not in ( "table" , "function" , "udata" ):

                        if prop_type == "lstring":

                            f.write(
                                "  if (!%s)\n"
                                "    lua_pushnil(L);\n"
                                "  else\n"
                                "    %s(L,%s,%s_len);\n"
                                %
                                ( prop["name"],lua_push[ prop_type ] , prop[ "name" ] , prop[ "name" ] )
                            )

                        else:

                            f.write(
                                "  %s(L,%s);\n"
                                %
                                ( lua_push[ prop_type ] , prop[ "name" ] )
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
                        "%s"
                        "MIGHT_BE_UNUSED %s self(lb_get_self(L,%s));\n"
                        %
                        ( bind_name , prop[ "name" ] , profiling_header("set_%s_%s"%(bind_name,prop["name"])) , udata_type , udata_type )
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
		    '  return UserData::get_callback( "%s" , L , -1 );'
                    "}\n"
                    %
                    ( bind_name , cb[ "name" ] , cb[ "name" ] )
                )

                f.write(
                    "\n"
                    "int set_%s_%s(lua_State*L)\n"
                    "{\n"
                    "MIGHT_BE_UNUSED %s self(lb_get_self(L,%s));\n"
                    'MIGHT_BE_UNUSED int %s(!lb_set_callback(L,"%s"));\n'
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

            #if len(callbacks) > 0:
            #
            #    f.write(
            #        "\n"
            #        "void detach_%s(lua_State*L,%s self)\n"
            #        "{\n"
            #        "  lb_clear_callbacks(L,self,%s);\n"
            #        "}\n"
            #        %
            #        (bind_name , udata_type , metatable_name )
            #    )
            #-----------------------------------------------------------------------
            # INITIALIZER
            #-----------------------------------------------------------------------

            f.write(
                "\n"
                "int luaopen_%s(lua_State*L)\n"
                "{\n"
                %
                ( bind_name , )
            )

            initializers.append( bind_name );

            # Deal with restricted things

            if bind_restricted:

            	f.write(
            		'  if (!lb_is_allowed(L,\"%s\"))\n'
            		'    return 0;\n'
            		%
            		bind_name
            	)

	    # Lazy load?

	    if bind_type in [ "global" , "class" ]:

		f.write(
		    '  if ( lua_tointeger( L , -1 ) == LB_LAZY_LOAD )\n'
		    '  {\n'
		    '    lb_set_lazy_loader( L , "%s" , luaopen_%s );\n'
		    '    return 0;\n'
		    '  }\n\n'
		    % ( bind_name , bind_name )
	    )

            # Create the metatable

            f.write(
                "  luaL_newmetatable(L,%s);\n"
                '  lua_pushliteral(L,"type");\n'
                '  lua_pushliteral(L,"%s");\n'
                "  lua_rawset(L,-3);\n"

                '  lua_pushliteral(L,"__types__");\n'
                "  lua_newtable(L);\n"
                '  lua_pushliteral(L,"%s");\n'
                "  lua_pushboolean(L,1);\n"
                "  lua_rawset(L,-3);\n"
                "  lua_rawset(L,-3);\n"
                %
                (metatable_name,bind_name,bind_name)
            )

            # Put constants into the metatable

            for const in bind["constants"]:

                f.write(
                    '  lua_pushliteral(L,"%s");\n'
                    "  %s(L,%s);\n"
                    "  lua_rawset(L,-3);\n"
                    %
                    ( const["name"] , lua_push[ const[ "type" ] ] , const[ "value" ] )
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
                "  luaL_setfuncs(L,meta_methods,0);\n"
            )

            # If there are no properties, we set the __index metafield to point to
            # the metatable itself - the methods will be found there by Lua

            if len( bind[ "properties" ] ) == 0:

                if bind[ "inherits" ] is None:

                    f.write(
                        '  lua_pushliteral(L,"__index");\n'
                        "  lua_pushvalue(L,-2);\n"
                        "  lua_rawset(L,-3);\n"
                    )

            # Otherwise, we have to create the getters and setters tables and
            # put them in the metatable

            else:

                f.write(
                    '  lua_pushliteral(L,"__getters__");\n'
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

                f.write( '    {"extra",lb_get_extra}, // AUTO\n' )

                f.write(
                    "    {NULL,NULL}\n"
                    "  };\n"
                    "  luaL_setfuncs(L,getters,0);\n"
                    "  lua_rawset(L,-3);\n"
                )

                # Setters

                f.write(
                    '  lua_pushliteral(L,"__setters__");\n'
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

                f.write( '    {"extra",lb_set_extra}, // AUTO\n' )

                f.write(
                    "    {NULL,NULL}\n"
                    "  };\n"
                    "  luaL_setfuncs(L,setters,0);\n"
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
                    '  lb_setglobal(L,"%s");\n'
                    %
                    ( bind_name , bind_name )
                )

            # Otherwise, it is a class

            elif bind_type == "class":

                if len( constructors ) == 0:

                    sys.exit( "No constructor for " + bind_name )

                f.write(
                    "  lua_pushcfunction(L,new_%s);\n"
                    '  lb_setglobal(L,"%s");\n'
                    %
                    ( bind_name , bind_name )
                )

            f.write( "  return 0;\n" )
            f.write( "}\n" )

        #-----------------------------------------------------------------------

    header.write( '#include "lb.h"\n' );

    f.write( '#include "lb.h"\n' );

    if options.profiling:

    	f.write( '#include "profiler.h"\n' );

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
            "int luaopen_%s(lua_State*L)\n"
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
                '  lb_setglobal(L,"%s");\n'
                %
                ( g , g )
            )

	f.write( "  return 0;\n" )
        f.write( "}\n" )


if __name__ == "__main__":

    parser = OptionParser()
    parser.add_option( "-l" , "--lines" , action="store_true" , default=False , help="Include #line directives" )
    parser.add_option( "-p" , "--profiling" , action="store_true" , default=False , help="Enable profiling" )
    parser.add_option( "-t" , "--tracing" , action="store_true" , default=False , help="Enable tracing of Lua calls" )
    parser.add_option( "-m" , "--mac", action="store_true" , default=False , help="Enable output of Objective-C++ file for Mac happiness" )

    (options,args) = parser.parse_args()

    for file_name in args:
        
        bn = os.path.basename( file_name )

        if options.mac:
            output = open( bn + ".mm" , "w")
        else:
            output = open( bn + ".cpp" , "w")
            
        header = open( bn + ".h" , "w")

        binding = parse( open( file_name ).read() )


        header_guard = "_TRICKPLAY_%s_H" % bn.replace(".","_").upper()
        header.write( "#ifndef %s\n#define %s\n\n" % ( header_guard , header_guard ) )

        emit( binding , output , header )

        header.write( "#endif //%s\n" % header_guard )

        output.close()
        
        header.close()
