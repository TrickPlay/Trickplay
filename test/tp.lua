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

d_timer = Timer( 1/30 )

function d_timer.on_timer( t )
    local c = 0
    stage:foreach_child(
        function (child)
            if child.type == "Image" then
                c = c + 1
            
                child.depth = child.depth + 20
                local tp = child.transformed_position
                local ts = child.transformed_size
                
                if ( tp[1] > stage.w or tp[2] > stage.h )
                    or ( tp[1] + ts[1] < 0 ) or ( tp[2] + ts[2] < 0 ) then
                    stage:remove( child )                    
                end
            end
        end
    )
    if c == 0 then
        collectgarbage()
        return false
    end
end

dofile("Json.lua")

stage:set{ color = "000000" , size = { 960 , 540 } }


text = Text
    {
        font = "Sans 32px",
        color = "FFFFFF",
        position = { 5 , 0 },
        size = { 955 , 50 },        
        text = "airplane",
        cursor_visible = true,
        cursor_color = "0000FF",
        editable = true,
        wants_enter = false,
        max_length = 25        
    }
    
stage:add( text )

text:grab_key_focus()

search = nil
timer = Timer( 1 )

function text.on_text_changed( text )
    timer:stop()
    if #text.text > 2 then
        search = text.text
        timer:start()
    end
end

image_queue = {}

add_image_timer = Timer( 0.5 )

function add_image_timer.on_timer( timer )

    collectgarbage()

    if #image_queue > 0 then
    
        url = table.remove( image_queue , 1 )
        
        local image = Image{ src = url }

        function image.on_size_changed( image , width , height )
            image.anchor_point = { width / 2 , height / 2 }
            image.position =
                {
                    math.random(-stage.w,stage.w*2) ,
                    math.random(-stage.h,stage.h*2) ,
                    math.random(-5000,-4000)
                }
            stage:add( image )
            image.on_size_changed = nil
            d_timer:start()
        end
        
        function image.on_loaded( image , failed )
            if failed then
                image.on_size_changed = nil
            end
            image.on_loaded = nil
        end
        

    end
    
    return #image_queue > 0
end

function timer.on_timer( timer )
    
    function escape (s)
      s = string.gsub(s, "([&=+%c])", function (c)
            return string.format("%%%02X", string.byte(c))
          end)
      s = string.gsub(s, " ", "+")
      return s
    end

    local base="http://boss.yahooapis.com/ysearch/images/v1/"
    local apikey = "BGR2OV3V34EaSUqKb6VEjhskkPX_Kw.SkooCmNjnYsESJeb4gULWCiVdosX_"
    local max = 50

    local request = URLRequest( base.."\""..escape(search).."\"?appid="..apikey.."&dimensions=medium&count="..max )
    
    function request.on_complete( request , response )

        local result = Json.Decode( response.body )
        
        for i , photo in pairs( result.ysearchresponse.resultset_images ) do
            table.insert( image_queue , 1 , photo.url )
        end
        
        request.on_complete = nil
        
        add_image_timer:start()
        
        collectgarbage()
    end
    
    request:send()
    
    return false
end



