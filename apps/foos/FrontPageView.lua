CHANGE_VIEW_TIME = 100
math.randomseed(os.time())

FrontPageView = Class(View, function(view, model, ...)
    view._base.init(view, model)

    view.timer = Timer()
    view.timer.interval = 3

    view.ui = Group{name="front page ui"}
    screen:add(view.ui)

    view.selector = Image
    {
        name = "frontpageselector",
        src = "assets/blackwhiteframe_overlay.png",
        opacity = 0--255
    }
    view.sel_info = Image
    {
        name = "pic_info",
        src = "assets/overlay_infobar.png",
        opacity = 0
    }
    view.backdrop = Image
    {
        name = "pic_info",
        src = "assets/backdrop.png",
        opacity = 0
    }


    --model.album_group:add(view.selector)
    view.ui:add(model.album_group)

    grad = Image
    {
        src = "assets/gradient_mask.png",
        opacity = 0
    }
    screen:add(grad)

    local right_edge = Clone{source = grad}
    right_edge.scale = {1,1080}
    right_edge.opacity = 255
    right_edge.x = 1550
    view.ui:add(right_edge)

    local left_edge = Clone{source = grad}
    left_edge.scale = {1,1080}
    left_edge.opacity = 255
    left_edge.z_rotation = {180,0,0}
    left_edge.y = 1080
    left_edge.x = 1920-1550
    view.ui:add(left_edge)


    function view:initialize()
        self:set_controller(FrontPageController(self))
    end

    local prev_scale = {1,1}
 
    function view:shift_group(dir)
--[[
        local next_spot = model.front_page_index + dir
        local upper_bound = math.ceil(model.num_sources / NUM_ROWS) -
                                     (NUM_VIS_COLS-1)
        if next_spot > 0 and next_spot <= upper_bound then
            model.front_page_index = next_spot
        end
--]]
        left_edge:complete_animation()
        right_edge:complete_animation()
        local new_x
        if model.front_page_index == 1 then
            new_x = 0
            left_edge:animate{ duration = CHANGE_VIEW_TIME, opacity = 0}
            right_edge:animate{duration = CHANGE_VIEW_TIME, opacity = 255}
        elseif model.front_page_index == math.ceil(model.num_sources / 
                     NUM_ROWS) - (NUM_VIS_COLS-1)               then
            new_x = -1*(model.front_page_index-1) * PIC_W + 
                       (screen.width - NUM_VIS_COLS*PIC_W)
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

    local prev_i = {1,1} 
           
    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local  sel       = {}
        sel[1],sel[2]    = controller:get_selected_index()
               sel[2]    = sel[2] + model.front_page_index  - 1
        model.fp_index = {sel[1],sel[2]}
        if comp == Components.FRONT_PAGE  then

            view:shift_group()
            print("\n\nShowing FrontPageView UI\n")

            view.ui:raise_to_top()
            view.ui.opacity = 255            

            print("new index is",sel[1],sel[2],"shift",
                                   model.front_page_index)
            print("previous index is",prev_i[1],prev_i[2])


            local prev_index = model.front_page_index*2 + (prev_i[1]-1)
            local sel_index  = model.front_page_index*2 + (sel[1]-1)


            local new_r = PIC_H * (sel[1]-1)
---[[
            if sel[1] == 1 then
                new_r = 0
            elseif sel[1] == NUM_ROWS then
                  new_r = new_r * .9
--                new_r = .9*screen.height * (sel[1]-1) / NUM_ROWS
            else
                  new_r = new_r * .95
--                new_r = .95*screen.height * (sel[1]-1) / NUM_ROWS
            end
--]]
            local new_c = PIC_W * (sel[2]-1) - .05*PIC_W 

--[[
            local new_c = screen.width  * (sel[2]-1) / 
                             (NUM_VIS_COLS + 1)
--]]


            local previous
            local current
            local prev_bs
            local curr_bs
---[=[
            if model.albums[prev_i[1]] == nil or 
               model.albums[prev_i[1]][prev_i[2]] == nil then

                previous = model.placeholders[prev_i[1]][prev_i[2]]
                prev_bs = {
                    model.def_bs[1],model.def_bs[2]
                }
            else
                previous = model.albums[prev_i[1]][prev_i[2]]
                prev_bs = {
                    model.albums[prev_i[1]][prev_i[2]].base_size[1],
                    model.albums[prev_i[1]][prev_i[2]].base_size[2]
                }
            end
--]=]
---[=[
            if model.albums[sel[1]] == nil or 
               model.albums[sel[1]][sel[2]] == nil then
               print("going to placeholder",sel[1],sel[2])
                current = model.placeholders[sel[1]][sel[2]]
--]=]
---[=[
                curr_bs =  {
                   model.def_bs[1],model.def_bs[2]
                }
--]=]
            else
                current = model.albums[sel[1]][sel[2]]
---[=[
                curr_bs = {
                    model.albums[sel[1]][sel[2]].base_size[1],
                    model.albums[sel[1]][sel[2]].base_size[2]
                }
--]=]
            end
---[[
            print(prev_bs[1],prev_bs[2],curr_bs[1],curr_bs[2])

assert(previous ~= nil,"wth")
                previous:complete_animation()
            previous:animate{
                duration = CHANGE_VIEW_TIME,
                scale    = { PIC_W / prev_bs[1], PIC_H / prev_bs[2] },
                position = { PIC_W * (prev_i[2]-1),PIC_H * (prev_i[1]-1)},
                on_completed = function()
                    prev_i = {sel[1],sel[2]}
                    print("completed to placeholder:",sel[1],sel[2])
                    --if current:complete_animation ~= nil then
                        current:complete_animation()
                    current:raise_to_top()
                    --end
--]]
--[[
                    view.selector:complete_animation()
                    view.selector.position={new_c-55,new_r-55}
                    view.selector:animate{
                        duration = 2*CHANGE_VIEW_TIME,
                        --scale = {1.05,1.15},
                        opacity = 255
                    }
                    --current:raise_to_top()

                    view.selector:raise_to_top()
--]]
---[[
                    current:animate{
                        duration = CHANGE_VIEW_TIME,
                        position = {new_c,new_r},
                        scale  = {SEL_W / curr_bs[1],SEL_H /curr_bs[2]}
                    }



                end
            }
--]]


--[==[
            view.sel_info:complete_animation()
            view.sel_info.opacity = 0
            view.sel_info.scale   = {1,1}
            view.sel_info.position = {new_c,new_r+PIC_H}

            view.selector:raise_to_top()
            view.selector:complete_animation()
            view.selector:animate{
                 duration = 2*CHANGE_VIEW_TIME,
                 mode = EASE_OUT_BOUNCE,
                 position = {new_c-55,new_r-55},
                 --opacity  = 0
                 on_completed=function()
                     if model.albums[sel[1]] ~= nil and 
                        model.albums[sel[1]][sel[2]] ~= nil and
                        (view.sel_info.x/PIC_W) + 1 == sel[2] and
                        (view.sel_info.y/PIC_H) == sel[1] then

                     --view.sel_info.position = {new_c,new_r+PIC_H}
                    view.selector:raise_to_top()

                     view.sel_info:animate{
                         duration = 10*CHANGE_VIEW_TIME,
                         opacity  = 255,
                         on_completed = function()
                     if model.albums[sel[1]] ~= nil and 
                        model.albums[sel[1]][sel[2]] ~= nil and
                        (view.sel_info.x/PIC_W) + 1 == sel[2] and
                        (view.sel_info.y/PIC_H) == sel[1] then

                    view.selector:raise_to_top()

                             view.sel_info:animate{
                                 duration = 2*CHANGE_VIEW_TIME,
                                 y = view.sel_info.y - 100,
                                 scale = {1,100}
                             }
end
                         end
                     }
                     end
                 end
            }
--]==]

            if model.album_group:find_child("frontpageselector") == nil 
                                                                   then
print("adding selector")
                view.selector.opacity = 0
                model.album_group:add(view.selector)
                model.album_group:add(view.sel_info)
--[[
                view.selector:complete_animation()
                view.selector:animate{
                     duration = 15*CHANGE_VIEW_TIME,
                     --position = {new_c-55,new_r-55}
                     opacity  = 255
                }
--]]
                view.timer:start()
                

            end
--[[

            local rand = math.random(1,3)
            --print(rand,model.swapping_cover)
            if rand == 3 and model.swapping_cover == false then
                model.swapping_cover = true
                local rand_i = {
                    math.random(1,NUM_ROWS),
                    math.random(1,NUM_VIS_COLS) + 
                         model.front_page_index  - 1
                }
                local search_i = math.random(1,10)
                local formula = (rand_i[2]-1)*2 + (rand_i[1])
                --print("formula?",rand_i[1],rand_i[2],formula)
                loadCovers(formula, searches[formula], search_i)
            end
            prev_i = {sel[1],sel[2]}
--]]

        else
            print("Hiding FrontPageView UI")
            model.album_group:complete_animation()
            view.ui.opacity = 0
        end
    end

function view.timer.on_timer(timer)
	print("random insert")
            --print(rand,model.swapping_cover)
            if model.swapping_cover == false then
                model.swapping_cover = true
                local rand_i = {
                    math.random(1,NUM_ROWS),
                    math.random(1,NUM_VIS_COLS) + 
                         model.front_page_index  - 1
                }
                local search_i = math.random(1,10)
                local formula = (rand_i[2]-1)*2 + (rand_i[1])
                --print("formula?",rand_i[1],rand_i[2],formula)
                loadCovers(formula, searches[formula], search_i)
            end

end

end)

