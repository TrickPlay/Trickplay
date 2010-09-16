--[[
    local adapters = 
    {
        { name = "Google Search",
          logosrc = "adapter/Google/logo.png",
          search_request = function(search_term,search_index)
              return "http://ajax.googleapis.com/ajax/services/search/"..
                     "images?v=1.0&q="..search_term.."&rsz=1&start="..
                     search_index.."&imgsz=xxlarge"
          end,
          search_response = function(response)
              if (type(data.responseData) == "table"  and 
                 data.responseData.results[1] ~= nil) then
                  return data.responseData.results[1].unescapedUrl
              else
                  return "" 
              end
          end,
        },
        ["Yahoo"]  = function(search_term,search_index)
        end,
        ["Flickr"] = function(search_term,search_index)
        end,
        ["Photobucket"] = function(search_term,search_index,f)

        end
    }

Flickr_User = Class(nil,function(adapter, slot_ref, info, ...)
	local api_key = "e68b53548e8e6a71565a1385dc99429f"
	local slot = slot_ref
	--right now, ignore query type, assume user search
	local username 	= info
	local userid	= nil
	local userid_request = URLRequest
	{
		url = "http://www.flickr.com/services/rest/?"..
			"method=flickr.people.findByUsername&"..
			"username="..username..
			"&format=json"..
			"&api_key="..api_key..
			"&nojsoncallback=1",
		on_complete = function(request,response)
			local data = json:parse(response.body)
			if data.user then
				userid = data.user.nsid
				--CALL THE RANDOM-COVER-DRAW FUNCTION
			else
				error("could not get user ID, insert proper"..
				" error handling here")
			end
		end
	}
	userid_request:send()
	function adapter:get_photo_url(i)
		if userid ~= nil then
			local pic_request = URLRequest
			{
				url = "http://www.flickr.com/services/rest/?"..
					"method=flickr.people.getPublicPhotos"..
					"&format=json"..
					"&api_key="..api_key..
					"&user_id="..userid..
					"&nojsoncallback=1",
				on_complete = function(request,response)
					local data = json:parse(response.body)
					local start_index = (i-1)%#data.photos.photo + 1
					local src = "http://farm"..data.photos.photo[start_index].farm..
                               ".static.flickr.com/"
                               ..data.photos.photo[start_index].server..
                               "/"..data.photos.photo[start_index].id..
                               "_"..data.photos.photo[start_index].secret..
                               ".jpg"
					Load_Image(adapter,site,search,slot)
				end
			}
		else
		end
	end
end)
--]]

Flickr_Interesting = Class(nil,function(adapter, slot_ref,search_term,...)
	local api_key = "e68b53548e8e6a71565a1385dc99429f"
	local slot = slot_ref
	local search = string.gsub(search_term,"%%20"," ")
    local interesting_photos = nil


	function adapter:get_interesting_photos()--i,thumb,callback)
		local base_url = 
				"http://api.flickr.com/services/rest/?"..
				"method=flickr.photos.search"..
				"&license=4%2C5%2C6%2C7%2C8"..
				"&sort=interestingness-desc"..
				"&safe_search=1"..
				"&content_type=1"..
				"&media=photos"..
				"&extras=license%2Cowner_name%2Curl_t%2Curl_m%2Curl_o"..
				"&format=json&nojsoncallback=1"
		local request  = URLRequest
		{
			url = base_url.."&per_page=200&page=1&api_key="..api_key..
					"&tag="..search,
			on_complete =
			function( request , response )

				interesting_photos = json:parse( response.body )
---[[
				if(0 == #(interesting_photos.photos.photo)) then
					-- Bug in flickr API sometimes returns no results: RESEND
					print("FLICKR BUG!!  RESEND: ",request.url)
					request:send()
					return
				end
				LoadImg(adapter:get_photos_at(math.random(5),true),slot)
--]]
--[[
				local src = nil
				if thumb then
					src=data.photos.photo[i].url_m
				else
					src=data.photos.photo[i].url_o
				end
				callback(src,slot)
--]]
			end
		}
		request:send()

	end
	function adapter:get_photos_at(i,thumb)
i=i+1
print(i)
		if interesting_photos == nil then
			return ""
		elseif thumb then
			return interesting_photos.photos.photo[i].url_m
		else
			return interesting_photos.photos.photo[i].url_m
		end
	end
end)


--[==[

---------------------------------------------------
----             OAUTH SIGNING                 ----
---------------------------------------------------

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
function urlencode(str)
   if (str) then
       str = string.gsub (str, "\n", "\r\n")
       str = string.gsub (str, "([^%w ])",
                function (c) 
                    return string.format ("%%%02X", string.byte(c))
                 end
             )
       str = string.gsub (str, " ", "+")
   end
   return str        
end
--[=[
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
--]=]
function oauth_signing(param_list, url_path, http_method)
    --get the nonce
    local nonce = make_nonce()

    --the required keys for the api signature
    local lex_keys =
    {
        "oauth_consumer_key",
        "oauth_nonce",
        "oauth_signature_mehtod",
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
        params_str = params_str .. lex_keys[i].."="..lex_vals[i]
        if i ~= #lex_keys then
            params_str = params_str .. "&"
        end
    end

    --get the sig
    local base_string = http_method.."&"..urlencode(url_path).."&"..
                                          urlencode(params_str)
    local sig = hmac_sha1(private_key.."&",base_string)
    

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
--]==]
