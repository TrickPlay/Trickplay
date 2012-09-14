--------------------
-- Message Window 
--------------------
local msg_window 		= {}
local input_purpose     = ""

local projectlist_len 
local selected_prj 	= ""

function msg_window.inputMsgWindow_savefile(input_text, cfn, save_current_file)

     local global_section_contents, new_contents, global_section_footer_contents
     local file_not_exists = true
     local screen_dir = editor_lb:readdir(current_dir.."/screens/")
	 if screen_dir == nil then screen_dir = {} end 

     local main_dir = editor_lb:readdir(current_dir)
	 if main_dir == nil then main_dir = {} end 

     local enter_gen_stub_code = false

	 if cfn ~= "OK" and save_current_file == nil then 
     	for i, v in pairs(screen_dir) do
          if input_text == v then
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

		local gen_stub_code 

		local function there(j) 
		     if util.need_stub_code(j) == true then 
	         	new_contents = new_contents.."-- "..fileUpper.."."..string.upper(j.name).." SECTION\n" 	--SECTION \n\n
			   	if j.extra.type == "Button" then 
	            	new_contents = new_contents.."layout[\""..fileLower.."\"]."..j.name..".on_focus = function() -- Handler for "..j.name..".on_focus in this screen\nend\n"
	                new_contents = new_contents.."layout[\""..fileLower.."\"]."..j.name..".on_press = function() -- Handler for "..j.name..".on_press in this screen\nend\n"
	                new_contents = new_contents.."layout[\""..fileLower.."\"]."..j.name..".on_unfocus = function() -- Handler for "..j.name..".on_unfocus in this screen\nend\n"
			    elseif j.extra.type == "ButtonPicker" or j.extra.type == "RadioButtonGroup" then 
	            	new_contents = new_contents.."layout[\""..fileLower.."\"]."..j.name..".on_selection_change = function(selected_item) -- Handler for "..j.name..".on_selection_change in this screen\nend\n"
			   	elseif j.extra.type == "CheckBoxGroup" then 
	                new_contents = new_contents.."layout[\""..fileLower.."\"]."..j.name..".on_selection_change = function(selected_items) -- Handler for "..j.name..".on_selection_change in this screen\nend\n"
			   	elseif j.extra.type == "MenuButton" then 
			   		for k,l in pairs (j.items) do 
			   	     	if l["type"] == "item" then 
	                   		new_contents = new_contents.."layout[\""..fileLower.."\"]."..j.name..".items["..k.."][\"f\"] = function() end -- Handler for the menuButton Item, "..l["string"].."\n"
			   	     	end 
			   		end 
			   	end 
	            new_contents = new_contents.."-- END "..fileUpper.."."..string.upper(j.name).." SECTION\n\n"
		     else -- if j 가 컨테이너 이며는 그속을 다 확인하여 스터브 코드가 필요한 것을 가려내야함. 흐미..   
			   if util.is_this_container(j) == true then 
					if j.extra.type == "TabBar" then 
						for q,w in pairs (j.tabs) do
							gen_stub_code(w)
						end
					elseif j.extra.type == "ScrollPane" or j.extra.type == "DialogBox" or j.extra.type == "ArrowPane" then 
						gen_stub_code(j.content)
			    	elseif j.extra.type == "LayoutManager" then 
						local content_num = 0 
						local lm_name = j.name
			        	for k,l in pairs (j.cells) do 
							for n,m in pairs (l) do 
								if m then 
									j = m 
									there(j)
								end 
							end 
						end 
						new_contents = new_contents.."-- "..fileUpper.."."..string.upper(lm_name).." SECTION\n\n\t--[[\n\t\tHere is how you might add set_focus and clear_focus function to the each cell item\n\t]]\n\n\t--[[\n\t\tfor r=1, layout[\""..fileLower.."\"]."..lm_name..".rows do\n\t\t\tfor c=1, layout[\""..fileLower.."\"]."..lm_name..".columns do\n\t\t\t\t".."local cell_obj = layout[\""..fileLower.."\"]."..lm_name..".cells[r][c]\n\t\t\t\tif cell_obj.extra.set_focus == nil then\n\t\t\t\t\tfunction cell_obj.extra.set_focus ()\n\t\t\t\t\tend\n\t\t\t\tend\n\t\t\t\tif cell_obj.extra.clear_focus == nil then\n\t\t\t\t\tfunction cell_obj.extra.clear_focus ()\n\t\t\t\t\tend\n\t\t\t\tend\n\t\t\tend\n\t\tend\n\t]]\n\n-- END "..fileUpper.."."..string.upper(lm_name).." SECTION\n\n"
					elseif j.extra.type == "Group" then  
						gen_stub_code(j)
					end
			   end -- is this container == true 
		    end  -- need stub code ~= true
		end -- function there

	   	gen_stub_code = function(grp) 
	 
			if new_contents == nil then 	
				new_contents="-- "..fileUpper.." SECTION\ngroups[\""..fileLower.."\"] = Group() -- Create a Group for this screen\nlayout[\""..fileLower.."\"] = {}\nloadfile(\"/screens/"..input_text.."\")(groups[\""..fileLower.."\"]) -- Load all the elements for this screen\nui_element.populate_to(groups[\""..fileLower.."\"],layout[\""..fileLower.."\"]) -- Populate the elements into the Group\n\n"
			end

			for i, j in pairs (grp.children) do 
				there(j)	  
	   		end -- for g.chilren do
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
					new_contents = new_contents.."-- END "..fileUpper.." SECTION\n\n"
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


	   if main_exist == false then 
		-- main.lua 생성해서 

		global_section_contents = "function main()\n-- GLOBAL SECTION\nui_element = dofile(\"/lib/ui_element.lua\") --Load widget helper library\nlayout = {} --Table containing all the UIElements that make up each screen\ngroups = {} --Table of groups of the UIElements of each screen, each of which can then be ui_element.screen_add()ed\n-- END GLOBAL SECTION\n\n"
	        gen_stub_code(g)

		local screen_mouse_code = "\n-- SCREEN ON_MOTION SECTION\nfunction screen:on_motion(x,y)\n\tif dragging then\n\t\tlocal actor = unpack(dragging)\n\t\tif (actor.name == \"grip\") then\n\t\t\tlocal actor,s_on_motion = unpack(dragging)\n\t\t\ts_on_motion(x, y)\n\t\t\treturn true\n\t\tend\n\t\treturn true\n\tend\nend\n-- END SCREEN ON_MOTION SECTION\n\n-- SCREEN ON_BUTTON_UP SECTION\nfunction screen:on_button_up()\n\tif dragging then\n\t\tdragging = nil\n\tend\nend\n-- END SCREEN ON_BUTTON_UP SECTION\n"

		global_section_footer_contents="-- GLOBAL SECTION FOOTER \nscreen:grab_key_focus()\nscreen:show()\nscreen.reactive = true\n\nui_element.screen_add(groups[\""..fileLower.."\"])\n\n-- SCREEN ON_KEY_DOWN SECTION\nfunction screen:on_key_down(key)\nend\n-- END SCREEN ON_KEY_DOWN SECTION\n"..screen_mouse_code.."\n-- END GLOBAL SECTION FOOTER \nend\n\ndolater( main )\n"

		editor_lb:writefile("main.lua", global_section_contents, true)
		new_contents = new_contents.."-- END "..fileUpper.." SECTION\n\n"
		editor_lb:writefile("main.lua", new_contents, false)
		editor_lb:writefile("main.lua", global_section_footer_contents, false)
	   end 
	   if app_exist == false then 
		local app_contents = "app=\n{\tid = \"com.trickplay.editor\",\n\trelease = \"1\",\n\tversion = \"1.0\",\n\tname = \"TrickPlay\",\n\tcopyright = \"Trickplay Inc.\"\n}"
		editor_lb:writefile("app", app_contents, true)
	   end 
	 
            current_fn = "screens/"..input_text
            if editor_lb:writefile(current_fn, contents, true) == false then 
				if save_current_file == false then 
					editor.error_message("019", current_dir) 
				end 
				screen:find_child("menu_text").text = screen:find_child("menu_text").extra.project
			else 

				local fa, fb = string.find(current_fn, "unsaved_temp") 
	   			if fa == nil then 
	   				screen:find_child("menu_text").text = screen:find_child("menu_text").extra.project .. "/" ..current_fn
	   			end 
			end 
            contents = ""
            --screen:grab_key_focus(screen) 
      end
      menu.menu_raise_to_top()

