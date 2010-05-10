Timer{ interval = 2 , on_timer = function() collectgarbage() end }

dofile("Flickr.lua")

-- How many images in each column?
local rows_per_column = 6
-- How many images should we load at a time? More takes longer, fewer means more fetches
local prefetch_images = rows_per_column * 10
-- How much should the wall be padde on the left side?
local left_pad = screen.size[1] / 10
-- How much should the wall be padded on top?
local top_pad = screen.size[2] / 10
-- How big shold each image tile be?
local tile_size = 160
-- How much padding between adjacent tiles?
local tile_pad = 20
-- At what angle to the screen should the image wall live?
local tilt_angle = 30

local super_tilt_angle = 85
-- API Key for flickr API access for this app
local flickr_api_key="e68b53548e8e6a71565a1385dc99429f"
local trickplay_red = { 150, 10, 4 }


--[[

TODO: Flush images not being used to free up memory

]]--

local dx = tile_size * math.cos( math.rad( tilt_angle ) )
local dz = tile_size * math.sin( math.rad( tilt_angle ) )

local cols_per_page = math.floor(prefetch_images / rows_per_column)
local left_col = 0
local selection_col = 0
local selection_row = 0

mediaplayer.on_loaded = function () mediaplayer:play() end
mediaplayer.on_end_of_stream = function ()
						mediaplayer:seek(0)
						mediaplayer:play()
					end
mediaplayer:load('assets/background.mp4')
curtain = Rectangle { color = '00000080', position = { -1.5*screen.w, -1.5*screen.h, -screen.h }, size = {3*screen.w, 3*screen.h} }
screen:add(curtain)

-- The wall will contain an array of Images which will slide around diagonally on the screen at an angle
local wall = Group{ position = { left_pad , top_pad } , size = screen.size }
wall.y_rotation = { super_tilt_angle , 480 , 0 }
wall.z = -10000

-- The wall is placed inside an enclosing group so we can manipulate the wall itself without regard to
-- how far it's slide along its axis, the rotation, etc.
local wall_enclosure = Group{ position = { 0, 0 }, size = screen.size }
wall_enclosure:add(wall)

screen:add( wall_enclosure )

-- Adding the logo at the end here and with a minor z component will make sure it stays on top
local logo = Image {
				src = Flickr.logo_url,
				keep_aspect_ratio = true,
				x = 5 * (screen.w / 6) - 12,
				y = 12,
				z = 1,
				width = screen.w / 6,
}
screen:add(logo)

local gridRect = Rectangle {
					size = {tile_size-2, tile_size-2},
					color = "808080",
					position = { 1, 1 },
					z = -1,
					opacity = 0
}
screen:add(gridRect)

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

photo_index = {}

local waiting = nil
local pages_loaded = 0
-- This function will load the next available page of images from Flickr, and then execute completion:callback
function populate_next_page( completion )

	-- If we're already loading a page, then just bail; it'll retry by calling again
	if(waiting) then return end

	-- Poor man's lock: really need a proper semaphore to avoid a potential race someday
	waiting = true

	-- Call to the Flickr module to load the images.  It will populate the image meta-data into the photo_index
	-- table, and finally call us back by invoking :callback on the final argument
	-- We store some state for the callback in the that table so it can be used without scoping issues in the callback's
	-- context
	Flickr.fetch_photos(flickr_api_key, Flickr.cc_interesting_url, cols_per_page*rows_per_column, pages_loaded+1, photo_index,
		{
			start = #photo_index,
			final = #photo_index + cols_per_page*rows_per_column,
			-- completion here is passed into the parent function -- we're storing it in the table to avoid any
			-- scoping issues inside the callback context
			completion = completion,
			callback = function( self )
				-- For each new image that was fetched
				for i=self.start+1,self.final do

					local col, row = image_index_to_position(i)
					-- Create a new image from the thumbnail URL Flickr got for that image
					-- and with an appropriate offset position in the wall
					local image = Image{
											src = Flickr.get_thumb_url(photo_index[i]),
											position = {
															(tile_size - tonumber(photo_index[i].width_t))/2,
															(tile_size - tonumber(photo_index[i].height_t))/2
														},
											z = 1,
										}
					local grid = Clone { source = gridRect, opacity = 64 }

					local igroup = Group { children = { grid, image }, position = get_tile_position( col, row ) }

					photo_index[i].thumbWallImage = igroup

					wall:add( igroup )
				end

				waiting = nil

				pages_loaded = pages_loaded+1
				if self.completion then completion:callback() end
			end
		})
end

local deactivate = function (image)
	image:animate({ duration = 100, y_rotation = 0 })
	image.children[1]:animate({ duration = 100, opacity = 64 })
end

local activate = function (image)
	image:raise_to_top()
	image:animate({ duration = 100, y_rotation = -tilt_angle })
	image.children[1]:animate({ duration = 100, opacity = 220 })
end


-- Fetch the first set of images
-- We pass a callback which itself will load more images once first page is loaded
-- ...with its own callback to load page 3 as well.  So we basically load the first 3 pages, one at a time at startup.
populate_next_page({
					callback = function( self )
						activate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)						populate_next_page({
								callback = function( self )
									populate_next_page({
										callback = function( self )
										end
									})
								end
						})
					end
				})


screen:show_all()

-- We also want to get the list of licenses for displaying along with images when zoomed
local licenses = {}
Flickr.license_info(flickr_api_key, licenses)

wall:animate({ duration = 500, z = 0, mode = "EASE_OUT_SINE", on_completed = function()
	wall:animate({ duration = 1000, y_rotation = tilt_angle, mode = "EASE_OUT_ELASTIC" })
end })

