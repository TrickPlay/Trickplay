--[[
dolater(
dofile,"Button/test.lua"
)
--]]
--[[
dolater(
dofile,"ToggleButton/test.lua"
)
dolater(
dofile,"RadioButtonGroup/test.lua"
)
--]]

--[[
dolater(
dofile,"DialogBox/test.lua"
)
--]]
--[[
dolater(
dofile,"ProgressSpinner/test.lua"
)
--]]

--[=[
screen:show()

if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end
if not BUTTON            then dofile("Button/Button.lua")                 end


--------------------------------------------------------------------------------



local color_scheme_json = '{"ColorScheme":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (10)":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (11)":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (12)":{"activation":[155,155,155],"default":[0,0,0],"focus":[155,155,155]},"ColorScheme (13)":{"activation":[155,255,255],"default":[255,255,155],"focus":[255,255,155]},"ColorScheme (14)":{"activation":[155,255,255],"default":[255,255,155],"focus":[255,255,155]},"ColorScheme (15)":{"activation":[155,255,255],"default":[255,255,155],"focus":[255,255,155]},"ColorScheme (16)":{"activation":[155,155,155],"default":[80,0,0],"focus":[155,155,155]},"ColorScheme (17)":{"activation":[155,255,255],"default":[255,255,155],"focus":[255,255,155]},"ColorScheme (18)":{"activation":[155,155,155],"default":[80,0,0],"focus":[155,155,155]},"ColorScheme (20)":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (21)":{"activation":[155,155,155],"default":[0,0,0],"focus":[155,155,155]},"ColorScheme (22)":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (4)":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (5)":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (6)":{"activation":[155,155,155],"default":[0,0,0],"focus":[155,155,155]},"ColorScheme (7)":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (8)":{"activation":[255,0,0],"default":[255,255,255],"focus":[255,255,255]},"ColorScheme (9)":{"activation":[155,155,155],"default":[0,0,0],"focus":[155,155,155]}}'

local styles_json = '{"Style (1)":{"arrow":"ArrowStyle (1)","border":"BorderStyle (1)","fill_colors":"ColorScheme (6)","text":"TextStyle (1)"},"Style (2)":{"arrow":"ArrowStyle (2)","border":"BorderStyle (2)","fill_colors":"ColorScheme (9)","text":"TextStyle (2)"},"Style (3)":{"arrow":"ArrowStyle (3)","border":"BorderStyle (3)","fill_colors":"ColorScheme (12)","text":"TextStyle (3)"},"Style (4)":{"arrow":"ArrowStyle (4)","border":"BorderStyle (6)","fill_colors":"ColorScheme (21)","text":"TextStyle (6)"},"Style (5)":{"arrow":"ArrowStyle (5)","border":"BorderStyle (5)","fill_colors":"ColorScheme (18)","text":"TextStyle (5)"},"Style (6)":{"arrow":"ArrowStyle (6)","border":"BorderStyle (4)","fill_colors":"ColorScheme (16)","text":"TextStyle (4)"}}'
local arrow_json = '{"ArrowStyle (1)":{"colors":"ColorScheme (22)","offset":10,"size":20},"ArrowStyle (2)":{"colors":"ColorScheme (22)","offset":10,"size":20},"ArrowStyle (3)":{"colors":"ColorScheme (22)","offset":10,"size":20},"ArrowStyle (4)":{"colors":"ColorScheme (22)","offset":10,"size":20},"ArrowStyle (5)":{"colors":"ColorScheme (22)","offset":10,"size":20},"ArrowStyle (6)":{"colors":"ColorScheme (22)","offset":10,"size":20}}'
local border_json = '{"BorderStyle (1)":{"colors":"ColorScheme","corner_radius":10,"width":2},"BorderStyle (2)":{"colors":"ColorScheme (4)","corner_radius":10,"width":2},"BorderStyle (3)":{"colors":"ColorScheme (7)","corner_radius":10,"width":2},"BorderStyle (4)":{"colors":"ColorScheme (14)","corner_radius":10,"width":10},"BorderStyle (5)":{"colors":"ColorScheme (13)","corner_radius":10,"width":10},"BorderStyle (6)":{"colors":"ColorScheme (10)","corner_radius":10,"width":2}}'
local text_json = '{"TextStyle (1)":{"alignment":"CENTER","color":[255,255,255],"colors":"ColorScheme (5)","font":"Sans 40px","justify":true,"type":"TEXTSTYLE","wrap":true,"x_offset":0,"y_offset":0},"TextStyle (2)":{"alignment":"CENTER","color":[255,255,255],"colors":"ColorScheme (8)","font":"Sans 40px","justify":true,"type":"TEXTSTYLE","wrap":true,"x_offset":0,"y_offset":0},"TextStyle (3)":{"alignment":"CENTER","color":[255,255,255],"colors":"ColorScheme (11)","font":"Sans 40px","justify":true,"type":"TEXTSTYLE","wrap":true,"x_offset":0,"y_offset":0},"TextStyle (4)":{"alignment":"CENTER","color":[255,255,155],"colors":"ColorScheme (15)","font":"Sans 50px","justify":true,"type":"TEXTSTYLE","wrap":true,"x_offset":0,"y_offset":0},"TextStyle (5)":{"alignment":"CENTER","color":[255,255,155],"colors":"ColorScheme (17)","font":"Sans 50px","justify":true,"type":"TEXTSTYLE","wrap":true,"x_offset":200,"y_offset":-50},"TextStyle (6)":{"alignment":"CENTER","color":[255,255,255],"colors":"ColorScheme (20)","font":"Sans 40px","justify":true,"type":"TEXTSTYLE","wrap":true,"x_offset":0,"y_offset":0}}'


styles_json = '{"style":'..styles_json..',"arrow":'..arrow_json..',"border":'..border_json..',"text":'..text_json..'}'



local screen_json = '['
screen_json = screen_json.. '{"name":"b1","anchor_point":[0,0],"focused":false,"gid":22,"h":50,"label":"Button","opacity":255,"scale":[1,1,0,0],"style":"Style (3)","type":"Button","w":200,"x":0,"x_rotation":[0,0,0],"y":0,"y_rotation":[0,0,0],"z":0,"z_rotation":[0,0,0]}'
screen_json = screen_json..',{"name":"b2","anchor_point":[0,0],"focused":false,"gid":17,"h":50,"label":"lAbel","opacity":255,"scale":[1,1,0,0],"style":"Style (5)","type":"Button","w":200,"x":100,"x_rotation":[0,0,0],"y":200,"y_rotation":[0,0,0],"z":0,"z_rotation":[0,0,0]}'
screen_json = screen_json..',{"name":"b3","anchor_point":[0,0],"focused":false,"gid":29,"h":100,"label":"new_label","opacity":255,"scale":[1,1,0,0],"style":"Style (6)","type":"Button","w":400,"x":100,"x_rotation":[0,0,0],"y":400,"y_rotation":[0,0,0],"z":0,"z_rotation":[0,0,0]}'
screen_json = screen_json..',{"name":"b4","anchor_point":[0,0],"focused":false,"gid":34,"h":150,"images":{"default":"Button\/button3.png","focus":"Button\/button-focus.png"},"label":"Button","opacity":255,"scale":[1,1,0,0],"style":"Style (4)","type":"Button","w":300,"x":200,"x_rotation":[0,0,0],"y":600,"y_rotation":[0,0,0],"z":0,"z_rotation":[0,0,0]}'
screen_json = screen_json..',{"name":"b5","anchor_point":[0,0],"focused":false,"gid":35,"h":100,"label":"new_label","opacity":255,"scale":[1,1,0,0],"style":"Style (6)","type":"Button","w":400,"x":100,"x_rotation":[0,0,0],"y":700,"y_rotation":[0,0,0],"z":0,"z_rotation":[0,0,0]}'
screen_json = screen_json..']'

 

]=]
--------------------------------------------------------------------------------

