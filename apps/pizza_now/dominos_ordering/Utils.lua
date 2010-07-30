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

function get_response(url, formdata)
   local request = URLRequest{url=url}
   if formdata then
      request.method="POST"
      request.body=urlencode(formdata)
   end

   local response = request:perform()
   assert(not response.failed)
   return response
end

function parse_form(html, form_id, debug)
   local match = string.match
   local gmatch = string.gmatch
   local formdata = {}
   local id
   local input_name
   local input_value
   local input_type
   local input_checked
   local input_selected

   local print =
      function(...)
         if debug then print(...) end
      end

   -- radio INPUT elements unchecked and checked
   local unchecked = {}
   local checked = {}

   for form_attrs, form_html in gmatch(html, "<form (.-)>(.-)</form>") do
      id = match(form_attrs, "id=['\"](.-)['\"]")
      local debugstr = "form with id " .. id .. " found"
      local width = string.len(debugstr)
      print("\n" ..
         string.rep("=", width+4) .. "\n" ..
         "= " .. debugstr .. " =\n" ..
         string.rep("=", width+4) .. "\n")
      if (not form_id) or id == form_id then
         for input_attrs in gmatch(form_html, "<input (.-)>") do
            input_name = match(input_attrs, "name=['\"](.-)['\"]")
            input_value = match(input_attrs, "value=['\"](.-)['\"]") or ""
            input_type = match(input_attrs, "type=['\"](.-)['\"]")
            input_checked = match(input_attrs, "checked=['\"](.-)['\"]") or match(input_attrs, " checked")

            if not input_type then
               print("No input type attr in input_attrs: " .. input_attrs)
               input_type = "text"
            end

            assert(input_name, "No input name attr in input_attrs: " .. input_attrs)
            
            if input_type == "hidden" then
               print(input_name, "=", input_value)
               formdata[input_name] = input_value
            elseif input_type == "text" then
               print(input_name, "=", input_value)
               formdata[input_name] = input_value
            elseif input_type == "radio" then
               if input_checked then
                  assert(not checked[input_name], "radio input " .. input_name .. " already checked")
                  print(input_name, "=", input_value)
                  formdata[input_name] = input_value
                  checked[input_name] = true
                  if unchecked[input_name] then
                     unchecked[input_name] = nil
                  end
               else
                  if checked[input_name] then
                     assert(not unchecked[input_name])
                  elseif not unchecked[input_name] then
                     unchecked[input_name] = input_value
                  end
               end
            elseif input_type == "checkbox" then
               if input_checked then
                  print(input_name, "=", input_value)
                  formdata[input_name] = input_value
               end
            end
         end -- matching input tags

         for select_attrs, select_html in gmatch(form_html, "<select (.-)>(.-)</select>") do
            input_name = match(select_attrs, "name=['\"](.-)['\"]")
            
            local opt_selected = false
            local first_option_val = nil
            for option_attrs, fallback_val in gmatch(select_html, "<option (.-)>(.-)</option>") do
               input_value = match(option_attrs, "value=['\"](.-)['\"]") or fallback_val
               input_selected = match(option_attrs, "selected=['\"](.-)['\"]") or match(option_attrs, " selected")
               if input_selected and not formdata[input_name] then
                  print(input_name, "=", input_value)
                  formdata[input_name] = input_value
                  opt_selected = true
               elseif not first_option_val then
                  first_option_val = input_value
               end
            end
            -- if not opt_selected then
            --    print("SELECT element " .. input_name .. " has no value selected, setting to " .. first_option_val)
            --    print(input_name, "=", first_option_val)
            --    formdata[input_name] = first_option_val
            -- end
         end
      end
   end
   -- for k,v in pairs(unchecked) do
   --    print("Radio input with name " .. k .. " left unchecked, defaulting to " .. v)
   --    formdata[k] = v
   -- end

   return formdata
end
