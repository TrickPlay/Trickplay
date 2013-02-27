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
local api_key = "e68b53548e8e6a71565a1385dc99429f"

--Grabs the creative commons licensing information
local licenses_acquired = false
local licenses = {}
local license_info_url =
	"http://api.flickr.com/services/rest/?"..
	"method=flickr.photos.licenses.getInfo"..
	"&format=json&nojsoncallback=1"

local extract_short_license = function(url)
	local result
	_, _, result = string.find(url, "http://creativecommons.org/"..
									"licenses/([%a%-]+)/")
	if(nil == result) then
		result = "free"
	end
	return result
end

--Request to CreativeCommmons.org
local req = URLRequest{
	url = license_info_url.."&api_key="..api_key,
	on_complete = function(request,response)
		if response.body == nil then return end
		local data = json:parse( response.body )
		for i, license in ipairs( data.licenses.license ) do
			licenses[license.id] =
			{
				name  = license.name,
				url   = license.url,
				short = extract_short_license(license.url),
			}
		end
		licenses_acquired = true
	end
}
req:send()


Flickr_Interesting = Class(nil,function(adapter, slot_ref,search_term,...)
	--slot on the front page
	local slot = slot_ref
	--save the URLEncoded search term
	local search = string.gsub(search_term,"%%20"," ")
	--keeps track of current search page (50 results per page)
	local page_num = 1
	--saved img urls from the search queries
	adapter.photo_list = {}
	--an attempt to prevent the user from flooding Flickr with requests
	local outbound_requests = {}


	--gets the list of URLs from a search query
	function adapter:get_interesting_photos(i)
		local num_retrys = 0
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
		--if a parameter indicates the page requested
		local page = page_num
		if i ~= nil then page = i end
		--checks if a request for this page has already been sent
		local already_requested = false
		for i = 1, #outbound_requests do
			if outbound_requests[i] == page then
				already_requested = true
			end
		end
		if already_requested then return end
		print("requesting",page)

		outbound_requests[#outbound_requests + 1] = page
		local request  = URLRequest
		{
			url = base_url.."&per_page=50&page="..page..
					"&api_key="..api_key..
					"&text="..search,
			on_complete =
			function( request , response )
print("response",num_retrys)
				--remove the request from the outbound list
				for i = 1, #outbound_requests do
					if outbound_requests[i] == page then
						table.remove(outbound_requests,i)
						break
					end
				end
				--response is bad, try again
				if response == nil or response.body == nil then
					if num_retrys <= 3 then
						num_retrys = num_retrys+1
						local tmp = Timer{}
						tmp.interval = 1000
						function tmp.on_timer()
							tmp:stop()
							tmp = nil
							print("FLICKR BUG!!  RESEND: ",request.url)
							request:send()
						end
						tmp:start()
					end
					return
				end
				local data = json:parse( response.body )
				--if response is empty
				if((0 == #(data.photos.photo)) and page_num <= 5 ) or
					data.photos == nil then
						if num_retrys <= 3 then
							num_retrys = num_retrys+1
						local tmp = Timer{}
						tmp.interval = 1000

						function tmp.on_timer()
							tmp:stop()
							tmp = nil
							print("FLICKR BUG!!  RESEND: ",request.url)
							request:send()
						end
						tmp:start()
					end
					return
				end
				--Otherwise, grab the URLs
				--dumptable( data.photos.photo )
				for i , photo in ipairs( data.photos.photo ) do
					adapter.photo_list[(page-1)*50 +i]= photo
				end

				--load picture in the front page
				local i = math.random(5)
				local foto,lic_tit, lic_auth
				foto,lic_tit, lic_auth = adapter:get_photos_at(i,true)
				LoadImg(foto,slot,lic_tit, lic_auth, i)
			end
		}
		request:send()

	end
	function adapter:get_photos_at(i,thumb)
		local lic_tit, lic_auth
		--print(adapter.photo_list[i])
		--dumptable(adapter.photo_list[i])
		--i=i+1
		if  adapter.photo_list[i] == nil then
			self:get_interesting_photos(math.ceil(i/50))

			return "","",""
		end
		if i == #adapter.photo_list -30 then
			page_num = page_num + 1
			self:get_interesting_photos()
		end
		if licenses_acquired then
			lic_tit  = "\""..adapter.photo_list[i].title.."\" ©"
			lic_auth = 	adapter.photo_list[i].ownername..
						" ("..licenses[adapter.photo_list[i].
							license].short..")"
		else
			lic_tit = "Acquiring Licenses..."
			lic_auth = ""
		end
--[[
		if thumb then
			return adapter.photo_list[i].url_m,  lic_tit, lic_auth
		else

local lg_img = adapter.photo_list[i].url_m

			return lg_img, lic_tit, lic_auth
		end
--]]
local l = string.gsub( adapter.photo_list[i].url_m , "(.*)%.([^%.]*)$" , "%1_b.%2" , 1 )
		return adapter.photo_list[i].url_m,  lic_tit, lic_auth, l
	end
end)


--[==[
--Was needed for Photobucket, but they were removed as a source
--maybe useful to keep around

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
