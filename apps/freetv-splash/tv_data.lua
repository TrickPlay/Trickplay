local loaded = false
local tvdb_api_key = "D209ABA4E61650BB"
local banner_prefix = "http://thetvdb.com/banners/"

--local mirrors = URLRequest{url="http://thetvdb.com/api/"..tvdb_api_key.."/mirrors.xml"}:perform().body
--print(mirrors)
--mirrors = XML_PARSE(mirrors)
--dumptable(mirrors)

start_of_data = {
    year  = 2013,
    month = 1,
    day   = 17,
    hour  = 0,
    min   = 0,
}

curr_time = {
    year  = 2013,
    month = 1,
    day   = 17,
    hour  = 18,
    min   = 0,
}
local real_time = os.date("*t")
curr_time.hour = real_time.hour+8
curr_time.min = real_time.min > 30 and 30 or 0
print("REAL TIME HOUR",real_time.hour)
function os_time(t)
    return os.time(t)-8*60*60
end

start_of_data__seconds = os_time(start_of_data)
curr_time__seconds = os_time(curr_time)



local channels = {}

local series = {}

local days_r = {
    "MON",
    "TUE",
    "WED",
    "THU",
    "FRI",
    "SAT",
    "SUN",
}

local cast_list = {
    {actor = "Debra Messing",    role = "Julia"},
    {actor = "Jack Davenport",   role = "Derek Walsh"},
    {actor = "Katharine McPhee", role = "Karen"      },
    {actor = "Christian Borle",  role = "Tom"        },
    {actor = "Meghan Hilty",     role = "Ivy"        },
    {actor = "Anjelica Huston",  role = "Eileen"     },
    {actor = "Raza Jaffrey",     role = "Dev"        },
}
local function extract_time(s, file)
    --expected input
    --"2012-10-23T17:50:00Z" 2013-01-17 00:00
    local t = {}
    t.year,
    t.month,
    t.day,
    t.hour,
    t.min =
        string.match(s,"(%d*)-(%d*)-(%d*) (%d*):(%d*)")

    if  t.hour == "" then
        t.hour = 22
        print(file,s)
    end
    if  t.year == nil or
        t.day  == nil or
        t.month == nil or
        t.hour == nil or
        t.min == nil then

        t.year,
        t.month,
        t.day,
        t.min =
            string.match(s,"(%d*)-(%d*)-(%d*) (%d*)")
        t.hour = 23
        print(file,s)

    end
    t.wkdy = days_r[(math.floor(t.year/100)+t.year%100+t.month+t.day)%7+1]
    --print(s)

    return t
end


local function fill_gaps_in_season(s,i)
    if s[i] == nil then dumptable(s) error("no",2) end
    local last_real_episode = s[i].max_episode_number
    for j=s[i].max_episode_number-1,1,-1 do
        if s[i][j] == nil then
            s[i][j] = last_real_episode
        else
            last_real_episode = j
        end
    end
end

local function fill_gaps_in_series()

    for id,s in pairs(series) do
        local last_real_season = s.max_season_number
        if last_real_season > 0 then
            fill_gaps_in_season(s,last_real_season)
            for i=(s.max_season_number-1),1,-1 do
                if s[i] == nil then
                    s[i] = last_real_season
                else
                    last_real_season = i
                    fill_gaps_in_season(s,i)
                end
            end
        end
    end
end
local function add_show_to_series(series_id,show)

    local s = series[series_id]
    if s == nil then
        s = {
            no_season_number = {},
            max_season_number = 0,
            all_shows = {}
        }
        series[series_id] = s
    end

    local s_num = show.season_number
    local e_num = show.episode_number

    table.insert(s.all_shows,show)
    if s_num == json_null then
        table.insert(s.no_season_number,show)
    else
        s[s_num] = s[s_num] or
            {
                max_episode_number = 0,
                no_episode_number = {},
            }
        if e_num == json_null then
            table.insert(
                s[s_num].no_episode_number,
                show
            )
        else
            s[s_num][e_num] = show
            s[s_num].max_episode_number =
                math.max(e_num,s[s_num].max_episode_number)
        end
        s.max_season_number=math.max(s.max_season_number,s_num)
    end
end

--[[
local banner_requests = {}
local function try_again(req)
    print(req.url.." FAILED. Trying again.")
    dolater(10*1000,req.send,req)
end
local request_banner = function( name)
    if banner_requests[name] then return end
    banner_requests[name] = true
    if editor:file_exists("banners/"..name..".png") or editor:file_exists("banners/"..name..".png") then
        print("saving time")
        return
    end
    local req = URLRequest{
        url = "http://thetvdb.com/api/GetSeries.php?seriesname="..
            uri:escape(name),
        on_complete = function( self, response )
            if response.code == 200 then
                local t = XML_PARSE(response.body)
                --dumptable(t)
                if t.Data.Series == nil then return end
                t = t.Data.Series[1] and
                    t.Data.Series[1] or t.Data.Series
                local b = t.banner
                if b then
                    local req = URLRequest{
                        url = banner_prefix..b,
                        on_complete = function(self,response)
                            if response.code == 200 then
                                editor:writefile("banners/"..name..(b:sub(-4)),
                                    response.body
                                )
                                print("banners/"..name..(b:sub(-4)))
                            else
                                print(response.code,response.status)
                                --try_again(self)
                            end
                        end
                    }
                    req:send()
                end
            else
                print(response.code,response.status)
                --try_again(self)
            end
                --sfasdfa()
        end
    }
    req:send()
end
--]]
--[=[]]
local t = editor:readdir("apps/freetv-splash/tv_guide_json")
local t_map = {}
for i,v in ipairs(t) do
    t_map[v] = true
