--local source = {}

local adapter = {
	name = "Google Images Search",
	logoUrl = "adapter/Google/logo.png",
	logoscale = {0.3,0.3},
	{
		name = "public",
		caption = function(data) return "Url: "..data.responseData.results[1].visibleUrl.."\nInfo: "..data.responseData.results[1].titleNoFormatting end,
		required_inputs = {
			format = "QUERY",
			query = "space",
		},
		albums = function() end,
		photos = function(search,current_pic) return "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..current_pic.."&imgsz=xxlarge" end,
		site = function(data) return data.responseData.results[1].unescapedUrl or "" end
		
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

function adapter:loadCovers(i,search, start_index)
	print (adapters[i].logoUrl)
	local request = URLRequest {
	url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q="..search.."&rsz=1&start="..start_index.."&imgsz=xxlarge",
	on_complete = function (request, response)
		local data = json:parse(response.body)
		
		site = data.responseData.results[1].unescapedUrl or ""
      Load_Image(site,i)
--		print(i)
--		debug()

	end
	}
	request:send()
end

return adapter