end -- end of msg_window.inputMsgWindow_savefile  

function msg_window.inputMsgWindow_openfile(input_text, ret)
    local dir = editor_lb:readdir(current_dir.."/screens")
	if dir == nil then dir = {} end 

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
			if current_fn ~= "screens/unsaved_temp.lua" then 
				editor.error_message("009", input_text, msg_window.inputMsgWindow_openfile)  
				return
			end
		elseif ret == "OK" then 
			-- restore
			bfc = readfile(back_fn)
			if bfc then 
				editor_lb:writefile("screens/unsaved_temp.lua", bfc, true)
				current_fn = "screens/unsaved_temp.lua"
			end 
			restore_fn = input_text
		end 

        local f = loadfile(current_fn)
        f(g) 

		if current_fn == "screens/unsaved_temp.lua" then 
			current_fn = ""
			editor_lb:writefile("screens/unsaved_temp.lua", "", true)
		else 
			local back_file = current_fn..".back"
			editor_lb:writefile(back_file, cfc, true)	
		end 

	   	if screen:find_child("timeline") then 
	      	for i,j in pairs (screen:find_child("timeline").children) do
	         	if j.name:find("pointer") then 
		    		j.extra.set = true
	         	end      
	      	end      
	   	end 

		if ret == "OK" then 
			if current_fn == "" then 
	   			screen:find_child("menu_text").text = screen:find_child("menu_text").text .. "/screens/" .. input_text
			end 
		else
	   		screen:find_child("menu_text").text = screen:find_child("menu_text").text .. "/screens/" .. input_text
		end
     end 

     if(g.extra.video ~= nil) then util.clear_bg() end 
     item_num = #g.children

     local x_scroll_from=0
     local x_scroll_to=0

     local y_scroll_from=0
     local y_scroll_to=0



	local function set_children (obj, reactive, lock, is_in_group)
     	obj.reactive = reactive
	  	obj.extra.lock = lock
		obj.extra.is_in_group = is_in_group
        util.create_on_button_down_f(obj)
	end 


	local function there (v, is_in_group)
	 	
		set_children(v,true,false,is_in_group,nil)	  

	  	if(v.type == "Text") then
			v.cursor_visible = false
			function v:on_key_down(key)
             		if key == keys.Return then
						v:set{cursor_visible = false}
						return true
	     			end 
			end 
	  	end 

		if(v.type == "Group") then 
		    if v.extra.type == "Group" then 
	       		for j, c in pairs (v.children) do
					if c.extra.type and c.extra.type == "Group" then 
						there(c,true)
					else 
						set_children(c,true,false,true)
					end 
	       		end 
		    end 

	       	if v.extra.type == "ScrollPane" or v.extra.type == "DialogBox" or v.extra.type == "ArrowPane" then 
		    	for j, c in pairs(v.content.children) do 
					if c.extra.type and c.extra.type == "Group" then 
						there(c,false)
					else
						set_children(c,true,false,true)
					end
		    	end 
	       	elseif v.extra.type == "TabBar" then 
		    	for j, c in pairs(v.tabs) do 
					for k, d in pairs (c.children) do
						if c.extra.type and c.extra.type == "Group" then 
							there(d,false)
						else
							set_children(d,true,false,true)
						end
					end 
		    	end 
	       	elseif v.extra.type == "LayoutManager" then 
		   		local f 
		   		f = function (k, c) 
     		    	if type(c) == "table" then
	 		   			--table.foreach(c, f)
                        for p, q in pairs(c) do
                            f(p, c[p])
                        end
     		    	elseif not c.extra.is_in_group then 
						if c.extra.type and c.extra.type == "Group" then 
							there(d,false)
						else
							set_children(c,true,false,true)
						end 
     		    	end 
		   		end 
		   		--table.foreach(v.cells, f)
                for p, q in pairs(v.cells) do
                    f(p, v.cells[p])
                end
	       end 
	  	end 
	end 

    for i, v in pairs(g.children) do
		there(v, false)
    end 

     menu.menu_raise_to_top()
end

function msg_window.inputMsgWindow_yn(txt)
     if(txt == "no") then
          editor.save(false)
     elseif(txt =="yes") then 
          if editor_lb:writefile(current_fn, contents, true) == false then 
			   print("yugi")
		  end 
          contents = ""
     end
     screen:grab_key_focus(screen) 
end

function msg_window.inputMsgWindow_openvideo(notused, parm_txt)
     
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
	 if dir == nil then dir = {} end 

     for i, v in pairs(dir) do
          if(input_text == v)then
               file_not_exists = false
          end
     end

     if (file_not_exists) then
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
	  
	  while (util.is_available("image"..tostring(item_num)) == false) do  
		item_num = item_num + 1
	  end 

          ui.image= Image{src = "/assets/images/"..input_text}
		  ui.image:set{ name="image"..tostring(item_num),opacity = 255 , position = {200,200}, extra = {org_x = 200, org_y = 200} }
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

     end 
end

return msg_window
