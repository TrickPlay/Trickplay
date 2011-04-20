--
--  Description: This test application is used for verifying that video related Mediaplayer APIs are functioning as expected.
--  Author: Peter von dem Hagen (Trickplay QA)
--  Date: 4/19/2011
--
--

-- Focus variables
local focus_items = { start = 1, skip_back= 2, slow_speed = 3, stop = 4, play = 5, pause = 6, fast_speed = 7, skip_forward = 8, End = 9, vol_up = 10, vol_down = 11, mute = 12 }
local focus_group = { controls = 1, media_select = 2 }
local current_focus
local current_focus_group
local selected_content_index

-- Misc variables
local current_video
local video_state  = "No video loaded\n"
local full_debug_text = {}
local default_viewport = true
local playback_rate = 1
local current_test = 1
local tests_to_run

-- Test setup
local test_folder = "packages/"
local test_steps_file = "smoke_tests_ubuntu.txt" -- Modify this to show different test steps.

-- Content
-- Add more content in this table
-- { filename, streaming? (versus local), bitrate, description  } 
local content = {
    {"IMG_0009.MOV",  "no","781", "test"},
    {"MVI_3992.AVI", "no", "??", "test"},
    {"golf_game.mp4", "no", "886", "golf"},
    {"clouds.mp4", "no","103", "clouds"},
    {"science.m4v", "no", "1415", "science"},
     {"http://video2.videohostpro.com/video/cvs/5townsbband.mov", "yes", "1844", "mov stream"},
     {"http://www.cfa.montevallo.edu/ca/videoclips/DV%20class%20test%20clip.mov", "yes", "2556", "mov stream"},
     {"http://www.cyrobaptista.com/video/beat_the_donkey_11.wmv", "yes", "18", "wmv stream"},
     {"http://www.thissitedoesnotexist.com/video.mov", "no", "n/a", "Nonexistent URL"},
     {"FF_glow.png", "no", "n/a", "png file"},
     {"text.txt", "no", "n/a", "error case text file"}
}

-- Load video control images
local start_btn = Image{ src = "app_assets/start.png", position = { 510, screen.h - 150 }, scale = {0.7, 0.7 } }
local skip_back_btn = Image{ src = "app_assets/skip_back.png", position = { 590, screen.h - 150 }, scale = {0.7, 0.7 } }
local slow_btn = Image{ src = "app_assets/Rewind.png", position = { 670, screen.h - 150 }, scale = {0.7, 0.7 } }
local stop_btn = Image{ src = "app_assets/stop.png", position = { 750, screen.h - 150 }, scale = {0.7, 0.7 } }
local play_btn = Image{ src = "app_assets/play.png", position = { 830, screen.h - 150 }, scale = {0.7, 0.7 } }
local pause_btn = Image{ src = "app_assets/pause.png", position = { 910, screen.h - 150 }, scale = {0.7, 0.7 } }
local fast_btn = Image{ src = "app_assets/FF.png", position = { 990, screen.h - 150 }, scale = {0.7, 0.7 } }
local skip_forward_btn = Image{ src = "app_assets/skip_forward.png", position = { 1070, screen.h - 150 }, scale = {0.7, 0.7 } }
local end_btn = Image{ src = "app_assets/end.png", position = { 1150, screen.h - 150 }, scale = {0.7, 0.7 } }
local vol_up_btn = Image{ src = "app_assets/vol_up.png", position = { 1230, screen.h - 163 }, scale = {0.9, 0.9} } 
local vol_down_btn = Image{ src = "app_assets/vol_down.png", position = { 1310, screen.h - 163 }, scale = {0.9, 0.9} }
local mute_btn = Image{ src = "app_assets/mute.png", position = { 1390, screen.h - 163 }, scale = {0.9, 0.9} }
local unmute_btn = Image{ src = "app_assets/unmute.png", position = { 1390, screen.h - 163 }, scale = {0.9, 0.9} } 
local start_glow_btn = Image{ src = "app_assets/start_glow.png", position = { 510, screen.h - 150 }, scale = {0.7, 0.7 } }
local skip_back_glow_btn = Image{ src = "app_assets/skip_back_glow.png", position = { 590, screen.h - 150 }, scale = {0.7, 0.7 } }
local slow_glow_btn = Image{ src = "app_assets/Rewind_glow.png", position = { 670, screen.h - 150 }, scale = {0.7, 0.7 } }
local stop_glow_btn = Image{ src = "app_assets/stop_glow.png", position = { 750, screen.h - 150 }, scale = {0.7, 0.7 } }
local play_glow_btn = Image{ src = "app_assets/play_glow.png", position = { 830, screen.h - 150 }, scale = {0.7, 0.7 } }
local pause_glow_btn = Image{ src = "app_assets/pause_glow.png", position = { 910, screen.h - 150 }, scale = {0.7, 0.7 } }
local fast_glow_btn = Image{ src = "app_assets/FF_glow.png", position = { 990, screen.h - 150 }, scale = {0.7, 0.7 } }
local skip_forward_glow_btn = Image{ src = "app_assets/skip_forward_glow.png", position = { 1070, screen.h - 150 }, scale = {0.7, 0.7 } }
local end_glow_btn = Image{ src = "app_assets/end_glow.png", position = { 1150, screen.h - 150 }, scale = {0.7, 0.7 } }
local vol_up_glow_btn = Image{ src = "app_assets/vol_up_glow.png", position = { 1230, screen.h - 163 }, scale = {0.9, 0.9}}
local vol_down_glow_btn = Image{ src = "app_assets/vol_down_glow.png", position = { 1310, screen.h - 163 }, scale = {0.9, 0.9} }
local mute_glow_btn = Image{ src = "app_assets/mute_glow.png", position = { 1390, screen.h - 163 }, scale = {0.9, 0.9} }
local unmute_glow_btn = Image{ src = "app_assets/unmute_glow.png", position = { 1390, screen.h - 163 }, scale = {0.9, 0.9} }


