
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")              end
if not MISC              then dofile("__UTILITIES/Misc.lua")                end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("__CORE/Style.lua")                    end
if not WIDGET            then dofile("__CORE/Widget.lua")                   end
if not LISTMANAGER       then dofile("__UTILITIES/ListManagement.lua")      end
if not LAYOUTMANAGER     then dofile("LayoutManager/LayoutManager.lua")     end
if not NINESLICE         then dofile("NineSlice/NineSlice.lua")             end
if not SLIDER            then dofile("Slider/Slider.lua")                   end

s2 = Slider{x=500, y = 300, grip_w = 50, grip_h = 200, track_w = 500, track_h = 50}
--s1 = Slider{direction = "vertical", }
--s1:set{x=30,track_h = 400, track_w = 100,grip_w = 100,grip_h = 100}

--dumptable(s1.attributes)
screen:add(s1,s2)

screen.reactive = true