STYLE = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local default_fill_colors = {
    default    = {  0,  0,  0},
    focus      = {  0,  0,  0,  0},
    activation = {155,155,155},
    selection  = {  0,  0,155},
} 
local default_arrow_colors = {
    default    = {255,255,255},
    focus      = {255,255,255},
    activation = {255,  0,  0},
    selection  = {  0,  0,155},
} 
local default_border_colors = {
    default    = {255,255,255},
    focus      = {255,  0,  0},
    activation = {255,  0,  0},
    selection  = {  0,  0,  0,  0},
} 
local default_text_colors = {
    default    = {255,255,255},
    focus      = {255,  0,  0},
    activation = {255,  0,  0},
    focus      = {255,  0,  0},
}

local func_upval
local __newindex = function(meta_setters)
    
    return function(t,k,v)
        
        func_upval = meta_setters[k]
        
        return func_upval and func_upval(v)
        
    end
    
end

local __index = function(meta_getters)
    
    return function(t,k)
        
        func_upval = meta_getters[k]
        
        return func_upval and func_upval()
        
    end
    
end



--------------------------------------------------------------------------------

ArrowStyle = function(parameters)
    
	--input is either nil or a table
	parameters = is_table_or_nil("ArrowStyle",parameters)
    
    local instance, size, offset
    local colors = ColorScheme(default_arrow_colors)
    
    local  meta_setters = {
        size   = function(v) size   = v  end,
        offset = function(v) offset = v  end,
        colors = function(v) colors:set(v or {}) end,
    }
    local meta_getters = {
        size   = function() return size   or 20 end,
        offset = function() return offset or 10 end,
        colors = function() return colors       end,
        type   = function() return "ARROWSTYLE" end,
        attributes = function() 
            return {
                size   = instance.size,
                offset = instance.offset,
                colors = colors.attributes,
            }
        end,
    }
    
    instance = setmetatable(
        {
            to_json = function()
                return json:stringify{
                    size   = instance.size,
                    offset = instance.offset,
                    colors = instance.colors.attributes,
                }
            end,
        },
        {
            __index    = __index(meta_getters)
        }
    )
    set_up_subscriptions( instance, getmetatable(instance),
        
        __newindex(meta_setters),
        
        function(self,t)
            
            if type(t) ~= "table" then
                error("Expects a table. Received "..type(t),2)
            end
            
            for k, v in pairs(t) do
                self[k] = v
            end
            
        end
    )
    
    --can't use a table, need to ensure some properties receive a nil in order
    --to trigger the default condition
    instance.size   = parameters.size
    instance.offset = parameters.offset
    instance.colors = parameters.colors
    colors:subscribe_to( nil, function(t) instance:notify({colors=t}) end )
    
    return instance
    
end

--------------------------------------------------------------------------------

BorderStyle = function(parameters)
    
	parameters = is_table_or_nil("BorderStyle",parameters)
    
    
    local instance, width, corner_radius, name
    local colors = ColorScheme(default_border_colors)
    
    local  meta_setters = {
        width         = function(v) width         = v   end,
        corner_radius = function(v) corner_radius = v   end,
        colors        = function(v) colors:set(v or {}) end,
    }
    local meta_getters = {
        width         = function() return width         or 2  end,
        corner_radius = function() return corner_radius or 10 end,
        colors        = function() return colors              end,
        type          = function() return "BORDERSTYLE"       end,
        attributes    = function() 
            return {
                width         = instance.width,
                corner_radius = instance.corner_radius,
                colors        = colors.attributes,
            }
        end,
    }
    
    instance = setmetatable(
        {
            to_json = function()
                return json:stringify{
                    width         = instance.width,
                    corner_radius = instance.corner_radius,
                    colors        = instance.colors.name,
                }
            end,
        },
        {
            __index    = __index(meta_getters),
        }
    )
    set_up_subscriptions( instance, getmetatable(instance),
        
        __newindex(meta_setters),
        
        function(self,t)
            
            if type(t) ~= "table" then
                error("Expects a table. Received "..type(t),2)
            end
            
            for k, v in pairs(t) do
                self[k] = v
            end
            
        end
    )
    
    --can't use a table, need to ensure some properties receive a nil in order
    --to trigger the default condition
    instance.width         = parameters.width
    instance.corner_radius = parameters.corner_radius
    instance.colors        = parameters.colors
    colors:subscribe_to( nil, function(t) instance:notify({colors=t}) end )
    
    return instance
    
end

--------------------------------------------------------------------------------

TextStyle = function(parameters)
    
	parameters = is_table_or_nil("TextStyle",parameters)
    local colors = ColorScheme(default_text_colors)
    local properties = {
        font  = "Sans 40px",
        alignment = "CENTER",
        justify = true,
        wrap    = true,
        x_offset = 0,
        y_offset = 0,
    }
    
    local instance
    instance = {
        set = function(_,parameters)
            
            for k,v in pairs(parameters) do
                
                instance[k] = v
                
            end
            
        end,
        get_table  = function() return properties end,
        to_json = function()
            local t = {}
            
            for property, value in pairs(instance:get_table()) do
                t[property] = value
            end
            t.color  = nil
            t.name   = instance.name
            t.colors = obj.colors.attributes
            
            return json:stringify(t)
        end,
    }
    
    
    local meta_setters = {
        colors    = function(v) 
            
            colors:set(v or {})
            
            return true
            
        end,
    }
    
    local meta_getters = {
        colors = function() return colors end,
        attributes = function() 
            local t = recursive_overwrite({}, properties)
            t.colors = colors.attributes
            return t 
        end,
    }
    
    setmetatable(
        
        instance,
        
        {
            
            __index    = function(t,k)
                
                func_upval = meta_getters[k]
                
                if func_upval then return func_upval()
                else return properties[k] end
                
            end
            
        }
    )
    set_up_subscriptions( instance, getmetatable(instance),
        
        function(t,k,v)
            
            func_upval = meta_setters[k]
            
            if      func_upval then func_upval(v)
            elseif k ~= "type" then properties[k] = v end
            
        end,
        
        function(self,parameters)
            
            for k,v in pairs(parameters) do
                
                self[k] = v
                
            end
            
        end
    )
    
    if parameters.colors == nil then instance.colors = nil end
    instance:set(parameters)
    colors:subscribe_to( nil, function(t) instance:notify({colors=t}) end )
    
    --properties.color = parameters.color or instance.colors.default
    
    return instance
    
end

