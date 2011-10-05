test_group = Group ()

-- Unit Test Framework
dofile( "packages/engine_unit_tests/harness/unit_test.lua" )

-- Unit Tests
--dofile( "urlRequest2.lua" )  -- Failing because can't fail url request due to URL redirect.

dofile( "packages/engine_unit_tests/tests/Alpha1.lua" ) 

dofile( "packages/engine_unit_tests/tests/xmlParser1.lua" ) 
dofile( "packages/engine_unit_tests/tests/xmlParser2.lua" )
dofile( "packages/engine_unit_tests/tests/timer1.lua")
dofile( "packages/engine_unit_tests/tests/urlRequest1.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement1.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement2.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement3.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement4.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement6.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement5.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement7.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement8.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement9.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement10.lua" )
dofile( "packages/engine_unit_tests/tests/Container1.lua" )
dofile( "packages/engine_unit_tests/tests/Container2.lua" )
dofile( "packages/engine_unit_tests/tests/Container3.lua" )
dofile( "packages/engine_unit_tests/tests/Container4.lua" )
dofile( "packages/engine_unit_tests/tests/screen1.lua" )
dofile( "packages/engine_unit_tests/tests/clone1.lua" )
dofile( "packages/engine_unit_tests/tests/image1.lua")
dofile( "packages/engine_unit_tests/tests/image2.lua")
dofile( "packages/engine_unit_tests/tests/Rectangle1.lua")
dofile( "packages/engine_unit_tests/tests/text1.lua" )
dofile( "packages/engine_unit_tests/tests/text2.lua" )
dofile( "packages/engine_unit_tests/tests/Timeline1.lua" )
dofile( "packages/engine_unit_tests/tests/Timeline2.lua" )
dofile( "packages/engine_unit_tests/tests/Timeline3.lua" )
dofile( "packages/engine_unit_tests/tests/Timeline4.lua" )
dofile( "packages/engine_unit_tests/tests/Timeline5.lua" )
dofile( "packages/engine_unit_tests/tests/Timeline6.lua" )
dofile( "packages/engine_unit_tests/tests/Interval1.lua" )
dofile( "packages/engine_unit_tests/tests/Path1.lua" )
dofile( "packages/engine_unit_tests/tests/Path2.lua" )
dofile( "packages/engine_unit_tests/tests/load_file1.lua" )
dofile( "packages/engine_unit_tests/tests/readfile1.lua" )
dofile( "packages/engine_unit_tests/tests/choose1.lua" )
dofile( "packages/engine_unit_tests/tests/serialize1.lua" )
dofile( "packages/engine_unit_tests/tests/encoding_encrypting1.lua" )
dofile( "packages/engine_unit_tests/tests/global_misc1.lua" )
dofile( "packages/engine_unit_tests/tests/json1.lua" ) 
dofile( "packages/engine_unit_tests/tests/trickplay1.lua" )
dofile( "packages/engine_unit_tests/tests/bug_814.lua" )
dofile( "packages/engine_unit_tests/tests/settings1.lua" )
dofile( "packages/engine_unit_tests/tests/system1.lua" )
dofile( "packages/engine_unit_tests/tests/uri1.lua" )
dofile( "packages/engine_unit_tests/tests/stopwatch1.lua" ) 
dofile( "packages/engine_unit_tests/tests/bitmap1.lua") 
dofile( "packages/engine_unit_tests/tests/canvas1.lua" ) 
dofile( "packages/engine_unit_tests/tests/profile1.lua" ) 
dofile( "packages/engine_unit_tests/tests/UIElement12.lua" )  
dofile( "packages/engine_unit_tests/tests/mediaplayer1.lua" )
--dofile( "packages/engine_unit_tests/tests/UIElement13.lua" ) -- Causing asserts now
dofile( "packages/engine_unit_tests/tests/Alpha2.lua" )
dofile( "packages/engine_unit_tests/tests/app1.lua" )


screen:add (test_group)

-- Timer to give sometime for any tests to complete before calling unit_test
local total = 0

function idle.on_idle( idle , seconds )
      total = total + seconds
      if total >= 3 then

	-- Enter any setup steps that need to be executed before the unit tests run here
	if logo_image ~= nil then	
	   logo_image:grab_key_focus()
	   globe_image:grab_key_focus()
	end

	-- run unit test
        local engine_results = engine_unit_test() 
		screen:remove (test_group)
		mediaplayer:set_viewport_geometry (750,10,0,0)
        idle.on_idle = nil
		layout["ui2"].button0.on_focus_in()
      end
end





