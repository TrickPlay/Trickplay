function inspector_apply (v, inspector)
      local org_object, new_object
      if(v.type == "Rectangle") then
           org_object = Rectangle{}
           new_object = Rectangle{}

           org_object.color = v.color
           v.color = inspector:find_child("fill_color  "):find_child("input_text").text
           new_object.color = v.color

           org_object.border_color = v.border_color
           v.border_color = inspector:find_child("border_color"):find_child("input_text").text
           new_object.border_color = v.border_color

           org_object.border_width = v.border_width
           v.border_width = tonumber(inspector:find_child("border_width"):find_child("input_text").text)
           new_object.border_width = v.border_width

       elseif (v.type == "Text") then
           org_object = Text{}
           new_object = Text{}

           org_object.color = v.color
           v.color = inspector:find_child("color"):find_child("input_text").text
           new_object.color = v.color

           org_object.font = v.font
           v.font = inspector:find_child("font "):find_child("input_text").text
           new_object.font = v.font

           org_object.text = v.text
           v.text = inspector:find_child("text"):find_child("input_text").text
           new_object.text = v.text

                  org_object.editable = v.editable
                  v.editable = toboolean(inspector:find_child("editable"):find_child("input_text").text)
                  new_object.editable = v.editable

                  org_object.wants_enter = v.wants_enter
                  v.wants_enter = toboolean(inspector:find_child("wants_enter"):find_child("input_text").text)
                  new_object.wants_enter = v.wants_enter

                  org_object.wrap = v.wrap
                  v.wrap = toboolean(inspector:find_child("wrap"):find_child("input_text").text)
                  new_object.wrap = v.wrap

                  org_object.wrap_mode = v.wrap_mode
                  v.wrap_mode = inspector:find_child("wrap_mode"):find_child("input_text").text
                  new_object.wrap_mode = v.wrap_mode

             elseif (v.type == "Image") then
                  org_object = Image{}
                  new_object = Image{}

                  org_object.src = v.src
                  v.src = inspector:find_child("src"):find_child("input_text").text
                  new_object.src = v.src

                  org_object.clip = v.clip
                  local clip_t = {}
                  clip_t[1] = inspector:find_child("cx"):find_child("input_text").text
                  clip_t[2] = inspector:find_child("cy"):find_child("input_text").text
                  clip_t[3] = inspector:find_child("cw"):find_child("input_text").text
                  clip_t[4] = inspector:find_child("ch"):find_child("input_text").text
                  v.clip = clip_t
                  new_object.clip = v.clip

             end
            org_object.name = v.name
            v.name = inspector:find_child("name"):find_child("input_text").text
            new_object.name = v.name

            org_object.x = v.x
            v.x = tonumber(inspector:find_child("x"):find_child("input_text").text)
            new_object.x = v.x

            org_object.y = v.y
            v.y = tonumber(inspector:find_child("y"):find_child("input_text").text)
            new_object.y = v.y

            org_object.z = v.z
            v.z = tonumber(inspector:find_child("z"):find_child("input_text").text)
            new_object.z = v.z

            org_object.w = v.w
            v.w = tonumber(inspector:find_child("w"):find_child("input_text").text)
            new_object.w = v.w

            org_object.h = v.h
            v.h = tonumber(inspector:find_child("h"):find_child("input_text").text)
            new_object.h = v.h

            org_object.opacity = v.opacity
            v.opacity = tonumber(inspector:find_child("opacity"):find_child("input_text").text)
            new_object.opacity = v.opacity

            table.insert(undo_list, {v.name, CHG, org_object, new_object})

	return org_object, new_object
end

