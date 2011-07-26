--------------------
-- Message Window 
--------------------

local msg_window 		= {}
local msgw_focus 		= ""
local input_purpose     = ""

local  msgw = Group {
	     name = "msgw",
}

local msgw_cur_x = 25  
local msgw_cur_y = 50

local function cleanMsgWindow()
     msgw_cur_x = 25
     msgw_cur_y = 50
	 local msgw = screen:find_child("msgw")
     screen:remove(msgw)
     input_mode = hdr.S_SELECT
end 

local projectlist_len 
local selected_prj 	= ""

function msg_window.printMsgWindow(txt, name)
     if (name == nil) then
        name = "pritMsgWindow"
     end

     txt_sz = string.len(txt) 
     local n = table.getn(projects)
  
     if n == 0 then 
     	txt = "New Project : "
     	name = ""
     end 
 
     if (name == "aleady_exists" ) then
		txt_sz = txt_sz - 50
     elseif(name == "projectlist") then  
     	projectlist_len = n * 45 
		txt_sz = projectlist_len + 20  
		if (n > 14) then 
			msgw.position = {400, 100}
		elseif (n > 10) then 
			msgw.position = {400, 200}
		elseif (n > 5) then 
			msgw.position = {400, 300}
		end 
     else 
     	i, j = string.find(txt, "\n")
     	if (j ~= nil) then 
	     txt_sz = txt_sz + 20 
        end 
     end 
     local msgw_bg = factory.make_popup_bg("msgw", txt_sz)
     if msgw_bg.Image then
  	 	msgw_bg= msgw_bg:Image()
     end

     msgw:add(msgw_bg)
     input_mode = hdr.S_POPUP
     local textText = Text{name= name, text = txt, font= "DejaVu Sans 32px",
     color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y+10}, editable = false ,
     reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"}
     msgw:add(textText)     
     textText:grab_key_focus()
  

     if(name == "projectlist") then  
         msgw_cur_x = msgw_cur_x + string.len(txt) * 20
	 
     	 for i, j in pairs (projects) do  
	     --local prj_text = Text {text = j, color = {255,255,255,255}, font= "DejaVu Sans 32px", color = "FFFFFF"}
	     local prj_text = Text {text = j, color = DEFAULT_COLOR, font= "DejaVu Sans 32px", color = "FFFFFF"}
	     prj_text.reactive = true
	     prj_text.position = {msgw_cur_x, msgw_cur_y+10}
	     prj_text.extra.index = i 
	     prj_text.name = "prj"..i 
	     msgw:add(prj_text)
	     msgw_cur_y = msgw_cur_y + 32 + 10 -- 10 : line padding 

	     function prj_text.extra.on_focus_in()
                  prj_text:set{color = {0,255,0,255}}
	 	  prj_text:grab_key_focus()
		  msgw_focus = prj_text.name
             end
    
             function prj_text.extra.on_focus_out()
                  prj_text:set{color = {255,255,255,255}}
             end

	     function prj_text:on_key_down(key)
			if(key == keys.Return) then 
		     if( selected_prj == prj_text.name) then 
			selected_prj = ""
			prj_text.extra.on_focus_in()
		     else
			if( selected_prj ~= "") then  
			    if(msgw:find_child(selected_prj) ~= nil) then 
				msgw:find_child(selected_prj):set{color = {255,255,255,255}} 
			    end 
			end 
			selected_prj = prj_text.name
		     end 
			elseif(key == keys.Tab and shift == false) or (key == keys.Down) or key == keys.Right then 
			prj_text.extra.on_focus_out()
			if(prj_text.name == selected_prj) then
			     prj_text:set{color = {0,255,0,255}}
			end 
			if (prj_text.extra.index < n) then 
				local k = prj_text.extra.index + 1
				msgw:find_child("prj"..k).extra.on_focus_in()
			else 
				msgw:find_child("input_b").extra.on_focus_in()
			end 
			elseif(key == keys.Tab and shift == true) or key == keys.Up or key == keys.Left then 
			if (prj_text.extra.index > 1) then 
				prj_text.extra.on_focus_out()
				if(prj_text.name == selected_prj) then
			     	     	prj_text:set{color = {0,255,0,255}}
				end 
				local k = prj_text.extra.index - 1
				msgw:find_child("prj"..k).extra.on_focus_in()
			end 
			end 
			return true 
	     end 

	     function prj_text:on_button_down(x,y,button,num)
	         if( selected_prj ~= "") then  
		      if(msgw:find_child(selected_prj) ~= nil) then 
		           msgw:find_child(selected_prj):set{color = {255,255,255,255}} 
	              end 
		 	end 
	         msgw:find_child(msgw_focus).extra.on_focus_out()
		 	prj_text.extra.on_focus_in()
		 	selected_prj = prj_text.name
		 	msgw_focus = prj_text.name --1102
	     end 

	     if (i == 1) then msgw_focus = prj_text.name project = prj_text.text end 

         end 
     end 
