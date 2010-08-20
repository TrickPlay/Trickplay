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
        position = {40,-75},
        size = {300, 225}
    }
                                                                              
    local album_title = Text
    {
        name     = "pic_text",
        text     = "",
        color    = "FFFFFF",
        font     = "Sans 32px",
        position = {320, 10}
    }
    local controls = Image
    {
        src = "assets/buttons.png",
        name     = "controls",
        position = {-10, 25}
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

    local prev_i = {1,1} 
    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local  sel       = {}
        sel[1],sel[2]    = controller:get_selected_index()
               sel[2]    = sel[2] + model.front_page_index  - 1
        model.fp_index = {sel[1],sel[2]}
        model.fp_1D_index = (sel[2]-1)*NUM_ROWS + (sel[1])
        if comp == Components.FRONT_PAGE  then

            view:shift_group()
            print("\n\nShowing FrontPageView UI\n")

            --view.ui:raise_to_top()
            view.ui.opacity = 255            

            print("new index is",sel[1],sel[2],"shift",
                                   model.front_page_index)
            print("previous index is",prev_i[1],prev_i[2])


            local prev_index = model.front_page_index*2 + (prev_i[1]-1)
            local sel_index  = model.front_page_index*2 + (sel[1]-1)


            local new_r = PIC_H * (sel[1]-1)
--[[
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
            local new_c = PIC_W * (sel[2]-1) - .025*PIC_W 

--[[
            local new_c = screen.width  * (sel[2]-1) / 
                             (NUM_VIS_COLS + 1)
--]]

---[=[
            local previous =  model.fp_slots[prev_i[1]][prev_i[2]]
            local current  =  model.fp_slots[sel[1]][sel[2]]
--[=[
            local prev_bs  = {model.fp_slots[prev_i[1]][prev_i[2]].base_size[1],
                              model.fp_slots[prev_i[1]][prev_i[2]].base_size[2]}
            local curr_bs  = {model.fp_slots[sel[1]][sel[2]].base_size[1],
                              model.fp_slots[sel[1]][sel[2]].base_size[2]}
--]=]
--[=[
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
            if model.album_group:find_child("bottom_bar") == nil 
                                                                   then
print("adding bottom bar")
                model.album_group:add(view.backdrop)
                model.fp_slots[model.fp_index[1]][model.fp_index[2]]:add(view.bottom_bar)
                view.timer:start()

            end



--[=[
            if model.albums[sel[1]] == nil or 
               model.albums[sel[1]][sel[2]] == nil then
               print("going to placeholder",sel[1],sel[2])
                current = model.placeholders[sel[1]][sel[2]]
                curr_bs =  {
                   model.def_bs[1],model.def_bs[2]
                }
            else
                current = model.albums[sel[1]][sel[2]]
                curr_bs = {
                    model.albums[sel[1]][sel[2]].base_size[1],
                    model.albums[sel[1]][sel[2]].base_size[2]
                }
            end
--]=]
            --print(prev_bs[1],prev_bs[2],curr_bs[1],curr_bs[2])
            view.bottom_bar.opacity = 0

            view.bottom_bar:complete_animation()
           -- view.bottom_bar.opacity = 0

            view.bottom_bar:unparent()

            model.fp_slots[model.fp_index[1]][model.fp_index[2]]:add(view.bottom_bar)

            view.bottom_bar.position = {0,PIC_H}

            assert(previous ~= nil,"wth")
            previous:complete_animation()
            view.backdrop.opacity = 0
            previous:animate{
                duration = CHANGE_VIEW_TIME,
                scale = {1,1},
                position = { PIC_W * (prev_i[2]-1),PIC_H * (prev_i[1]-1)+10},
                on_completed = function()
                    if model.albums[sel[1] ]          ~= nil    and
                       model.albums[sel[1] ][sel[2] ] ~= nil    and
                       model.fp_index[2]              == sel[2] and
                       model.fp_index[1]              == sel[1] then

                    prev_i = {sel[1],sel[2]}
                    print("completed to placeholder:",sel[1],sel[2])
                    current:complete_animation()
                    current:animate{
                        duration = CHANGE_VIEW_TIME,
                        position = {new_c,new_r},
                        scale    = {1.05,1.05},
                        on_completed = function()
                            if model.albums[sel[1] ]          ~= nil    and
                               model.albums[sel[1] ][sel[2] ] ~= nil    and
                               model.fp_index[2]              == sel[2] and
                               model.fp_index[1]              == sel[1] then

                                view.backdrop.position={new_c-22,new_r-17}
                                view.backdrop.scale = {.945,.945}
                                view.backdrop.opacity = 255
                                view.backdrop:raise_to_top()
                                current:raise_to_top()

                                view.bottom_bar:raise_to_top()
                                --idk why this needs to be here but it fixes issues of the
                                --animation fucking up while you're moving around
                                view.bottom_bar.scale   = {1.1,1}
                                view.bottom_bar.position = {-10, PIC_H}

                                view.bottom_bar:animate{
                                    duration = 4*CHANGE_VIEW_TIME,
                                    y        = PIC_H,
                                    on_completed = function()
                                        if model.fp_slots[sel[1] ][sel[2] ]:find_child("bottom_bar") ~= nil then
                                            view.bottom_bar.opacity = 255
                                            album_title.text = string.gsub((adapters[#adapters - 
                                                 model.fp_1D_index + 1][1].required_inputs.query),
                                                                                      "%%20"," ")
                                            album_logo.src = adapters[#adapters - model.fp_1D_index + 1].logoUrl

                                            view.bottom_bar:animate{
                                                duration = 2*CHANGE_VIEW_TIME,
                                                y        = PIC_H- 50,
                                                on_completed = function()
                                                    if model.fp_slots[sel[1] ][sel[2] ]:find_child(
                                                                          "bottom_bar") ~= nil then
                                                        view.bottom_bar:animate{
                                                            duration = 20*CHANGE_VIEW_TIME,
                                                            y        = PIC_H- 50,
                                                            on_completed = function()
                                                                 if model.fp_slots[sel[1] ][sel[2] ]:find_child("bottom_bar") ~= nil then
                                                                        view.bottom_bar:animate{
                                                                        duration = CHANGE_VIEW_TIME,
                                                                        y        = PIC_H- 120
                                                                    }
                                                                end
                                                            end
                                                        }
                                                    end
                                                end
                                                --scale    = {1.051,60},
--[[
                                                on_completed = function()
                                                    if model.fp_slots[sel[1] ][sel[2] ]:find_child("pic_logo") ~= nil and
                                                       model.fp_slots[sel[1] ][sel[2] ]:find_child("pic_text") ~= nil then
                                                        view.album_title:raise_to_top()
                                                        view.album_title.text = 
                                                              adapters[#adapters - model.fp_1D_index + 1][1].required_inputs.query
                                                        view.album_title.position = {300,
                                                                              PIC_H-50}
                                                        view.album_title:animate{
                                                            duration = .5*CHANGE_VIEW_TIME, 
                                                            opacity  = 255
                                                        }

                                                        view.album_logo:raise_to_top()
                                                        view.album_logo.size = {200,50}
                                                        view.album_logo.position = {0,
                                                                              PIC_H-50}
                                                        view.album_logo:animate{
                                                            duration = .5*CHANGE_VIEW_TIME, 
                                                            opacity  = 255
                                                        }
                                                    end
                                                end--]]
                                            }
                                        end
                                    end
                                }
                            end
                        end
                    
                    }
                    end
                end
            }

        elseif comp == Components.SOURCE_MANAGER then
            print("Dimming FrontPageView UI")
            view:shift_group()

            model.album_group:complete_animation()
            view.ui:animate{duration = 100,opacity = 150}

        else
            print("Hiding FrontPageView UI")
            model.album_group:complete_animation()
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
                --print("trying at",rand_i[1],rand_i[2],"when at",model.fp_index[1],
                --                                                model.fp_index[2])
                local formula = (rand_i[2]-1)*NUM_ROWS + (rand_i[1])

                if (rand_i[1] ~= model.fp_index[1] or
                   rand_i[2] ~= model.fp_index[2]) and adapters[formula]~=nil then
                    print("calling")
                    model.swapping_cover = true

                    local search_i = math.random(1,10)
                    --print("formula?",rand_i[1],rand_i[2],formula)
                    loadCovers(formula, searches[#adapters+1-formula], search_i)
                else
                    print("not calling")
                end
            end

end

end)

