--------------------------------------------------------------------------------
-- FROM http://lua-users.org/wiki/TableSerialization
--------------------------------------------------------------------------------

function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end

--------------------------------------------------------------------------------
--[[
local goog = "http://www.google.com/intl/en_ALL/images/logo.gif"
local airplane = "http://www.tuxpaint.org/stamps/stamps/vehicles/flight/planes/747.png"
]]
--------------------------------------------------------------------------------

Timer{ interval = 2 , on_timer = function() collectgarbage() end }

dofile("Json.lua")

local cols_per_page = 10
local rows_per_page = 4
local cols_we_have = 0
local left_col = 0
local left_pad = 90
local top_pad = 70
local tile_size = 120
local selection_col = 0
local selection_row = 0
local max_pages = 0
local tilt_angle = 30

function get_tile_position( col , row )
    return { left_pad + ( col * tile_size ) , top_pad + ( row * tile_size ) }
end

function inflate( position , size , dx , dy )
    return { position[ 1 ] + dx , position[ 2 ] + dy } , { size[ 1 ] - ( dx * 2 ) , size[ 2 ] - ( dy * 2 ) }
end

local photo_index = {}


screen.color = "000000";
screen.size = { 960 , 540 }
screen:show_all()

local wall = Group{ position = { 0 , 0 } , size = screen.size }
wall.y_rotation = { 80 , 480 , 0 }
wall.z = -10000

screen:add( wall )

local logo_url = "http://userlogos.org/files/logos/sandwiches/flickr0.png"
local logo = Image {
				src = logo_url,
				keep_aspect_ratio = true,
				x = 5 * (screen.w / 6) - 12,
				y = 12,
				width = screen.w / 6,
}

screen:add(logo)




local flickr_api_key="e68b53548e8e6a71565a1385dc99429f"
local --flickr_base_url="http://api.flickr.com/services/rest/?method=flickr.interestingness.getList&format=json&nojsoncallback=1&extras=license,owner_name"
flickr_base_url="http://api.flickr.com/services/rest/?method=flickr.photos.search&license=4%2C5%2C6%2C7&sort=interestingness-desc&safe_search=1&content_type=1&media=photos&extras=license%2Cowner_name&format=json&nojsoncallback=1"
function get_photo_page(per_page,page)
    local json = URLRequest( flickr_base_url.."&per_page="..per_page.."&page="..page.."&api_key="..flickr_api_key):perform().body
    local result = {}
    json = Json.Decode( json )
    if max_pages == 0 then
        max_pages = json.photos.pages
    end
    for i , photo in ipairs( json.photos.photo ) do
        table.insert(result,photo)
    end
    return result
end

function get_photo_url(photo)
    return "http://farm"..photo.farm..".static.flickr.com/"..photo.server.."/"..photo.id.."_"..photo.secret.."_t.jpg"
end

local waiting = false

function image_size_changed( image , width , height )

    if ( width < 100 ) then
        image.x = image.x + ( 100 - width ) / 2
    end
    
    if ( height < 100 ) then
        image.y = image.y + ( 100 - height ) / 2
    end
    
    image.on_size_changed = nil
end

function populate_next_page(callback)

    local next_page_number = ( cols_we_have / cols_per_page ) + 1
    
    if max_pages > 0 and next_page_number > max_pages then
        return
    end
    
    if waiting then
        return
    end
    
    local request = URLRequest
            {
                url = flickr_base_url.."&per_page="..( cols_per_page * rows_per_page ).."&page="..next_page_number.."&api_key="..flickr_api_key ,
                on_complete =
                    function( request , response )
                
                        local json = Json.Decode( response.body )

                        if max_pages == 0 then
                            max_pages = json.photos.pages
                        end
                        
                        local start_col = cols_we_have
                        local col = start_col
                        local row = 0
                        local cols = 0
                        
                        for i , photo in ipairs( json.photos.photo ) do
                        
                            local ok
                            local url

                            ok , url = pcall( get_photo_url , photo )
                            
                            if ok then 
                                local image = Image{ src = url , position = get_tile_position( col , row ) }
                                
                                image.on_size_changed = image_size_changed
                                
                                wall:add( image )
                                
                                table.insert( photo_index , ( start_col * rows_per_page ) + i , photo )
                            end
                            
                            col = col + 1
                            if col == cols_per_page + start_col then
                                col = start_col
                                row = row + 1
                                cols = cols_per_page
                            end
                        end
                        
                        cols_we_have = cols_we_have + cols    

                        waiting = false
                        
                        if callback then
                            callback()
                        end
                    end
            }
                        
    waiting = true
    
    request:send()
        
