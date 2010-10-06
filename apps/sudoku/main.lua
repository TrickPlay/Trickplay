math.randomseed(os.time())
--local bg = Image{src="assets/background.jpg"}
local blank_button_on   = Image{src="assets/blank_on",  opacity=0}
local blank_button_off  = Image{src="assets/blank_off", opacity=0}
local green_button_on   = Image{src="assets/green_on",  opacity=0}
local green_button_off  = Image{src="assets/green_off", opacity=0}
local red_button_on     = Image{src="assets/red_on",    opacity=0}
local red_button_off    = Image{src="assets/red_off",   opacity=0}
local blue_button_on    = Image{src="assets/blue_on",   opacity=0}
local blue_button_off   = Image{src="assets/blue_off",  opacity=0}
local yellow_button_on  = Image{src="assets/yellow_on", opacity=0}
local yellow_button_off = Image{src="assets/yellow_off",opacity=0}
local blue = Image{src = "assets/3x3grid-blue.png",opacity=0}
local red  = Image{src =  "assets/3x3grid-red.png",opacity=0}
screen:add(
	 blank_button_on,  blank_button_off, green_button_on, green_button_off,
	   red_button_on,    red_button_off,  blue_button_on,  blue_button_off,
	yellow_button_on, yellow_button_off, red,blue
)


local red_board = Group{}
local red_blox = 
{
	{
		Clone{source=red},
		Clone{source=red, x= red.w   + 30},
		Clone{source=red, x= red.w*2 + 30*2}
	},
	{
		Clone{source=red,                    y= red.h   + 30},
		Clone{source=red, x= red.w   + 30,   y= red.h   + 30},
		Clone{source=red, x= red.w*2 + 30*2, y= red.h   + 30}
	},
	{
		Clone{source=red,                    y= red.h*2 + 30*2},
		Clone{source=red, x= red.w   + 30,   y= red.h*2 + 30*2},
		Clone{source=red, x= red.w*2 + 30*2, y= red.h*2 + 30*2}
	}
}
local blue_board = Group{opacity=0}
local blue_blox = 
{
	{
		Clone{source=blue},
		Clone{source=blue, x= blue.w   + 30},
		Clone{source=blue, x= blue.w*2 + 30*2}
	},
	{
		Clone{source=blue,                     y= blue.h   + 30},
		Clone{source=blue, x= blue.w   + 30,   y= blue.h   + 30},
		Clone{source=blue, x= blue.w*2 + 30*2, y= blue.h   + 30}
	},
	{
		Clone{source=blue,                     y= blue.h*2 + 30*2},
		Clone{source=blue, x= blue.w   + 30,   y= blue.h*2 + 30*2},
		Clone{source=blue, x= blue.w*2 + 30*2, y= blue.h*2 + 30*2}
	}
}
screen:add(Image{src="assets/background.jpg"},red_board,blue_board)
for i=1,3 do
	blue_board:add( unpack(blue_blox[i]) )
	red_board:add(  unpack( red_blox[i]) )
end
red_board.anchor_point  = {  red_board.w/2,  red_board.h/2 }
red_board.position      = {     screen.w/2,     screen.h/2 }
blue_board.anchor_point = { blue_board.w/2, blue_board.h/2 }
blue_board.position     = {     screen.w/2,     screen.h/2 }

local num_font = "DejaVu Bold Condensed 30px"
local pencil_menu = Group{y=40,opacity=0,z=1}
function p_x(i) return 20*i+80 end
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
	Image{name="clear_on",  src="assets/button_on.png",y=70,x=100},
	Image{name="clear_off", src="assets/button_off.png",y=70,x=100},
	Text{ name="clear",     text="Clear",font="DejaVu 40px",color="FFFFFF",y=70,x=112},
	Image{name="done_on",   src="assets/button_on.png",y=70,x=210},
	Image{name="done_off",  src="assets/button_off.png",y=70,x=210},
	Text{ name="done",      text="Done",font="DejaVu 40px",color="FFFFFF",y=70,x=222}
)
local side_font = "Dejavu Bold 60px"
local right_menu = Group{z=1}
local right_list = {
	Text{text="Undo",          font=side_font,color="FFFFFF",x=1500,y=400},
	Text{text="Mark Errors",   font=side_font,color="FFFFFF",x=1500,y=500},
	Text{text="Restart Puzzle",font=side_font,color="FFFFFF",x=1500,y=600},
}
right_menu:add( unpack(right_list) )
screen:add(right_menu)
local left_menu = Group{z=1}
local left_list = {
--	Text{text="Pause",      font=side_font,color="FFFFFF",x=100,y=300},
	Text{text="Help",       font=side_font,color="FFFFFF",x=100,y=400},
	Text{text="New Puzzle", font=side_font,color="FFFFFF",x=100,y=500},
	Text{text="Save & Exit",font=side_font,color="FFFFFF",x=100,y=600},
}
right_menu:add( unpack(left_list) )
screen:add(left_menu)