local color_scheme_uri = 'app/color_schemes.json'
local style_uri        = 'app/styles.json'
local layer_dir        = 'app/'

local color_schemes

local function load_color_schemes()
    
    local input = color_scheme_json--readfile(color_scheme_uri)
    
    if input == nil then
        
        print("'"..color_scheme_uri.."' does not exist, Default colors will be used")
        
        color_schemes = {}
        
        return
        
    end
    
    input = json:parse(input)
    
    if input == nil then
        
        error("'"..color_scheme_uri.."' is invalid json",2)
        
    end
    
    if type(input) ~= "table" then
        
        error("JSON in '"..color_scheme_uri.."' is not formatted as expected.",2)
        
    end
    
    color_schemes = {}
    
    for k,v in pairs(input) do
        
		v.name = k
		
        color_schemes[k] = ColorScheme(v)
        
    end
    
end

--------------------------------------------------------------------------------

local styles

function load_styles(str)
    
        
    if type(styles) == "table" then
        
        print("WARNING. Styles table already exists")
        
    end
    
    if type(str) ~= "string" then
        
        error("Expected string. Received "..type(str),2)
        
    end
    
    styles = json:parse(str)
    
    if type(styles) ~= "table" then
        
        error("String is not valid json",2)
        
    end
    
    for name,attributes in pairs(styles) do
        
        styles[name] = Style(name):set(attributes)
        
    end
    
    return styles
        
end

