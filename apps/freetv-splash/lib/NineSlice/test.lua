
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

ns1 = NineSlice{}
ns2 = NineSlice{w=200,h=50,x=100}
ns3 = NineSlice{
    x = 400,
    w = 400,
    h = 300,
    cells = {
        default = {
            {
                Widget_Rectangle{w=30,h=30,color="440055"},
                Widget_Rectangle{w=10,h=30,color="000055"},
                Widget_Rectangle{w=30,h=30,color="440055"},
            },
            {
                Widget_Rectangle{w=30,h=10,color="000055"},
                Widget_Rectangle{w=10,h=10,color="777777"},
                Widget_Rectangle{w=30,h=10,color="000055"},
            },
            {
                Widget_Rectangle{w=30,h=30,color="440055"},
                Widget_Rectangle{w=10,h=30,color="000055"},
                Widget_Rectangle{w=30,h=30,color="440055"},
            },
        },
        focus = {
            {
                Widget_Rectangle{w=30,h=30,color="777777"},
                Widget_Rectangle{w=10,h=30,color="0000bb"},
                Widget_Rectangle{w=30,h=30,color="777777"},
            },
            {
                Widget_Rectangle{w=30,h=10,color="0000bb"},
                Widget_Rectangle{w=10,h=10,color="999999"},
                Widget_Rectangle{w=30,h=10,color="0000bb"},
            },
            {
                Widget_Rectangle{w=30,h=30,color="777777"},
                Widget_Rectangle{w=10,h=30,color="0000bb"},
                Widget_Rectangle{w=30,h=30,color="777777"},
            },
        },
    }
}

screen:add(Rectangle{size = screen.size,color = "444444"},ns1,ns2,ns3)