CHANGE_VIEW_TIME = 100

FrontPageView = Class(View, function(view, model, ...)

    view._base.init(view, model)

   -- Init_Pics(view.ui)
view.selector = Image{
   src = "assets/polaroid_overlay.png",
   opacity = 0
}

    model.album_group:add(view.selector)
    screen:add(model.album_group)

    function view:initialize()
        self:set_controller(FrontPageController(self))
    end

    local prev_scale = {1,1}
 
    function view:shift_group(dir)
        local next_spot = model.front_page_index + dir
        local upper_bound = math.ceil(model.num_sources / NUM_ROWS) - (NUM_VIS_COLS-1)
        if next_spot > 0 and next_spot <= upper_bound then
        model.front_page_index = next_spot
        model.album_group.x = model.album_group.x - 
                              dir*(screen.width/(NUM_VIS_COLS+1))
--[[
        view.selector.x = view.selector.x + 
                              dir*(screen.width/(NUM_VIS_COLS+1))
--]]
        --TODO include loader threshold here
        end
    end

    function view:move_right()
--[[
        if model.right_edge[1] ~= nil then
            local prev = view:get_controller():get_prev_index()
            view:get_controller():set_prev_index(prev[1],prev[2]-1)
            --shift left side of visible pics to the left edge
            for i = 1,NUM_ROWS do
                if model.left_edge[i] ~= nil then

                    model.left_edge[i]:unparent()
                end
                model.left_edge[i] = model.vis_pics[i][1]
                model.left_edge[i].position=
                {
                    0  -
                    screen.width  / (NUM_VIS_COLS + 1)*.5,
                    screen.height * (i-1) / NUM_ROWS
                }
            end
            --shift the visible pics
            for i = 1,NUM_ROWS do 
                for j = 2,NUM_VIS_COLS do
                    model.vis_pics[i][j-1] = model.vis_pics[i][j]
                    model.vis_pics[i][j-1].position = 
                    {
                        screen.width  * (j-2) / (NUM_VIS_COLS + 1) +
                        screen.width  / (NUM_VIS_COLS + 1)*.5,
                        screen.height * (i-1) / NUM_ROWS
                    }
                end
            end
            --shift the right edge to the right side of the visible pics
            for i = 1,NUM_ROWS do
                model.vis_pics[i][NUM_VIS_COLS] = model.right_edge[i]
                model.vis_pics[i][NUM_VIS_COLS].position=                  
                    {
                        screen.width *(NUM_VIS_COLS-1)/(NUM_VIS_COLS + 1)+
                        screen.width  / (NUM_VIS_COLS + 1)*.5,
                        screen.height * (i-1) / NUM_ROWS
                    }
                model.right_edge[i] = nil
            end

            local next_index = model.front_page_index + 1
            
            --add in pics to the right edge
            print("front index is now:",next_index,
                  "  checking as:",(model.front_page_index + 3)*2 - 1)
            if (next_index + 3)*2 - 1 < model.num_sources then
                model.front_page_index = next_index
                for i = 1, NUM_ROWS do
                    local index = (model.front_page_index + 2)*2 + i
                    




            model.right_edge[i] = Clone{
              source = model.album_covers[index]
            }
model.right_edge[i].position = 
                 {
                    screen.width  -
                    screen.width  / (NUM_VIS_COLS + 1)*.5,
                    screen.height * (i-1) / NUM_ROWS
                 }
            model.right_edge[i].scale = 
             {
                 (screen.width/(NUM_VIS_COLS+1))  / 
                  model.album_base_sizes[index][1],
                 (screen.height/NUM_ROWS) / 
                  model.album_base_sizes[index][2]
             }
        view.ui:add(model.right_edge[i])





                end
            end
        end
--]]
    end

    function view:move_left()
--[[
        if model.left_edge[1] ~= nil then
            local prev = view:get_controller():get_prev_index()
            view:get_controller():set_prev_index(prev[1],prev[2]+1)

            --shift right side of visible pics to the right edge
            for i = 1,NUM_ROWS do
                if model.right_edge[i] ~= nil then

                    model.right_edge[i]:unparent()
                end
                model.right_edge[i] = model.vis_pics[i][NUM_VIS_COLS]
                model.right_edge[i].position=
                {
                    screen.width  -
                    screen.width  / (NUM_VIS_COLS + 1)*.5,
                    screen.height * (i-1) / NUM_ROWS
                }
            end

            --shift the visible pics
            for i = 1,NUM_ROWS do 
                for j = NUM_VIS_COLS-1,1,-1 do
                    model.vis_pics[i][j+1] = model.vis_pics[i][j]
                    model.vis_pics[i][j+1].position = 
                    {
                        screen.width  * (j-0) / (NUM_VIS_COLS + 1) +
                        screen.width  / (NUM_VIS_COLS + 1)*.5,
                        screen.height * (i-1) / NUM_ROWS
                    }
                end
            end

            --shift the left edge to the left side of the visible pics
            for i = 1,NUM_ROWS do
                model.vis_pics[i][1] = model.left_edge[i]
                model.vis_pics[i][1].position=                  
                    {

                        screen.width  / (NUM_VIS_COLS + 1)*.5,
                        screen.height * (i-1) / NUM_ROWS
                    }
                model.left_edge[i] = nil
            end

            local next_index = model.front_page_index - 1
            
            --add in pics to the right edge
            print("front index is now:",next_index)
            if next_index > 1 then
                model.front_page_index = next_index
                for i = 1, NUM_ROWS do
                    local index = model.front_page_index*2+ i-4
--(model.front_page_index + 2)*2
                    print("grabbing pic",index)




            model.left_edge[i] = Clone{source=model.album_covers[index]}
            model.left_edge[i].position = 
                       {
                            0  -
                            screen.width  / (NUM_VIS_COLS + 1)*.5,
                            screen.height * (i-1) / NUM_ROWS
                        }
            model.left_edge[i].scale = 
                    {
                        (screen.width/(NUM_VIS_COLS+1))  / 
                         model.album_base_sizes[index][1],
                        (screen.height/NUM_ROWS) / 
                         model.album_base_sizes[index][2]
                    }
        view.ui:add(model.left_edge[i])





                end
            end
        end
--]]
    end
           
    function view:update()
        local controller =       view:get_controller()
        local comp       =      model:get_active_component()
        local sel        = {}
           sel[1],sel[2] = controller:get_selected_index()
              sel[2]     = sel[2] + model.front_page_index  - 1
        local prev       = {}
        prev[1],prev[2]  = controller:get_prev_index()
              prev[2]    = prev[2] + model.front_page_index - 1

        if comp == Components.FRONT_PAGE  then
            print("\n\nShowing FrontPageView UI\n")

            model.album_group:raise_to_top()
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
-- +                        .9*screen.width  / (NUM_VIS_COLS + 1)*.5--15

            view.selector:animate{
                 duration = CHANGE_VIEW_TIME,
                 opacity  = 0
            }
print("prev")
            
            if model.albums[prev[1]][prev[2]] == nil then
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
-- +                         screen.width  / (NUM_VIS_COLS + 1)*.5,
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
                         print("moving selector")
                         view.selector:raise_to_top()
                         view.selector.position={new_c-37,new_r-10}
                         view.selector:animate{
                             duration = CHANGE_VIEW_TIME,
                             scale = {1.05,1.1},
                             opacity = 255
                         }
                     end
                }     
            else
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
-- +                         screen.width  / (NUM_VIS_COLS + 1)*.5,
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
                         print("moving selector")
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


           

--[[
            for i = 1,NUM_ROWS do
                for j = 1,NUM_VIS_COLS do
                    if sel[1] == i and sel[2] == j then 
                        print("Moving to",i,j)
                        model.vis_pics[i][j]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 255,
                            z        = 5
                        }
                    elseif model.vis_pics[i][j] ~= nil then
                        model.vis_pics[i][j]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 150,
                            z        = 0
                        }
                    end
                end
            end
--]]
        elseif comp == Components.ITEM_SELECTED  then
        else
            print("Hiding FrontPageView UI")
            model.album_group:complete_animation()
--[[
                        model.vis_pics[sel[1] ][sel[2] ]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 150,
                            z        = 0
                        }
--]]
        end
    end

end)