-- Add default video images to the screen
screen:add( start_btn )
screen:add( skip_back_btn )
screen:add( slow_btn )
screen:add( stop_btn )
screen:add( play_btn )
screen:add( pause_btn )
screen:add( fast_btn )
screen:add( skip_forward_btn )
screen:add( end_btn )
screen:add( mute_btn )
screen:add( vol_down_btn )
screen:add( vol_up_btn )

--Create video player border
local video_rec = Canvas (screen.w, screen.h)
video_rec:rectangle (screen.w - 1425, 340, 960, 540)
video_rec:set_source_color ( "002EB8" )
video_rec.line_width = 5
video_rec:stroke()
screen:add (video_rec:Image())

-- load_test_steps file
function load_test_steps ()
	local loaded_test_steps = {}
	
	local tests_file_string = readfile ("packages/"..test_steps_file)
	
	local all_tests = json:parse(tests_file_string)

	return all_tests
end

-- display test steps in the box
function display_test ( test_list, test_no )

	if screen:find_child("test_step_txt") ~= nil then
		screen:remove (screen:find_child("test_step_txt"))
	end
	
	local test_step_txt = Group {
		name = "test_step_txt",
		children = {	
			Text {
				font = "DejaVu Serif 30px",
				color = "000000",
				position = { 60, 110 },
				markup = "<b>Step:   </b>"..test_list[test_no]["step"].."\n<b>Verify: </b>"..test_list[test_no]["verify"]
				},
			Text {
				font = "DejaVu Serif 20px",
				color = "000000",
				position = { screen.w - 160, 90 },
				markup = "<b>"..test_no.."</b> of<b> "..#test_list.."</b>"
				},
			Text {
				font = "DejaVu Serif 20px",
				color = "E6AC00",
				position = { screen.w - 520, 90 },
				markup = "<b>F7 = Previous</b>"
				},
			Text {
				font = "DejaVu Serif 20px",
				color = "00289E",
				position = { screen.w - 350, 90 },
				markup = "<b>F8 = Forward</b>"
				}
		}
	}

	screen:add (test_step_txt)
end


