
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")              end
if not MISC              then dofile("__UTILITIES/Misc.lua")                end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("__CORE/Style.lua")                    end
if not WIDGET            then dofile("__CORE/Widget.lua")                   end
if not PROGRESSSPINNER   then dofile("ProgressSpinner/ProgressSpinner.lua") end
if not CLIPPINGREGION    then dofile("ClippingRegion/ClippingRegion.lua")   end

local test_group = Group()

screen:add(test_group)
local tests = {
}

for i,test in ipairs(tests) do
    
    if not test() then print("test "..i.." failed") end
    test_group:clear()
end

test_group:unparent()







screen:show()


cr1 = ClippingRegion()

cr1:add(
    Widget_Rectangle{w=1000,h=1000,color="ffff00"},
    Widget_Rectangle{w=100,h=100,color="ff0000"},
    Widget_Rectangle{x = 300,y=300,w=100,h=100,color="00ff00"}
)


screen:add(cr1)

