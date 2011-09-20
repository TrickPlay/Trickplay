
--[[
Filename: mediaplay1.lua
Author: Peter von dem Hagen
Date: January 28, 2011
Description: Mediaplayer  test  

--]]

 local video_playing
 local video_paused
 local video_idle

 mediaplayer:load("packages/acceptance_unit_tests/assets/glee-1.mp4")
 mediaplayer:set_viewport_geometry (750,10,200,200)
 video_idle =mediaplayer.state
 

 function mediaplayer:on_loaded()
	mediaplayer:play()
	video_playing = mediaplayer.state
	bitrate = mediaplayer.tags["bitrate"]
	mediaplayer.volume = 0.5
	mediaplayer.mute = false
  end


screen:show()

function test_mediaplayer_state ()
	mediaplayer:seek(20)
	mediaplayer:pause()
	video_paused =mediaplayer.state
    assert_equal( video_playing, 8 , "mediaplayer.state = play failed" )
    assert_equal( video_paused, 4 , "mediaplayer.state = paused failed" )
    assert_equal( video_idle, 2 , "mediaplayer.state = idle failed" )
end

function test_mediaplayer_position ()
    assert_number ( mediaplayer.position , "mediaplayer.position failed" )
end

function test_mediaplayer_buffered_duration ()
    assert_number ( mediaplayer.buffered_duration[1] , "mediaplayer.buffered_duration[1] failed" )
    assert_number ( mediaplayer.buffered_duration[2] , "mediaplayer.buffered_duration[2] failed" )
end

function test_mediaplayer_video_size ()
    assert_number ( mediaplayer.video_size[1] , "mediaplayer.video_size[1] failed" )
    assert_number ( mediaplayer.video_size[2] , "mediaplayer.video_size[2] failed" )
end

function test_mediaplayer_has_video ()
    assert_equal ( mediaplayer.has_video , true,  "mediaplayer.has_video failed" )
end

function test_mediaplayer_volume ()
 	assert_equal ( string.sub(mediaplayer.volume, 1, 5) , "0.500",  "mediaplayer.volume failed" )
end

function test_mediaplayer_mute ()
    assert_equal ( mediaplayer.mute , false,  "mediaplayer.false failed" )
end

function test_mediaplayer_has_audio ()
    assert_equal ( mediaplayer.has_audio , true,  "mediaplayer.has_audio failed" )
end

function test_mediaplayer_tags ()
    assert_string ( mediaplayer.tags["bitrate"] , "mediaplayer.tags[bitrate] failed" )
    assert_string ( mediaplayer.tags["container-format"] , "mediaplayer.tags[container-format] failed" )
    assert_string ( mediaplayer.tags["video-codec"] , "mediaplayer.tags[video-codec] failed" )
    assert_string ( mediaplayer.tags["maximum-bitrate"] , "mediaplayer.tags[maximum-bitrate] failed" )
    assert_string ( mediaplayer.tags["language-code"] , "mediaplayer.tags[language-code] failed" )
    assert_string ( mediaplayer.tags["audio-codec"] , "mediaplayer.tags[audio-codec] failed" )
end
