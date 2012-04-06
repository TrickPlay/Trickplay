
if not OVERRIDEMETATABLE then dofile("__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("__UTILITIES/Canvas.lua")              end
if not COLORSCHEME       then dofile("__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("__CORE/Style.lua")                    end
if not WIDGET            then dofile("__CORE/Widget.lua")                   end
if not PROGRESSSPINNER   then dofile("ProgressSpinner/ProgressSpinner.lua") end





screen:show()


ps1 = ProgressSpinner()

ps2 = ProgressSpinner{x = 200,image = "ProgressSpinner/load-sun-spin.png"}


screen:add(ps1,ps2)

