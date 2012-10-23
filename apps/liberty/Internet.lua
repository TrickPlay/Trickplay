local get_channels_url =[[http://217.149.130.199/traxis/web/json/Channels/Props/LogicalChannelNumber,Name,PlayInfos,IsViewableOnCpe,Pictures/Sort/LogicalChannelNumber?output=json
]]

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