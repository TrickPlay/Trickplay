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

wrap_i = function(i,n) return (i - 1) % (n) + 1 end



local bg = Rectangle{size=screen.size}
json_null = json.null
screen:add(bg)
dofile("widget_helper.lua")

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
