--local source = {}

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
	local request = URLRequest {
	url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..i.."&imgsz=xxlarge",
	on_complete = function (request, response)
		local data = json:parse(response.body)
		table.insert(sites,data.responseData.results[1].unescapedUrl)
		Load_Image(site,i)
	end
	}
	request:send()
end


return adapter
