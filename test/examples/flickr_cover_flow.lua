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

stage:set{ color = "000000" , size = { 960 , 540 } }

local flickr_api_key="e68b53548e8e6a71565a1385dc99429f"
local flickr_base_url="http://api.flickr.com/services/rest/?method=flickr.interestingness.getList&format=json&nojsoncallback=1"

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

local photos = get_photo_page(15,1)

center_w = 300
center_h = 300

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
    
    image.parent:add(
        Clone{ source = image , position = image.position , size = image.size , x_rotation = { -180 , image.h , 0 } },
        Rectangle{ color = "000000CC" , w = image.w , h = image.h * 1.1 , x = image.x , y = image.y + image.h }
        )
end

positions = {}


local g = Group{
    
    position = { ( stage.w - center_w ) / 2 , (stage.h - center_h ) / 3 } , 
    size = { center_w , center_h },
    children = { Image{ src = get_photo_url( table.remove( photos ) ) , on_size_changed = size_changed } }
    }

positions[0] = g

stage:add(g)

local pad = 70
local l = ( stage.w / 2 ) - ( pad  )

for i = 1 , 7 do

    local g = Group{
        position = { l , ( stage.h - center_h ) / 3 },
        size = { center_w , center_h },
        children = { Image{ src = get_photo_url( table.remove( photos ) ) , on_size_changed = size_changed } },
        y_rotation = { -85 , center_w , 0 }
    }
    
    stage:add( g )
    
    g:lower_to_bottom()
    
    g.z = -200
    
    positions[ i ] = g
    
    l = l + pad

end

local l = ( stage.w / 2 ) + ( pad  ) - center_w

for i = 1 , 7 do

    local g = Group{
        position = { l , ( stage.h - center_h ) / 3 },
        size = { center_w , center_h },
        children = { Image{ src = get_photo_url( table.remove( photos ) ) , on_size_changed = size_changed } },
        y_rotation = { 85 , 0 , 0 }
    }
    
    stage:add( g )
    
    g:lower_to_bottom()
    
    g.z = -200
    
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

timeline = Timeline{ duration = 100 }

alpha = Alpha{ timeline = timeline , mode = "EASE_OUT_CIRC" }

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

function stage.on_key_down(stage,keyval)
    
    if keyval == key_left or keyval == key_right then
    
        if timeline.is_playing then
            return
        end
    
        local d = 1
        
        if keyval == key_right then
            d = -1
        end
        
        if index == d * 7 then
            return
        end
        
        index = index + d
        
        for i = -7 , 7 do
        
            local a = positions[ i ]
            local b = positions[ i + d ]
            
            local animation = { g = a }
            
            if b then
                animation.x = Interval( a.x , b.x )
                animation.z = Interval( a.z , b.z )
                animation.r = Interval( a.y_rotation[1] , b.y_rotation[1] )
                animation.rx = b.y_rotation[2]
            else
                animation.x = Interval( a.x , a.x + ( d * pad ) )
                animation.z = Interval( a.z , -200 )
                
                if i > 0 then
                    animation.r = Interval( a.y_rotation[1] , -85 )
                    animation.rx = center_w
                else
                    animation.r = Interval( a.y_rotation[1] , 85 )
                    animation.rx = 0
                end
            end
            
            table.insert( animations , animation )
               
        end
        
        timeline:start()
                
    elseif keyval == key_enter then
    
    end
    
end