--------------------------------------------------------------------------------

local all_styles =  setmetatable({},{__mode = 'v'})

get_all_styles = function()
    
    local t = {}
    
    collectgarbage("collect")
    
    for name,obj in pairs(all_styles) do
        
        t[name]         = {
            name        = obj.name,
            --arrow       = obj.arrow.attributes,
            --border      = obj.border.attributes,
            text        = obj.text.attributes,
            --fill_colors = obj.fill_colors.attributes,
            spritesheet_map = obj.spritesheet_map
        }
    end
    
    return json:stringify(t)
    
end



local global_style_subscriptions = {}
clone_sources = 
    screen:find_child("Widget Library Clone Sources - DO NOT REMOVE or SHOW") or 
    Group{       name="Widget Library Clone Sources - DO NOT REMOVE or SHOW"}
if clone_sources.parent == nil then screen:add(clone_sources) end
clone_sources:hide()
states = {"default","focus","activation","selection"}

local fallbacks = {
    -- key falls back to its value
    -- "key" = "value"
    
    --"ArrowPane/arrow-down/activation.png"
    --"ArrowPane/arrow-down/default.png"
    --"ArrowPane/arrow-down/focus.png"
    --"ArrowPane/arrow-left/activation.png"
    --"ArrowPane/arrow-left/default.png"
    --"ArrowPane/arrow-left/focus.png"
    --"ArrowPane/arrow-right/activation.png"
    --"ArrowPane/arrow-right/default.png"
    --"ArrowPane/arrow-right/focus.png"
    --"ArrowPane/arrow-up/activation.png"
    --"ArrowPane/arrow-up/default.png"
    --"ArrowPane/arrow-up/focus.png"
    ["ArrowPane/default/c.png"]  = "Button/default/c.png",
    ["ArrowPane/default/e.png"]  = "Button/default/e.png",
    ["ArrowPane/default/n.png"]  = "Button/default/n.png",
    ["ArrowPane/default/ne.png"] = "Button/default/ne.png",
    ["ArrowPane/default/nw.png"] = "Button/default/nw.png",
    ["ArrowPane/default/s.png"]  = "Button/default/s.png",
    ["ArrowPane/default/se.png"] = "Button/default/se.png",
    ["ArrowPane/default/sw.png"] = "Button/default/sw.png",
    ["ArrowPane/default/w.png"]  = "Button/default/w.png",
    ["Button/activation/c.png"]  = "Button/focus/c.png",
    ["Button/activation/e.png"]  = "Button/focus/e.png",
    ["Button/activation/n.png"]  = "Button/focus/n.png",
    ["Button/activation/ne.png"] = "Button/focus/ne.png",
    ["Button/activation/nw.png"] = "Button/focus/nw.png",
    ["Button/activation/s.png"]  = "Button/focus/s.png",
    ["Button/activation/se.png"] = "Button/focus/se.png",
    ["Button/activation/sw.png"] = "Button/focus/sw.png",
    ["Button/activation/w.png"]  = "Button/focus/w.png",
    --"Button/default/c.png"
    --"Button/default/e.png"
    --"Button/default/n.png"
    --"Button/default/ne.png"
    --"Button/default/nw.png"
    --"Button/default/s.png"
    --"Button/default/se.png"
    --"Button/default/sw.png"
    --"Button/default/w.png"
    ["Button/focus/c.png"]       = "Button/default/c.png",
    ["Button/focus/e.png"]       = "Button/default/e.png",
    ["Button/focus/n.png"]       = "Button/default/n.png",
    ["Button/focus/ne.png"]      = "Button/default/ne.png",
    ["Button/focus/nw.png"]      = "Button/default/nw.png",
    ["Button/focus/s.png"]       = "Button/default/s.png",
    ["Button/focus/se.png"]      = "Button/default/se.png",
    ["Button/focus/sw.png"]      = "Button/default/sw.png",
    ["Button/focus/w.png"]       = "Button/default/w.png",
    --"ButtonPicker/arrow-down/activation.png"
    --"ButtonPicker/arrow-down/default.png"
    --"ButtonPicker/arrow-down/focus.png"
    --"ButtonPicker/arrow-left/activation.png"
    --"ButtonPicker/arrow-left/default.png"
    --"ButtonPicker/arrow-left/focus.png"
    --"ButtonPicker/arrow-right/activation.png"
    --"ButtonPicker/arrow-right/default.png"
    --"ButtonPicker/arrow-right/focus.png"
    --"ButtonPicker/arrow-up/activation.png"
    --"ButtonPicker/arrow-up/default.png"
    --"ButtonPicker/arrow-up/focus.png"
    ["ButtonPicker/default/c.png"]  = "Button/default/c.png",
    ["ButtonPicker/default/e.png"]  = "Button/default/e.png",
    ["ButtonPicker/default/n.png"]  = "Button/default/n.png",
    ["ButtonPicker/default/ne.png"] = "Button/default/ne.png",
    ["ButtonPicker/default/nw.png"] = "Button/default/nw.png",
    ["ButtonPicker/default/s.png"]  = "Button/default/s.png",
    ["ButtonPicker/default/se.png"] = "Button/default/se.png",
    ["ButtonPicker/default/sw.png"] = "Button/default/sw.png",
    ["ButtonPicker/default/w.png"]  = "Button/default/w.png",
    ["CheckBox/activation/c.png"]   = "ToggleButton/activation/c.png",
    ["CheckBox/activation/e.png"]   = "ToggleButton/activation/e.png",
    ["CheckBox/activation/n.png"]   = "ToggleButton/activation/n.png",
    ["CheckBox/activation/ne.png"]  = "ToggleButton/activation/ne.png",
    ["CheckBox/activation/nw.png"]  = "ToggleButton/activation/nw.png",
    ["CheckBox/activation/s.png"]   = "ToggleButton/activation/s.png",
    ["CheckBox/activation/se.png"]  = "ToggleButton/activation/se.png",
    ["CheckBox/activation/sw.png"]  = "ToggleButton/activation/sw.png",
    ["CheckBox/activation/w.png"]   = "ToggleButton/activation/w.png",
    --"CheckBox/box-default.png"
    --"CheckBox/box-focus-selected.png"
    --"CheckBox/box-focus.png"
    --"CheckBox/box-selected.png"
    ["CheckBox/default/c.png"]   = "ToggleButton/default/c.png",
    ["CheckBox/default/e.png"]   = "ToggleButton/default/e.png",
    ["CheckBox/default/n.png"]   = "ToggleButton/default/n.png",
    ["CheckBox/default/ne.png"]  = "ToggleButton/default/ne.png",
    ["CheckBox/default/nw.png"]  = "ToggleButton/default/nw.png",
    ["CheckBox/default/s.png"]   = "ToggleButton/default/s.png",
    ["CheckBox/default/se.png"]  = "ToggleButton/default/se.png",
    ["CheckBox/default/sw.png"]  = "ToggleButton/default/sw.png",
    ["CheckBox/default/w.png"]   = "ToggleButton/default/w.png",
    ["CheckBox/focus/c.png"]   = "ToggleButton/focus/c.png",
    ["CheckBox/focus/e.png"]   = "ToggleButton/focus/e.png",
    ["CheckBox/focus/n.png"]   = "ToggleButton/focus/n.png",
    ["CheckBox/focus/ne.png"]  = "ToggleButton/focus/ne.png",
    ["CheckBox/focus/nw.png"]  = "ToggleButton/focus/nw.png",
    ["CheckBox/focus/s.png"]   = "ToggleButton/focus/s.png",
    ["CheckBox/focus/se.png"]  = "ToggleButton/focus/se.png",
    ["CheckBox/focus/sw.png"]  = "ToggleButton/focus/sw.png",
    ["CheckBox/focus/w.png"]   = "ToggleButton/focus/w.png",
    ["CheckBox/selection/c.png"]   = "ToggleButton/selection/c.png",
    ["CheckBox/selection/e.png"]   = "ToggleButton/selection/e.png",
    ["CheckBox/selection/n.png"]   = "ToggleButton/selection/n.png",
    ["CheckBox/selection/ne.png"]  = "ToggleButton/selection/ne.png",
    ["CheckBox/selection/nw.png"]  = "ToggleButton/selection/nw.png",
    ["CheckBox/selection/s.png"]   = "ToggleButton/selection/s.png",
    ["CheckBox/selection/se.png"]  = "ToggleButton/selection/se.png",
    ["CheckBox/selection/sw.png"]  = "ToggleButton/selection/sw.png",
    ["CheckBox/selection/w.png"]   = "ToggleButton/selection/w.png",
    ["ClippingRegion/default/c.png"]  = "Button/default/c.png",
    ["ClippingRegion/default/e.png"]  = "Button/default/e.png",
    ["ClippingRegion/default/n.png"]  = "Button/default/n.png",
    ["ClippingRegion/default/ne.png"] = "Button/default/ne.png",
    ["ClippingRegion/default/nw.png"] = "Button/default/nw.png",
    ["ClippingRegion/default/s.png"]  = "Button/default/s.png",
    ["ClippingRegion/default/se.png"] = "Button/default/se.png",
    ["ClippingRegion/default/sw.png"] = "Button/default/sw.png",
    ["ClippingRegion/default/w.png"]  = "Button/default/w.png",
    ["DialogBox/default/c.png"]  = "Button/default/c.png",
    ["DialogBox/default/e.png"]  = "Button/default/e.png",
    ["DialogBox/default/n.png"]  = "Button/default/n.png",
    ["DialogBox/default/ne.png"] = "Button/default/ne.png",
    ["DialogBox/default/nw.png"] = "Button/default/nw.png",
    ["DialogBox/default/s.png"]  = "Button/default/s.png",
    ["DialogBox/default/se.png"] = "Button/default/se.png",
    ["DialogBox/default/sw.png"] = "Button/default/sw.png",
    ["DialogBox/default/w.png"]  = "Button/default/w.png",
    --"DialogBox/seperator-h.png"
    ["MenuButton/activation/c.png"]   = "ToggleButton/activation/c.png",
    ["MenuButton/activation/e.png"]   = "ToggleButton/activation/e.png",
    ["MenuButton/activation/n.png"]   = "ToggleButton/activation/n.png",
    ["MenuButton/activation/ne.png"]  = "ToggleButton/activation/ne.png",
    ["MenuButton/activation/nw.png"]  = "ToggleButton/activation/nw.png",
    ["MenuButton/activation/s.png"]   = "ToggleButton/activation/s.png",
    ["MenuButton/activation/se.png"]  = "ToggleButton/activation/se.png",
    ["MenuButton/activation/sw.png"]  = "ToggleButton/activation/sw.png",
    ["MenuButton/activation/w.png"]   = "ToggleButton/activation/w.png",
    ["MenuButton/default/c.png"]   = "ToggleButton/default/c.png",
    ["MenuButton/default/e.png"]   = "ToggleButton/default/e.png",
    ["MenuButton/default/n.png"]   = "ToggleButton/default/n.png",
    ["MenuButton/default/ne.png"]  = "ToggleButton/default/ne.png",
    ["MenuButton/default/nw.png"]  = "ToggleButton/default/nw.png",
    ["MenuButton/default/s.png"]   = "ToggleButton/default/s.png",
    ["MenuButton/default/se.png"]  = "ToggleButton/default/se.png",
    ["MenuButton/default/sw.png"]  = "ToggleButton/default/sw.png",
    ["MenuButton/default/w.png"]   = "ToggleButton/default/w.png",
    ["MenuButton/focus/c.png"]   = "ToggleButton/focus/c.png",
    ["MenuButton/focus/e.png"]   = "ToggleButton/focus/e.png",
    ["MenuButton/focus/n.png"]   = "ToggleButton/focus/n.png",
    ["MenuButton/focus/ne.png"]  = "ToggleButton/focus/ne.png",
    ["MenuButton/focus/nw.png"]  = "ToggleButton/focus/nw.png",
    ["MenuButton/focus/s.png"]   = "ToggleButton/focus/s.png",
    ["MenuButton/focus/se.png"]  = "ToggleButton/focus/se.png",
    ["MenuButton/focus/sw.png"]  = "ToggleButton/focus/sw.png",
    ["MenuButton/focus/w.png"]   = "ToggleButton/focus/w.png",
    ["MenuButton/selection/c.png"]   = "ToggleButton/selection/c.png",
    ["MenuButton/selection/e.png"]   = "ToggleButton/selection/e.png",
    ["MenuButton/selection/n.png"]   = "ToggleButton/selection/n.png",
    ["MenuButton/selection/ne.png"]  = "ToggleButton/selection/ne.png",
    ["MenuButton/selection/nw.png"]  = "ToggleButton/selection/nw.png",
    ["MenuButton/selection/s.png"]   = "ToggleButton/selection/s.png",
    ["MenuButton/selection/se.png"]  = "ToggleButton/selection/se.png",
    ["MenuButton/selection/sw.png"]  = "ToggleButton/selection/sw.png",
    ["MenuButton/selection/w.png"]   = "ToggleButton/selection/w.png",
    --"OrbitingDots/icon.png"
    ["ProgressBar/empty/c.png"]  = "Button/default/c.png",
    ["ProgressBar/empty/e.png"]  = "Button/default/e.png",
    ["ProgressBar/empty/n.png"]  = "Button/default/n.png",
    ["ProgressBar/empty/ne.png"] = "Button/default/ne.png",
    ["ProgressBar/empty/nw.png"] = "Button/default/nw.png",
    ["ProgressBar/empty/s.png"]  = "Button/default/s.png",
    ["ProgressBar/empty/se.png"] = "Button/default/se.png",
    ["ProgressBar/empty/sw.png"] = "Button/default/sw.png",
    ["ProgressBar/empty/w.png"]  = "Button/default/w.png",
    ["ProgressBar/filled/c.png"] = "Button/focus/c.png",
    ["ProgressBar/filled/e.png"] = "Button/focus/e.png",
    ["ProgressBar/filled/n.png"] = "Button/focus/n.png",
    ["ProgressBar/filled/ne.png"] = "Button/focus/ne.png",
    ["ProgressBar/filled/nw.png"] = "Button/focus/nw.png",
    ["ProgressBar/filled/s.png"]  = "Button/focus/s.png",
    ["ProgressBar/filled/se.png"] = "Button/focus/se.png",
    ["ProgressBar/filled/sw.png"] = "Button/focus/sw.png",
    ["ProgressBar/filled/w.png"]  = "Button/focus/w.png",
    --"ProgressSpinner/icon.png"
    ["RadioButton/activation/c.png"]   = "ToggleButton/activation/c.png",
    ["RadioButton/activation/e.png"]   = "ToggleButton/activation/e.png",
    ["RadioButton/activation/n.png"]   = "ToggleButton/activation/n.png",
    ["RadioButton/activation/ne.png"]  = "ToggleButton/activation/ne.png",
    ["RadioButton/activation/nw.png"]  = "ToggleButton/activation/nw.png",
    ["RadioButton/activation/s.png"]   = "ToggleButton/activation/s.png",
    ["RadioButton/activation/se.png"]  = "ToggleButton/activation/se.png",
    ["RadioButton/activation/sw.png"]  = "ToggleButton/activation/sw.png",
    ["RadioButton/activation/w.png"]   = "ToggleButton/activation/w.png",
    ["RadioButton/default/c.png"]   = "ToggleButton/default/c.png",
    ["RadioButton/default/e.png"]   = "ToggleButton/default/e.png",
    ["RadioButton/default/n.png"]   = "ToggleButton/default/n.png",
    ["RadioButton/default/ne.png"]  = "ToggleButton/default/ne.png",
    ["RadioButton/default/nw.png"]  = "ToggleButton/default/nw.png",
    ["RadioButton/default/s.png"]   = "ToggleButton/default/s.png",
    ["RadioButton/default/se.png"]  = "ToggleButton/default/se.png",
    ["RadioButton/default/sw.png"]  = "ToggleButton/default/sw.png",
    ["RadioButton/default/w.png"]   = "ToggleButton/default/w.png",
    ["RadioButton/focus/c.png"]   = "ToggleButton/focus/c.png",
    ["RadioButton/focus/e.png"]   = "ToggleButton/focus/e.png",
    ["RadioButton/focus/n.png"]   = "ToggleButton/focus/n.png",
    ["RadioButton/focus/ne.png"]  = "ToggleButton/focus/ne.png",
    ["RadioButton/focus/nw.png"]  = "ToggleButton/focus/nw.png",
    ["RadioButton/focus/s.png"]   = "ToggleButton/focus/s.png",
    ["RadioButton/focus/se.png"]  = "ToggleButton/focus/se.png",
    ["RadioButton/focus/sw.png"]  = "ToggleButton/focus/sw.png",
    ["RadioButton/focus/w.png"]   = "ToggleButton/focus/w.png",
    --"RadioButton/radio-default.png"
    --"RadioButton/radio-focus-selected.png"
    --"RadioButton/radio-focus.png"
    --"RadioButton/radio-selected.png"
    ["RadioButton/selection/c.png"]   = "ToggleButton/selection/c.png",
    ["RadioButton/selection/e.png"]   = "ToggleButton/selection/e.png",
    ["RadioButton/selection/n.png"]   = "ToggleButton/selection/n.png",
    ["RadioButton/selection/ne.png"]  = "ToggleButton/selection/ne.png",
    ["RadioButton/selection/nw.png"]  = "ToggleButton/selection/nw.png",
    ["RadioButton/selection/s.png"]   = "ToggleButton/selection/s.png",
    ["RadioButton/selection/se.png"]  = "ToggleButton/selection/se.png",
    ["RadioButton/selection/sw.png"]  = "ToggleButton/selection/sw.png",
    ["RadioButton/selection/w.png"]   = "ToggleButton/selection/w.png",
    ["ScrollPane/default/c.png"]  = "Button/default/c.png",
    ["ScrollPane/default/e.png"]  = "Button/default/e.png",
    ["ScrollPane/default/n.png"]  = "Button/default/n.png",
    ["ScrollPane/default/ne.png"] = "Button/default/ne.png",
    ["ScrollPane/default/nw.png"] = "Button/default/nw.png",
    ["ScrollPane/default/s.png"]  = "Button/default/s.png",
    ["ScrollPane/default/se.png"] = "Button/default/se.png",
    ["ScrollPane/default/sw.png"] = "Button/default/sw.png",
    ["ScrollPane/default/w.png"]  = "Button/default/w.png",
    ["ScrollPane/grip/default/c.png"]  = "Slider/grip/default/c.png",
    ["ScrollPane/grip/default/e.png"]  = "Slider/grip/default/e.png",
    ["ScrollPane/grip/default/n.png"]  = "Slider/grip/default/n.png",
    ["ScrollPane/grip/default/ne.png"] = "Slider/grip/default/ne.png",
    ["ScrollPane/grip/default/nw.png"] = "Slider/grip/default/nw.png",
    ["ScrollPane/grip/default/s.png"]  = "Slider/grip/default/s.png",
    ["ScrollPane/grip/default/se.png"] = "Slider/grip/default/se.png",
    ["ScrollPane/grip/default/sw.png"] = "Slider/grip/default/sw.png",
    ["ScrollPane/grip/default/w.png"]  = "Slider/grip/default/w.png",
    ["ScrollPane/grip/focus/c.png"]  = "Slider/grip/focus/c.png",
    ["ScrollPane/grip/focus/e.png"]  = "Slider/grip/focus/e.png",
    ["ScrollPane/grip/focus/n.png"]  = "Slider/grip/focus/n.png",
    ["ScrollPane/grip/focus/ne.png"] = "Slider/grip/focus/ne.png",
    ["ScrollPane/grip/focus/nw.png"] = "Slider/grip/focus/nw.png",
    ["ScrollPane/grip/focus/s.png"]  = "Slider/grip/focus/s.png",
    ["ScrollPane/grip/focus/se.png"] = "Slider/grip/focus/se.png",
    ["ScrollPane/grip/focus/sw.png"] = "Slider/grip/focus/sw.png",
    ["ScrollPane/grip/focus/w.png"]  = "Slider/grip/focus/w.png",
    ["ScrollPane/track/c.png"]  = "Slider/track/c.png",
    ["ScrollPane/track/e.png"]  = "Slider/track/e.png",
    ["ScrollPane/track/n.png"]  = "Slider/track/n.png",
    ["ScrollPane/track/ne.png"] = "Slider/track/ne.png",
    ["ScrollPane/track/nw.png"] = "Slider/track/nw.png",
    ["ScrollPane/track/s.png"]  = "Slider/track/s.png",
    ["ScrollPane/track/se.png"] = "Slider/track/se.png",
    ["ScrollPane/track/sw.png"] = "Slider/track/sw.png",
    ["ScrollPane/track/w.png"]  = "Slider/track/w.png",
    ["Slider/grip/default/c.png"]  = "Button/default/c.png",
    ["Slider/grip/default/e.png"]  = "Button/default/e.png",
    ["Slider/grip/default/n.png"]  = "Button/default/n.png",
    ["Slider/grip/default/ne.png"] = "Button/default/ne.png",
    ["Slider/grip/default/nw.png"] = "Button/default/nw.png",
    ["Slider/grip/default/s.png"]  = "Button/default/s.png",
    ["Slider/grip/default/se.png"] = "Button/default/se.png",
    ["Slider/grip/default/sw.png"] = "Button/default/sw.png",
    ["Slider/grip/default/w.png"]  = "Button/default/w.png",
    ["Slider/grip/focus/c.png"]  = "Button/focus/c.png",
    ["Slider/grip/focus/e.png"]  = "Button/focus/e.png",
    ["Slider/grip/focus/n.png"]  = "Button/focus/n.png",
    ["Slider/grip/focus/ne.png"] = "Button/focus/ne.png",
    ["Slider/grip/focus/nw.png"] = "Button/focus/nw.png",
    ["Slider/grip/focus/s.png"]  = "Button/focus/s.png",
    ["Slider/grip/focus/se.png"] = "Button/focus/se.png",
    ["Slider/grip/focus/sw.png"] = "Button/focus/sw.png",
    ["Slider/grip/focus/w.png"]  = "Button/focus/w.png",
    ["Slider/track/c.png"]  = "Button/default/c.png",
    ["Slider/track/e.png"]  = "Button/default/e.png",
    ["Slider/track/n.png"]  = "Button/default/n.png",
    ["Slider/track/ne.png"] = "Button/default/ne.png",
    ["Slider/track/nw.png"] = "Button/default/nw.png",
    ["Slider/track/s.png"]  = "Button/default/s.png",
    ["Slider/track/se.png"] = "Button/default/se.png",
    ["Slider/track/sw.png"] = "Button/default/sw.png",
    ["Slider/track/w.png"]  = "Button/default/w.png",
    ["TabBar/activation/c.png"]   = "ToggleButton/activation/c.png",
    ["TabBar/activation/e.png"]   = "ToggleButton/activation/e.png",
    ["TabBar/activation/n.png"]   = "ToggleButton/activation/n.png",
    ["TabBar/activation/ne.png"]  = "ToggleButton/activation/ne.png",
    ["TabBar/activation/nw.png"]  = "ToggleButton/activation/nw.png",
    ["TabBar/activation/s.png"]   = "ToggleButton/activation/s.png",
    ["TabBar/activation/se.png"]  = "ToggleButton/activation/se.png",
    ["TabBar/activation/sw.png"]  = "ToggleButton/activation/sw.png",
    ["TabBar/activation/w.png"]   = "ToggleButton/activation/w.png",
    --"TabBar/arrow-down/activation.png"
    --"TabBar/arrow-down/default.png"
    --"TabBar/arrow-down/focus.png"
    --"TabBar/arrow-left/activation.png"
    --"TabBar/arrow-left/default.png"
    --"TabBar/arrow-left/focus.png"
    --"TabBar/arrow-right/activation.png"
    --"TabBar/arrow-right/default.png"
    --"TabBar/arrow-right/focus.png"
    --"TabBar/arrow-up/activation.png"
    --"TabBar/arrow-up/default.png"
    --"TabBar/arrow-up/focus.png"
    ["TabBar/default/c.png"]   = "ToggleButton/default/c.png",
    ["TabBar/default/e.png"]   = "ToggleButton/default/e.png",
    ["TabBar/default/n.png"]   = "ToggleButton/default/n.png",
    ["TabBar/default/ne.png"]  = "ToggleButton/default/ne.png",
    ["TabBar/default/nw.png"]  = "ToggleButton/default/nw.png",
    ["TabBar/default/s.png"]   = "ToggleButton/default/s.png",
    ["TabBar/default/se.png"]  = "ToggleButton/default/se.png",
    ["TabBar/default/sw.png"]  = "ToggleButton/default/sw.png",
    ["TabBar/default/w.png"]   = "ToggleButton/default/w.png",
    ["TabBar/focus/c.png"]   = "ToggleButton/focus/c.png",
    ["TabBar/focus/e.png"]   = "ToggleButton/focus/e.png",
    ["TabBar/focus/n.png"]   = "ToggleButton/focus/n.png",
    ["TabBar/focus/ne.png"]  = "ToggleButton/focus/ne.png",
    ["TabBar/focus/nw.png"]  = "ToggleButton/focus/nw.png",
    ["TabBar/focus/s.png"]   = "ToggleButton/focus/s.png",
    ["TabBar/focus/se.png"]  = "ToggleButton/focus/se.png",
    ["TabBar/focus/sw.png"]  = "ToggleButton/focus/sw.png",
    ["TabBar/focus/w.png"]   = "ToggleButton/focus/w.png",
    ["TabBar/selection/c.png"]   = "ToggleButton/selection/c.png",
    ["TabBar/selection/e.png"]   = "ToggleButton/selection/e.png",
    ["TabBar/selection/n.png"]   = "ToggleButton/selection/n.png",
    ["TabBar/selection/ne.png"]  = "ToggleButton/selection/ne.png",
    ["TabBar/selection/nw.png"]  = "ToggleButton/selection/nw.png",
    ["TabBar/selection/s.png"]   = "ToggleButton/selection/s.png",
    ["TabBar/selection/se.png"]  = "ToggleButton/selection/se.png",
    ["TabBar/selection/sw.png"]  = "ToggleButton/selection/sw.png",
    ["TabBar/selection/w.png"]   = "ToggleButton/selection/w.png",
    ["TextInput/default/c.png"]  = "Button/default/c.png",
    ["TextInput/default/e.png"]  = "Button/default/e.png",
    ["TextInput/default/n.png"]  = "Button/default/n.png",
    ["TextInput/default/ne.png"] = "Button/default/ne.png",
    ["TextInput/default/nw.png"] = "Button/default/nw.png",
    ["TextInput/default/s.png"]  = "Button/default/s.png",
    ["TextInput/default/se.png"] = "Button/default/se.png",
    ["TextInput/default/sw.png"] = "Button/default/sw.png",
    ["TextInput/default/w.png"]  = "Button/default/w.png",
    ["TextInput/focus/c.png"]  = "Button/focus/c.png",
    ["TextInput/focus/e.png"]  = "Button/focus/e.png",
    ["TextInput/focus/n.png"]  = "Button/focus/n.png",
    ["TextInput/focus/ne.png"] = "Button/focus/ne.png",
    ["TextInput/focus/nw.png"] = "Button/focus/nw.png",
    ["TextInput/focus/s.png"]  = "Button/focus/s.png",
    ["TextInput/focus/se.png"] = "Button/focus/se.png",
    ["TextInput/focus/sw.png"] = "Button/focus/sw.png",
    ["TextInput/focus/w.png"]  = "Button/focus/w.png",
    ["ToastAlert/default/c.png"]  = "DialogBox/default/c.png",
    ["ToastAlert/default/e.png"]  = "DialogBox/default/e.png",
    ["ToastAlert/default/n.png"]  = "DialogBox/default/n.png",
    ["ToastAlert/default/ne.png"] = "DialogBox/default/ne.png",
    ["ToastAlert/default/nw.png"] = "DialogBox/default/nw.png",
    ["ToastAlert/default/s.png"]  = "DialogBox/default/s.png",
    ["ToastAlert/default/se.png"] = "DialogBox/default/se.png",
    ["ToastAlert/default/sw.png"] = "DialogBox/default/sw.png",
    ["ToastAlert/default/w.png"]  = "DialogBox/default/w.png",
    --"ToastAlert/error.png"
    --"ToastAlert/seperator-h.png"
    ["ToggleButton/activation/c.png"]  = "Button/activation/c.png",
    ["ToggleButton/activation/e.png"]  = "Button/activation/e.png",
    ["ToggleButton/activation/n.png"]  = "Button/activation/n.png",
    ["ToggleButton/activation/ne.png"] = "Button/activation/ne.png",
    ["ToggleButton/activation/nw.png"] = "Button/activation/nw.png",
    ["ToggleButton/activation/s.png"]  = "Button/activation/s.png",
    ["ToggleButton/activation/se.png"] = "Button/activation/se.png",
    ["ToggleButton/activation/sw.png"] = "Button/activation/sw.png",
    ["ToggleButton/activation/w.png"]  = "Button/activation/w.png",
    ["ToggleButton/default/c.png"]  = "Button/default/c.png",
    ["ToggleButton/default/e.png"]  = "Button/default/e.png",
    ["ToggleButton/default/n.png"]  = "Button/default/n.png",
    ["ToggleButton/default/ne.png"] = "Button/default/ne.png",
    ["ToggleButton/default/nw.png"] = "Button/default/nw.png",
    ["ToggleButton/default/s.png"]  = "Button/default/s.png",
    ["ToggleButton/default/se.png"] = "Button/default/se.png",
    ["ToggleButton/default/sw.png"] = "Button/default/sw.png",
    ["ToggleButton/default/w.png"]  = "Button/default/w.png",
    ["ToggleButton/focus/c.png"]  = "Button/focus/c.png",
    ["ToggleButton/focus/e.png"]  = "Button/focus/e.png",
    ["ToggleButton/focus/n.png"]  = "Button/focus/n.png",
    ["ToggleButton/focus/ne.png"] = "Button/focus/ne.png",
    ["ToggleButton/focus/nw.png"] = "Button/focus/nw.png",
    ["ToggleButton/focus/s.png"]  = "Button/focus/s.png",
    ["ToggleButton/focus/se.png"] = "Button/focus/se.png",
    ["ToggleButton/focus/sw.png"] = "Button/focus/sw.png",
    ["ToggleButton/focus/w.png"]  = "Button/focus/w.png",
    ["ToggleButton/focus/c.png"]  = "Button/focus/c.png",
    ["ToggleButton/selection/e.png"]  = "ToggleButton/activation/e.png",
    ["ToggleButton/selection/n.png"]  = "ToggleButton/activation/n.png",
    ["ToggleButton/selection/ne.png"] = "ToggleButton/activation/ne.png",
    ["ToggleButton/selection/nw.png"] = "ToggleButton/activation/nw.png",
    ["ToggleButton/selection/s.png"]  = "ToggleButton/activation/s.png",
    ["ToggleButton/selection/se.png"] = "ToggleButton/activation/se.png",
    ["ToggleButton/selection/sw.png"] = "ToggleButton/activation/sw.png",
    ["ToggleButton/selection/w.png"]  = "ToggleButton/activation/w.png",

}

