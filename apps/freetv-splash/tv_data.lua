local loaded = false


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

local function load_up_data(dir)

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

        channels[num]  = channel

        largest_chan = math.max(largest_chan,num)

        channel.schedule = readfile(dir.."/channel_"..channel.id..".json")

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

                show.start_time_t =
                    extract_time(show.start_time)

                if show.series_id ~= json.null then

                    if  series[show.series_id] == nil then
                        series[show.series_id] = {}
                    end


                    table.insert(series[show.series_id],show)
                end

            end
            --]]
        end
    end

    local last_nil
    for i = 1,largest_chan do

        if channels[i] ~= nil then
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
    collectgarbage("stop")
    return channels, series
end

return load_up_data
