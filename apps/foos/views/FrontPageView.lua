CHANGE_VIEW_TIME = 100
math.randomseed(os.time())

FrontPageView = Class(View, function(view, model, ...)
    view._base.init(view, model)

    --timer that pings an random cover to change
    view.timer = Timer()
    view.timer.interval = 3000

    view.ui = Group{name="front page ui"}
    screen:add(view.ui)

    --black box used to gray-out the the covers
    local big_black_box = Rectangle
    {
        width   = 1920,
        height  = 1080,
        color   = "000000",
        opacity = 0
    }
    view.ui:add(big_black_box)
--[[
    view.selector = Image
    {
        name = "frontpageselector",
        src = "assets/blackwhiteframe_overlay.png",
        opacity = 0--255
    }
--]]
    view.backdrop = Image
    {
        name = "backdrop",
        src = "assets/backdrop.png",
        opacity = 255
    }
--]]

    --the bottom bar that appears over the selected album cover
--[[
    view.bottom_bar = Group{name="bottom_bar"}
    local sel_info = Image
    {
        name     = "pic_info",
        src      = "assets/bottom_bar.png",
        scale    = {1.1,1},
        position = {-10,0},
    }
    local album_logo = Image
    {
        name = "pic_logo",
        src  = "",
        position = {-40,-75},
        size = {300, 225}
    }
                                                                              
    local album_title = Text
    {
        name     = "pic_text",
        text     = "",
        color    = "FFFFFF",
        font     = "Sans 32px",
        position = {240, 10}
    }
    local controls = Image
    {
        src = "assets/buttons.png",
        name     = "controls",
        position = {-10, 45}
    }
    view.bottom_bar:add(sel_info, album_logo, album_title,controls)
--]]

    --gradients for the half-visible albums


    --add the album covers to the ui
    view.ui:add(model.album_group)

    --state info for the selection animation
    local prev_i = {1,1}
    view.previous   = nil
    view.current    = nil
    view.prev_pos   = {}
    view.prev_scale = {1,1}

	fp_selector = Group{name="selector"}
	local selectorImg = Image {name="img",src = "assets/poloroid.png" }
	local selector_title = Text{name="title",font = "DejaVu Sans condensed 22px",
			y = 585,color = "000000",text = "", opacity=125, x=30,ellipsize="END",alignment="RIGHT",w=PIC_W,clip={0,0,540,50}}
	local selector_auth = Text{name="auth", opacity=125,font = "DejaVu Sans condensed 22px",
			y = 610,color = "000000",text = "",alignment="RIGHT",w=PIC_W,x=30,clip={0,0,540,50},ellipsize="END"}

	fp_selector:add(selectorImg,selector_title,selector_auth)
	view.ui:add(fp_selector)
	function view:move_selector(moving)
	    local sel_timeline = Timeline
		{
        	name      = "Selection animation",
	        loop      =  false,
			--duration  =  3000,
        	duration  = 300,
	        direction = "FORWARD",
    	}
		local license
        local  sel        = {}
        sel[1],sel[2]     = view:get_controller():get_selected_index()

		local curr_old_x  = view.current.x
		local curr_targ_x = view.current.x
		local prev_old_x  = view.previous.x
		local prev_targ_x = PIC_W * (prev_i[2]-1) 

		local old_x    = fp_selector.x
		local old_y    = fp_selector.y
---[[
		if     sel[2] + model.front_page_index -1 == 1 then
			curr_targ_x = 35
		elseif sel[2] == NUM_VIS_COLS and 
				model.front_page_index == math.ceil(#sources / 
                     NUM_ROWS) - (NUM_VIS_COLS-1) then
			curr_targ_x = curr_targ_x - 30

		end
--]]
		local target_y = view.current.y
		if     sel[1] == 1        then target_y = 0
		elseif sel[1] == NUM_ROWS then target_y = PIC_H -110
		end

		selector_title.text = view.current.extra.lic_tit
		selector_auth.text = view.current.extra.lic_auth
		if 540 > selector_title.w then
			selector_title.x = selectorImg.w-selector_title.w-50
		else
			selector_title.x = 30
		end
		if 540 > selector_auth.w then
			selector_auth.x = selectorImg.w-selector_auth.w-50
		else
			selector_auth.x=30
		end
		local prev_old_y  = view.previous.y
		local prev_targ_y = PIC_H * (prev_i[1]-1)

		local curr_old_y = view.current.y
		local curr_targ_y = view.current.y
		if     sel[1] == 1        then curr_targ_y = 40
		elseif sel[1] == NUM_ROWS then curr_targ_y = PIC_H -75
		end

	    function sel_timeline.on_new_frame(t,_,p)
			--local target_x = model.album_group.x + view.current.x - 35
