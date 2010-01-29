screen.size = { 960 , 540 }
--screen.size = { 1920, 1080 }

dofile("debug-lib.lua")

Timer{ interval = 2 , on_timer = function() collectgarbage() end }

dofile("Flickr.lua")

-- How many images should we load at a time? More takes longer, fewer means more fetches
local prefetch_images = 40
-- How many images in each column?
local rows_per_column = 2 + math.floor(screen.size[2] / 270)
-- How much should the wall be padde on the left side?
local left_pad = screen.size[1] / 10
-- How much should the wall be padded on top?
local top_pad = screen.size[2] / 10
-- How big shold each image tile be?
local tile_size = 120
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

local cols_per_page = math.floor(prefetch_images / rows_per_column)
local left_col = 0
local selection_col = 0
local selection_row = 0

screen.color = "000000";
screen:show_all()

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

	pages_loaded = pages_loaded+1
	-- Call to the Flickr module to load the images.  It will populate the image meta-data into the photo_index
	-- table, and finally call us back by invoking :callback on the final argument
	-- We store some state for the callback in the that table so it can be used without scoping issues in the callback's
	-- context
	Flickr.fetch_photos(flickr_api_key, Flickr.cc_interesting_url, cols_per_page*rows_per_column, pages_loaded, photo_index,
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
					local image = Image{ src = Flickr.get_thumb_url(photo_index[i]), position = get_tile_position( col , row ) }

					-- center the image thumbnail inside the tile					
					image.x = image.x + ( (tile_size - tile_pad) - tonumber(photo_index[i].width_t) ) / 2
					image.y = image.y + ( (tile_size - tile_pad) - tonumber(photo_index[i].height_t) ) / 2

					photo_index[i].thumbWallImage = image

					wall:add( image )
				end

				waiting = nil
				
				if self.completion then completion:callback() end
			end
		})

end

local cursor = Rectangle{ color = trickplay_red , opacity = 0 }
cursor.position , cursor.size = inflate( get_tile_position( selection_col , selection_row ) , { 100 , 100 } , -4 , -4 )

wall:add( cursor )

-- Fetch the first set of images
-- We pass a callback which itself will load more images once first page is loaded
-- ...with its own callback to load page 3 as well.  So we basically load the first 3 pages, one at a time at startup.
populate_next_page({
							callback = function( self )
								populate_next_page({
										callback = function( self )
											populate_next_page()
										end
								})
							end
						})

-- We also want to get the list of licenses for displaying along with images when zoomed
local licenses = {}
Flickr.license_info(flickr_api_key, licenses)

-- The start_timeline will wait until the images are likely to have started loading, then rotate the
-- wall to its tilted angle, from its original super-tilted angle
local start_timeline = Timeline{ duration = 500 , delay = 800 }
local a = Interval( wall.z , 0 )
local b = Interval( wall.y_rotation[1] , tilt_angle )
local c = Alpha{ timeline = start_timeline , mode = "EASE_OUT_SINE" }

function start_timeline.on_new_frame( t , msecs )
    wall.z = a:get_value( c.alpha )
    
end

function start_timeline.on_completed( )
    
    local t = Timeline{ duration = 1000 }
    
    local d = Alpha{ timeline = t , mode = "EASE_OUT_ELASTIC" }
    
    function t.on_new_frame(t)
        wall.y_rotation = { b:get_value( d.alpha ) , screen.w / 2 , 0 }
        cursor.opacity = 255 * t.progress
    end
        
    t:start()
end

start_timeline:start()


local x_interval = nil
local y_interval = nil

local timeline = Timeline{ duration = 40 }

function timeline.on_new_frame(t,msecs)
    
    if x_interval then
        cursor.x = x_interval:get_value( t.progress )
    end
    if y_interval then
        cursor.y = y_interval:get_value( t.progress )
    end
end

local wall_x_interval = nil
local wall_z_interval = nil

local wall_timeline = Timeline{ duration = 40 }

function wall_timeline.on_new_frame( t , msecs )
    if wall_x_interval then
        wall.x = wall_x_interval:get_value( t.progress )
    end
    if wall_z_interval then
        wall.z = wall_z_interval:get_value( t.progress )
    end
end

local key_right = 65363
local key_left  = 65361
local key_down  = 65364
local key_up    = 65362
local key_enter = 65293

local zoom_image
local wall_zoom_back_z = -300
local image_zoom_back_z = -200

local wall_zoom_timeline = Timeline{ duration = 250 }
local wall_zoom_alpha = Alpha{ timeline = wall_zoom_timeline , mode = "EASE_OUT_SINE" }

