adaptersTable = { "Google", "Google", "Google", "Google", "Google", "Google" }
picsTable = {}
adapters = {}

	START_INDEX = 1
NUM_SLIDESHOW_IMAGES =16 

function startAdapter(selection)
	dofile("adapter/"..adaptersTable[selection].."/adapter.lua")
end

function loadCovers()
	search = "scene"
	for i =1, 16 do
		local request = URLRequest {
		url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..i.."&imgsz=xxlarge",
		on_complete = function (request, response)
			local data = json:parse(response.body)
         site = data.responseData.results[1].unescapedUrl
         Load_Image(site,i)
		end
		}
		request:send()
	end
end