end
t_map["channels.json"] = nil
--]=]
--[=[]]
local banner_sprites_map = {}
local tv_show_sprites_map = {}

for i,v in ipairs(tv_show_sprites.ids) do
    tv_show_sprites_map[v] = true
end
for i,v in ipairs(banner_sprites.ids) do
    banner_sprites_map[v] = true
end


        dumptable(tv_show_sprites_map)

local all_poster_ids = ""
local all_banner_ids = ""
local wrote_show_name = {}
local function get_sprite( uri )
    if type(uri)~="string" then return false end
    uri = uri:sub(uri:len()-uri:reverse():find("/")+2)
    return(uri)
end
local function write_show_ids(show)

    local uri =
        get_sprite(show.banner) or
        get_sprite(show.cast)   or
        get_sprite(show.logo)   or
        ""
    if uri ~= "" then
        --all_poster_ids = all_poster_ids..uri.."\n"
        tv_show_sprites_map[uri] = nil
    end
    --[[
    if not wrote_show_name[show.show_name] then
        wrote_show_name[show.show_name] = true
        all_banner_ids = all_banner_ids..show.show_name..".jpg\n"
    end
    --]]
    banner_sprites_map[show.show_name..".jpg"] = nil
end
--]=]
local rm_these_jsons = "rm"

local function load_up_data(dir)
    collectgarbage("stop")

    if settings.channels then
        return settings.channels, settings.series
    end

    dir = dir or ""

    if loaded then error("data was already loaded") end

    loaded = true

    local channels_str = readfile( dir.."channels.json")

    if channels_str == nil then
        error("readfile('"..dir.."channels.json') failed")
    end

    channels_str = json:parse( channels_str )

    if channels_str == nil then
        error("'"..dir.."channels.json' is not vaild json")
    end

    local largest_chan = 0

    for num,channel in pairs(channels_str) do

        num = tonumber(num)
        if num < 100 then
        channels[num]  = channel

        largest_chan = math.max(largest_chan,num)

        channel.schedule = readfile(dir.."/channel_"..channel.id..".json")

        --t_map["channel_"..channel.id..".json"] = nil
        if channel.schedule == nil then
            print("readfile('"..dir.."channel_"..
                channel.id..".json') failed")
        else
---[[
            channel.schedule = json:parse( channel.schedule )

            if channel.schedule == nil then
                error("'"..dir.."channel_"..channel.id.."' is not valid json")
            end

            for i,show in ipairs(channel.schedule) do

                --request_banner(show.show_name)
                show.start_time_t =
                    extract_time(show.start_time)

                show.start_time_s = os_time(show.start_time_t)

                channel.on_now = (show.start_time_s <= curr_time__seconds) and
                    show or channel.on_now

                show.cast_list = cast_list
                if show.series_id ~= json_null then
                    --[[
                    if  series[show.series_id] == nil then
                        series[show.series_id] = {}
                    end


                    table.insert(series[show.series_id],show)
                    --]]
                    add_show_to_series(show.series_id,show)
                end

                --write_show_ids(show)
            end
            --]]
        end
        --else
            --rm_these_jsons = rm_these_jsons.." "..dir.."channel_"..channel.id..".json"
        end
    end
    fill_gaps_in_series()
    local prev_channel = channels[largest_chan]
    local last_nil
    for i = 1,largest_chan do

        if channels[i] ~= nil then
            channels.first    = channels.first or channels[i]
            channels[i].prev  = prev_channel
            prev_channel.next = channels[i]
            prev_channel      = channels[i]
            channels[i].number = i
            if last_nil then
                channels[last_nil] = i
                last_nil = nil
            end
        else
            if last_nil == nil then last_nil = i end
            channels[i] = false
        end
        --if channels[i] then print("\t",i,channels[i].name) end
    end
    --[[
    local i = 1
    while i <= largest_chan do
        if type(channels[i]) == "number" then i = channels[i] end
        print(i)
        i = i + 1
    end
    --]]
    --[[]
    if editor then
        editor:writefile(
            "rm_these_jsons.txt",
            rm_these_jsons
        )
    end
    --]]
    --[[
    if editor then
        local str = "rm"
        for k,v in pairs( t_map ) do
            str = str .. " " .. k
        end
        editor:writefile(
            "rm_these_jsons.txt",
            str
        )
    end
    --]]
    --[=[]]
    if editor then
        --[[
        editor:writefile(
            "all_poster_ids.txt",
            all_poster_ids
        )
        editor:writefile(
            "all_banner_ids.txt",
            all_banner_ids
        )
        --]]
        dumptable(tv_show_sprites_map)
        local str = ""
        for k,v in pairs( banner_sprites_map ) do
            str = str .. k .. "\n"
        end
        editor:writefile(
            "remove_these_banner_ids.txt",
            str
        )
        str = "stitcher"
        for k,v in pairs(tv_show_sprites_map) do
            str = str .." -g ".. k
        end
        editor:writefile(
            "remove_these_poster_ids.txt",
            str
        )
    end
    --]=]
    collectgarbage("restart")
    collectgarbage("collect")
    --settings.channels = channels
    --settings.series   = series
    return channels, series
end

return load_up_data
