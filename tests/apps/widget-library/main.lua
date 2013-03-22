
if not editor then
    error("\n\nThis test app must receive editor permissions\n")
end

---------------------------------------------------------------------

--If the locations of this test app or of the widget library change,
--then these must change as well
local relative_path_to_test_app       = "tests/apps/widget-library/"
local relative_path_to_widget_library = "libraries/ui/"
local absolute_path_to_test_app       = editor.app_path

local absolute_path_to_widget_library =
    --returns the path to trickplay root
    absolute_path_to_test_app:sub(
        1,
        absolute_path_to_test_app:len() -
        relative_path_to_test_app:len() + 1
    ) ..
    --appends the path to the widget_library
    relative_path_to_widget_library

---------------------------------------------------------------------

local tests = {}
local t
local tests_group = Group()
for i,file in ipairs(editor:readdir(absolute_path_to_test_app)) do

    if file ~= "app" and file ~= "main.lua" then
        file = file:sub(1,file:len()-4)
        print("waht",file)
        --tests[file] = loadfile(file)
        t      = Text{
            text=file,
            color="white",
            font="Lato 40px",
            y = 100*(#tests+1),
            x = 100,
        }
        t.file = loadfile(file)
        table.insert(tests,t)
    end
    tests_group:add(unpack(tests))

end

local load_test_menu
load_test_menu = function()
    screen:add(Rectangle{color="880000",y = 80,h=100,w=500},tests_group)
    screen:show()
    tests_group.y = 0
    local i = 1
    local key_events
    key_events = {
        [keys.Down] = function()
            if i == #tests then return end

            i = i + 1

            tests_group:stop_animation()
            tests_group:animate{duration=100,y = -100*(i-1)}
        end,
        [keys.Up] = function()
            if i == 1 then return end

            i = i - 1

            tests_group:stop_animation()
            tests_group:animate{duration=100,y = -100*(i-1)}
        end,
        [keys.OK] = function()
            screen:clear()
            key_events = {
                [keys.BACK] = function()
                    screen:clear()
                    load_test_menu()
                end,
            }
            tests[i].file()
        end,
    }

    function screen:on_key_down(k)
        return key_events[k] and key_events[k]()
    end
end

load_test_menu()
---------------------------------------------------------------------
editor:change_app_path(absolute_path_to_widget_library)
WL = dofile("Widget_Library.lua")

dofile("load_json.lua")

print(editor.app_path)
dumptable(getmetatable(editor))
dumptable(tests)
--[=[]]
local l = "/Users/trickplay/tp/trickplay/"
--dumptable(getmetatable(editor))
local path_to_WL = "/Users/trickplay/tp/trickplay/libraries/ui/"
editor:change_app_path(path_to_WL)
print(editor.app_path)


WL = dofile("Widget_Library.lua")
dofile("load_json.lua")
--add_verbosity("STYLE_SUBSCRIPTIONS")
--add_verbosity("DEBUG")
--add_verbosity("TABBAR")
--add_verbosity("ArrayManager")


dofile("OrbittingDots/test.lua")
--[[
wg = WL.Widget_Group{name='wg'}

wg:add(WL.MenuButton{
    name = "lm",
    y = 400,
})

str = wg:to_json()
print(str)
screen:add(load_layer(str))
--]]
screen:show()
controllers:start_pointer()

---------------------------------------------------------------------
r = Rectangle{w=10,h=10,y = 1070}
screen:add(r)

r:animate{
    loop = true,
    duration = 60000,
    w = screen.w
}
--]=]
