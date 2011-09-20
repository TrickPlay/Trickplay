
list( APPEND 3RD_PARTY_SOURCE_FILES

    ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/zip_utils/unzip.cpp

)

# This should be taken out for windows

add_definitions( -DZIP_STD=1 )

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/zip_utils ) 


include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/Box2D_v2.1.2/Box2D ) 

set(BOX2D_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/Box2D_v2.1.2/Box2D/Box2D)

list( APPEND 3RD_PARTY_SOURCE_FILES

	${BOX2D_SOURCE}/Collision/b2BroadPhase.cpp
	${BOX2D_SOURCE}/Collision/b2CollideCircle.cpp
	${BOX2D_SOURCE}/Collision/b2CollidePolygon.cpp
	${BOX2D_SOURCE}/Collision/b2Collision.cpp
	${BOX2D_SOURCE}/Collision/b2Distance.cpp
	${BOX2D_SOURCE}/Collision/b2DynamicTree.cpp
	${BOX2D_SOURCE}/Collision/b2TimeOfImpact.cpp
	${BOX2D_SOURCE}/Collision/Shapes/b2CircleShape.cpp
	${BOX2D_SOURCE}/Collision/Shapes/b2PolygonShape.cpp
	${BOX2D_SOURCE}/Common/b2BlockAllocator.cpp
	${BOX2D_SOURCE}/Common/b2Math.cpp
	${BOX2D_SOURCE}/Common/b2Settings.cpp
	${BOX2D_SOURCE}/Common/b2StackAllocator.cpp
	${BOX2D_SOURCE}/Dynamics/b2Body.cpp
	${BOX2D_SOURCE}/Dynamics/b2ContactManager.cpp
	${BOX2D_SOURCE}/Dynamics/b2Fixture.cpp
	${BOX2D_SOURCE}/Dynamics/b2Island.cpp
	${BOX2D_SOURCE}/Dynamics/b2World.cpp
	${BOX2D_SOURCE}/Dynamics/b2WorldCallbacks.cpp
	${BOX2D_SOURCE}/Dynamics/Contacts/b2CircleContact.cpp
	${BOX2D_SOURCE}/Dynamics/Contacts/b2Contact.cpp
	${BOX2D_SOURCE}/Dynamics/Contacts/b2ContactSolver.cpp
	${BOX2D_SOURCE}/Dynamics/Contacts/b2PolygonAndCircleContact.cpp
	${BOX2D_SOURCE}/Dynamics/Contacts/b2PolygonContact.cpp
	${BOX2D_SOURCE}/Dynamics/Contacts/b2TOISolver.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2DistanceJoint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2FrictionJoint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2GearJoint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2Joint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2LineJoint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2MouseJoint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2PrismaticJoint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2PulleyJoint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2RevoluteJoint.cpp
	${BOX2D_SOURCE}/Dynamics/Joints/b2WeldJoint.cpp
)

include_directories( ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/json )

list( APPEND 3RD_PARTY_SOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/3rd_party/json/JSON_parser.c )


# Inhibit warnings from 3rd party code. We may want to turn this off
# when we update code from a 3rd party.

set_source_files_properties( ${3RD_PARTY_SOURCE_FILES} COMPILE_FLAGS "-w" )
