math.randomseed(os.time())

dofile("Class.lua") -- Must be declared before any class definitions.

dofile("Game.lua")

dofile("FocusableImage.lua")
local num_givens = 50
--local bg = Image{src="assets/background.jpg"}
local blank_button_on   = Image{src="assets/blank_on.png",      opacity=0}
local blank_button_off  = Image{src="assets/blank_off.png",     opacity=0}
local green_button_on   = Image{src="assets/green_on.png",      opacity=0}
local green_button_off  = Image{src="assets/green_off.png",     opacity=0}
local red_button_on     = Image{src="assets/red_on.png",        opacity=0}
local red_button_off    = Image{src="assets/red_off.png",       opacity=0}
local blue_button_on    = Image{src="assets/blue_on.png",       opacity=0}
local blue_button_off   = Image{src="assets/blue_off.png",      opacity=0}
local yellow_button_on  = Image{src="assets/yellow_on.png",     opacity=0}
local yellow_button_off = Image{src="assets/yellow_off.png",    opacity=0}
local blue              = Image{src ="assets/3x3grid-blue.png", opacity=0}
local red               = Image{src ="assets/3x3grid-red.png",  opacity=0}
sparkle_base            = Image{src ="assets/Sparkle.png",      opacity=0}
--sparkle = Group{name="\n\n\njhsdfsdfjklsdfjkl;d",z=3}

screen:add(
	 blank_button_on,  blank_button_off, green_button_on, green_button_off,
	   red_button_on,    red_button_off,  blue_button_on,  blue_button_off,
	yellow_button_on, yellow_button_off,             red,             blue,
	         sparkle_base

)

--sparkle:add(sparkle_base)
--sparkle.clip = {0,0,sparkle_base.w/5,sparkle_base.h}
--sparkle.anchor_point = {sparkle_base.w/(5*2),sparkle_base.h/2}
function start_sparkle(x,y, num_sparkles)
	local timeline = Timeline
	{
		duration = 2000,
		loop = false,
		direction = "FORWARD"
	}
	local sparkles = {}
	local sparkles_strip = {}

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
		for r = 1,4 do
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

			for c = 1,4 do
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
					sparkles[r][c][i].clip = {0,0,sparkles_strip[r][c][i].w/5,sparkles_strip[r][c][i].h}
					sparkles[r][c][i]:add(sparkles_strip[r][c][i])
                
					local x_dir = math.random(85,115)/100
					x_start[r][c][i] = math.random(-2,2)+x[c]
					sparkles[r][c][i].x = x_start[r][c][i]
					y_start[r][c][i] = math.random(-2,2)+y[r]
					sparkles[r][c][i].y = y_start[r][c][i]
					x_peak[r][c][i]  = x_start[r][c][i]*x_dir
					y_peak[r][c][i]  = y_start[r][c][i]-80+math.random(-10,10)
					x_end[r][c][i]   = x_peak[r][c][i]*x_dir
					y_end[r][c][i]   = y_peak[r][c][i]+90+math.random(-10,10)
                
					--scale[i] = math.random(8,9)/10
					--sparkles[i].scale={scale[i],scale[i]}
                
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
	--end
	
		function timeline.on_new_frame(t,msecs,p)
			--local sparkle_stage = math.ceil(p*5)
			--sparkle_base.x = -1*(stage-1)*sparkle_base.w/5
			--sparkle.z_rotation = {360*p,sparkle_base.w/(5*2),sparkle_base.h/2}
			local prog
			local stage
			for r = 1,4 do
			for c = 1,4 do
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
					sparkles_strip[r][c][i].x =  -1*(stage-1)*sparkles_strip[r][c][i].w/5
					end
				end
			end
		end
	end
	function timeline.on_completed()
		for r = 1,4 do
		for c = 1,4 do

		for i=1,num_sparkles do
			sparkles[r][c][i]:clear()
			sparkles[r][c][i]:unparent()
			sparkles[r][c][i] = nil
end
end
		end
	end
	timeline:start()
