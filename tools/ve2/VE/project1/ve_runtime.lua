
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end
if not BUTTON            then dofile("Button/Button.lua")                 end


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

--------------------------------------------------------------------------------

local constructors = {
    Group     = Group,
    Image     = Image,
    Rectangle = Rectangle,
    Clone     = Clone,
    Text      = Text,
    Button    = Button,
}
print("Button",Button)
local construct

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
        
        error("Received invalid type '"..t.type.."'")
    
end

--------------------------------------------------------------------------------

load_layer = function(layer_name)
    
    if type(layer_name) ~= "string" then
        
        error("'load_layer()' expects type 'string'. Recieved "..type(layer_name),2)
        
    end
    
    --the first time this function is called, styles will get set up
    if not styles then load_styles() end
    
    --load the json
    local layer = readfile(layer_name..".json")
    
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
        --print(v.name,v.style.name)
        local current_object = construct(v)
        
        if type(current_object) ~= "userdata" and not current_object.__types__.actor then
            
            error(i.."-th entry in the '"..layer_name.."' layer is not a UIElement",2)
            
        end
        
        if type(current_object.name) ~= "string" then
            
            error(i.."-th entry in the '"..layer_name.."' layer does not have a name",2)
            
        end
        
        layer_object.elements[ string.gsub( current_object.name, " ", "_" ) ] = current_object
        --print(current_object.name,current_object.style.name)
        layer_object:add(  current_object  )
        
    end
    
    loadfile(layer_name.."_user.lua")(layer_object)

    return layer_object
    
end
