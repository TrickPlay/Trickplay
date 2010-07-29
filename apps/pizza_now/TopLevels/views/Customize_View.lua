
CustomizeView = Class(View, function(view, model, ...)
    view._base.init(view,model)
     
    view.ui=Group{name="Customize ui", position={0,0}, opacity=255}
    view.bg = Image{src = "assets/MenuBg.jpg", position={0,0}}
    view.bg2 = Clone{src=bg,position={960,0}}
    view.ui:add(bg)
    view.ui:add(bg2)
        screen:add(view.ui)

    --view.item = food_item
    view.menu_items      = {}
    view.sub_group       = {}
    view.sub_group_items = {}
    view.hor_lines       = {}
    view.vert_lines      = {}
    view.arrow           = {}
    --view.ui.add(view.arrow)

----------------------------------------------------------------------------
    --Build Tabs and their sub groups
    function view:Create_Menu_Items()
        --clear it out
        view.menu_items      = {}
        view.sub_group       = {}
        view.sub_group_items = {}
        view.hor_lines       = {}
        view.vert_lines      = {}

    
        --gut the UI
        view.ui:clear()
        view.ui:add(view.bg)
        view.ui:add(view.bg2)

        view.arrow = Image{                
                position = {300, 0},
                src      = "assets/SubmenuArrow.png"
            }
        view.food_name = Text {
              position = {140, 20},
              font     = CUSTOMIZE_NAME_FONT,
              color    = Colors.BLACK,
            z_rotation = {90,0,0},
              text     = model.current_item.Name
           }
        view.vert_sep    = Image {
                position = {150, 0},
                width    = 20,
                height   = 960,
                tiled    = {false,true},
                src      = "assets/MenuLine.png"
            }
        view.back_arrow = Image{                
                position = {5, 800},
                src      = "assets/BackArrowOutline.png"
            }
        view.back_arrow_selected = Image{                
                position = {5, 800},
                opacity  = 0,
                src      = "assets/BackArrowFilled.png"
            }
        view.add_to_order = Text{
              position    = {155, 850},
              font        = CUSTOMIZE_TAB_FONT,
              color       = Colors.BLACK,
              text        = "Add to Order"
           }
        view.hor_sep =  Image {
                position = {150, 840},
                height   = 960-150,
                scale    = {1,1.5},
              z_rotation = {-90,0,0},
                tiled    = {false,true},
                src      = "assets/MenuLine.png"
            }
        view.selector = Image {
                position  = {150, 0},
                src       = "assets/SubmenuHighlight.png"
            }
        view.add_to_order_selector = Image {
                position  = {150, 845},
                src       = "assets/EditOrderHighlight.png"
            }
        view.ui.opacity = 255
        for tab_index,tab in ipairs(model.current_item.Tabs) do

    
            --check to see if there is an item selected
            assert(model.current_item,"no item selected for Customization")
    
            --build the customization menu
            view.menu_items[tab_index] = Text {
                position = {155, 120*(tab_index-1)+30},
                font     = CUSTOMIZE_SUB_FONT,
                color    = Colors.BLACK,
                text     = tab.Tab_Text
            }
            view.hor_lines[tab_index] = Image {
                position = {150, 120*(tab_index-1)+120},
                scale    = {1,1.5},
                src      = "assets/MenuHorzLine.png"
            }
            view.vert_lines[tab_index] = Image {
                position = {300, 120*(tab_index-1)},
                width    = 20,
                height   = 120,
                tiled    = {false,true},
                src      = "assets/MenuLine.png"
            }

            view.sub_group_items[tab_index] = {}
            view.sub_group[tab_index] = Group{name="Tab "..tab_index.." sub-group",
                                                    position={500,60}, opacity=0}
            if tab.Options ~= nil then
                for opt_index,option in ipairs(tab.Options) do
                    local indent = 1
                    view.sub_group_items[tab_index][opt_index] = {}
                    view.sub_group_items[tab_index][opt_index][1] = Text {
                        position = {0, 60*(opt_index-1)+10},
                        font     = CUSTOMIZE_SUB_FONT,
                        color    = Colors.BLACK,
                        text     = option.Name
                    }
                    view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][indent])
                    --for item, selection in pairs(option) do
                        if item ~= "Name" and item ~= "Image" and item ~= "Selected" then
                            indent = indent + 1
                                view.sub_group_items[tab_index][opt_index][3] = Image {
                                      position = {-70*(3-1), 60*(opt_index-1)},
                                      src      = "assets/Placement/NONE.png"
                                }
                                view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][3])

                                view.sub_group_items[tab_index][opt_index][2] = Image {
                                     position = {-70*(3-1), 60*(opt_index-1)},
                                     src      = "assets/CoverageX/bullshit.png"
                                }
                                view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][2])

                                
                            
                        end
                    --end
                    if opt_index > 13 then
                        view.sub_group_items[tab_index][opt_index][1].opacity = 0
                        view.sub_group_items[tab_index][opt_index][2].opacity = 0
                        view.sub_group_items[tab_index][opt_index][3].opacity = 0
                    end
                end

            end
            view.ui:add(view.sub_group[tab_index])
        end
            view.vert_lines[#view.menu_items+1] = Image {
                position = {300, 120*(#view.menu_items+1-1)},
                width    = 20,
                height   = 840-120*(#view.menu_items+1-1),
                tiled    = {false,true},
                src      = "assets/MenuLine.png"
            }
        --view:get_controller():init_shit()
        view.ui:add(unpack(view.menu_items))
        --fthis = view.hor_lines[1]
        view.ui:add(unpack(view.hor_lines))
        for i = 1,#view.hor_lines do
            view.ui:raise(view.hor_lines[i])
        end
        view.ui:add(unpack(view.vert_lines))
        --bg:lower_to_bottom()
        view.ui:lower(bg)
        view.ui:add(view.arrow)
        view.ui:add(view.food_name)
        view.ui:add(view.vert_sep)
        view.ui:add(view.back_arrow)
        view.ui:add(view.back_arrow_selected)
        view.ui:add(view.add_to_order)
        view.ui:add(view.hor_sep)
        view.ui:add(view.selector)
        view.ui:add(view.add_to_order_selector)
    end
    --view:Create_Menu_Items()
----------------------------------------------------------------------------


    function view:initialize()
        view:set_controller(CustomizeController(self))
        view.initialize = nil
    end

    function view:enter_sub_group()
        --view.menu_items[view:get_controller():get_selected_index()]:animate{duration=100, opacity = 100}
        --view.sub_group[view:get_controller():get_selected_index()]:animate{duration = 100, opacity = 255}
        model:set_active_component(Components.TAB)
        --print("entering sub group")

        self:get_model():notify()
    end

    function view:update()
        local controller = view:get_controller()
        local comp = model:get_active_component()
        --print("Active Component: "..comp)
        if comp == Components.CUSTOMIZE then
            print("Showing CustomizeView UI")
            view.ui.opacity = 255
            if controller.on_back_arrow then
                view.back_arrow_selected.opacity = 255
                view.selector.opacity = 0
                view.add_to_order_selector.opacity = 0
            elseif controller.add_to_order then
                print("addd to order")
                view.add_to_order_selector.opacity = 255
                view.back_arrow_selected.opacity = 0
                view.selector.opacity = 0
            else
                view.selector.opacity = 255
                view.back_arrow_selected.opacity = 0
                view.add_to_order_selector.opacity = 0
                for i,item in ipairs(view.menu_items) do
                    if i == controller:get_selected_index() then
                        --print("\t",i,"opacity to 255")
                        view.arrow.y = (i-1)*120
                        --item:animate{duration=100, opacity = 255}
                        --item.opacity = 255
                        view.sub_group[i]:animate{duration = 100, opacity = 255}
                        view.vert_lines[i].opacity = 0
                        view.selector.y = 120*(i-1)
                    else
                        --print("\t",i,"opacity to 0")
                        --item:animate{duration=100, opacity = 100}
                        view.sub_group[i]:animate{duration = 100, opacity = 0}
                        view.vert_lines[i].opacity = 255
                    end
                end
            end
        elseif comp == Components.TAB or comp == Components.CUSTOMIZE_ITEM then
            print("Greying CustomizeView UI")
            --view.ui.opacity = 100
            view.selector.opacity = 0
        else
            print("Hiding CustomizeView UI")
            view.ui.opacity = 0
        end
    end

   end)
