
WL = dofile('LIB/Widget/Widget_Library.lua') --Load widget library

local function ve_init(user_main)
local ve = {}

local color_scheme_uri = 'app/color_schemes.json'
local style_uri        = 'app/styles.json'
local layer_dir        = 'app/'

local color_schemes

local function load_color_schemes()

    local input = color_scheme_json 

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


function ve.load_styles(str)


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

--------------------------------------------------------------------------------

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

local deep_copy
deep_copy = function(old_t)
    local new_t = {}

    for k,v in pairs(old_t) do
        if type(v) == "table" then
            v = deep_copy(v)
        end
        new_t[k]=v
    end

    return new_t
end

local construct_internal
construct_internal = function(t)

    if type(t) ~= "table" then

        return error("Expects table, received "..type(t),2)

    end

    local elements
    if t.type == "LayoutManager" then
        elements = {}
        for i,row in ipairs(t.cells) do
            for j,v in ipairs(row) do
                if v then -- v == false when no item was specified
                    t.cells[i][j] = construct_internal(v)
    
                    elements[t.cells[i][j].name] = t.cells[i][j]
                    elements = concat_elements(elements,obj_to_elements_map[t.cells[i][j]])
                end
            end
        end
    elseif t.type == "ListManager" then
        elements = {}
        for i,v in ipairs(t.cells) do

            if v then -- v == false when no item was specified
                t.cells[i] = construct_internal(v)
    
                elements[t.cells[i].name] = t.cells[i]
                elements = concat_elements(elements,obj_to_elements_map[t.cells[i]])
            end
        end
    elseif t.type == "MenuButton" then
        elements = {}
        for i,v in ipairs(t.items) do

            if v then -- v == false when no item was specified
                t.items[i] = construct_internal(v)
    
                elements[t.items[i].name] = t.items[i]
                elements = concat_elements(elements,obj_to_elements_map[t.items[i]])
            end
        end
    elseif t.children then
        elements = {}
        for i,v in ipairs(t.children) do

            t.children[i] = construct_internal(v)
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

local construct
function construct(t)
    
    return construct_internal(deep_copy(t))
end

--------------------------------------------------------------------------------

function ve.load_json(str) -- json string 
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

    return layer 
end 

function ve.load_layer(name) -- layer table
    local layer
    local layer_t = ve.layer_t["children"][ve.layer_idx[name]]
    names = {}
    neigbor_info = {}
    clone_info = {}

    if  layer_t.realized == true then 
        print ("Layer is already realized.", 2) 
        return 
    end 

    --the setter for Widget_Group.children calls the appropriate
    --constructors when it receives an attributes table as an entry
    layer = construct(layer_t)

    if string.find(layer.name, "Layer") then
        layer.elements = obj_to_elements_map[layer]
    end

    for clone,src in pairs(clone_info) do
        clone.source = names[src]
    end

    for obj,neighbors in
        pairs(neigbor_info) do

        for k,v in
            pairs(neighbors) do
            obj.neighbors[k] = names[v]
        end
    end

    for k,v in pairs(names) do ve.objects[k] = v end
    ve.layer_t["children"][ve.layer_idx[name]].realized = true 
    if user_main then 
        layer = dofile(string.lower(name)..'.lua')(layer,ve)
    end

    return layer
end

function ve.unload_layer(name)
    if  ve.layer_t["children"][ve.layer_idx[name]].realized == false then 
        print (name.." is already unrealized.", 2) 
        return 
    end 
    ve.layer_t["children"][ve.layer_idx[name]].realized = false 
end

function ve.org_load_layer(str) 
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
    layer = construct_internal(layer)
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

--------------------------------------------------------------------------------

ve.screens = nil
--ve.layerGroup = WL.Widget_Group{}
ve.objects = {}
--ve.layerGroup.objects = {}

local currentScreen 

function ve.transit_to (nextScreen, effect)
	
    local img_t = {}
    local layer
    table.insert(img_t, json:parse(ve.screens))

    if nextScreen == nil then
        currentScreen = img_t[1]["currentScreenName"]
        for i, j in ipairs (img_t[1][currentScreen]) do
            layer = ve.load_layer(j)
            screen:add(layer)
        end 
        return
    end
        
	if effect == "fade" then 

    	local fade_timeline = Timeline ()

    	fade_timeline.duration = 1000 -- progress duration 
    	fade_timeline.direction = "FORWARD"
    	fade_timeline.loop = false

        for i, j in ipairs (img_t[1][nextScreen]) do
            layer = ve.load_layer(j)
            if layer then 
                layer.opacity = 0
                screen:add(layer)
            end
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
                layer = screen:find_child(j)
                layer:unparent()
                layer = nil 
                ve.unload_layer(j) 
            end 
            for i, j in ipairs (img_t[1][nextScreen]) do
                screen:find_child(j).opacity = 255
            end 
            currentScreen = nextScreen
     	end 

		fade_timeline:start()

	else 
        for i, j in ipairs (img_t[1][currentScreen]) do
            layer = screen:find_child(j)
            layer:hide()
            layer:unparent()
            ve.unload_layer(layer)
        end 
        for i, j in ipairs (img_t[1][nextScreen]) do
            layer = ve.load_layer(j)
            if user_main then 
                layer = dofile(string.lower(j)..'.lua')(layer,ve)
            end
            screen:add(layer)
        end 
        currentScreen = nextScreen
	end 
	screen:grab_key_focus()
end 

--------------------------------------------------------------------------------

function ve.ve_main()

    local layers_file = 'screens/layers.json'
    local styles_file = 'screens/styles.json'
    local screens_file = 'screens/screens.json'
    local image_path = 'assets/images/'

    local style = readfile(styles_file)
    style = string.sub(style, 2, string.len(style)-1)
    ve.load_styles(style)

    local layer = readfile(layers_file)
    layer = string.sub(layer, 2, string.len(layer)-1)

    ve.screens = readfile(screens_file)
    ve.screens = string.sub(ve.screens, 2, string.len(ve.screens)-1)
    
    ve.layer_t = json:parse(layer)
    ve.layer_idx = {}
    for i, j in ipairs(ve.layer_t["children"]) do 
        if string.find(j.name, 'Layer') then 
            j.realized = false
            ve.layer_idx[j.name] = i
        end
    end

    if user_main then 
        dofile('event.lua')(ve)
        user_main()
    end 
    controllers:start_pointer()
end

--------------------------------------------------------------------------------

if user_main then 
    dolater(ve.ve_main)
end 

return ve

end 

return ve_init
