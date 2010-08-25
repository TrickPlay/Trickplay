--local source = {}
num_photos = 1

local adapter = {
	name = "Flickr User Photostream",
	logoUrl = "adapter/Flickr/logo.png",
	logoscale = {0.1,0.1},
	{
		name = "public",
		caption = function(data) return "" end,
		required_inputs = {
			format = "LOGIN",
			query = "",
			user_id = "",
		},
		albums = function() end,
		photos = function(search,current_pic, i)
      	return "http://www.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&format=json&api_key=e68b53548e8e6a71565a1385dc99429f&user_id="..user_ids[i].."&nojsoncallback=1"
		end,
		site = function(data,i) 
			num_photos = #data.photos.photo
			local start_index = (i-1)%num_photos + 1
			return "http://farm"..data.photos.photo[start_index].farm..".static.flickr.com/"..data.photos.photo[start_index].server.."/"..data.photos.photo[start_index].id.."_"..data.photos.photo[start_index].secret..".jpg"
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
	start_index = (start_index-1)%(num_photos) + 1

	if (user_ids[#adapters+1-i]) then
	local request = URLRequest {
		url = "http://www.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&format=json&api_key=e68b53548e8e6a71565a1385dc99429f&user_id="..user_ids[#adapters+1-i].."&nojsoncallback=1",
		on_complete = function (request, response)
			local data = json:parse(response.body)
			for k,v in pairs(data.photos.photo[1]) do print(k,v) end
			test = "http://farm"..data.photos.photo[start_index].farm..".static.flickr.com/"..data.photos.photo[start_index].server.."/"..data.photos.photo[start_index].id.."_"..data.photos.photo[start_index].secret..".jpg"
         if (not dontswap) then
			   Load_Image(test,i)
			end
		end
		}
		request:send()
	end
end

function adapter:getUserID(username)
	local request = URLRequest {		
		url = "http://www.flickr.com/services/rest/?method=flickr.people.findByUsername&username="..username.."&format=json&api_key=e68b53548e8e6a71565a1385dc99429f&nojsoncallback=1",
		on_complete = function(request,response)
			local data = json:parse(response.body)
--			print (json:stringify(data))
--			debug()
			if (data.user) then
				self[1].required_inputs.user_id = data.user.nsid
				user_ids[#adapters] = data.user.nsid
	--			self[1].required_inputs.query = data.user.nsid
		      model.album_group:clear()
		      model.albums = {}
		      Setup_Album_Covers()
		      model:notify()
		   end
		end
	}
	request:send()
end

return adapter
