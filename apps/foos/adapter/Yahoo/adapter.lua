--[[source = {}

function showYahooImage(search,x,y,index)
	local request = URLRequest {
		url = "http://search.yahooapis.com/ImageSearchService/V1/imageSearch?appid=YahooDemo&query="..search.."&results=1&output=json",
		
		on_complete = function (request, response)
			local data = json:parse(response.body)
			local image = Image {
				src = data.ResultSet.Result[index].ClickUrl,
				x = x,
				y = y
			}
			screen:add(image)
		end
	}
	request:send()
end

return source

]]

local adapter = {
	name = "GoogleImages",
	logoUrl = "adapter/Google/logo.jpg",
	{
		name = "public",
		caption = adapter:getCaption(),
		required_inputs = {
			query = adapter:getQuery(),
		},
		albums = adapter:getAlbums(),
		photos = adapter:getPhotos(album, start, num_images)
	}
}

function adapter:getQuery()
	return "National+Geographic"
end

function adapter:getCaption()
	-- some caption of the album
	return "hello"
end

function adapter:getAlbums()
	return {}
end

function adapter:getPhotos(album,start,num_images)
	sites = {}
	search = self:getQuery()
	for i = start, start + num_images do
		local request = URLRequest {
		url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..i.."&imgsz=xxlarge",
		on_complete = function (request, response)
			local data = json:parse(response.body)
			table.insert(sites,data.responseData.results[1].unescapedUrl)
		end
		}
		request:send()
	end
	return sites
end


return adapter