end
local help = Group{z=3,opacity=0}
screen:add(help)
help:add(
	Rectangle{
		color="000000",
		w=1000,
		h=800,
	--	x=screen.w/2,
	--	y=screen.h/2,
		opacity=220
	},
	Text{
		text = "The Rules of Sudoku:\n\n"..
			"- All the numbers in any row must be unique\n"..
			"- All the numbers in any column must be unique\n"..
			"- All the numbers in any designate 3x3 must be unique\n\n"..
			"The numbers 1-9 will be placed exactly once in each of\n"..
			"those categories.\n\n"..
			"Gameplay:\n\n"..
			" ARROWS  - Move the cursor around to select tiles\n"..
			" NUMBERS - Allow you to make a guess on a tile\n"..
			" ENTER   - Opens the pencil menu to guess multiple"..
				" numbers\n\n"..
			"Good Luck!\nPress any button to go back",
		font = "DejaVu 45px",
		color = "FFFFFF",
		x = 50, y = 50
	}
)
help.anchor_point = {   help.w/2,   help.h/2 }
help.position     = { screen.w/2, screen.h/2 }

local side_font = "Dejavu Bold 60px"
right_menu = Group{z=1}
local right_list = {
	FocusableImage({0,0},"Cheat", 
		red_button_off,red_button_on,function() end),

	FocusableImage({0,blank_button_off.h+8},"Undo Move", 
		green_button_off,green_button_on,
		function() 
			game:undo() 
		end),

	FocusableImage({0,2*(blank_button_off.h+8)},"Show Errors", 
		yellow_button_off,yellow_button_on, 
		function() 
			game:error_check() 
		end),

	FocusableImage({0,3*(blank_button_off.h+8)},"Restart Puzzle", 
		blue_button_off, blue_button_on, 
		function() 
			game:restart() 
		end)
}
right_menu:add( right_list[1].group,right_list[2].group,right_list[3].group,right_list[4].group )
right_menu.anchor_point = {right_menu.w/2,0}
--right_menu.y_rotation ={-25,right_menu.w/2,0}
right_menu.position = {screen.w - right_menu.w/2+80,red.h   + 90}
local left_menu = Group{z=1}
local left_list = {
	FocusableImage({0,0},"New Puzzle", 
		blank_button_off,blank_button_on,
		function() 
---[[
			--game.board:clear()
			
			--game = Game(BoardGen(num_givens))
			--ind = {r=1,c=1}
--]]
			flip_board()

--[[
			splash.opacity = 255
			focus = "SPLASH"
			left_list[left_index].color = "FFFFFF"
			left_index = 1
--]]
		end),

	FocusableImage({0,blank_button_off.h+8},"Help", 
		blank_button_off,blank_button_on,
		function() 
			help.opacity = 255
			help:raise_to_top()
			focus = "HELP"
		end),
	FocusableImage({0,2*(blank_button_off.h+8)},"Settings", 
		blank_button_off,blank_button_on,
		function() 

		end),


	FocusableImage({0,3*(blank_button_off.h+8)},"Save & Exit", 
		blank_button_off,blank_button_on,
		function() 
			game:save()
			exit()
		end)
}
left_menu:add( left_list[1].group,left_list[2].group,left_list[3].group,left_list[4].group )
left_menu.anchor_point = {left_menu.w/2,0}
left_menu.position = {left_menu.w/2+260,red.h   + 90}


local left_index = 1
local right_index = 1


local red_is_on = true
local red_board = Group{}
local red_blox = 
{
	{
		Group{},
		Group{x= red.w   + 30},
		Group{x= red.w*2 + 30*2}
	},
	{
		Group{                   y= red.h   + 30},
		Group{x= red.w   + 30,   y= red.h   + 30},
		Group{x= red.w*2 + 30*2, y= red.h   + 30}
	},
	{
		Group{                   y= red.h*2 + 30*2},
		Group{x= red.w   + 30,   y= red.h*2 + 30*2},
		Group{x= red.w*2 + 30*2, y= red.h*2 + 30*2}
	}
}
for i = 1,#red_blox do    for j=1,#red_blox[i] do

		red_blox[i][j]:add(Clone{source=red})

end                        end

local blue_board = Group{}
local blue_blox = 
{
	{
		Group{opacity = 0},
		Group{opacity = 0, x= blue.w   + 30},
		Group{opacity = 0, x= blue.w*2 + 30*2}
	},
	{
		Group{opacity = 0,                     y= blue.h   + 30},
		Group{opacity = 0, x= blue.w   + 30,   y= blue.h   + 30},
		Group{opacity = 0, x= blue.w*2 + 30*2, y= blue.h   + 30}
	},
	{
		Group{opacity = 0,                     y= blue.h*2 + 30*2},
		Group{opacity = 0, x= blue.w   + 30,   y= blue.h*2 + 30*2},
		Group{opacity = 0, x= blue.w*2 + 30*2, y= blue.h*2 + 30*2}
	}
}
for i = 1,#blue_blox do    for j=1,#blue_blox[i] do

		blue_blox[i][j]:add(Clone{source=blue})