-- Display Title
local header = Text { 
			text = "Video Tester",
			position = { screen.w/2 - 250, 5 },
			color = "99B3CC",
			font = "San 80px"
			}
screen:add (header)

-- Create a video selection box
local video_sel_text_box = Rectangle {
			size = { 457, 700 },
			position = { 20, 340 },
			color = "CFCFCF",
			border_color = "B0B0B0",
			border_width = 5
			}
screen:add (video_sel_text_box)

local video_sel_text_header_box =
		Group  {
			name = "video_sel_text_header_box",
			children =
			{
				Rectangle {
					size = { 80, 35 },
					position = { 17, 340 },
					color = "CFCFCF",
					border_color = "000000",
					border_width = 3
				},
	  			Rectangle {
					size = { 120, 35 },
					position = { 97, 340 },
					color = "CFCFCF",
					border_color = "000000",
					border_width = 3
				},
	  			Rectangle {
					size = { 85, 35 },
					position = { 217, 340 },
					color = "CFCFCF",
					border_color = "000000",
					border_width = 3
				},
	  			Rectangle {
					size = { 177, 35 },
					position = { 302, 340 },
					color = "CFCFCF",
					border_color = "000000",
					border_width = 3
				},
				Text {
					font = "San 35px",
					color = "000000",
					position = { 23, 340 },
					text = "Type"
				},
				Text {
					font = "San 35px",
					color = "000000",
					position = { 101, 340 },
					text = "Streamed"
				},
				Text {
					font = "San 35px",
					color = "000000",
					position = { 221, 340 },
					text = "Bitrate"
				},
				Text {
					font = "San 35px",
					color = "000000",
					position = { 320, 340 },
					text = "Description"
				}
			}
     		}
screen:add (video_sel_text_header_box)

local video_sel_text_box_txt = Text {
			font = "San 50px",
			color = "99B3CC",
			position = { 25, 295 },
			text = "Choose media:"
			}

screen:add (video_sel_text_box_txt)

local video_info_text_box = Rectangle {
			size = { 420, 700 },
			position = { screen.w - 440, 340 },
			color = "CFCFCF",
			border_color = "B0B0B0",
			border_width = 5
			}
screen:add (video_info_text_box)

local video_info_text_box_txt = Text {
			font = "San 50px",
			color = "99B3CC",
			position = { screen.w - 430, 300 },
			text = "Media info"
			}

screen:add (video_info_text_box_txt)


-- Create the test step box and text

local test_step_text_box = Rectangle {
			size = { screen.w - 100, 180 },
			position = { 45, 90 },
			color = "E6E6E6",
			border_color = "FFFFFF",
			border_width = 2
			}
screen:add (test_step_text_box)

local test_step_title_box_txt = Text {
			font = "San 45px",
			color = "99B3CC",
			position = { 46, 44 },
			text = "Test Steps"
			}

screen:add (test_step_title_box_txt)

-- Set the video location

function set_default_viewport ()
	local scx =  247  --screen.w/10
	local scy = 170 --screen.h/8
	mediaplayer:set_viewport_geometry (scx, scy, 480, 270)
	default_viewport = true
end


-- Load the video
function load_video (media_name)


	if content[selected_content_index][2] == "no" then 
		mediaplayer:load(test_folder.."media_assets/"..media_name)
	else
		mediaplayer:load(media_name)
	end

	function mediaplayer:on_loaded()
		update_state_txt (mediaplayer.state) 
		update_media_name ( content[selected_content_index][1] )
		update_video_size (mediaplayer.video_size[1]..","..mediaplayer.video_size[2] )
		update_duration (mediaplayer.duration)
		update_has_av (mediaplayer.has_video, mediaplayer.has_audio)
		update_audio_status (mediaplayer.volume, mediaplayer.mute)	
	end

	function mediaplayer:on_end_of_stream()
		update_debug_text ("on_end_of_stream_called")
		idle.on_idle = nil
	end 

	function mediaplayer:on_error (code, message)
		update_debug_text ("on_error called")
		update_debug_text ("<b>error:</b>\n"..code)
		update_debug_text ("<b>message:</b>\n"..message)
		idle.on_idle = nil
	end 

	current_video = media_name
 
