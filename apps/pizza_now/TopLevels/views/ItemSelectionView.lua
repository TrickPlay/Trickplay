ItemSelectionView = Class(View, function(view, model, sel_menu, ...)
    view._base.init(view,model)
    assert(sel_menu.Options,"Parameter to ItemSelectionView() is not"
                                         .." a Selection_Menu object")

    local MAX_NUM_COLS = 5
    
    local row = 1
    local col = 1
    view.menu_items = {}
    view.menu_items[row] = {}
    for i, food_item in ipairs(sel_menu.Options) do
        col = i - MAX_NUM_COLS*(row-1)
        if col == MAX_NUM_COLS then
            row = row + 1
            col = 1
            view.menu_items[row] = {}
        end
        view.menu_items[row][col] = Text{
                position = {400*(col-1),150*(row-1)},
                font     = DEFAULT_FONT,
                color    = DEFAULT_COLOR,
                text     = food_item.Name
            }
        print("row",row,"col",col)
    end
    row = row + 1
    col = 1
    view.menu_items[row] = {}

        view.menu_items[row][col] = Text{
                position = {400*(col-1),150*(row)},
                font     = DEFAULT_FONT,
                color    = DEFAULT_COLOR,
                text     = "Go Back"
            }


    view.ui=Group{name="Item Selection UI", position={10,60}, opacity=0}
    for i, t in ipairs(view.menu_items) do
        view.ui:add(unpack(view.menu_items[i]))
    end
    screen:add(view.ui)

    function view:initialize()
        self:set_controller(ItemSelectionController(self))
    end

    function view:update()
        local controller =  self:get_controller()
        local comp =  self.model:get_active_component()
        if    comp == Components.ITEM_SELECTION then
            print("Showing ItemSelectionView UI")
            self.ui.opacity = 255
            for r,item in ipairs(view.menu_items) do
                for c,item in ipairs(view.menu_items[r]) do
                    if r == controller:get_selected_index().row and
                       c == controller:get_selected_index().col then
                        item:animate{duration=100, opacity = 255}
                    else
                        item:animate{duration=100, opacity = 100}
                    end
                end
            end
        else
            print("Hiding ItemSelectionView UI")
            self.ui.opacity = 0
        end
    end

end)
