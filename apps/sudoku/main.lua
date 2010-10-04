math.randomseed(os.time())
--local bg = Image{src="assets/background.jpg"}
local num_font = "DejaVu Bold Condensed 30px"
local pencil_menu = Group{y=40,opacity=0,z=1}
function p_x(i) return 20*i+80 end
pencil_menu:add(
	Image{name="bg_up",src="assets/pencil-menu-up.png"},
	Image{name="bg_dn",src="assets/pencil-menu-down.png",y=15},
	Text{name="1",text="1",font=num_font,color="FFFFFF",x=20*1+80,y=25},
	Text{name="2",text="2",font=num_font,color="FFFFFF",x=20*2+80,y=25},
	Text{name="3",text="3",font=num_font,color="FFFFFF",x=20*3+80,y=25},
	Text{name="4",text="4",font=num_font,color="FFFFFF",x=20*4+80,y=25},
	Text{name="5",text="5",font=num_font,color="FFFFFF",x=20*5+80,y=25},
	Text{name="6",text="6",font=num_font,color="FFFFFF",x=20*6+80,y=25},
	Text{name="7",text="7",font=num_font,color="FFFFFF",x=20*7+80,y=25},
	Text{name="8",text="8",font=num_font,color="FFFFFF",x=20*8+80,y=25},
	Text{name="9",text="9",font=num_font,color="FFFFFF",x=20*9+80,y=25},
	Image{name="clear_on",src="assets/button_on.png",y=70,x=100},
	Image{name="clear_off",src="assets/button_off.png",y=70,x=100},
	Text{name="clear",text="Clear",font="DejaVu 40px",color="FFFFFF",y=70,x=112},
	Image{name="done_on",src="assets/button_on.png",y=70,x=210},
	Image{name="done_off",src="assets/button_off.png",y=70,x=210},
	Text{name="done",text="Done",font="DejaVu 40px",color="FFFFFF",y=70,x=222}
)

local selector = Image{src="assets/board-focus.png"}
selector.anchor_point = {selector.w/2,selector.h/2}
screen:add(
	Image{src="assets/background.jpg"}, 
	Image{src="assets/board.png"},
	selector,
	pencil_menu
)--bg)

screen:add(
	Text{
		text = "M - Main Menu\n\nU - Undo\nR - Redo\n"..
		        "C - Clear Tile\nE - Error \n     Checking",
		font = "DejaVu Bold 60px",
		color = "FFFFFF",
		x = 1600,
		y = 200
	}
)
local num_givens = 50
local splash     = Group{z=2}
splash:add(
	Rectangle{color="000000",w=1000,h=500,x=screen.w/2,y=screen.h/2,opacity=180},
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
--[[
dofile("MVC.lua")
dofile("FocusableImage.lua")

dofile("views/SplashView.lua")
dofile("controllers/SplashController.lua")

dofile("views/CurrentGameView.lua")
dofile("controllers/CurrentGameController.lua")

Components = {
   COMPONENTS_FIRST = 1,
   SPLASH           = 1,
   CURRENT_GAME     = 2,
   COMPONENTS_LAST  = 2
}
model = Model()


local front_page_view = FrontPageView(model)
front_page_view:initialize()

local slide_show_view = SlideshowView(model)
slide_show_view:initialize()

local source_manager_view = SourceManagerView(model)
source_manager_view:initialize()

--cache all of the current searches
function app:on_closing()
	settings.game = current_game
end

--delegates the key press to the appropriate on_key_down() 
--function in the active component
function screen:on_key_down(k)
    screen.on_key_down = function() end
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

--stores the function pointer
model.keep_keys = screen.on_key_down

function reset_keys()
    print("reseting keys",model.keep_keys)
    screen.on_key_down = model.keep_keys
end
model:start_app(Components.SPLASH)
--]]
local pencil_menu_index = 2
local game_on = false
game = nil
local ind = {r=1,c=1}
local mode = {"TRAVERSAL","CLEAR","PEN","PENCIL","BACK"}
local curr_mode = "TRAVERSAL"
function num_press(n)
	if menu_open then
		game:toggle_guess(ind.r,ind.c,n,"REG")
		if 	pencil_menu:find_child(n).color == "202020" then
			pencil_menu:find_child(n).color = "FFFFFF"
		else
			pencil_menu:find_child(n).color = "202020"
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
				
--[[
				game:out_focus(ind.r,ind.c)
				game:on_focus(ind.r,ind.c)
--]]
			end
		end,
		[keys.Up] = function()
			if not menu_open and ind.r > 1 then
				--game:out_focus(ind.r,ind.c)
				ind.r=ind.r-1
selector.x,selector.y = sel_pos(ind.r,ind.c)

				--game:on_focus(ind.r,ind.c)

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
					--game:out_focus(ind.r,ind.c)
					ind.c=ind.c+1
					selector.x,selector.y = sel_pos(ind.r,ind.c)

					--game:on_focus(ind.r,ind.c)
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
					--game:out_focus(ind.r,ind.c)
					ind.c=ind.c-1
					selector.x,selector.y = sel_pos(ind.r,ind.c)
	
				--	game:on_focus(ind.r,ind.c)
				end
			end
		end,
---[[
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
					pencil_menu.y = selector.y - selector.h/2 - pencil_menu.h +20

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
--]]
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
		[ keys["Return"] ] = function()
			splash.opacity = 0			

			if splash_hor_index == 2 then
				if settings.givens and settings.guesses then
					game.board:clear()
				end
				game = Game(BoardGen(num_givens))
				ind = {r=1,c=1}
		
			end
			game_on = true
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
function screen:on_key_down(k)
	if game_on then
		game_on_key_down(k)
	else
		splash_on_key_down(k)
	end
end
function app:on_closing()
	game:save()
end
selector.x,selector.y = sel_pos(1,1)
--game:on_focus(1,1)
screen:show()
