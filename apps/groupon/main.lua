--GLOBALS

--I f*cking hate radians
function sin(val) return math.sin(math.pi/180*val) end
function cos(val) return math.cos(math.pi/180*val) end
function tan(val) return math.tan(math.pi/180*val) end

--upvals to stop calls to    screen:get_w() & screen:get_h()
screen_w = screen.w
screen_h = screen.h

--Images
assets = {
	
	tag          = Image{src="assets/button-tag.png"},
	btn_glow     = Image{src="assets/button-glow.png"},
	submit_btn   = Image{src="assets/button-small.png"},
	submit_glow  = Image{src="assets/button-small-focus.png"},
	check_green  = Image{src="assets/check-green.png"},
	check_red    = Image{src="assets/check-red.png"},
	dot          = Image{src="assets/dot.png"},
	cell_dark    = Image{src="assets/cell-dark-grey.png"},
	cell_green   = Image{src="assets/cell-green.png"},
	cell_dark_s  = Image{src="assets/cell-dark-grey-small.png"},
	cell_green_s = Image{src="assets/cell-green-small.png"},
	g            = Image{src="assets/g.png"},
	--message      = Image{src="assets/message-bg.png"},
	--red_message  = Image{src="assets/first-location-bg.png"},
	--zip_entry    = Image{src="assets/change-location-bg.png"},
	info_panel   = Image{src="assets/more-info-panel.png"},
	
	
	zip_cells    = Image{src="assets/zip-cells-5-grey.png"},
	n_a          = Image{src="assets/no-longer-available.png"},
	hourglass    = {
		Image{src="assets/hourglass/hourglass000.gif"},
		Image{src="assets/hourglass/hourglass001.gif"},
		Image{src="assets/hourglass/hourglass002.gif"},
		Image{src="assets/hourglass/hourglass003.gif"},
		Image{src="assets/hourglass/hourglass004.gif"},
		Image{src="assets/hourglass/hourglass005.gif"},
		Image{src="assets/hourglass/hourglass006.gif"},
		Image{src="assets/hourglass/hourglass007.gif"},
		Image{src="assets/hourglass/hourglass008.gif"},
		Image{src="assets/hourglass/hourglass009.gif"},
		Image{src="assets/hourglass/hourglass010.gif"},
		Image{src="assets/hourglass/hourglassfinal.gif"},
	},
	hourglass_soldout = Image{src="assets/hourglass/hourglasssoldout.gif"},
}
--assets that are only used in Canvas's
bmp = {
	card_bg      = Bitmap("assets/card-bg.png",false),
	title_slice  = Bitmap("assets/title-bar-slice.png",false),
	title_top    = Bitmap("assets/title-bar-top.png",false),
	red_dot      = Bitmap("assets/dot-red.png",false),
}

--Images are add to a hidden group
local clone_srcs = Group{}
screen:add(clone_srcs)
clone_srcs:hide()

--add each image
for _,img in pairs(assets) do
	--go through nested tables
	if type(img) == "table" then
		for _,img2 in ipairs(img) do
			clone_srcs:add(img2)
		end
	else
		clone_srcs:add(img)
	end
end

--load saved data
links_sent = settings.sent_links or {}
--save that same data on closing
app.on_closing = function()
	
	settings.sent_links = links_sent
	
end

--------------------------------------------------------------------------------
--GLOBALS from files

ENUM                                        = dofile("Utils.lua")

App_State, Idle_Loop                        = dofile("App_Framework.lua")

Xml_Parse                                   = dofile("XML_to_lua_table.lua")

KEY_HANDLER                                 = dofile("User_Input.lua")

screen.on_key_down                          = KEY_HANDLER.on_key_down

GET_DEALS, SEND_SMS, GET_LAT_LNG, TRY_AGAIN = dofile("Internet_Interfaces.lua")

Loading_G                                   = dofile("LoadingDots.lua")

--ZIP_PROMPT                                  = dofile("Object_Zip_Prompt.lua")

ZIP_ENTRY                                   = dofile("Object_Zip_Entry.lua")

SMS_ENTRY                                   = dofile("Object_SMS_Entry.lua")

Card_Constructor                            = dofile("Card.lua")

Rolodex_Constructor                         = dofile("Rolodex.lua")




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


App_State.state:change_state_to("LOADING")

Idle_Loop:resume()

screen:show()