--[[
local function load_styles()
    
    if not color_schemes then load_color_schemes() end
    
    local input = styles_json--readfile(style_uri)
    
    if input == nil then
        
        print("'"..style_uri.."' does not exist, Default styles and colors will be used")
        
        styles = {}
        
        return
        
    end
    
    input = json:parse(input)
    
    if input == nil then
        
        error("'"..style_uri.."' is invalid json",2)
        
    end
    
    if type(input) ~= "table" or not (input.arrow and input.border and input.text and input.style) then
        
        error("JSON in '"..style_uri.."' is not formatted as expected.",2)
        
    end
    
    styles = {}
    
    local arrow_styles, text_styles, border_styles = {},{},{}
    
    for k,v in pairs(input.arrow)  do
        --v.colors = type(v.colors) == "string" and color_schemes[v.colors] or v.colors
        v.name = k
		arrow_styles[k]  = ArrowStyle(v)
    end
    for k,v in pairs(input.border) do
        --v.colors = type(v.colors) == "string" and color_schemes[v.colors] or v.colors
        v.name = k
		border_styles[k] = BorderStyle(v)
    end
    for k,v in pairs(input.text)   do
        --v.colors = type(v.colors) == "string" and color_schemes[v.colors] or v.colors
        v.name = k
		text_styles[k]   = TextStyle(v)
    end
    
    for k,v in pairs(input.style) do
        
        --v.arrow       = type(v.arrow)       == "string" and arrow_styles[v.arrow]        or v.arrow
        --v.border      = type(v.border)      == "string" and border_styles[v.border]      or v.border
        --v.text        = type(v.text)        == "string" and text_styles[v.text]          or v.text
        --v.fill_colors = type(v.fill_colors) == "string" and color_schemes[v.fill_colors] or v.fill_colors
        v.name = k
        styles[k] = Style(v)
        
    end
    
end
]]

--------------------------------------------------------------------------------

local names
local neigbor_info
local curr_neighbors
local obj

local construct
construct = function(t)
    
    if type(t) ~= "table" then
        
        return error("Expects table, received "..type(t),2)
        
    end
    
    if t.type == "LayoutManager" then
        for i,row in ipairs(t.cells) do
            for j,v in ipairs(row) do
                
                t.cells[i][j] = construct(v)
                
            end
        end
    elseif t.type == "ListManager" then
        for i,v in ipairs(t.cells) do
            
            t.cells[i] = construct(v)
            
        end
    elseif t.children then
        for i,v in ipairs(t.children) do
            
            t.children[i] = construct(v)
            
        end
    end
    curr_neighbors = t.neighbors
    obj = _G[t.type] and _G[t.type](t) or
        
        error("Received invalid type: "..t.type)
    
    names[obj.name] = obj
    neigbor_info[obj] = curr_neighbors
    
    return obj
    
end
function load_layer(str)
    
    names = {}
    neigbor_info = {}
    
      --load_styles should be called before load_layer
    if type(styles) ~= "table" then
        
        print("WARNING. Styles table is empty")
        
    end
    
    --load_layer expects to receive a json string
    if type(str) ~= "string" then
        
        error("Expected string. Received "..type(str),2)
        
    end
    
    --parse the json
    local layer = json:parse(str)
    
    --load_layer expects valid json
    if type(layer) ~= "table" then
        
        error("String is not valid json",2)
        
    end
    
    --the setter for Widget_Group.children calls the appropriate 
    --constructors when it receives an attributes table as an entry
    layer = construct(layer)
    
    for obj,neighbors in pairs(neigbor_info) do
        
        for k,v in pairs(neighbors) do
            
            obj.neighbors[k] = names[v]
            
        end
        
    end
    
    return layer
end

--[[
construct = function(t)
    
    if type(t) ~= "table" then
        
        return error("Expects table, received "..type(t))
        
    end
    
    if t.children then
        
        for i,v in ipairs(t.children) do
            
            t.children[i] = construct(t)
            
        end
        
    end
    
    return constructors[t.type] and constructors[t.type](t) or
        
        error("Received invalid type "..t.type)
    
end

--------------------------------------------------------------------------------

load_layer = function(layer_name)
    
    if type(layer_name) ~= "string" then
        
        error("'load_layer()' expects type 'string'. Recieved "..type(layer_name),2)
        
    end
    
    --the first time this function is called, styles will get set up
    if not styles then load_styles() end
    
    --load the json
    local layer = readfile(layer_name)
    
    if layer == nil then
        
        error("Layer '"..layer_name.."' does not exist.",2)
        
    end
    
    --parse it
    layer = json:parse(layer)
    
    if layer == nil then
        
        error("Layer '"..layer_name.."' has invalid json",2)
        
    end
    
    if type(layer) ~= "table" then
        
        error("Layer '"..layer_name.."' contained expected json. Top-Level is not an array.",2)
        
    end
    
    --make it a group
    local layer_object = Group()
    
    layer_object.elements = {}
    
    for i,v in ipairs(layer) do
        print(v.name,v.style)
        v.style = type(v.style) == "string" and styles[v.style] or v.style
        print(v.name,v.style.name)
        local current_object = construct(v)
        
        if type(current_object) ~= "userdata" and not current_object.__types__.actor then
            
            error(i.."-th entry in the '"..layer_name.."' layer is not a UIElement",2)
            
        end
        
        if type(current_object.name) ~= "string" then
            
            error(i.."-th entry in the '"..layer_name.."' layer does not have a name",2)
            
        end
        
        layer_object.elements[ string.gsub( current_object.name, " ", "_" ) ] = current_object
        print(current_object.name,current_object.style.name)
        layer_object:add(  current_object  )
        
    end
    
    return layer_object
    
end
]]

--l = load_layer("fake")

--screen:add(l)
--]]
