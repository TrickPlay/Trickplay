# - Find curl
# Find the native CLUTTER headers and libraries.
#
#  CLUTTER_INCLUDE_DIRS - where to find curl/curl.h, etc.
#  CLUTTER_LIBRARIES    - List of libraries when using curl.
#  CLUTTER_FOUND        - True if curl found.

# Look for the header file.
FIND_PATH(CLUTTER_INCLUDE_DIR NAMES clutter-1.0/clutter/clutter.h)
MARK_AS_ADVANCED(CLUTTER_INCLUDE_DIR)

# Look for the library.
FIND_LIBRARY(CLUTTER_LIBRARY NAMES clutter-glx-1.0)
MARK_AS_ADVANCED(CLUTTER_LIBRARY)

# handle the QUIETLY and REQUIRED arguments and set CLUTTER_FOUND to TRUE if 
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CLUTTER DEFAULT_MSG CLUTTER_LIBRARY CLUTTER_INCLUDE_DIR)

IF(CLUTTER_FOUND)
  SET(CLUTTER_LIBRARIES ${CLUTTER_LIBRARY})
  SET(CLUTTER_INCLUDE_DIRS ${CLUTTER_INCLUDE_DIR}/clutter-1.0)
ELSE(CLUTTER_FOUND)
  SET(CLUTTER_LIBRARIES)
  SET(CLUTTER_INCLUDE_DIRS)
ENDIF(CLUTTER_FOUND)