end

-- Update the video state in the debug window.
function update_state_txt (state_number )
	local state, video_state_txt
	if state_number == 1 then state = "IDLE"
	elseif state_number == 2 then state = "LOADING"
	elseif state_number == 4 then state = "PAUSED"
	elseif state_number == 8 then state = "PLAYING"
	end
	
	screen:remove (screen:find_child ("video_state_txt"))
	video_state_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = { screen.w - 430, 355 },
				markup = "<b>State:</b> ".. state,
				name = "video_state_txt"
				}
	screen:add (video_state_txt )
end

-- Update the media name in the debug window
function update_media_name (media_name)
	local state, update_media_name
	
	screen:remove (screen:find_child ("update_media_name"))
	update_media_name_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = {  screen.w - 430, 390 },
				markup = "<b>Filename:</b> ".. media_name,
				name = "update_media_name"
				}
	screen:add ( update_media_name_txt )
end

-- Update the video size in the debug window
function update_video_size (video_size)
	local state, update_video_size
	
	screen:remove (screen:find_child ("update_video_size"))
	update_video_size_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = {  screen.w - 430, 430 },
				markup = "<b>Video Size: </b>"..video_size,
				name = "update_video_size"
				}
	screen:add ( update_video_size_txt )
end

-- Update the video duration in the debug window
function update_duration (duration)
	local state, update_duration
	
	screen:remove (screen:find_child ("update_duration"))
	update_duration_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = {  screen.w - 430, 470 },
				markup = "<b>Duration: </b>"..duration,
				name = "update_duration"
				}
	screen:add ( update_duration_txt )
end

-- Update whether the video has video in the debug window
function update_has_av (has_audio, has_video)
	local state, update_has_av

	if has_audio == true then has_audio = "yes" else has_audio = "no" end
	if has_video == true then has_video = "yes" else has_video = "no" end
	
	screen:remove (screen:find_child ("update_has_av"))
	update_has_av_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = {  screen.w - 430, 510 },
				markup = "<b>Video: </b>"..has_video.."  <b>Audio: </b>"..has_audio,
				name = "update_has_av"
				}
	screen:add ( update_has_av_txt )
end

-- Update whether the video has audio in the debug window
function update_audio_status (volume, mute)
	local state, update_audio_status
	
	if mute == true then mute = "yes" else mute = "no" end

	screen:remove (screen:find_child ("update_audio_status"))
	update_audio_status_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = {  screen.w - 430, 550 },
				markup = "<b>Volume: </b>"..volume.."  <b>Mute: </b>"..mute,
				name = "update_audio_status"
				}
	screen:add ( update_audio_status_txt )
end

-- Update the video buffer in the debug window
function update_buffered_duration (buffer)
	local state, update_buffer
	screen:remove (screen:find_child ("update_buffer"))
	update_buffer_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = {  screen.w - 430, 590 },
				markup = "<b>Buffered Duration: </b>"..buffer[1]..", "..buffer[2],
				name = "update_buffer"
				}
	screen:add ( update_buffer_txt )
end

-- Update the video position in the debug window
function update_video_position (position)
	local state, update_video_position
	
	screen:remove (screen:find_child ("update_video_position"))
	update_video_position_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = {  screen.w - 430, 630 },
				markup = "<b>Position: </b>"..position,
				name = "update_video_position"
				}
	screen:add ( update_video_position_txt )
end

-- show debug message in the debug window
function update_debug_text (debug_text)
	print ("update_debug")
	print (debug_text)
	local state, update_debug_text_txt
	local string_with_crs = ""
	
	table.insert (full_debug_text, 1, debug_text)
	dumptable (full_debug_text)
	if #full_debug_text == 8 then table.remove(full_debug_text) end

	for i,v in ipairs(full_debug_text) do
		string_with_crs = v.."\n"..string_with_crs
	end
	print (string_with_crs)
	screen:remove (screen:find_child ("debug_text_txt"))
	update_debug_text_txt = Text {
				size = { 100, 35 },
				font = "DejaVu Serif 25px",
				color = "000000",
				position = {  screen.w - 430, 670 },
				markup = "<u><b>Debug\n</b></u>"..string_with_crs,
				name = "debug_text_txt"
				}
	screen:add ( update_debug_text_txt )
