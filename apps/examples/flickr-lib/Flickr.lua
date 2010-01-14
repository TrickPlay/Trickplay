dofile("Json.lua")

Flickr = {
	logo_url = "http://userlogos.org/files/logos/sandwiches/flickr0.png",
	cc_interesting = "http://api.flickr.com/services/rest/?method=flickr.photos.search&license=4%2C5%2C6%2C7&sort=interestingness-desc&safe_search=1&content_type=1&media=photos&extras=license%2Cowner_name%2Curl_t%2Curl_m%2Curl_o&format=json&nojsoncallback=1",

	get_thumb_url = function( photo )
		return photo.url_t
	end,
	
	get_medium_url = function( photo )
		return photo.url_m
	end,
	
	get_original_url = function( photo )
		return photo.url_o
	end,

	fetch_photos = function(api_key, base_url, per_page, page_num, photos, completion)
		-- Figure out which page to fetch next based on how many are already in the index

		-- Set up the request
	   local request = URLRequest
            {
            	 url = Flickr.cc_interesting.."&per_page="..per_page.."&page="..page_num.."&api_key="..api_key,
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
