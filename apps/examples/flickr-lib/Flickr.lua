dofile("Json.lua")

Flickr = {
	logo_url = "http://userlogos.org/files/logos/sandwiches/flickr0.png",
	cc_interesting_url = "http://api.flickr.com/services/rest/?method=flickr.photos.search&license=4%2C5%2C6%2C7&sort=interestingness-desc&safe_search=1&content_type=1&media=photos&extras=license%2Cowner_name%2Curl_t%2Curl_m%2Curl_o&format=json&nojsoncallback=1",

	license_info_url = "http://api.flickr.com/services/rest/?method=flickr.photos.licenses.getInfo&format=json&nojsoncallback=1",

	-- Fetch license info for available Flickr licenses, and append it into the licenses table
	license_info = function(api_key, licenses)
	
		local extract_short_license = function(url)
			local result
			_, _, result = string.find(url, "http:\/\/creativecommons.org\/licenses\/([%a%-]+)\/")
			return result
		end
	
		local json = URLRequest( Flickr.license_info_url.."&api_key="..api_key):perform().body
      json = Json.Decode( json )
      for i, license in ipairs( json.licenses.license ) do
      	licenses[license.id] =	{
      										name = license.name,
												url = license.url,
												short = extract_short_license(license.url),
											}
		end
	end,

	get_thumb_url = function( photo )
		return photo.url_t
	end,
	
	get_medium_url = function( photo )
		return photo.url_m
	end,
	
	get_original_url = function( photo )
		return photo.url_o
	end,

	-- Fetch some photo metadata from Flickr API, using the passed base URL.
	-- Append the metadata for each image into "photos", and then execute completion:callback()
	fetch_photos = function(api_key, base_url, per_page, page_num, photos, completion)
		-- Set up the request
	   local request = URLRequest
            {
            	 url = base_url.."&per_page="..per_page.."&page="..page_num.."&api_key="..api_key,
                on_complete =
                    function( request , response )
                
                        local json = Json.Decode( response.body )
                        
                        for i , photo in ipairs( json.photos.photo ) do
									 table.insert(photos, photo)
                        end

                        if completion then
                            completion:callback()
                        end
                    end
            }

		request:send()
	end

}