end                        end

local bg_red  = Image{src="assets/bg_red.jpg"}
local bg_blue = Image{src="assets/bg_blue.jpg",opacity=0}
screen:add(bg_red,bg_blue,red_board,blue_board, Image{src="assets/logo.png",x=40,y=40})
for i=1,3 do
	blue_board:add( unpack(blue_blox[i]) )
	red_board:add(  unpack( red_blox[i]) )
end
red_board.anchor_point  = {  red_board.w/2,  red_board.h/2 }
red_board.position      = {     screen.w/2,     screen.h/2 }
blue_board.anchor_point = { blue_board.w/2, blue_board.h/2 }
blue_board.position     = {     screen.w/2,     screen.h/2 }

function flip_board()
	local timeline = Timeline
	{
		duration  =  200*(3+3),
		loop      =  false,
		direction = "FORWARD"
	}
	local stopwatch = Stopwatch()
	local old_board, new_board, old_bg, new_bg
	
	--function timeline.on_started()
		if red_is_on then
			old_board =  red_blox
			new_board = blue_blox
			old_bg    =    bg_red
			new_bg    =   bg_blue
		else
			old_board = blue_blox
			new_board =  red_blox
			old_bg    =   bg_blue
			new_bg    =    bg_red
		end
		for r = 1,3 do for c = 1,3 do
			new_board[r][c].y_rotation = {-180,new_board[r][c].w/2,0}
		end            end

	--end
	function timeline.on_new_frame(t,msecs,prog)
if stopwatch then
	print(stopwatch.elapsed)
	stopwatch = nil
end
		old_bg.opacity = 255 * (1-prog)
		new_bg.opacity = 255 *    prog
		local stage_i = math.ceil(msecs / 200) --stages 1-15
				
		local p = (msecs - (stage_i-1)*200) / 200  --progress w/in a stage
		local degrees_old, degrees_new
		for r = 1,3 do   for c = 1,3 do

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

			old_board[r][c].y_rotation = { degrees_old, 
				old_board[r][c].w/2, 0 }
			new_board[r][c].y_rotation = { degrees_new, 
				new_board[r][c].w/2, 0 }

			if degrees_old <  135 and degrees_old >  45 then
				old_board[r][c].opacity = 255 * (1- (degrees_old - 45)/90)
			elseif degrees_old > 135 then
				old_board[r][c].opacity = 0
			end
			if degrees_new > -135 and degrees_new < -45 then
				new_board[r][c].opacity = 255* (degrees_new - 45)/90
			elseif degrees_new > -45 then
				new_board[r][c].opacity = 255
			end

		end		end

	end
	function timeline.on_completed()
		for r = 1,3 do   for c = 1,3 do

			old_board[r][c].y_rotation = { 180, old_board[r][c].w/2, 0 }
			new_board[r][c].y_rotation = {   0, new_board[r][c].w/2, 0 }
			old_board[r][c].opacity =   0
			new_board[r][c].opacity = 255

		end              end

		if red_is_on then red_is_on = false else red_is_on = true end
		old_bg.opacity =   0
		new_bg.opacity = 255
	end
	timeline:start()
end

