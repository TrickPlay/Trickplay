CHANGE_VIEW_TIME = 100

FrontPageView = Class(View, function(view, model, ...)

    view._base.init(view, model)

    view.ui=Group{name="Front_Page_ui"}
    view.menu_items = {}
--[[
    view.selected_box = Rectangle{
        color    = "000000",
        z        = 1,
        opacity  = 0
    }
--]]
    view.selected_box = {
--[[
        Image{src="assets/piece_empty_left_side.png",
              z=1,
              opacity = 255
        },
        Image{src="assets/piece_empty_right_center.png",
              z=1,
              opacity = 255
        }
--]]
        Image{src="assets/empty_leftside.png",
              z=1,
              opacity = 255
        },
        Image{src="assets/empty_rightside.png",
              z=1,
              opacity = 255
        }

    }
    view.ui:add(unpack(view.selected_box))

    local grid
    grid, view.menu_items  = GenerateGrid(view.ui)
    function view:refresh()
print("refreshin")
        view.ui:clear()
        view.ui:add(unpack(view.selected_box))

        view.menu_items = {}
        grid, view.menu_items = GenerateGrid(view.ui)
        assert(view.menu_items,"no menu items")
        assert(grid,"no grid :(")
        view:get_controller():refresh_grid(grid)
        sel = view:get_controller():get_selected_index()
        view:get_controller():set_selected_index(grid[sel[1]][sel[2]][1],
                                                 grid[sel[1]][sel[2]][2])
        model:notify()
        --view:get_controller():reset_selected_index()
    end

    screen:add(view.ui)

    function view:initialize()
        self:set_controller(FrontPageController(self, grid))
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.FRONT_PAGE  then
            print("\n\nShowing FrontPageView UI\n")
            view.selected_box[1]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 0,
            }
            view.selected_box[2]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 0,
            }


            view.ui:raise_to_top()
            view.ui.opacity = 255            
            --view.ui:animate{duration=CHANGE_VIEW_TIME,opacity = 255}

            local sel = controller:get_selected_index()
            print("index is",sel[1],sel[2])
            for i = 1,NUM_ROWS do
                for j = 1,NUM_COLS do
                    if sel[1] == i and sel[2] == j then 
                        print("Moving to",i,j)
                        view.menu_items[i][j]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 255,
                            z        = 5
                        }
                    elseif view.menu_items[i][j] ~= nil then
                        view.menu_items[i][j]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 150,
                            z        = 0
                        }
                    end
                end
            end
        elseif comp == Components.ITEM_SELECTED  then
            local sel = controller:get_selected_index()
--[=[
            view.selected_box.y = view.menu_items[sel[1]][sel[2]].y -20
            view.selected_box.x = view.menu_items[sel[1]][sel[2]].x -20

            view.selected_box.height = view.menu_items[sel[1]][sel[2]].height*
                                       view.menu_items[sel[1]][sel[2]].scale[2]+
                                       40
            view.selected_box.width = view.menu_items[sel[1]][sel[2]].width*
                                      view.menu_items[sel[1]][sel[2]].scale[1]+
                                      270

            view.selected_box:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 150,
            }
--]=]
            --use the left box
            if sel[2] > NUM_COLS/2+1 then
                print("image left")
                view.selected_box[1].y = view.menu_items[sel[1]][sel[2]].y -20
                view.selected_box[1].x = view.menu_items[sel[1]][sel[2]].x -250
                view.selected_box[1]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 255
                }

            else
                print("image right")
                view.selected_box[2].y = view.menu_items[sel[1]][sel[2]].y -20
                view.selected_box[2].x = view.menu_items[sel[1]][sel[2]].x 
                view.selected_box[2]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 255
                }

            end
        else
            local sel = controller:get_selected_index()

            print("Hiding FrontPageView UI")
            view.ui:complete_animation()
                        view.menu_items[sel[1]][sel[2]]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 150,
                            z        = 0
                        }
            view.selected_box[1]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 0,
            }
            view.selected_box[2]:animate{
                            duration = CHANGE_VIEW_TIME,
                            opacity  = 0,
            }

--[[
            view.ui:animate{duration = CHANGE_VIEW_TIME,
                              opacity = 100}
--]]
        end
    end

end)
