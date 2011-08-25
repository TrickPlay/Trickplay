test_group = Group ()

-- Unit Test Framework
dofile( "packages/acceptance_unit_tests/unit_test.lua" )

-- Unit Tests
--dofile( "urlRequest2.lua" )  -- Failing because can't fail url request due to URL redirect.

dofile( "packages/acceptance_unit_tests/Alpha1.lua" ) 

dofile( "packages/acceptance_unit_tests/xmlParser1.lua" ) 
dofile( "packages/acceptance_unit_tests/xmlParser2.lua" )
dofile( "packages/acceptance_unit_tests/timer1.lua")
dofile( "packages/acceptance_unit_tests/urlRequest1.lua" )
dofile( "packages/acceptance_unit_tests/UIElement1.lua" )
dofile( "packages/acceptance_unit_tests/UIElement2.lua" )
dofile( "packages/acceptance_unit_tests/UIElement3.lua" )
dofile( "packages/acceptance_unit_tests/UIElement4.lua" )
dofile( "packages/acceptance_unit_tests/UIElement6.lua" )
dofile( "packages/acceptance_unit_tests/UIElement5.lua" )
dofile( "packages/acceptance_unit_tests/UIElement7.lua" )
dofile( "packages/acceptance_unit_tests/UIElement8.lua" )
dofile( "packages/acceptance_unit_tests/UIElement9.lua" )
dofile( "packages/acceptance_unit_tests/UIElement10.lua" )
dofile( "packages/acceptance_unit_tests/Container1.lua" )
dofile( "packages/acceptance_unit_tests/Container2.lua" )
dofile( "packages/acceptance_unit_tests/Container3.lua" )
dofile( "packages/acceptance_unit_tests/Container4.lua" )
dofile( "packages/acceptance_unit_tests/screen1.lua" )
dofile( "packages/acceptance_unit_tests/clone1.lua" )
dofile( "packages/acceptance_unit_tests/image1.lua")
dofile( "packages/acceptance_unit_tests/image2.lua")
dofile( "packages/acceptance_unit_tests/Rectangle1.lua")
dofile( "packages/acceptance_unit_tests/text1.lua" )
dofile( "packages/acceptance_unit_tests/text2.lua" )
dofile( "packages/acceptance_unit_tests/Timeline1.lua" )
dofile( "packages/acceptance_unit_tests/Timeline2.lua" )
dofile( "packages/acceptance_unit_tests/Timeline3.lua" )
dofile( "packages/acceptance_unit_tests/Timeline4.lua" )
dofile( "packages/acceptance_unit_tests/Timeline5.lua" )
dofile( "packages/acceptance_unit_tests/Timeline6.lua" )
dofile( "packages/acceptance_unit_tests/Interval1.lua" )
dofile( "packages/acceptance_unit_tests/Path1.lua" )
dofile( "packages/acceptance_unit_tests/Path2.lua" )
dofile( "packages/acceptance_unit_tests/load_file1.lua" )
dofile( "packages/acceptance_unit_tests/readfile1.lua" )
dofile( "packages/acceptance_unit_tests/choose1.lua" )
dofile( "packages/acceptance_unit_tests/serialize1.lua" )
dofile( "packages/acceptance_unit_tests/encoding_encrypting1.lua" )
dofile( "packages/acceptance_unit_tests/global_misc1.lua" )
dofile( "packages/acceptance_unit_tests/json1.lua" ) 
dofile( "packages/acceptance_unit_tests/trickplay1.lua" )
dofile( "packages/acceptance_unit_tests/bug_814.lua" )
dofile( "packages/acceptance_unit_tests/settings1.lua" )
dofile( "packages/acceptance_unit_tests/system1.lua" )
dofile( "packages/acceptance_unit_tests/uri1.lua" )
dofile( "packages/acceptance_unit_tests/stopwatch1.lua" ) 
dofile( "packages/acceptance_unit_tests/bitmap1.lua") 
dofile( "packages/acceptance_unit_tests/canvas1.lua" ) 
dofile( "packages/acceptance_unit_tests/profile1.lua" ) 
dofile( "packages/acceptance_unit_tests/UIElement12.lua" )  
dofile( "packages/acceptance_unit_tests/mediaplayer1.lua" )
--dofile( "packages/acceptance_unit_tests/UIElement13.lua" ) -- Causing asserts now
dofile( "packages/acceptance_unit_tests/Alpha2.lua" )
dofile( "packages/acceptance_unit_tests/app1.lua" )


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





