math.randomseed(os.time())
screen_w = screen.w
screen_h = screen.h
dofile("Class.lua") -- Must be declared before any class definitions.
dofile("bg.lua")
dofile("Game.lua")

dofile("FocusableImage.lua")

local anchors = {}
function save(thing)  anchors[thing] = true end
function clear(thing) anchors[thing] = nil  end
local won = false
local diff_from = nil
local conf_from = nil

local num_givens = 50
local blank_button_on   = Image{src="assets/blank_on.png",         opacity=0}
local blank_button_off  = Image{src="assets/blank_off.png",        opacity=0}
local green_button_on   = Image{src="assets/green_on.png",         opacity=0}
local green_button_off  = Image{src="assets/green_off.png",        opacity=0}
local red_button_on     = Image{src="assets/red_on.png",           opacity=0}
local red_button_off    = Image{src="assets/red_off.png",          opacity=0}
local blue_button_on    = Image{src="assets/blue_on.png",          opacity=0}
local blue_button_off   = Image{src="assets/blue_off.png",         opacity=0}
local yellow_button_on  = Image{src="assets/yellow_on.png",        opacity=0}
local yellow_button_off = Image{src="assets/yellow_off.png",       opacity=0}
local blue              = Image{src ="assets/3x3grid-blue.png",    opacity=0}
local red               = Image{src ="assets/3x3grid-red.png",     opacity=0}
local sparkle_base      = Image{src ="assets/Sparkle.png",         opacity=0}
local arrow_down_off    = Image{src = "assets/arrow-down-off.png", opacity=0}
local arrow_down_on     = Image{src = "assets/arrow-down-on.png",  opacity=0}
local arrow_up_off      = Image{src = "assets/arrow-up-off.png",   opacity=0}
local arrow_up_on       = Image{src = "assets/arrow-up-on.png",    opacity=0}
local panel             = Image{src = "assets/panel.png",          opacity=0}
local diff_title        = Image{src = "assets/difficulty.png",     opacity=0}
local sudoku_title      = Image{src = "assets/sudoku.png",         opacity=0}
local conf_text         = Text { text  = "Are you sure you want to start a new game?",
                                 font  = "DejaVu Sans Condensed 32px",
                                 color = "FFFFFF", 
								 opacity = 0
}


screen:add(
	 blank_button_on,  blank_button_off, green_button_on, green_button_off,
	   red_button_on,    red_button_off,  blue_button_on,  blue_button_off,
	yellow_button_on, yellow_button_off,             red,             blue,
	           panel,      sparkle_base,      diff_title,     sudoku_title,
	       conf_text
)
local blanks = {blank_button_off,blank_button_on}
local arrows = {

arrow_up_off,
arrow_up_on ,
arrow_down_off,
arrow_down_on 
}
screen:add(unpack(arrows))
local block_sz = red.w
assert(red.h == block_sz)
local red_is_on = true
local red_board = Group{}
local red_board2 = Group{}
local red_blox = 
{
	{
		Group{},
		Group{x= block_sz   + 30},
		Group{x= block_sz*2 + 30*2}
	},
	{
		Group{                      y= block_sz   + 30},
		Group{x= block_sz   + 30,   y= block_sz   + 30},
		Group{x= block_sz*2 + 30*2, y= block_sz   + 30}
	},
	{
		Group{                      y= block_sz*2 + 30*2},
		Group{x= block_sz   + 30,   y= block_sz*2 + 30*2},
		Group{x= block_sz*2 + 30*2, y= block_sz*2 + 30*2}
	}
}
for i = 1,#red_blox do    for j=1,#red_blox[i] do
		red_board2:add(Clone{name="3x3 "..i.." "..j,source=red,x=(i-1)*(block_sz+30),y=(j-1)*(block_sz+30)})
		--red_blox[i][j]:add(Clone{source=red})

end                        end

assert(blue.w == block_sz)
assert(blue.h == block_sz)
local blue_board = Group{}
local blue_board2 = Group{}
local blue_blox = 
{
	{
		Group{opacity = 0},
		Group{opacity = 0, x= block_sz   + 30,z=1},
		Group{opacity = 0, x= block_sz*2 + 30*2,z=1}
	},
	{
		Group{opacity = 0,                       y= block_sz   + 30,z=1},
		Group{opacity = 0, x= block_sz   + 30,   y= block_sz   + 30,z=1},
		Group{opacity = 0, x= block_sz*2 + 30*2, y= block_sz   + 30,z=1}
	},
	{
		Group{opacity = 0,                       y= block_sz*2 + 30*2,z=1},
		Group{opacity = 0, x= block_sz   + 30,   y= block_sz*2 + 30*2,z=1},
		Group{opacity = 0, x= block_sz*2 + 30*2, y= block_sz*2 + 30*2,z=1}
	}
}
for i = 1,#blue_blox do    for j=1,#blue_blox[i] do
		blue_board2:add(Clone{name="3x3 "..i.." "..j,source=blue,x=(i-1)*(block_sz+30),y=(j-1)*(block_sz+30),opacity=0})
		--blue_blox[i][j]:add(Clone{source=blue})

end                        end
local selector = Image{src="assets/board-focus.png",opacity=0}
selector.anchor_point = {selector.w/2,selector.h/2}

local top_left_logo =  Image{src="assets/logo.png",x=40,y=35,opacity=0}
screen:add(red_board2,blue_board2,selector,red_board,blue_board, top_left_logo)
for i=1,3 do
	blue_board:add( unpack(blue_blox[i]) )
	red_board:add(  unpack( red_blox[i]) )
end
red_board.anchor_point  = {  red_board2.w/2,  red_board2.h/2 }
red_board.position      = {     screen_w/2,     screen_h/2 }
blue_board.anchor_point = { blue_board2.w/2, blue_board2.h/2 }
blue_board.position     = {     screen_w/2,     screen_h/2 }

red_board2.anchor_point  = {  red_board2.w/2,  red_board2.h/2 }
red_board2.position      = {     screen_w/2,     screen_h/2 }
blue_board2.anchor_point = { blue_board2.w/2, blue_board2.h/2 }
blue_board2.position     = {     screen_w/2,     screen_h/2 }


--sparkle:add(sparkle_base)
--sparkle.clip = {0,0,sparkle_base.w/5,sparkle_base.h}
--sparkle.anchor_point = {sparkle_base.w/(5*2),sparkle_base.h/2}
local win_txt = Image{src="assets/won.png",z=3,y=35,opacity=0}

