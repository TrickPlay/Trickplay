local encodings = {
   [" "]="%20",
   ["<"]="%3C",
   [">"]="%3E",
   ["#"]="%23",
   ["%"]="%25",
   ["{"]="%7B",
   ["}"]="%7D",
   ["|"]="%7C",
   ["\\"]="%5C",
   ["^"]="%5E",
   ["~"]="%7E",
   ["["]="%5B",
   ["]"]="%5D",
   ["`"]="%60",
   [";"]="%3B",
   ["/"]="%2F",
   ["?"]="%3F",
   [":"]="%3A",
   ["@"]="%40",
   ["="]="%3D",
   ["&"]="%26",
   ["$"]="%24"
}
function urlencode(tbl)
   assert(type(tbl) == "table")
   result_tbl = {}
   local key, value
   for k,v in pairs(tbl) do
      key=string.gsub(k, '.', encodings)
      value=string.gsub(v, '.', encodings)
      table.insert(result_tbl, key .. "=" .. value)
   end
   return table.concat(result_tbl, "&")
end

function urlescape(str)
   assert(type(str) == "string")
   return string.gsub(str, '.', encodings)
end

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

function form_print(formdata)
   local temp_array = {}
   for k,v in pairs(formdata) do
      table.insert(temp_array, k .. " = " .. v)
   end
   
   table.sort(temp_array)
   print("\n" .. table.concat(temp_array,"\n"))
end