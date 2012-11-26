local get_channels_url =[[http://217.149.130.199/traxis/web/json/Channels/Props/LogicalChannelNumber,Name,Pictures/Sort/LogicalChannelNumber?output=json]]

function get_channel_list(f)
    
    if editor then
        local response = readfile("local_data/get_channel_list")
        if type(response) == "string" then
            response = json:parse(response)
            if response ~= nil then
                dolater(f,response)
                return
            end
        end
        
    end
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
            
            if editor then 
                editor:writefile("local_data/get_channel_list",response.body)
            end
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
    
    local received_schedule = function(response)
        
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
        
        if editor then 
            editor:writefile("local_data/get_scheduling",response.body)
            meta.time_scheduling_was_requested = os.time()
            save_meta()
        end
        response = json:parse(response.body)
        
        if response == nil then
            print("json:parse(response.body) == nil")
            return
        end
        
        f(response)
        
        return true
    end
    local function get_local_data(t)
        local resp = readfile("local_data/get_scheduling")
        if type(resp) == "string" then
            resp = json:parse(resp)
            if t ~= nil then
                dolater(f,resp,t)
            end
        end
    end
    
    local curr_time = os.date('*t')
    if editor and meta.time_scheduling_was_requested then
        --[[
        local t = tonumber(meta.time_scheduling_was_requested)
        curr_time.hour=curr_time.hour - 11
        --dumptable(os.date('*t',t))
        if os.time(curr_time) < t then
            print("local data is less than a 11 hours old")
            get_local_data()
            return
        end
        --]]
        get_local_data(meta.time_scheduling_was_requested)
    end
    
    curr_time = os.date('*t')
    --expected input
    --"2012-10-23T17:50:00Z"
    curr_time.hour = curr_time.hour - 1
    --curr_time.day = curr_time.day - 3
    local start_time = os.date('*t',os.time(curr_time))
    curr_time.hour = curr_time.hour + 1
    curr_time.day = curr_time.day + 1
    local   end_time = os.date('*t',os.time(curr_time))
    --dumptable(curr_time)
    --dumptable(start_time)
    --dumptable(end_time)
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
    print("Requesting scheduling for the interval",start_time,end_time)
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
            if not received_schedule(response) then
                get_local_data(meta.time_scheduling_was_requested)
                return
            end
        end
    }
    print("sending")
    req:send()
end



--:~~2F~~2Fschange.com~~2F9c4bc73b-48d6-48a1-be61-cd684e482839
function get_root_categories(f)
    local req = URLRequest{
        url = [[http://217.149.130.199/traxis/web/json/RootCategories/Props/Name,IsRoot,ChildCategories,ChildCategoryCount?CpeId=device1]],
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
--:~~2F~~2Fschange.com~~2F9c4bc73b-48d6-48a1-be61-cd684e482839
function get_category_info(id,f,parent,only_tranverse_this)
    local req = URLRequest{
        url = [[http://217.149.130.199/traxis/web/json/Category/]]..id..[[/Props/Name,ShortSynopsis,IsAdult,ChildCategories,ChildCategoryCount,TitleCount,ProductCount,ApplicationCount?CpeId=device1]],
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
            
            f(response,parent,only_tranverse_this)
        end
    }
    
    req:send()
end

--:~~2F~~2Fschange.com~~2F9c4bc73b-48d6-48a1-be61-cd684e482839
function get_titles(id,f,parent,only_tranverse_this)
    local req = URLRequest{
        url = [[http://217.149.130.199/traxis/web/json/Category/]]..id..[[/Props/Titles?CpeId=device1]],
        method="PUT",
        body = [[<?xml version="1.0" encoding="utf-8"?><SubQueryOptions xmlns="urn:eventis:traxisweb:1.0"><QueryOption path="Titles">/props/Contents,Name,Pictures,ShortSynopsis,IsPreview,IsFeature,IsViewableOnCpe</QueryOption><QueryOption path="Titles/Contents">/props/IsHd,Is3d,EntitlementState,Aliases,Products</QueryOption><QueryOption path="Titles/Contents/Products">/props/Type,Currency,IsAvailable,ListPrice,OfferPrice</QueryOption></SubQueryOptions>]],
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
            
            f(response,parent,only_tranverse_this)
        end
    }
    
    req:send()
end