function start_sparkle(x,y, num_sparkles)
--Text{text="You've Won!",font="DejaVu ExtraLight 60px",color="FFFFFF",opacity=0,z=3,x=x[math.ceil(#x/2)],y=y[math.ceil(#y/2)]}
win_txt.anchor_point = {win_txt.w/2,win_txt.h/2}
win_txt.y = 35+win_txt.h/2
win_txt.x = screen_w/2+3/2*block_sz+30+(screen_w/2-3/2*block_sz-30)/2
	--screen.on_key_down = nil
	local timeline = Timeline
	{
		duration = 2000,
		loop = false,
		direction = "FORWARD"
	}
	save(timeline)
	local sparkles = {}
	local sparkles_strip = {}
	local sparkle_w = sparkle_base.w
	local sparkle_h = sparkle_base.h
	--each sparkle gets predefined params (with variance)
	local x_start = {}
	local y_start = {}
	local x_peak  = {}
	local y_peak  = {}
	local x_end   = {}
	local y_end   = {}

	local scale  = {}
	local rot_start   = {}
	local rot_speed   = {}
	local stage_start = {}
	local stage_speed = {}
	local o_peak      = {}
	local t_start     = {}
	local t_peak      = {}
	local t_end       = {}

	--function timeline.on_started()
		for r = 1,#x do
			sparkles[r] = {}
			sparkles_strip[r] = {}
	
			x_start[r] = {}
			y_start[r] = {}
			x_peak[r]  = {}
			y_peak[r]  = {}
			x_end[r]   = {}
			y_end[r]   = {}
	
			scale[r]  = {}
			rot_start[r]   = {}
			rot_speed[r]   = {}
			stage_start[r] = {}
			stage_speed[r] = {}
			o_peak[r]      = {}
			t_start[r]     = {}
			t_peak[r]      = {}
			t_end[r]       = {}

			for c = 1,#y do
				sparkles[r][c] = {}
				sparkles_strip[r][c] = {}
	        
				x_start[r][c] = {}
				y_start[r][c] = {}
				x_peak[r][c]  = {}
				y_peak[r][c]  = {}
				x_end[r][c]   = {}
				y_end[r][c]   = {}
	        
				scale[r][c]  = {}
				rot_start[r][c]   = {}
				rot_speed[r][c]   = {}
				stage_start[r][c] = {}
				stage_speed[r][c] = {}
				o_peak[r][c]      = {}
				t_start[r][c]     = {}
				t_peak[r][c]      = {}
				t_end[r][c]       = {}

				for i = 1, num_sparkles do
					sparkles[r][c][i] = Group{opacity=0}
					sparkles_strip[r][c][i] = Clone{source = sparkle_base}
					sparkles[r][c][i].clip = {0,0,sparkle_w/5,sparkle_h}
					sparkles[r][c][i]:add(sparkles_strip[r][c][i])
                
					local x_dir = math.random(85,115)/100
					x_start[r][c][i] = math.random(-2,2)+x[r]
					sparkles[r][c][i].x = x_start[r][c][i]
					y_start[r][c][i] = math.random(-2,2)+y[c]
					sparkles[r][c][i].y = y_start[r][c][i]
					x_peak[r][c][i]  = x_start[r][c][i]*x_dir
					y_peak[r][c][i]  = y_start[r][c][i]-80+math.random(-10,10)
					x_end[r][c][i]   = x_peak[r][c][i]*x_dir
					y_end[r][c][i]   = y_peak[r][c][i]+90+math.random(-10,10)
                
                
					rot_start[r][c][i]   = math.random(   0, 359) --initial rotation
					rot_speed[r][c][i]   = math.random( 500, 700) --num of milliseconds for a rotation
					stage_start[r][c][i] = math.random(   1,   5) --initial start stage
					stage_speed[r][c][i] = math.random(  50, 100) --num of milliseconds between switches
					
					o_peak[r][c][i]  = math.random(170,255)
					t_start[r][c][i] = math.random(0,300)
					t_peak[r][c][i]  = 400 + math.random(-100,100)
					t_end[r][c][i]   = math.random(0,300) -- when, during the final 200 milliseconds,
													-- the opacity goes to 0
					screen:add(sparkles[r][c][i])
					sparkles[r][c][i]:raise_to_top()
				end
			end
		end
screen:add(win_txt)
win_txt:raise_to_top()
	--end
	
		function timeline.on_new_frame(t,msecs,p)
			--local sparkle_stage = math.ceil(p*5)
			--sparkle_base.x = -1*(stage-1)*sparkle_base.w/5
			--sparkle.z_rotation = {360*p,sparkle_base.w/(5*2),sparkle_base.h/2}
			local prog
			local stage
			for r = 1,#x do
			for c = 1,#y do
	    	for i = 1,num_sparkles do
				stage = math.floor(msecs/stage_speed[r][c][i] + stage_start[r][c][i])%5+1
--[[	
	    		if msecs < 250 and msecs > t_start[i] then
					sparkles[i].opacity = msecs/250 * o_peak[i]
				end
--]]	
				if msecs < t_peak[r][c][i] and msecs > t_start[r][c][i] then
					prog = (msecs-t_start[r][c][i])/(t_peak[r][c][i]-t_start[r][c][i])
					sparkles[r][c][i].opacity = prog * o_peak[r][c][i]
					sparkles[r][c][i].x = prog*(x_peak[r][c][i]-x_start[r][c][i]) + x_start[r][c][i]
					sparkles[r][c][i].y = prog*(y_peak[r][c][i]-y_start[r][c][i]) + y_start[r][c][i]
					sparkles_strip[r][c][i].x =  -1*(stage-1)*sparkles_strip[r][c][i].w/5
					--sparkles[i].z_rotation = {rot_start[i]+360*(msecs%rot_speed[i]),0,0}
					
				elseif msecs < (t.duration - t_end[r][c][i])and msecs > t_start[r][c][i] then
					prog = (msecs-t_peak[r][c][i])/(t.duration- t_end[r][c][i]-t_peak[r][c][i])
					sparkles[r][c][i].x = prog*(x_end[r][c][i]-x_peak[r][c][i]) + x_peak[r][c][i]
					sparkles[r][c][i].y = prog*(y_end[r][c][i]-y_peak[r][c][i]) + y_peak[r][c][i]
					sparkles[r][c][i].opacity = (1-prog)*o_peak[r][c][i]
					sparkles_strip[r][c][i].x =  -1*(stage-1)*sparkle_w/5
					end
				end
			end
		end
		if msecs < 2*t.duration/3 then
			win_txt.opacity = 255*msecs/(2*t.duration/3)
		else
			win_txt.opacity = 255
		end
	end
	function timeline.on_completed()
		for r = 1,#x do
		for c = 1,#y do

		for i=1,num_sparkles do
			sparkles[r][c][i]:clear()
			sparkles[r][c][i]:unparent()
			sparkles[r][c][i] = nil
		end
		end
		end
		clear(timeline)
		--dolater(start_sparkle,x,y,num_sparkles)
		restore_keys()
	end
	timeline:start()
	mediaplayer:play_sound("audio/won_game.mp3")

end
local help = Group{z=3,opacity=0}
local help_img = Image{src="assets/help.png"}
local help_button = FocusableImage({help_img.w/2-blank_button_off.w/2,help_img.h - blank_button_off.h -20},"Back", 
		blank_button_off,blank_button_on,
		function() 

		end)
help_button:on_focus()
help:add(help_img,help_button.group)
screen:add(help)
help.anchor_point = {   help.w/2,   help.h/2 }
help.position     = { screen_w/2, screen_h/2 }


local splash     = Group{z=2,anchor_point={panel.w/2,panel.h/2},x=screen_w/2,y=screen_h/2}
local difficulty = Group{z=2,anchor_point={panel.w/2,panel.h/2},x=screen_w/2,y=screen_h/2,opacity=0}
local confirm    = Group{z=2,anchor_point={panel.w/2,panel.h/2},x=screen_w/2,y=screen_h/2,opacity=0}

local dim = Rectangle{color ="000000", w=screen_w,h=screen_h,opacity=100,z=2}
local side_font = "Dejavu Bold 60px"
right_menu = Group{z=1}
yellow_light = Image{src="assets/button-yellow-circle.png",x=0,y=2*(blank_button_off.h+8),opacity=0}
local right_list = {}
right_list = {
	FocusableImage({0,0},"Cheat", 
		red_button_off,red_button_on,
		function() 
			game:cheat()
		end),

	FocusableImage({0,blank_button_off.h+8},"Undo Move", 
		green_button_off,green_button_on,
		function() 
			local r,c
			r,c = game:undo() 
			return r,c
		end),

	FocusableImage({0,2*(blank_button_off.h+8)},"Show Errors", 
		yellow_button_off,yellow_button_on, 
		function() 
			game:error_check() 
			if right_list[3].group:find_child("text").text == "Show Errors" then
				right_list[3].group:find_child("text").text = "Hide Errors"
				right_list[3].group:find_child("text_s").text = "Hide Errors"
				yellow_light.opacity = 255
			else
				right_list[3].group:find_child("text").text = "Show Errors"
				right_list[3].group:find_child("text_s").text = "Show Errors"
				yellow_light.opacity = 0
			end
			restore_keys()
		end),

	FocusableImage({0,3*(blank_button_off.h+8)},"Restart Puzzle", 
		blue_button_off, blue_button_on, 
		function() 
			if red_is_on then
				game = Game(game:get_all_givens(),
					game:get_sol(),nil,blue_blox)
			else
				game = Game(game:get_all_givens(),
					game:get_sol(),nil,red_blox)
			end
			dolater(flip_board)
			win_txt:unparent()
			won = false
			right_list[3].group:find_child("text").text = "Show Errors"
			right_list[3].group:find_child("text_s").text = "Show Errors"
			yellow_light.opacity = 0
			--game:restart() 
			--restore_keys()
		end)
}
right_menu:add( 
	right_list[1].group,
	right_list[2].group,
	right_list[3].group,
	right_list[4].group, 
	yellow_light 
)

--right_menu.anchor_point = {blank_button_off.w/2,0}
--right_menu.y_rotation ={-25,right_menu.w/2,0}
--right_menu.position = {screen.w - right_menu.w/2+80,red.h   + 90}
right_menu.position = 
{
	screen_w/2+3/2*block_sz+30+
		(screen_w/2-3/2*block_sz - blank_button_off.w-30)/2,
	screen_h/2-block_sz/2-10
}
right_menu.y_rotation = {-135,blank_button_off.w,0}
right_menu.opacity=0
local left_menu = Group{z=1}
local left_list = 
{
	FocusableImage({0,0},"New Puzzle", 
		blank_button_off,blank_button_on,
		function() 
						focus = "ARE_YOU_SURE"
						confirm.opacity   = 255
						conf_from = "GAME_LEFT"
						confirm:find_child("DIFF").opacity=0
						confirm:find_child("GAME_LEFT").opacity=255
restore_keys()
--[[
			if red_is_on then
				local givens, sol
				givens,sol =BoardGen(num_givens) 
				game = Game(givens,sol,nil,blue_blox)
			else
				local givens, sol
				givens,sol =BoardGen(num_givens) 
				game = Game(givens,sol,nil,red_blox)
			end
			dolater(flip_board)
			win_txt:unparent()
			won = false
			right_list[3].group:find_child("text").text = "Show Errors"
			right_list[3].group:find_child("text_s").text = "Show Errors"
			yellow_light.opacity = 0
			--restore_keys()
--]]
		end),

	FocusableImage({0,blank_button_off.h+8},"Help", 
		blank_button_off,blank_button_on,
		function() 
			help.opacity = 255
			help:raise_to_top()
			focus = "HELP"
			dim.opacity = 100
			restore_keys()
		end),
	FocusableImage({0,2*(blank_button_off.h+8)},"Difficulty", 
		blank_button_off,blank_button_on,
		function() 
			difficulty.opacity = 255
--			records:raise_to_top()
			focus = "DIFF"
			diff_from  = "GAME_LEFT"
			dim.opacity = 100
			restore_keys()
		end),


	FocusableImage({0,3*(blank_button_off.h+8)},"Save & Exit", 
		blank_button_off,blank_button_on,
		function() 
			game:save()
			exit()
			restore_keys()
		end)
}
left_menu:add( left_list[1].group,left_list[2].group,left_list[3].group,left_list[4].group )
--left_menu.anchor_point = {left_menu.w/2,left_menu.h/2}
left_menu.position = {(screen_w/2-3/2*block_sz - blank_button_off.w-30)/2,screen_h/2-block_sz/2-10}
left_menu.y_rotation={135,0,0}
left_menu.opacity=0

local left_index = 1
local right_index = 1


function flip_board()
	screen.on_key_down = nil
	local timeline = Timeline
	{
		duration  =  200*(3+3),
		loop      =  false,
		direction = "FORWARD"
	}
	save(timeline)
--	local stopwatch = Stopwatch()
	local lookups = {o_b = {},n_b ={}}
	local old_board, new_board, old_bg, new_bg,old_group,new_group
	
	if red_is_on then
		old_group =  red_board2
		new_group = blue_board2
		old_board =   red_blox
		new_board =  blue_blox
		old_bg    =     red_bg
		new_bg    =    blue_bg
	else
		old_group = blue_board2
		new_group =  red_board2
		old_board = blue_blox
		new_board =  red_blox
		old_bg    =   blue_bg
		new_bg    =    red_bg
	end

	for r = 1,3 do 
		lookups.o_b[r] = {}
		lookups.n_b[r] = {}
		for c = 1,3 do
			lookups.o_b[r][c] = old_board[r][c].w/2
			lookups.n_b[r][c] = new_board[r][c].w/2

			new_group:find_child("3x3 "..r.." "..c).y_rotation =
				{-180, lookups.n_b[r][c],0}

			new_board[r][c].y_rotation = {-180,lookups.n_b[r][c],0}
		end
	end 

	function timeline.on_new_frame(t,msecs,prog)
--[[
if stopwatch then
	print(stopwatch.elapsed)
	stopwatch = nil
end
--]]
		bg.color = 
		{
			old_bg[1] + prog*(new_bg[1]-old_bg[1]),
			old_bg[2] + prog*(new_bg[2]-old_bg[2]),
			old_bg[3] + prog*(new_bg[3]-old_bg[3])
		}
		local stage_i = math.ceil(msecs / 200) --stages 1-15
				
		local p = (msecs - (stage_i-1)*200) / 200  --progress w/in a stage
		local degrees_old, degrees_new
		local old_tile,    new_tile
		for r = 1,3 do   for c = 1,3 do

			old_tile = old_group:find_child("3x3 "..r.." "..c)
			new_tile = new_group:find_child("3x3 "..r.." "..c)

			--flipping stage 1
			-- the old board tiles rotate from    0 - 90
			-- the new board tiles rotate from -180 - 90
			if (r+c-1)  == stage_i then
				degrees_old = 90*(p)
			--flipping stage 2
			-- the old board tiles rotate from  90 - 180
			-- the new board tiles rotate from -90 - 0
			elseif (r+c-1)  == stage_i - 1 then
				degrees_old = 90+90*(p)
			--already flipped
			-- the old board tiles are at 180
			-- the new board tiles are at   0
			elseif (r+c-1) < stage_i - 1 then
				degrees_old = 180
			--havent flipped
			-- the old board tiles are at    0
			-- the new board tiles are at -180
			else
				degrees_old = 0
			end					
			degrees_new = degrees_old - 180

			old_tile.y_rotation = { degrees_old, 
				block_sz/2, 0 }
			new_tile.y_rotation = { degrees_new, 
				block_sz/2, 0 }

			old_board[r][c].y_rotation = { degrees_old, lookups.o_b[r][c], 0 }
			new_board[r][c].y_rotation = { degrees_new, lookups.n_b[r][c], 0 }

			if degrees_old <  135 and degrees_old >  45 then
				old_board[r][c].opacity = 255 * (1- (degrees_old - 45)/90)
				old_tile.opacity        = 255 * (1- (degrees_old - 45)/90)
			elseif degrees_old > 135 then
				old_board[r][c].opacity = 0
				old_tile.opacity = 0
			end
			if degrees_new > -135 and degrees_new < -45 then
				new_board[r][c].opacity = 255* (degrees_new - 45)/90
				new_tile.opacity        = 255* (degrees_new - 45)/90
			elseif degrees_new > -45 then
				new_board[r][c].opacity = 255
				new_tile.opacity        = 255
			end

		end		end

	end
	function timeline.on_completed()
		local old_tile,    new_tile

		for r = 1,3 do   for c = 1,3 do
			old_tile = old_group:find_child("3x3 "..r.." "..c)
			new_tile = new_group:find_child("3x3 "..r.." "..c)

			old_tile.y_rotation = { 180, block_sz/2, 0 }
			new_tile.y_rotation = {   0, block_sz/2, 0 }
			old_tile.opacity =   0
			new_tile.opacity = 255

			old_board[r][c].y_rotation = { 180, lookups.o_b[r][c], 0 }
			new_board[r][c].y_rotation = {   0, lookups.n_b[r][c], 0 }
			old_board[r][c].opacity =   0
			new_board[r][c].opacity = 255

		end              end

		if red_is_on then 
			for r = 1,3 do   for c = 1,3 do
				red_blox[r][c]:clear()
			end              end
			
			red_is_on = false 
		else 
			for r = 1,3 do   for c = 1,3 do
				blue_blox[r][c]:clear()
			end              end

			red_is_on = true 
		end

		bg.color = { new_bg[1], new_bg[2], new_bg[3] }	

		clear(timeline)
		restore_keys()
	end
	timeline:start()
	mediaplayer:play_sound("audio/new_game.mp3")

end

local num_font = "DejaVu Bold Condensed 30px"
local pencil_menu    = Group{y=40,opacity=0,z=1}
local p_m_button_on  = Image{src="assets/button_on.png",y=60,x=105,opacity=0}
local p_m_button_off = Image{src="assets/button_off.png",y=60,x=105,opacity=0}
screen:add(p_m_button_on,p_m_button_off)

local clear_txt        = Text{ name  = "clear", 
                               text  = "Clear",
                               font  = "DejaVu 36px",
                               color = "FFFFFF"}
clear_txt.anchor_point = {         clear_txt.w/2,        clear_txt.h/2 }
clear_txt.position     = { 105+p_m_button_on.w/2, 60+p_m_button_on.h/2 }

local done_txt        = Text{ name  = "done", 
                              text  = "Done",
                              font  = "DejaVu 36px",
                              color = "FFFFFF"}
done_txt.anchor_point = {          done_txt.w/2,        done_txt.h/2 }
done_txt.position     = { 215+p_m_button_on.w/2,60+p_m_button_on.h/2 }

function p_x(i) return 24*i+80 end

pencil_menu:add(
	Image{name="bg_up",src="assets/pencil-menu-up.png"},
	Image{name="bg_dn",src="assets/pencil-menu-down.png",y=15},
	Text{name="1",text="1",font=num_font,color="FFFFFF",x=p_x(1),y=25},
	Text{name="2",text="2",font=num_font,color="FFFFFF",x=p_x(2),y=25},
	Text{name="3",text="3",font=num_font,color="FFFFFF",x=p_x(3),y=25},
	Text{name="4",text="4",font=num_font,color="FFFFFF",x=p_x(4),y=25},
	Text{name="5",text="5",font=num_font,color="FFFFFF",x=p_x(5),y=25},
	Text{name="6",text="6",font=num_font,color="FFFFFF",x=p_x(6),y=25},
	Text{name="7",text="7",font=num_font,color="FFFFFF",x=p_x(7),y=25},
	Text{name="8",text="8",font=num_font,color="FFFFFF",x=p_x(8),y=25},
	Text{name="9",text="9",font=num_font,color="FFFFFF",x=p_x(9),y=25},
	Clone{name="clear_on",  source= p_m_button_on,  y=60,x=105,opacity=255},
	Clone{name="clear_off", source= p_m_button_off, y=60,x=105,opacity=255},
	clear_txt,
	Clone{name="done_on",  source= p_m_button_on,  y=60,x=215,opacity=255},
	Clone{name="done_off", source= p_m_button_off, y=60,x=215,opacity=255},
	done_txt
)
screen:add(pencil_menu)

--[[ Game Clock Code, could potentially be used again
local clock_sec = 50
local clock_min = 59
local clock_hr = 0
local clock_txt = Text{
	text = "00:00",
	font = side_font,
	color = "FFFFFF",
	x = 50,
	y = 200,
	z = 2
}
screen:add(clock_txt)
clock = Timer{interval = 1000}
function clock:on_timer()
	if clock_sec < 59 then
		clock_sec = clock_sec + 1
	elseif clock_min < 59 then
		clock_sec = 0
		clock_min = clock_min + 1
	else
		clock_sec = 0
		clock_min = 0
		clock_hr  = clock_hr + 1
	end
	
	local base = ""
	if clock_hr > 0 then
		base = clock_hr..":"
	end
	if clock_min > 9 then
		base = base..clock_min..":"
	else
		base = base.."0"..clock_min..":"
	end
	if clock_sec > 9 then
		base = base..clock_sec
	else
		base = base.."0"..clock_sec
	end
	clock_txt.text = base
end
--]]





splash:add(Clone{source=panel,        x=panel.w/2, y=panel.h/2,anchor_point={panel.w/2,panel.h/2}},
           Clone{source=sudoku_title, x=panel.w/2, y=60,       anchor_point={sudoku_title.w/2, 0}})
local splash_list = {}
local splash_hor_index = 1
if settings.givens and settings.sol and settings.guesses then
	splash_list = 
	{
		FocusableImage(
			{panel.w/2-blank_button_off.w - 20,
			 panel.h/2+50},
			"Continue Game", 
			blank_button_off,blank_button_on,
			function(pass_in_splash) 
				focus = "GAME_BOARD"
				selector.opacity = 255
				dolater(splash_to_game,function() restore_keys() end,splash)
			end),
		FocusableImage({panel.w/2+ 20,panel.h/2+50},"New Game", 
			blank_button_off,blank_button_on,
			function() 
				focus = "DIFF"
				splash.opacity=0
				difficulty.opacity=255
				difficulty:raise_to_top()
				restore_keys()
			end)
	}
	splash:add( 
		splash_list[1].group,
		splash_list[2].group 
	)

	if red_is_on then
		game = Game(settings.givens,settings.sol,
			settings.guesses,red_blox,settings.undo)
	else
		game = Game(settings.givens,settings.sol,
			settings.guesses,blue_blox,settings.undo)
	end
	screen:add(game.board)
else
	splash_list = 
	{
		FocusableImage({panel.w/2-blank_button_off.w/2,
			panel.h/2+50},
			"New Game", 
			blank_button_off,blank_button_on,
			function() 
				focus = "DIFF"
				splash.opacity=0
				difficulty.opacity=255
				difficulty:raise_to_top()
				restore_keys()
			end)
	}
	splash:add( splash_list[1].group )

	game = nil
end
splash_list[1]:on_focus()

local game_num = {45,55,30}
local game_opts = {"Medium","Easy","Hard"}
local curr_opt = 1
local diff_hor_index = 2
local diff_list = {
 	FocusableImage(
		{panel.w/2-blank_button_off.w - 20,
		 panel.h/2+50},
		"Back", 
		blank_button_off,blank_button_on,
		function() restore_keys() end),
	VertButtonCarousel(
		"Difficulty",
		game_opts,
		{panel.w/2+20,
		panel.h/2+50-arrows[1].h},
		blanks,
		arrows
	)
}



diff_list[2]:on_focus()
difficulty:add(
	Clone{
		source=panel,
		x = panel.w/2,
		y = panel.h/2,
		anchor_point={panel.w/2,panel.h/2}
	},
	Clone{
		source=diff_title,
		x = panel.w/2,
		y = 60,
		anchor_point={diff_title.w/2,0}
	},
	diff_list[1].group,
	diff_list[2].group
)
local are_you_sure = false
local conf_hor_index = 2
local conf_list = {
 	FocusableImage(
		{panel.w/2-blank_button_off.w - 20,
		 panel.h/2+90},
		"No", 
		blank_button_off,blank_button_on,
		function() restore_keys() end),
 	FocusableImage(
		{panel.w/2 + 20,
		 panel.h/2 + 90},
		"Yes", 
		blank_button_off,blank_button_on,
		function() restore_keys() end),
}
conf_list[conf_hor_index]:on_focus()
confirm:add(
	Clone{
		source=panel,
		x = panel.w/2,
		y = panel.h/2,
		anchor_point={panel.w/2,panel.h/2}
	},
	Clone{
		name="GAME_LEFT",
		source=sudoku_title,
		x = panel.w/2,
		y = 60,
		anchor_point={sudoku_title.w/2,0}
	},
	Clone{
		name="DIFF",
		source=diff_title,
		x = panel.w/2,
		y = 60,
		anchor_point={diff_title.w/2,0}
	},
	Clone{
		source=conf_text,
        x = panel.w/2,
        y = panel.h/2+10,
		anchor_point={conf_text.w/2,0}
	},
	conf_list[1].group,
	conf_list[2].group
)

screen:add(dim,splash,difficulty,confirm)
Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}

function splash_to_game(next_func,prev_menu)
	local deg = 135
	screen.on_key_down = nil
	local timeline = Timeline
	{
		duration = 500
	}
	save(timeline)
	function timeline.on_new_frame(t,msecs,p)
		dim.opacity = 100*(1-p)
		left_menu.y_rotation  = {deg*(1-p),0,0}
		right_menu.y_rotation = {-deg*(1-p),blank_button_off.w,0}
		left_menu.opacity     = 255*p
		right_menu.opacity    = 255*p
		top_left_logo.opacity = 255*p
		prev_menu.opacity     = 255*(1-p)
	end
	function timeline:on_completed()
		dim.opacity = 0
		left_menu.y_rotation = {0,0,0}
		right_menu.y_rotation = {0,blank_button_off.w,0}
		left_menu.opacity = 255
		right_menu.opacity = 255
		top_left_logo.opacity = 255
		prev_menu.opacity = 0
		if next_func then
			dolater(next_func)
		else
			restore_keys()
		end
		clear(timeline)
	end
	timeline:start()
end


local pencil_menu_index = 2
focus = "SPLASH"
local game_on = false
local ind = {r=1,c=1}
function num_press(n)
	if won then
		restore_keys()
		return 
	end
	if menu_open then
		game:toggle_guess(ind.r,ind.c,n,"REG")
		local g = game:get_guesses(ind.r,ind.c)
		for i = 1,9 do
			if g[i] then
				pencil_menu:find_child(i.."").color = "202020"
			else
				pencil_menu:find_child(i.."").color = "FFFFFF"
			end
		end
	else
		game:pen(ind.r,ind.c,n)
	end
end
function game_on_key_down(k)
	local key = 
	{
		[keys.Down] = function()
			if not menu_open and ind.r < 9 then
				ind.r=ind.r+1
				selector.x,selector.y = sel_pos(ind.r,ind.c)
			end
			restore_keys()
		end,
		[keys.Up] = function()
			if not menu_open and ind.r > 1 then
				ind.r=ind.r-1
				selector.x,selector.y = sel_pos(ind.r,ind.c)
			end
			restore_keys()
		end,
		[keys.Right] = function()
			if menu_open then
				pencil_menu_index = 2

				pencil_menu:find_child("clear_on").opacity  = 0
				pencil_menu:find_child("clear_off").opacity = 255
				pencil_menu:find_child("clear").color       = "FFFFFF"

				pencil_menu:find_child("done_on").opacity  = 255
				pencil_menu:find_child("done_off").opacity = 0
				pencil_menu:find_child("done").color       = "202020"

			else
				if ind.c < 9 then
					ind.c=ind.c+1
					selector.x,selector.y = sel_pos(ind.r,ind.c)
				else
					focus = "GAME_RIGHT"
					right_list[right_index]:on_focus()
					selector.opacity = 0
				end
			end
			restore_keys()
		end,
		[keys.Left] = function()
			if menu_open then
				pencil_menu_index = 1

				pencil_menu:find_child("clear_on").opacity  = 255
				pencil_menu:find_child("clear_off").opacity = 0
				pencil_menu:find_child("clear").color       = "202020"

				pencil_menu:find_child("done_on").opacity  = 0
				pencil_menu:find_child("done_off").opacity = 255
				pencil_menu:find_child("done").color       = "FFFFFF"
				
			else
				if ind.c > 1 then
					ind.c=ind.c-1
					selector.x,selector.y = sel_pos(ind.r,ind.c)
				else
					focus = "GAME_LEFT"
					left_list[left_index]:on_focus()
					selector.opacity = 0
				end
			end
			restore_keys()
		end,
		[keys.Return] = function()
			if menu_open then
				if pencil_menu_index == 1 then
					game:clear_tile(ind.r,ind.c)
					local g = game:get_guesses(ind.r,ind.c)
					for i = 1,9 do
						if g[i] then
							pencil_menu:find_child(i.."").color = "202020"
						else
							pencil_menu:find_child(i.."").color = "FFFFFF"
						end
					end


				elseif pencil_menu_index == 2 then
					menu_open = false
					pencil_menu.opacity = 0
				else
					error("pencil_menu_index is "..pencil_menu_index)
				end
			elseif game:get_givens(ind.r,ind.c) == 0 then
				menu_open = true
				pencil_menu.opacity = 255
				pencil_menu_index = 2
				local g = game:get_guesses(ind.r,ind.c)
				for i = 1,9 do
					if g[i] then
						pencil_menu:find_child(i.."").color = "202020"
					else
						pencil_menu:find_child(i.."").color = "FFFFFF"
					end
				end
				if ind.r > 9/2 then
					pencil_menu:find_child("bg_up").opacity=0
					pencil_menu:find_child("bg_dn").opacity=255
					pencil_menu.x = selector.x - 163
					pencil_menu.y = selector.y - selector.h/2 - 
					                pencil_menu.h +20

					pencil_menu:find_child("clear_on").opacity = 0
					pencil_menu:find_child("clear_off").opacity = 255
					pencil_menu:find_child("clear").color = "FFFFFF"

					pencil_menu:find_child("done_on").opacity = 255
					pencil_menu:find_child("done_off").opacity = 0
					pencil_menu:find_child("done").color = "202020"
				else
					pencil_menu:find_child("bg_up").opacity=255
					pencil_menu:find_child("bg_dn").opacity=0
					pencil_menu.x = selector.x - 163
					pencil_menu.y = selector.y + selector.h/2-20

					pencil_menu:find_child("clear_on").opacity = 0
					pencil_menu:find_child("clear_off").opacity = 255
					pencil_menu:find_child("clear").color = "FFFFFF"

					pencil_menu:find_child("done_on").opacity = 255
					pencil_menu:find_child("done_off").opacity = 0
					pencil_menu:find_child("done").color = "202020"

				end	
				--pencil_menu:raise_to_top()
			end
			restore_keys()
		end,
		[keys["1"] ] = function() num_press(1) end,
		[keys["2"] ] = function() num_press(2) end,
		[keys["3"] ] = function() num_press(3) end,
		[keys["4"] ] = function() num_press(4) end,
		[keys["5"] ] = function() num_press(5) end,
		[keys["6"] ] = function() num_press(6) end,
		[keys["7"] ] = function() num_press(7) end,
		[keys["8"] ] = function() num_press(8) end,
		[keys["9"] ] = function() num_press(9) end,


		[keys["KP_End"] ]       = function() num_press(1) end,
		[keys["KP_Down"] ]      = function() num_press(2) end,
		[keys["KP_Page_Down"] ] = function() num_press(3) end,
		[keys["KP_Left"] ]      = function() num_press(4) end,
		[keys["KP_Begin"] ]     = function() num_press(5) end,
		[keys["KP_Right"] ]     = function() num_press(6) end,
		[keys["KP_Home"] ]      = function() num_press(7) end,
		[keys["KP_Up"] ]        = function() num_press(8) end,
		[keys["KP_Page_Up"] ]   = function() num_press(9) end,
		[keys["c"] ] = function()
			if won or menu_open then
				restore_keys()
				return
			else
				right_list[1]:press_enter()
			end
		end,
		[keys["u"] ] = function()
			if won or menu_open then
				restore_keys()
				return
			else
				local r,c
				r,c = right_list[2]:press_enter()
				if menu_open and ind.r ==r and ind.c == c then
					local g = game:get_guesses(ind.r,ind.c)
					for i = 1,9 do
						if g[i] then
							pencil_menu:find_child(i.."").color = "202020"
						else
							pencil_menu:find_child(i.."").color = "FFFFFF"
						end
					end
				end
			end
		end,
		[keys["e"] ] = function()
			if won or menu_open then
				restore_keys()
				return
			else
				right_list[3]:press_enter()
			end
		end,
		[keys["r"] ] = function()
			if won or menu_open then
				restore_keys()
				return
			else
				right_list[4]:press_enter()
			end
		end
	}
	if key[k] then 
		key[k]() 
	else
		restore_keys()
	end
end
function confirm_on_key_down(k)
	local key = 
	{
		[keys.Left] = function()
				if conf_hor_index > 1 then
					conf_list[conf_hor_index]:out_focus()
					conf_hor_index = conf_hor_index - 1
					conf_list[conf_hor_index]:on_focus()
				end
			restore_keys()
		end,
		[keys.Right] = function()
				if conf_hor_index < #conf_list then
					conf_list[conf_hor_index]:out_focus()
					conf_hor_index = conf_hor_index + 1
					conf_list[conf_hor_index]:on_focus()
				end
			restore_keys()
		end,
		[keys.Return] = function()
				if conf_hor_index == 2 then

						if red_is_on then
							local givens,sol
							givens,sol = BoardGen(num_givens)
							game = Game(givens,sol,nil,blue_blox)
						else
							local givens,sol
							givens,sol = BoardGen(num_givens)
							game = Game(givens,sol,nil,red_blox)
						end
                
						ind = {r=1,c=1}
						selector.x, selector.y = sel_pos(1,1)
						selector.opacity = 255

						focus = "GAME_BOARD"

						left_list[left_index]:out_focus()
						left_index      = 1
						confirm.opacity = 0
						dim.opacity     = 0
						dolater(flip_board)
						are_you_sure      = false


				elseif conf_hor_index == 1 then
						are_you_sure      = false
						focus = conf_from
						confirm.opacity   = 0
						if conf_from == "DIFF" then
							difficulty.opacity = 255
						end
						conf_hor_index = 2
						conf_list[1]:out_focus()
						conf_list[2]:on_focus()
						restore_keys()
				end
			restore_keys()
		end
	}
	if key[k] then key[k]() else restore_keys() end
end
function diff_on_key_down(k)
	local key = 
	{
		[keys.Left] = function()
			if are_you_sure then
				if conf_hor_index > 1 then
					conf_list[conf_hor_index]:out_focus()
					conf_hor_index = conf_hor_index - 1
					conf_list[conf_hor_index]:on_focus()
				end
			else
				if diff_hor_index > 1 then
					diff_list[diff_hor_index]:out_focus()
					diff_hor_index = diff_hor_index - 1
					diff_list[diff_hor_index]:on_focus()
				end
			end
			restore_keys()

		end,
		[keys.Right] = function()
			if are_you_sure then
				if conf_hor_index < #conf_list then
					conf_list[conf_hor_index]:out_focus()
					conf_hor_index = conf_hor_index + 1
					conf_list[conf_hor_index]:on_focus()
				end
			else
				if diff_hor_index < #diff_list then
					diff_list[diff_hor_index]:out_focus()
					diff_hor_index = diff_hor_index + 1
					diff_list[diff_hor_index]:on_focus()
				end
			end
			restore_keys()
		end,
		[ keys.Up ] = function()
			if are_you_sure then
			else
				if diff_hor_index == 2 then
					curr_opt = (curr_opt - 1-1)%(#game_opts)+1
					num_givens = game_num[curr_opt]
					diff_list[2]:press_up()
				end
			end
			restore_keys()
		end,
		[ keys.Down ] = function()
			if are_you_sure then
			else
				if diff_hor_index == 2 then
					curr_opt = (curr_opt + 1-1)%(#game_opts)+1
					num_givens = game_num[curr_opt]
					diff_list[2]:press_down()
				end
			end
			restore_keys()
		end,
		[ keys.Return ] = function()
			if are_you_sure then
				if conf_hor_index == 2 then

					if red_is_on then
						local givens,sol
						givens,sol = BoardGen(num_givens)
						game = Game(givens,sol,nil,blue_blox)
					else
						local givens,sol
						givens,sol = BoardGen(num_givens)
						game = Game(givens,sol,nil,red_blox)
					end

					ind = {r=1,c=1}
					selector.x, selector.y = sel_pos(1,1)
					selector.opacity = 255

						focus = "GAME_BOARD"

						left_list[left_index]:out_focus()
						left_index      = 1
						confirm.opacity = 0
						dim.opacity     = 0
						dolater(flip_board)
						are_you_sure      = false


				elseif conf_hor_index == 1 then
						focus = "DIFF"
						--are_you_sure      = false
						confirm.opacity   = 0
						difficulty.opacity = 255
						conf_hor_index = 2
						conf_list[1]:out_focus()
						conf_list[2]:on_focus()
						restore_keys()
				end
			else
				if diff_hor_index == 1 then

					if diff_from == "SPLASH" then
						focus = "SPLASH"
						splash.opacity=255
						difficulty.opacity=0
						splash:raise_to_top()
					else
						focus = "GAME_LEFT"
						difficulty.opacity=0
						dim.opacity = 0

					end
					restore_keys()

				elseif diff_hor_index == 2 then
--					if red_is_on then
--						local givens,sol
--						givens,sol = BoardGen(num_givens)
--						game = Game(givens,sol,nil,blue_blox)
--					else
--						local givens,sol
--						givens,sol = BoardGen(num_givens)
--						game = Game(givens,sol,nil,red_blox)
--					end
--					--collectgarbage("collect")
--					ind = {r=1,c=1}
--					focus = "GAME_BOARD"
					if diff_from == "SPLASH" then
						if red_is_on then
							local givens,sol
							givens,sol = BoardGen(num_givens)
							game = Game(givens,sol,nil,blue_blox)
						else
							local givens,sol
							givens,sol = BoardGen(num_givens)
							game = Game(givens,sol,nil,red_blox)
						end

						selector.opacity = 255

						focus = "GAME_BOARD"
						dolater(splash_to_game,flip_board,difficulty)
					else
						--are_you_sure = true
						focus = "ARE_YOU_SURE"
						confirm.opacity = 255
						difficulty.opacity = 0
						restore_keys()
						conf_from = "DIFF"
						confirm:find_child("DIFF").opacity=255
						confirm:find_child("GAME_LEFT").opacity=0
--[[
						left_list[left_index]:out_focus()
						left_index = 1
						difficulty.opacity=0
						dim.opacity = 0
						dolater(flip_board)
--]]
					end
					won = false
				end 
			end
		end
	}
	if key[k] then key[k]() else restore_keys() end
end
function splash_on_key_down(k)
	local key = 
	{
		[ keys.Return ] = function()
			splash_list[splash_hor_index]:press_enter(splash)
			diff_from = "SPLASH"
		end,
		[keys.Left] = function()
			if splash_hor_index > 1 then
				splash_list[splash_hor_index]:out_focus()
				splash_hor_index = splash_hor_index - 1
				splash_list[splash_hor_index]:on_focus()
			end
			restore_keys()

		end,
		[keys.Right] = function()
			if splash_hor_index < #splash_list then
				splash_list[splash_hor_index]:out_focus()
				splash_hor_index = splash_hor_index + 1
				splash_list[splash_hor_index]:on_focus()
			end
			restore_keys()
		end,
	}
	if key[k] then key[k]() else restore_keys() end

end
function left_menu_on_key_down(k)
	local key = 
	{
		[keys.Up] = function()
			if left_index > 1 then
				left_list[left_index]:out_focus()
				left_index = left_index - 1
				left_list[left_index]:on_focus()
			end
			restore_keys()
		end,
		[keys.Down] = function()
			if left_index < #left_list then
				left_list[left_index]:out_focus()
				left_index = left_index + 1
				left_list[left_index]:on_focus()
			end
			restore_keys()
		end,
		[keys.Right] = function()
			left_list[left_index]:out_focus()
			left_index = 1
			focus = "GAME_BOARD"
			selector.opacity = 255
			restore_keys()

		end,
		[keys.Left] = function()
			right_list[left_index]:on_focus()
			left_list[left_index]:out_focus()
			right_index = left_index
			left_index = 1
			focus = "GAME_RIGHT"
			ind.c = 9
			selector.x,selector.y = sel_pos(ind.r,ind.c)
			restore_keys()
		end,

		[keys.Return] = function()
			left_list[left_index]:press_enter()
		end,
		[keys["c"] ] = function()
			if won then
				restore_keys()
				return
			else
				right_list[1]:press_enter()
			end
		end,
		[keys["u"] ] = function()
			if won then
				restore_keys()
				return
			else
				right_list[2]:press_enter()
			end
		end,
		[keys["e"] ] = function()
			if won then
				restore_keys()
				return
			else
				right_list[3]:press_enter()
			end
		end,
		[keys["r"] ] = function()
			if won then
				restore_keys()
				return
			else
				right_list[4]:press_enter()
			end
		end

	}
	if key[k] then 
		key[k]() 
	else
		restore_keys()
	end
end

function right_menu_on_key_down(k)
	local key = 
	{
		[keys.Up] = function()
			if right_index > 1 then
				right_list[   right_index]:out_focus()
				right_index = right_index - 1
				right_list[   right_index]:on_focus()
			end
			restore_keys()
		end,
		[keys.Down] = function()
			if right_index < #right_list then
				right_list[   right_index]:out_focus()
				right_index = right_index + 1
				right_list[   right_index]:on_focus()
			end
			restore_keys()
		end,
		[keys.Left] = function()
			right_list[right_index]:out_focus()
			right_index = 1
			focus = "GAME_BOARD"
			selector.opacity = 255
			restore_keys()
		end,
		[keys.Right] = function()
			right_list[right_index]:out_focus()
			left_list[right_index]:on_focus()
			left_index = right_index
			right_index = 1
			focus = "GAME_LEFT"
			ind.c = 1
			selector.x,selector.y = sel_pos(ind.r,ind.c)
			restore_keys()
		end,
		[keys.Return] = function()
			right_list[right_index]:press_enter()
		end,
		[keys["c"] ] = function()
			if won then
				restore_keys()
				return
			else
				right_list[1]:press_enter()
			end
		end,
		[keys["u"] ] = function()
			if won then
				restore_keys()
				return
			else
				right_list[2]:press_enter()
			end
		end,
		[keys["e"] ] = function()
			if won then
				restore_keys()
				return
			else
				right_list[3]:press_enter()
			end
		end,
		[keys["r"] ] = function()
			if won then
				restore_keys()
				return
			else
				right_list[4]:press_enter()
			end
		end
	}
	if key[k] then 
		key[k]() 
	else
		restore_keys()
	end
end
function screen:on_key_down(k)
	screen.on_key_down = nil

	if k == keys.RED    then k = keys.c end
	if k == keys.GREEN  then k = keys.u end
	if k == keys.YELLOW then k = keys.e end
	if k == keys.BLUE   then k = keys.r end
	if k == keys.OK     then k = keys.Return end

	local sub_on_key_down = 
	{
		["ARE_YOU_SURE"] = function(key_press)
			confirm_on_key_down(key_press)
		end,
		["SPLASH"] = function(key_press)
			splash_on_key_down(key_press)
		end,
		["DIFF"] = function(key_press)
			diff_on_key_down(key_press)
		end,
		["GAME_BOARD"] = function(key_press)
			game_on_key_down(key_press)
		end,
		["GAME_LEFT"] = function(key_press)
			left_menu_on_key_down(key_press)
		end,
		["GAME_RIGHT"] = function(key_press)
			right_menu_on_key_down(key_press)
		end,		
		["HELP"] = function(key_press)
			if key_press == keys.Return then
				dim.opacity  = 0
				help.opacity = 0
				focus = "GAME_LEFT"
			end
			restore_keys()
		end,	
	}
	if k == keys.s then
		start_sparkle({200,300,400},
{200,300,400},12)
restore_keys()
		return
	end
	if sub_on_key_down[focus] then
		sub_on_key_down[focus](k)
	else
		error(focus.." does not have an on_key_down")
	end
end
store_keys = screen.on_key_down
function restore_keys()
	screen.on_key_down = store_keys
end
function player_won()
	local y = {100}
	local x = {1660,1680,1700,1720}
	win_txt.opacity=0
	if focus == "GAME_RIGHT" then
		right_list[right_index]:out_focus()
	end
	start_sparkle(x,y,6)
	focus = "GAME_LEFT"
	selector.opacity = 0
	ind.r = 1
	ind.c = 1
	selector.x,selector.y = sel_pos(1,1)
	left_list[left_index]:on_focus()
end
function app:on_closing()
	if game then
		game:save()
	end
end
screen:add(right_menu,left_menu)

selector.x,selector.y = sel_pos(1,1)
--game:on_focus(1,1)
screen:show()
