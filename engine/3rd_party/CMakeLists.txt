
# This should be taken out for windows
add_definitions( -DZIP_STD=1 )

list( APPEND 3RD_PARTY_SOURCE_FILES

    ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/zip_utils/unzip.cpp

)

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/zip_utils )

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/Box2D_v2.2.1 )

set(BOX2D_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/Box2D_v2.2.1/Box2D)

list( APPEND 3RD_PARTY_SOURCE_FILES

    ${BOX2D_SOURCE}/Collision/b2BroadPhase.cpp
    ${BOX2D_SOURCE}/Collision/b2CollideCircle.cpp
    ${BOX2D_SOURCE}/Collision/b2CollideEdge.cpp
    ${BOX2D_SOURCE}/Collision/b2CollidePolygon.cpp
    ${BOX2D_SOURCE}/Collision/b2Collision.cpp
    ${BOX2D_SOURCE}/Collision/b2Distance.cpp
    ${BOX2D_SOURCE}/Collision/b2DynamicTree.cpp
    ${BOX2D_SOURCE}/Collision/b2TimeOfImpact.cpp
    ${BOX2D_SOURCE}/Collision/Shapes/b2ChainShape.cpp
    ${BOX2D_SOURCE}/Collision/Shapes/b2CircleShape.cpp
    ${BOX2D_SOURCE}/Collision/Shapes/b2EdgeShape.cpp
    ${BOX2D_SOURCE}/Collision/Shapes/b2PolygonShape.cpp
    ${BOX2D_SOURCE}/Common/b2BlockAllocator.cpp
    ${BOX2D_SOURCE}/Common/b2Draw.cpp
    ${BOX2D_SOURCE}/Common/b2Math.cpp
    ${BOX2D_SOURCE}/Common/b2Settings.cpp
    ${BOX2D_SOURCE}/Common/b2StackAllocator.cpp
    ${BOX2D_SOURCE}/Common/b2Timer.cpp
    ${BOX2D_SOURCE}/Dynamics/b2Body.cpp
    ${BOX2D_SOURCE}/Dynamics/b2ContactManager.cpp
    ${BOX2D_SOURCE}/Dynamics/b2Fixture.cpp
    ${BOX2D_SOURCE}/Dynamics/b2Island.cpp
    ${BOX2D_SOURCE}/Dynamics/b2World.cpp
    ${BOX2D_SOURCE}/Dynamics/b2WorldCallbacks.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2ChainAndCircleContact.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2ChainAndPolygonContact.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2CircleContact.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2Contact.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2ContactSolver.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2EdgeAndCircleContact.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2EdgeAndPolygonContact.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2PolygonAndCircleContact.cpp
    ${BOX2D_SOURCE}/Dynamics/Contacts/b2PolygonContact.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2DistanceJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2FrictionJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2GearJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2Joint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2MouseJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2PrismaticJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2PulleyJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2RevoluteJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2RopeJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2WeldJoint.cpp
    ${BOX2D_SOURCE}/Dynamics/Joints/b2WheelJoint.cpp
)

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/json )

list( APPEND 3RD_PARTY_SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/json/JSON_parser.c )


# Inhibit warnings from 3rd party code. We may want to turn this off
# when we update code from a 3rd party.

set_source_files_properties( ${3RD_PARTY_SOURCE_FILES} COMPILE_FLAGS "-w" )

set( BUILD_DEMOS OFF CACHE BOOL "" FORCE )
set( USE_GLUT OFF CACHE BOOL "" FORCE )
set( INSTALL_LIBS ON CACHE BOOL "" FORCE )
set( BUILD_MINICL_OPENCL_DEMOS OFF CACHE BOOL "" FORCE )
set( BUILD_NVIDIA_OPENCL_DEMOS OFF CACHE BOOL "" FORCE )
set( BUILD_EXTRAS OFF CACHE BOOL "" FORCE )

add_definitions( -DBT_NO_PROFILE=1 )

set(CMAKE_CXX_OLDFLAGS ${CMAKE_CXX_FLAGS})
set(CMAKE_CXX_FLAGS "-w")
add_subdirectory( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/bullet-2.79 )
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_OLDFLAGS})

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/bullet-2.79/src )

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/txmpp)
