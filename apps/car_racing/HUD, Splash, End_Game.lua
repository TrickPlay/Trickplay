--the speedometer and point-ometer
local hud = Group{name="hud"}
do
	
	local speedo = Assets:Clone{src="assets/speedo.png",x=screen_w,y=screen_h}
	speedo.anchor_point={speedo.w,speedo.h}
	local mph_txt    = Text{
        text=    "000",
        font="Digital-7 60px",
        color="ffd652",
        x=1785,
        y= 982
    }
	local points_txt = Text{
        text="0000000",
        font="Digital-7 26px",
        color="ffa752",
        x=1648,
        y=1034
    }
	local highscore_txt  = Text{
        text=string.format("%07d",Game_State.highscore),
        font="Digital-7 20px",
        color="78a1b6",
        x=1658,
        y=981
    }
	
	hud.update = function(self,mph,points)
		mph_txt.text = string.format("%03d",mph)
		points_txt.text = string.format("%07d",points)
		points_txt.text = string.format("%07d",points)
		if Game_State.highscore < points then
			Game_State.highscore = points
			highscore_txt.text = string.format("%07d",Game_State.highscore)
		end
		
	end
	
    hud:add(speedo,mph_txt,points_txt,highscore_txt)
    hud:hide()
	
	Game_State:add_state_change_function(
		function(old_state,new_state)
			hud:show()
		end,
		STATES.SPLASH,
		STATES.PLAYING
	)

end

local Splash = Group{
	name="Splash Button",
	x=760*2,
	y=420*2,
}
do
	local unpressed = Assets:Clone{
		src="assets/splash/start-btn-default.png"
	}
	local pressed = Assets:Clone{
		src="assets/splash/start-btn-pressed.png",
		opacity=0
	}
	local glow = Assets:Clone{
		src="assets/splash/start-btn-glow.png",
		opacity=0,
		x=-9,
		y=-28
	}
	
	local pulsate = function(self,msecs,p)
		self.opacity = 255*(.5+.5*cos(360*p))
	end
	
	
	Splash:add(unpressed,pressed,glow)
	
	Splash.pressed = false
	
	Splash.timer = Timer{
		interval = 1000,
		on_timer = function(self)
			self:stop()
			Splash:unparent()
			Splash = nil
			Game_State:change_state_to(STATES.PLAYING)
		end
	}
	Splash.timer:stop()
	Splash.press = function(self)
		if not self.pressed then
			unpressed.opacity=0
			pressed.opacity=255
			glow.opacity=255
			glow.y=-8
			self.pressed = true
			Splash.timer:start()
			Idle_Loop:remove_function(
				pulsate
				
			)
		end
	end
	Game_State:add_state_change_function(
		function(old_state,new_state)
			Splash:show()
			Idle_Loop:add_function(
				pulsate,
				glow,
				2000,
				true
			)
		end,
		STATES.LOADING,
		STATES.SPLASH
	)
	Splash:hide()
end

--End of Game Message
local end_game = Group{x=screen_w/2,y=screen_h/2}
do
	local end_game_text = Text{
		text="You Crashed\n\nRestarting in 3",
		alignment="CENTER",
		font="Digital-7 80px",
		color="ffd652"
	}
	local end_game_backing=Rectangle{
		w=end_game_text.w+50,
		h=end_game_text.h+50,
		color="000000",
		opacity=255*.5
	}
	end_game_text.anchor_point={
		end_game_text.w/2,
		end_game_text.h/2
	}
	end_game_backing.anchor_point={
		end_game_backing.w/2,
		end_game_backing.h/2
	}
	end_game:add(end_game_backing,end_game_text)
	local update = function(self,msecs,p)
		end_game_text.text = "You Crashed\n\nRestarting in "..math.floor(total_dead_time-msecs/1000)
		if p == 1 then
			print("change")
            Game_State:change_state_to(STATES.PLAYING)
        end
	end
	
	Game_State:add_state_change_function(
		function(old_state,new_state)
			Game_State.points = 0
            end_game:hide()
		end,
		STATES.CRASH,
		STATES.PLAYING
	)
	Game_State:add_state_change_function(
		function(old_state,new_state)
			end_game_text.text = "You Crashed\n\nRestarting in "..total_dead_time
			end_game:show()
			Idle_Loop:add_function(update, end_game, total_dead_time*1000,false)
		end,
		STATES.PLAYING,
		STATES.CRASH
	)
	end_game:hide()
end

return hud, Splash, end_game