
if not editor then
    error("\n\nThis test app must receive editor permissions\n")
end

---------------------------------------------------------------------

--If the locations of this test app or of the widget library change,
--then these must change as well
local absolute_path_to_test_app       = editor.app_path

local absolute_path_to_widget_library =
    --returns the path to trickplay root
    absolute_path_to_test_app:sub(
        1,
        absolute_path_to_test_app:len() -
        ("tests/apps/widget-library/"):len() + 1
    ) ..
    --appends the path to the widget_library
    "libraries/ui/"

---------------------------------------------------------------------

local tests = {}
local tests_group = Group()
for i,file in ipairs(editor:readdir(absolute_path_to_test_app)) do

    if file ~= "app" and file ~= "main.lua" then

        file = file:sub(1,file:len()-4)

        table.insert(tests,Text{
            text     = file,
            color    = "white",
            font     = "Lato 40px",
            y        = 100*(#tests+1),
            x        = 100,
            extra    = {
                file = loadfile(file),
            }
        })
    end
end
tests_group:add(unpack(tests))

---------------------------------------------------------------------
local load_test_menu
load_test_menu = function()
    screen:add(Rectangle{color="880000",y = 80,h=100,w=500},tests_group)

    tests_group.y = 0
    local i = 1
    local key_events
    key_events = {
        [keys.Down] = function()
            if i == #tests then return end

            i = i + 1

            tests_group:stop_animation()
            tests_group:animate{duration=100,y = -tests[i].y+100}
        end,
        [keys.Up] = function()
            if i == 1 then return end

            i = i - 1

            tests_group:stop_animation()
            tests_group:animate{duration=100,y = -tests[i].y+100}
        end,
        [keys.OK] = function()
            screen:clear()
            key_events = {
                [keys.BACK] = function()
                    screen:grab_key_focus()
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

controllers:start_pointer()
screen:show()
load_test_menu()
---------------------------------------------------------------------
editor:change_app_path(absolute_path_to_widget_library)
WL = dofile("Widget_Library.lua")

dofile("load_json.lua")
