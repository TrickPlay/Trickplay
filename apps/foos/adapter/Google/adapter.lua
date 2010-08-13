--local source = {}

function showGoogleImage(search,index)
	local request = URLRequest {
		url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..index.."&imgsz=medium",
		on_complete = function (request, response)
			
			local data = json:parse(response.body)
                        site = data.responseData.results[1].unescapedUrl
			picsTable[index] = site
                        Load_Image(site,index)
			if (index+1 < START_INDEX + NUM_SLIDESHOW_IMAGES) then
				showGoogleImage(search,index+1)
			else
				getUrls(picsTable)
			end

		end
	}
	request:send()
end
showGoogleImage("stuff", START_INDEX)

