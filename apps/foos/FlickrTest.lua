--[[

--PhotoBucket
API key is: 149830333
API private key is: 35cbcef171010144952df0fc117a5d9f

]]

Timer{ interval = 2 , on_timer = function() collectgarbage() end }

dofile("Flickr.lua")

local tile_size = 160
-- API Key for flickr API access for this app
local flickr_api_key="e68b53548e8e6a71565a1385dc99429f"
local trickplay_red = { 150, 10, 4 }

-- Given an image index number, find it's column/row indices in the wall
function image_index_to_position( i )
	return math.floor( (i-1) / rows_per_column), (i-1) % rows_per_column
end

-- Given a column,row, get the image index
function image_position_to_index( col, row)
	return col * rows_per_column + row + 1
end

-- Given a column,row get the pixel offset of the image top left corner relative to the wall
function get_tile_position( col , row )
    return { ( col * tile_size ) , ( row * tile_size ) }
end

function inflate( position , size , dx , dy )
    return { position[ 1 ] + dx , position[ 2 ] + dy } , { size[ 1 ] - ( dx * 2 ) , size[ 2 ] - ( dy * 2 ) }
end

pagenum = 1
photo_index = {}
photo_urls = {}
local waiting = nil
local pages_loaded = 0
-- This function will load the next available page of images from Flickr, and then execute completion:callback
function populate_next_page( completion )
	Flickr.fetch_photos(flickr_api_key,Flickr.cc_interesting_url, 1,pagenum, photo_index,
		{
			
			callback = function(self)
				photo_urls[pagenum] = Flickr.get_medium_url(photo_index[pagenum])				

				if (photo_urls[pagenum]) then
					drawImage(photo_urls[pagenum])
				end
				pagenum = pagenum + 1
				if (pagenum < 50) then
					populate_next_page({})
				else
					dofile("Load.lua")
				end
			end
		})
end
populate_next_page({})
function drawImage(url)
		local the_photo = photo_index[pagenum]
		local image = Image{
			src = url,
			async = true,
			position = {math.random(1600), math.random(700)},
			z = 1,
		}
		screen:add(image)
end

-- Fetch the first set of images
-- We pass a callback which itself will load more images once first page is loaded
-- ...with its own callback to load page 3 as well.  So we basically load the first 3 pages, one at a time at startup.

screen:show_all()

-- We also want to get the list of licenses for displaying along with images when zoomed
local licenses = {}
Flickr.license_info(flickr_api_key, licenses)

local zoom_image
local wall_zoom_back_z = -300
local image_zoom_back_z = -200
--[[
function screen.on_key_down(screen,keyval)
	if (keyval == keys.Return) then
		screen:clear()
		populate_next_page({})
	end
end]]
