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

        error("'"..color_scheme_uri.."' is invalid json",3)

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

        styles[name] = WL.Style(name):set(attributes)

    end

    return styles

end


local names
local neigbor_info, clone_info
local curr_neighbors
local obj

local concat_elements = function(t1,t2)
    if t2 == nil then return t1 end
    local t3 = {}
    for k,v in pairs(t2) do
        t3[k]=v
    end
    --t1 has precendence over t2
    for k,v in pairs(t1) do
        t3[k]=v
    end
    return t3
end


local obj_to_elements_map = {}
local construct


construct = function(t)

    if type(t) ~= "table" then

        return error("Expects table, received "..type(t),2)

    end

    local elements
    if t.type == "LayoutManager" then
        elements = {}
        for i,row in ipairs(t.cells) do
            for j,v in ipairs(row) do
                if v then -- v == false when no item was specified
                    t.cells[i][j] = construct(v)
    
                    elements[t.cells[i][j].name] = t.cells[i][j]
                    elements = concat_elements(elements,obj_to_elements_map[t.cells[i][j]])
                end
            end
        end
    elseif t.type == "ListManager" then
        elements = {}
        for i,v in ipairs(t.cells) do

            if v then -- v == false when no item was specified
                t.cells[i] = construct(v)
    
                elements[t.cells[i].name] = t.cells[i]
                elements = concat_elements(elements,obj_to_elements_map[t.cells[i]])
            end
        end
    elseif t.type == "MenuButton" then
        elements = {}
        for i,v in ipairs(t.items) do

            if v then -- v == false when no item was specified
                t.items[i] = construct(v)
    
                elements[t.items[i].name] = t.items[i]
                elements = concat_elements(elements,obj_to_elements_map[t.items[i]])
            end
        end
    elseif t.children then
        elements = {}
        for i,v in ipairs(t.children) do


            t.children[i] = construct(v)
            --print ( t.children[i] )
            elements[t.children[i].name] = t.children[i]
            elements = concat_elements(elements,obj_to_elements_map[t.children[i]])

        end
    end
    curr_neighbors = t.neighbors
    --obj = WL[t.type] and WL[t.type](t) or
    obj = _G[t.type] and _G[t.type](t) or WL[t.type] and WL[t.type](t) or

        error("Received invalid type: "..t.type)
    
    names[obj.name] = obj
    neigbor_info[obj] = curr_neighbors
    obj_to_elements_map[obj] = elements
    if t.type == "Widget_Clone" then
        clone_info[obj] = t.source
    end
    return obj

end


function load_layer(str)

    names = {}
    neigbor_info = {}
    clone_info = {}
    
    
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
    --layer.elements = names
    --layer.elements = {}

    for i,v in ipairs(layer.children) do
        if string.find(v.name, "Layer") then
            v.elements = obj_to_elements_map[v]
            --layer.elements[ string.gsub( v.name, " ", "_" ) ] = v
        end
    end
    
    for clone,src in pairs(clone_info) do
        clone.source = names[src]
    end
    
    for obj,neighbors in pairs(neigbor_info) do

        for k,v in pairs(neighbors) do

            obj.neighbors[k] = names[v]

        end
    end

    layer.objects = names
    return layer
end



function transit_to (screens, nextScreen, effect)
	
    local img_t = {}
    table.insert(img_t, json:parse(screens))

    if nextScreen == nil then
        currentScreen = img_t[1]["currentScreenName"]
        for i, j in ipairs (img_t[1][currentScreen]) do
            screen:find_child(j):show()
        end 
        return
    end
        
	if effect == "fade" then 

    	local fade_timeline = Timeline ()

    	fade_timeline.duration = 1000 -- progress duration 
    	fade_timeline.direction = "FORWARD"
    	fade_timeline.loop = false

        for i, j in ipairs (img_t[1][nextScreen]) do
            screen:find_child(j).opacity = 0
            screen:find_child(j):show()
        end 

     	function fade_timeline.on_new_frame(t, m, p)
            for i, j in ipairs (img_t[1][currentScreen]) do
                screen:find_child(j).opacity = (1-p) * 255 
            end 
            for i, j in ipairs (img_t[1][nextScreen]) do
                screen:find_child(j).opacity = p * 255
            end 
     	end  

     	function fade_timeline.on_completed()
            for i, j in ipairs (img_t[1][currentScreen]) do
                screen:find_child(j):hide()
            end 
            for i, j in ipairs (img_t[1][nextScreen]) do
                screen:find_child(j):show()
                screen:find_child(j).opacity = 255
            end 
            currentScreen = nextScreen
     	end 

		fade_timeline:start()

	else 
        for i, j in ipairs (img_t[1][currentScreen]) do
            screen:find_child(j):hide()
        end 
        for i, j in ipairs (img_t[1][nextScreen]) do
            screen:find_child(j):show()
        end 
        currentScreen = nextScreen
	end 
	screen:grab_key_focus()
end 


