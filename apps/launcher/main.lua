dofile("ferris.lua")

screen:show_all()

local color_scheme = "red"
local oem_vendor = "lg"

local bar_off_image = Image { src = "assets/bar-"..color_scheme.."-off.png", opacity = 0,scale={screen.w/1920, screen.h/1080} }
local bar_on_image  = Image { src = "assets/bar-"..color_scheme.."-on.png", opacity = 0,scale={screen.w/1920, screen.h/1080} }

-- Load the generic app image once and clone it 

local generic_app_image = Image { src = "assets/generic-app-icon.png", opacity = 0,scale={screen.w/1920, screen.h/1080} }

screen:add(bar_off_image,bar_on_image,generic_app_image)

my_id = app.id

local items = {}

--------------------------------------------------------------------------------
-- Functions to update tiles when apps are being installed

function update_installing_tile( install_info , tile )
    
    local app_id = install_info.app_id
    
    -- Find the tile for this app id, if the one passed in is nil
    
    -- If it does not exist, add it
    
    -- If the tile is not in "installing" mode, switch it to that mode
    
    -- Finally, update the progress from the install info using
    -- status, percent_downloaded and percent_installed
    
end

function remove_tile( app_id )

    -- An app failed to install, so we need to remove its tile

end

function clear_installing_tile( app_id )

    -- An installation finished, so we need to take its tile from
    -- "installing" mode back to normal. 
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
    
    -- Update the info in the installs table (or insert new info)
    
    installs[ install_info.app_id ] = install_info
    
    -- Now update the tile for this one
    
    update_installing_tile( install_info )
    
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
    
        clear_installing_tile( install_info.app_id )
        
    end
    
    -- Finally, we remove it from our installs table
    
    installs[ install_info.app_id ] = nil
    
end

--------------------------------------------------------------------------------

local make_tile = function(id,name)
               
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
	
	image:set { x = 14*(screen.w/1920)/2, y = 14*(screen.h/1080)/2, z = 0, scale={screen.w/3840, screen.h/2160} }
	
	
	item:add(image)

	local my_bar_off = Clone { source = bar_off_image, opacity = 255, z = 0,scale={screen.w/3840, screen.h/2160} }
	local my_bar_on  = Clone { source = bar_on_image, opacity = 0, z = 0,scale={screen.w/3840, screen.h/2160} }
	item:add(my_bar_off)
	item:add(my_bar_on)


	local label= Text {
						text = name,
						font="Graublau Web,DejaVu Sans,Sans "..24*(screen.h/1080).."px",
						color="FFFFFF",
						z = 1,
						scale={screen.w/1920, screen.h/1080}
					}
	label.x = (my_bar_off.w*(screen.w/1920)/2 - label.w*(screen.w/1920)) - 20*(screen.w/1920)
	label.y = (my_bar_off.h*(screen.h/1080)/2 - label.h*(screen.h/1080)) / 2

	item.extra.id = id
	item.extra.label = label
	item.extra.off = my_bar_off
	item.extra.on = my_bar_on
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
		if(app.id ~= "com.trickplay.launcher") then
			table.insert(items, make_tile(app.id,app.name))
		end
	end
end

