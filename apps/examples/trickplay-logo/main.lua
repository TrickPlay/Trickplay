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
--------------------------------------------------------------------------------


stage:set{ color = "000000FF" , size = { 960 , 540 } }

local g = Group
    {
        size = { 800 , 500 } ,
        position = { 10 , 10 },
        children =
        {
            Rectangle{ color = { 255 , 255 , 255 } , border_width = 2 , border_color = { 255 , 0 , 255 } , size = { 240 , 120 } , position = { 90 , 90 } },
            Text{ font = "Sans 38px" , markup = "Hello <i>World</i>!" , color = { 255 , 0 , 0 , 128 } , position = { 100 , 100 } }
        }
        
    }

stage:add( g )

local ticks = 0

local r = Rectangle{ color = { 255 , 0 , 0 , 255 } , size = { 100 , 100 } , position = { 106 , 10 } }

local r2 =

Group{
    size = { 100 , 100 },
    position = { 106 , 10 },
    clip = { 0 , 0 , 100 , 100 },
    children = { 

        Rectangle{ color = "AF0000" , size = { 100 , 100 } , position = { 0 , 0 } , z_rotation = { 45 , 50 , 50 } }
    }
}

g.children = { r , r2 , Text{ font = "Sans 46px" , markup = "TrickPlay" , color = "FFFFFF" , position = { 0 , 50 } } }

print( to_string( stage.perspective , 2 ) )

local p = stage.perspective
p[1]=30
stage.perspective = p

local tim = Timeline{ duration = 5000 }

--tim:add_marker( "foo" , 1000 )
--tim:add_marker( "bar" , 1500 )
--tim:add_marker( "caca" , 1000 )


print( "MARKERS" , to_string( tim:list_markers( -1 ) ) )


local a = Alpha{ timeline = tim , mode = "EASE_IN_CUBIC" }


print( a.mode )

--[[
function a.on_alpha(self,progress)
    print( "PROGRESS" , progress )
    return 0.5
end
]]

local iv = Interval( 10 , 610 )
print (iv:get_value( 1 ) )

print( a.mode )

tim.loop = true

function tim.on_new_frame( self , msecs )
    --print( "NEW FRAME" , msecs , self.progress , self.delta , a.alpha )
    
    --g.opacity = 255 - ( self.progress * 255 )

    --g.x = iv:get_value( a.alpha )
    
    --g.y = 10 + ( a.alpha * 300 )
    
    --g.x_rotation = { 90 * a.alpha , g.w / 2 , 0 }
    g.y_rotation = { 360 * self.progress , 106 , -500 }
    
    --g.z_rotation = { 360 * self.progress , 206 , 100 }

    
    --g.depth = -5000 * a.alpha
    
end

function tim.on_started(self)
    print("Started" , self.duration )
end

function tim.on_paused(self)
    print( "PAUSED" )
end

function tim.on_marker_reached(self,marker,msecs)
    print( "REACHED MARKER" , marker , msecs )
    if marker == "foo" then
--        self:rewind()
    end
end

--[[
function tim.on_completed(self)
    print("COMPLETED")
    self.on_new_frame = nil
    self.on_started = nil
    self.on_paused = nil
    self.on_marker_reached = nil
    self.on_completed = nil
    tim = nil
end
]]

local h = { from = 10 , to = 12 }

--tim.loop = true

Timer{ interval = 0.5 , on_timer = function() tim:start() return false end }


