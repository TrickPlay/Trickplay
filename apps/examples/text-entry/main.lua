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

screen:show_all()

t = Text
    {
        text="Hello world, how are you doing?" ,
        position = { 10 , 10 } ,
        size = { 300 , 100 } ,
        color = "FFFFFF",
        font = "Sans 38px",
        wrap = false,
        selection_color = "FF00FF",
        cursor_color = "FF00FF"
        
    }

screen:add(
    Rectangle{ color = "FF0000" , position = t.position , size = t.size } ,
    t
    )

t.editable=true
t.cursor_visible = true
t.cursor_position = 3
t:set_selection(3,9)
print(t.selected_text)
print(t.cursor_position,t.selection_end,t.cursor_visible)
t:delete_selection()
print(t.text)
print(screen.key_focus.type)
screen.key_focus = t
t.wants_enter=false
t.reactive = true
t.password_char = 42

function t.on_key_down( self , key , unicode , time )
    print( "KEY DOWN" , self , self.type , key , unicode , time )
end

function t.on_key_up( self , key , unicode , time )
    print( "KEY UP  " , self , self.type , key , unicode , time )
end

function t.on_key_focus_in( self )
    print( "KEY IN  " , self , self.type )
end

function t.on_key_focus_out( self )
    print( "KEY OUT " , self , self.type )
end

function t.on_button_down( self , x , y , button , click_count )
    print( "BTN DOWN" , self , self.type , x , y , button , click_count )
end

function t.on_button_up( self , x , y , button , click_count )
    print( "BTN UP  " , self , self.type , x , y , button , click_count )
end

function t.on_scroll( self , x , y , direction )
    print( "SCROLL  " , self , self.type , x , y , direction )
end

function t.on_text_changed( self )
    print( "TEXT CHANGED" , self , self.type )
end

    
