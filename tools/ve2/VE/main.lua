if not OVERRIDEMETATABLE then dofile("LIB/Widget/__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("LIB/Widget/__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("LIB/Widget/__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("LIB/Widget/__UTILITIES/Canvas.lua")            end
if not MISC              then dofile("LIB/Widget/__UTILITIES/Misc.lua")            end
if not COLORSCHEME       then dofile("LIB/Widget/__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("LIB/Widget/__CORE/Style.lua")                  end
if not WIDGET            then dofile("LIB/Widget/__CORE/Widget.lua")                 end
if not BUTTON            then dofile("LIB/Widget/Button/Button.lua")                 end
if not TEXTINPUT         then dofile("LIB/Widget/TextInput/TextInput.lua")           end
if not ORBITTINGDOTS     then dofile("LIB/Widget/OrbittingDots/OrbittingDots.lua")   end
if not PROGRESSSPINNER   then dofile("LIB/Widget/ProgressSpinner/ProgressSpinner.lua") end
if not TOASTALERT        then dofile("LIB/Widget/ToastAlert/ToastAlert.lua")         end
if not DIALOGBOX         then dofile("LIB/Widget/DialogBox/DialogBox.lua")           end

if not RADIOBUTTONGROUP  then dofile("LIB/Widget/RadioButtonGroup/RadioButtonGroup.lua") end
if not GRIDMANAGER       then dofile("LIB/Widget/__UTILITIES/ListManagement.lua")   end
if not NINESLICE         then dofile("LIB/Widget/NineSlice/NineSlice.lua")          end
if not CLIPPINGREGION    then dofile("LIB/Widget/ClippingRegion/ClippingRegion.lua")end
if not SLIDER            then dofile("LIB/Widget/Slider/Slider.lua")                end
if not LAYOUTMANAGER     then dofile("LIB/Widget/LayoutManager/LayoutManager.lua")  end
if not SCROLLPANE        then dofile("LIB/Widget/ScrollPane/ScrollPane.lua")        end
if not ARROWPANE         then dofile("LIB/Widget/ArrowPane/ArrowPane.lua")          end
if not BUTTONPICKER      then dofile("LIB/Widget/ButtonPicker/ButtonPicker.lua")    end
if not MENUBUTTON        then dofile("LIB/Widget/MenuButton/MenuButton.lua")        end
if not TABBAR            then dofile("LIB/Widget/TabBar/TabBar.lua")                end

dofile("LIB/VE/ve_runtime")

hdr = dofile("header")
editor = dofile("editor")
screen_ui = dofile("screen_ui")

--[[ test engine ui element 

g = Group{name="Layer1"}
loadfile("test1.lua")(g)

]]

function dump_properties( o )
        local t = {}
        local l = 0
        for k , v in pairs( getmetatable( o ).__getters__ ) do
            local s = v( o )
            if type( s ) == "table" then
                s = serialize( s )
            elseif type( s ) == "string" then
                s = string.format( "%q" , s )
            else
                s = tostring( s )
            end
            table.insert( t , { k , s } )
            l = math.max( l , # k )
        end
        table.sort( t , function( a , b ) return a[1] < b[1] end )
        for i = 1 , # t do
            print( string.format( "%-"..tostring(l+1).."s = %s" , t[i][1] , t[i][2] ) )
        end
end

-- UI Element / Layer Naming Number 

local uiNum = 0
local layerNum = 0
local curLayerGid = nil

-- UI Element Creation Function Map 

local uiElementCreate_map = 
{
    ['Button'] = function()  return Button() end, 
    ['Text'] = function()  return Widget_Text() end, 
    ['Image'] = function()  return Widget_Image() end, 
    --['Rectangle'] = function()  return Widget_Rectangle() end, 
    ['DialogBox'] = function() return DialogBox() end,
    ['ToastAlert'] = function() return ToastAlert() end,
    ['ProgressSpinner'] = function() return ProgressSpinner() end,
    ['OrbittingDots'] = function() return OrbittingDots() end,
    ['TextInput'] = function() return TextInput() end,
    ['LayoutManager'] = function()  return LayoutManager() end, 
    ['Slider'] = function()  return Slider() end, 
    ['ArrowPane'] = function()  return ArrowPane() end, 
    ['ScrollPane'] = function()  return ScrollPane() end, 
    ['TabBar'] = function()  return TabBar() end, 
    ['ButtonPicker'] = function()  return ButtonPicker() end, 
    ['MenuButton'] = function()  return MenuButton() end, 
}

-- Layer JSON 

json_head = '[{"anchor_point":[0,0], "children":[{"anchor_point":[0,0], "children":'  
json_tail = ',"gid":2,"is_visible":true,"name":"screen","opacity":255,"position":[0,0,0],"scale":[0.5, 0.5],"size":[1920, 1080],"type":"Group","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}], "gid":0,"is_visible":true,"name":"stage","opacity":255,"position":[0,0,0],"scale":[1,1],"size":[960, 540],"type":"Stage","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}]'

-- Style JSON 

sjson_head = '[{"anchor_point":[0,0], "children":'  
sjson_tail = ',"gid":2,"is_visible":true,"name":"screen","opacity":255,"position":[0,0,0],"scale":[1, 1],"size":[1920, 1080],"type":"Group","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}]'


--[[  For engine UI Element test 

fake_json = '{"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "Layer1", "anchor_point": [0,0], "x_rotation": [0,0,0], "gid": 3, "z_rotation": [0,0,0], "position": [0,0,0], "type": "Group", "children": [{"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "rectangle0", "anchor_point": [0,0],"border_color": [255,255,255,255], "x_rotation": [0,0,0], "color": [255,255,255,255], "gid": 4, "z_rotation": [0,0,0], "position": [0,0,0], "border_width": 0, "type": "Rectangle", "size": [212, 186]}, {"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "clone1", "anchor_point": [0,0], "x_rotation": [0,0,0], "source": {"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "rectangle0", "anchor_point": [0,0], "border_color": [255,255,255,255], "x_rotation": [0,0,0], "color": [255,255,255,255], "gid": 4, "z_rotation": [0,0,0], "position": [216,160,0],"border_width": 0, "type": "Rectangle", "size": [212, 186]}, "gid": 5, "z_rotation": [0,0,0], "position": [216, 390, 0], "type": "Clone", "size": [212, 186]}, {"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "image2", "clip": [0,0,450,978], "src": "/assets/images/img_big_01.png", "anchor_point": [0,0], "x_rotation": [0,0,0], "gid": 6, "z_rotation": [0,0,0], "position": [208, 590, 0], "type": "Texture", "size": [978, 450]}, {"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "text3", "anchor_point": [0,0], "text": "TEXT", "x_rotation": [0,0,0], "color": [255,255,255,255], "gid": 7, "z_rotation": [0,0,0], "position": [224, 1046, 0], "font": "FreeSans Medium 30px", "type": "Text", "size": [39, 75]}], "size": [1186, 1121]}'
]]

--[[

fake_layer_name = '{"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "'
fake_layer_gid = '", "anchor_point": [0,0], "x_rotation": [0,0,0], "gid": '
fake_layer_children = ', "children" : ['
fake_layer_end = '], "z_rotation": [0,0,0], "position": [0,0,0], "type": "Group", "size": [1186, 1121]}'

]]

--[[ For style json test 

fake_style_json = '{"Style":{"arrow":{"colors":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"offset":10,"size":20},"border":{"colors":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"corner_radius":10,"width":2},"fill_colors":{"activation":[155,155,155],"default":[0,0,0],"focus":[155,155,155]},"name":"Style","text":{"alignment":"CENTER","colors":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"font":"Sans 40px","justify":true,"wrap":true,"x_offset":0,"y_offset":0}}}'

]]


---------------------------------------------------------------------------
---                 Local Editor Functions                              ---
---------------------------------------------------------------------------

local rect_init_x = 0
local rect_init_y = 0

local uiRectangle = nil

local function create_mouse_event_handler(uiInstance)
    function uiInstance:on_motion(x,y)
        if dragging then
            local actor , dx , dy = unpack( dragging )
            actor.position = { x - dx , y - dy  }
        end
    end


    function uiInstance:on_button_down(x , y , button)
        dragging = { uiInstance , x - uiInstance.x , y - uiInstance.y }
        _VE_.openInspector(uiInstance.gid)
        uiInstance:grab_pointer()
        if uiTypeStr == "Text" then 
            uiInstance.cursor_visible = true
            uiInstance.editable= true
            uiInstance:grab_key_focus()
            return true
        end 
    end

    function uiInstance:on_button_up(x , y , button)
        dragging = nil
        uiInstance:ungrab_pointer()
        uiInstance:set{}
    end
end 

local function assign_right_name (uiInstance, uiTypeStr)

    for m,n in ipairs (screen.children) do
        if string.find(n.name, "Layer") then  
            for k,l in ipairs (n.children) do 
                if l.name == uiTypeStr:lower()..uiNum then 
                    uiNum = uiNum + 1
                end
            end
        end
    end 

    uiInstance.name = uiTypeStr:lower()..uiNum
    uiNum = uiNum + 1

end 

local function editor_rectangle(x, y)

    local dragging = nil 
    rect_init_x = x 
    rect_init_y = y 
    
    uiRectangle = Widget_Rectangle()

    assign_right_name(uiRectangle, "Rectangle")

    --[[
    for m,n in ipairs (screen.children) do
        if string.find(n.name, "Layer") then  
            for k,l in ipairs (n.children) do 
                if l.name == "rectangle"..uiNum then 
                    uiNum = uiNum + 1
                end
            end
        end
    end 
    uiRectangle.name = "rectangle"..uiNum
    uiNum = uiNum + 1
    ]]

    uiRectangle.size = {1,1}
    uiRectangle.color= hdr.DEFAULT_COLOR
    uiRectangle.position = {x,y,0}
    uiRectangle.org_x = x
    uiRectangle.org_y = y


    create_mouse_event_handler(uiRectangle)

    uiRectangle.reactive = true

    --dump_properties(uiRectangle)

    devtools:gid(curLayerGid):add(uiRectangle)

    _VE_.getUIInfo()
    _VE_.getStInfo()

    if uiRectangle.subscribe_to then  
        -- not nil because there is no in_use property supported
        uiRectangle:subscribe_to(nil, function() if dragging == nil then  _VE_.repUIInfo(uiRectangle) end end) 
    end 

    uiRectangle.reactive = true

    return uiRectangle
end 


local function editor_rectangle_move(x,y)

	if uiRectangle then 
        uiRectangle.size = { math.abs(x-rect_init_x), math.abs(y-rect_init_y) }
        if(x- rect_init_x < 0) then
            uiRectangle.x = x
        end
        if(y- rect_init_y < 0) then
            uiRectangle.y = y
        end
	end

end



local function editor_rectangle_done(x,y)
	if uiRectangle == nil then return end 
    uiRectangle.size = { math.abs(x-rect_init_x), math.abs(y-rect_init_y) }
    if(x-rect_init_x < 0) then
    	uiRectangle.x = x
    end
    if(y-rect_init_y < 0) then
    	uiRectangle.y = y
    end
    screen.grab_key_focus(screen)
end 

local function editor_text(uiText)

    uiText.position ={200, 200, 0}
	uiText.wants_enter = true
	uiText.editable = true
	uiText.text = "AA"
    uiText.font= "FreeSans Medium 30px"
    uiText.color = {100,255,255,255}
    --wrap=true, wrap_mode="CHAR", 
	--extra = {org_x = 200, org_y = 200}

    uiText.grab_key_focus(uiText)

    function uiText:on_key_down(key,u,t,m)

    	if key == keys.Return then 
			uiText:set{cursor_visible = false}
        	screen.grab_key_focus(screen)
			uiText:set{editable= false}
			local text_len = string.len(uiText.text) 
			local font_len = string.len(uiText.font) 
	        local font_sz = tonumber(string.sub(uiText.font, font_len - 3, font_len -2))	
			local total = math.floor((font_sz * text_len / uiText.w) * font_sz *2/3) 
			if(total > uiText.h) then 
				uiText.h = total 
			end 
			return true
	    end 

	end 

end 

---------------------------------------------------------------------------
---            Global  Visual Editor Functions                          ---
---------------------------------------------------------------------------

_VE_ = {}

-- GET 
_VE_.getStInfo = function()

    local t = {}
    --table.insert(t, json:parse(fake_style_json))
    table.insert(t, json:parse(get_all_styles()))
    print("getStInfo"..json:stringify(t))
end 

_VE_.repStInfo = function()
    local t = {}
    table.insert(t, json:parse(get_all_styles()))
    print("repStInfo"..json:stringify(t))
end 

_VE_.getUIInfo = function()
    local t = {}
    for m,n in ipairs (screen.children) do
    --[[
        if string.find(n.name, "Layer") then  
            fake_layer = fake_layer_name..n.name..fake_layer_gid..n.gid..fake_layer_children
            for i,j in ipairs(n.children) do 
                if j.to_json then 
                    if i > 1 then
                        fake_layer = fake_layer..','..j:to_json()
                    else 
                        fake_layer = fake_layer..j:to_json()
                    end
                end 
            end 
            fake_layer = fake_layer..fake_layer_end
            table.insert(t, json:parse(fake_layer))
        else]]
        if n.to_json then -- s1.b1
            table.insert(t, json:parse(n:to_json()))
        end
    end
    
    print("getUIInfo"..json_head..json:stringify(t)..json_tail)
end 

-- SET
_VE_.setUIInfo = function(gid, property, value)
    devtools:gid(gid)[property] = value 
end 

-- REPORT 
_VE_.repUIInfo = function(uiInstance)
    --_VE_.getUIInfo()
    --_VE_.getStInfo()
    ---[[
    local t = {}
    if uiInstance.to_json then 
        table.insert(t, json:parse(uiInstance:to_json()))
    end 
    print("repUIInfo"..json:stringify(t))
    ---]] 
end

--[[
_VE_.repUIInfoWfakeJson = function(uiInstance)
    local t = {}
    if uiInstance.to_json then 
        table.insert(t, json:parse(uiInstance.extra.to_json()))
    end 
    print("repUIInfo"..json_head..json:stringify(t)..json_tail)
end
]]

_VE_.openInspector = function(gid)
    print("openInspc"..gid)
end 

_VE_.setAppPath = function(path)
    editor_lb:change_app_path(path)
end 

_VE_.openFile = function(path)
    editor_lb:change_app_path(path)
    screen:clear()

    layers_file = "layers.json"
    styles_file = "styles.json"
    screens_file = "screens.json"

    print("scrJSInfo"..readfile(screens_file))

    --the first time this function is called, styles will get set up
    --if not styles then load_styles() end
    
    --load the json
    local style = readfile(styles_file)
    style = string.sub(style, 2, string.len(style)-1)

    if style == nil then
        error("Style '"..styles_file.."' does not exist.",2)
    end

    load_styles(style) 

    local layer = readfile(layers_file)
    layer = string.sub(layer, 2, string.len(layer)-1)
    
    if layer == nil then
        error("Layer '"..layers_file.."' does not exist.",2)
    end

    -- Image !!! 

    q,w = string.find(path, "/screens")
    path = string.sub(path, 1, q - 1)
    path = path.."/assets/images/"
    print (path)
    editor_lb:change_app_path(path)

    s = load_layer(layer)

    for i,j in ipairs(s.children) do
        if string.find(j.name, "Layer") ~= nil then 
            for l,m in ipairs(j.children) do 
                m.created = false


                if m.subscribe_to then  
                    m:subscribe_to(nil, function() if dragging == nil then _VE_.repUIInfo(m) end end)
                end 
                function m.on_motion ( m, x , y )
                    if dragging then 
                        local actor , dx , dy = unpack( dragging )
                        actor.position = { x - dx , y - dy  }
                    end
                end

                function m.on_button_down( m , x , y , button )
                    dragging = { m , x - m.x , y - m.y }
                    _VE_.openInspector(m.gid)
                    m:grab_pointer()
                end
        
                function m.on_button_up( m , x , y , button )
                    dragging = nil
                    m:ungrab_pointer()
                    m:set{}
                end
                m.reactive = true 
            end
        end 
        j:unparent()
        screen:add(j)
    end
    
    _VE_.getUIInfo()
    _VE_.getStInfo()
    
    --[[
    for i,j in ipairs(s.children) do
        if string.find(j.name, "Layer") ~= nil then 
            for l,m in ipairs(j.children) do 
               if m.subscribe_to then  
                m:subscribe_to(nil, function() if dragging == nil then _VE_.repUIInfo(m) end end)
               end 
            end
        end
    end
    -]]
end 


--[[
_VE_.openLuaFile = function()
    --s = load_layer("layer1.json")
    screen:clear()
    g.reactive = false
    
    screen:add(g)

    for i,j in ipairs(screen.children) do
        --dump_properties(j)
        --print (j.name)
        j.extra.to_json = function() return fake_json end
        function j.on_button_down( j , x , y , button )
            dragging = { j , x - j.x , y - j.y }
            if button == 3 then
                _VE_.openInspector(4)
            end
        end
    
        function j.on_button_up( j , x , y , button )
            dragging = nil
        end
    
        j.reactive = true 
        _VE_.repUIInfoWfakeJson(j)
    end
end 
]]

_VE_.newLayer = function()
    for m,n in ipairs (screen.children) do
        if n.name == "Layer"..layerNum then 
            layerNum = layerNum + 1
        end
    end 
    screen:add(Widget_Group{name="Layer"..layerNum, size={1920, 1080}, position={0,0,0}})
    layerNum = layerNum + 1

    _VE_.getUIInfo()
    _VE_.getStInfo()
end 

_VE_.saveFile = function(scrJson)
    local layer_t = {}
    local style_t = {}

    for a, b in ipairs (screen.children) do
            if b.to_json then -- s1.b1
                table.insert(layer_t, json:parse(b:to_json()))
            end
    end

    table.insert(style_t, json:parse(get_all_styles()))

    editor_lb:writefile("layers.json", sjson_head..json:stringify(layer_t)..sjson_tail, true) 
    editor_lb:writefile("styles.json", json:stringify(style_t), true) 
    editor_lb:writefile("screens.json", scrJson, true) 

end 



_VE_.insertUIElement = function(layerGid, uiTypeStr, path)

    local uiInstance, dragging = nil 

    curLayerGid = layerGid

    if uiTypeStr == "Rectangle" then 
        input_mode = hdr.S_RECTANGLE 
        screen:grab_key_focus()
        return
    end 

    if uiElementCreate_map[uiTypeStr] then
        uiInstance = uiElementCreate_map[uiTypeStr](self)
    end 

    assign_right_name(uiInstance, uiTypeStr)

    --[[
    if uiElementCreate_map[uiTypeStr] then
        uiInstance = uiElementCreate_map[uiTypeStr](self)
        for m,n in ipairs (screen.children) do
            if string.find(n.name, "Layer") then  
                for k,l in ipairs (n.children) do 
                    if l.name == uiTypeStr:lower()..uiNum then 
                        uiNum = uiNum + 1
                    end
                end
            end
        end 
        uiInstance.name = uiTypeStr:lower()..uiNum
        uiNum = uiNum + 1
    else
        print "error"
    end

    ]]

    if uiTypeStr == "Image" then 
        uiInstance.src = path
    end 

    if uiTypeStr == "Text" then 
        editor_text(uiInstance)
    end

    create_mouse_event_handler(uiInstance)

    uiInstance.reactive = true

    --dump_properties(uiInstance)

    devtools:gid(curLayerGid):add(uiInstance)

    _VE_.getUIInfo()
    _VE_.getStInfo()

    if uiInstance.subscribe_to then  
        -- not nil because there is no in_use property supported
        uiInstance:subscribe_to(nil, function() if dragging == nil then  _VE_.repUIInfo(uiInstance) end end) 
    end 
    if uiTypeStr == "Text" then 
        uiInstance:grab_key_focus()
	    uiInstance.editable = true

    end


end

---------------------------------------------------------------------------
---           Global  Screen Mouse Event Handler Functions              ---
---------------------------------------------------------------------------
---[[

	function screen:on_button_down(x,y,button,num_clicks,m)

      	mouse_state = hdr.BUTTON_DOWN 		-- for drawing rectangle 

		if current_focus and input_mode ~=  hdr.S_RECTANGLE then -- for closing menu button or escaping from text editting 
			current_focus.clear_focus()
			screen:grab_key_focus()
			return
		end 

      	if(input_mode == hdr.S_RECTANGLE) then 
	       uiRectanle = editor_rectangle( x, y) 
		   return
	  	end

		screen_ui.multi_select(x,y)
    end

	local move 
	function screen:on_button_up(x,y,button,clicks_count, m)

		-- for dragging timepoint 
		screen_ui.dragging_up(x,y)

	  	dragging = nil

        if (mouse_state == hdr.BUTTON_DOWN) then
            if input_mode == hdr.S_RECTANGLE then 
	           editor_rectangle_done(x, y) 
	           input_mode = hdr.S_SELECT 
	      	else
				screen_ui.multi_select_done(x,y)
				if move == nil then
					screen_ui.n_selected_all()
				end
				move = nil
	      	end 
       	end

       	mouse_state = hdr.BUTTON_UP

	end

    function screen:on_motion(x,y)

	  	if control == true then 
			screen_ui.draw_selected_container_border(x,y) 
		end 
	 
	 	screen_ui.cursor_setting()
	 	screen_ui.dragging(x,y)

        if(mouse_state == hdr.BUTTON_DOWN) then
            if (input_mode == hdr.S_RECTANGLE) then 
				editor_rectangle_move(x, y) 
			end
            if (input_mode == hdr.S_SELECT) then 
		    	screen_ui.multi_select_move(x, y) 
				move = true
			end
        end
	end


screen.reactive = true
screen:show()

controllers:start_pointer()
dolater(print("<<VE_READY>>:"))