local num_font = "DejaVu Bold Condensed 30px"
local pencil_menu = Group{y=40,opacity=0,z=1}
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
	Image{name="clear_on",  src="assets/button_on.png",y=60,x=100},
	Image{name="clear_off", src="assets/button_off.png",y=60,x=100},
	Text{ name="clear",     text="Clear",font="DejaVu 40px",color="FFFFFF",y=67,x=115},
	Image{name="done_on",   src="assets/button_on.png",y=60,x=210},
	Image{name="done_off",  src="assets/button_off.png",y=60,x=210},
	Text{ name="done",      text="Done",font="DejaVu 40px",color="FFFFFF",y=67,x=225}
)
--[[
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
local selector = Image{src="assets/board-focus.png"}
selector.anchor_point = {selector.w/2,selector.h/2}
screen:add(
	--Image{src="assets/background.jpg"}, 
	--Image{src="assets/board.png"},
	selector,
	pencil_menu
)




local splash     = Group{z=2}
local splash_list = 
{
	FocusableImage({screen.w/2+800,screen.h/2+800},"Continue Game", 
		blank_button_off,blank_button_on,
		function() 
			splash.opacity = 0			

			focus = "GAME_BOARD"
			selector.opacity = 255

		end),
	FocusableImage({screen.w/2+1800,screen.h/2+800},"New Medium Game", 
		blank_button_off,blank_button_on,
		function() 
			splash.opacity = 0			
			if settings.givens and settings.guesses then
				for r = 1,9 do     for c = 1,9 do
					--game.grid_of_groups[r][c]:clear()
					--game.grid_of_groups[r][c]:unparent()
					--game.grid_of_groups[r][c] = nil

				end                end

			end
			if red_is_on then
				game = Game(BoardGen(num_givens),nil,blue_blox)
			else
				game = Game(BoardGen(num_givens),nil,red_blox)
			end
			collectgarbage("collect")
			ind = {r=1,c=1}
			focus = "GAME_BOARD"
			selector.opacity = 255
			flip_board()
		end)

	
}
splash:add(
	Image{src="assets/splash-menu.png",x = screen.w/2,y = screen.h/2-100},
	splash_list[1].group,
	splash_list[2].group
)
--[[
splash:add(
	Rectangle{
		color="000000",
		w=1000,
		h=500,
		x=screen.w/2,
		y=screen.h/2,
		opacity=180
	},
	Text{
		name  = "title_s",
		text  = "Sudoku",
		font  = "DejaVu Bold 100px",
		color = "000000",
		x     = screen.w/2 + 3,
		y     = screen.h/2 - 200 +3
	},
	Text{
		name  = "title",
		text  = "Sudoku",
		font  = "DejaVu Bold 100px",
		color = "FFFFFF",
		x     = screen.w/2,
		y     = screen.h/2 - 200
	},
	Text{
		name  = "new_s",
		text  = "New Game\n# Givens:",
		font  = "DejaVu Bold 100px",
		color = "000000",
		x     = screen.w/2+250+3,
		y     = screen.h/2+3
	},
	Text{
		name  = "new",
		text  = "New Game\n # Givens:",
		font  = "DejaVu Bold 100px",
		color = "FFFFFF",
		x     = screen.w/2+250,
		y     = screen.h/2
	},
	Text{
		name  = "cont_s",
		text  = "Continue\n Old Game",
		font  = "DejaVu Bold 100px",
		color = "000000",
		x     = screen.w/2-250+3,
		y     = screen.h/2+3
	},

	Text{
		name  = "cont",
		text  = "Continue\n Old Game",
		font  = "DejaVu Bold 100px",
		color = "FFFFFF",
		x     = screen.w/2-250,
		y     = screen.h/2
	},
	Text{
		name  = "givens_s",
		text  = num_givens,
		font  = "DejaVu Bold 100px",
		color = "000000",
		x     = screen.w/2+250+3,
		y     = screen.h/2+180+3
	},

	Text{
		name  = "givens",
		text  = num_givens,
		font  = "DejaVu Bold 100px",
		color = "FFFFFF",
		x     = screen.w/2+250,
		y     = screen.h/2+180
	}
)
--]]
splash:foreach_child( function(child)
	if child.group ~= nil then
		child.group.anchor_point = {child.w/2,child.h/2}
	else
		child.anchor_point = {child.w/2,child.h/2}
	end
end)

screen:add(splash)
Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}
local pencil_menu_index = 2
focus = "SPLASH"
local game_on = false
game = nil
local ind = {r=1,c=1}
local mode = {"TRAVERSAL","CLEAR","PEN","PENCIL","BACK"}
local curr_mode = "TRAVERSAL"
function num_press(n)
	if menu_open then
		game:toggle_guess(ind.r,ind.c,n,"REG")
--[[
		if 	pencil_menu:find_child(n).color == "202020" then
			pencil_menu:find_child(n).color = "FFFFFF"
		else
			pencil_menu:find_child(n).color = "202020"
		end
--]]
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
		end,
		[keys.Up] = function()
			if not menu_open and ind.r > 1 then
				ind.r=ind.r-1
				selector.x,selector.y = sel_pos(ind.r,ind.c)
			end
		end,
		[keys.Right] = function()
			if menu_open then
				pencil_menu_index = 2

				pencil_menu:find_child("clear_on").opacity = 0
				pencil_menu:find_child("clear_off").opacity = 255
				pencil_menu:find_child("clear").color = "FFFFFF"

				pencil_menu:find_child("done_on").opacity = 255
				pencil_menu:find_child("done_off").opacity = 0
				pencil_menu:find_child("done").color = "202020"

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
		end,
		[keys.Left] = function()
			if menu_open then
				pencil_menu_index = 1

				pencil_menu:find_child("clear_on").opacity = 255
				pencil_menu:find_child("clear_off").opacity = 0
				pencil_menu:find_child("clear").color = "202020"

				pencil_menu:find_child("done_on").opacity = 0
				pencil_menu:find_child("done_off").opacity = 255
				pencil_menu:find_child("done").color = "FFFFFF"

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
		end,
		[keys.Return] = function()
			if menu_open then
				if pencil_menu_index == 1 then
					game:clear_tile(ind.r,ind.c)

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
					pencil_menu.x = selector.x - 160
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
					pencil_menu.x = selector.x - 160
					pencil_menu.y = selector.y + selector.h/2-20

					pencil_menu:find_child("clear_on").opacity = 0
					pencil_menu:find_child("clear_off").opacity = 255
					pencil_menu:find_child("clear").color = "FFFFFF"

					pencil_menu:find_child("done_on").opacity = 255
					pencil_menu:find_child("done_off").opacity = 0
					pencil_menu:find_child("done").color = "202020"

				end	
			end
		end,
		[keys["1"] ] = function()
			num_press(1)
		end,
		[keys["2"] ] = function()
			num_press(2)
		end,
		[keys["3"] ] = function()
			num_press(3)
		end,
		[keys["4"] ] = function()
			num_press(4)
		end,
		[keys["5"] ] = function()
			num_press(5)
		end,
		[keys["6"] ] = function()
			num_press(6)
		end,
		[keys["7"] ] = function()
			num_press(7)
		end,
		[keys["8"] ] = function()
			num_press(8)
		end,
		[keys["9"] ] = function()
			num_press(9)
		end,


		[keys["KP_End"] ] = function()
			num_press(1)
		end,
		[keys["KP_Down"] ] = function()
			num_press(2)
		end,
		[keys["KP_Page_Down"] ] = function()
			num_press(3)
		end,
		[keys["KP_Left"] ] = function()
			num_press(4)
		end,
		[keys["KP_Begin"] ] = function()
			num_press(5)
		end,
		[keys["KP_Right"] ] = function()
			num_press(6)
		end,
		[keys["KP_Home"] ] = function()
			num_press(7)
		end,
		[keys["KP_Up"] ] = function()
			num_press(8)
		end,
		[keys["KP_Page_Up"] ] = function()
			num_press(9)
		end,
--[[
		[keys["u"] ] = function()
			game:undo(ind.r,ind.c)
		end,
		[keys["r"] ] = function()
			game:redo(ind.r,ind.c)
		end,
		[keys["m"] ] = function()
			splash.opacity = 255
			game_on = false
		end,
		[keys["c"] ] = function()
			game:clear_tile(ind.r,ind.c)
		end,
		[keys["e"] ] = function()
			game:error_check()
		end,
--]]
	}
	if key[k] then key[k]() end