end

-- Populate the video selection window with the media
function create_content_list ()
	for i=1, #content do
	    local content_list_txt = Text {
			font = "DejaVu Sans Mono 23px",
			color = "000000",
			position = { 30, 350 + i * 25 },
			text = string.lower (string.sub(content[i][1], -3)).."     "..content[i][2].."     "..content[i][3].."   "..content[i][4]
			}

	    screen:add (content_list_txt)
	end
end

-- set the focus in the video selection area
function set_media_focus (item_no)
	screen:remove (screen:find_child ("focused_item"))
	local focused_item = Rectangle {
			color = "FFFF3339",
			size = { 440, 30 },
			position = { 30, 350 + item_no * 25 },	
			name = "focused_item"
			}	
	screen:add(focused_item)
end

-- Play the video
function play_media ()
	
	mediaplayer:play ()	
	update_debug_text ("play")

	function idle:on_idle(elapsed_seconds)
		update_video_position (mediaplayer.position)
		if mediaplayer.buffered_duration ~= nil then
			update_buffered_duration (mediaplayer.buffered_duration)
		end
		update_audio_status (mediaplayer.volume, mediaplayer.mute)
	
	end
end

-- Change the playback rate of the video
function change_playback_rate (change_value)
	playback_rate = playback_rate + change_value
	if playback_rate == 0 then
		playback_rate = playback_rate + change_value
	end
	mediaplayer:set_playback_rate(playback_rate)
	print ("new playback rate = "..playback_rate)
end

-- set default focus on startup
selected_content_index = 1
set_media_focus (selected_content_index)


local current_focus_group = focus_group["media_select"]