local target_x = model.album_group.x + view.current.x - 35
			--move the selector
			fp_selector.x = old_x + (target_x - old_x)*p
			fp_selector.y = old_y + (target_y - old_y)*p

			--move old slot back to its position
			view.previous.y = prev_old_y + (prev_targ_y - prev_old_y)*p
			view.previous.x = prev_old_x + (prev_targ_x - prev_old_x)*p

			--move the next slot up (if on the bottom row) 
			-- or down (if on the top row)
			view.current.y = curr_old_y + (curr_targ_y - curr_old_y)*p
			view.current.x = curr_old_x + (curr_targ_x - curr_old_x)*p
	         --view.current.scale = {1 + p*.05, 1 + p * .05}
	         --view.previous.scale = {1 + (1-p)*.05, 1 + (1-p) * .05}

		end
	    function sel_timeline.on_completed()
			local target_x = model.album_group.x + view.current.x - 35
	        --view.previous.scale = {1, 1 }

	        --view.current.scale = {1.05, 1.05}
			view.previous.y = prev_targ_y
			view.previous.x = prev_targ_x

			view.current.y = curr_targ_y
			view.current.x = curr_targ_x
			fp_selector.x = target_x
			fp_selector.y = target_y
			prev_i[1] = sel[1]
			prev_i[2] = sel[2] + model.front_page_index-1
reset_keys()
--print("done",selector.x,selector.y,sel[1],sel[2])
		end
		sel_timeline:start()
	end


    function view:initialize()
        self:set_controller(FrontPageController(self))
    end

    local prev_scale = {1,1}
    function view:shift_group(dir)


        local new_x
        if model.front_page_index == 1 then
            new_x = 0--10
        elseif model.front_page_index == math.ceil(#sources / 
                     NUM_ROWS) - (NUM_VIS_COLS-1)               then
            new_x = -1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W)-- - 10
        else
            new_x = -1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W)/2 
        end
        model.album_group:complete_animation()

        model.album_group:animate
        {
            duration = 2*CHANGE_VIEW_TIME,
            mode     = EASE_OUT_QUAD,
            x        = new_x,
            on_completed = function()
            --    reset_keys()
            end
        }

        --TODO include loader threshold here
        
    end
 local fucking_stupid = true
view.timer:start()
    function view:update()
        local controller  = view:get_controller()
        local comp        = model:get_active_component()
        local  sel        = {}
        sel[1],sel[2]     = controller:get_selected_index()
               sel[2]     = sel[2] + model.front_page_index  - 1
        model.fp_index    = { sel[1], sel[2] }
        model.fp_1D_index = ( sel[2]-1 ) * NUM_ROWS + ( sel[1] )
        if comp == Components.FRONT_PAGE  then

            --an if that is entered every time the view switches back
   --         if model.album_group:find_child("bottom_bar") == nil then
   --             print("adding bottom bar")
                --model.album_group:add(view.backdrop)
                --model.fp_slots[model.fp_index[1]][model.fp_index[2]]:add(view.bottom_bar)
    --            view.timer:start()
    --        end
--stupid edge case for the very beginning
if fucking_stupid then
	 
	model.album_group.x=0--10
else
            view:shift_group()
end
  --          print("\n\nShowing FrontPageView UI\n")

            --view.ui:raise_to_top()
            view.ui.opacity = 255            
            big_black_box.opacity = 0
--
  --          print("new index is",sel[1],sel[2],"shift",
      --                             model.front_page_index)
    --        print("previous index is",prev_i[1],prev_i[2])



            --sel_timeline:stop()
            view.previous   =  model.fp_slots[prev_i[1]][prev_i[2]]
            view.prev_pos   = {view.previous.position[1],
                               view.previous.position[2]}
            view.prev_scale = {view.previous.scale[1],
                               view.previous.scale[2]}
            view.prev_target_pos = {PIC_W * (prev_i[2]-1),
                                    PIC_H * (prev_i[1]-1)+10}
