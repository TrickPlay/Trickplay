screen:show()


req = URLRequest{
	url = "http://stream.twitter.com/1/statuses/filter.json&track=\"#glee\"",
	on_response_chunk = function(request,response)
		if response.body then
			print(response.body)
		else
			print(response.status)
		end
	end
}
req:stream()



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