Style = setmetatable({},
    {

        subscribe_to = function(self,f)
            
            global_style_subscriptions[f] = true
            
            collectgarbage("collect")
            
            for _,s in pairs(all_styles) do
                
                s:subscribe_to(nil,f)
                
            end
            
        end,

        __index = function(t,k)
            t = getmetatable(t)
            
            return t[k]
        end,

        __call = function(self,parameters)
            --print("Style(",parameters,")")
            if type(parameters) == "string" then
                if all_styles[parameters] then
                    
                    return all_styles[parameters]
                    
                else
                    
                    parameters = { name = parameters }
                    
                end
                
            end
            --print("new style",parameters.name)
            
            local style_sources = Group{name=tostring(parameters.name)}
            clone_sources:add(style_sources)
            --if parameters.name == false then error("no",4) end
            parameters = is_table_or_nil("Style",parameters)
            
            local instance = { 
                    to_json = function(self)
                        
                        return json:stringify(self.attributes)
                        
                    end,
                }
            local name
            local arrow       = ArrowStyle()
            local border      = BorderStyle()
            local text        = TextStyle()
            local fill_colors = ColorScheme(default_fill_colors)
            --[=[
            local last_built = nil
            
            local rounded_corner_getter,rounded_corner_setter = 
                image_set_interface(function() 
                    local t = {}
                    local x = 0
                    local y = (last_built==nil) and 0 or (last_built.y+last_built.h*2+5)
                    for _,state in ipairs(states) do
                        t[state] = make_rounded_corner(instance,state) 
                        t[state].scale = 2
                        t[state].x = x
                        x = x + t[state].w*2 + 5
                        t[state].y = y
                    end
                    last_built = t[states[1]]
                    return t
                end, function(old, new) 
                    if old then old:unparent() end
                    if new then 
                        if new.parent then new:unparent() end
                        style_sources:add(new)
                    end
                end
            )
            local rounded_corner 
            
            local top_edge_getter,top_edge_setter = 
                image_set_interface(function() 
                    local t = {}
                    local x = 0
                    local y = (last_built==nil) and 0 or (last_built.y+last_built.h*2+5)
                    for _,state in ipairs(states) do
                        t[state] = make_top_sliver(instance,state) 
                        t[state].scale = 2
                        t[state].x = x
                        x = x + t[state].w*2 + 5
                        t[state].y = y
                    end
                    last_built = t[states[1]]
                    return t
                end, function(old, new) 
                    if old then old:unparent() end
                    if new then 
                        if new.parent then new:unparent() end
                        style_sources:add(new)
                    end
                end
            )
            local top_edge 
            
            local side_edge_getter,side_edge_setter = 
                image_set_interface(function() 
                    local t = {}
                    local x = 0
                    local y = (last_built==nil) and 0 or (last_built.y+last_built.h*2+5)
                    for _,state in ipairs(states) do
                        t[state] = make_side_sliver(instance,state) 
                        t[state].scale = 2
                        t[state].x = x
                        x = x + t[state].w*2 + 5
                        t[state].y = y
                    end
                    last_built = t[states[1]]
                    return t
                end, function(old, new) 
                    if old then old:unparent() end
                    if new then 
                        if new.parent then new:unparent() end
                        style_sources:add(new)
                    end
                end
            )
            local side_edge 
            
            local arrow_getter,arrow_setter = 
                image_set_interface(function() 
                    local t = {}
                    local x = 0
                    local y = (last_built==nil) and 0 or (last_built.y+last_built.h*2+5)
                    for _,state in ipairs(states) do
                        t[state] = make_arrow(instance,state) 
                        t[state].scale = 2
                        t[state].x = x
                        x = x + t[state].w*2 + 5
                        t[state].y = y
                    end
                    last_built = t[states[1]]
                    return t
                end, function(old, new) 
                    if old then old:unparent() end
                    if new then 
                        if new.parent then new:unparent() end
                        style_sources:add(new)
                    end
                end
            )
            local triangle 
            
            local empty_toggle_icon_getter,empty_toggle_icon_setter = 
                image_set_interface(function() 
                    local t = {}
                    local x = 0
                    local y = (last_built==nil) and 0 or (last_built.y+last_built.h*2+5)
                    for _,state in ipairs(states) do
                        t[state] = make_box(instance,state) 
                        t[state].scale = 2
                        t[state].x = x
                        x = x + t[state].w*2 + 5
                        t[state].y = y
                    end
                    last_built = t[states[1]]
                    return t
                end, function(old, new) 
                    if old then old:unparent() end
                    if new then 
                        if new.parent then new:unparent() end
                        style_sources:add(new)
                    end
                end
            )
            local empty_toggle_icon
            
            local filled_toggle_icon_getter,filled_toggle_icon_setter = 
                image_set_interface(function() 
                    local t = {}
                    local x = 0
                    local y = (last_built==nil) and 0 or (last_built.y+last_built.h*2+5)
                    for _,state in ipairs(states) do
                        t[state] = make_x_box(instance,state) 
                        t[state].scale = 2
                        t[state].x = x
                        x = x + t[state].w*2 + 5
                        t[state].y = y
                    end
                    last_built = t[states[1]]
                    return t
                end, function(old, new) 
                    if old then old:unparent() end
                    if new then 
                        if new.parent then new:unparent() end
                        style_sources:add(new)
                    end
                end
            )
            local filled_toggle_icon
            
            local empty_radio_icon_getter,empty_radio_icon_setter = 
                image_set_interface(function() 
                    local t = {}
                    local x = 0
                    local y = (last_built==nil) and 0 or (last_built.y+last_built.h*2+5)
                    for _,state in ipairs(states) do
                        t[state] = make_empty_radio_icon(instance,state) 
                        t[state].scale = 2
                        t[state].x = x
                        x = x + t[state].w*2 + 5
                        t[state].y = y
                    end
                    last_built = t[states[1]]
                    return t
                end, function(old, new) 
                    if old then old:unparent() end
                    if new then 
                        if new.parent then new:unparent() end
                        style_sources:add(new)
                    end
                end
            )
            local empty_radio_icon
            
            local filled_radio_icon_getter,filled_radio_icon_setter = 
                image_set_interface(function() 
                    local t = {}
                    local x = 0
                    local y = (last_built==nil) and 0 or (last_built.y+last_built.h*2+5)
                    for _,state in ipairs(states) do
                        t[state] = make_filled_radio_icon(instance,state) 
                        t[state].scale = 2
                        t[state].x = x
                        x = x + t[state].w*2 + 5
                        t[state].y = y
                    end
                    last_built = t[states[1]]
                    return t
                end, function(old, new) 
                    if old then old:unparent() end
                    if new then 
                        if new.parent then new:unparent() end
                        style_sources:add(new)
                    end
                end
            )
            local filled_radio_icon
            
            local toggle_icon_w = parameters.toggle_icon_w or 30
            local toggle_icon_h = parameters.toggle_icon_h or 30
            local radio_icon_r = parameters.radio_icon_r or 15
            --]=]
            local spritesheet
            local spritesheet_map
            local meta_getters
            local recursive_fallbacks
            recursive_fallbacks = function(id)
                return meta_getters[id] or fallbacks[id] and recursive_fallbacks(fallbacks[id])
            end
            local setup_meta_getters = function()
                meta_getters = {
                    spritesheet     = function() return spritesheet     end,
                    spritesheet_map = function() return spritesheet_map end,
                    name            = function() return name            end,
                    type            = function() return "STYLE"         end,
                    text            = function() return text            end,
                    attributes      = function() 
                        return {
                            spritesheet = instance.spritesheet,
                            name        = instance.name,
                            type        = instance.type,
                        }
                    end,
                }
                getmetatable(instance).__index    = __index(meta_getters)
                
                for _,id in pairs(spritesheet:get_ids()) do
                    meta_getters[id] = function()
                        return id--Sprite{ sheet = default_spritesheet, id = id }
                    end
                end
                for value,replacement in pairs(fallbacks) do
                    meta_getters[value] = recursive_fallbacks(value)
                end
            end
            local meta_setters = {
                spritesheet_map   = function(v) 
                    
                    spritesheet_map = v or default_spritesheet 
                    
                    spritesheet   = SpriteSheet{ map = spritesheet_map }
                    
                    setup_meta_getters()
                    
                end,
                text          = function(v) text:set(       v or {}) end,
                --[[
                toggle_icon_w = function(v) toggle_icon_w = v end,
                toggle_icon_h = function(v) toggle_icon_h = v end,
                radio_icon_r  = function(v) radio_icon_r  = v end,
                arrow         = function(v) arrow:set(      v or {}) end,
                border        = function(v) border:set(     v or {}) end,
                fill_colors   = function(v) fill_colors:set(v or {}) end,
                rounded_corner     = rounded_corner_setter,
                top_edge           = top_edge_setter,
                side_edge          = side_edge_setter,
                empty_toggle_icon  = empty_toggle_icon_setter,
                filled_toggle_icon = filled_toggle_icon_setter,
                empty_radio_icon   = empty_radio_icon_setter,
                filled_radio_icon  = filled_radio_icon_setter,
                arrow              = arrow_setter,
                --]]
                name        = function(v)
                    
                    if v ~= false then
                        
                        if name then all_styles[name] = nil end
                        
                        v = check_name( all_styles, instance, v, "Style" )
                        
                    end
                    
                    name = v
                    
                end,
            }
            --[[
            local meta_getters = {
                spritesheet   = function() return spritesheet end,
                toggle_icon_w = function() return toggle_icon_w end,
                toggle_icon_h = function() return toggle_icon_h end,
                radio_icon_r  = function() return radio_icon_r end,
                name          = function() return name        end,
                arrow         = function() return arrow       end,
                border        = function() return border      end,
                text          = function() return text        end,
                fill_colors   = function() return fill_colors end,
                type          = function() return "STYLE"     end,
                rounded_corner     = rounded_corner_getter,
                top_edge           = top_edge_getter,
                side_edge          = side_edge_getter,
                empty_toggle_icon  = empty_toggle_icon_getter,
                filled_toggle_icon = filled_toggle_icon_getter,
                empty_radio_icon   = empty_radio_icon_getter,
                filled_radio_icon  = filled_radio_icon_getter,
                triangle              = arrow_getter,
                attributes  = function() 
                    return {
                        name        = instance.name,
                        arrow       = instance.arrow.attributes,
                        border      = instance.border.attributes,
                        text        = instance.text.attributes,
                        fill_colors = instance.fill_colors.attributes,
                    }
                end,
            }
            --]]
            setmetatable(
                instance,
                {
                    __index    = __index(meta_getters)
                }
            )
            set_up_subscriptions( instance, getmetatable(instance),
                
                __newindex(meta_setters),
                
                function(self,t)
                    
                    if type(t) == "string" then
                        
                        if not all_styles[t] then
                            error("No existing style by the name "..t,2)
                        end
                        
                        for k, v in pairs(all_styles[t].attributes) do
                            if k ~= "name" then self[k] = v end
                        end
                        
                    elseif type(t) == "table" then
                        
                        for k, v in pairs(t) do
                            self[k] = v
                        end
                        
                    else
                        error("Expects a string or a table. Received "..type(t),2)
                    end
                    
                    return instance
                end
            )
            --[[
            --can't use a table, need to ensure some properties receive a nil in order
            --to trigger the default condition 
            instance.name        = parameters.name 
            instance.arrow       = parameters.arrow
            instance.border      = parameters.border
            instance.fill_colors = parameters.fill_colors
            --clone_sources
            instance.rounded_corner     = parameters.rounded_corner
            instance.top_edge           = parameters.top_edge
            instance.side_edge          = parameters.side_edge
            instance.empty_toggle_icon  = parameters.empty_toggle_icon
            instance.filled_toggle_icon = parameters.filled_toggle_icon
            instance.empty_radio_icon   = parameters.empty_radio_icon
            instance.filled_radio_icon  = parameters.filled_radio_icon
            instance.triangle           = parameters.triangle
            
            --]]
            instance.name            = parameters.name 
            instance.spritesheet_map = parameters.spritesheet_map
            instance.text            = parameters.text
            ---[[
            -- if a substyle was modified, notify my subscribers
            --print(instance.name,"Style object is subscribing to sub-styles")
            --arrow:subscribe_to(       nil, function(t) instance:notify({arrow       = t}) end )
            --border:subscribe_to(      nil, function(t) instance:notify({border      = t}) end )
            text:subscribe_to(        nil, function(t) instance:notify({text        = t}) end )
            --fill_colors:subscribe_to( nil, function(t) instance:notify({fill_colors = t}) end )
            --]]
            for f,_ in pairs(global_style_subscriptions) do
                instance:subscribe_to(nil,f)
            end
            
            return instance
    
        end
    }
)
--really dumb, but I need to hold a reference for the default style somewhere
--so that the weak table doesn't throw it away (if i use a local, lua is smart
--enough to realize its never going to be used and will throw it away anyway)
getmetatable(all_styles).default = Style("Default")

external.Style          = Style
external.get_all_styles = get_all_styles
