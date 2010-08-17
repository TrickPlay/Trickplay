adaptersTable = { "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google", "Google"}
picsTable = {}
adapters = {}

	START_INDEX = 1
NUM_SLIDESHOW_IMAGES =16 

--function startAdapter(selection)
for i =1, #adaptersTable do
	adapters[i] = dofile("adapter/"..adaptersTable[i].."/adapter.lua")
end
--end



function loadCovers(i,search, start_index)
	print (adapters[i].logoUrl)
	local request = URLRequest {
	url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..start_index.."&imgsz=medium",
	on_complete = function (request, response)
		local data = json:parse(response.body)
		site = data.responseData.results[1].unescapedUrl
      Load_Image(site,i)
	end
	}
	request:send()
end

function getNextUrl(search, index)
	
end

function slideShow()
	
	screen:clear()
end

