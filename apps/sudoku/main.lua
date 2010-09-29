math.randomseed(os.time())


Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}

dofile("Class.lua") -- Must be declared before any class definitions.

dofile("Game.lua")

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

