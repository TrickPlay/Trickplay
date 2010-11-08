print = function() end
Directions = {
   RIGHT = { 1, 0},
   LEFT  = {-1, 0},
   DOWN  = { 0, 1},
   UP    = { 0,-1}
}
NUM_ROWS       = 2
NUM_VIS_COLS   = 3

PIC_H = (screen.height/NUM_ROWS)
PIC_W = PIC_H



dofile("Class.lua") -- Must be declared before any class definitions.
dofile("adapters.lua")--/Adapter.lua")

dofile("MVC.lua")
dofile("FocusableImage.lua")

dofile("views/FrontPageView.lua")
dofile("controllers/FrontPageController.lua")

dofile("views/SlideshowView.lua")
dofile("controllers/SlideshowController.lua")
--[[
dofile("views/SourceManagerView.lua")
dofile("controllers/SourceManagerController.lua")
--]]
dofile("Load.lua")

Components = {
   COMPONENTS_FIRST = 1,
   FRONT_PAGE       = 1,
   SLIDE_SHOW       = 2,
   SOURCE_MANAGER   = 3,
   COMPONENTS_LAST  = 3
}
model = Model()

Setup_Album_Covers()

local front_page_view = FrontPageView(model)
front_page_view:initialize()

local slide_show_view = SlideshowView(model)
slide_show_view:initialize()
--cache all of the current searches
function app:on_closing()
	settings.searches = searches
	settings.adaptersTable = adaptersTable
	settings.user_ids = user_ids
end

local lock = { anim = true, timer = true}
single_press = Timer{interval=100}
function single_press:on_timer()
	if lock.timer and lock.anim then
		self:stop()
		screen.on_key_down = model.keep_keys	
	end
	lock.timer = true
end


--delegates the key press to the appropriate on_key_down() 
--function in the active component
function screen:on_key_down(k)
    screen.on_key_down = function()
		lock.timer = false
	end
    if k == keys.OK   then k = keys.Return end
    if k == keys.BACK then k = keys.BackSpace end
	lock.anim = false
	lock.timer = true
	single_press:start()
    assert(model:get_active_controller())
    model:get_active_controller():on_key_down(k)
end

--stores the function pointer
model.keep_keys = screen.on_key_down

function reset_keys()
	lock.anim = true
   -- print("reseting keys",model.keep_keys)
   -- screen.on_key_down = model.keep_keys
end
model:start_app(Components.FRONT_PAGE)

