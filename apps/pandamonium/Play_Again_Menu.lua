

local sel_scale = 1.2

local unsel_scale = 1

--------------------------------------------------------------------------------
--umbrella object
--------------------------------------------------------------------------------
local Death_Screen = Group{name = "Death Screen",opacity = 0}


--------------------------------------------------------------------------------
--Visual Components
--------------------------------------------------------------------------------

--general
local title      = Text{
	font         = "Baveuse 130px",
	text         = "high scores",
	color        = "ffffff",
	position     = {screen.w/2, 120}
}

title = make_text(title,"green")

local scrim = Rectangle{size = screen.size,color="000000",opacity = 0}


Death_Screen:add(title)
Death_Screen:hide()

local scores = {}

for i,s in pairs(highscores) do
	
	scores[i] = {}
	
	scores[i].name = make_text(
		Text{
			text = s.name,
			font = "Baveuse 55px",
			x    = 2*screen_w/5,
			y    = screen_h/2 + (i-(#highscores+1)/2)*70
		},"green"
	)
	
	scores[i].score = make_text(
		Text{
			text = s.score,
			font = "Baveuse 55px",
			x    = 3*screen_w/5,
			y    = screen_h/2 + (i-(#highscores+1)/2)*70
		},"green"
	)
	
	--scores[i].score.anchor_point = {scores[i].score.w,scores[i].score.h/2}
	Death_Screen:add(scores[i].name, scores[i].score)
end





--for saving
local Save_Score_Group = Group{opacity = 0}



local initials = {}

for i = 1,3 do
	initials[i] = Text{
		text    = "a",
		font    = "Baveuse 55px",
		color   = "e2e92c",
		x       = 2*screen_w/5-60 + 60*(i-1),
		y       = screen_h - title.y
	}
	initials[i].anchor_point = {
		initials[i].w/2,
		initials[i].h/2
	}
	
	local a = "a"; a = a:byte()
	local z = "z"; z = z:byte()
	
	initials[i].up = function(self)
		
		self.text = string.char(
			
			(  (self.text:byte() + 1) - a  )  %
			
			( z - a + 1 ) + a
			
		)
		
	end
	initials[i].dn = function(self)
		
		self.text = string.char(
			
			(  (self.text:byte() - 1) - a  )  %
			
			( z - a + 1 ) + a
			
		)
	end
end

local up_arrow   = Clone{
	source       = assets.arrow,
	anchor_point = {assets.arrow.w, assets.arrow.h/2},
	x            = initials[1].x,
	y            = initials[1].y-60,
	z_rotation   = {-90,0,0}
}

local dn_arrow   = Clone{
	source       = assets.arrow,
	anchor_point = {assets.arrow.w, assets.arrow.h/2},
	x            = initials[1].x,
	y            = initials[1].y+60,
	z_rotation   = {90,0,0}
}


local submit = Text{
	font         = "Baveuse 60px",
	text         = "Submit",
	color        = "ffffff",
	position     = {initials[3].x+300, screen_h - title.y}
	
}

submit = make_text(submit,"green")

Save_Score_Group:add(unpack(initials))
Save_Score_Group:add(up_arrow,dn_arrow,submit)

Death_Screen:add(Save_Score_Group)




--for just viewing
local View_Scores_Group = Group{opacity = 0}

local help       = Text{
	font         = "Baveuse 70px",
	text         = "help",
	color        = "ffffff",
	position     = {screen.w/4, 920}
	
}
help = make_text(help,"green")
local play_again = Text{
	font         = "Baveuse 70px",
	text         = "Play",
	color        = "ffffff",
	position     = {screen.w/2, 920}
	
}
play_again = make_text(play_again,"green")
local quit       = Text{
	font         = "Baveuse 70px",
	text         = "QUIT",
	color        = "ffffff",
	position     = {screen.w*3/4, 920}
	
}
quit = make_text(quit,"green")

View_Scores_Group:add(help,play_again,quit)

Death_Screen:add(View_Scores_Group)




Death_Screen:add(scrim)

--------------------------------------------------------------------------------
--behavior
--------------------------------------------------------------------------------
local save_index = 1

local save_h_score_selectables = {
	initials[1],
	initials[2],
	initials[3],
	submit
}

local view_index = 2

local view_h_score_selectables = {
	help,
	play_again,
	quit,
}





local mag = .02

local first_pass = true

local obj = nil
local wobble = Timeline{
	
	duration     = 700,
	loop         = true,
	on_new_frame = function(_,ms,p)
		
		if first_pass then
			
			mag = .02 + .3*(1-p)
			
		end
		
		obj.scale = {
			sel_scale+mag*math.sin(math.pi*4*p),
			sel_scale-mag*math.sin(math.pi*4*p)
		}
		--[[
		menu_items[index].z_rotation = {
			1*math.sin(math.pi*2*p),
			menu_items[index].w/2*menu_items[index].scale[1],20
		}
		--]]
	end,
	on_completed = function() first_pass = false end
}

local function wobble_start(o)
	obj = o
	wobble:stop()
	first_pass = true
	wobble:start()
end

local curr_scale, curr_o = 0, 0
--[[
local function save_select(t,i)
	
	if index == i then return end
	
	assert(
		
		i > 0    and    i <= # t,
		
		"Tried to select "..i.." in the 'Play Again' menu"
		
	)
	
	wobble:stop()
	
	first_pass = true
	
	curr_scale = t[index].scale[1]
	
	curr_o     = t[index].opacity
	
	t[index]:complete_animation()
	
	t[index].scale = { curr_scale, curr_scale }
	
	t[index].opacity = curr_o
	
	
	curr_scale = t[i].scale[1]
	
	curr_o     = t[i].opacity
	
	t[i]:complete_animation()
	
	t[i].scale = { curr_scale, curr_scale }
	
	t[i].opacity = curr_o
	
	
	t[index]:animate{
		duration   = 100,
		scale      = { unsel_scale, unsel_scale },
		z_rotation = 0,
		opacity    = 255*.7,
	}
	
	t[i]:animate{
		duration     = 100,
		scale        = { sel_scale, sel_scale },
		opacity      = 255,
		on_completed = function()
			wobble:start()
		end
	}
	
	index = i
	
end
local function view_select(t,i)
	
	if index == i then return end
	
	assert(
		
		i > 0    and    i <= # t,
		
		"Tried to select "..i.." in the 'Play Again' menu"
		
	)
	
	wobble:stop()
	
	first_pass = true
	
	curr_scale = t[index].scale[1]
	
	curr_o     = t[index].opacity
	
	t[index]:complete_animation()
	
	t[index].scale = { curr_scale, curr_scale }
	
	t[index].opacity = curr_o
	
	
	curr_scale = t[i].scale[1]
	
	curr_o     = t[i].opacity
	
	t[i]:complete_animation()
	
	t[i].scale = { curr_scale, curr_scale }
	
	t[i].opacity = curr_o
	
	
	t[index]:animate{
		duration   = 100,
		scale      = { unsel_scale, unsel_scale },
		z_rotation = 0,
		opacity    = 255*.7,
	}
	
	t[i]:animate{
		duration     = 100,
		scale        = { sel_scale, sel_scale },
		opacity      = 255,
		on_completed = function()
			wobble:start()
		end
	}
	
	index = i
	
end
--]]

local lose_wobble = function(obj)
	
	wobble:stop()
	
	
	curr_scale = obj.scale[1]
	
	curr_o     = obj.opacity
	
	obj:complete_animation()
	
	obj.scale = { curr_scale, curr_scale }
	
	obj.opacity = curr_o
	
	
	
	
	obj:animate{
		duration   = 100,
		scale      = { unsel_scale, unsel_scale },
		z_rotation = 0,
		opacity    = 255*.7,
	}
end
local get_wobble = function(obj)
	
	
	first_pass = true
	
	
	
	curr_scale = obj.scale[1]
	
	curr_o     = obj.opacity
	
	obj:complete_animation()
	
	obj.scale = { curr_scale, curr_scale }
	
	obj.opacity = curr_o
	
	
	
	obj:animate{
		duration     = 100,
		scale        = { sel_scale, sel_scale },
		opacity      = 255,
		on_completed = function()
			
			wobble_start(obj)
		end
	}
	
	index = i
end

local curr_x = 0

local get_arrows = function(obj)
	
	curr_x = up_arrow.x
	
	up_arrow:complete_animation()
	dn_arrow:complete_animation()
	
	up_arrow.x = curr_x
	dn_arrow.x = curr_x
	
	up_arrow:animate{
		duration = 200,
		x        = obj.x,
		opacity  = 255,
	}
	dn_arrow:animate{
		duration = 200,
		x        = obj.x,
		opacity  = 255,
	}
end

local fade_out_arrows = function()
	
	curr_o = up_arrow.opacity
	
	up_arrow:complete_animation()
	dn_arrow:complete_animation()
	
	up_arrow.opacity = curr_o
	dn_arrow.opacity = curr_o
	
	up_arrow:animate{
		duration = 200,
		opacity  = 0,
	}
	dn_arrow:animate{
		duration = 200,
		opacity  = 0,
	}
end

for i,obj in pairs(initials) do
	obj.get_focus = get_arrows
	obj.lose_focus = function() end
end

submit.get_focus  = function()
	fade_out_arrows()
	get_wobble(submit)
end
submit.lose_focus = function()
	lose_wobble(submit)
end

help.get_focus  = get_wobble
help.lose_focus = lose_wobble

quit.get_focus  = get_wobble
quit.lose_focus = lose_wobble

play_again.get_focus  = get_wobble
play_again.lose_focus = lose_wobble

--the press enter functions
function help:press_enter()    GameState:change_state_to("HELP")    end
function quit:press_enter()    exit()    end

function play_again:press_enter()    GameState:change_state_to("GAME")    end
function submit:press_enter()    GameState:change_state_to("VIEW_HIGHSCORE")    end

--the state change animations (fading the Play Again screen in and out)
do
	--upval
	local curr_opacity
	local fade_in_death_screen = function()
			curr_opacity = Death_Screen.opacity
			
			Death_Screen:complete_animation()
			
			Death_Screen.opacity = curr_opacity
			
			Death_Screen:raise_to_top()
			
			Death_Screen:show()
			
			Death_Screen:animate{
				duration = 500,
				opacity  = 255,
				on_completed = function()
					screen.on_key_down = Play_Again.on_key_down
					
				end
			}
	end
	--fade out
	GameState:add_state_change_function(
		function()
			wobble:stop()
			
			curr_opacity = Death_Screen.opacity
			
			Death_Screen:complete_animation()
			
			Death_Screen.opacity = curr_opacity
			
			Death_Screen:animate{
				duration = 300,
				opacity  = 0,
				on_completed = function()
					Death_Screen:hide()
				end
			}
		end,
		
		"VIEW_HIGHSCORE", "GAME"
	)
	GameState:add_state_change_function(
		function()
			screen.on_key_down = nil
			
			wobble:stop()
			
			curr_opacity = scrim.opacity
			
			scrim:complete_animation()
			
			scrim.opacity = curr_opacity
			
			scrim:animate{
				duration = 300,
				opacity  = 255*.6,
			}
		end,
		
		"VIEW_HIGHSCORE", "HELP"
	)
	
	GameState:add_state_change_function(
		function()
			screen.on_key_down = nil
			
			curr_opacity = scrim.opacity
			
			scrim:complete_animation()
			
			scrim.opacity = curr_opacity
			
			scrim:animate{
				duration = 600,
				opacity  = 0,
				on_completed = function()
					wobble:start()
					screen.on_key_down = Play_Again.on_key_down
				end
			}
		end,
		
		"HELP", "VIEW_HIGHSCORE"
	)
	
	GameState:add_state_change_function(
		function(old)
			
			if old == "HELP" then return end
			
			wobble:stop()
			
			view_index = 2
			
			if Death_Screen.opacity ~= 255 then fade_in_death_screen() end
			
			for i,item in pairs(view_h_score_selectables) do
				
				if i == view_index then
					
					item.scale = {   sel_scale,   sel_scale }
					
					wobble_start(item)
					
				else
					
					item.scale = { unsel_scale, unsel_scale }
					
				end
				
			end
			
			curr_opacity = View_Scores_Group.opacity
			
			View_Scores_Group:complete_animation()
			
			View_Scores_Group.opacity = curr_opacity
			
			View_Scores_Group:animate{
				duration = 300,
				opacity  = 255,
			}
		end,
		
		nil,"VIEW_HIGHSCORE"
	)
	
	GameState:add_state_change_function(
		function()
			--wobble:stop()
			
			local i = 1
			
			while true do
				
				if scores[i].yellow then
					
					scores[i].name:unparent()
					scores[i].name = make_text(
						Text{
							text = highscores[i].name,
							font = "Baveuse 55px",
							x    = 2*screen_w/5,
							y    = screen_h/2 + (i-(#highscores+1)/2)*70
						},"green"
					)
					scores[i].score:unparent()
					scores[i].score = make_text(
						Text{
							text = highscores[i].score,
							font = "Baveuse 55px",
							x    = 3*screen_w/5,
							y    = screen_h/2 + (i-(#highscores+1)/2)*70
						},"green"
					)
					scores[i].yellow = false
					Death_Screen:add(scores[i].name, scores[i].score)
				end
				if highscores[i].score < hud:get_score() then
					
					table.insert(
						highscores,i,
						{
							name = initials[1].text..initials[2].text..initials[3].text,
							score = hud:get_score()
						}
					)
					highscores[#highscores] = nil
					
					table.insert(
						scores,i,
						{
							name = make_text(
								Text{
									text = highscores[i].name,
									font = "Baveuse 55px",
									x    = 2*screen_w/5,
									y    = screen_h/2 + (i-(#highscores+1)/2)*70
								},"yellow"
							),
							score = make_text(
								Text{
									text = highscores[i].score,
									font = "Baveuse 55px",
									x    = 3*screen_w/5,
									y    = screen_h/2 + (i-(#highscores+1)/2)*70
								},"yellow"
							),
							yellow = true
						}
					)
					--print(screen_h/2 + (i-(#highscores+1)/2)*70)
					
					--scores[i].score.anchor_point = {scores[i].score.w,scores[i].score.h/2}
					Death_Screen:add(scores[i].name, scores[i].score)
					
					scores[# scores].name:unparent()
					scores[# scores].score:unparent()
					
					scores[# scores] = nil
					
					for j = i,#scores do
						
						if j ~= i and scores[j].yellow then
							scores[j].name:unparent()
							scores[j].name = make_text(
								Text{
									text = highscores[j].name,
									font = "Baveuse 55px",
									x    = 2*screen_w/5,
									y    = screen_h/2 + (j-(#highscores+1)/2+1)*70
								},"green"
							)
							scores[j].score:unparent()
							scores[j].score = make_text(
								Text{
									text = highscores[j].score,
									font = "Baveuse 55px",
									x    = 3*screen_w/5,
									y    = screen_h/2 + (j-(#highscores+1)/2+1)*70
								},"green"
							)
							scores[j].yellow = false
							Death_Screen:add(scores[j].name, scores[j].score)
						end
						
						scores[j].name.y  = screen_h/2 + (j-(#highscores+1)/2)*70
						scores[j].score.y = screen_h/2 + (j-(#highscores+1)/2)*70
					end
					
					break
					
				end
				
				
				
				i = i + 1
				
				if i > #highscores then error("the shit?") end
			end
			
			curr_opacity = Save_Score_Group.opacity
			
			Save_Score_Group:complete_animation()
			
			Save_Score_Group.opacity = curr_opacity
			
			Save_Score_Group:animate{
				duration = 300,
				opacity  = 0,
			}
		end,
		
		"SAVE_HIGHSCORE", nil
	)
	
	GameState:add_state_change_function(
		function()
			
			if Death_Screen.opacity ~= 255 then fade_in_death_screen() end
			
			wobble:stop()
			
			up_arrow.x = initials[1].x
			dn_arrow.x = initials[1].x
			
			up_arrow.opacity = 255
			dn_arrow.opacity = 255
			
			save_index = 1
			
			View_Scores_Group.opacity = 0
			
			curr_opacity = Save_Score_Group.opacity
			
			Save_Score_Group:complete_animation()
			
			Save_Score_Group.opacity = curr_opacity
			
			Save_Score_Group:animate{
				duration = 300,
				opacity  = 255,
			}
		end,
		
		nil, "SAVE_HIGHSCORE"
	)
	
end

--Key Handler for the splash screen
do
	
	local score_entry_keys = {
		
		[keys.Right] = function()
			
			if save_index == # save_h_score_selectables then return end
			
			save_h_score_selectables[save_index]:lose_focus()
			
			save_index = save_index + 1
			
			save_h_score_selectables[save_index]:get_focus()
			
			--index = index + 1
			
			--arrow:move_to(index)
			
		end,
		[keys.Left] = function()
			
			if save_index == 1 then return end
			
			save_h_score_selectables[save_index]:lose_focus()
			
			save_index = save_index - 1
			
			save_h_score_selectables[save_index]:get_focus()
			
			--index = index - 1
			
			--arrow:move_to(index)
			
		end,
		[keys.OK] = function()
			
			if  save_h_score_selectables[save_index].press_enter then
				save_h_score_selectables[save_index]:press_enter()
			end
			
		end,
		[keys.Up] = function()
			
			if  save_h_score_selectables[save_index].up then
				save_h_score_selectables[save_index]:up()
			end
			
		end,
		[keys.Down] = function()
			
			if  save_h_score_selectables[save_index].dn then
				save_h_score_selectables[save_index]:dn()
			end
			
		end,
	}
	
	local menu_keys = {
		
		[keys.Right] = function()
			
			if view_index == # view_h_score_selectables then return end
			
			view_h_score_selectables[view_index]:lose_focus()
			
			view_index = view_index + 1
			
			view_h_score_selectables[view_index]:get_focus()
			
			--index = index + 1
			
			--arrow:move_to(index)
			
		end,
		[keys.Left] = function()
			
			if view_index == 1 then return end
			
			view_h_score_selectables[view_index]:lose_focus()
			
			view_index = view_index - 1
			
			view_h_score_selectables[view_index]:get_focus()
			
			--index = index - 1
			
			--arrow:move_to(index)
			
		end,
		[keys.OK] = function()
			
			if  view_h_score_selectables[view_index].press_enter then
				view_h_score_selectables[view_index]:press_enter()
			end
			
		end,
	}
	
	local keys
	
	GameState:add_state_change_function(
		function()
			keys = score_entry_keys
		end,
		
		nil, "SAVE_HIGHSCORE"
	)
	
	GameState:add_state_change_function(
		function()
			keys = menu_keys
		end,
		
		nil, "VIEW_HIGHSCORE"
	)
	
	
	
	function Death_Screen:on_key_down(k)    if keys[k] then    keys[k]()    end    end
end
iii = view_index
layers.menu:add(Death_Screen)

return Death_Screen