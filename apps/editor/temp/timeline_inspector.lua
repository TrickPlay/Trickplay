local function pointer_inspector(pointer)
	local pi  = Group {
	     name = "pointer_inspector",
	     position ={pointer.x, screen.h - 276},
             children = {}
        }

	screen:find_child("timeline")
	
	
	local input_l, input_t, input_box_l, input_box_t
	local save_t, save_b, cancel_t, cancel_b, delete_t, delete_b

	local function create_on_key_down_f(button) 
     	     function button:on_key_down(key)
	     if key == keys.Return then
              	if (button.name == "apply") then 
		     if (input_l.text ~= "") then 
			-- change the pointer label = input_l.text 
		     elseif (input_t.text ~= "") then 
		 	-- change the pointer time 
		        -- pointer_on_button_up() call ! with tonumber(input_t.text) 
			
		     end 
              	elseif (button.name == "delete") then  
		     -- delete the point 
              	end
		pi.children = {}
		screen:remove(pi)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	        return true 
	     elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
              	if (button.name == "cancel") then cancel_b.extra.on_focus_out() save_b.extra.on_focus_in()
              	elseif (button.name == "apply") then save_b.extra.on_focus_out() delete_b.extra.on_focus_in()
              	elseif (button.name == "delete") then 
		     delete_b.extra.on_focus_out()
		     if(pointer_type(v.name) == "v_pointer") then 
			  input_box_t.extra.on_focus_in()
                          input_t.cursor_visible = true
		     elseif(pointer_type(v.name) == "h_pointer") then 
			  input_box_l.extra.on_focus_in()
                          input_l.cursor_visible = true
		     end 
                end
	        return true 
	     elseif (key == keys.Tab and shift == true) or ( key == keys.Up ) or (key == keys.Left) then 
              	if (button.name == "apply") then 
		     save_b.extra.on_focus_out() 
		     cancel_b.extra.on_focus_in()
              	elseif (button.name == "cancel") then 
	             cancel_b.extra.on_focus_out()	
		     if(pointer_type(v.name) == "v_pointer") then 
			  input_box_t.extra.on_focus_in()
                          input_t.cursor_visible = true
		     elseif(pointer_type(v.name) == "h_pointer") then 
			  input_box_l.extra.on_focus_in()
                          input_l.cursor_visible = true
		     end 
              	elseif (button.name == "delete") then 
		     delete_b.extra.on_focus_out()
		     save_b.extra.on_focus_in()
                end
	        return true 
	     end 
             end 
        end 

	local pi_bg = factory.make_popup_bg("guidew", 0)

     	pi:add(pi_bg)
     	pi:add(Text{name= "title", text = "GUIDE LINE", font= "DejaVu Sans 25px",
     	color = "FFFFFF", position ={pi.w * 2/5, 40}, editable = false , reactive = false})

	if(pointer_type(v.name) == "h_pointer") then 
             input_l = Text { name="input_l", font= "DejaVu Sans 25px", color = "FFFFFF", 
	     position = {10, 10}, text = tostring(v.y), editable = true , reactive = true, cursor_visible=false}

             input_t = Text { name="input_t", font= "DejaVu Sans 25px", color = "FFFFFF", 
	     position = {10, 10}, text = "" , editable = true , reactive = true, cursor_visible=false}
	elseif(pointer_type(v.name) == "v_pointer") then 
             input_t = Text { name="input_t", font= "DejaVu Sans 25px", color = "FFFFFF", 
	     position = {10, 10}, text = tostring(v.x) , editable = true , reactive = true, cursor_visible=false}

             input_l = Text { name="input_l", font= "DejaVu Sans 25px", color = "FFFFFF", 
	     position = {10, 10}, text = "", editable = true , reactive = true, cursor_visible=false}
	end 

	pi:add(Text{name= "label", text = "LABEL", font= "DejaVu Sans 25px",
     	color = "FFFFFF", position ={40, 90}, editable = false , reactive = false})

	input_box_l = create_tiny_input_box(input_l)
        input_box_l.position = {140, 90}
        pi:add(input_box_l)

	pi:add(Text{name= "timepoint", text = "TIME", font= "DejaVu Sans 25px",
     	color = "FFFFFF", position ={350, 90}, editable = false ,
     	reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"}) 
	
	input_box_t = create_tiny_input_box(input_t)
        input_box_t.position = {430, 90}
        pi:add(input_box_t)

	save_b, save_t  = factory.make_msgw_button_item( assets , "Apply")
        save_b.position = {250, 150}
	save_b.reactive = true 
	save_b.name = "apply"

        cancel_b, cancel_t= factory.make_msgw_button_item( assets ,"Cancel")
        cancel_b.position = {40, 150}
	cancel_b.reactive = true 
	cancel_b.name = "cancel"
	
        delete_b, delete_t= factory.make_msgw_button_item( assets ,"Delete")
        delete_b.position = {450, 150}
	delete_b.reactive = true 
	delete_b.name = "delete"

        pi:add(cancel_b)
        pi:add(save_b)
        pi:add(delete_b)

	create_on_key_down_f(save_b) 
	create_on_key_down_f(cancel_b) 
	create_on_key_down_f(delete_b) 

	 function input_l:on_key_down(key)
		if(key == keys.Return) then 
		elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
			input_box_l.extra.on_focus_out()
                        input_l.cursor_visible = false
              		cancel_b.extra.on_focus_in()
	                return true 
                end
	 end

	 function input_t:on_key_down(key)
		if(key == keys.Return) then 
		elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
			input_box_t.extra.on_focus_out()
                        input_t.cursor_visible = false
			cancel_b.extra.on_focus_in()
			return true
		end 
	 end
	
	 function cancel_b:on_button_down(x,y,button,num_clicks)
		pi.children = {}
		screen:remove(pi)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
         end 

         function cancel_t:on_button_down(x,y,button,num_clicks)
		pi.children = {}
		screen:remove(pi)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
         end 

	 function save_b:on_button_down(x,y,button,num_clicks)
		if (input_l.text ~= "") then 
		     v.y = tonumber(input_l.text) 
		elseif (input_t.text ~= "") then 
		     v.x = tonumber(input_t.text) 
		end 
		pi.children = {}
		screen:remove(pi)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	 end 

         function save_t:on_button_down(x,y,button,num_clicks)
	        if (input_l.text ~= "") then 
		     v.y = tonumber(input_l.text) 
		elseif (input_t.text ~= "") then 
		     v.x = tonumber(input_t.text) 
		end 

		pi.children = {}
		screen:remove(pi)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	 end 

	 function delete_b:on_button_down(x,y,button,num_clicks)
		pi.children = {}
		screen:remove(screen:find_child(v.name))
		screen:remove(pi)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	 end 

         function delete_t:on_button_down(x,y,button,num_clicks)
		pi.children = {}
		screen:remove(screen:find_child(v.name))
		screen:remove(pi)
                input_mode = S_SELECT
	        screen:grab_key_focus(screen)
	 end 
         
	input_mode = S_POPUP 
	screen:add(pi)

	if(pointer_type(v.name) == "h_pointer")then 
            input_l.cursor_visible = true
	    input_box_l.extra.on_focus_in()
	    input_l:grab_key_focus()
	else 
            input_t.cursor_visible = true
	    input_box_t.extra.on_focus_in()
	    input_t:grab_key_focus()
	end

end 
