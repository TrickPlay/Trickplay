--local source = {}

local adapter = {
	name = "GoogleImages",
	logoUrl = "adapter/Google/logo.jpg",
	{
		name = "public",
		caption = function(data) return "Url: "..data.responseData.results[1].visibleUrl.." Info: "..data.responseData.results[1].titleNoFormatting end,
		required_inputs = {
			query = "space",
		},
		albums = function() end,
		photos = function(search,current_pic) return "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..current_pic.."&imgsz=xxlarge" end,
		site = function(data) return data.responseData.results[1].unescapedUrl end
		
	}
}

function adapter:getCaption()
	-- some caption of the album
	return "hello"
end

function adapter:getAlbums()
	return {}
end

function adapter:getPhotos(album,start,num_images)

end


return adapter