local ferris = Ferris.new( (11*(screen.w/1920))*#items, items, -30 )
local shop = Group {
						opacity=0,
						children = {
							Image { src = "assets/featured-poker.png", z = 1, x = 0, y = 3*screen.h/32,scale={screen.w/1920, screen.h/1080} },
							Image { src = "assets/featured-abc.png", z = 1, x = 0, y = 14*screen.h/32,scale={screen.w/1920, screen.h/1080} },
							Image { src = "assets/featured-buzz.png", z = 1, x = 296*(screen.w/1920), y = 14*screen.h/32,scale={screen.w/1920, screen.h/1080} },
							Image { src = "assets/featured-marvel.png", z = 1, x = 0, y = 20*screen.h/32,scale={screen.w/1920, screen.h/1080} },
							Image { src = "assets/featured-glory.png", z = 1, x = 296*(screen.w/1920), y = 20*screen.h/32,scale={screen.w/1920, screen.h/1080} },
						},
						y_rotation = { 45, 0, 0 }
}

-- Move a bit more than double the radius off-screen
ferris.offscreen = {
					x = (-25*(screen.w/1920))*#items,
					y = screen.h/2
				}
ferris.onscreen = {
					x = (11*(screen.w/1920))*#items,
					y = screen.h/2
				}
ferris.fullscreen = {
					x = screen.w - (3*(screen.w/1920))*#items,
					y = screen.h/2 + 70*(screen.h/1080)
				}

ferris.ferris.x = ferris.offscreen.x
ferris.ferris.y = ferris.offscreen.y


shop.extra.onscreen = {
					x = ferris.onscreen.x,
					y = screen.h/16
				}
shop.extra.fullscreen = {
						x = screen.w/2 - 295*(screen.w/1920),
						y = screen.h/16
					}

shop.x = shop.extra.onscreen.x
shop.y = shop.extra.onscreen.y

-- These two are "fake" groups, to ensure that these elements are in front of the backdrop,
-- regardless of their z-depth within these fake groups; the group itself stays above the background
local ferris_group = Group { children = { ferris.ferris }, z = 1 }
local shop_group = Group { children = { shop }, z = 2 }

local storeMockup = Image { src = "assets/store_mock_poker.jpg", z = 0, opacity = 0,scale={screen.w/1920, screen.h/1080} }

local backdrop1 = Image { src = "assets/background-"..color_scheme.."-1.jpg", z = -1,  size = { screen.w, screen.h}, opacity = 0 }
local backdrop2 = Image { src = "assets/background-"..color_scheme.."-2.jpg", z = 0,  size = { screen.w, screen.h}, opacity = 0 }

local playLabel = Text { text = "play", font="Graublau Web,DejaVu Sans,Sans 72px", color="FFFFFF", opacity = 0, x = 10, y = screen.h/16, z=1,scale={screen.w/1920, screen.h/1080} }
local getLabel  = Text { text = "get",  font="Graublau Web,DejaVu Sans,Sans 72px", color="FFFFFF", opacity = 0, x = 10, y = screen.h/16, z=1,scale={screen.w/1920, screen.h/1080} }

local OEMLabel = Group
						{
							children =
							{
								Image { src = "assets/"..oem_vendor.."-oem-1.png", z = 1, x = screen.w/32, y = 2*screen.h/32,scale={screen.w/1920, screen.h/1080} },
								Image { src = "assets/"..oem_vendor.."-oem-2.png", z = 1, x = screen.w/32, y = 11*screen.h/32,scale={screen.w/1920, screen.h/1080} },
								Image { src = "assets/"..oem_vendor.."-oem-3.png", z = 1, x = screen.w/32, y = 20*screen.h/32,scale={screen.w/1920, screen.h/1080} },
							},
							x = 10*(screen.w/1920),
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

local swap_tile = function(image, new_src, delay)
	Timer { interval = delay, on_timer = function(timer)
		image:animate({ duration = 250, y_rotation = -90, mode = "EASE_IN_SINE", on_completed = function()
			image.src = new_src
			image:animate({ duration = 250, y_rotation = 0, mode = "EASE_OUT_SINE" })
		timer:stop()
		end})
	end }
end

Timer { interval = 15, on_timer = function(timer)
	local first = OEMLabel.children[1].src
	swap_tile(OEMLabel.children[1], OEMLabel.children[2].src, .5)
	swap_tile(OEMLabel.children[2], OEMLabel.children[3].src, 1)
	swap_tile(OEMLabel.children[3], first, 1.5)
end }

screen:add(getLabel)
screen:add(shop_group)
screen:add(playLabel)
screen:add(ferris_group)

screen:add(storeMockup)
storeMockup:raise_to_top()

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

	if ( keys.s == key ) then
		storeMockup:animate({duration = 500, opacity = 255-storeMockup.opacity, mode = "EASE_IN_OUT_SINE" })
		return
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
			-- Would launch the app here!
                        
                        -- Check to see if it is being installed
                        
                        local app_id = items[active].extra.id
                        
                        if installs[ app_id ] == nil then
                        
                            settings.active = active
                            apps:launch(app_id)
                        
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
										scale = { 1.4, 1.4 },
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
									x = 20*(screen.w/1920),
									mode = "EASE_OUT_SINE",
									y_rotation = 0,
								}
							)
			playLabel:animate(
								{
									duration = 1000,
									opacity = 255,
									x = (screen.w-playLabel.w) - 250*(screen.w/1920),
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
										y_rotation = -30,
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
										y_rotation = 45,
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
									x = 10*(screen.w/1920),
									mode = "EASE_IN_SINE",
									y_rotation = 90,
								}
							)
			playLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 10*(screen.w/1920),
									mode = "EASE_IN_SINE",
								}
							)
			getLabel:animate(
								{
									duration = 1000,
									opacity = 0,
									x = 10*(screen.w/1920),
									mode = "EASE_IN_SINE",
								}
							)
			state = "onscreen"
		end
	end

end
