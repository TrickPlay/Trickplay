

--I f*cking hate radians
function sin(val) return math.sin(math.pi/180*val) end
function cos(val) return math.cos(math.pi/180*val) end
function tan(val) return math.tan(math.pi/180*val) end

--upvals to stop calls to    screen:get_w() & screen:get_h()
screen_w = screen.w
screen_h = screen.h



assets = {
	bg          = Image{src="assets/card-bg.png"},
	tag         = Image{src="assets/button-tag.png"},
	btn_glow    = Image{src="assets/button-glow.png"},
	submit_btn  = Image{src="assets/button-small.png"},
	submit_glow = Image{src="assets/button-small-focus.png"},
	check_green = Image{src="assets/check-green.png"},
	check_red   = Image{src="assets/check-red.png"},
	dot         = Image{src="assets/dot.png"},
	cell_dark   = Image{src="assets/cell-dark-grey.png"},
	cell_green  = Image{src="assets/cell-green.png"},
	expired     = Image{src="assets/expired.png"},
	g           = Image{src="assets/g.png"},
	message     = Image{src="assets/message-bg.png"},
	red_message = Image{src="assets/first-location-bg.png"},
	zip_entry   = Image{src="assets/change-location-bg.png"},
	info_panel  = Image{src="assets/more-info-panel.png"},
	sold_out    = Image{src="assets/sold-out.png"},
	title_slice = Image{src="assets/title-bar-slice.png"},
	title_top   = Image{src="assets/title-bar-top.png"},
}


local clone_srcs = Group{}
screen:add(clone_srcs)
clone_srcs:hide()

for _,img in pairs(assets) do
	clone_srcs:add(img)
end


ENUM = dofile("Utils.lua")

App_State, Idle_Loop = dofile("App_Framework.lua")

KEY_HANDLER = dofile("User_Input.lua")

screen.on_key_down = KEY_HANDLER.on_key_down

GET_DEALS, GET_LAT_LNG = dofile("Internet_Interfaces.lua")

Groupon_Request       = dofile("Internet_Groupon.lua")

Loading_G             = dofile("LoadingDots.lua")

--Zip                   = dofile("Modal.lua")

ZIP_PROMPT = dofile("Object_Zip_Prompt.lua")

ZIP_ENTRY  = dofile("Object_Zip_Entry.lua")

SMS_ENTRY  = dofile("Object_SMS_Entry.lua")

Card_Constructor      = dofile("Card.lua")

Rolodex_Constructor   = dofile("Rolodex.lua")




App_State.state:add_state_change_function(
    function(old_state,new_state)
        
        if App_State.zip then
        else
            GET_DEALS(Rolodex_Constructor)
        end
        
        screen:add(Loading_G)
        
        Loading_G.x = 450
        
        Loading_G.y = screen_h - 200
        
        Idle_Loop:add_function(Loading_G.spinning,Loading_G,2000,true)
        
    end,
    "OFFLINE",
    "LOADING"
)



--[[
assert(STATES         ~= nil,  "The STATES table no longer exists, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.LOADING ~= nil,"LOADING is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.ROLODEX ~= nil,"ROLODEX is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.ZIP     ~= nil,    "ZIP is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
assert(STATES.PHONE   ~= nil,  "PHONE is no longer a STATES table, possibly renamed. The file \"User_Input.lua\" needs to be updated.")
--]]

App_State.state:change_state_to("LOADING")

Idle_Loop:resume()

screen:show()