end
local splash_hor_index = 2
if settings.givens and settings.guesses then

	if red_is_on then
		game = Game(settings.givens,settings.guesses,red_blox)
	else
		game = Game(settings.givens,settings.guesses,blue_blox)
	end
	screen:add(game.board)
	splash_hor_index = 1
	splash_list[1]:on_focus()
--[[
	splash:find_child("cont").color    = "FF0000"
	splash:find_child("new").color   = "FFFFFF"
--]]
else
	game = nil
	splash_list[2]:out_focus()
--[[
	splash:find_child("cont").color    = "FFFFFF"
	splash:find_child("new").color   = "FF0000"
--]]
end
local game_num = {55,45,30}
local game_opts = {"Easy","Medium","Hard"}
local curr_opt = 2
function splash_on_key_down(k)
	local key = 
	{
		[ keys.Return ] = function()
--[[
			splash.opacity = 0			

			if splash_hor_index == 2 then
				if settings.givens and settings.guesses then
					game.board:clear()
				end
				game = Game(BoardGen(num_givens))
				ind = {r=1,c=1}
		
			end
			--game_on = true
			focus = "GAME_BOARD"
			selector.opacity = 255
			--clock:start()
			--game:on_focus(1,1)
--]]
			splash_list[splash_hor_index]:press_enter()
		end,
		[keys.Down] = function()
			if num_givens > 25 and splash_hor_index == 2 and curr_opt < 3 then
				--num_givens = num_givens - 1
				curr_opt = curr_opt + 1
				num_givens = game_num[curr_opt]

--[[
				splash:find_child("givens").text = num_givens
				splash:find_child("givens_s").text = num_givens
--]]
				local t = splash_list[2].group:find_child("text")
				t.text = "New "..game_opts[curr_opt].." Game"
				t.anchor_point = {t.w/2,t.h/2}
				t = splash_list[2].group:find_child("text_s")
				t.text = "New "..game_opts[curr_opt].." Game"
				t.anchor_point = {t.w/2,t.h/2}
				
			end
		end,
		[keys.Up] = function()
			if num_givens < 60 and splash_hor_index == 2 and curr_opt > 1 then
				--num_givens = num_givens + 1
				curr_opt = curr_opt - 1
				num_givens = game_num[curr_opt]
--[[
				splash:find_child("givens").text = num_givens
				splash:find_child("givens_s").text = num_givens
--]]
				local t = splash_list[2].group:find_child("text")
				t.text = "New "..game_opts[curr_opt].." Game"
				t.anchor_point = {t.w/2,t.h/2}
				t = splash_list[2].group:find_child("text_s")
				t.text = "New "..game_opts[curr_opt].." Game"
				t.anchor_point = {t.w/2,t.h/2}

			end

		end,
		[keys.Right] = function()
			splash_hor_index = 2
			splash_list[2]:on_focus()
			splash_list[1]:out_focus()
--[[
			splash:find_child("new").color    = "FF0000"
			splash:find_child("cont").color   = "FFFFFF"
--]]
		end,
		[keys.Left] = function()

			if settings.givens and settings.guesses then
				splash_hor_index = 1
			splash_list[1]:on_focus()
			splash_list[2]:out_focus()
--[[
				splash:find_child("new").color    = "FFFFFF"
				splash:find_child("cont").color   = "FF0000"
--]]
			end
		end,

	}
	if key[k] then key[k]() end	
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
		end,
		[keys.Down] = function()
			if left_index < #left_list then
				left_list[left_index]:out_focus()
				left_index = left_index + 1
				left_list[left_index]:on_focus()
			end
		end,
		[keys.Right] = function()
			left_list[left_index]:out_focus()
			left_index = 1
			focus = "GAME_BOARD"
			selector.opacity = 255

		end,
		[keys.Return] = function()
			left_list[left_index]:press_enter()
		end,
	}
	if key[k] then key[k]() end
