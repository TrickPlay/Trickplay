CHANGE_VIEW_TIME = 100

FrontPageView = Class(View, function(view, model, ...)
    view._base.init(view, model)
    view.ui = Group{name="front page ui"}
    screen:add(view.ui)

    view.selector = Image
    {
        src = "assets/polaroid_overlay.png",
        opacity = 0
    }

    model.album_group:add(view.selector)
    view.ui:add(model.album_group)

    grad = Image
    {
        src = "assets/gradient_mask.png",
        opacity = 0--255
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

    --right_edge:raise_to_top()
    --left_edge:raise_to_top()

    function view:initialize()
        self:set_controller(FrontPageController(self))
    end

    local prev_scale = {1,1}
 
    function view:shift_group(dir)
        local controller = view:get_controller()

        local sel        = {}
        sel[1],sel[2]    = controller:get_selected_index()
               sel[2]    = sel[2] + model.front_page_index  - 1
        local prev       = {}
        prev[1],prev[2]  = controller:get_prev_index()
                prev[2]  = prev[2] + model.front_page_index - 1
        if model.albums[prev[1]][prev[2]] == nil then
            model.placeholders[prev[1]][prev[2]]:complete_animation()
        else
            model.albums[prev[1]][prev[2]]:complete_animation()
        end
        if model.albums[sel[1]][sel[2]] == nil then
            model.placeholders[sel[1]][sel[2]]:complete_animation()
        else
            model.albums[sel[1]][sel[2]]:complete_animation()
        end


        local next_spot = model.front_page_index + dir
        local upper_bound = math.ceil(model.num_sources / NUM_ROWS) -
                                     (NUM_VIS_COLS-1)
        if next_spot > 0 and next_spot <= upper_bound then
        model.front_page_index = next_spot
        model.album_group:complete_animation()
            model.album_group:animate
            {
                duration = CHANGE_VIEW_TIME,
                x = model.album_group.x - dir*(screen.width/(NUM_VIS_COLS+1))
            }
        --TODO include loader threshold here
        end
    end

 
           
    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local sel        = {}
        sel[1],sel[2]    = controller:get_selected_index()
               sel[2]    = sel[2] + model.front_page_index  - 1
        local prev       = {}
        prev[1],prev[2]  = controller:get_prev_index()
                prev[2]  = prev[2] + model.front_page_index - 1

        if comp == Components.FRONT_PAGE  then
            print("\n\nShowing FrontPageView UI\n")

            model.album_group:raise_to_top()
            --grad:raise_to_top()
            right_edge:raise_to_top()
            left_edge:raise_to_top()
            model.album_group.opacity = 255            
            --view.ui:animate{duration=CHANGE_VIEW_TIME,opacity = 255}

            print("new index is",sel[1],sel[2],"shift",model.front_page_index)
            print("previous index is",prev[1],prev[2])

            --Init_Pics(view.ui)
            --Reload_Images(view)
            print("focusing on a pic")

            local prev_index = model.front_page_index*2 + (prev[1]-1)
            local sel_index = model.front_page_index*2 + (sel[1]-1)


            local new_r
            if sel[1] == 1 then
                new_r = 0
            elseif sel[1] == NUM_ROWS then
                new_r = .9*screen.height * (sel[1]-1) / NUM_ROWS
            else
                new_r = .95*screen.height * (sel[1]-1) / NUM_ROWS
            end
            local new_c = screen.width  * (sel[2]-1) / 
                        (NUM_VIS_COLS + 1)

            view.selector:animate{
                 duration = CHANGE_VIEW_TIME,
                 opacity  = 0
            }
            
            if model.albums[prev[1]][prev[2]] == nil then
                model.placeholders[prev[1]][prev[2]]:complete_animation()
                model.placeholders[prev[1]][prev[2]]:animate{
                     duration = CHANGE_VIEW_TIME,
                     scale    = {
                         (screen.width/(NUM_VIS_COLS+1))  / 
                          model.default.base_size[1],
                         (screen.height/NUM_ROWS) / 
                          model.default.base_size[2]
                     },
                     position = {
                         screen.width  * (prev[2]-1) / (NUM_VIS_COLS + 1),
                         screen.height * (prev[1]-1) / NUM_ROWS
                     },

                     on_completed = function()
                         if model.albums[sel[1]][sel[2]] == nil then
                             model.placeholders[sel[1]][sel[2]]:raise_to_top()
                             model.placeholders[sel[1]][sel[2]]:animate{
                                 duration = CHANGE_VIEW_TIME,
                                 position = {new_c,new_r},
                                 scale  = {
                                     1.1*(screen.width/(NUM_VIS_COLS+1))  / 
                                     model.default.base_size[1],
                                     1.1*(screen.height/NUM_ROWS) / 
                                     model.default.base_size[2]
                                 }

                             }
                         else
                             model.placeholders[prev[1]][prev[2]]:complete_animation()
                             model.albums[sel[1]][sel[2]]:complete_animation()
                             model.albums[sel[1]][sel[2]]:raise_to_top()
                             model.albums[sel[1]][sel[2]]:animate{
                                 duration = CHANGE_VIEW_TIME,
                                 position = {new_c,new_r},
                                 scale  = {
                                     1.1*(screen.width/(NUM_VIS_COLS+1))  / 
                                     model.albums[sel[1]][sel[2]].base_size[1],
                                     1.1*(screen.height/NUM_ROWS) / 
                                     model.albums[sel[1]][sel[2]].base_size[2]
                                 }

                             }
                         end
                         view.selector:complete_animation()
                         view.selector:raise_to_top()
                         view.selector.position={new_c-37,new_r-10}
                         view.selector:animate{
                             duration = 2*CHANGE_VIEW_TIME,
                             scale = {1.05,1.1},
                             opacity = 255
                         }
                     end
                }     
            else
                model.albums[prev[1]][prev[2]]:complete_animation()
                model.albums[prev[1]][prev[2]]:animate{
                     duration = CHANGE_VIEW_TIME,
                     scale    = {
                         (screen.width/(NUM_VIS_COLS+1))  / 
                          model.albums[prev[1]][prev[2]].base_size[1],
                         (screen.height/NUM_ROWS) / 
                          model.albums[prev[1]][prev[2]].base_size[2]
                     },
                     position = {
                         screen.width  * (prev[2]-1) / (NUM_VIS_COLS + 1),
                         screen.height * (prev[1]-1) / NUM_ROWS
                     },

                     on_completed = function()
                         if model.albums[sel[1]][sel[2]] == nil then
                             model.placeholders[sel[1]][sel[2]]:raise_to_top()
                             model.placeholders[sel[1]][sel[2]]:animate{
                                 duration = CHANGE_VIEW_TIME,
                                 position = {new_c,new_r},
                                 scale  = {
                                     1.1*(screen.width/(NUM_VIS_COLS+1))  / 
                                     model.default.base_size[1],
                                     1.1*(screen.height/NUM_ROWS) / 
                                     model.default.base_size[2]
                                 }

                             }
                         else
                             model.albums[prev[1]][prev[2]]:complete_animation()
                             model.albums[sel[1]][sel[2]]:complete_animation()
                             model.albums[sel[1]][sel[2]]:raise_to_top()
                             model.albums[sel[1]][sel[2]]:animate{
                                 duration = CHANGE_VIEW_TIME,
                                 position = {new_c,new_r},
                                 scale  = {
                                     1.1*(screen.width/(NUM_VIS_COLS+1))  / 
                                     model.albums[sel[1]][sel[2]].base_size[1],
                                     1.1*(screen.height/NUM_ROWS) / 
                                     model.albums[sel[1]][sel[2]].base_size[2]
                                 }

                             }
                         end
                         view.selector:complete_animation()
                         view.selector:raise_to_top()
                         view.selector.position={new_c-37,new_r-10}
                         view.selector:animate{
                             duration = CHANGE_VIEW_TIME,
                             scale = {1.05,1.1},
                             opacity = 255
                         }
                     end
                } 
            end

        elseif comp == Components.ITEM_SELECTED  then
        else
            print("Hiding FrontPageView UI")
            model.album_group:complete_animation()
        end
    end

end)
