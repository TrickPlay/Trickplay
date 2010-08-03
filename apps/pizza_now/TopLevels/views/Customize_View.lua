CUSTOMIZE_SCROLL_THRESHOLD = 12
CUSTOMIZE_OPT_NAME = 1
CUSTOMIZE_OPT_COV = 2
CUSTOMIZE_OPT_PLACEMENT = 3

CustomizeView = Class(View, function(view, model, ...)
    view._base.init(view,model)
     
    view.ui=Group{name="Customize ui", position={0,0}, opacity=255}
    view.bg = Image{src = "assets/MenuBg.jpg", position={0,0}}
    view.bg2 = Clone{source=view.bg}
    view.bg2.position = {960,0}
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
        view.center_sep    = Image {
                position = {960, 0},
                width    = 20,
                height   = 960,
                tiled    = {false,true},
                src      = "assets/MenuLine.png"
            }
        view.nutrition   = Image {
                position = {960, 0},
                src      = "assets/NutritionMockup.png"
            }
        view.slice_lines = Image {
                position = {960, 500},
                src      = "assets/PizzaSliceLines_12.png"
            }
        if self:get_model().current_item_is_in_cart == false then
            view.back_arrow_text = Text {
                  position = {5, 750},
                  font     = CUSTOMIZE_TAB_FONT,
                  color    = Colors.BLACK,
                  text     = "Back"
                }
        else
            view.back_arrow_text = Text {
                  position = {5, 750},
                  font     = CUSTOMIZE_TAB_FONT,
                  color    = Colors.BLACK,
                  text     = "Remove"
                }
        end
        view.back_arrow = Image{                
                position = {5, 800},
                src      = "assets/BackArrowOutline.png"
            }
        view.back_arrow_selected = Image{                
                position = {5, 800},
                opacity  = 0,
                src      = "assets/BackArrowFilled.png"
            }
        if self:get_model().current_item_is_in_cart == false then
            view.add_to_order = Text{
                  position    = {155, 850},
                  font        = CUSTOMIZE_TAB_FONT,
                  color       = Colors.BLACK,
                  text        = "Add to Order"
                }
        else
            view.add_to_order = Text{
                  position    = {155, 850},
                  font        = CUSTOMIZE_TAB_FONT,
                  color       = Colors.BLACK,
                  text        = "Confirm Item"
                }
        end
        view.price = Text{
              position    = {800, 850},
              font        = CUSTOMIZE_TAB_FONT,
              color       = Colors.BLACK,
              text        = model.current_item.Price
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

        view.accordian_group = {}
        view.accordian_group_items = {}
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
            view.accordian_group[tab_index] = {}
            view.accordian_group_items[tab_index] = {}
            view.sub_group[tab_index] = Group{name="Tab "..tab_index.." sub-group",
                                                    position={500,80}, opacity=0}
            if tab.Options ~= nil then
                --view.accordian_group[tab_index][opt_index] = {}
                --view.accordian_group_items[tab_index][opt_index] = {}

                for opt_index,option in ipairs(tab.Options) do
                    if option.Radio then
                        view.sub_group_items[tab_index][opt_index] = {}
                        view.sub_group_items[tab_index][opt_index][1] = Text {
                            position = {0, 60*(opt_index-1)+10},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = option.Name
                        }
                        view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][1])
                        view.sub_group_items[tab_index][opt_index][2] = {}

                        view.accordian_group_items[tab_index][opt_index] = {}
                        view.accordian_group[tab_index][opt_index] = Group{
                                name = option.Name.." accordian",
                            position = {120, 60*(opt_index)+10},
                             opacity = 0
                        }
                        local acc_index = 1
                        local acc_adjust = 0                        
                        for item,curr_selection in pairs(option) do
                            if item ~= "Name" and item ~= "Image" and item ~= "Selected" 
                               and item ~= "Radio" and item ~= "ToppingGroup" then
                                view.accordian_group_items[tab_index][opt_index][acc_index] = {}
                                local radio_index = 1  
                                view.accordian_group[tab_index][opt_index]:add(Text{
                                          position = {0, --[[60*(radio_index-1)+]]acc_adjust},
                                          font     = CUSTOMIZE_SUB_FONT,
                                          color    = Colors.BLACK,
                                          text     = item..":"
                                })
                                acc_adjust = acc_adjust+50
                                for r=1,#All_Options[item.."_r"] do
                                    view.accordian_group_items[tab_index][opt_index][acc_index][radio_index]={}
                                    view.accordian_group_items[tab_index][opt_index][acc_index][radio_index][1] = Text {
                                          position = {60, --[[60*(radio_index-1)+]]acc_adjust},
                                          font     = CUSTOMIZE_SUB_FONT,
                                          color    = Colors.BLACK,
                                          text     = All_Options[item.."_r"][r]
                                    }
                                    if r == curr_selection then
                                        view.accordian_group_items[tab_index][opt_index][acc_index][radio_index][2] = Image {
                                          position = {0, --[[60*(radio_index-1)+]]acc_adjust-15},
                                          src      = "assets/RadioOn.png"
                                        }
                                    else
                                        view.accordian_group_items[tab_index][opt_index][acc_index][radio_index][2] = Image {
                                          position = {0,--[[ 60*(radio_index-1)+]]acc_adjust-15},
                                          src      = "assets/RadioOff.png"
                                        }
                                    end
                                    view.accordian_group[tab_index][opt_index]:add(view.accordian_group_items[tab_index][opt_index][acc_index][radio_index][1])
                                    view.accordian_group[tab_index][opt_index]:add(view.accordian_group_items[tab_index][opt_index][acc_index][radio_index][2])
                                    radio_index = radio_index + 1
                                    acc_adjust = acc_adjust+50

                                end
                               -- acc_adjust = acc_adjust +radio_index*60
                                acc_index = acc_index + 1

                            end
                        end
