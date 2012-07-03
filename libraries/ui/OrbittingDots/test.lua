
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")              end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("__CORE/Style.lua")                    end
if not WIDGET            then dofile("__CORE/Widget.lua")                   end
if not PROGRESSSPINNER   then dofile("ProgressSpinner/ProgressSpinner.lua") end
if not ORBITTINGDOTS     then dofile("OrbittingDots/OrbittingDots.lua")     end







local style = {
    border = {
        width = 10,
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
    text = {
        font = "Sans 50px",
        colors = {
            default    = {255,255,155},
            focus      = {255,255,155},
            activation = {155,255,255}
        }
    },
    fill_colors    = {
        default    = {80,0,0},
        focus      = {155,155,155},
        activation = {155,155,155}
    }
}


screen:show()


od1 = OrbittingDots()

od2 = OrbittingDots{x = 200,image = "OrbittingDots/x.png",dot_size = 40}
od3 = OrbittingDots{x = 400}

od3.image = "OrbittingDots/x.png"

od4 = OrbittingDots{y = 200,num_dots = 40,animating = true}
od4.num_dots = 4
od4.num_dots = 12
od4.num_dots = 12
od4.size = {200,200}

od5 = OrbittingDots{x = 400,y = 200,num_dots = 10,animating = true,style = style}
print(od1:to_json())
print(od2:to_json())
print(od3:to_json())
print(od4:to_json())
screen:add(od1,od2,od3,od4,od5)

