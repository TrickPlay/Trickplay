CUSTOMIZE_SCROLL_THRESHOLD = 12
CUSTOMIZE_OPT_NAME = 1
CUSTOMIZE_OPT_COV = 2
CUSTOMIZE_OPT_PLACEMENT = 3

CustomizeView = Class(View, function(view, model, ...)
    view._base.init(view,model)
    view.first_tab_groups = {}

    view.ingredientbox_right = {}
    view.ingredientbox_left  = {}
    view.ingredientbox_top   = ""
 
    view.ingredient_top_text   = Text{
        position = {1000,70},
        text     = ""
    }
    view.ingredient_left_text  = Text{
        position = {1000,140},
        text     = ""
    }
    view.ingredient_right_text = Text{
        position = {1500,140},
        text     = ""
    }


    view.images = {}
    view.preloaded_images=Group{name="preloaded",opacity=0}
    screen:add(view.preloaded_images)
    function view:pre_loader()
        view.images.bg = Image{src = "assets/MenuBg.jpg", position={0,0}}
view.preloaded_images:add(view.images.bg)
        view.images.vert_sep    = Image {
            width    = 20,
            height   = 960,
            tiled    = {false,true},
            src      = "assets/MenuLine.png"
        }
view.preloaded_images:add(view.images.vert_sep)
        view.images.hor_sep = Image{
            scale    = {1,1.5},
            tiled    = {true,false},
            width    = 400,
            src      = "assets/MenuHorzLine.png"
        }
view.preloaded_images:add(view.images.hor_sep)
        view.images.nutrition   = Image {
            position = {960, 0},
            src      = "assets/IngredientsBox.png"
        }
view.preloaded_images:add(view.images.nutrition)
        view.images.slice_lines = Image {
            position = {960, 480},
            src      = "assets/PizzaSliceLines_12.png"
        }
view.preloaded_images:add(view.images.slice_lines)
--[[
        view.images.selector = Image {
            width     = 150,
            height    = (960/#model.current_item.Tabs),
            scale     = {false,true},
            src       = "assets/TabFocus_small.png"
        }
--]]
        view.images.hor_line = Image {
            --scale    = {1,1.5},
            src      = "assets/MenuHorzLine.png"
        }
view.preloaded_images:add(view.images.hor_line)
--[[
        view.images.vert_line = Image {
            width    = 20,
            height   = 960/#model.current_item.Tabs,
            tiled    = {false,true},
            src      = "assets/MenuLine.png"
        }
--]]
        view.images.rad_on = Image {
            src      = "assets/RadioOn.png"
        }
view.preloaded_images:add(view.images.rad_on)
        view.images.rad_off = Image {
            src      = "assets/RadioOff.png"
        }
view.preloaded_images:add(view.images.rad_off)
        view.images.covx={}
        for i=1,#All_Options["CoverageX_r"] do
            view.images.covx[i] = Image{
                src      = "assets/CoverageX/"..All_Options["CoverageX_r"][i]..".png"
            }
        end
view.preloaded_images:add(unpack(view.images.covx))
        view.images.place={}
        for i=1,#All_Options["Placement_r"] do
            view.images.place[i] = Image{
                 src      = "assets/Placement/"..All_Options["Placement_r"][i]..".png"
            }
        end
view.preloaded_images:add(unpack(view.images.place))
        view.images.crust4 = Image{
            src      = "assets/CrustSelect4.png"
        }
view.preloaded_images:add(view.images.crust4)
        view.images.crust3 = Image{
            src      = "assets/CrustSelect3.png"
        }
view.preloaded_images:add(view.images.crust3)
        view.images.crustS = Image{
            src      = "assets/CrustSelectSize.png"
        }
view.preloaded_images:add(view.images.crustS)
        view.images.up_arrow = Image{
            src      = "assets/UpScrollArrow.png"
        }
view.preloaded_images:add(view.images.up_arrow)
        view.images.down_arrow = Image{
            src      = "assets/DownScrollArrow.png"
        }
view.preloaded_images:add(view.images.down_arrow)
        view.images.pzzaLR = Image{
            src      = "assets/PizzaLR.png"
        }
view.preloaded_images:add(view.images.pzzaLR)
        view.images.size = {}
        view.images.sizefocus = {}
        for i=1,#All_Options["Size_r"] do
            view.images.size[i] = Image{
                src      = "assets/Size"..All_Options["Size_r"][i]..".png"
            }
            view.images.sizefocus[i] = Image{
                opacity  = 0,
                src      = "assets/Size"..All_Options["Size_r"][i].."Focus.png"
            }
        end
        view.preloaded_images:add(unpack(view.images.size))
        view.preloaded_images:add(unpack(view.images.sizefocus))

    end
    view:pre_loader()

     
    view.ui=Group{name="Customize ui", position={0,0}, opacity=255}
    --view.bg = Image{src = "assets/MenuBg.jpg", position={0,0}}
    view.bg = Clone{source=view.images.bg}
    view.bg.position = {0,0}
    view.ui:add(bg)
   -- view.ui:add(bg2)
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

        view.ingredientbox_right = {}
        view.ingredientbox_left  = {}
        view.ingredientbox_top   = ""

    
        --gut the UI
        view.ui:clear()
        view.ui:add(view.bg)

        view.ingredient_top_text   = Text{
            position = {1080,70},
              font        = CUSTOMIZE_SUB_FONT_B,

            text     = ""
        }
        view.ingredient_left_text  = Text{
            position = {1100,200},
              font        = CUSTOMIZE_SUB_FONT,

            text     = ""
        }
        view.ingredient_right_text = Text{
            position = {1450,200},
              font        = CUSTOMIZE_SUB_FONT,

            text     = ""
        }

        --view.ui:add(view.bg2)
--[[
        view.arrow = Image{                
                position = {300, 0},
                src      = "assets/SubmenuArrow.png"
            }
--]]
        view.food_name = Text {
              position = {140, 20},
              font     = CUSTOMIZE_NAME_FONT,
              color    = Colors.BLACK,
            z_rotation = {90,0,0},
              text     = model.current_item.Name
           }
--[[
        view.vert_sep    = Image {
                position = {150, 0},
                width    = 20,
                height   = 960,
                tiled    = {false,true},
                src      = "assets/MenuLine.png"
            }
--]]
        view.vert_sep = Clone{source=view.images.vert_sep}
        view.vert_sep.position = {150,0}
--[[
        view.nutrition   = Image {
                position = {960, 0},
                src      = "assets/IngredientsBox.png"
            }
--]]
        view.nutrition = Clone{source=view.images.nutrition}
        view.nutrition.position = {960,0}
--[[
        view.slice_lines = Image {
                position = {960, 480},
                src      = "assets/PizzaSliceLines_12.png"
            }
--]]
        view.slice_lines = Clone{source=view.images.slice_lines}
        view.slice_lines.position = {960,480}

        view.price = Text{
              position    = {1630, 70},
              font        = CUSTOMIZE_TAB_FONT,
              color       = Colors.BLACK,
              text        = model.current_item:PriceString()
            }
---[[
        view.selector = Image {
                position  = {150, 0},
                width     = 150,
                height    = (960/#model.current_item.Tabs),
                scale     = {false,true},
                src       = "assets/TabFocus_small.png"
            }
--]]
--[[
        view.selector = Clone{source=view.images.selector}
        view.selector.position = {150,0}
--]]
        fffthis = view.selector
        view.ui.opacity = 255

        view.accordian_group = {}
        view.accordian_group_items = {}
        view.first_tab_groups = {}
        for tab_index,tab in ipairs(model.current_item.Tabs) do

            --check to see if there is an item selected
            assert(model.current_item,"no item selected for Customization")
    
            --build the customization menu
            view.menu_items[tab_index] = Text {
                position = {155, 960*(tab_index-1)/#model.current_item.Tabs+30},
                font     = CUSTOMIZE_SUB_FONT,
                color    = Colors.BLACK,
                text     = tab.Tab_Text
            }
--[[
            view.hor_lines[tab_index] = Image {
                position = {150, 960*(tab_index/#model.current_item.Tabs)},
                --position = {150, 120*(tab_index-1)+120},
                scale    = {1,1.5},
                src      = "assets/MenuHorzLine.png"
            }
--]]
---[[
            view.hor_lines[tab_index] = Clone{source=view.images.hor_line}
            view.hor_lines[tab_index].position = {150, 960*(tab_index/#model.current_item.Tabs)}
            view.hor_lines[tab_index].scale = {1,1.5}
            --view.hor_lines[tab_index].opacity = 255
--]]
---[[
            view.vert_lines[tab_index] = Image {
                position = {300, 960*(tab_index-1)/#model.current_item.Tabs},
                width    = 20,
                height   = 960/#model.current_item.Tabs,
                tiled    = {false,true},
                src      = "assets/MenuLine.png"
            }
--]]
--[[
            view.vert_lines[tab_index] = Clone{source=view.images.vert_line}
            view.vert_lines[tab_index].position = {}
--]]
            view.sub_group_items[tab_index] = {}
            view.accordian_group[tab_index] = {}
            view.accordian_group_items[tab_index] = {}
            view.sub_group[tab_index] = Group{name="Tab "..tab_index.." sub-group",
                                                    position={500,100}, opacity=0}
            
            --the crust cheese and sauce page
            if tab.Radio == true then
                --and everything is hardcoded.....
                view.first_tab_groups[1] = {}
                view.first_tab_groups[2] = {}
                view.first_tab_groups[3] = {}

                
                --Cheese is on the top
                -----------------------
                view.sub_group[tab_index]:add(Text {
                            position = {-180, -80},
                            font     = CUSTOMIZE_SUB_FONT_B,
                            color    = Colors.BLACK,
                            text     = "Cheese:"
                })
--[[
                view.sub_group[tab_index]:add(Image{
                    position = {-40, -60},
                    scale    = {1,1.5},
                    tiled    = {true,false},
                    width    = 400,
                    src      = "assets/MenuHorzLine.png"
                })
--]]
                local temp = Clone{source=view.images.hor_sep}
                temp.position = {-40,-60}
                view.sub_group[tab_index]:add(temp)

                --Cheese Placement
                view.first_tab_groups[1][1] = {}
                view.first_tab_groups[1][1][-2] = Text{
                            position = {-160, -40},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = "Placement:"
                }
                view.sub_group[tab_index]:add(view.first_tab_groups[1][1][-2])
--[[
                view.first_tab_groups[1][1][-1] = Image{
                            position = {-160, 0},
                            src      = "assets/CrustSelect4.png"
                }
--]]
                view.first_tab_groups[1][1][-1] = Clone{source=view.images.crust4}
                view.first_tab_groups[1][1][-1].position = {-160,0}

                view.sub_group[tab_index]:add(view.first_tab_groups[1][1][-1])
                for i=1,#All_Options["Placement_r"] do
                    view.first_tab_groups[1][1][i] ={}
                    view.first_tab_groups[1][1][i][1] = Text{
                            position = {10, 45*(i-1)},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = All_Options["Placement_r"][i]
                    }
--[[
                    view.sub_group[tab_index]:add(Image{
                        position = {-60, 45*(i-1)-15},
                        src      = "assets/Placement/"..All_Options["Placement_r"][i]..".png"
                    })
--]]
                    print(i)
                    temp=Clone{source=view.images.place[i]}
                    temp.position = {-60, 45*(i-1)-15}
                    view.sub_group[tab_index]:add(view.first_tab_groups[1][1][i][1])
--[[
                    view.first_tab_groups[1][1][i][2] = Image {
                        position = {-120, 45*(i-1)-15},
                        src      = "assets/RadioOn.png"
                    }
--]]
                    view.first_tab_groups[1][1][i][2] = Clone{source=view.images.rad_on}
                    view.first_tab_groups[1][1][i][2].position = {-120, 45*(i-1)-15}
--[[
                    view.first_tab_groups[1][1][i][3] = Image {
                        position = {-120,45*(i-1)-15},
                        src      = "assets/RadioOff.png"
                    }
--]]
                    view.first_tab_groups[1][1][i][3] = Clone{source=view.images.rad_off}
                    view.first_tab_groups[1][1][i][3].position = {-120,45*(i-1)-15}
                    if i == tab.Options[1].Placement then
                        view.first_tab_groups[1][1][i][2].opacity = 255
                        view.first_tab_groups[1][1][i][3].opacity = 0
                    else
                        view.first_tab_groups[1][1][i][2].opacity = 0
                        view.first_tab_groups[1][1][i][3].opacity = 255
                    end
                    view.sub_group[tab_index]:add(view.first_tab_groups[1][1][i][2])
                    view.sub_group[tab_index]:add(view.first_tab_groups[1][1][i][3])
                end
                --Cheese Coverage
                view.first_tab_groups[1][2] = {}
                view.first_tab_groups[1][2][-2] = Text{
                            position = {200, -40},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = "Coverage:"
                }
                view.sub_group[tab_index]:add(view.first_tab_groups[1][2][-2])
--[[
                view.first_tab_groups[1][2][-1] = Image{
                            position = {200, 0},
                            src      = "assets/CrustSelect4.png"
                }
--]]
                view.first_tab_groups[1][2][-1]=Clone{source=view.images.crust3}
                view.first_tab_groups[1][2][-1].position={200,0}
                view.sub_group[tab_index]:add(view.first_tab_groups[1][2][-1])
                for i=1,#All_Options["CoverageX_r"]-1 do
                    view.first_tab_groups[1][2][i] ={} 
--[[
                    view.sub_group[tab_index]:add(Image{
                        position = {300, 45*(i-1)-15},
                        src      = "assets/CoverageX/"..All_Options["CoverageX_r"][i+1]..".png"
                    })
--]]
                    temp = Clone{source=view.images.covx[i+1]}
                    temp.position = {300, 45*(i-1)-15}
                    view.first_tab_groups[1][2][i][1] = Text{
                            position = {370, 45*(i-1)},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = All_Options["CoverageX_r"][i+1]
                    }
                    view.sub_group[tab_index]:add(view.first_tab_groups[1][2][i][1])
--[[
                    view.first_tab_groups[1][2][i][2] = Image {
                        position = {240, 45*(i-1)-15},
                        src      = "assets/RadioOn.png"
                    }
--]]
                    view.first_tab_groups[1][2][i][2] = Clone{source=view.images.rad_on}
                    view.first_tab_groups[1][2][i][2].position = {240, 45*(i-1)-15}
--[[
                    view.first_tab_groups[1][2][i][3] = Image {
                        position = {240, 45*(i-1)-15},
                        src      = "assets/RadioOff.png"
                    }
--]]
                    view.first_tab_groups[1][2][i][3] = Clone{source=view.images.rad_off}
                    view.first_tab_groups[1][2][i][3].position = {240, 45*(i-1)-15}

                    if i == tab.Options[1].CoverageX-1 then
                        view.first_tab_groups[1][2][i][2].opacity = 255
                        view.first_tab_groups[1][2][i][3].opacity = 0
                    else
                        view.first_tab_groups[1][2][i][2].opacity = 0
                        view.first_tab_groups[1][2][i][3].opacity = 255
                    end
                    view.sub_group[tab_index]:add(view.first_tab_groups[1][2][i][2])
                    view.sub_group[tab_index]:add(view.first_tab_groups[1][2][i][3])
                end


                --Crust and Size are in the middle
                ----------------------------------
                view.sub_group[tab_index]:add(Text {
                            position = {-180, 180},
                            font     = CUSTOMIZE_SUB_FONT_B,
                            color    = Colors.BLACK,
                            text     = "Crust:"
                })
--[[
                view.sub_group[tab_index]:add(Image{
                    position = {-40, 200},
                    scale    = {1,1.5},
                    tiled    = {true,false},
                    width    = 400,
                    src      = "assets/MenuHorzLine.png"
                })
--]]
                temp = Clone{source=view.images.hor_sep}
                temp.position = {-40,200}
                view.sub_group[tab_index]:add(temp)
                --Crust Style
                view.first_tab_groups[2][1] = {}
                view.first_tab_groups[2][1][-2] = Text{
                            position = {-160, 220},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = "Styles:"
                }
                view.sub_group[tab_index]:add(view.first_tab_groups[2][1][-2])
--[[
                view.first_tab_groups[2][1][-1] = Image{
                            position = {-160, 265},
                            src      = "assets/CrustSelect4.png"
                }
--]]
                view.first_tab_groups[2][1][-1] = Clone{source=view.images.crust4}
                view.first_tab_groups[2][1][-1].position={-160,265}
                view.sub_group[tab_index]:add(view.first_tab_groups[2][1][-1])
                for i=1,#All_Options["Crust_Style_r"] do
                    view.first_tab_groups[2][1][i] ={}
                    view.first_tab_groups[2][1][i][1] = Text{
                            position = {-60, 45*(i-1)+265},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = All_Options["Crust_Style_r"][i]
                    }
                    view.sub_group[tab_index]:add(view.first_tab_groups[2][1][i][1])
--[[
                    view.first_tab_groups[2][1][i][2] = Image {
                        position = {-120, 45*(i-1)+250},
                        src      = "assets/RadioOn.png"
                    }
--]]
                    view.first_tab_groups[2][1][i][2] = Clone{source=view.images.rad_on}
                    view.first_tab_groups[2][1][i][2].position = {-120, 45*(i-1)+250}
--[[
                    view.first_tab_groups[2][1][i][3] = Image {
                        position = {-120,45*(i-1)+250},
                        src      = "assets/RadioOff.png"
                    }
--]]
                    view.first_tab_groups[2][1][i][3] = Clone{source=view.images.rad_off}
                    view.first_tab_groups[2][1][i][3].position = {-120, 45*(i-1)+250}

                    if i == tab.Options[3].Crust_Style then
                        view.first_tab_groups[2][1][i][2].opacity = 255
                        view.first_tab_groups[2][1][i][3].opacity = 0
                    else
                        view.first_tab_groups[2][1][i][2].opacity = 0
                        view.first_tab_groups[2][1][i][3].opacity = 255
                    end
                    view.sub_group[tab_index]:add(view.first_tab_groups[2][1][i][2])
                    view.sub_group[tab_index]:add(view.first_tab_groups[2][1][i][3])
                end
                --Size
                view.first_tab_groups[2][2] = {}
                view.first_tab_groups[2][2][-2] = Text{
                            position = {200, 220},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = "Available Size:"
                }
                view.sub_group[tab_index]:add(view.first_tab_groups[2][2][-2])
--[[
                view.first_tab_groups[2][2][-1] = Image{
                            position = {200, 265},
                            src      = "assets/CrustSelectSize.png"
                }
--]]
                view.first_tab_groups[2][2][-1] = Clone{source=view.images.crustS}
                view.first_tab_groups[2][2][-1].position = {200, 265}
                view.sub_group[tab_index]:add(view.first_tab_groups[2][2][-1])
                local retarded = {0,80,180,300}
                local half_retarded = {40-30,50-30,60-30,70-30}
                for i=1,#All_Options["Size_r"] do
                    view.first_tab_groups[2][2][i] ={}
                    --print(80*(i-1)+20*((i-1)/2))
--[[
                    view.first_tab_groups[2][2][i][1] = Image{
                            position = {300, retarded[i]+265 + 10*(i-1)},
                            src      = "assets/Size"..All_Options["Size_r"][i]..".png"
                    }
--]]
                    view.first_tab_groups[2][2][i][1] = Clone{source=view.images.size[i]}
                    view.first_tab_groups[2][2][i][1].position = {300, retarded[i]+265 + 10*(i-1)}
--[[
                    view.first_tab_groups[2][2][i][4] = Image{
                            position = {300, retarded[i]+265 + 10*(i-1)},
                            opacity  = 0,
                            src      = "assets/Size"..All_Options["Size_r"][i].."Focus.png"
                    }
--]]
                    view.first_tab_groups[2][2][i][4] = Clone{source=view.images.sizefocus[i]}
                    view.first_tab_groups[2][2][i][4].position = {300, retarded[i]+265 + 10*(i-1)}
                    view.sub_group[tab_index]:add(view.first_tab_groups[2][2][i][4])
                    view.sub_group[tab_index]:add(view.first_tab_groups[2][2][i][1])
--[[
                    view.first_tab_groups[2][2][i][2] = Image {
                        position = {240, half_retarded[i]+retarded[i]+265+ 10*(i-1)},
                        src      = "assets/RadioOn.png"
                    }
--]]
                    view.first_tab_groups[2][2][i][2] = Clone{source=view.images.rad_on}
                    view.first_tab_groups[2][2][i][2].position = {240, half_retarded[i]+retarded[i]+265+ 10*(i-1)}
--[[
                    view.first_tab_groups[2][2][i][3] = Image {
                        position = {240, half_retarded[i]+retarded[i]+265+ 10*(i-1)},
                        src      = "assets/RadioOff.png"
                    }
--]]
                    view.first_tab_groups[2][2][i][3] = Clone{source=view.images.rad_off}
                    view.first_tab_groups[2][2][i][3].position = {240, half_retarded[i]+retarded[i]+265+ 10*(i-1)}

                    if i == tab.Options[4].Size then
                        view.first_tab_groups[2][2][i][2].opacity = 255
                        view.first_tab_groups[2][2][i][3].opacity = 0
                    else
                        view.first_tab_groups[2][2][i][2].opacity = 0
                        view.first_tab_groups[2][2][i][3].opacity = 255
                    end
                    view.sub_group[tab_index]:add(view.first_tab_groups[2][2][i][2])
                    view.sub_group[tab_index]:add(view.first_tab_groups[2][2][i][3])
                end

               


                --Sauce is bottom left
                ----------------------------------
                view.first_tab_groups[3][1] = {}

                view.first_tab_groups[3][1][-2]=Text {
                            position = {-160, 500},
                            font     = CUSTOMIZE_SUB_FONT_B,
                            color    = Colors.BLACK,
                            text     = "Sauce:"
                }
                view.sub_group[tab_index]:add(view.first_tab_groups[3][1][-2])
--[[
                view.first_tab_groups[3][1][-1] = Image{
                            position = {-160, 540},
                            src      = "assets/CrustSelect4.png"
                }
--]]
                view.first_tab_groups[3][1][-1] = Clone{source=view.images.crust4}
                view.first_tab_groups[3][1][-1].position = {-160, 540}

                view.sub_group[tab_index]:add(view.first_tab_groups[3][1][-1])
                for i=1,#All_Options["Sauce_Type_r"] do
                    view.first_tab_groups[3][1][i] ={}
                    view.first_tab_groups[3][1][i][1] = Text{
                            position = {-60, 45*(i-1)+535},
                            font     = CUSTOMIZE_SUB_FONT,
                            color    = Colors.BLACK,
                            text     = All_Options["Sauce_Type_r"][i]
                    }
                    view.sub_group[tab_index]:add(view.first_tab_groups[3][1][i][1])
--[[
                    view.first_tab_groups[3][1][i][2] = Image {
                        position = {-120,45*(i-1)+520},
                        src      = "assets/RadioOn.png"
                    }
--]]
                    view.first_tab_groups[3][1][i][2] = Clone{source=view.images.rad_on}
                    view.first_tab_groups[3][1][i][2].position = {-120,45*(i-1)+520}
--[[
                    view.first_tab_groups[3][1][i][3] = Image {
                        position = {-120,45*(i-1)+520},
                        src      = "assets/RadioOff.png"
                    }
--]]
                    view.first_tab_groups[3][1][i][3] = Clone{source=view.images.rad_off}
                    view.first_tab_groups[3][1][i][3].position = {-120,45*(i-1)+520}


                    if i == tab.Options[2].Sauce_Type then
                        view.first_tab_groups[3][1][i][2].opacity = 255
                        view.first_tab_groups[3][1][i][3].opacity = 0
                    else
                        view.first_tab_groups[3][1][i][2].opacity = 0
                        view.first_tab_groups[3][1][i][3].opacity = 255
                    end
                    view.sub_group[tab_index]:add(view.first_tab_groups[3][1][i][2])
                    view.sub_group[tab_index]:add(view.first_tab_groups[3][1][i][3])

                end
                view.ingredientbox_top = All_Options.Size_r[model.current_item.Tabs[1].Options[4].Size].." "..
                                         All_Options.Crust_Style_r[model.current_item.Tabs[1].Options[3].Crust_Style].." "..
                                         model.current_item.Name                  

            --the Topping pages
            elseif tab.Options ~= nil then
                --view.accordian_group[tab_index][opt_index] = {}
                --view.accordian_group_items[tab_index][opt_index] = {}

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
                        --if item ~= "Name" and item ~= "Image" and item ~= "Selected" 
                        --                  and item ~= "ToppingGroup" then
                            indent = indent + 1
                            if option.Placement ~= nil then
                                view.sub_group_items[tab_index][opt_index][4] = TextBox(-70*(3-1)-10, 
                                                                                         60*(opt_index-1),
                                                                                         70*(3-1))
                                view.sub_group_items[tab_index][opt_index][4].opacity = 255
                                view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][4].group)
--[[
                                view.sub_group_items[tab_index][opt_index][3] = Image {
                                      position = {-70*(3-1), 60*(opt_index-1)},
                                      src      = "assets/Placement/"..
                                       All_Options.Placement_r[option.Placement]..".png"
                                }
--]]
                                view.sub_group_items[tab_index][opt_index][3] = Clone{source=view.images.place[i]}
                                view.sub_group_items[tab_index][opt_index][3].position = {-70*(3-1), 60*(opt_index-1)}

                                if option.Placement == All_Options.Placement.Entire or
                                   option.Placement == All_Options.Placement.Left then
                                    view.ingredientbox_left[#view.ingredientbox_left+1] = option.Name
                                end
                                if option.Placement == All_Options.Placement.Entire or
                                   option.Placement == All_Options.Placement.Right then
                                    view.ingredientbox_right[#view.ingredientbox_right+1] = option.Name
                                end
 
                                view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][3])
--[[
                                view.sub_group_items[tab_index][opt_index][2] = Image {
                                     position = {-70*(2-1), 60*(opt_index-1)},
                                     src      = "assets/CoverageX/"..
                                      All_Options.CoverageX_r[option.CoverageX]..".png"
                                }
-]]
                                view.sub_group_items[tab_index][opt_index][2] = Clone{source=view.images.covx[i]}
                                view.sub_group_items[tab_index][opt_index][2].position = {-70*(2-1), 60*(opt_index-1)}

                                view.sub_group[tab_index]:add(view.sub_group_items[tab_index][opt_index][2])
                            
                                if opt_index > CUSTOMIZE_SCROLL_THRESHOLD then
                                    assert(option.Placement ~= nil,"shit "..option.Name)
                                    view.sub_group_items[tab_index][opt_index][1].opacity = 0
                                    view.sub_group_items[tab_index][opt_index][2].opacity = 0
                                    view.sub_group_items[tab_index][opt_index][3].opacity = 0
                                    view.sub_group_items[tab_index][opt_index][4].group.opacity = 0
                                end
                            end
                        --end
                    

                    
                end

            end 
            view.ui:add(view.sub_group[tab_index])
        end
--[[
            view.vert_lines[#view.menu_items+1] = Image {
                position = {300, 120*(#view.menu_items+1-1)},
                width    = 20,
                height   = 960-120*(#view.menu_items+1-1),
                tiled    = {false,true},
                src      = "assets/MenuLine.png"
            }
--]]
        --view:get_controller():init_shit()
        view.ui:add(unpack(view.menu_items))
        --fthis = view.hor_lines[1]
        view.ui:add(unpack(view.hor_lines))
        for i = 1,#view.hor_lines do
            view.ui:raise(view.hor_lines[i])
        end
        view.ui:add(unpack(view.vert_lines))
--[[
        view.up_arrow = Image{
            position = {850, 60*(1-1)- 25+view.sub_group[1].y},
                 src = "assets/UpScrollArrow.png"
            }
--]]
        view.up_arrow = Clone{source=view.images.up_arrow}
        view.up_arrow.position = {850, 60*(1-1)- 25+view.sub_group[1].y}
        view.ui:add(view.up_arrow)
--[[
        view.down_arrow = Image{
            position = {850,60*(CUSTOMIZE_SCROLL_THRESHOLD-0)+5+view.sub_group[1].y},
                 src = "assets/DownScrollArrow.png"
             }
--]]
        view.down_arrow = Clone{source=view.images.down_arrow}
        view.down_arrow.position = {850,60*(CUSTOMIZE_SCROLL_THRESHOLD-0)+5+view.sub_group[1].y}

        view.ui:add(view.down_arrow)
--[[
        view.pzzaLR = Image{
            position = {view.sub_group[1].x-70*(3-1)-20,0},
                 src = "assets/PizzaLR.png"
            }
--]]
        view.pzzaLR = Clone{source=view.images.pzzaLR}
        view.pzzaLR.position = {view.sub_group[1].x-70*(3-1)-20,0}
        view.ui:add(view.pzzaLR)
 
        view.rebuild_ingredient_box()    
        view.ui:add(view.ingredient_top_text)
        view.ui:add(view.ingredient_left_text)
        view.ui:add(view.ingredient_right_text)


        --bg:lower_to_bottom()
        view.ui:lower(view.bg)
--        view.ui:add(view.arrow)
        view.ui:add(view.price)
        view.ui:add(view.food_name)
        view.ui:add(view.vert_sep)
       -- view.ui:add(view.center_sep)
        view.ui:add(view.nutrition)
        --view.ui:add(view.back_arrow)
        --view.ui:add(view.back_arrow_text)
        --view.ui:add(view.back_arrow_selected)
        --view.ui:add(view.add_to_order)
        --view.ui:add(view.hor_sep)
        view.ui:add(view.selector)
        --view.ui:add(view.add_to_order_selector)
        view.ui:add(model.current_item.pizzagroup)
        model.current_item.pizzagroup:show_all()
        view.ui:add(view.slice_lines)
        view.vert_sep:raise_to_top()
        for i=1,#view.menu_items do
            view.menu_items[i]:raise_to_top()
            view.hor_lines[i]:raise_to_top()
        end
        assert(view:get_controller().conches,"shit")
        assert(view:get_controller().conches[6],"shitballs")

        view:get_controller().conches[6]:refresh_mapping()
        --view:get_controller().conches[view:get_controller().ChildComponents.FIRST_TAB]:refresh_mapping()
    end
    --view:Create_Menu_Items()
----------------------------------------------------------------------------


    function view:initialize()
local foot_view = CustomizeFooterView(model,view)
foot_view:initialize()
local first_tab_view = CustomizeFirstTabView(model,view)
first_tab_view:initialize()

        view:set_controller(CustomizeController(self,foot_view))
        view.initialize = nil
------------------------
-- Child view/controllers
------------------------
local tab_view = TabView(model,view)
tab_view:initialize()
view:get_controller():set_child_controller(tab_view:get_controller())
local acc_view = AccordianView(model,view)
acc_view:initialize()
local windmill_view = WindMillView(model)
windmill_view:initialize()

        view:get_controller():set_children({self:get_controller(),
                                        tab_view:get_controller(),
                                       foot_view:get_controller(),
                                   windmill_view:get_controller(),
                                        acc_view:get_controller(),
                                  first_tab_view:get_controller()})
        --first_tab_view:initing()
    end
    function view:rebuild_ingredient_box()
        print("\n\nRebuilding ingredientbox: # left",#view.ingredientbox_left,"# right",#view.ingredientbox_right)
        --top
        view.ingredient_top_text.text = view.ingredientbox_top
        --left
        local left = ""
        for i=1,#view.ingredientbox_left do
            left = left..view.ingredientbox_left[i].."\n"
        end
        view.ingredient_left_text.text = left
        --right
        local right = ""
        for i=1,#view.ingredientbox_right do
            right = right..view.ingredientbox_right[i].."\n"
        end
        view.ingredient_right_text.text = right
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
            --view.ui.opacity = 255
            view.ui:animate{duration = CHANGE_VIEW_TIME, position  = SHOW_POSITION}
                --view.back_arrow_selected.opacity = 0
                --view.add_to_order_selector.opacity = 0
                for i,item in ipairs(view.menu_items) do
                    if i == controller:get_selected_index() then
                        --print("\t",i,"opacity to 255")
                        --item:animate{duration=100, opacity = 255}
                        --item.opacity = 255
                        if i == 1 then
                            view.pzzaLR.opacity = 0
                        else
                            view.pzzaLR.opacity = 255
                        end
                        view.sub_group[i]:animate{duration = 100, opacity = 255}
                        if #view.sub_group_items[i] > 
                            CUSTOMIZE_SCROLL_THRESHOLD then
 
                            view.up_arrow.opacity = 255
                            view.down_arrow.opacity = 255
                        else
                            view.up_arrow.opacity = 0
                            view.down_arrow.opacity = 0
                        end
                        if controller.curr_comp == view:get_controller().ChildComponents.TAB_BAR then
                            --view.arrow.y = (i-1)*120
                            view.selector.opacity = 255
                            view.vert_lines[i].opacity = 0
                            view.selector.y = 960*(i-1)/#model.current_item.Tabs
                            view.selector:raise_to_top()
                        else
                            view.vert_lines[i].opacity = 0
                            view.selector.opacity = 0
                        end
                    else
                        --print("\t",i,"opacity to 0")
                        --item:animate{duration=100, opacity = 100}
                        view.sub_group[i]:animate{duration = 100, opacity = 0}
                        view.vert_lines[i].opacity = 255
                    end
                end
            --end
        elseif comp == Components.TAB or comp == Components.CUSTOMIZE_ITEM or
               comp == Components.ACCORDIAN then
            print("Greying CustomizeView UI")
            --view.ui.opacity = 100
            view.selector.opacity = 0
        else
            print("Hiding CustomizeView UI")
            view.ui:complete_animation()
            if(Components.FOOD_SELECTION ~= comp) then
                view.ui.opacity = 0
            else
                view.ui.opacity = 255
            end
            view.ui:animate{duration = CHANGE_VIEW_TIME, position = HIDE_RIGHT}
        end
    end

end)
