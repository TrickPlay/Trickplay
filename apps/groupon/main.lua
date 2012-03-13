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
	
	tag           = Image{src = "assets/button-tag.png"},
	btn_glow      = Image{src = "assets/button-glow.png"},
	submit_btn    = Image{src = "assets/button-small.png"},
	submit_glow   = Image{src = "assets/button-small-focus.png"},
	check_red     = Image{src = "assets/check-red.png"},
	dot           = Image{src = "assets/dot.png"},
	cell_dark     = Image{src = "assets/cell-dark-grey.png"},
	cell_green    = Image{src = "assets/cell-green.png"},
	cell_dark_s   = Image{src = "assets/cell-dark-grey-small.png"},
	cell_green_s  = Image{src = "assets/cell-green-small.png"},
	g             = Image{src = "assets/g.png"},
	info_panel    = Image{src = "assets/more-info-panel.png"},
	controller    = Image{src = "assets/controller.png"},
	control_mmr   = Image{src = "assets/controller-mmr.png"},
	zip_cells     = Image{src = "assets/zip-cells-5-grey.png"},
    zip_entry_top = Image{src = "assets/numeric-panel-mmr-top.png"},
    zip_entry_btm = Image{src = "assets/numeric-panel-mmr-btm.png"},
	n_a           = Image{src = "assets/no-longer-available.png"},
    close_btn     = Image{src = "assets/button-mmr-close.png"},
    close_focus   = Image{src = "assets/button-mmr-close-focus.png"},
    clear_btn     = Image{src = "assets/button-mmr-clear.png"},
    clear_focus   = Image{src = "assets/button-mmr-clear-focus.png"},
    change        = Image{src = "assets/button-mmr-change.png"},
    change_focus  = Image{src = "assets/button-mmr-change-focus.png"},
    hor_num_pad   = Image{src = "assets/numeric-pad.png"},
    hor_num_hl    = Image{src = "assets/numeric-hilite.png"},
    x             = Image{src = "assets/close-btn.png"},
    red_dot       = Image{src = "assets/dot-red.png"},
	hourglass     = {
		Image{src = "assets/hourglass/hourglass000.gif"},
		Image{src = "assets/hourglass/hourglass001.gif"},
		Image{src = "assets/hourglass/hourglass002.gif"},
		Image{src = "assets/hourglass/hourglass003.gif"},
		Image{src = "assets/hourglass/hourglass004.gif"},
		Image{src = "assets/hourglass/hourglass005.gif"},
		Image{src = "assets/hourglass/hourglass006.gif"},
		Image{src = "assets/hourglass/hourglass007.gif"},
		Image{src = "assets/hourglass/hourglass008.gif"},
		Image{src = "assets/hourglass/hourglass009.gif"},
		Image{src = "assets/hourglass/hourglass010.gif"},
		Image{src = "assets/hourglass/hourglassfinal.gif"},
	},
	hourglass_soldout = Image{src="assets/hourglass/hourglasssoldout.gif"},
}
--assets that are only used in Canvases
bmp = {
	card_bg      = Bitmap("assets/card-bg.png",         false),
	title_slice  = Bitmap("assets/title-bar-slice.png", false),
	title_top    = Bitmap("assets/title-bar-top.png",   false),
	--red_dot      = Bitmap("assets/dot-red.png",         false),
	shadow       = Bitmap("assets/shadow.png",          false),
	tag          = Bitmap("assets/button-tag.png",      false),
}

--Images are add to a hidden group
local clone_srcs = Group{}
screen:add(clone_srcs)
clone_srcs:hide()

--add each image
for _,img in pairs(assets) do
	--go through nested tables (hard-coded for a single layer of nesting)
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

using_keys = true

--------------------------------------------------------------------------------
--GLOBALS from files

ENUM                                        = dofile("Utils.lua")

App_State, Idle_Loop                        = dofile("App_Framework.lua")

Xml_Parse                                   = dofile("XML_to_lua_table.lua")

KEY_HANDLER                                 = dofile("User_Input.lua")

screen.on_key_down                          = KEY_HANDLER.on_key_down

GET_DEALS, SEND_SMS, GET_LAT_LNG, CANCEL    = dofile("Internet_Interfaces.lua")

Loading_G                                   = dofile("LoadingDots.lua")

CONTOLLER_PROMPT                            = dofile("Controller_Notification_Menu.lua")

ZIP_ENTRY                                   = dofile("Object_Zip_Entry.lua")

SMS_ENTRY                                   = dofile("Object_SMS_Entry.lua")

Card_Constructor                            = dofile("Card.lua")

Rolodex_Constructor                         = dofile("Rolodex.lua")

mouse                                       = dofile("Mouse.lua")

screen:add(mouse)

App_State.zip = settings and settings.zip

App_State.state:add_state_change_function(
    function(old_state,new_state)
        
        if type(App_State.zip) == "string" then
            
            GET_LAT_LNG( App_State.zip, function(zip_info)
                
                if zip_info == false or
                    type(zip_info)                                  ~= "table" or
                    type(zip_info.results)                          ~= "table" or
                    type(zip_info.results[1])                       ~= "table" or
                    type(zip_info.results[1].address_components)    ~= "table" or
                    type(zip_info.results[1].geometry)              ~= "table" or
                    type(zip_info.results[1].geometry.location)     ~= "table" or
                    type(zip_info.results[1].geometry.location.lat) == "nil" or
                    type(zip_info.results[1].geometry.location.lng) == "nil" then
                    
                    Loading_G:message("Having trouble connecting")
                    
                    return
                    
                end
                
                if zip_info.status ~= "OK" or
                    zip_info.results[1].address_components[
                            #zip_info.results[1].address_components
                        ].short_name ~= "US" then
                    GET_DEALS(Rolodex_Constructor)
                else
                    
                    local lat = zip_info.results[1].geometry.location.lat
                    local lng = zip_info.results[1].geometry.location.lng
                    
                    GET_DEALS(Rolodex_Constructor,lat,lng,50)
                    
                    
                end
            end)
            
        else
            GET_DEALS(Rolodex_Constructor)
        end
        
        screen:add(Loading_G)
        
        mouse:raise_to_top()
        
        Loading_G.x = 200
        
        Loading_G.y = screen_h - 200
        
        Idle_Loop:add_function(Loading_G.spinning,Loading_G,2000,true)
        
    end,
    "OFFLINE",
    "LOADING"
)






App_State.state:change_state_to("LOADING")

Idle_Loop:resume()

screen:show()