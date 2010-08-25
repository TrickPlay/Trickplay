CHANGE_VIEW_TIME = 100
math.randomseed(os.time())

FrontPageView = Class(View, function(view, model, ...)
    view._base.init(view, model)

    view.timer = Timer()
    view.timer.interval = 3

    view.ui = Group{name="front page ui"}
    screen:add(view.ui)

    local big_black_box = Rectangle
    {
        width = 1920,
        height = 1080,
        color = "000000",
        opacity = 0
    }
    view.ui:add(big_black_box)
    view.selector = Image
    {
        name = "frontpageselector",
        src = "assets/blackwhiteframe_overlay.png",
        opacity = 0--255
    }
    view.backdrop = Image
    {
        name = "backdrop",
        src = "assets/backdrop.png",
        opacity = 255
    }

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
    local prev_i = {1,1} 
    local controls = Image
    {
        src = "assets/buttons.png",
        name     = "controls",
        position = {-10, 45}
    }

    view.bottom_bar:add(sel_info, album_logo, album_title,controls)
    --model.album_group:add(view.selector)
    view.ui:add(model.album_group)

    grad = Image
    {
        src = "assets/gradient_mask.png",
        opacity = 0
    }
    screen:add(grad)

    local right_edge = Clone{source = grad}
    right_edge.scale = {.5,1080}
    right_edge.opacity = 255
    right_edge.x = 1750
    view.ui:add(right_edge)

    local left_edge = Clone{source = grad}
    left_edge.scale = {.5,1080}
    left_edge.opacity = 255
    left_edge.z_rotation = {180,0,0}
    left_edge.y = 1080
    left_edge.x = 1920-1750
    view.ui:add(left_edge)

    local sel_timeline = Timeline
    {
        name      = "Selection animation",
        loop      =  false,
        duration  =  3000,
        direction = "FORWARD",
    }

    view.previous   = nil
    view.current    = nil
    view.prev_pos   = {}
    view.prev_scale = {1,1}

    function sel_timeline.on_new_frame(t,msecs)
        local  sel       = {}
        sel[1],sel[2]    = view:get_controller():get_selected_index()
               sel[2]    = sel[2] + model.front_page_index  - 1
        -- shrink the previous
        if msecs <= 200  then
            local progress    =  msecs/200
			  dontswap = true		
            --cannot assume that image will have made it to its full expanded size
            local pos_delta   = {view.prev_pos[1] - view.prev_target_pos[1],
                                 view.prev_pos[2] - view.prev_target_pos[2]}
            local scale_delta = {view.prev_scale[1] - 1, view.prev_scale[2] - 1}

            view.previous.x     =  view.prev_pos[1]   - progress*pos_delta[1]
            view.previous.y     =  view.prev_pos[2]   - progress*pos_delta[2]
            view.previous.scale = 
            {
                view.prev_scale[1] - progress*scale_delta[1],
                view.prev_scale[2] - progress*scale_delta[2]
            }
        -- grow the next one
        elseif msecs > 200 and msecs <= 400 then
 
            --in case on_new_frame didn't get called on the 200th msec
            view.previous.position = {view.prev_target_pos[1],view.prev_target_pos[2]}
            view.previous.scale    = {1,1}
            prev_i={sel[1],sel[2]}

            local progress = (msecs - 200)/200

            view.current.x = PIC_W * (sel[2]-1) -  (.025*PIC_W)*progress
            view.current.y = PIC_H * (sel[1]-1) +  10 - progress*15
	         view.current.scale = {1 + progress*.05, 1 + progress * .05}
				
            view.backdrop.scale = {.845 + .1*progress,.845 + .1*progress}
            view.backdrop.opacity = 255--*progress
            view.backdrop.position={PIC_W * (sel[2]-1) -  (.025*PIC_W)-22*progress,
                         PIC_H * (sel[1]-1)-22*progress}
           dontswap = false

        elseif msecs > 400  and msecs <= 800 then
            --in case on_new_frame didn't get called on the 400th msec
            view.current.position = {PIC_W * (sel[2]-1) -  (.025*PIC_W),
                                     PIC_H * (sel[1]-1)-5}
            view.current.scale    = {1.05,1.05}

            view.backdrop.scale = {.945,.945}
            view.backdrop.position={PIC_W * (sel[2]-1) -  (.025*PIC_W)-22,
                         PIC_H * (sel[1]-1)-22}

        -- bring the bar up a little bit
        elseif msecs > 800  and msecs <= 900 then
            local progress = (msecs - 800)/100
            view.bottom_bar.opacity = 255
            view.bottom_bar.y = PIC_H - progress*70
        elseif msecs > 900 and msecs <= 2900 then
            view.bottom_bar.y = PIC_H - 70
        -- bring the bar up a little more
        elseif msecs > 2900 and msecs <= 3000 then
            local progress = (msecs - 2900)/100

            view.bottom_bar.y = PIC_H - progress*140
        end
    end

    function sel_timeline.on_completed()
        view.bottom_bar.y = PIC_H - 140
    end
    function view:initialize()
        self:set_controller(FrontPageController(self))
    end

    local prev_scale = {1,1}
 
    function view:shift_group(dir)

        left_edge:complete_animation()
        right_edge:complete_animation()

        local new_x
        if model.front_page_index == 1 then
            new_x = 10
            left_edge:animate{ duration = CHANGE_VIEW_TIME, opacity = 0}
            right_edge:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
        elseif model.front_page_index == math.ceil(#adapters / 
                     NUM_ROWS) - (NUM_VIS_COLS-1)               then
            new_x = -1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W) - 10
            left_edge:animate{ duration = CHANGE_VIEW_TIME, opacity = 255}
            right_edge:animate{duration = CHANGE_VIEW_TIME, opacity = 0}
        else
            new_x = -1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W)/2 
            left_edge:animate{ duration = CHANGE_VIEW_TIME, opacity = 255}
            right_edge:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
        end
        model.album_group:complete_animation()

        model.album_group:animate
        {
             duration = 2*CHANGE_VIEW_TIME,
             mode     = EASE_OUT_QUAD,
             x        = new_x
             --x = model.album_group.x - dir*(screen.width/(NUM_VIS_COLS+1))
        }

        --TODO include loader threshold here
        
    end

    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local  sel       = {}
        sel[1],sel[2]    = controller:get_selected_index()
               sel[2]    = sel[2] + model.front_page_index  - 1
        model.fp_index = {sel[1],sel[2]}
        model.fp_1D_index = (sel[2]-1)*NUM_ROWS + (sel[1])
        if comp == Components.FRONT_PAGE  then

            if model.album_group:find_child("bottom_bar") == nil then
                print("adding bottom bar")
                model.album_group:add(view.backdrop)
                model.fp_slots[model.fp_index[1]][model.fp_index[2]]:add(view.bottom_bar)
                view.timer:start()

            end

            view:shift_group()
            print("\n\nShowing FrontPageView UI\n")

            --view.ui:raise_to_top()
            view.ui.opacity = 255            
            big_black_box.opacity = 0

            print("new index is",sel[1],sel[2],"shift",
                                   model.front_page_index)
            print("previous index is",prev_i[1],prev_i[2])



            sel_timeline:stop()
            view.previous   =  model.fp_slots[prev_i[1]][prev_i[2]]
            view.prev_pos   = {view.previous.position[1],
                               view.previous.position[2]}
            view.prev_scale = {view.previous.scale[1],
                               view.previous.scale[2]}
            view.prev_target_pos = {PIC_W * (prev_i[2]-1),
                                    PIC_H * (prev_i[1]-1)+10}
            print(view.prev_pos[1],        view.prev_pos[2],"  ",
                  view.prev_target_pos[1], view.prev_target_pos[2],"  ",
                  view.previous.x,         view.previous.y)

            view.current    =  model.fp_slots[sel[1]][sel[2]]



            view.bottom_bar.opacity = 0
            view.bottom_bar:unparent()

            model.fp_slots[model.fp_index[1]][model.fp_index[2]]:add(view.bottom_bar)
            view.bottom_bar.position = {-10,PIC_H}
            view.bottom_bar.scale   = {1.1,1}

            album_title.text = string.gsub((adapters[#adapters - 
                                                 model.fp_1D_index + 1][1].required_inputs.query),
                                                                                      "%%20"," ")
            album_logo.src = adapters[#adapters - model.fp_1D_index + 1].logoUrl


            view.backdrop.opacity = 0
            view.backdrop:raise_to_top()
            view.current:raise_to_top()

            sel_timeline:start()
        elseif comp == Components.SOURCE_MANAGER then
            print("Dimming FrontPageView UI")
            view:shift_group()

            model.album_group:complete_animation()
            big_black_box:raise_to_top()
            big_black_box:animate{duration = 100,opacity = 150}

        else
            print("Hiding FrontPageView UI")
            model.album_group:complete_animation()
            big_black_box.opacity = 0
            view.ui.opacity = 0
        end
    end

function view.timer.on_timer(timer)
	print("random insert, locked = ",model.swapping_cover)
            if model.swapping_cover == false then
                local rand_i = {
                    math.random(1,NUM_ROWS),
                    math.random(1,NUM_VIS_COLS) + 
                         model.front_page_index  - 1
                }

                local formula = (rand_i[2]-1)*NUM_ROWS + (rand_i[1])
					
                if (rand_i[1] ~= model.fp_index[1] or
                    rand_i[2] ~= model.fp_index[2]) and 
                    adapters[formula]~=nil then
                    if (not dontswap) then
                   	
                    print("calling")
                    model.swapping_cover = true

                    local search_i = math.random(1,10)
                    --print("formula?",rand_i[1],rand_i[2],formula)
                     loadCovers(formula, searches[#adapters+1-formula], search_i)
                    end
                else
                    print("not calling")
                end
            end

end

function view:Delete_Cover(index)
    model.swapping_cover = false
    print("Delete_Cover( "..index.." )")
    if #adapters ~= 1 then
    local keys = view:get_controller().on_key_down 
    view:get_controller().on_key_down = function() end
    local del_timeline = Timeline
    {
        name      = "Deletion animation",
        loop      =  false,
        duration  =  200,
        direction = "FORWARD",
    }
    function del_timeline.on_started()
        print("started")
    end
    function del_timeline.on_new_frame(t,msecs)
        print("on new frame")
        local progress = msecs/t.duration
	    dontswap = true

        if model.albums[(index-1)%NUM_ROWS +1]
                       [math.ceil(index/NUM_ROWS)] ~= nil then 
            model.albums[(index-1)%NUM_ROWS +1]
                        [math.ceil(index/NUM_ROWS)].opacity = 
                                                (1-progress)*255
        elseif model.placeholders[(index-1)%NUM_ROWS +1]
                                 [math.ceil(index/NUM_ROWS)] ~= nil then
            model.placeholders[(index-1)%NUM_ROWS +1]
                              [math.ceil(index/NUM_ROWS)].opacity = 
                                                 (1-progress)*255
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
        local i = (index-1)%NUM_ROWS +1
        local j = math.ceil(index/NUM_ROWS)
        --print("DEL on completed",index,",",i,j,",",model.albums[i][j],model.placeholders[i][j])

        if  model.albums[i] ~= nil and model.albums[i][j] ~= nil then
            model.albums[i][j]:unparent()
            model.albums[i][j] = nil
        elseif  model.placeholders[i]~= nil and 
                model.placeholders[i][j] ~= nil and 
                model.placeholders[i][j] ~= 0   then
            model.placeholders[i][j].opacity = 0
            model.placeholders[i][j]:unparent()
            model.placeholders[i][j] = nil
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
                
                model.albums[targ_i][targ_j] = model.albums[curr_i][curr_j]
            else
                model.fp_slots[targ_i][targ_j] = nil
                model.albums[targ_i][targ_j] = nil
            end
        end
        if model.front_page_index == math.ceil(#adapters / 
                              NUM_ROWS) - (NUM_VIS_COLS-1) and
                              model.front_page_index ~= 1  and 
                            ((#adapters-1)%NUM_ROWS) == 0  then
            model.front_page_index = model.front_page_index - 1
        end
        --print("\n\n",index,#adapters)
        if index  == #adapters then
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
        model:notify()
        view:get_controller().on_key_down = keys
         dontswap = false


    end
    del_timeline:start()
    end
end

end)

function Add_Cover()
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
--[[
        model.fp_slots[(index-1)%NUM_ROWS +1]
                      [math.ceil(index/NUM_ROWS)] = nil
        model.albums[(index-1)%NUM_ROWS +1]
                    [math.ceil(index/NUM_ROWS)]:unparent()
        model.albums[(index-1)%NUM_ROWS +1]
                    [math.ceil(index/NUM_ROWS)] = nil
--]]
        for ind = #adapters,1,-1 do
            local targ_i = (ind+1-1)%NUM_ROWS +1
            local targ_j = math.ceil((ind+1)/NUM_ROWS)

            local curr_i = (ind-1)%NUM_ROWS +1
            local curr_j = math.ceil((ind)/NUM_ROWS)

            if  model.fp_slots[curr_i]        ~= nil and
                model.fp_slots[curr_i][curr_j] ~= nil then

                --model.fp_slots[new_i][new_j]:raise_to_top()
                model.fp_slots[curr_i][curr_j].position =
                {
                    PIC_W*(targ_j-1) ,
                    PIC_H*(targ_i-1) + 10
                }
                --an edge case if there's only one picture
                if model.fp_slots[targ_i] == nil then
                    model.fp_slots[targ_i] = {}
                end
                if model.albums[targ_i] == nil then
                    model.albums[targ_i] = {}
                end

                model.fp_slots[targ_i][targ_j] =
                     model.fp_slots[curr_i][curr_j]
                model.albums[targ_i][targ_j] = model.albums[curr_i][curr_j]
                model.placeholders[targ_i][targ_j] = model.placeholders[curr_i][curr_j]
                model.fp_slots[curr_i][curr_j]     = nil
                model.albums[curr_i][curr_j]       = nil
                model.placeholders[curr_i][curr_i] = nil
--[[
            else
                model.fp_slots[targ_i][targ_j] = nil
                 model.albums[targ_i][targ_j] = nil
--]]
            end
        end
        model.albums[1][1]   = nil
        model.fp_slots[1][1] = Group
        {
            --name     = "Slot "..i.." "..j, 
            position = { 0, 10 },
            clip     = { 0, 0,  PIC_W, PIC_H },
            opacity  = 255
        }
        model.placeholders[1][1] = Clone
        {
            source = model.default[math.random(1,8)],
            opacity =255
        }
        model.fp_slots[1][1]:add(model.placeholders[1][1])
        model.album_group:add(model.fp_slots[1][1])
        loadCovers(1,searches[#adapters], math.random(5)) 

--[[
        if model.front_page_index == math.ceil(#adapters / 
                              NUM_ROWS) - (NUM_VIS_COLS-1) and
                              model.front_page_index ~= 1  and 
                            ((#adapters-1)%NUM_ROWS) == 0  then
            model.front_page_index = model.front_page_index - 1
        end
        print("\n\n",index,#adapters)
        if index  == #adapters then
            local i = ((index-1)-1)%NUM_ROWS +1
            local j = math.ceil((index-1)/NUM_ROWS)
            print("setting to",i,j - 
                                    ( model.front_page_index  - 1 ))
            view:get_controller():set_selected_index(i,j - 
                                    ( model.front_page_index  - 1 ))
            prev_i = {i,j -( model.front_page_index  - 1 )}
        end
--]]
        --deleteAdapter(index)
        model:notify()
    end
    add_timeline:start()
end

