local get_channels_url =[[http://217.149.130.199/traxis/web/json/Channels/Props/LogicalChannelNumber,Name,Pictures/Sort/LogicalChannelNumber?output=json]]

function get_channel_list(f)
    local req = URLRequest{
        url = get_channels_url,
        on_complete = function(self,response)
            if response.failed then
                return
            elseif response.code ~= 200 then
                return
            elseif response.body == nil then
                return
            end
            
            --print( response.body )
            
            response = json:parse(response.body)
            
            if response == nil then
                return
            end
            
            f(response)
        end
    }
    
    req:send()
end

local scheduling_url = [[http://217.149.130.199/traxis/web/json/Channels/Sort/Name/props/Events,Name]]
function get_scheduling(f)
    --expected input
    --"2012-10-23T17:50:00Z"
    local curr_time = os.date('*t')
    curr_time.hour = curr_time.hour - 1
    local start_time = os.date('*t',os.time(curr_time))
    curr_time.hour = curr_time.hour + 1
    curr_time.hour = curr_time.day + 1
    local   end_time = os.date('*t',os.time(curr_time))
    dumptable(curr_time)
    dumptable(start_time)
    dumptable(end_time)
    ---[[
    start_time = 
        string.format("%04d",start_time.year) .."-"..
        string.format("%02d",start_time.month).."-"..
        string.format("%02d",start_time.day)  .."T"..
        string.format("%02d",start_time.hour) ..":"..
        string.format("%02d",start_time.min)  ..":"..
        string.format("%02d",start_time.sec)  .."Z"
        --]]
    end_time = 
        string.format("%04d",end_time.year) .."-"..
        string.format("%02d",end_time.month).."-"..
        string.format("%02d",end_time.day)  .."T"..
        string.format("%02d",end_time.hour) ..":"..
        string.format("%02d",end_time.min)  ..":"..
        string.format("%02d",end_time.sec)  .."Z"
        --]]
    print(start_time,end_time)
    local req = URLRequest{
        url = scheduling_url,
        timeout = 60*5,
        method = "PUT",
        body = [[<?xml version="1.0" encoding="utf-8"?><SubQueryOptions><QueryOption path="Events">/Filter/AvailabilityEnd&gt;]]..start_time..[[,AvailabilityStart&lt;]]..end_time..[[/Sort/AvailabilityStart/props/Titles,AvailabilityStart,AvailabilityEnd,DurationInSeconds</QueryOption><QueryOption path="Events/Titles">/props/Name,Genres</QueryOption></SubQueryOptions>]],
        --[[
        headers = {
        ["Accept"]="*/*",
["Accept-Charset"]="ISO-8859-1,utf-8;q=0.7,*;q=0.3",
["Accept-Encoding"]="gzip,deflate,sdch",
["Accept-Language"]="en-US,en;q=0.8",
["Access-Control-Request-Headers"]="origin, content-type",
["Access-Control-Request-Method"]="PUT",
["Connection"]="keep-alive",
["Origin"]="http://localhost",
["Referer"]="http://localhost/dawn/build/",
["User-Agent"]="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/536.11 (KHTML, like Gecko) Ubuntu/12.04 Chromium/20.0.1132.47 Chrome/20.0.1132.47 Safari/536.11",
        },
        --]]
        on_complete = function(self,response)
            print("here")
            if response.failed then
                print("response.failed")
                return
            elseif response.code ~= 200 then
                print("response.code ~= 200")
                return
            elseif response.body == nil then
                print("response.body == nil")
                return
            end
            
            --print( response.body )
            
            response = json:parse(response.body)
            
            if response == nil then
                print("json:parse(response.body) == nil")
                return
            end
            
            f(response)
        end
    }
    print("sending")
    req:send()
end