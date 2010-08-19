local adapter = {
	name = "Yahoo Image Search",
	logoUrl = "adapter/Yahoo/logo.png",
	logoscale = {1,1},
	{
		name = "public",
		caption = function(data) return "" end,
		required_inputs = {
			format = "QUERY",
			query = "space",
		},
		albums = function() end,
		photos = function(search,current_pic) return "http://search.yahooapis.com/ImageSearchService/V1/imageSearch?appid=YahooDemo&query="..search.."&results=1&start="..current_pic.."&output=json" end,
		site = function(data) 
		--	return data.responseData.results[1].unescapedUrl
			return data.ResultSet.Result[1].ClickUrl or ""
		end
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
	local request = URLRequest {
	url = "http://search.yahooapis.com/ImageSearchService/V1/imageSearch?appid=YahooDemo&query="..search.."&results=1&start="..start_index.."&output=json",
	on_complete = function (request, response)
		local data = json:parse(response.body)
		for k,v in pairs(data) do print(k,v) end

		site = data.ResultSet.Result[1].ClickUrl
      Load_Image(site,i)
	end
	}
	request:send()
end

return adapter