function screen.on_key_down( screen , key )

   -- Bring focus to the video select area
   if current_focus_group == focus_group["media_select"] then

        if key == keys.Return then	
		current_focus = focus_items["play"]
		screen:add (play_glow_btn)
		screen:remove (play_btn)
		current_focus_group = focus_group["controls"]
		load_video (content[selected_content_index][1])
 	end

	if key == keys.Down and selected_content_index < #content then
		selected_content_index = selected_content_index + 1
		set_media_focus (selected_content_index)
	end

	if key == keys.Up and selected_content_index > 1 then
		selected_content_index = selected_content_index - 1
		set_media_focus (selected_content_index)
	end

   -- Bring focus to the video controls area
   elseif current_focus_group == focus_group["controls"] then
	
	if key == keys.Return then
		
		if current_focus == focus_items["start"] then
			load_video (content[selected_content_index][1])
			update_debug_text ("go to beginning")
		elseif current_focus == focus_items["skip_back"] then
			mediaplayer:seek (mediaplayer.position - 2 )
			update_debug_text ("skip back 2 seconds")
			update_state_txt (mediaplayer.state) 
		elseif current_focus == focus_items["slow_speed"] then
			change_playback_rate (-1)
			update_debug_text ("slower play speed") 
		elseif current_focus == focus_items["rewind"] then
			mediaplayer:seek (mediaplayer.position - 2 )
			update_debug_text ("rewind 2 seconds")
			update_state_txt (mediaplayer.state) 
		elseif current_focus == focus_items["play"] then
			if mediaplayer.state == 4 then
				play_media()				
				update_state_txt (mediaplayer.state) 
			else
				play_media()
			end
			update_state_txt (mediaplayer.state) 
		elseif current_focus == focus_items["stop"] then
			mediaplayer:reset()
			current_focus_group = focus_group["media_select"]
			idle.on_idle = nil
			update_debug_text ("stop")	
			screen:remove (stop_glow_btn)
			screen:add (stop_btn)
			update_state_txt (mediaplayer.state) 
		elseif current_focus == focus_items["pause"] then
			update_debug_text ("pause")
			mediaplayer:pause()
			idle.on_idle = nil
			update_state_txt (mediaplayer.state) 
		elseif current_focus == focus_items["skip_forward"] then
			mediaplayer:seek (mediaplayer.position + 2 )
			update_debug_text ("skip forward 2 seconds")
			update_state_txt (mediaplayer.state) 
		elseif current_focus == focus_items["fast_speed"] then
			change_playback_rate (1)
			update_debug_text ("faster play speed") 
		elseif current_focus == focus_items["End"] then
			mediaplayer:seek(mediaplayer.duration)
			update_debug_text ("go to end")
			update_state_txt (mediaplayer.state) 
		elseif current_focus == focus_items["vol_up"] then
			update_debug_text ("volume up")
			mediaplayer.volume = mediaplayer.volume + 0.1
		elseif current_focus == focus_items["vol_down"] then
			update_debug_text ("volume down")
			mediaplayer.volume = mediaplayer.volume - 0.1
		elseif current_focus == focus_items["mute"] then
			local mute_status = mediaplayer.mute
			if mute_status == true then 
				mediaplayer.mute = false
				screen:remove (mute_glow_btn)
				screen:add (unmute_glow_btn)
				update_debug_text ("mute = false")
			else 
				mediaplayer.mute = true 
				screen:remove (unmute_glow_btn)
				screen:add (mute_glow_btn)
				update_debug_text ("mute = true")

			end
		end        
        end

	if key == keys.Right then
		if current_focus == focus_items ["start"] then
			current_focus = focus_items["skip_back"]
			screen:add (skip_back_glow_btn)
			screen:remove (skip_back_btn)
			screen:remove (start_glow_btn)
			screen:add (start_btn)
		elseif current_focus == focus_items ["skip_back"] then
			current_focus = focus_items["slow_speed"]
			screen:add (slow_glow_btn)
			screen:remove (slow_btn)
			screen:remove (skip_back_glow_btn)
			screen:add (skip_back_btn)
		elseif current_focus == focus_items ["slow_speed"] then
			current_focus = focus_items["stop"]
			screen:add (stop_glow_btn)
			screen:remove (stop_btn)
			screen:remove (slow_glow_btn)
			screen:add (slow_btn)
		elseif current_focus == focus_items ["stop"] then
			current_focus = focus_items["play"]
			screen:add (play_glow_btn)
			screen:remove (play_btn)
			screen:remove (stop_glow_btn)
			screen:add (stop_btn)
		elseif current_focus == focus_items ["play"] then
			current_focus = focus_items["pause"]
			screen:add (pause_glow_btn)
			screen:remove (pause_btn)
			screen:remove (play_glow_btn)
			screen:add (play_btn)
		elseif current_focus == focus_items ["pause"] then
			current_focus = focus_items["fast_speed"]
			screen:add (fast_glow_btn)
			screen:remove (fast_btn)
			screen:remove (pause_glow_btn)
			screen:add (pause_btn)
		elseif current_focus == focus_items ["fast_speed"] then
			current_focus = focus_items["skip_forward"]
			screen:add (skip_forward_glow_btn)
			screen:remove (skip_forward_btn)
			screen:remove (fast_glow_btn)
			screen:add (fast_btn)
		elseif current_focus == focus_items ["skip_forward"] then
			current_focus = focus_items["End"]
			screen:add (end_glow_btn)
			screen:remove (end_btn)
			screen:remove (skip_forward_btn)
			screen:add (skip_forward_btn)
		elseif current_focus == focus_items ["End"] then
			current_focus = focus_items["vol_up"]
			screen:add (vol_up_glow_btn)
			screen:remove (vol_up_btn)
			screen:remove (end_glow_btn)
			screen:add (end_btn)
		elseif current_focus == focus_items ["vol_up"] then
			current_focus = focus_items["vol_down"]
			screen:add (vol_down_glow_btn)
			screen:remove (vol_down_btn)
			screen:remove (vol_up_glow_btn)
			screen:add (vol_up_btn)
		elseif current_focus == focus_items ["vol_down"] then
			print ("1")
			current_focus = focus_items["mute"]
			screen:add (mute_glow_btn)
			screen:remove (mute_btn)
			screen:remove (vol_down_glow_btn)
			screen:add (vol_down_btn)
		elseif current_focus == focus_items ["mute"] then
		end
	end


	if key == keys.Left then
		if current_focus == focus_items ["start"] then
		elseif current_focus == focus_items ["skip_back"] then
			current_focus = focus_items["start"]
			screen:add (start_glow_btn)
			screen:remove (start_btn)
			screen:add (skip_back_btn)
			screen:remove (skip_back_glow_btn)
		elseif current_focus == focus_items ["slow_speed"] then
			current_focus = focus_items["skip_back"]
			screen:add (skip_back_glow_btn)
			screen:remove (skip_back_btn)
			screen:add (slow_btn)
			screen:remove (stop_glow_btn)
		elseif current_focus == focus_items ["stop"] then
			current_focus = focus_items["slow_speed"]
			screen:add (slow_glow_btn)
			screen:remove (slow_btn)
			screen:add (stop_btn)
			screen:remove (stop_glow_btn)
		elseif current_focus == focus_items ["play"] then
			current_focus = focus_items["stop"]
			screen:add (stop_glow_btn)
			screen:remove (stop_btn)
			screen:add (play_btn)
			screen:remove (play_glow_btn)
		elseif current_focus == focus_items ["pause"] then
			current_focus = focus_items["play"]
			screen:add (play_glow_btn)
			screen:remove (play_btn)
			screen:add (pause_btn)
			screen:remove (pause_glow_btn)
		elseif current_focus == focus_items ["fast_speed"] then
			current_focus = focus_items["pause"]
			screen:add (pause_glow_btn)
			screen:remove (pause_btn)
			screen:add (fast_btn)
			screen:remove (fast_glow_btn)
		elseif current_focus == focus_items ["skip_forward"] then
			current_focus = focus_items["fast_speed"]
			screen:add (fast_glow_btn)
			screen:remove (fast_btn)
			screen:add (skip_forward_btn)
			screen:remove (skip_forward_glow_btn)
		elseif current_focus == focus_items ["End"] then
			current_focus = focus_items["skip_forward"]
			screen:add (skip_forward_glow_btn)
			screen:remove (skip_forward_btn)
			screen:add (end_btn)
			screen:remove (end_glow_btn)
		elseif current_focus == focus_items ["vol_up"] then
			current_focus = focus_items["End"]
			screen:add (end_glow_btn)
			screen:remove (end_btn)
			screen:add (vol_up_btn)
			screen:remove (vol_up_glow_btn)
		elseif current_focus == focus_items ["vol_down"] then
			current_focus = focus_items["vol_up"]
			screen:add (vol_up_glow_btn)
			screen:remove (vol_up_btn)
			screen:add (vol_down_btn)
			screen:remove (vol_down_glow_btn)
		elseif current_focus == focus_items ["mute"] then
			current_focus = focus_items["vol_down"]
			screen:add (vol_down_glow_btn)
			screen:remove (vol_down_btn)
			screen:add (mute_btn)
			screen:remove (mute_glow_btn)
		end
	 end

     end

    	-- Toggle viewport to full screen and back to current size
     	if key == keys.GREEN then
		if default_viewport == true then
			mediaplayer:reset_viewport_geometry()
			default_viewport = false
		else
			set_default_viewport()
		end
	 end

	-- go to next test step
 	if key == keys.BLUE then
		if current_test >= 1 and current_test < #tests_to_run then
			current_test = current_test + 1
			display_test (tests_to_run, current_test)
		end
	 end

	-- go to previous test step
 	if key == keys.YELLOW then
		if current_test > 1 then
			current_test = current_test - 1
			display_test (tests_to_run, current_test)
		end
        end
end


-- main --
tests_to_run = load_test_steps()
display_test (tests_to_run, current_test)
update_state_txt (1)
create_content_list ()
set_default_viewport ()
screen:show()