function screen.on_key_down(screen,keyval)

	local function reset()
		if timeline.is_playing then
			--move_selection()
			if x_interval then
				cursor.x = x_interval.to
			end
			if y_interval then
				cursor.y = y_interval.to
			end
			timeline:advance(timeline.duration)
		end

		if zoom_image then
			if wall_zoom_timeline.is_playing then
				wall_zoom_timeline:advance(wall_zoom_timeline.duration)
			end
			local wall_zoom_int = Interval( wall_enclosure.z, 0 )
			local image_zoom_z_int = Interval( zoom_image.z, image_zoom_back_z )
			local image_zoom_opacity_int = Interval( 255, 0 )
			function wall_zoom_timeline.on_new_frame( t , msecs )
				wall_enclosure.z = wall_zoom_int:get_value( wall_zoom_alpha.alpha )
				zoom_image.z = image_zoom_z_int:get_value( wall_zoom_alpha.alpha )
				zoom_image.opacity = image_zoom_opacity_int:get_value( wall_zoom_alpha.alpha )
			end

			function wall_zoom_timeline.on_completed( )
				zoom_image.parent:remove(zoom_image)
				zoom_image = nil
			end

			wall_zoom_timeline:start()
		end
	end

	local function reset_wall()
		if not wall_timeline.is_playing then
			return
		end
		if wall_x_interval then
			wall.x = wall_x_interval.to
		end
		if wall_z_interval then
			wall.z = wall_z_interval.to
		end
	end

	key_actions = {
	
		[key_right] =  function()
			reset()
			reset_wall()
	
			if selection_col >= pages_loaded*cols_per_page - 1 then
				return
			end
	
			x_interval = Interval( cursor.x , cursor.x + tile_size )
			y_interval = nil
			selection_col = selection_col + 1
			timeline:start()
			
			if selection_col + left_col > ( pages_loaded/cols_per_page - 8 ) then
				-- Fetch another set of images
				populate_next_page()
			end
			
			if selection_col - left_col > 3 then
				local dx = tile_size * math.cos( math.rad( tilt_angle ) )
				wall_x_interval = Interval( wall.x , wall.x - dx )
				wall_z_interval = Interval( wall.z , wall.z + ( dx * math.tan( math.rad( tilt_angle ) ) ) )
				
				left_col = left_col + 1
				
				wall_timeline:start()
			end
		end,


		[key_left] = function()
			reset()
			reset_wall()
			
			if selection_col == 0 then
				return
			end
			x_interval = Interval( cursor.x , cursor.x - tile_size )
			y_interval = nil
			selection_col = selection_col - 1
			
			timeline:start()
			
			if selection_col < left_col  and left_col > 0 then
				local dx = tile_size * math.cos( math.rad( tilt_angle ) )
				wall_x_interval = Interval( wall.x , wall.x + dx )
				wall_z_interval = Interval( wall.z , wall.z - ( dx * math.tan( math.rad( tilt_angle ) ) ) )
				
				left_col = left_col - 1
				
				wall_timeline:start()
			end
		end,

		[key_up] = function()
			reset()
			
			if selection_row > 0 then
				x_interval = nil
				y_interval = Interval( cursor.y , cursor.y - tile_size )
				selection_row = selection_row - 1
				timeline:start()
			end
		end,

		[key_down] = function()
			reset()
			
			if selection_row < rows_per_column-1 then
				x_interval = nil
				y_interval = Interval( cursor.y , cursor.y + tile_size )
				selection_row = selection_row + 1        
				timeline:start()
			end
		end,

		[key_enter] = function()
			if not zoom_image then
				reset()
	
				-- identify the photo based on column & row
				local the_photo = photo_index[image_position_to_index(selection_col, selection_row)]
	
				local start_position = cursor.transformed_position
	
				zoom_image = Group { position = {0,0} }
				local zoom_image_url
				if screen.size[2] < 1080 then
					zoom_image_url = Flickr.get_medium_url(the_photo)
				else
					zoom_image_url = Flickr.get_original_url(the_photo)
				end
				local zoom_thumb_img = Clone { source = the_photo.thumbWallImage }
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
				zoom_image_scale = { 0.1, 0.1, zoom_image_img.size[1]/2, zoom_image_img.size[2]/2 }
	
				screen:add( zoom_image )
				if wall_zoom_timeline.is_playing then
					wall_enclosure.z = wall_zoom_int.to
					wall_zoom_timeline:stop()
				end
				local wall_zoom_int = Interval( wall_enclosure.z, wall_zoom_back_z )
				local image_zoom_z_int = Interval( image_zoom_back_z, 0 )
				local image_zoom_scale_int = Interval ( 0.1, 1.0 )
	
				function wall_zoom_timeline.on_new_frame( t , msecs )
					zoom_image.z = image_zoom_z_int:get_value( wall_zoom_alpha.alpha )
					zoom_image.scale =	{
											image_zoom_scale_int:get_value( wall_zoom_alpha.alpha ),
											image_zoom_scale_int:get_value( wall_zoom_alpha.alpha ),
											zoom_image_img.size[1]/2,
											zoom_image_img.size[2]/2
										}
					wall_enclosure.z = wall_zoom_int:get_value( wall_zoom_alpha.alpha )
				end
	
				wall_zoom_timeline.on_completed = nil
				wall_zoom_timeline:start()
			else
				reset()
			end
		end,
	 }

	if key_actions[keyval] then
		key_actions[keyval]()
	else
		print("KEY: "..keyval)
	end
end