end

function right_menu_on_key_down(k)
	local key = 
	{
		[keys.Up] = function()
			if right_index > 1 then
				right_list[right_index]:out_focus()
				right_index = right_index - 1
				right_list[right_index]:on_focus()

			end
		end,
		[keys.Down] = function()
			if right_index < #right_list then
				right_list[right_index]:out_focus()
				right_index = right_index + 1
				right_list[right_index]:on_focus()

			end
		end,
		[keys.Left] = function()
			right_list[right_index]:out_focus()
			right_index = 1
			focus = "GAME_BOARD"
			selector.opacity = 255

		end,
		[keys.Return] = function()
			right_list[right_index]:press_enter()
		end,
	}
	if key[k] then key[k]() end
end
function screen:on_key_down(k)
	local sub_on_key_down = 
	{
		["SPLASH"] = function(key_press)
			splash_on_key_down(key_press)
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
			help.opacity = 0
			focus = "GAME_LEFT"
		end,	
	}
	if k == keys.s then
		start_sparkle({200,300,400,500,600,700,800,900,1000},
{200,300,400,500,600,700,800,900,1000},12)
		return
	end
	if sub_on_key_down[focus] then
		sub_on_key_down[focus](k)
	else
		error(focus.." does not have an on_key_down")
	end
--[[
	if game_on then
		game_on_key_down(k)
	else
		splash_on_key_down(k)
	end
--]]
end
function player_won()
		splash.opacity = 255
		focus = "SPLASH"
		selector.opacity = 0
end
function app:on_closing()
	game:save()
end
screen:add(right_menu,left_menu)

selector.x,selector.y = sel_pos(1,1)
--game:on_focus(1,1)
screen:show()
