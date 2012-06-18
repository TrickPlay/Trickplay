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

g = Group{name="Layer1"}

dofile("LIB/VE/ve_runtime")
loadfile("test1.lua")(g)

local function dump_properties( o )
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

local uiNum = 0
local layerNum = 0
local dragging = nil
json_head = '[{"anchor_point":[0,0], "children":[{"anchor_point":[0,0], "children":'  
json_tail = ',"gid":2,"is_visible":true,"name":"screen","opacity":255,"position":[0,0,0],"scale":[0.5, 0.5],"size":[1920, 1080],"type":"Group","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}], "gid":0,"is_visible":true,"name":"stage","opacity":255,"position":[0,0,0],"scale":[1,1],"size":[960, 540],"type":"Stage","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}]'

sjson_head = '[{"anchor_point":[0,0], "children":'  
sjson_tail = ',"gid":2,"is_visible":true,"name":"screen","opacity":255,"position":[0,0,0],"scale":[1, 1],"size":[1920, 1080],"type":"Group","x_rotation":[0,0,0],"y_rotation":[0,0,0],"z_rotation":[0,0,0]}]'
fake_json = '{"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "Layer1", "anchor_point": [0,0], "x_rotation": [0,0,0], "gid": 3, "z_rotation": [0,0,0], "position": [0,0,0], "type": "Group", "children": [{"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "rectangle0", "anchor_point": [0,0],"border_color": [255,255,255,255], "x_rotation": [0,0,0], "color": [255,255,255,255], "gid": 4, "z_rotation": [0,0,0], "position": [0,0,0], "border_width": 0, "type": "Rectangle", "size": [212, 186]}, {"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "clone1", "anchor_point": [0,0], "x_rotation": [0,0,0], "source": {"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "rectangle0", "anchor_point": [0,0], "border_color": [255,255,255,255], "x_rotation": [0,0,0], "color": [255,255,255,255], "gid": 4, "z_rotation": [0,0,0], "position": [216,160,0],"border_width": 0, "type": "Rectangle", "size": [212, 186]}, "gid": 5, "z_rotation": [0,0,0], "position": [216, 390, 0], "type": "Clone", "size": [212, 186]}, {"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "image2", "clip": [0,0,450,978], "src": "/assets/images/img_big_01.png", "anchor_point": [0,0], "x_rotation": [0,0,0], "gid": 6, "z_rotation": [0,0,0], "position": [208, 590, 0], "type": "Texture", "size": [978, 450]}, {"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "text3", "anchor_point": [0,0], "text": "TEXT", "x_rotation": [0,0,0], "color": [255,255,255,255], "gid": 7, "z_rotation": [0,0,0], "position": [224, 1046, 0], "font": "FreeSans Medium 30px", "type": "Text", "size": [39, 75]}], "size": [1186, 1121]}'

fake_layer_name = '{"opacity": 255, "is_visible": true, "scale": [1,1], "y_rotation": [0,0,0], "name": "'
fake_layer_gid = '", "anchor_point": [0,0], "x_rotation": [0,0,0], "gid": '
fake_layer_children = ', "children" : ['
fake_layer_end = '], "z_rotation": [0,0,0], "position": [0,0,0], "type": "Group", "size": [1186, 1121]}'

fake_style_json =
'{"Style":{"arrow":{"colors":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"offset":10,"size":20},"border":{"colors":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"corner_radius":10,"width":2},"fill_colors":{"activation":[155,155,155],"default":[0,0,0],"focus":[155,155,155]},"name":"Style","text":{"alignment":"CENTER","colors":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"font":"Sans 40px","justify":true,"wrap":true,"x_offset":0,"y_offset":0}}}'

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
    _VE_.getUIInfo()
    _VE_.getStInfo()
    --[[
    local t = {}
    if uiInstance.to_json then 
        table.insert(t, json:parse(uiInstance:to_json()))
    end 
    print("repUIInfo"..json:stringify(t))
    ]] 
end

_VE_.repUIInfoWfakeJson = function(uiInstance)
    local t = {}
    if uiInstance.to_json then 
        table.insert(t, json:parse(uiInstance.extra.to_json()))
    end 
    print("repUIInfo"..json_head..json:stringify(t)..json_tail)
end

_VE_.openInspector = function(gid)
    print("openInspc"..gid)
end 

---[[
_VE_.setAppPath = function(path)
    editor:change_app_path(path)
end 
--]]

