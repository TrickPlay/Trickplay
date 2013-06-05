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


function ampm(hr,min)

    hr  = tonumber(hr)
    min = min and string.format(":%02d",min) or ""

    --hours
    return ((hr > 12 and hr-12) or -- (13:00-23:00) -> (1:00-11:00)
            (hr == 0 and    12) or hr) .. --  0:00  -> 12:00
        --minutes & AM/PM
        min .. (hr < 12 and "AM" or "PM")

end




FONT_NAME = "Lato Regular"
FONT = "Lato Regular"
FONT_BOLD = "Lato Bold"

banner_sprites  = SpriteSheet{map="assets/banner_sprites/banners.json"}
imdb_sprites    = SpriteSheet{map="assets/imdb_poster_sprites/imdb.json"}
ui_sprites      = SpriteSheet{map="assets/ui_sprites/assets.json"}
tv_show_sprites = SpriteSheet{map="assets/tv_show_sprites/tv-shows.json"}


lorem_ipsum = [[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco]]

lorem_ipsum_longer = [[Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.]]
wrap_i = function(i,n) return (i - 1) % (n) + 1 end
screen_w = screen.w
screen_h = screen.h


json_null = json.null
dofile("widget_helper.lua")
dofile("make_SlidingBar")
dofile("make_MoreInfoBacking")
dofile("make_WindowedList")
dofile("make_MyAnimator")
XML_PARSE = dofile("XML_to_lua_table")
dofile("launcher.lua")

load_data = dofile("tv_data.lua")
print("before")
channels, series = load_data("tv_guide_json/")
print("after")
dofile("launcher/EPG.lua")
epg.more_info = dofile("launcher/EPG_MoreInfo.lua")
--[[
    Globals -- very limited set of these
]]--


movie_data = json:parse(readfile("movie_data.json"))
num_completed = 0
local function try_again(req)
    print(m.name.." FAILED. Trying again.")
    dolater(10*1000,req.send,req)
end
--[[
movie_data = json:parse(readfile("imdb-top-250.json"))

local prefix = "http://www.imdb.com/title/"

num_completed = 0
for i,movie in ipairs(movie_data) do
    local m = movie
    local id = m.link:sub(prefix:len()+1,m.link:len()-1)
    local req = URLRequest{
        url = "http://imdbapi.org/?ids="..id..
        "&type=json&plot=full&episode=1&lang=en-US&aka=simple&release=simple&business=0&tech=0",
        on_complete = function(self,response)

            --print(response.code,response.body)
            if response.code ~= 200 then
                try_again(self)
            else
                local t = json:parse(response.body)
                if type(t) ~= "table" then
                    try_again(self)
                else
                    --for
                    --movie_data[m.rank]
                    for k,v in pairs(t[1]) do
                        --print(m.rank,type(m.rank+0))
                        movie_data[m.rank+0][k] = v
                    end
                    --dumptable(movie_data[m.rank+0])
                    num_completed = num_completed + 1
                    print("finish",i)
                    if num_completed == #movie_data then
                        editor:writefile(
                            "movie_data.json",
                            json:stringify(movie_data)
                        )
                    end
                end
            end
        end,
    }
    print("send",i)
    req:send()
    --break;
end
--]]
--[[
for i,v in ipairs(movie_data) do
    local rrr=URLRequest{
        url = v.poster,--"http://www.google.com/images/srpr/logo4w.png",
        on_complete = function(self,response)
            if response.body then
                editor:writefile("assets/imdb_posters/"..v.name..".jpg",response.body)
                num_completed = num_completed + 1
                print("finished",i)
                if num_completed == #movie_data then
                    print("FINISHED")
                    print("FINISHED")
                    print("FINISHED")
                end
            else
                try_again(self)
            end
        end,
    }
    rrr:send()
end
--]]
--[[
for i,v in ipairs(movie_data) do
    v.poster = "assets/imdb_posters/"..v.name..".jpg"
end
editor:writefile(
    "movie_data.json",
    json:stringify(movie_data)
)
--]]
--dumptable(movie_data)
local back_to_start = settings.back_to_start

if( false and not back_to_start) then

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
    start_launcher(settings.service or "xfinity", settings.back_to_start)
end




--[[
mediaplayer:load("glee-1.mp4")
function mediaplayer:on_loaded()
    mediaplayer:play()
    mediaplayer.volume = 0
end
function mediaplayer:on_end_of_stream()
    mediaplayer:seek(0)
    mediaplayer:play()
end
--]]
if  tuners.available[1] then
    tuners.available[1]:tune_channel(
        'humax-channel:256,477,3000,0x100,0x101'
    )
end

-------------------------------------------------------------------------
do
    local A = ("A"):byte()
    local every_char =
        "ÁÉÍÓÚÜÑáéíóúüñ¿¡!-@#$%^&*()[]{},.;:\"\'"
    for i=A,A+25 do -- every upper case letter
        every_char = every_char.. string.char(i)
    end
    A = ("a"):byte()
    for i=A,A+25 do -- every lower case letter
        every_char = every_char.. string.char(i)
    end
    for i=0,9 do -- every number
        every_char = every_char.. i
    end
    local every_char_g = Group{name="Every Character"}
    for _,font_name in ipairs{"Lato Regular","Lato Bold"} do
        for _,sz in ipairs{18,20,24,32,40} do
            every_char_g:add(
                Text{
                    name = font_name.." "..sz.."px",
                    font = font_name.." "..sz.."px",
                    text = every_char,
                }
            )
        end
    end
    every_char_g:hide()
    screen:add(every_char_g)
    dolater(100,function() every_char_g:unparent() end)
end
