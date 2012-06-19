
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")              end
if not MISC              then dofile("__UTILITIES/Misc.lua")                end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("__CORE/Style.lua")                    end
if not WIDGET            then dofile("__CORE/Widget.lua")                   end
if not NINESLICE         then dofile("NineSlice/NineSlice.lua")             end
if not SLIDER            then dofile("Slider/Slider.lua")                   end
if not CLIPPINGREGION    then dofile("ClippingRegion/ClippingRegion.lua")   end
if not LISTMANAGER       then dofile("__UTILITIES/ListManagement.lua")      end
if not LAYOUTMANAGER     then dofile("LayoutManager/LayoutManager.lua")     end
if not SCROLLPANE        then dofile("ScrollPane/ScrollPane.lua")           end

s1 = ScrollPane()
s1:add(Rectangle{w=1000,h=1000,color="ffff00"},Rectangle{w=100,h=100,color="ff0000"},Rectangle{x = 300,y=300,w=100,h=100,color="00ff00"})
s2 = ScrollPane{slider_thickness = 200,pane_h = 700,x = 600}
s2:add(Rectangle{w=1000,h=1000,color="ffff00"},Rectangle{w=100,h=100,color="ff0000"},Rectangle{x = 300,y=300,w=100,h=100,color="00ff00"})
screen:add(s1,s2)

screen.reactive = true