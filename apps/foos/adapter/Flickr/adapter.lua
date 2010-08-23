--local source = {}

local adapter = {
	name = "Flickr User Search",
	logoUrl = "adapter/Flickr/logo.png",
	logoscale = {0.3,0.3},
	{
		name = "public",
		caption = function(data) return "" end,
		required_inputs = {
			format = "LOGIN",
			query = "",
			user_id = "",
		},
		albums = function() end,
		photos = function(search,current_pic)
			return "http://www.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&format=json&api_key=1a1b2c811464d2d3423bb9200bbb4680&user_id=52863822@N05&nojsoncallback=1" 
		end,
		site = function(data) 
			local num_photos = #data.photos.photo
			current_pic = (current_pic-1)%num_photos + 1
			return "http://farm"..data.photos.photo[current_pic].farm..".static.flickr.com/"..data.photos.photo[current_pic].server.."/"..data.photos.photo[current_pic].id.."_"..data.photos.photo[current_pic].secret..".jpg" 
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
	url = "http://www.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&format=json&api_key=1a1b2c811464d2d3423bb9200bbb4680&user_id=52863822@N05&nojsoncallback=1",
	on_complete = function (request, response)
		local data = json:parse(response.body)
		for k,v in pairs(data.photos.photo[1]) do print(k,v) end
		-- http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}.jpg
		test = "http://farm"..data.photos.photo[start_index].farm..".static.flickr.com/"..data.photos.photo[start_index].server.."/"..data.photos.photo[start_index].id.."_"..data.photos.photo[start_index].secret..".jpg"
      Load_Image(test,i)
	end
	}
	request:send()
end

function adapter:getUserID(username)
	local request = URLRequest {		
		url = "http://www.flickr.com/services/rest/?method=flickr.people.findByUsername&username="..username.."&format=json&api_key=1a1b2c811464d2d3423bb9200bbb4680&nojsoncallback=1",
		on_complete = function(request,response)
			local data = json:parse(response.body)
			self[1].required_inputs.user_id = data.user.nsid
		end
	}
	request:send()
end

return adapter
