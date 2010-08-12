local source = {}

function showGoogleImage(search,index)
	local request = URLRequest {
		url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..index.."&imgsz=xxlarge",
		on_complete = function (request, response)
			
			local data = json:parse(response.body)
			table.insert(source, data.responseData.results[1].unescapedUrl)
			if (index+1 < START_INDEX + NUM_SLIDESHOW_IMAGES) then
				showGoogleImage(search,index+1)
			else
				getUrls(source)
			end

		end
	}
	request:send()
end
showGoogleImage("National+Geographic", START_INDEX)

