
Flickr = {
	logo_url = "assets/flickr0.tif",
	cc_interesting_url = "http://api.flickr.com/services/rest/?method=flickr.photos.search&license=4%2C5%2C6%2C7%2C8&sort=interestingness-desc&safe_search=1&content_type=1&media=photos&extras=license%2Cowner_name%2Curl_t%2Curl_m%2Curl_o&format=json&nojsoncallback=1",

	license_info_url = "http://api.flickr.com/services/rest/?method=flickr.photos.licenses.getInfo&format=json&nojsoncallback=1",

	-- Fetch license info for available Flickr licenses, and append it into the licenses table
	license_info = function(api_key, licenses)
	
		local extract_short_license = function(url)
			local result
			_, _, result = string.find(url, "http:\/\/creativecommons.org\/licenses\/([%a%-]+)\/")
			if(nil == result) then
				result = "free"
			end
			return result
		end
	
		local data = json:parse( URLRequest( Flickr.license_info_url.."&api_key="..api_key):perform().body )
		for i, license in ipairs( data.licenses.license ) do
		licenses[license.id] =	{
											name = license.name,
											url = license.url,
											short = extract_short_license(license.url),
										}
		end
	end,

	get_thumb_url = function( photo )
		if photo then
			return photo.url_t
		else
			return nil
		end
	end,
	
	get_medium_url = function( photo )
		if photo then
			return photo.url_m
		else
			return nil
		end
	end,
	
	get_original_url = function( photo )
		if photo then
			return photo.url_o
		else
			return nil
		end
	end,

	-- Fetch some photo metadata from Flickr API, using the passed base URL.
	-- Append the metadata for each image into "photos", and then execute completion:callback()
	fetch_photos =
	function(api_key, base_url, per_page, page_num, photos, completion)
		-- Set up the request
		local request = URLRequest
		{
			url = base_url.."&per_page="..per_page.."&page="..page_num.."&api_key="..api_key,
			on_complete =
			function( request , response )

				local data = json:parse( response.body )
				if(0 == #(data.photos.photo)) then
					-- Bug in flickr API sometimes returns no results: RESEND
					print("FLICKR BUG!!  RESEND: ",request.url)
					request:send()
					return
				end

				for i , photo in ipairs( data.photos.photo ) do
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
