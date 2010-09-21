dofile("ferris.lua")

screen:show_all()

local color_scheme = "red"
local oem_vendor = "trickplay"

local bar_off_image = Image { src = "assets/bar-"..color_scheme.."-off.png", opacity = 0 }
local bar_on_image  = Image { src = "assets/bar-"..color_scheme.."-on.png", opacity = 0 }

-- Load the generic app image once and clone it 

local generic_app_image = Image { src = "assets/generic-app-icon.png", opacity = 0 }

screen:add(bar_off_image,bar_on_image,generic_app_image)

my_id = app.id

--------------------------------------------------------------------------------
-- Table of all the tiles in the wheels

items = {}

--------------------------------------------------------------------------------
-- Assets for installation. We lazy-load them.

installing_assets =
{
    load =  function( self )
    
                self.progress_left = Image{ src = "assets/loading-progress-left.png" , opacity = 0 }
                self.progress_center = Image{ src = "assets/loading-progress-center.png" , opacity = 0, tile = { true , false } }
                self.progress_right = Image{ src = "assets/loading-progress-right.png" , opacity = 0 }
                self.icon = Image{ src = "assets/loading-icon.png" , opacity = 0 }
                
                screen:add( self.progress_left, self.progress_center, self.progress_right, self.icon )
                
                -- This is a simple way to make sure the code above only runs once
                
                self.load = function() end
    
            end            
}

--------------------------------------------------------------------------------
-- Functions to update tiles when apps are being installed

function update_installing_tile( install_info , tile )
    
    assert( install_info )
    
    local app_id = install_info.app_id
    
    local tiles = {}
    
    local tiles_to_add_to_ui = {}
    
    -- Find the tiles for this app id, if the one passed in is nil
    
    if tile ~= nil then
    
        table.insert( tiles , tile )
        
    else
    
        for _ , item in ipairs( items ) do
        
            if item.extra.id == app_id then
            
                table.insert( tiles , item )
                
            end
        
        end
    
    end
    
    -- If it does not exist, create a new tile and mark it to be added to
    -- the UI
    
    if #tiles == 0 then
    
        tile = make_tile( app_id , install_info.app_name )
        
        table.insert( tiles , tile )
        
        table.insert( tiles_to_add_to_ui , tile )
    
    end
    
    -- If the tiles are not in "installing" mode, switch them to that mode
    
    for _ , tile in ipairs( tiles ) do
    
        local extra = tile.extra
        
        if not extra.installing then
        
            extra.installing = true
            
            -- Make the UI changes
            
            assert( extra.image )
            
            -- Load the installing assets if they have not been loaded already
            
            installing_assets:load()
            
            -- An icon that covers the app icon
            
            local icon = Clone{
                source = installing_assets.icon,
                size = extra.image.size,
                scale = extra.image.scale,
                position = extra.image.position }
            
            tile:add( icon )
            
            icon:raise( extra.image )
            
            -- The progress bar pieces
            
            local x_scale , y_scale = unpack( icon.scale , 1 , 2 )
            
            -- Left cap
            
            local p_left = Clone{
                source = installing_assets.progress_left,
                scale = icon.scale,
                position = { icon.x + 7 * x_scale , icon.y + 49 * y_scale }
                }
            
            tile:add( p_left )
            p_left:raise( icon )
            
            -- Center
            
            local p_center = Clone{
                source = installing_assets.progress_center,
                scale = icon.scale,
                position = { p_left.x + p_left.w * x_scale , p_left.y },
                width = 0,
                }
                
            tile:add( p_center )
            p_center:raise( icon )
            
            -- Right cap
            
            local p_right = Clone{
                source = installing_assets.progress_right,
                scale = icon.scale,
                position = { p_center.x + p_center.w * x_scale , p_center.y }
            }
            
            tile:add( p_right )
            p_right:raise( icon )
            
            -- Now, note all the things that will need to be removed to clear the
            -- installing mode of the tile.
            
            extra.installing_ui = { icon = icon , p_left = p_left , p_center = p_center, p_right = p_right }
        
        end
        
        local percent = ( install_info.percent_downloaded + install_info.percent_installed ) / 200
        
        -- The well is actually 138 pixels wide, but the right cap has an extra 3 pixels of
        -- transparency on its right side. That's where we get 141.
        
        local center_width = math.ceil( ( 141 * percent ) - ( extra.installing_ui.p_left.w + extra.installing_ui.p_right.w ) )
        
        if center_width > 0 and center_width ~= extra.installing_ui.p_center.w then
        
            extra.installing_ui.p_center.w = center_width
            
            extra.installing_ui.p_right.x = extra.installing_ui.p_center.x + center_width * extra.installing_ui.p_center.scale[ 1 ]
        
        end
    
    end
    
    -- Add any new tiles to the UI
    
    for _ , tile in ipairs( tiles_to_add_to_ui ) do
    
        -- TODO: add it to the UI
    
    end
    
