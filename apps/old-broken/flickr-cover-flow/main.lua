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

dofile("Json.lua")

screen:show_all()

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
    return "http://farm"..photo.farm..".static.flickr.com/"..photo.server.."/"..photo.id.."_"..photo.secret..".jpg"
end

num_photos = 50

-- make sure number is odd
num_photos = math.floor(num_photos/2)*2 + 1
-- make sure number is allowed by flickr API
if num_photos > 499 then num_photos = 499 end

local photos = get_photo_page(num_photos,1)

center_w = 500
center_h = 500
z_front = 0
z_back = -500
pad = 50
left_tilt = 85
right_tilt = -left_tilt

function size_changed( image , width , height )
    image.on_size_changed = nil

    image.keep_aspect_ratio = true
    if width > image.parent.w then
        image.w = image.parent.w
    end
    if height > image.parent.h then
        --image.h = image.parent.h
    end
    
    image.x = ( image.parent.w - image.w ) / 2
    image.y = ( image.parent.h - image.h )


    if not image.extra.no_reflect then
    image.parent:add(
        Clone{ source = image , position = image.position , size = image.size , x_rotation = { -180 , image.h , 0 } },
        Rectangle{ color = "000000CC" , w = image.w , h = image.h * 1.1 , x = image.x , y = image.y + image.h }
        )
    end
end

local logo_url = "http://userlogos.org/files/logos/sandwiches/flickr0.png"
local logo = Image {
				src = logo_url,
				keep_aspect_ratio = true,
				x = 12,
				y = 12,
				width = screen.w / 6,
}

screen:add(logo)

positions = {}


local g = Group{
    
    position = { ( screen.w - center_w ) / 2 , (screen.h - center_h ) / 3 } , 
    size = { center_w , center_h },
    children = { Image{ src = get_photo_url( table.remove( photos ) ) , on_size_changed = size_changed } }
    }

positions[0] = g

screen:add(g)

local l = ( screen.w  / 2 ) - ( pad )

for i = 1 , math.floor(num_photos/2) do

    local g = Group{
        position = { l , ( screen.h - center_h ) / 3 },
        size = { center_w , center_h },
        children = { Image{ src = get_photo_url( table.remove( photos ) ) , on_size_changed = size_changed } },
        y_rotation = { right_tilt , center_w , 0 }
    }
    
    screen:add( g )
    
    g:lower_to_bottom()
    
    g.z = z_back
    
    positions[ i ] = g
    
    l = l + pad

end

local l = ( screen.w / 2 ) + ( pad ) - center_w

for i = 1 , math.floor(num_photos/2) do

    local g = Group{
        position = { l , ( screen.h - center_h ) / 3 },
        size = { center_w , center_h },
        children = { Image{ src = get_photo_url( table.remove( photos ) ) , on_size_changed = size_changed } },
        y_rotation = { left_tilt , 0 , 0 }
    }
    
    screen:add( g )
    
    g:lower_to_bottom()
    
    g.z = z_back
    
    positions[ -i ] = g
    
    l = l - pad

end


local key_right = 65363
local key_left  = 65361
local key_down  = 65364
local key_up    = 65362
local key_enter = 65293

animations = {}
index = 0

timeline = Timeline{ duration = 200 }

alpha = Alpha{ timeline = timeline , mode = "EASE_OUT_SINE" }

function timeline.on_new_frame( timeline , msecs , progress )

    progress = alpha.alpha

    for i , t in ipairs( animations ) do
        t.g.x = t.x:get_value( progress )
        
        if t.z then
            t.g.z = t.z:get_value( progress )
        end
        
        if t.r then
            local r = t.g.y_rotation
            r[1] = t.r:get_value( progress )
            r[2] = t.rx
            t.g.y_rotation = r
        end
    end
end

function timeline.on_completed()
    animations = {}
end

function screen.on_key_down(screen,keyval)
    
    if keyval == key_left or keyval == key_right then
    
        if timeline.is_playing then
            return
        end
    
        local d = 1
        
        if keyval == key_right then
            d = -1
        end
        
        -- index is the slot which is currently active
        -- check if we are at the edge and can't move
        if index == d * math.floor(num_photos/2) then
            return
        end
        
        -- now index is moved to be the new active picture
        index = index + d
        
        -- loop through all the images and move them to their new location
        for i = -math.floor(num_photos/2) , math.floor(num_photos/2) do
        
				-- a is the image we're considering's current location; b is the new location
				-- NOTE that b might not exist if we're at the edge
            local a = positions[ i ]
            local b = positions[ i + d ]
            
            local animation = { g = a }

				-- check if in fact there IS a b element we can move to            
            if b then
                -- if there is, then set the destination of this image to be the current location of the next one along
                animation.x = Interval( a.x , b.x )
                animation.z = Interval( a.z , b.z )
					 -- rotate the image to its final orientation
                animation.r = Interval( a.y_rotation[1] , b.y_rotation[1] )
					 -- rotate around a point cleverly chosen
					 if index == i and 1 == d then
					 	 animation.rx = a.x
					 else
	                animation.rx = b.x
	             end
            else
            	 -- if there is no b element (for the edges), then we need to just shift the image along by a fixed amount
                animation.x = Interval( a.x , a.x + ( d * pad ) )
                animation.z = Interval( a.z , z_back )

                if i > 0 then
                    animation.r = Interval( a.y_rotation[1] , right_tilt )
                    animation.rx = center_w
                else
                    animation.r = Interval( a.y_rotation[1] , left_tilt )
                    animation.rx = 0
                end
            end
            
            table.insert( animations , animation )
               
        end
        
        timeline:start()
                
    elseif keyval == key_enter then
    
    end
    
end