--            print(view.prev_pos[1],        view.prev_pos[2]        ,"   ",
  --                view.prev_target_pos[1], view.prev_target_pos[2] ,"   ",
    --              view.previous.x,         view.previous.y)

            view.current    =  model.fp_slots[sel[1]][sel[2]]



            --view.bottom_bar.opacity = 0
            --view.bottom_bar:unparent()

            --model.fp_slots[model.fp_index[1]][model.fp_index[2]]:add(view.bottom_bar)
            --view.bottom_bar.position = {-10,PIC_H}
            --view.bottom_bar.scale   = {1.1,1}
--				print (#adapters - model.fp_1D_index + 1,adapters[#adapters - model.fp_1D_index + 1].hasImages)
--				debug()
--[[
				if (adapters[#adapters - model.fp_1D_index + 1].hasImages) then
	         album_title.text = string.gsub((adapters[#adapters - model.fp_1D_index + 1][1].required_inputs.query),"%%20"," ")
	         else
	         	album_title.text = "NO IMAGES"
	         end

            album_logo.src = adapters[#adapters - model.fp_1D_index + 1].logoUrl
--]]

            --view.backdrop.opacity = 0
            --view.backdrop:raise_to_top()
            view.current:raise_to_top()
			if prev_i[1] ~= sel[1] or prev_i[2] ~= sel[2] or fucking_stupid then
				fucking_stupid = false
				view.move_selector()
			end
            --sel_timeline:start()
        elseif comp == Components.SOURCE_MANAGER then
      --      print("Dimming FrontPageView UI")
            view:shift_group()

            model.album_group:complete_animation()
            big_black_box:raise_to_top()
            big_black_box:animate{duration = 100,opacity = 150}

        else
        --    print("Hiding FrontPageView UI")
            model.album_group:complete_animation()
            big_black_box.opacity = 0
            view.ui.opacity = 0
        end
    end

function view.timer:on_timer()
	print("random_insert(), locked = ",model.swapping_cover)
            if model.swapping_cover == false then
                local rand_i = {
                    math.random(1,NUM_ROWS),
                    math.random(1,NUM_VIS_COLS) + 
                         model.front_page_index  - 1
                }

                local formula = (rand_i[2]-1)*NUM_ROWS + (rand_i[1])
		if sources[formula] ~= nil then			
                --if adapters[#adapters+1-formula]~=nil then
                   	
                    print("\tcalling")
                    model.swapping_cover = true

                    --print("formula?",rand_i[1],rand_i[2],formula)
--[[
                     adapters[#adapters+1-formula]:loadCovers(

                                model.fp_slots[rand_i[1] ][rand_i[2] ], 
                                searches[#adapters+1-formula], 
                                math.random(1,10),
				#adapters+1-formula
                     )
--]]
local rand_photo = math.random(1,50)
local foto,lic_tit, lic_auth
				foto,lic_tit, lic_auth = sources[formula]:get_photos_at(rand_photo,true)
				if lic_tit == model.fp_slots[rand_i[1] ][rand_i[2] ].extra.lic_tit then
					foto,lic_tit, lic_auth = sources[formula]:get_photos_at(rand_photo+1,true)
	end
                    LoadImg(foto,model.fp_slots[rand_i[1] ][rand_i[2] ],lic_tit,lic_auth,rand_photo)
                else
                    print("not calling")
                end
            end

end
--[=[
function view:Delete_Cover(index)
    model.swapping_cover = false
    print("Delete_Cover( "..index.." )")
    --if #adapters ~= 1 then
    --local keys = view:get_controller().on_key_down 
    --view:get_controller().on_key_down = function() end
    local del_timeline = Timeline
    {
        name      = "Deletion animation",
        loop      =  false,
        duration  =  200,
        direction = "FORWARD",
    }
    function del_timeline.on_started()
        print("del on started")
    end
    function del_timeline.on_new_frame(t,msecs)
        print("del on new frame")
        local progress = msecs/t.duration
	    --dontswap = true
--[[
        if model.albums[(index-1)%NUM_ROWS +1]
                       [math.ceil(index/NUM_ROWS)] ~= nil then 
            model.albums[(index-1)%NUM_ROWS +1]
                        [math.ceil(index/NUM_ROWS)].opacity = 
                                                (1-progress)*255
        end
        if model.placeholders[(index-1)%NUM_ROWS +1]
                                 [math.ceil(index/NUM_ROWS)] ~= nil then
            model.placeholders[(index-1)%NUM_ROWS +1]
                              [math.ceil(index/NUM_ROWS)].opacity = 
                                                 (1-progress)*255
        end
--]]
        local cover = model.fp_slots[(index-1)%NUM_ROWS +1]
                       [math.ceil(index/NUM_ROWS)]:find_child("cover")
        
        local placeholder = model.fp_slots[(index-1)%NUM_ROWS +1]
                       [math.ceil(index/NUM_ROWS)]:find_child("placeholder")
        if cover ~= nil then 
            cover.opacity = (1-progress)*255
        end
        if placeholder ~= nil then
           placeholder.opacity = (1-progress)*255
        end

        for ind = index, #adapters do
            local targ_i = (ind-1)%NUM_ROWS +1
            local targ_j = math.ceil(ind/NUM_ROWS)

            local curr_i = (ind+1-1)%NUM_ROWS +1
            local curr_j = math.ceil((ind+1)/NUM_ROWS)

            if model.fp_slots[curr_i]        ~= nil and
               model.fp_slots[curr_i][curr_j] ~= nil then
                --model.fp_slots[new_i][new_j]:raise_to_top()
                model.fp_slots[curr_i][curr_j].position =
                {
                    PIC_W*(curr_j-1) + progress * ((PIC_W*(targ_j-1)) -
                                                   (PIC_W*(curr_j-1))),
                    PIC_H*(curr_i-1)+10 + progress * ((PIC_H*(targ_i-1)) -
                                                      (PIC_H*(curr_i-1)))
                }
            end
        end
        if model.front_page_index == math.ceil(#adapters / 
                              NUM_ROWS) - (NUM_VIS_COLS-1) and
           model.front_page_index ~= 1 and ((#adapters-1)%NUM_ROWS) == 0 then

            --stupid edge case
            if model.front_page_index == 2 then
                model.album_group.x = (1-progress)*(-1*
                             (model.front_page_index-1) * PIC_W + 
                             (screen.width - NUM_VIS_COLS*PIC_W)) 
                              - 10 + progress*10
            else
                model.album_group.x = -1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W) - 10 + progress*PIC_W
            end
        end
    end
    function del_timeline.on_completed()
        print("del on completed")
        local i = (index-1)%NUM_ROWS +1
        local j = math.ceil(index/NUM_ROWS)
        --print("DEL on completed",index,",",i,j,",",model.albums[i][j],model.placeholders[i][j])

        if  model.fp_slots[i][j]:find_child("cover") ~= nil then
            model.fp_slots[i][j]:remove("cover")
        end
        if  model.fp_slots[i][j]:find_child("placeholder") ~= nil then
            model.fp_slots[i][j]:remove("placeholder")
        end
        model.fp_slots[i][j] = nil

        for ind = index, #adapters do
            local targ_i = (ind-1)%NUM_ROWS +1
            local targ_j = math.ceil(ind/NUM_ROWS)

            local curr_i = (ind+1-1)%NUM_ROWS +1
            local curr_j = math.ceil((ind+1)/NUM_ROWS)

            if  model.fp_slots[curr_i]        ~= nil and
                model.fp_slots[curr_i][curr_j] ~= nil then

                --model.fp_slots[new_i][new_j]:raise_to_top()
                model.fp_slots[curr_i][curr_j].position =
                {
                    PIC_W*(targ_j-1) ,
                    PIC_H*(targ_i-1) + 10
                }
                model.fp_slots[targ_i][targ_j] =
                     model.fp_slots[curr_i][curr_j]
                
                --model.albums[targ_i][targ_j] = model.albums[curr_i][curr_j]
            else
                model.fp_slots[targ_i][targ_j] = nil
                --model.albums[targ_i][targ_j] = nil
            end
        end
        if model.front_page_index == math.ceil(#adapters / 
                              NUM_ROWS) - (NUM_VIS_COLS-1) and
                              model.front_page_index ~= 1  and 
                            ((#adapters-1)%NUM_ROWS) == 0  then
            model.front_page_index = model.front_page_index - 1
        end
        --print("\n\n",index,#adapters)
        if index  == #adapters and index ~= 1 then
            local ii = (index-1-1)%NUM_ROWS +1
            local jj = math.ceil((index-1)/NUM_ROWS)

            print("setting to",ii,jj - 
                                    ( model.front_page_index  - 1 ))
            view:get_controller():set_selected_index(ii,jj - 
                                    ( model.front_page_index  - 1 ))
            prev_i = {ii,jj -( model.front_page_index  - 1 )}
        end
--[[
        for ind=index,#adapters do
            local i = (ind-1)%NUM_ROWS +1
            local j = math.ceil(ind/NUM_ROWS)
            if model.albums[a]           ~= nil  and
               model.albums[i][j]        ~= nil  and
               model.albums[i][j].loaded ~= true then
                model.albums[i][j] = nil
                model.placeholders[i][j] = Clone
                {
                    source = model.default[math.random(1,8)],
                    opacity =255
                }
                model.fp_slots[i][j]:add(model.placeholders[i][j])
                model.album_group:add(model.fp_slots[i][j])
                loadCovers(ind,searches[#adapters], math.random(5))
            end
        end
--]]


        deleteAdapter(index)
        -- ... fuckin race conditions
        --print("hacked")
        --local hack = model.keep_keys
       -- model.keep_keys = function() end
        model:notify()
        --model.keep_keys = hack
        --print("unhacked")
        --view:get_controller().on_key_down = keys
        -- dontswap = false
        --reset_keys()            


    end
    del_timeline:start()
    --end
end
--]=]
end)
--[=[
function Add_Cover()
    model.swapping_cover = false

    local add_timeline = Timeline
    {
        name      = "Adding animation",
        loop      =  false,
        duration  =  200,
        direction = "FORWARD",
    }


    function add_timeline.on_new_frame(t,msecs)
        print("on neww frame")
        local progress = msecs/t.duration
--[[
        model.albums[(index-1)%NUM_ROWS +1]
                    [math.ceil(index/NUM_ROWS)].opacity = (1-progress)*255
--]]
        for ind = 1, #adapters do
            local targ_i = (ind+1-1)%NUM_ROWS +1
            local targ_j = math.ceil((ind+1)/NUM_ROWS)

            local curr_i = (ind-1)%NUM_ROWS +1
            local curr_j = math.ceil((ind)/NUM_ROWS)

            if model.fp_slots[curr_i]        ~= nil and
               model.fp_slots[curr_i][curr_j] ~= nil then
                --model.fp_slots[new_i][new_j]:raise_to_top()
                model.fp_slots[curr_i][curr_j].position =
                {
                    PIC_W*(curr_j-1) + progress * ((PIC_W*(targ_j-1)) -
                                                   (PIC_W*(curr_j-1))),
                    PIC_H*(curr_i-1)+10 + progress * ((PIC_H*(targ_i-1)) -
                                                      (PIC_H*(curr_i-1)))
                }
            end
        end
--[[
        if model.front_page_index == math.ceil(#adapters / 
                              NUM_ROWS) - (NUM_VIS_COLS-1) and
           model.front_page_index ~= 1 and ((#adapters-1)%NUM_ROWS) == 0 then

            --stupid edge case
            if model.front_page_index == 2 then
                model.album_group.x = (1-progress)*(-1*
                             (model.front_page_index-1) * PIC_W + 
                             (screen.width - NUM_VIS_COLS*PIC_W)) 
                              - 10 + progress*10
            else
                model.album_group.x = -1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W) - 10 + progress*PIC_W
            end
        end
--]]
    end
    function add_timeline.on_completed()

        for ind = #adapters,1,-1 do
            local targ_i = (ind+1-1)%NUM_ROWS +1
            local targ_j = math.ceil((ind+1)/NUM_ROWS)

            local curr_i = (ind-1)%NUM_ROWS +1
            local curr_j = math.ceil((ind)/NUM_ROWS)

            if  model.fp_slots[curr_i]        ~= nil and
                model.fp_slots[curr_i][curr_j] ~= nil then

                model.fp_slots[curr_i][curr_j].position =
                {
                    PIC_W*(targ_j-1) ,
                    PIC_H*(targ_i-1) + 10
                }
                --an edge case if there's only one picture
                if model.fp_slots[targ_i] == nil then
                    model.fp_slots[targ_i] = {}
                end
                model.fp_slots[targ_i][targ_j] = model.fp_slots[curr_i][curr_j]
                model.fp_slots[curr_i][curr_j]     = nil
            end
        end
        model.fp_slots[1][1] = Group
        {
            position = { 0, 10 },
            clip     = { 0, 0,  PIC_W, PIC_H },
            opacity  = 255
        }
        model.fp_slots[1][1]:add(Clone
        {
            name   = "placeholder",
            source = model.default[math.random(1,8)],
            opacity =255
        })
        model.album_group:add(model.fp_slots[1][1])
        adapters[#adapters]:loadCovers(model.fp_slots[1][1],
searches[#adapters]                       , 
                                               math.random(5),#adapters) 

        model:notify()
        --dont need to give keys back here, they are given 
        --back in the leave accordian animation
    end
    add_timeline:start()
end
--]=]
