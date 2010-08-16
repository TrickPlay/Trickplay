CHANGE_VIEW_TIME = 100
math.randomseed(os.time())

FrontPageView = Class(View, function(view, model, ...)
    view._base.init(view, model)

    view.ui = Group{name="front page ui"}
    screen:add(view.ui)

    view.selector = Image
    {
        name = "frontpageselector",
        src = "assets/polaroid_overlay.png",
        opacity = 0
    }

    model.album_group:add(view.selector)
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

        local next_spot = model.front_page_index + dir
        local upper_bound = math.ceil(model.num_sources / NUM_ROWS) -
                                     (NUM_VIS_COLS-1)
        if next_spot > 0 and next_spot <= upper_bound then
        model.front_page_index = next_spot
        model.album_group:complete_animation()

            model.album_group:animate
            {
                 duration = 2*CHANGE_VIEW_TIME,
                 mode     = EASE_IN_QUAD,
                 x = model.album_group.x - dir*(screen.width/(NUM_VIS_COLS+1))
            }

        --TODO include loader threshold here
        end
    end

    local prev_i = {1,1} 
           
    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local sel        = {}
        sel[1],sel[2]    = controller:get_selected_index()
               sel[2]    = sel[2] + model.front_page_index  - 1
        if comp == Components.FRONT_PAGE  then

            if model.album_group:find_child("frontpageselector") == nil 
                                                                   then
                controller:reset_selected_index()
                sel = {1,1}
                prev_i = {1,1}
                model.front_page_index = 1
                model.album_group:add(view.selector)
            end
            print("\n\nShowing FrontPageView UI\n")

            view.ui:raise_to_top()
            view.ui.opacity = 255            

            print("new index is",sel[1],sel[2],"shift",
                                   model.front_page_index)
            print("previous index is",prev_i[1],prev_i[2])


            local prev_index = model.front_page_index*2 + (prev_i[1]-1)
            local sel_index  = model.front_page_index*2 + (sel[1]-1)


            local new_r = PIC_H * (sel[1]-1)
            if sel[1] == 1 then
                new_r = 0
            elseif sel[1] == NUM_ROWS then
                  new_r = new_r * .9
--                new_r = .9*screen.height * (sel[1]-1) / NUM_ROWS
            else
                  new_r = new_r * .95
--                new_r = .95*screen.height * (sel[1]-1) / NUM_ROWS
            end
            local new_c = PIC_W * (sel[2]-1)
--[[
            local new_c = screen.width  * (sel[2]-1) / 
                             (NUM_VIS_COLS + 1)
--]]
            view.selector:animate{
                 duration = CHANGE_VIEW_TIME,
                 opacity  = 0
            }


            local previous
            local current
            local prev_bs
            local curr_bs

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

            if model.albums[sel[1]] == nil or 
               model.albums[sel[1]][sel[2]] == nil then
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
            print(prev_bs[1],prev_bs[2],curr_bs[1],curr_bs[2])

            previous:complete_animation()
            previous:animate{
                duration = CHANGE_VIEW_TIME,
                scale    = { PIC_W / prev_bs[1], PIC_H / prev_bs[2] },
                position = { PIC_W * (prev_i[2]-1),PIC_H * (prev_i[1]-1)},
                on_completed = function()


                    current:complete_animation()
                    current:raise_to_top()
                    current:animate{
                        duration = CHANGE_VIEW_TIME,
                        position = {new_c,new_r},
                        scale  = {SEL_W / curr_bs[1],SEL_H /curr_bs[2]}
                    }

                    view.selector:complete_animation()
                    view.selector:raise_to_top()
                    view.selector.position={new_c-37,new_r-10}
                    view.selector:animate{
                        duration = 2*CHANGE_VIEW_TIME,
                        scale = {1.05,1.1},
                        opacity = 255
                    }

                    local r = math.random(1,4)
                    print(r)
                    if r == 4 then
                        local next_pic = Image{
                            src="assets/thumbnails/Album3.jpg",
                            opacity = 0,
                            on_loaded = function()

                            end
                        }
---[=[
                                next_pic.scale = {
                                    PIC_W / next_pic.base_size[1],
                                    PIC_H / next_pic.base_size[2]
                                }
--]=]
                            --next_pic.y_rotation = { -90,  PIC_W , 0 }


                        Flip_Pic(prev_i[1],prev_i[2],next_pic)
                    end
                    prev_i = {sel[1],sel[2]}

                end
            }


        else
            print("Hiding FrontPageView UI")
            model.album_group:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
