
AccordianView = Class(View, function(view, model,parent, ...)
    view._base.init(view,model)
    view.parent = parent
    view.ui=Group{name="Accordian ui", position={660,80}, opacity=255}
    view.menu_items = {}
    view.selector = Image{
        position={-70,0},
        src = "assets/OptionHighlightShorter.png"
    }
    view.ui:add(view.selector)
    --screen:add(view.ui)
--[[
    function view:Create_Menu_Items()
        view.menu_items = {}
        --gut the UI
        view.ui:clear()
        view.ui:add(view.selector)
        view.menu_items = view.parent.sub_group_items
        for i, t in ipairs(view.menu_items) do
            view.ui:add(unpack(view.menu_items[i]))
        end
    end
--]]
    function view:init_selector(acc_g)
        local sel = view:get_controller():get_selected_index()
        view.acc_g = acc_g
        view.selector.y = view.menu_items[sel[1]][sel[2]][1].y + view.acc_g.y - 10
    end
    screen:add(view.ui)

    function view:initialize()
        view:set_controller(AccordianController(self))
    end



    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        if comp == Components.ACCORDIAN then
            print("Showing AccordianView UI")
            view.ui.opacity = 255
            view.selector.opacity = 255
            local sel = controller:get_selected_index()
            view.selector.y = view.menu_items[sel[1]][sel[2]][1].y + view.acc_g.y - 10
        else
            print("Hiding AccordianView UI")
            view.ui.opacity = 0
            view.selector.opacity = 0
        end
    end
    

   end)