local zoom_image
local wall_zoom_back_z = -300
local image_zoom_back_z = -200

function controllers.on_controller_connected(controllers, controller)
	controller:declare_resource("flickr","assets/flickr-phone.png")
	controller:set_ui_background("flickr")
end

local controller
for _,controller in pairs(controllers.connected) do
	controllers:on_controller_connected( controller )
end

function screen.on_key_down(screen,keyval)

	local reset_zoom = function()
		if(zoom_image) then
			-- Zoom image back out and vanish
			wall_enclosure:animate({ duration = 250, z = 0 })
			zoom_image:animate({ duration = 250, z = image_zoom_back_z, scale = { 0.1, 0.1}, opacity = 0, on_completed = function () zoom_image = nil end })
		end
	end

	key_actions = {
		[keys.Right] =  function()
			if selection_col >= pages_loaded*cols_per_page - 1 then
				return
			end

			deactivate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)
			selection_col = selection_col + 1
			activate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)

			if selection_col > ( pages_loaded*cols_per_page - 20 ) then
				-- Fetch another set of images
				populate_next_page()
			end
			
			if selection_col - left_col > 3 then
				left_col = left_col + 1
				wall:animate({ duration = 250, x = left_pad-left_col*dx, z = left_col*dz })
			end
		end,

		[keys.Left] = function()

			if selection_col == 0 then
				return
			end

			deactivate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)
			selection_col = selection_col - 1
			activate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)
			
			if selection_col < left_col  and left_col > 0 then
				left_col = left_col - 1
				wall:animate({ duration = 250, x = left_pad-left_col*dx, z = left_col*dz })
			end
		end,

		[keys.Up] = function()
			
			if selection_row > 0 then
				deactivate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)
				selection_row = selection_row - 1
				activate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)
			end
		end,

		[keys.Down] = function()

			if selection_row < rows_per_column-1 then
				deactivate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)
				selection_row = selection_row + 1
				activate(photo_index[image_position_to_index(selection_col, selection_row)].thumbWallImage)
			end
		end,

		[keys.Return] = function()
			if not zoom_image then
				-- identify the photo based on column & row
				local the_photo = photo_index[image_position_to_index(selection_col, selection_row)]
				if the_photo == nil then
					return
				end

				local start_position = the_photo.thumbWallImage.transformed_position

				zoom_image = Group { position = {0,0} }
				local zoom_image_url
				if screen.size[2] > 540 then
					zoom_image_url = Flickr.get_original_url(the_photo)
				else
					zoom_image_url = Flickr.get_medium_url(the_photo)
				end
				local zoom_thumb_img = Clone { source = the_photo.thumbWallImage.children[2] }
				local zoom_image_txt_grp = Group { position = { 0, 0 } }
				local zoom_image_txt_rect = Rectangle { color = trickplay_red , opacity = 255*0.7, size = { 200, 24 }, position = { 0, 0} }
				local zoom_image_txt = Text	{
												position = { 10, 0 },
												text = "\""..the_photo.title.."\" ©"..the_photo.ownername.." ("..licenses[the_photo.license].short..")",
												z = 1,
												color = { 255, 255, 255 },
												font = "Graublau Web,DejaVu Sans,Sans 18px",
												wrap = false,
											}
				zoom_image_txt_grp:add(zoom_image_txt_rect)
				zoom_image_txt_grp:add(zoom_image_txt)
	
				local zoom_image_img = Image {
										position = {0,0},
										src = zoom_image_url,
				}
				zoom_image_img.on_loaded = function()
											-- The zoom might be cancelled before the image finished loading
											if zoom_image == nil then return end
											zoom_image.children = { zoom_image_img, zoom_image_txt_grp }
										end


				zoom_image.children = { zoom_thumb_img, zoom_image_txt_grp }


				if (the_photo.width_m / 16) > ( the_photo.height_m / 9 )then
					zoom_image_img.width = screen.w * 0.9
					zoom_image_img.height = ( screen.w * 0.9 ) * ( the_photo.height_m / the_photo.width_m )
				else
					zoom_image_img.request_mode = "WIDTH_FOR_HEIGHT"
					zoom_image_img.height = screen.h * 0.9
					zoom_image_img.width = ( screen.h * 0.9 ) * ( the_photo.width_m / the_photo.height_m )
				end
				zoom_thumb_img.request_mode = zoom_image_img.request_mode
				zoom_thumb_img.height = zoom_image_img.height
				zoom_thumb_img.width = zoom_image_img.width
	
				local max_txt_width = zoom_image_img.height - 40
				if max_txt_width < zoom_image_txt.size[1] then
					zoom_image_txt.scale = { max_txt_width/zoom_image_txt.size[1], 1.0 }
				end
				zoom_image_txt_rect.width = zoom_image_txt.transformed_size[1] + 20
				zoom_image_txt_grp.z_rotation = { 90, 0, 0 }
				zoom_image.position = { ( screen.w - zoom_image_img.size[1] ) / 2,
												( screen.h - zoom_image_img.size[2] ) / 2 }
				zoom_image.z = image_zoom_back_z
				zoom_image.scale = { 0.1, 0.1, zoom_image_img.size[1]/2, zoom_image_img.size[2]/2 }
				screen:add( zoom_image )

				wall_enclosure:animate({ duration = 250, z = wall_zoom_back_z })
				zoom_image:animate({ duration = 250, z = 0, scale = { 1.0, 1.0 }, opacity = 255 })
			end
		end,
	 }

	reset_zoom()
	if key_actions[keyval] then
		key_actions[keyval]()
	else
		print("KEY: "..keyval)
	end
end
