math.randomseed(os.time())
local bg = Image{src="assets/bg.jpg"}
screen:add(bg)
screen:add(
	Text{
		text = "N - New Game\n\nU - Undo\nR - Redo\n"..
		        "C - Clear Tile\nE - Error \n     Checking",
		font = "DejaVu Bold 60px",
		color = "FFFFFF",
		x = 1600,
		y = 200
	}
)
local num_givens = 50
local splash     = Group{}
splash:add(
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
		text  = "New Game\nNumber of Givens",
		font  = "DejaVu Bold 100px",
		color = "000000",
		x     = screen.w/2+150+3,
		y     = screen.h/2+3
	},
	Text{
		name  = "new",
		text  = "New Game\nNumber of Givens",
		font  = "DejaVu Bold 100px",
		color = "FFFFFF",
		x     = screen.w/2+150,
		y     = screen.h/2
	},
	Text{
		name  = "cont_s",
		text  = "Continue Old Game",
		font  = "DejaVu Bold 100px",
		color = "000000",
		x     = screen.w/2-150+3,
		y     = screen.h/2+3
	},

	Text{
		name  = "cont",
		text  = "Continue Old Game",
		font  = "DejaVu Bold 100px",
		color = "FFFFFF",
		x     = screen.w/2-150,
		y     = screen.h/2
	},
	Text{
		name  = "givens_s",
		text  = num_givens,
		font  = "DejaVu Bold 100px",
		color = "000000",
		x     = screen.w/2+250+3,
		y     = screen.h/2+3
	},

	Text{
		name  = "givens",
		text  = num_givens,
		font  = "DejaVu Bold 100px",
		color = "FFFFFF",
		x     = screen.w/2+250,
		y     = screen.h/2
	}
)
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
local game_on = false
game = nil
local ind = {r=1,c=1}
local mode = {"TRAVERSAL","CLEAR","PEN","PENCIL","BACK"}
local curr_mode = "TRAVERSAL"
function game_on_key_down(k)
	local key = 
	{
		[keys.Down] = function()
			if ind.r < 9 then
				game:out_focus(ind.r,ind.c)
				ind.r=ind.r+1
				game:on_focus(ind.r,ind.c)
			end
		end,
		[keys.Up] = function()
			if ind.r > 1 then
				game:out_focus(ind.r,ind.c)
				ind.r=ind.r-1
				game:on_focus(ind.r,ind.c)

			end
		end,
		[keys.Right] = function()
			if ind.c < 9 then
				game:out_focus(ind.r,ind.c)
				ind.c=ind.c+1
				game:on_focus(ind.r,ind.c)
			end
		end,
		[keys.Left] = function()

			if ind.c > 1 then
				game:out_focus(ind.r,ind.c)
				ind.c=ind.c-1
				game:on_focus(ind.r,ind.c)
			end

		end,
--[[
		[keys.Return] = function()
			local enter_presses = {
				["TRAVERSAL"] = function ()
					game:enter_menu(ind.r,ind.c)
					curr_mode = "PENCIL"
				end,
				["CLEAR"] = function ()
					game:clear_guesses()
				end,
				["PEN"] = function ()
				end,
				["PENCIL"] = function ()
				end,
				["BACK"] = function ()
					game:close_menu()
					curr_mode = "TRAVERSAL"
				end,				
			}
			if enter_presses[curr_mode] then
				enter_presses[curr_mode]()
			else
				error("aw shit")
			end
		end,
--]]
		[keys["1"] ] = function()
			game:toggle_guess(ind.r,ind.c,1,"REG")
		end,
		[keys["2"] ] = function()
			game:toggle_guess(ind.r,ind.c,2,"REG")
		end,
		[keys["3"] ] = function()
			game:toggle_guess(ind.r,ind.c,3,"REG")
		end,
		[keys["4"] ] = function()
			game:toggle_guess(ind.r,ind.c,4,"REG")
		end,
		[keys["5"] ] = function()
			game:toggle_guess(ind.r,ind.c,5,"REG")
		end,
		[keys["6"] ] = function()
			game:toggle_guess(ind.r,ind.c,6,"REG")
		end,
		[keys["7"] ] = function()
			game:toggle_guess(ind.r,ind.c,7,"REG")
		end,
		[keys["8"] ] = function()
			game:toggle_guess(ind.r,ind.c,8,"REG")
		end,
		[keys["9"] ] = function()
			game:toggle_guess(ind.r,ind.c,9,"REG")
		end,


		[keys["KP_End"] ] = function()
			game:toggle_guess(ind.r,ind.c,1,"REG")
		end,
		[keys["KP_Down"] ] = function()
			game:toggle_guess(ind.r,ind.c,2,"REG")
		end,
		[keys["KP_Page_Down"] ] = function()
			game:toggle_guess(ind.r,ind.c,3,"REG")
		end,
		[keys["KP_Left"] ] = function()
			game:toggle_guess(ind.r,ind.c,4,"REG")
		end,
		[keys["KP_Begin"] ] = function()
			game:toggle_guess(ind.r,ind.c,5,"REG")
		end,
		[keys["KP_Right"] ] = function()
			game:toggle_guess(ind.r,ind.c,6,"REG")
		end,
		[keys["KP_Home"] ] = function()
			game:toggle_guess(ind.r,ind.c,7,"REG")
		end,
		[keys["KP_Up"] ] = function()
			game:toggle_guess(ind.r,ind.c,8,"REG")
		end,
		[keys["KP_Page_Up"] ] = function()
			game:toggle_guess(ind.r,ind.c,9,"REG")
		end,
		
		[keys["u"] ] = function()
			game:undo(ind.r,ind.c)
		end,
		[keys["r"] ] = function()
			game:redo(ind.r,ind.c)
		end,
		[keys["n"] ] = function()
			game.board:clear()
			game = Game(80)
			game:on_focus(1,1)
			ind = {r=1,c=1}
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
if settings.g then
	game = settings.g
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
				if settings.g then
					game.board:clear()
				end
				game = Game(num_givens)
			end
			game_on = true
			game:on_focus(1,1)
			ind = {r=1,c=1}
		end,
		[keys.Down] = function()
			if num_givens > 25 then
				num_givens = num_givens - 1
				splash:find_child("givens").text = num_givens
				splash:find_child("givens_s").text = num_givens
			end
		end,
		[keys.Up] = function()
			if num_givens < 60 then
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

			if settings.g then
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
function app:on_close()
	settings.g = game
end
--game:on_focus(1,1)
screen:show()
