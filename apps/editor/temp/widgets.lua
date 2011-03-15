
function editor.widgets()
	local WIDTH = 500
	local L_PADDING = 50
	local R_PADDING = 50
        local TOP_PADDING = 60
        local BOTTOM_PADDING = 12
        local Y_PADDING = 10 
	local X_PADDING = 10
	local STYLE = {font = "DejaVu Sans 26px" , color = "FFFFFF"}
	local space = WIDTH
	local msgw_bg = factory.make_popup_bg("widgets")
	local msgw = Group {
	     position ={500, 100},
	     anchor_point = {0,0},
             children =
             {
              msgw_bg,
             }
	}
        local widgets_list = Text {name = "w_list", text = "Widgets List"}:set(STYLE)
	local text_g

	cur_w= (WIDTH - widgets_list.w)/2
	cur_h= TOP_PADDING/2 + Y_PADDING

        widgets_list.position = {cur_w,cur_h}
        msgw:add(widgets_list)

	local widgets = {"Button", "Text_Input_Box", "Message_Window", "Sliding_Button", "Scroll_Bar", "Menu_Bar"}
        
        function print_widget_list() 
	    cur_w = L_PADDING
            cur_h = TOP_PADDING + widgets_list.h + Y_PADDING

	    text_g = Group{position = {cur_w, cur_h}}
	    text_g.extra.org_y = cur_h
	    text_g.reactive  = true 
            cur_w = 0
	    cur_h = 0 

            local input_text
            for i, v in pairs(widgets) do
	        text = Text {name = tostring(i), text = v}:set(STYLE)
                text.position  = {cur_w, cur_h}
		text.reactive = true
    	        text_g:add(text)

		if(cur_w == L_PADDING) then
		     cur_w = cur_w + 7*L_PADDING
		else 
	             cur_w = 0 
	             cur_h = cur_h + text.h + Y_PADDING
		end
           end
           cur_w = cur_w + L_PADDING
           cur_h = cur_h + TOP_PADDING + widgets_list.h + Y_PADDING
           msgw:add(text_g)
	end

	print_widget_list()
	
	local file_list_size = 250
        local open_b, open_t  = factory.make_msgw_button_item( assets , "open")
    	open_b.position = {(WIDTH - 2*open_b.w - X_PADDING)/2, file_list_size + 110}
    	open_b.name = "openfile"
    	open_b.reactive = true

    	local cancel_b, cancel_t = factory.make_msgw_button_item( assets , "cancel")
    	cancel_b.position = {open_b.x + open_b.w + X_PADDING, file_list_size + 110}
    	cancel_b.name = "cancel"
    	cancel_b.reactive = true 
	
    	msgw:add(open_b)
    	msgw:add(cancel_b)

    function open_b:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then 
              inputMsgWindow_openfile(input_text.text) 
	      cleanMsgWin(msgw)
	 end 
    end 
    function open_t:on_button_down(x,y,button,num_clicks)
	 if (input_text ~= nil) then 
              inputMsgWindow_openfile(input_text.text) 
	      cleanMsgWin(msgw)
	 end 
    end 

    function cancel_b:on_button_down(x,y,button,num_clicks)
	 cleanMsgWin(msgw)
	 screen:grab_key_focus(screen)
    end 

    function cancel_t:on_button_down(x,y,button,num_clicks)
	 cleanMsgWin(msgw)
	 screen:grab_key_focus(screen)
    end 

    screen:add(msgw)
--]]
end 