end

function remove_tile( app_id )

    -- TODO: An app failed to install, so we need to remove its tile

end

function clear_installing_tile( install_info )

    -- An installation finished, so we need to take its tile from
    -- "installing" mode back to normal.

    for _ , tile in ipairs( items ) do
    
        if tile.extra.id == install_info.app_id then
  
            tile.extra.installing = false
            
            if tile.extra.installing_ui then
            
                for _ , thing in pairs( tile.extra.installing_ui ) do
                
                    thing:unparent()
                    
                end
                
                tile.extra.installing_ui = nil
                
                -- TODO: We should re-load the app's icon because
                -- it could be different now.
            
            end
            
        end
    
    end
end

function tu( percent )

    update_installing_tile(
        {
            app_id = "com.trickplay.flickr-photo-wall" ,
            percent_downloaded = percent or 0 ,
            percent_installed = percent or 0 } )

end

function tc()

    clear_installing_tile( { app_id = "com.trickplay.flickr-photo-wall" } )
    
end

--------------------------------------------------------------------------------
-- Cache the app icons

icons = {}

--------------------------------------------------------------------------------
-- Apps that are being installed, keyed by id

installs = nil

--[[    
    install info has the following fields:
    
    id - integer. Identifier for the install
    status - string. One of "DOWNLOADING", "INSTALLING", "FAILED", "FINISHED"
    owner - string. The owner of the install (the app id of the app that started it)
    app_id - string. The id of the app that is being installed.
    app_name - string. The name of the app being installed.
    percent_downloaded - double.
    percent_installed - double.
    extra - table. Extra payload passed by the app that started it. This has string keys and values.
]]    


-- This populates the installs table if it has not been populated already

function populate_installs()

    if installs == nil then
    
        installs = {}
    
        local installs_info = apps:get_all_installs()
    
        for _ , install_info in ipairs( installs_info ) do
        
            if install_info.status == "FINISHED" then
            
                -- We just finish it up right here.
                -- This could increase load time for the launcher, so we may
                -- want to rethink.
                
                if not apps:complete_install( install_info.id ) then
                
                    apps:abandon_install( install_info.id )
                
                end
                
            elseif install_info.status == "DOWNLOADING" or install_info.status == "INSTALLING" then
            
                -- We put it in the installs table, so we can track it
                
                installs[ install_info.app_id ] = install_info
            
            end
        
        end
    
    end    
end

-- We do it right here

populate_installs()

-- Callback for install progress

function apps.on_install_progress( apps , install_info )

    -- installs should have been populated

    assert( installs )
    
    -- Update the tile for this one, adding it if necessary
    
    update_installing_tile( install_info )
    
    -- Update the info in the installs table (or insert new info)
    
    installs[ install_info.app_id ] = install_info
    
end

-- Callback for install completion

function apps.on_install_finished( apps , install_info )

    local check_it = install_info.status == "FAILED"

    if install_info.status == "FINISHED" then
    
        if not apps:complete_install( install_info.id ) then
        
            check_it = true
            
            apps:abandon_install( install_info.id )
        
        end
    
    end
    
    --[[
    
    If it failed completely, or finished but the final step went
    wrong, we do a little sanity check to decide whether to remove the
    tile.
    
    It is possible that the download failed, and if there was a previous
    version of the app installed, it may remain intact.
    
    ]]
    
    if check_it and not apps:is_app_installed( install_info.app_id , true ) then
    
        remove_tile( install_info.app_id )
        
    else
    
        clear_installing_tile( install_info )
        
    end
    
    -- Finally, we remove it from our installs table
    
    installs[ install_info.app_id ] = nil
    
