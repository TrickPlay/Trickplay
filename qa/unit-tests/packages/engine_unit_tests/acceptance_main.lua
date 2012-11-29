test_group = Group ()

-- Unit Test Framework
dofile( "packages/engine_unit_tests/harness/unit_test.lua" )
-- Unit Tests

--dofile( "urlRequest2.lua" )  -- Failing because can't fail url request due to URL redirect.
dofile( "packages/engine_unit_tests/tests/Alpha1.lua" )
dofile( "packages/engine_unit_tests/tests/xmlParser1.lua" )
dofile( "packages/engine_unit_tests/tests/xmlParser2.lua" )
dofile( "packages/engine_unit_tests/tests/timer1.lua")
dofile( "packages/engine_unit_tests/tests/timer2.lua")
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
dofile( "packages/engine_unit_tests/tests/UIElement11.lua" )
dofile( "packages/engine_unit_tests/tests/UIElement12.lua" )
dofile( "packages/engine_unit_tests/tests/clutter_actor1.lua" )
dofile( "packages/engine_unit_tests/tests/Container1.lua" )
dofile( "packages/engine_unit_tests/tests/Container2.lua" )
dofile( "packages/engine_unit_tests/tests/Container3.lua" )
dofile( "packages/engine_unit_tests/tests/Container4.lua" )
dofile( "packages/engine_unit_tests/tests/Container5.lua" )
dofile( "packages/engine_unit_tests/tests/Container6.lua" )
dofile( "packages/engine_unit_tests/tests/screen1.lua" )
dofile( "packages/engine_unit_tests/tests/clone1.lua" )
dofile( "packages/engine_unit_tests/tests/image1.lua")
dofile( "packages/engine_unit_tests/tests/image2.lua")
dofile( "packages/engine_unit_tests/tests/image3.lua" )
dofile( "packages/engine_unit_tests/tests/image4.lua" )
dofile( "packages/engine_unit_tests/tests/Rectangle1.lua")
dofile( "packages/engine_unit_tests/tests/text1.lua" )
dofile( "packages/engine_unit_tests/tests/text2.lua" )
dofile( "packages/engine_unit_tests/tests/text3.lua" )
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
dofile( "packages/engine_unit_tests/tests/animator1.lua" )
dofile( "packages/engine_unit_tests/tests/animationState1.lua" )
dofile( "packages/engine_unit_tests/tests/animationState2.lua" )
dofile( "packages/engine_unit_tests/tests/app1.lua" )
dofile( "packages/engine_unit_tests/tests/text3.lua" )
dofile( "packages/engine_unit_tests/tests/text4.lua" )
dofile( "packages/engine_unit_tests/tests/text5.lua" )
dofile( "packages/engine_unit_tests/tests/text6.lua" )
dofile( "packages/engine_unit_tests/tests/text7.lua" )
dofile( "packages/engine_unit_tests/tests/text8.lua" )
dofile( "packages/engine_unit_tests/tests/text9.lua" )
dofile( "packages/engine_unit_tests/tests/text10.lua" )
dofile( "packages/engine_unit_tests/tests/Score1.lua" )
dofile( "packages/engine_unit_tests/tests/Score2.lua" )
--dofile( "packages/engine_unit_tests/tests/Score3.lua" )
dofile( "packages/engine_unit_tests/tests/Score4.lua" )
dofile( "packages/engine_unit_tests/tests/Score5.lua" )

dofile( "packages/engine_unit_tests/tests/Timeline7.lua" )
dofile( "packages/engine_unit_tests/tests/Timeline8.lua" )
dofile( "packages/engine_unit_tests/tests/Timeline9.lua" )
dofile( "packages/engine_unit_tests/tests/Path3.lua" )
dofile( "packages/engine_unit_tests/tests/Path4.lua" )
dofile( "packages/engine_unit_tests/tests/Path5.lua")
dofile( "packages/engine_unit_tests/tests/bitmap1.lua")
dofile( "packages/engine_unit_tests/tests/bitmap2.lua")
dofile( "packages/engine_unit_tests/tests/bitmap3.lua")
dofile( "packages/engine_unit_tests/tests/mediaplayer1.lua" )

screen:add (test_group)

-- setup steps
if logo_image ~= nil then
   logo_image:grab_key_focus()
   globe_image:grab_key_focus()
end
mediaplayer:set_viewport_geometry (750,10,0,0)
layout["ui2"].button0.on_focus_in()




-- Timer to give sometime for any tests to complete before calling unit_test
local total = 0

idle.limit = 1.0

function idle.on_idle( idle , seconds )
       total = total + seconds

	if 	( animator_timeline_completed_called == true  and
		appOnLoadedCalled == true and
		bitmap1_async_loaded_called == true and
		image1Loaded == true  and
		image2_callback_called == true and
		--on_alpha_called == true  and
		media_player_stream_completed == true and
		timeline1_on_completed_called == true and
		alpha1_completed == true and
		timeline_4_test_completed == true and
		timeline5_on_completed_called == true and
		timeline6_on_completed_called == true and
		timeline_8_test_completed == true and
		urlrequest1_on_complete_called == true and
		tag_img_loaded == true and
		animation_state2_completed == true and
		score_on_completed_called == true and
		total > 5 )
 		or total > 30 then

			if  total < 10 then
		 		all_callbacks_fired = true
			end

			-- run unit tests
			local engine_results = engine_unit_test()

			idle.on_idle = nil

			-- clean up
			screen:remove (test_group)
			test_group = nil

      end
end