--[[
                        --radio_index = radio_index + 1
                                --acc_adjust = acc_adjust+60
                        view.accordian_group_items[tab_index][opt_index][acc_index]={}
                        view.accordian_group_items[tab_index][opt_index][acc_index][1]={}
                        view.accordian_group_items[tab_index][opt_index][acc_index][1][1] = Text {
                                          position = {0, --[=[60*(radio_index-1)+]=]acc_adjust},
                                          font     = CUSTOMIZE_SUB_FONT_SP,
                                          color    = Colors.BLACK,
                                          text     = "Continue"
                                    }
                        --acc_adjust = acc_adjust +radio_index*60
                        view.accordian_group[tab_index][opt_index]:add(view.accordian_group_items[tab_index][opt_index][acc_index][1][1])--]]

                        view.sub_group[tab_index]:add(view.accordian_group[tab_index][opt_index])
                                    --acc_adjust = acc_adjust+60

                        option.Selected = function()
                            if opt_index < #tab.Options then
                                for i=opt_index+1,#tab.Options do
                                    view.sub_group_items[tab_index][i][1].y = view.sub_group_items[tab_index][i][1].y + acc_adjust
                                end
                            end
                            view.accordian_group[tab_index][opt_index].opacity = 255
                            self:get_model():set_active_component(Components.ACCORDIAN)
                            self:get_model():get_active_controller():init_shit(view.accordian_group_items[tab_index][opt_index],tab_index,opt_index,option,view.accordian_group[tab_index][opt_index])

                            self:get_model():notify()

                            --model.accordian
                            --init accordian
                        end
                --[[        option.UnSelected = function()
                            print("\n\nunselecting")
                            if opt_index < #tab.Options then
                                for i=opt_index+1,#tab.Options do
                                    view.sub_group_items[tab_index][i][1].y = view.sub_group_items[tab_index][i][1].y - acc_adjust
                                end
                            end
                            view.accordian_group[tab_index][opt_index].opacity = 0
                            model:set_active_component(Components.TAB)
                            self:get_model():notify()

                        end--]]
                    else
                        local indent = 1
                        view.sub_group_items[tab_index][opt_index] = {}
                        view.sub_group_items[tab_index][opt_index][1] = Text {
                            position = {0, 60*(opt_index-1)+10},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = option.Name
                        }
                        view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][indent])
                        --if item ~= "Name" and item ~= "Image" and item ~= "Selected" 
                        --                  and item ~= "ToppingGroup" then
                            indent = indent + 1
                            if option.Placement ~= nil then
                                view.sub_group_items[tab_index][opt_index][3] = Image {
                                      position = {-70*(3-1), 60*(opt_index-1)},
                                      src      = "assets/Placement/"..
                                       All_Options.Placement_r[option.Placement]..".png"
                                }
                                view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][3])
                                view.sub_group_items[tab_index][opt_index][2] = Image {
                                     position = {-70*(2-1), 60*(opt_index-1)},
                                     src      = "assets/CoverageX/"..
                                      All_Options.CoverageX_r[option.CoverageX]..".png"
                                }
                                view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][2])                            
                                if opt_index > CUSTOMIZE_SCROLL_THRESHOLD then
                                    assert(option.Placement ~= nil,"shit "..option.Name)
                                    view.sub_group_items[tab_index][opt_index][1].opacity = 0
                                    view.sub_group_items[tab_index][opt_index][2].opacity = 0
                                    view.sub_group_items[tab_index][opt_index][3].opacity = 0
                                end
                            end
                        --end
                    

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
        view.up_arrow = Image{
            position = {850, 60*(1-1)- 25+view.sub_group[1].y},
                 src = "assets/UpScrollArrow.png"
            }
        view.ui:add(view.up_arrow)
        view.down_arrow = Image{
            position = {850,60*(CUSTOMIZE_SCROLL_THRESHOLD-0)+5+view.sub_group[1].y},
                 src = "assets/DownScrollArrow.png"
             }
        view.ui:add(view.down_arrow)
        view.ui:add(Image{
            position = {view.sub_group[1].x-70*(3-1)-20,0},
                 src = "assets/PizzaLR.png"
            })
 

        --bg:lower_to_bottom()
        view.ui:lower(view.bg)
        view.ui:add(view.arrow)
        view.ui:add(view.price)
        view.ui:add(view.food_name)
        view.ui:add(view.vert_sep)
        view.ui:add(view.center_sep)
        view.ui:add(view.nutrition)
        view.ui:add(view.back_arrow)
        view.ui:add(view.back_arrow_text)
        view.ui:add(view.back_arrow_selected)
        view.ui:add(view.add_to_order)
        view.ui:add(view.hor_sep)
        view.ui:add(view.selector)
        view.ui:add(view.add_to_order_selector)
        view.ui:add(model.current_item.pizzagroup)
        model.current_item.pizzagroup:show_all()
        view.ui:add(view.slice_lines)
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
                        if #view.sub_group_items[i] > 
                            CUSTOMIZE_SCROLL_THRESHOLD then
 
                            view.up_arrow.opacity = 255
                            view.down_arrow.opacity = 255
                        else
                            view.up_arrow.opacity = 0
                            view.down_arrow.opacity = 0
                        end
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
        elseif comp == Components.TAB or comp == Components.CUSTOMIZE_ITEM or
               comp == Components.ACCORDIAN then
            print("Greying CustomizeView UI")
            --view.ui.opacity = 100
            view.selector.opacity = 0
        else
            print("Hiding CustomizeView UI")
            view.ui.opacity = 0
        end
    end

   end)
