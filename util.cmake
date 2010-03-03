
#------------------------------------------------------------------------------
# Finds a header file, and adds its path to a variable passed in,
# for example:
#   TP_FIND_INCLUDE( expat.h INCLUDE_DIRS)
#   TP_FIND_INCLUDE( glib-2.0 glib.h INCLUDE_DIRS)  # Because we want to find [<prefix>/glib-2.0/]glib.h
#   TP_FIND_INCLUDE( curl/curl.h INCLUDE_DIRS)

macro(TP_FIND_INCLUDE)
    
    unset(DEST CACHE)
    
    if (${ARGC} STREQUAL 3)
        set(PREFIX ${ARGV0})
        set(NAME ${ARGV1})
        set(ADD_TO ${ARGV2})        
    else (${ARGC} STREQUAL 3)
        unset(PREFIX)
        set(NAME ${ARGV0})
        set(ADD_TO ${ARGV1})
    endif (${ARGC} STREQUAL 3)
    
    find_path(
        DEST
        NAMES ${NAME}
        PATHS include
        PATH_SUFFIXES ${PREFIX}

        ONLY_CMAKE_FIND_ROOT_PATH
    )
    
    if (${DEST} STREQUAL DEST-NOTFOUND)
    
        if (${ARGC} STREQUAL 3)
            message(FATAL_ERROR "Include '${PREFIX}/${NAME}' not found")
        else (${ARGC} STREQUAL 3)
            message(FATAL_ERROR "Include '${NAME}' not found")
        endif (${ARGC} STREQUAL 3)
        
    else (${DEST} STREQUAL DEST-NOTFOUND)
    
        message(STATUS "Found include '${DEST}/${NAME}'" )
        
        list(APPEND ${ADD_TO} ${DEST})
        list(REMOVE_DUPLICATES ${ADD_TO})
        
    endif(${DEST} STREQUAL DEST-NOTFOUND)
    

endmacro(TP_FIND_INCLUDE)

#------------------------------------------------------------------------------
# Finds a header file, and adds its path to a variable passed in

macro(TP_FIND_LIB_INCLUDE)
    
    unset(DEST CACHE)
    
    if (${ARGC} STREQUAL 3)
        set(PREFIX ${ARGV0})
        set(NAME ${ARGV1})
        set(ADD_TO ${ARGV2})        
    else (${ARGC} STREQUAL 3)
        unset(PREFIX)
        set(NAME ${ARGV0})
        set(ADD_TO ${ARGV1})
    endif (${ARGC} STREQUAL 3)
    
    find_path(
        DEST
        NAMES ${NAME}
        PATHS ${CMAKE_FIND_ROOT_PATH}/lib
        PATH_SUFFIXES ${PREFIX}/include
        
        ONLY_CMAKE_FIND_ROOT_PATH
    )
    
    if (${DEST} STREQUAL DEST-NOTFOUND)
    
        if (${ARGC} STREQUAL 3)
            message(FATAL_ERROR "Include '${PREFIX}/${NAME}' not found")
        else (${ARGC} STREQUAL 3)
            message(FATAL_ERROR "Include '${NAME}' not found")
        endif (${ARGC} STREQUAL 3)
        
    else (${DEST} STREQUAL DEST-NOTFOUND)
    
        message(STATUS "Found include '${DEST}/${NAME}'" )
        
        list(APPEND ${ADD_TO} ${DEST})
        list(REMOVE_DUPLICATES ${ADD_TO})
        
    endif(${DEST} STREQUAL DEST-NOTFOUND)
    

endmacro(TP_FIND_LIB_INCLUDE)

#------------------------------------------------------------------------------
# Finds a library, and adds its path to a variable passed in,
# for example:
#   TP_FIND_LIBRARY( glib-2.0 LIBRARIES)

macro(TP_FIND_LIBRARY NAME ADD_TO)

    unset(DEST CACHE)

    find_library(
        DEST
        NAMES ${NAME}
        PATH_SUFFIXES lib

        ONLY_CMAKE_FIND_ROOT_PATH
    )
    
    if (${DEST} STREQUAL DEST-NOTFOUND)
    
        message(STATUS "Library '${NAME}' not found")
        
    else (${DEST} STREQUAL DEST-NOTFOUND)
    
        message(STATUS "Found library '${DEST}'" )
        list(APPEND ${ADD_TO} ${DEST})
        
    endif(${DEST} STREQUAL DEST-NOTFOUND)

endmacro(TP_FIND_LIBRARY)

#------------------------------------------------------------------------------
# This takes all the paths in the path list and, if they are present
# in CMAKE_FIND_ROOT_PATH plus the suffix, it reorders them according to
# CMAKE_FIND_ROOT_PATH.


macro(TP_ORDER_PATHS PATH_LIST SUFFIX)
    
    unset(FOO)
    
    foreach(PATH ${CMAKE_FIND_ROOT_PATH})
        
        list(FIND ${PATH_LIST} ${PATH}/${SUFFIX} INDEX)
        
        if (NOT INDEX STREQUAL -1)
            list(APPEND FOO ${PATH}/${SUFFIX})
        endif (NOT INDEX STREQUAL -1)
    
    endforeach(PATH)
    
    list(APPEND FOO ${${PATH_LIST}})
    list(REMOVE_DUPLICATES FOO)
    
    set(${PATH_LIST} ${FOO})
    
endmacro(TP_ORDER_PATHS)
