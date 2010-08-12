CHANGE_VIEW_TIME = 100

FrontPageView = Class(View, function(view, model, ...)

    view._base.init(view, model)

    view.ui=Group{name="Front_Page_ui"}

    Init_Pics(view.ui)

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(FrontPageController(self))
    end

    local prev_scale = {1,1}
 
    function view:move_right()
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
                    model.right_edge[i] = Image{

                        position = 
                        {
                            screen.width  -
                            screen.width  / (NUM_VIS_COLS + 1)*.5,
                            screen.height * (i-1) / NUM_ROWS
                        },

                        src = PIC_DIR.."Album"..index..".jpg"
                    }
                    model.right_edge[i].scale = 
                    {
                        (screen.width/(NUM_VIS_COLS+1))  / 
                         model.right_edge[i].base_size[1],
                        (screen.height/NUM_ROWS) / 
                         model.right_edge[i].base_size[2]
                    }
                    view.ui:add(model.right_edge[i])
                end
            end
        end
    end

    function view:move_left()
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
                    model.left_edge[i] = Image{
                       position = 
                       {
                            0  -
                            screen.width  / (NUM_VIS_COLS + 1)*.5,
                            screen.height * (i-1) / NUM_ROWS
                        },

                        src = PIC_DIR.."Album"..index..".jpg"
                    }
                    model.left_edge[i].scale = 
                    {
                        (screen.width/(NUM_VIS_COLS+1))  / 
                         model.left_edge[i].base_size[1],
                        (screen.height/NUM_ROWS) / 
                         model.left_edge[i].base_size[2]
                    }
                    view.ui:add(model.left_edge[i])
                end
            end
        end
    end
           
    function view:update()
        local controller =       view:get_controller()
        local comp       =      model:get_active_component()
        local sel        = controller:get_selected_index()
        local prev       = controller:get_prev_index()

        if comp == Components.FRONT_PAGE  then
            print("\n\nShowing FrontPageView UI\n")

            view.ui:raise_to_top()
            view.ui.opacity = 255            
            --view.ui:animate{duration=CHANGE_VIEW_TIME,opacity = 255}

            print("new index is",sel[1],sel[2])
            print("previous index is",prev[1],prev[2])

            local new_r
            if sel[1] == 1 then
                new_r = 0
            elseif sel[1] == NUM_ROWS then
                new_r = .9*screen.height * (sel[1]-1) / NUM_ROWS
            else
                new_r = .95*screen.height * (sel[1]-1) / NUM_ROWS
            end
            local new_c = screen.width  * (sel[2]-1) / 
                        (NUM_VIS_COLS + 1) +
                        .9*screen.width  / (NUM_VIS_COLS + 1)*.5--15


            model.vis_pics[prev[1]][prev[2]]:animate{
                 duration = CHANGE_VIEW_TIME,
                 scale  = {
                     (screen.width/(NUM_VIS_COLS+1))  / 
                      model.vis_pics[prev[1]][prev[2]].base_size[1],
                     (screen.height/NUM_ROWS) / 
                      model.vis_pics[prev[1]][prev[2]].base_size[2]
                 },
                 position = {
                     screen.width  * (prev[2]-1) / (NUM_VIS_COLS + 1) +
                     screen.width  / (NUM_VIS_COLS + 1)*.5,
                     screen.height * (prev[1]-1) / NUM_ROWS
                 },

                 on_completed = function()
                     model.vis_pics[sel[1]][sel[2]]:raise_to_top()
                     model.vis_pics[sel[1]][sel[2]]:animate{
                        duration = CHANGE_VIEW_TIME,
                        position = {new_c,new_r},
                        scale  = {
                            1.1*(screen.width/(NUM_VIS_COLS+1))  / 
                            model.vis_pics[sel[1]][sel[2]].base_size[1],
                            1.1*(screen.height/NUM_ROWS) / 
                            model.vis_pics[sel[1]][sel[2]].base_size[2]
                        }
                     }
                 end
            }


           

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
            view.ui:complete_animation()
                        model.vis_pics[sel[1]][sel[2]]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 150,
                            z        = 0
                        }
        end
    end

end)
