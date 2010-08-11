CHANGE_VIEW_TIME = 100

FrontPageView = Class(View, function(view, model, ...)

    view._base.init(view, model)

    view.ui=Group{name="Front_Page_ui"}
    view.menu_items = {}

    local grid
    grid, view.menu_items  = GenerateGrid(view.ui)
    function view:refresh()
print("refreshin")
        view.ui:clear()
        grid, view.menu_items = GenerateGrid(view.ui)
        assert(view.menu_items,"no menu items")
        assert(grid,"no grid :(")
        view:get_controller():refresh_grid(grid)
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
        else
            print("Hiding FrontPageView UI")
            view.ui:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
