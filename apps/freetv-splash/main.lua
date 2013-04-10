-- Based on demo video at https://www.dropbox.com/s/g37078405oxlnlm/OOBE%20Screen%205c.mp4

--[[

    This animation is split into phases (which overlap slightly):

    1. "Welcome to" "FREE TV!" zooms out from middle of TV and fades   0.0 through 0.25
    2. Movie posters accordion out from center of screen to the sides, growing and rotating slightly in y-axis  0.15 through 0.4
    3. "Hundreds of" "MOVIES" zooms out from middle of TV and fades
    4. TV show posters fly out from center of screen to all edges, growing as they go
    5. "Enjoy your favorite" "TV SHOWS" zooms out from middle of TV and fades
    6. "The Best" "MUSIC" zooms out from middle of TV and fades
    7. Album covers fly out from middle of TV, rotated at jaunty angles in x & y axes
    8. "Welcome to" "FREE TV!" zooms back in to middle of screen

]]--
lorem_ipsum = [[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco]]

lorem_ipsum_longer = [[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.]]
tv_show_sprites = SpriteSheet{map="assets/sprites2/tv-shows.json.json"}
wrap_i = function(i,n) return (i - 1) % (n) + 1 end



local bg = Rectangle{size=screen.size}
json_null = json.null
screen:add(bg)
dofile("widget_helper.lua")
dofile("make_SlidingBar")
dofile("launcher.lua")

load_data = dofile("tv_data.lua")
print("before")
channels, series = load_data("tv_guide_json/")
print("after")
--[[
    Globals -- very limited set of these
]]--

FONT_NAME = "Lato Regular"

local back_to_start = settings.back_to_start

if( not back_to_start) then

    dofile("unlock_code.lua")

    dofile("configure.lua")

    screen:show()

    local function on_configuration_completed(service)
        print("Configuration completed")
        settings.service = service
        start_launcher(service)
    end

    local function on_unlock_completed(code)
        print("Code entered:",code)
        if(code == "") then
            on_configuration_completed("xfinity")
        else
            start_configuration(on_configuration_completed, code)
        end
    end

    start_unlock_code(on_unlock_completed)
else
    screen:show()
    start_launcher(settings.service, settings.back_to_start)
end
bg:lower_to_bottom()
