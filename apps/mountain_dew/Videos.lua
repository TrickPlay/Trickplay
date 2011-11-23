local video_files = {
    "videos/chuckanderson.flv",
    "videos/scottlenhardt.flv",
    "videos/marksmith.flv",
    "videos/dez.flv",
    "videos/haze.flv",
    "videos/pjrichardson.flv",
    "videos/troydenning2.flv",
    "videos/mikesutfin.flv",
}

local videos = Group{}

local prev_state = "NIL"

mediaplayer.on_loaded = function()
    mediaplayer:play()
end

mediaplayer.on_end_of_stream = function()
    mediaplayer:pause()
    
    GLOBAL_STATE:change_state_to(prev_state)
end

videos.load = function(self, index)
    --print(index,video_files[index])
    mediaplayer:load(video_files[index])
    
end

GLOBAL_STATE:add_state_change_function(
	function(p_state,new_state)
		prev_state = p_state
        KEY_HANDLER.hold()
        main_screen:complete_animation()
        
        main_screen:animate{
            duration = TRANS_DUR,
            opacity = 0,
            on_completed = KEY_HANDLER.release
        }
	end,
	nil,
    "VIDEO"
)


GLOBAL_STATE:add_state_change_function(
	function(prev_state,new_state)
		KEY_HANDLER.hold()
        main_screen:complete_animation()
        
        main_screen:animate{
            duration = TRANS_DUR,
            opacity = 255,
            on_completed = KEY_HANDLER.release
        }
	end,
	"VIDEO",
    nil
)

local key_events = {
    [keys.OK] = function()
        mediaplayer.on_end_of_stream()
    end
}

KEY_HANDLER:add_keys("VIDEO",key_events)


local back_button = Image{src = "assets/movie/btn-back.png", x=40}
back_button.y = screen_h - back_button.h - 40

videos:add(back_button)

return videos