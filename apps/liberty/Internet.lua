local get_channels_url =[[http://217.149.130.199/traxis/web/json/Channels/Props/LogicalChannelNumber,Name,PlayInfos,IsViewableOnCpe,Pictures/Sort/LogicalChannelNumber?output=json
]]

function get_channel_list(f)
    local req = URLRequest{
        url = get_channels_url,
        on_complete = function(self,response)
            if response.failed then
            elseif response.code ~= 200 then
            elseif response.body == nil then
            end
            
            --print( response.body )
            
            response = json:parse(response.body)
            
            if response == nil then
            end
            
            f(response)
        end
    }
    
    req:send()
end