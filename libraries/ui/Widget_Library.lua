
local pwd = (where_am_i()).file

local i = string.find(string.reverse(pwd),'/')

pwd = i == nil and "" or string.sub( pwd ,1,pwd:len() - i+1)

local WL_ENV = setmetatable({},{__index = _G})

local WL = {}
local WL_EXT = {}

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


--print("going")
for i,dep in ipairs(core_dependencies) do    loadfile(pwd..dep)(WL_EXT,WL_ENV)    end

--_ENV = _G
print(WL_ENV.Widget)
_G.Widget = WL_ENV.Widget
print(_G.Widget)
--dumptable(WL_ENV)
--------------------------------------------------------------------------

local loaded = { }

local widget_dependencies = {
    ArrowPane        = {"Button","ClippingRegion","LayoutManager","ArrowPane"},
    Button           = {"Button"},
    ButtonPicker     = {"Button","LayoutManager","ButtonPicker"},
    ClippingRegion   = {"ClippingRegion"},
    DialogBox        = {"DialogBox"},
    ListManager      = {"LayoutManager"},
    LayoutManager    = {"LayoutManager"},
    MenuButton       = {"ToggleButton","LayoutManager","MenuButton"},
    NineSlice        = {"LayoutManager","NineSlice"},
    OrbittingDots    = {"OrbittingDots"},
    ProgressBar      = {"ProgressBar"},
    ProgressSpinner  = {"ProgressSpinner"},
    RadioButtonGroup = {"ToggleButton","RadioButtonGroup"},
    ScrollPane       = {"Slider","ClippingRegion","LayoutManager","ScrollPane"},
    Slider           = {"NineSlice","Slider"},
    TabBar           = {"RadioButtonGroup","ArrowPane","TabBar"},
    TextInput        = {"NineSlice","TextInput"},
    ToastAlert       = {"DialogBox","ToastAlert"},
    ToggleButton     = {"Button","ToggleButton","RadioButtonGroup"},
}

local    load_dependencies
function load_dependencies(w)
    
    if loaded[w] then return end
    loaded[w] = true
    for i,dep in ipairs(widget_dependencies[w]) do
        
        if dep ~= w then   load_dependencies(dep)   end
        
    end
    
    --[[ TODO: get working
    for k,v in pairs(dofile(pwd..w.."/"..w..".lua")) do
        loaded[k] = v
    end
    --]]
    print("dofile('"..pwd..w.."/"..w..".lua')")
    local f, err = loadfile(pwd..w.."/"..w..".lua")
    print(f,err)
    f(WL_EXT,WL_ENV)
    --loaded[w] = WL[w]
    
    --return loaded[w]
end

local launch_recursive_load = function(w)
    
    for i,dep in ipairs(widget_dependencies[w]) do
        
        load_dependencies(dep)
        
    end
    
    return  WL[w] -- TODO change to loaded
end

--------------------------------------------------------------------------

setmetatable(WL,{
    __index = function(t,k)
        
        return WL_EXT[k] or widget_dependencies[k] ~= nil and launch_recursive_load(k) or nil
        
    end,
    __newindex =  function(t,k,v)
        
        print("attempted to set index '",k,"' to '",v,"'")
        
    end,
})

return WL