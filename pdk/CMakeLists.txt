
set(CPACK_GENERATOR TBZ2)

set(CPACK_PACKAGE_NAME "trickplay-pdk")

set(CPACK_PACKAGE_VERSION "${GIT_CURRENT_TAG}")

#    set(CPACK_SYSTEM_NAME "Linux-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")

set(CPACK_PACKAGE_FILE_NAME "trickplay-pdk_${CPACK_PACKAGE_VERSION}")

# Documentation

install(DIRECTORY ${PROJECT_BINARY_DIR}/docs/oem/ DESTINATION docs)

# Resources

install(DIRECTORY ${PROJECT_SOURCE_DIR}/resources/ DESTINATION resources)

# Third party libraries

install(DIRECTORY ${CMAKE_INSTALL_PREFIX}/lib/ DESTINATION lib)

# Open source patches

install(DIRECTORY ${PROJECT_SOURCE_DIR}/platform-build/patches/ DESTINATION opensource/patches)

# List of open source components and licenses

install(FILES ${PROJECT_SOURCE_DIR}/pdk/opensource-list.csv DESTINATION opensource/)

# QA

install(DIRECTORY ${PROJECT_SOURCE_DIR}/qa/ DESTINATION qa)


include(CPack)

