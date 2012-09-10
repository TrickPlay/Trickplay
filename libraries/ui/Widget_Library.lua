
local pwd = (where_am_i())[2]


local WL = {}

local widget_list = {
    Button = "Button/Button.lua",
}

setmetatable(WL,{
    __index = function(t,k)
        if widget_list[k] then
            dofile(widget_list[k])
        end
    end
})

if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua") end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")      end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua") end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")            end
if not MISC              then dofile("__UTILITIES/Misc.lua")              end
if not LISTMANAGER       then dofile("__UTILITIES/ListManagement.lua")    end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")            end
if not STYLE             then dofile("__CORE/Style.lua")                  end
if not WIDGET            then dofile("__CORE/Widget.lua")                 end





return WL