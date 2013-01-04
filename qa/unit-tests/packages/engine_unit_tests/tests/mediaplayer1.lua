
--[[
Filename: mediaplay1.lua
Author: Peter von dem Hagen
Date: January 28, 2011
Description: Mediaplayer  test

--]]

 local video_playing
 local video_paused
 local video_idle
 media_player_loaded = false
 media_player_stream_completed = false

  function mediaplayer:on_end_of_stream()
    media_player_stream_completed = true
  end

 function mediaplayer:on_loaded()
 	media_player_loaded = true
	mediaplayer:play()
	video_playing = mediaplayer.state
	bitrate = mediaplayer.tags["bitrate"]
    --mediaplayer.mute = false
	mediaplayer.volume = 0.7
	mediaplayer:seek(130)
  end

 mediaplayer:load("packages/engine_unit_tests/tests/assets/glee-1.mp4")
 mediaplayer:set_viewport_geometry (750,10,200,200)
 video_idle =mediaplayer.state

screen:show()

function test_mediaplayer_state ()
	mediaplayer:seek(2)
	mediaplayer:pause()
	video_paused =mediaplayer.state
    assert_equal( video_playing, 8 , "Playing mediaplayer.state = "..video_playing.." Expected 8")
    assert_equal( video_paused, 4 , "Pausing mediaplayer.state = "..video_paused.." Expected 4")
    assert_equal( video_idle, 2 , "Idle mediaplayer.state = "..video_idle.." Expected 2")
end

function test_mediaplayer_position ()
    assert_number ( mediaplayer.position , "mediaplayer.position did not return a number." )
end

function test_mediaplayer_buffered_duration ()
    assert_number ( mediaplayer.buffered_duration[1] , "mediaplayer.buffered_duration[1] returned: "..mediaplayer.buffered_duration[1].." Expected a number" )
    assert_number ( mediaplayer.buffered_duration[2] , "mediaplayer.buffered_duration[2] returned: "..mediaplayer.buffered_duration[2].." Expected a number ")
end

function test_mediaplayer_video_size ()
    assert_number ( mediaplayer.video_size[1], "mediaplayer.video_size[1] returned: "..mediaplayer.video_size[1].." Expected a number" )
    assert_number ( mediaplayer.video_size[2], "mediaplayer.video_size[2] returned: "..mediaplayer.video_size[2].." Expected a number" )
end

function test_mediaplayer_has_video ()
    assert_equal ( mediaplayer.has_video , true,  "mediaplayer.has_video returned: "..tostring(mediaplayer.has_video).." Expected true" )
end

function test_mediaplayer_volume ()

    local error = mediaplayer.volume - 0.7
    local epsilon = 0.000001
    assert_less_than( error, epsilon, "mediaplayer.volume returned: "..mediaplayer.volume.." Expected 0.7")
end

function test_mediaplayer_mute ()
    assert_equal ( mediaplayer.mute , false,  "mediaplayer.mute returned: "..tostring(mediaplayer.mute).." Expected false" )
end

function test_mediaplayer_has_audio ()
    assert_equal ( mediaplayer.has_audio , true, "mediaplayer.has_audio returned:" ..tostring(mediaplayer.has_audio).." Expected true" )
end

function test_mediaplayer_tags ()
-- Commenting out this test as it's returning nil due to the short movie --
  assert_string ( mediaplayer.tags["bitrate"] , "mediaplayer.tags[bitrate] returned: "..tostring(mediaplayer.tags["bitrate"]).." Expected a string"  )
    assert_string ( mediaplayer.tags["container-format"] , "mediaplayer.tags[container-format] returned: "..mediaplayer.tags["container-format"].." Expected a string"  )
    assert_string ( mediaplayer.tags["video-codec"] , "mediaplayer.tags[video-codec] returned: "..mediaplayer.tags["video-codec"].." Expected a string"  )
    assert_string ( mediaplayer.tags["maximum-bitrate"] , "mediaplayer.tags[maximum-bitrate] returned: "..mediaplayer.tags["maximum-bitrate"].." Expected a string"  )
    assert_string ( mediaplayer.tags["language-code"] , "mediaplayer.tags[language-code] returned: "..mediaplayer.tags["language-code"].." Expected a string"  )
    assert_string ( mediaplayer.tags["audio-codec"] , "mediaplayer.tags[audio-codec] returned: "..mediaplayer.tags["audio-codec"].." Expected a string"  )
end