end

--------------------------------------------------------------------------------

function make_tile(id,name)
               
	local item = Group { }

	-- See if we already have one in our cache 
	
	local image = icons[ id ]


	if not image then
	
		-- If not, create it and put it in the cache

		image = Image()
	
		if not image:load_app_icon( id, "launcher-icon.png" ) then
		
			image = Clone{ source = generic_app_image, opacity = 255 }
			
		end
		
		icons[ id ] = image
		
	else

		-- If it exists in the cache, clone it
		
		image = Clone{ source = image }

	end

	image:set { x = 14/2, y = 14/2, z = 0, scale = { 1/2, 1/2 } }

	item:add(image)

	local my_bar_off = Clone { source = bar_off_image, opacity = 255, z = 0, scale={ 1/2, 1/2} }
	local my_bar_on  = Clone { source = bar_on_image, opacity = 0, z = 0, scale={ 1/2, 1/2 } }
	item:add(my_bar_off)
	item:add(my_bar_on)


	local label= Text {
						text = name,
						font="Graublau Web,DejaVu Sans,Sans 24px",
						color="FFFFFF",
						z = 1,
					}
	label.x = (my_bar_off.w/2 - label.w) - 20
	label.y = (my_bar_off.h/2 - label.h) / 2

	item.extra.id = id
	item.extra.label = label
	item.extra.off = my_bar_off
	item.extra.on = my_bar_on
        item.extra.image = image
	item:add(label)


        -- Check to see if this app is being installed
        
        local install_info = installs[ id ]
        
        -- If so, update its tile
        
        if install_info then
        
            update_installing_tile( install_info , item )
            
        end

	return item
end

local app
for i = 1,5 do
	for _,app in pairs(apps:get_all()) do
		if(app.id ~= "com.trickplay.launcher" and app.id ~= "com.trickplay.store") then
			table.insert(items, make_tile(app.id,app.name))
		end
	end
end