local left_index = 1
local right_index = 1
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

local num_givens = 50
local splash     = Group{z=2}
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
splash:foreach_child( function(child)
	child.anchor_point = {child.w/2,child.h/2}
end)
screen:add(splash)
Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}

dofile("Class.lua") -- Must be declared before any class definitions.

dofile("Game.lua")
local pencil_menu_index = 2
local focus = "SPLASH"
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
					right_list[right_index].color = "FF0000"
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
					left_list[left_index].color = "FF0000"
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
					pencil_menu.x = selector.x - 115
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
					pencil_menu.x = selector.x - 115
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
	game = Game(settings.givens,settings.guesses)
	screen:add(game.board)
	splash_hor_index = 1
	splash:find_child("cont").color    = "FF0000"
	splash:find_child("new").color   = "FFFFFF"

else
	game = nil
	splash:find_child("cont").color    = "FFFFFF"
	splash:find_child("new").color   = "FF0000"

end
function splash_on_key_down(k)
	local key = 
	{
		[ keys.Return ] = function()
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
		end,
		[keys.Down] = function()
			if num_givens > 25 and splash_hor_index == 2 then
				num_givens = num_givens - 1
				splash:find_child("givens").text = num_givens
				splash:find_child("givens_s").text = num_givens
			end
		end,
		[keys.Up] = function()
			if num_givens < 60 and splash_hor_index == 2 then
				num_givens = num_givens + 1
				splash:find_child("givens").text = num_givens
				splash:find_child("givens_s").text = num_givens
			end

		end,
		[keys.Right] = function()
			splash_hor_index = 2
			splash:find_child("new").color    = "FF0000"
			splash:find_child("cont").color   = "FFFFFF"

		end,
		[keys.Left] = function()

			if settings.givens and settings.guesses then
				splash_hor_index = 1
				splash:find_child("new").color    = "FFFFFF"
				splash:find_child("cont").color   = "FF0000"
			end
		end,

	}
	if key[k] then key[k]() end	
end
local left_nav_callbacks = 
{
--[[
	--Play/Pause
	function()
		if left_list[1].text == "Pause" then
			left_list[1].text = "Play"
			clock:stop()
		else
			left_list[1].text = "Pause"
			clock:start()
		end
	end,
--]]
	--Help
	function()
		help.opacity = 255
		help:raise_to_top()
		focus = "HELP"
	end,
	--New Puzzle
	function()
		splash.opacity = 255
		focus = "SPLASH"
		left_list[left_index].color = "FFFFFF"
		left_index = 1
	end,
	--Save & Exit
	function()
		game:save()
		exit()
	end,
}
function left_menu_on_key_down(k)
	local key = 
	{
		[keys.Up] = function()
			if left_index > 1 then
				left_list[left_index].color = "FFFFFF"
				left_index = left_index - 1
				left_list[left_index].color = "FF0000"
			end
		end,
		[keys.Down] = function()
			if left_index < #left_nav_callbacks then
				left_list[left_index].color = "FFFFFF"
				left_index = left_index + 1
				left_list[left_index].color = "FF0000"
			end
		end,
		[keys.Right] = function()
			left_list[left_index].color = "FFFFFF"
			left_index = 1
			focus = "GAME_BOARD"
			selector.opacity = 255

		end,
		[keys.Return] = function()
			left_nav_callbacks[left_index]()
		end,
	}
	if key[k] then key[k]() end
end
local right_nav_callbacks = 
{
	--Undo
	function()
		game:undo(ind.r,ind.c)
	end,
	--Mark Errors
	function()
		game:error_check()
	end,
	--Restart Puzzle
	function()
		game:restart()
	end,
}

function right_menu_on_key_down(k)
	local key = 
	{
		[keys.Up] = function()
			if right_index > 1 then
				right_list[right_index].color = "FFFFFF"
				right_index = right_index - 1
				right_list[right_index].color = "FF0000"

			end
		end,
		[keys.Down] = function()
			if right_index < #right_nav_callbacks then
				right_list[right_index].color = "FFFFFF"
				right_index = right_index + 1
				right_list[right_index].color = "FF0000"

			end
		end,
		[keys.Left] = function()
			right_list[right_index].color = "FFFFFF"
			right_index = 1
			focus = "GAME_BOARD"
			selector.opacity = 255

		end,
		[keys.Return] = function()
			right_nav_callbacks[right_index]()
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
selector.x,selector.y = sel_pos(1,1)
--game:on_focus(1,1)
screen:show()
