local adapter = {
	name = "Picasa Photostream",
	logoUrl = "adapter/Picasa/logo.png",
	logoscale = {0.1,0.1},
	hasImages = true,
	{
		name = "public",
		caption = function(data) return "" end,
		required_inputs = {
			format  = "QUERY",
			query   = "",
			user_id = "",
		},
		albums = function() end,
		photos = function(search,current_pic, i)
		return "http://picasaweb.google.com/data/feed/api/all?max-results=1&q="..search.."&start-index="..current_pic
		end,
		site = function(json,i) 
                       return json.content.result.primary.media[1].url
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

function adapter:loadCovers(slot,search, start_index)

    local request = URLRequest 
    {
        url = "http://picasaweb.google.com/data/feed/api/all?"..
              "max-results=1&q="..search.."&start-index="..start_index,
        on_complete = function (request, response)
            --local data = json:parse(response.body)
--dumptable(data)
            --local src = data.content.result.primary.media[1].url
            local src = response.feed.entry
--print("\n\n\t"..src.."\n\n")
            Load_Image(adapter,src,search,slot)
        end
    }
    request:send()
end
return adapter