end

function msg_window.inputMsgWindow_savefile(input_text, cfn, save_current_file)

     local global_section_contents, new_contents, global_section_footer_contents
     local file_not_exists = true
     local screen_dir = editor_lb:readdir(current_dir.."/screens/")
     local main_dir = editor_lb:readdir(current_dir)
     local enter_gen_stub_code = false

	 if cfn ~= "OK" and save_current_file == nil then 
     	for i, v in pairs(screen_dir) do
          if(input_text == v)then
			cleanMsgWindow()
			editor.error_message("004",input_text,msg_window.inputMsgWindow_savefile)
			return 
          end
		end
	end 

      -- main generation
    if (file_not_exists or cfn) then
	   	local main_exist = false
	   	local app_exist = false

	   	local a, b = string.find(input_text,"screens") 
	   	if a then 
			input_text = string.sub(input_text, 9, -1)
	   	end 

	   	local fileUpper= string.upper(string.sub(input_text, 1, -5))
	   	local fileLower= string.lower(string.sub(input_text, 1, -5))
	
	   	local function gen_stub_code (grp) 

		
		new_contents="--  "..fileUpper.." SECTION\ngroups[\""..fileLower.."\"] = Group() -- Create a Group for this screen\nlayout[\""..fileLower.."\"] = {}\nloadfile(\"\/screens\/"..input_text.."\")(groups[\""..fileLower.."\"]) -- Load all the elements for this screen\nui_element.populate_to(groups[\""..fileLower.."\"],layout[\""..fileLower.."\"]) -- Populate the elements into the Group\n\n"

		for i, j in pairs (grp.children) do 
		     local function there() 
		     if util.need_stub_code(j) == true then 
	                   new_contents = new_contents.."-- "..fileUpper.."\."..string.upper(j.name).." SECTION\n" 	--SECTION \n\n		
			   if j.extra.type == "Button" then 
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.focused = function() -- Handler for "..j.name.."\.focused in this screen\nend\n"
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.pressed = function() -- Handler for "..j.name.."\.pressed in this screen\nend\n"
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.released = function() -- Handler for "..j.name.."\.released in this screen\nend\n"
			   elseif j.extra.type == "ButtonPicker" or j.extra.type == "RadioButtonGroup" then 
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.rotate_func = function(selected_item) -- Handler for "..j.name.."\.rotate_func in this screen\nend\n"
			   elseif j.extra.type == "CheckBoxGroup" then 
	                   	new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.rotate_func = function(selected_items) -- Handler for "..j.name.."\.rotate_func in this screen\nend\n"
			   elseif j.extra.type == "MenuButton" then 
			   	for k,l in pairs (j.items) do 
			   	     if l["type"] == "item" then 
	                   			--new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.items["..k.."][\"f\"] = function() end -- Handler for in this menu button\n"
	                   			new_contents = new_contents.."layout[\""..fileLower.."\"]\."..j.name.."\.items["..k.."][\"f\"] = function() end -- Handler for the menuButton Item, "..l["string"].."\n"
			   	     end 
			   	end 
			   end 
	                   new_contents = new_contents.."-- END "..fileUpper.."\."..string.upper(j.name).." SECTION\n\n" 			
		     else -- qqqq if j 가 컨테이너 이며는 그속을 다 확인하여 스터브 코드가 필요한 것을 가려내야함. 흐미..   
			   if util.is_this_container(j) == true then 
				if j.extra.type == "TabBar" then 
					for q,w in pairs (j.tabs) do
						gen_stub_code(w)
					end
				elseif j.extra.type == "ScrollPane" or j.extra.type == "DialogBox" or j.extra.type == "ArrowPane" then 
					gen_stub_code(j.content)
			    elseif j.extra.type == "LayoutManager" then 
					local content_num = 0 
			        	for k,l in pairs (j.tiles) do 
						for n,m in pairs (l) do 
							if m then 
								j = m 
								there()
							end 
						end 
					end 
				elseif j.extra.type == "Group" then  
					gen_stub_code(j)
				end

			   end 
		     end 
		     end 
		     there()	  
		end 

		if enter_gen_stub_code == false then 
			new_contents = new_contents.."-- END "..fileUpper.." SECTION\n\n" 
			enter_gen_stub_code =true
		end 
	   end 
     	   for i, v in pairs(main_dir) do
          	if("main.lua" == v)then
			local main = readfile("main.lua")
			local added_stub_code = ""
			if string.find(main, "-- "..fileUpper.." SECTION") == nil then 
				-- 적당한 위치 찾아서 이 파일에 대한 내용을 넣어주기만 하면됨 이건 쉽지. 
				local q,w,main_first, main_last
				q, w = string.find(main, "-- END GLOBAL SECTION\n\n")
				gen_stub_code(g)
				if w~=nil then 
					 main_first = string.sub(main, 1, w)
					 main_last = string.sub(main, w+1, -1)
				end
				if new_contents then 
					main = ""
					main = main_first..new_contents..main_last
					editor_lb:writefile("main.lua",main, true)
				end 
			end 
		    main_exist = true
		end 
		if ("app" == v) then 
			app_exist = true
		end 
	   end 

	   --print(main_exist)

	   if main_exist == false then 
		-- main.lua 생성해서 

		global_section_contents = "function main()\n-- GLOBAL SECTION\nui_element = dofile(\"\/lib\/ui_element.lua\") --Load widget helper library\nlayout = {} --Table containing all the UIElements that make up each screen\ngroups = {} --Table of groups of the UIElements of each screen, each of which can then be ui_element.screen_add()ed\n-- END GLOBAL SECTION\n\n"
	        gen_stub_code(g)

		local screen_mouse_code = "\n-- SCREEN ON_MOTION SECTION\nfunction screen:on_motion(x,y)\n\tif dragging then\n\t\tlocal actor = unpack(dragging)\n\t\tif (actor.name == \"grip\") then\n\t\t\tlocal actor,s_on_motion = unpack(dragging)\n\t\t\ts_on_motion(x, y)\n\t\t\treturn true\n\t\tend\n\t\treturn true\n\tend\nend\n-- END SCREEN ON_MOTION SECTION\n\n-- SCREEN ON_BUTTON_UP SECTION\nfunction screen:on_button_up()\n\tif dragging then\n\t\tdragging = nil\n\tend\nend\n-- END SCREEN ON_BUTTON_UP SECTION\n"

		global_section_footer_contents="-- GLOBAL SECTION FOOTER \nscreen:grab_key_focus()\nscreen:show()\nscreen.reactive = true\n\nui_element.screen_add(groups[\""..fileLower.."\"])\n\n-- SCREEN ON_KEY_DOWN SECTION\nfunction screen:on_key_down(key)\nend\n-- END SCREEN ON_KEY_DOWN SECTION\n"..screen_mouse_code.."\n-- END GLOBAL SECTION FOOTER \nend\n\ndolater( main )\n"

		editor_lb:writefile("main.lua", global_section_contents, true)
		editor_lb:writefile("main.lua", new_contents, false)
		editor_lb:writefile("main.lua", global_section_footer_contents, false)
	   end 
	   if app_exist == false then 
		local app_contents = "app=\n{\tid = \"com.trickplay.editor\",\n\trelease = \"1\",\n\tversion = \"1.0\",\n\tname = \"TrickPlay\",\n\tcopyright = \"Trickplay Inc.\"\n}"
		editor_lb:writefile("app", app_contents, true)
	   end 
	 
           current_fn = "screens/"..input_text
           editor_lb:writefile(current_fn, contents, true)
	   screen:find_child("menu_text").text = screen:find_child("menu_text").extra.project .. "/" ..current_fn
           contents = ""
	   cleanMsgWindow()
           screen:grab_key_focus(screen) 
      end
      menu.menu_raise_to_top()

end -- end of msg_window.inputMsgWindow_savefile  

function msg_window.inputMsgWindow_openfile(input_text, ret)
    local dir = editor_lb:readdir(current_dir.."/screens")
	local back_fn = input_text..".back"

    if(input_text == nil) then
		print ("input_text is nil") 
		return 
    end 

    for i, v in pairs(dir) do
          if(v == back_fn)then
     	       back_fn = "screens/"..back_fn         
		  end
    end

    if(util.is_lua_file(input_text) == true) then 
        editor.close()
        current_fn = "screens/"..input_text

		local cfc = readfile(current_fn)
		local bfc = readfile(back_fn)

		if cfc ~= bfc and bfc ~= nil and ret == nil then 
			editor.error_message("009", input_text, msg_window.inputMsgWindow_openfile)  
			return
		elseif ret == "OK" then 
			bfc = readfile(back_fn)
			if bfc then 
				editor_lb:writefile(current_fn, bfc, true)
			end 
		end 

        local f = loadfile(current_fn)
        f(g) 

	   	if screen:find_child("timeline") then 
	      	for i,j in pairs (screen:find_child("timeline").children) do
	         	if j.name:find("pointer") then 
		    		j.extra.set = true
	         	end      
	      	end      
	   	end 
	   	screen:find_child("menu_text").text = screen:find_child("menu_text").text .. "/screens/" .. input_text
     else 
		  -- need error handling 
          --printMsgWindow("The file is not a lua file.\nFile Name : ","err_msg")
          --inputMsgWindow("reopenfile")
          return 
     end 

     if(g.extra.video ~= nil) then util.clear_bg() end 
     item_num = table.getn(g.children)

     local x_scroll_from=0
     local x_scroll_to=0

     local y_scroll_from=0
     local y_scroll_to=0

     for i, v in pairs(g.children) do
        v.reactive = true
	  	if(v.type == "Text") then
			v.cursor_visible = false
			function v:on_key_down(key)
             		if key == keys.Return then
						v:set{cursor_visible = false}
						return true
	     			end 
			end 
	  	end 
	  	v.extra.lock = false
        util.create_on_button_down_f(v)
	  
	  	if(v.type == "Group") then 
	       for j, c in pairs (v.children) do
		    	if util.is_in_list(v.extra.type, uiElements) == false then 
                	c.reactive = true
		        	c.extra.is_in_group = true
	  				c.extra.lock = false
                    util.create_on_button_down_f(c)
		    	end 
	       end 
	       if v.extra.type == "ScrollPane" or v.extra.type == "DialogBox" or v.extra.type == "ArrowPane" then 
		    	for j, c in pairs(v.content.children) do -- Group { children = {button4,rect3,} },
					c.reactive = true
		        	c.extra.is_in_group = true
	  				c.extra.lock = false
                    util.create_on_button_down_f(c)
		    	end 
	       elseif v.extra.type == "TabBar" then 
		    	for j, c in pairs(v.tabs) do 
					for k, d in pairs (c.children) do -- Group { children = {button4,rect3,} },
						d.reactive = true
		        		d.extra.is_in_group = true
	  					d.extra.lock = false
                    	util.create_on_button_down_f(d)
					end 
		    	end 
	       elseif v.extra.type == "LayoutManager" then 
		   		local f 
		   		f = function (k, c) 
     		    	if type(c) == "table" then
	 		   			table.foreach(c, f)
     		    	elseif not c.extra.is_in_group then 
			   			c.reactive = true
		           		c.extra.is_in_group = true
	  		   			c.extra.lock = false
                    	util.create_on_button_down_f(c)
     		    	end 
		   		end 
		   		table.foreach(v.tiles, f)
	       end 
	  end 

      if(v.x < 0) then 
			if( v.x < x_scroll_from )then 
		     	x_scroll_from = v.x 
			end
      end 
	  
      if(v.y < 0) then 
			if( v.y < y_scroll_from ) then 
		     	y_scroll_from = v.y 
			end
      end 

      if(v.x > screen.w) then 
			if( x_scroll_to < v.x + v.w)then 
		     	x_scroll_to = v.x + v.w
			end
      end 
	  
      if(v.y > screen.h) then 
			if(y_scroll_to < v.y + v.h) then 
		     	y_scroll_to = v.y + v.h 
			end
      end 

     end 

     if (x_scroll_to ~= 0 or x_scroll_from ~= 0 or y_scroll_to ~=0 or y_scroll_from ~= 0) then 
          --factory.make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     end 

     if(screen:find_child("screen_objects") == nil) then
	  	for i,j in pairs(g.children) do 
			if(y_scroll_from < 0) then
				j.y = j.y - y_scroll_from
			end 
			if(x_scroll_from < 0) then
				j.x = j.x - x_scroll_from
			end 
	  	end 
        screen:add(g)
     end

     menu.menu_raise_to_top()
end

function msg_window.inputMsgWindow_yn(txt)
     cleanMsgWindow()
     if(txt == "no") then
          editor.save(false)
     elseif(txt =="yes") then 
          editor_lb:writefile(current_fn, contents, true)
          contents = ""
     end
     screen:grab_key_focus(screen) 
end

function msg_window.inputMsgWindow_openvideo(notused, parm_txt)
     
	 print("inputMsgWindow_openvideo")
     if(util.is_mp4_file(parm_txt) == true) then 
          mediaplayer:load("assets/videos/"..parm_txt)
     else 
          return 
     end 


     video1 = { name = "video1", 
                type ="Video",
                viewport ={0,0,math.floor(screen.w * screen.scale[1]) ,math.floor(screen.h * screen.scale[2])},
           	source= "assets/videos/"..parm_txt,
           	loop= false, 
                volume=0.5  
              }

     g.extra.video = video1
     mediaplayer.on_loaded = function( self ) util.clear_bg() if(g.extra.video ~= nil) then self:play() end end 
     if(video1.loop == true) then 
	  	mediaplayer.on_end_of_stream = function ( self ) self:seek(0) self:play() end
     else  	
		mediaplayer.on_end_of_stream = function ( self ) self:seek(0) end
     end


end


function msg_window.inputMsgWindow_openimage(input_purpose, input_text)

     if(input_text == nil) then
		return
     end 

     local file_not_exists = true
     local dir = editor_lb:readdir(current_dir.."/assets/images")
     for i, v in pairs(dir) do
          if(input_text == v)then
               file_not_exists = false
          end
     end
     if (file_not_exists) then
          --cleanMsgWindow()
          --printMsgWindow("The file not exists.\nFile Name :","err_msg")
          --inputMsgWindow("reopenImg")
	  return 0
     end
 
     if (input_purpose == "open_bg_imagefile") then  
	  BG_IMAGE_20.opacity = 0
	  BG_IMAGE_40.opacity = 0
	  BG_IMAGE_80.opacity = 0
	  BG_IMAGE_white.opacity = 0
	  BG_IMAGE_import:set{src = input_text, opacity = 255} 
	  input_mode = hdr.S_SELECT
     elseif(util.is_img_file(input_text) == true) then 
	  
	  while (is_available("image"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	  end 

          ui.image= Image { name="image"..tostring(item_num),
          --src = input_text, opacity = 255 , position = {200,200}, 
          --src = trickplay.config.app_path.."/assets/images/"..input_text, opacity = 255 , position = {200,200}, 
          src = "/assets/images/"..input_text, opacity = 255 , position = {200,200}, 
	  extra = {org_x = 200, org_y = 200} }
          ui.image.reactive = true
	  ui.image.extra.lock = false
          util.create_on_button_down_f(ui.image)
          table.insert(undo_list, {ui.image.name, hdr.ADD, ui.image})
          g:add(ui.image)
	  
	  local timeline = screen:find_child("timeline")
  	  if timeline then 
	     ui.image.extra.timeline = {}
             ui.image.extra.timeline[0] = {}
	     local prev_point = 0
	     local cur_focus_n = tonumber(current_time_focus.name:sub(8,-1))
	     for l,k in pairs (attr_map["Image"]()) do 
	          ui.image.extra.timeline[0][k] = ui.image[k]
	     end
 	     if cur_focus_n ~= 0 then 
                 ui.image.extra.timeline[0]["hide"] = true  
	     end 
	     for i, j in util.orderedPairs(timeline.points) do 
	        if not ui.image.extra.timeline[i] then 
	             ui.image.extra.timeline[i] = {} 
	             for l,k in pairs (attr_map["Image"]()) do 
		         ui.image.extra.timeline[i][k] = ui.image.extra.timeline[prev_point][k] 
		     end 
		     prev_point = i 
		end 
	        if i < cur_focus_n  then 
                     ui.image.extra.timeline[i]["hide"] = true  
		end 
	     end 
	  end 


	
          if(screen:find_child("screen_objects") == nil) then
               screen:add(g)
          end 
          item_num = item_num + 1
     else 
	  --cleanMsgWindow()
	  --screen:grab_key_focus(screen) -- iii
          --printMsgWindow("The file is not an image file.\nFile Name : ","err_msg")
          --inputMsgWindow("reopenImg")
          return 
     end 

     --cleanMsgWindow()
     --screen:grab_key_focus(screen)
end



function msg_window.inputMsgWindow(input_purpose, cfn)


     local save_b, cancel_b, input_box, open_b, yes_b, no_b
     local save_t, cancel_t, input_box, open_t, yes_t, no_t
    

     if cfn then 
		msg_window.inputMsgWindow_savefile(cfn)
		return
     end 

     function create_on_key_down_f(button) 
     	function button:on_key_down(key)
	     if key == keys.Return then
              	if (button.name == "savefile") then msg_window.inputMsgWindow_savefile()
              	elseif (button.name == "yes") then msg_window.inputMsgWindow_yn(button.name)
              	elseif (button.name == "no") then msg_window.inputMsgWindow_yn(button.name)
              	elseif (button.name == "openfile") or (button.name == "reopenfile") then msg_window.inputMsgWindow_openfile() 
              	elseif (button.name == "projectlist") then set_project_path() editor.close()
              	elseif (button.name == "open_videofile") or (button.name == "reopen_videofile")then msg_window.inputMsgWindow_openvideo()
              	elseif (button.name == "open_imagefile") or (button.name == "reopenImg")  then  imsg_window.nputMsgWindow_openimage(input_purpose)
              	elseif (button.name == "cancel") then 	cleanMsgWindow() screen:grab_key_focus(screen)
							if(input_purpose == "projectlist") then projects = {} end 
                end
	        return true 
	     elseif (key == keys.Tab and shift == false) or ( key == keys.Down ) or (key == keys.Right) then 
		if (button.name == "savefile") then save_b.extra.on_focus_out() cancel_b.extra.on_focus_in()
              	elseif (button.name == "yes") then yes_b.extra.on_focus_out() no_b.extra.on_focus_in() 
              	elseif (button.name == "projectlist") then button.extra.on_focus_out() cancel_b.extra.on_focus_in() 
              	elseif (button.name == "openfile") or (button.name == "open_videofile") or (button.name == "reopen_videofile") or 
              	       (button.name == "open_imagefile") or (button.name == "reopenfile") or (button.name =="reopenImg") then 
			open_b.extra.on_focus_out() cancel_b.extra.on_focus_in() 
		end
	     elseif (key == keys.Tab and shift == true) or ( key == keys.Up ) or (key == keys.Left) then 
		if (button.name == "savefile") then save_b.extra.on_focus_out() input_box.extra.on_focus_in()
              	elseif (button.name == "no") then no_b.extra.on_focus_out() yes_b.extra.on_focus_in()
              	elseif (button.name == "projectlist") then button.extra.on_focus_out() 
				                           msgw:find_child("input_b").extra.on_focus_in()
              	elseif (button.name == "openfile") or (button.name == "open_videofile") or (button.name == "reopen_videofile") or 
              	(button.name == "open_imagefile") or (button.name == "reopenfile") or (button.name =="reopenImg") then 
			open_b.extra.on_focus_out() input_box.extra.on_focus_in()
              	elseif (button.name == "cancel") then 
			cancel_b.extra.on_focus_out() 
			if(open_b ~= nil) then open_b.extra.on_focus_in()
			elseif(save_b ~= nil) then save_b.extra.on_focus_in() end
               end
	     end 
        end 
     end 

     if (input_purpose == "reopenfile" or input_purpose == "reopenImg") or (input_purpose== "reopen_videofile") then 
		msgw_cur_x = msgw_cur_x + 200 
		msgw_cur_y = msgw_cur_y + 45
     elseif(input_purpose == "projectlist") then 
		msgw_cur_x = 25
		if(msgw_focus ~= "") then 
			msgw:add(Text{name= name, text = "   New Project : ", font= "DejaVu Sans 32px",
     		color = "FFFFFF", position ={msgw_cur_x, msgw_cur_y+10}, editable = false ,
     		reactive = false, wants_enter = false, wrap=true, wrap_mode="CHAR"})  
		else 
	     	msgw_focus = "input_b"
		end 

		msgw_cur_x = 360
		msgw_cur_y = msgw_cur_y + 10
     else 
		msgw_cur_x = msgw_cur_x + 200 
     end
     
     position = {msgw_cur_x, msgw_cur_y} 

     if (input_purpose ~= "yn") then 
		if(input_purpose == "projectlist") then 
            input_t = Text { name="input", font= "DejaVu Sans 30px", color = "FFFFFF" ,
            position = {25, 10}, text = "" , editable = true , reactive = true, wants_enter = false, w = screen.w , h = 50 }
            input_box = create_small_input_box(input_t)
            input_box.position = position
            msgw:add(input_box)
	    	input_box.extra.on_focus_out()
		else 
            input_box = create_input_box()
            input_box.position = position
            msgw:add(input_box)
	    input_box.extra.on_focus_in()
		end

     end 

     if (input_purpose == "savefile") then 

     	save_b, save_t  = factory.make_msgw_button_item( assets , "Save")
        save_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
		save_b.reactive = true 
		save_b.name = "savefile"

        cancel_b, cancel_t= factory.make_msgw_button_item( assets ,"Cancel")
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
		cancel_b.reactive = true 
		cancel_b.name = "cancel"
	
        msgw:add(save_b)
        msgw:add(cancel_b)
		create_on_key_down_f(save_b) 
		create_on_key_down_f(cancel_b) 

		function save_b:on_button_down(x,y,button,num_clicks)
			msg_window.inputMsgWindow_savefile()	
     	end 
		function save_t:on_button_down(x,y,button,num_clicks)
			msg_window.inputMsgWindow_savefile()	
     	end 


     elseif (input_purpose == "yn") then 
     	yes_b, yes_t  = factory.make_msgw_button_item( assets , "Yes")
        yes_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	yes_b.reactive = true
	yes_b.name = "yes"

        no_b, no_t= factory.make_msgw_button_item( assets ,"No")
        no_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	no_b.reactive = true
	no_b.name = "no"
	
        msgw:add(yes_b)
        msgw:add(no_b)

	create_on_key_down_f(yes_b) 
	create_on_key_down_f(no_b) 

	yes_b.extra.on_focus_in() 

	function yes_b:on_button_down(x,y,button,num_clicks)
		msg_window.inputMsgWindow_yn("yes")
		return true
     	end 
     	function no_b:on_button_down(x,y,button,num_clicks)
		msg_window.inputMsgWindow_yn("no")
		return true
     	end 
	function yes_t:on_button_down(x,y,button,num_clicks)
		msg_window.inputMsgWindow_yn("yes")
		return true
     	end 
     	function no_t:on_button_down(x,y,button,num_clicks)
		msg_window.inputMsgWindow_yn("no")
		return true
     	end 
     else 
     	open_b, open_t  = factory.make_msgw_button_item( assets , "Open")
        open_b.position = {msgw_cur_x + 260, msgw_cur_y + 70}
	open_b.reactive = true

        cancel_b, cancel_t = factory.make_msgw_button_item( assets ,"Cancel")
        cancel_b.position = {msgw_cur_x + 470, msgw_cur_y + 70}
	cancel_b.reactive = true 
	cancel_b.name = "cancel"
	
        msgw:add(open_b)
        msgw:add(cancel_b)


	if (input_purpose == "openfile") or  
	   (input_purpose == "reopenfile") then  
		open_b.name = "openfile"
		function open_b:on_button_down(x,y,button,num_clicks)
			msg_window.inputMsgWindow_openfile() 
			--return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			msg_window.inputMsgWindow_openfile() 
			--return true
     		end 
        elseif (input_purpose == "projectlist") then
 		open_b.name = "projectlist"
        	open_b.position = {360, msgw_cur_y + 70}
        	cancel_b.position = {560, msgw_cur_y + 70}

		function open_b:on_button_down(x,y,button,num_clicks)
				set_project_path()
		        editor.close()
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
				set_project_path()
		        editor.close()
     		end 

	elseif (input_purpose == "open_imagefile") or  
	       (input_purpose == "open_bg_imagefile") or  
	       (input_purpose == "reopenImg") then  
		open_b.name = "open_imagefile"
		function open_b:on_button_down(x,y,button,num_clicks)
			imsg_window.nputMsgWindow_openimage(input_purpose) 
			--return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			imsg_window.nputMsgWindow_openimage(input_purpose) 
			--return true
     		end 
	elseif (input_purpose == "open_videofile") or (input_purpose == "reopen_videofile") then  
		open_b.name = "open_videofile"
		function open_b:on_button_down(x,y,button,num_clicks)
			imsg_window.nputMsgWindow_openvideo() 
			return true
     		end 
		function open_t:on_button_down(x,y,button,num_clicks)
			imsg_window.nputMsgWindow_openvideo() 
			return true
     		end 
	end 
	create_on_key_down_f(open_b) 
	create_on_key_down_f(cancel_b) 
     end
     if(cancel_b ~= nil) then 
     	   function cancel_b:on_button_down(x,y,button,num_clicks)
		cleanMsgWindow()	
		screen:grab_key_focus(screen)
		if(input_purpose == "projectlist") then projects = {} end 
		--return true
     	   end 
     	   function cancel_t:on_button_down(x,y,button,num_clicks)
		cleanMsgWindow()	
		screen:grab_key_focus(screen)
		if(input_purpose == "projectlist") then projects = {} end 
		--return true
     	   end 
     end

     screen:add(msgw)
     input_mode = hdr.S_POPUP

	
     if( input_purpose =="yn") then 
          yes_b:grab_key_focus(yes_b)
     elseif( input_purpose == "projectlist") then 
	  if(msgw_focus ~= "") then 
	       msgw:find_child(msgw_focus).extra.on_focus_in()
	  end 
     else 
          input_t:grab_key_focus(input_t)
     end 

     function input_t:on_key_down(key)
	  if (input_t.text ~= "" and selected_prj ~= "") then 
		if(msgw:find_child(selected_prj) ~= nil) then 
			msgw:find_child(selected_prj):set{color = {255,255,255,255}}
		end 
		selected_prj = ""
	  end 

          if key == keys.Return or (key == keys.Tab and shift == false) or key == keys.Down or key == keys.Right then 
	      input_box.extra.on_focus_out()
	      if(open_b ~= nil) then open_b.extra.on_focus_in() 
	      elseif(save_b ~= nil) then save_b.extra.on_focus_in() end
	  elseif(key == keys.Tab and shift == true) or key == keys.Up or key == keys.Left then 
	      if (input_purpose == "projectlist") then 
	           local n = table.getn(projects)
	           input_box.extra.on_focus_out()
		   msgw:find_child("prj"..n).extra.on_focus_in()
		   return true 
	      end 
          end
     end 
	
    function input_t:on_button_down(x,y,button,num)
	 msgw:find_child(msgw_focus).extra.on_focus_out()
	 input_box.extra.on_focus_in()
    end 

    function input_box:on_button_down(x,y,button,num)
	 msgw:find_child(msgw_focus).extra.on_focus_out()
	 input_box.extra.on_focus_in()
    end 

end

return msg_window
