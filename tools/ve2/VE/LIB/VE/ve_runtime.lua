
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
            print ( t.children[i] )
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

    return layer
end