_VE_.openFile = function(path)
    --s = load_layer("layer1.json")
    --editor:change_app_path("/home/hjkim/code/trickplay/tools/ve2/VE/project1")
    editor:change_app_path(path)
    screen:clear()

    layers_file = "layers.json"
    styles_file = "styles.json"
    screens_file = "screens.json"

    --local scrJson = readfile(screens_file)
    --print("scrJSInfo"..scrJson)

    print("scrJSInfo"..readfile(screens_file))

    if type(styles_file) ~= "string" then
        
        error("'load_layer()' expects type 'string'. Recieved "..type(styles_file),2)
        
    end
    
    --the first time this function is called, styles will get set up
    --if not styles then load_styles() end
    
    --load the json
    local style = readfile(styles_file)
    

    style = string.sub(style, 2, string.len(style)-1)


    load_styles(style) 

    local layer = readfile(layers_file)
    layer = string.sub(layer, 2, string.len(layer)-1)
    
    if layer == nil then
        
        error("Layer '"..layers_file.."' does not exist.",2)
        
    end

    s = load_layer(layer)
    --screen:add(s)

    for i,j in ipairs(s.children) do
        if j.subscribe_to then  
            j:subscribe_to(nil, function()  _VE_.repUIInfo(j) end)
        end 
        function j.on_button_down( j , x , y , button )
            dragging = { j , x - j.x , y - j.y }
            if button == 3 then
                _VE_.openInspector(j.gid)
            end
        end
    
        function j.on_button_up( j , x , y , button )
            dragging = nil
        end
    
        if string.find(j.name, "Layer") ~= nil then 
            j.reactive = true 
        end 

        --_VE_.repUIInfo(j)
        j:unparent()
        screen:add(j)
    end
    _VE_.repUIInfo()
end 


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


_VE_.newLayer = function()
    for m,n in ipairs (screen.children) do
        if n.name == "Layer"..layerNum then 
            layerNum = layerNum + 1
        end
    end 
    screen:add(Widget_Group{name="Layer"..layerNum, size={1920, 1080}, position={0,0,0}})
    layerNum = layerNum + 1

    --_VE_.repUIInfo()
    _VE_.getUIInfo()
    _VE_.getStInfo()
end 

_VE_.saveFile = function(scrJson)
    local layer_t = {}
    local style_t = {}

    for a, b in ipairs (screen.children) do
            --editor:writefile("layer1.json", b.name, true) 
            if b.to_json then -- s1.b1
                table.insert(layer_t, json:parse(b:to_json()))
                --print (b.name, b:to_json())
            end
    end

    table.insert(style_t, json:parse(get_all_styles()))

    --editor:change_app_path("/home/hjkim/code/trickplay/tools/ve2/VE/project1")
    editor:writefile("layers.json", sjson_head..json:stringify(layer_t)..sjson_tail, true) 
    editor:writefile("styles.json", json:stringify(style_t), true) 
    editor:writefile("screens.json", scrJson, true) 
    --editor:writefile("layer1_user.lua", , true) 

end 


local uiElementCreate_map = 
{
    ['Button'] = function()  return Button() end, 
    ['DialogBox'] = function() return DialogBox() end,
    ['ToastAlert'] = function() return ToastAlert() end,
    ['ProgressSpinner'] = function() return ProgressSpinner() end,
    ['OrbittingDots'] = function() return OrbittingDots() end,
    ['TextInput'] = function() return TextInput() end,
}

_VE_.insertUIElement = function(curLayerGid, uiTypeStr)
    
    if uiElementCreate_map[uiTypeStr] then
        uiInstance = uiElementCreate_map[uiTypeStr](self)
        for m,n in ipairs (screen.children) do
            if n.name == uiTypeStr:lower()..uiNum then 
                uiNum = uiNum + 1
            end
        end 
        uiInstance.name = uiTypeStr:lower()..uiNum
        uiNum = uiNum + 1
    else
        print "error"
    end

    --print("--------------------")
    --print (uiInstance:to_json())
    --print("--------------------")

    if uiInstance.subscribe_to then  
        -- not nil because there is no in_use property supported
        uiInstance:subscribe_to(nil, function()  _VE_.repUIInfo(uiInstance) end) 
 
    end 

    function uiInstance.on_button_down( uiInstance , x , y , button )
        dragging = { uiInstance , x - uiInstance.x , y - uiInstance.y }
        if button == 3 then
            _VE_.openInspector(uiInstance.gid)
        end
    end

    function uiInstance.on_button_up( uiInstance , x , y , button )
        dragging = nil
    end

    devtools:gid(curLayerGid):add(uiInstance)
    --screen:add(uiInstance)

    --_VE_.repUIInfo(uiInstance)
    _VE_.getUIInfo()
    _VE_.getStInfo()
end

function screen.on_motion( screen , x , y )
    if dragging then
        local actor , dx , dy = unpack( dragging )
        actor.position = { x - dx , y - dy  }
    end
end

screen.reactive = true
screen:show()

controllers:start_pointer()
dolater(print("<<VE_READY>>:"))