ferris = Ferris.new( 11*#items, items, -35 )
local shop = Group {
						opacity=0,
						children = {
							Image { src = "assets/featured-poker.png", z = 1, x = 0, y = 3*screen.h/32 },
							Image { src = "assets/featured-abc.png", z = 1, x = 0, y = 13*screen.h/32 },
							Image { src = "assets/featured-buzz.png", z = 1, x = 296, y = 13*screen.h/32 },
							Image { src = "assets/featured-marvel.png", z = 1, x = 0, y = 19*screen.h/32 },
							Image { src = "assets/featured-glory.png", z = 1, x = 296, y = 19*screen.h/32 },
							Image { src = "assets/app-shop-"..oem_vendor..".png", z = 1, x = 6, y = 50*screen.h/64 },
						},
						y_rotation = { 35, 0, 0 }
}

-- Move a bit more than double the radius off-screen
ferris.offscreen = {
					x = -bar_off_image.w * 2,
					y = screen.h/2
				}
ferris.onscreen = {
					x = bar_off_image.w / 5,
					y = screen.h/2,
				}
ferris.fullscreen = {
					x = screen.w - bar_off_image.w * 4 / 11,
					y = screen.h/2 + 70
				}

ferris.ferris.x = ferris.offscreen.x
ferris.ferris.y = ferris.offscreen.y
ferris.ferris.z = -11*#items*math.sin(math.rad(35))

shop.extra.onscreen = {
					x = ferris.onscreen.x,
					y = screen.h/16
				}
shop.extra.fullscreen = {
						x = screen.w/2 - 295,
						y = screen.h/16
					}

shop.x = shop.extra.onscreen.x
shop.y = shop.extra.onscreen.y

-- These two are "fake" groups, to ensure that these elements are in front of the backdrop,
-- regardless of their z-depth within these fake groups; the group itself stays above the background
local ferris_group = Group { children = { ferris.ferris }, z = 1 }
local shop_group = Group { children = { shop }, z = 2 }

local backdrop1 = Image { src = "assets/background-"..color_scheme.."-1.jpg", z = -1,  size = { screen.w, screen.h}, opacity = 0 }
local backdrop2 = Image { src = "assets/background-"..color_scheme.."-2.jpg", z = 0,  size = { screen.w, screen.h}, opacity = 0 }

local playLabel = Text { text = "play", font="Graublau Web,DejaVu Sans,Sans 72px", color="FFFFFF", opacity = 0, x = 10, y = screen.h/16, z=2 }
local getLabel  = Text { text = "get",  font="Graublau Web,DejaVu Sans,Sans 72px", color="FFFFFF", opacity = 0, x = 10, y = screen.h/16, z=2 }

local OEMAds = {
	Image { src = "assets/"..oem_vendor.."-oem-1.png", opacity = 0 },
	Image { src = "assets/"..oem_vendor.."-oem-2.png", opacity = 0 },
	Image { src = "assets/"..oem_vendor.."-oem-3.png", opacity = 0 },
}

screen:add(OEMAds[1],OEMAds[2],OEMAds[3])

local OEMLabel = Group
						{
							children =
							{
								Clone { source = OEMAds[1], z = 1, x = screen.w/32, y =  5*screen.h/64, opacity = 255, extra = { number = 1 } },
								Clone { source = OEMAds[2], z = 1, x = screen.w/32, y = 24*screen.h/64, opacity = 255, extra = { number = 2 } },
								Clone { source = OEMAds[3], z = 1, x = screen.w/32, y = 43*screen.h/64, opacity = 255, extra = { number = 3 } },
							},
							x = 10,
							z = 1,
							opacity = 0,
							y_rotation = { 90, 0 ,0 },
						}

for k,v in pairs(OEMLabel.children) do
	v.y_rotation = { 0, v.w/2, v.h/2 }
end

screen:add(backdrop1)
screen:add(backdrop2)
screen:add(OEMLabel)

local swap_tile = function(image, delay)
	Timer { interval = delay, on_timer = function(timer)
		image:animate({ duration = 250, y_rotation = -90, mode = "EASE_IN_SINE", on_completed = function()
			image.extra.number = (image.extra.number % 3) + 1
			image.source = OEMAds[image.extra.number]
			image:animate({ duration = 250, y_rotation = 0, mode = "EASE_OUT_SINE" })
		timer:stop()
		end})
	end }
end

Timer { interval = 15000, on_timer = function(timer)
	swap_tile(OEMLabel.children[1], 500)
	swap_tile(OEMLabel.children[2], 1000)
	swap_tile(OEMLabel.children[3], 1500)
end }

screen:add(getLabel)
screen:add(shop_group)
screen:add(playLabel)
screen:add(ferris_group)

mediaplayer.on_loaded = function( self ) self:play() end
mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
mediaplayer:load('jeopardy.mp4')

-- 1 is forward, -1 is backward
local direction = 1

local state = "offscreen"

if( settings.active ) then
	ferris:goto( settings.active - 1)
end

backdrop_fade_wobble = function(backdrop)
	backdrop:animate({
					duration = 2500,
					opacity = 255,
					mode = "EASE_IN_OUT_SINE",
					on_completed = function ()
						backdrop:animate({
											duration = 2500,
											opacity = 0,
											mode = "EASE_IN_OUT_SINE",
											on_completed = function()
												backdrop_fade_wobble(backdrop)
											end
										})
					end })
end

local backdrop_stop_wobble = function(backdrop)
	backdrop:animate({ duration = 10, opacity = 0 })
end

function screen.on_key_down(screen, key)

	if ( keys.s == key or keys.BLUE == key ) then
		apps:launch("com.trickplay.store")
	end

	-- Stuff to rotate the wheel and choose items
	if( state == "onscreen" or state == "fullscreen" ) then
		if key >= keys["1"] and key <= keys["9"] then
			ferris:rotate( direction * (key - keys["0"]) )
		elseif key == keys["minus"] then
			direction = -direction
		elseif key == keys["CHAN_UP"] then
			ferris:rotate( 3 )
		elseif key == keys["CHAN_DOWN"] then
			ferris:rotate( -3 )
		elseif key == keys["Up"] then
			ferris:rotate( 1 )
		elseif key == keys["Down"] then
			ferris:rotate( -1 )
		elseif key == keys["Return"] then
			
                        local active = ferris:get_active()
			
                        -- Check to see if it is being installed
                        
                        local extra = items[ active ].extra
                        
                        if not extra.installing then
                        
                            settings.active = active
                            
                            apps:launch( extra.id )
                        
                        end
		end
	end


	-- Stuff to transition between states
	if( state == "onscreen") then
		if key == keys["Left"] or key == keys["Exit"] then
			ferris.highlight_on = false
			ferris:highlight()
			ferris.ferris:animate(
									{
										duration = 500,
										x = ferris.offscreen.x,
										mode = "EASE_IN_SINE",
										on_completed = function() ferris:highlight() end,
									}
								)
			state = "offscreen"
		elseif key == keys["Right"] then
			ferris.highlight_on = false
			ferris:highlight()
			ferris.ferris:animate(
									{
										duration = 1000,
										y_rotation = -90,
										x = ferris.fullscreen.x,
										y = ferris.fullscreen.y,
										scale = { 1.5, 1.5 },
										mode = "EASE_IN_OUT_SINE",
										on_completed = function() mediaplayer:pause() end,
									}
								)
			shop:animate(
								{
										duration = 1000,
										y_rotation = 0,
										x = shop.extra.fullscreen.x,
										y = shop.extra.fullscreen.y,
										opacity = 255,
										mode = "EASE_IN_OUT_SINE",
								}
							)
			ferris:rotate(#items)
                        
                        backdrop1:animate(
								{
									duration = 1000,
									opacity = 255,
									mode = "EASE_OUT_SINE",
									on_completed = function () backdrop2:show() backdrop_fade_wobble(backdrop2) end,
								}
							)
			OEMLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = 20,
									mode = "EASE_OUT_SINE",
									y_rotation = 0,
								}
							)
			playLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = (screen.w-playLabel.w) - 250,
									mode = "EASE_OUT_SINE",
								}
							)
			getLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = (screen.w-getLabel.w)/2,
									mode = "EASE_OUT_SINE",
								}
							)
			state = "fullscreen"
		end

	elseif (state == "offscreen") then
		if key == keys["Left"] or key == keys["Right"] then
			ferris.highlight_on = true
			ferris.ferris:animate(
									{
										duration = 500,
										x = ferris.onscreen.x,
										mode = "EASE_OUT_SINE",
										on_completed = function() ferris:highlight() end,
									}
								)
			state = "onscreen"
		end

	elseif (state == "fullscreen") then
		if key == keys["Left"] then
			ferris.highlight_on = true
			ferris.ferris:animate(
									{
										duration = 1000,
										y_rotation = -35,
										x = ferris.onscreen.x,
										y = ferris.onscreen.y,
										scale = { 1.0, 1.0 },
										mode = "EASE_IN_OUT_SINE",
										on_completed = function() ferris:highlight() mediaplayer:play() end,
									}
								)
			shop:animate(
									{
										duration = 1000,
										y_rotation = 35,
										x = shop.extra.onscreen.x,
										y = shop.extra.onscreen.y,
										opacity = 0,
										mode = "EASE_IN_OUT_SINE",
									}
								)
			backdrop1:animate(
								{
									duration = 1000,
									opacity = 0,
									mode = "EASE_IN_SINE",
								}
							)
			backdrop2:hide()
			OEMLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 10,
									mode = "EASE_IN_SINE",
									y_rotation = 90,
								}
							)
			playLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 10,
									mode = "EASE_IN_SINE",
								}
							)
			getLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 10,
									mode = "EASE_IN_SINE",
								}
							)
			state = "onscreen"
		end
	end

end
