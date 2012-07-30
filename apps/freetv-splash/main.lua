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

dofile("widget_helper.lua")

dofile("unlock_code.lua")

screen:show()

dolater(dofile,"preload_configure.lua")

dofile("configure.lua")

local function on_configuration_completed()
    print("Configuration completed")
end

local function on_unlock_completed(code)
    print("Code entered:",code)
    start_configuration(on_configuration_completed)
end

start_unlock_code(on_unlock_completed)
