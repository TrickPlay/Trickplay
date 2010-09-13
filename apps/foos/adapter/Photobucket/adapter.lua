local developer_key = "149830454"
local private_key = "7cafcca9b6375f261cde74ce131124f5"
local adapter = {
	name = "PhotoBucket Photostream",
	logoUrl = "adapter/Photobucket/logo.png",
	logoscale = {0.1,0.1},
	hasImages = true,
	{
		name = "public",
		caption = function(data) return "" end,
		required_inputs = {
			format = "QUERY",
			query = "",
			user_id = "",
		},
		albums = function() end,
		photos = function(search,current_pic, i)
		return oauth_signing({["format"]="json",["perpage"]="1",["page"]=current_pic},
                            "http://api.photobucket.com/search/"..search,"GET")
		end,
		site = function(json,i) 
                       return json.content.result.primary.media[1].url
--[[
			num_photos = #data.photos.photo
			local start_index = (i-1)%num_photos + 1
			return "http://farm"..data.photos.photo[start_index].farm..
                               ".static.flickr.com/"
                               ..data.photos.photo[start_index].server..
                               "/"..data.photos.photo[start_index].id..
                               "_"..data.photos.photo[start_index].secret..
                               ".jpg"--]]
		end
		
	}
}

function adapter:getCaption()
	-- some caption of the album
	return "hello"
end

function adapter:getAlbums()
	return {}
end

function adapter:getPhotos(album,start,num_images)

end

function adapter:loadCovers(slot,search, start_index)

    local request = URLRequest 
    {
        url = oauth_signing({["format"]="json",["perpage"]="1",["page"]=
               start_index},"http://api.photobucket.com/search/"..
               urlencode(search).."/image","GET"),
        on_complete = function (request, response)
            local data = json:parse(response.body)
dumptable(data)
            local src = data.content.result.primary.media[1].url
print("\n\n\t"..src.."\n\n")
            Load_Image(adapter,src,search,slot)
        end
    }
    request:send()
end


    --make the nonce (a randomized 32-character hex string)
function make_nonce()
    local nonce = ""
    local hex = {"a","b","c","d","e","f"}
    for i = 1,32 do
        local n = math.random(0,15)
        if n >= 10 then
            nonce = nonce .. hex[n-9]
        else
            nonce = nonce .. n
        end
    end
    return nonce
end
function urlencode (s)
     s = string.gsub(s, "([:/&=+%c])", function (c)
           return string.format("%%%02X", string.byte(c))
         end)
     s = string.gsub(s, " ", "%20")
     return s       
end
--[[
function urlencode(input)
    input = string.gsub(input," ","%%20")
    input = string.gsub(input,"%%%%","%%25")
    --yes this means that the '%20's will be %2520, its stupid... i know

    input = string.gsub(input,"&","%%26")    
    input = string.gsub(input,"/","%%2F")
    input = string.gsub(input,":","%%3A")
    input = string.gsub(input,"=","%%3D")
    return input
end
--]]
function oauth_signing(param_list, url_path, http_method)
    --get the nonce
    local nonce = make_nonce()

    --the required keys for the api signature
    local lex_keys =
    {
        "oauth_consumer_key",
        "oauth_nonce",
        "oauth_signature_method",
        "oauth_timestamp",
        "oauth_version"
    }
    local lex_vals = 
    {
        developer_key,
        nonce,
        "HMAC-SHA1",
        os.time(),
        "1.0",        
    }
    --insert the other params alphabetically
    for k,v in pairs(param_list) do
        local pos = 1
        for i = 1,#lex_keys+1 do
            pos = i
            if lex_keys[i] == nil or k < lex_keys[i] then break end
        end
        table.insert(lex_keys, pos, k)
        table.insert(lex_vals, pos, v)
    end

    --turn the params into a string
    local params_str = ""
    for i = 1, #lex_keys do
        params_str = params_str .. lex_keys[i].."="..urlencode(lex_vals[i])
        if i ~= #lex_keys then
            params_str = params_str .. "&"
        end
    end
--[[
url_path = "http://api.photobucket.com/search/me/image"
params_str = "format=xml&oauth_consumer_key=00000000&oauth_nonce=6e47e8127a2d7705a2d203e44cc4e983&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1205810735&oauth_token=28.1&oauth_version=1.0&perpage=2"
--]]
    --get the sig
    local base_string = http_method.."&"..urlencode(url_path).."&"..
                                          urlencode(params_str)
print(private_key.."&", base_string)
    local sig = urlencode(base64_encode( hmac_sha1( private_key.."&" , 
                                          base_string , true ) ) )
    
--print(sig)
--debug()
    --add the signature to the params string
    local pos = 1
    for i = 1,#lex_keys+1 do
        pos = i
        if lex_keys[i] == nil or "oauth_signature" < lex_keys[i] then break end
    end
    table.insert(lex_keys,pos,"oauth_signature")
    table.insert(lex_vals, pos, sig)
    params_str = ""
    for i = 1, #lex_keys do
        params_str = params_str .. lex_keys[i].."="..lex_vals[i]
        if i ~= #lex_keys then
            params_str = params_str .. "&"
        end
    end

    --return the authenticated URL
    print(url_path.."?"..params_str.."\n\n\n")
    return url_path.."?"..params_str
end
return adapter

