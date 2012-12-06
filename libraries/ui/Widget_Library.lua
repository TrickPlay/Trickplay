
--pwd equals the path to "Widget_Library.lua"
local pwd = (where_am_i()).file

--i equals the index of the last '\', counting from the back
local i = string.find(string.reverse(pwd),'/')

--if there were no '\', then the relative path is the empty string
--otherwise the pwd equals the path with "Widget_Library.lua" removed
pwd = i == nil and "" or string.sub( pwd ,1,pwd:len() - i+1)

--------------------------------------------------------------------------

--This table captures all of the globals created by the widget
--so that all of those variables remain internal and so that
--the global table doesn't become polluted with it
local WL_ENV = setmetatable({},{__index = _G})
--This table will hold everything that will be exposed to users
local WL_EXT = {}

WL_ENV.default_spritesheet = SpriteSheet{
    map = "skin.json"
}

dumptable(WL_ENV.default_spritesheet:get_ids())

local core_dependencies = {
    "__UTILITIES/AppVerbosity.lua",
    "__UTILITIES/OverrideMetatable.lua",
    "__UTILITIES/TypeChecking.lua",
    "__UTILITIES/TableManipulation.lua",
    "__UTILITIES/Canvas.lua",
    "__UTILITIES/Misc.lua",
    "__UTILITIES/ListManagement.lua",
    "__UTILITIES/Object.lua",
    "__CORE/ColorScheme.lua",
    "__CORE/Style.lua",
    "__CORE/Widget.lua",
}

local load = function(file)
    
    local f, err = loadfile(file)
    
    --this prints out any syntax errors in the file
    if err then error(err) end
    
    --call the loaded file
    f(WL_EXT,WL_ENV)
    
end

for i,dep in ipairs(core_dependencies) do    load(pwd..dep)    end

--------------------------------------------------------------------------

local widget_dependencies = {
    ArrowPane        = {"Button","ClippingRegion","LayoutManager","ArrowPane"},
    Button           = {"Button"},
    ButtonPicker     = {"Button","LayoutManager","ButtonPicker"},
    CheckBox         = {"Button","ToggleButton","CheckBox"},
    CheckBoxGroup    = {"ToggleButton","CheckBox"},
    ClippingRegion   = {"ClippingRegion"},
    DialogBox        = {"DialogBox"},
    ListManager      = {"LayoutManager"},
    LayoutManager    = {"LayoutManager"},
    MenuButton       = {"ToggleButton","LayoutManager","MenuButton"},
    --NineSlice        = {"LayoutManager","NineSlice"},
    OrbittingDots    = {"OrbittingDots"},
    ProgressBar      = {"ProgressBar"},
    ProgressSpinner  = {"ProgressSpinner"},
    RadioButton      = {"Button","ToggleButton","RadioButton"},
    RadioButtonGroup = {"ToggleButton","RadioButton"},
    ScrollPane       = {"Slider","ClippingRegion","LayoutManager","ScrollPane"},
    Slider           = {"Slider"},
    TabBar           = {"RadioButton","ArrowPane","TabBar"},
    TextInput        = {"TextInput"},
    ToastAlert       = {"DialogBox","ToastAlert"},
    ToggleButton     = {"Button","ToggleButton","RadioButton"},
}

local    load_dependencies
function load_dependencies(w)
    
    if WL_EXT[w] then return end
    
    -- setting true is just a placeholder to prevent redundant calls
    -- to load_dependencies() which results in stack overflow
    WL_EXT[w] = true 
    
    --recursively load all dependencies
    for i,dep in ipairs(widget_dependencies[w]) do
        
        if dep ~= w then   load_dependencies(dep)   end
        
    end
    
    load(pwd..w.."/"..w..".lua")
    
end

local launch_recursive_load = function(w)
    
    for i,dep in ipairs(widget_dependencies[w]) do
        
        load_dependencies(dep)
        
    end
    
    --returns the requested widget
    return  WL_EXT[w] 
end

--------------------------------------------------------------------------

--Interface
return setmetatable({},{
    __index = function(t,k)
        --WL_EXT[k]                = something that is already loaded
        --widget_dependencies[k]   = something that can be loaded
        --launch_recursive_load(k) = load that 'something'
        return WL_EXT[k] or widget_dependencies[k] ~= nil and launch_recursive_load(k) or nil
        
    end,
    __newindex =  function(t,k,v)
        
        error("attempted to set the Widget_Library's index '"..
            tostring(k).."' to '"..tostring(v).."'",2)
        
    end,
})