end

local under = Rectangle{ color = { 150 , 10 , 4 } , opacity = 0 }

function move_selection()
    under.position , under.size = inflate( get_tile_position( selection_col , selection_row ) , { 100 , 100 } , -4 , -4 )
end

move_selection()

wall:add( under )

populate_next_page( populate_next_page ) 


local start_timeline = Timeline{ duration = 500 , delay = 800 }
local a = Interval( wall.z , 0 )
local b = Interval( wall.y_rotation[1] , tilt_angle )
local c = Alpha{ timeline = start_timeline , mode = "EASE_OUT_CIRC" }

function start_timeline.on_new_frame( t , msecs )
    wall.z = a:get_value( c.alpha )
    
end

function start_timeline.on_completed( )
    
    local t = Timeline{ duration = 1000 }
    
    local d = Alpha{ timeline = t , mode = "EASE_OUT_ELASTIC" }
    
    function t.on_new_frame(t)
        wall.y_rotation = { b:get_value( d.alpha ) , screen.w / 2 , 0 }
        under.opacity = 255 * t.progress
    end
        
    t:start()
end

start_timeline:start()




local x_interval = nil
local y_interval = nil

local timeline = Timeline{ duration = 40 }

function timeline.on_new_frame(t,msecs)
    
    if x_interval then
        under.x = x_interval:get_value( t.progress )
    end
    if y_interval then
        under.y = y_interval:get_value( t.progress )
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

function screen.on_key_down(screen,keyval)

    local function reset()
        if timeline.is_playing then
            --move_selection()
            if x_interval then
                under.x = x_interval.to
            end
            if y_interval then
                under.y = y_interval.to
            end
            timeline:stop()
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
    
    if keyval == key_right then
        
        reset()
        reset_wall()
        
        if selection_col >= cols_we_have - 1 then
            return
        end

        x_interval = Interval( under.x , under.x + 120 )
        y_interval = nil
        selection_col = selection_col + 1
        timeline:start()
        
        if selection_col + left_col > ( cols_we_have - 4 ) then
            populate_next_page()
        end
        
        if selection_col - left_col > 3 then
            local dx = 120 * math.cos( math.rad( tilt_angle ) )
            wall_x_interval = Interval( wall.x , wall.x - dx )
            wall_z_interval = Interval( wall.z , wall.z + ( dx * math.tan( math.rad( tilt_angle ) ) ) )
            
            left_col = left_col + 1
            
            wall_timeline:start()
        end
    
    elseif keyval == key_left then
        reset()
        reset_wall()
        
        if selection_col == 0 then
            return
        end
        x_interval = Interval( under.x , under.x - 120 )
        y_interval = nil
        selection_col = selection_col - 1
        
        timeline:start()
        
        if selection_col < left_col  and left_col > 0 then
            local dx = 120 * math.cos( math.rad( tilt_angle ) )
            wall_x_interval = Interval( wall.x , wall.x + dx )
            wall_z_interval = Interval( wall.z , wall.z - ( dx * math.tan( math.rad( tilt_angle ) ) ) )
            
            left_col = left_col - 1
            
            wall_timeline:start()
        end

    elseif keyval == key_up then
        reset()
        
        if selection_row > 0 then
            x_interval = nil
            y_interval = Interval( under.y , under.y - 120 )
            selection_row = selection_row - 1
            timeline:start()
        end

    elseif keyval == key_down then
        reset()
        
        if selection_row < 3 then
            x_interval = nil
            y_interval = Interval( under.y , under.y + 120 )
            selection_row = selection_row + 1        
            timeline:start()
        end
        
    elseif keyval == key_enter then
    

    else
        print( "KEY" , keyval )
    end

end

