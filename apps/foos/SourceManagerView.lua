SourceManagerView = Class(View, function(view, model, ...)
    view._base.init(view, model)

    view.clones = Group{name="source manager clone sources",opacity = 0}
    view.ui     = Group{name="source manager ui", position = {200,0}}
    screen:add(view.ui)
    screen:add(view.clones)

    

    local  add_sel = Image{src = "assets/source\ manager/Add_Sel.png"}
    local  add_un  = Image{src = "assets/source\ manager/Add_UnSel.png"}
    local hide_sel = Image{src = "assets/source\ manager/Hide_Sel.png"}
    local hide_un  = Image{src = "assets/source\ manager/Hide_UnSel.png"}
    local ok_sel = Image { src = "assets/source\ manager/ok_focus.png"}
    local ok_un = Image { src = "assets/source\ manager/ok_nofocus.png"}
    local cancel_sel = Image { src = "assets/source\ manager/cancel_focus.png"}
    local cancel_un = Image { src = "assets/source\ manager/cancel_nofocus.png"}
    local txtbx_sel = Image{src="assets/source\ manager/typeinbox_focus.png"}
    local txtbx_un = Image{src="assets/source\ manager/typeinbox_nofocus.png"}
	 view.clones:add(ok_sel, ok_un, cancel_sel, cancel_un)
    view.clones:add(   add_sel )
    view.clones:add(   add_un  )
    view.clones:add(  hide_sel )
    view.clones:add(  hide_un  )
    view.clones:add( txtbx_sel )
    view.clones:add( txtbx_un  )

    view.menu_buttons = {}
    view.menu_items   = {}

    for i = 1,#model.source_list do

        view.menu_items[i] = Text{
            text     = model.source_list[i][1],
            font     = "KacstArt 42px",
            color    = "FFFFFF",
            opacity  = 255,
            position = {400,120*i}
        }

        view.menu_buttons[i]    = {}
        view.menu_buttons[i][1] = Clone{ source = add_un  }
        view.menu_buttons[i][2] = Clone{ source = add_sel }
        view.menu_buttons[i][1].position = {100, 120*i-20}
        view.menu_buttons[i][2].position = {100, 120*i-20}

        view.ui:add(unpack(view.menu_buttons[i]))
    end
 
    view.ui:add( unpack(view.menu_items) )

    view.accordian_items  = 
    {
        ["QUERY"] = 
        {
             FocusableImage(  0, 0,  txtbx_un,  txtbx_sel),
             FocusableImage(400, 0,     ok_un,     ok_sel),
             FocusableImage(800, 0, cancel_un, cancel_sel)
        },
        ["LOGIN"] = 
        {
             FocusableImage(  0, 0,   txtbx_un,  txtbx_sel),
             FocusableImage( 400, 0,  txtbx_un,  txtbx_sel),
             FocusableImage( 800, 0,     ok_un,     ok_sel),
             FocusableImage(1200, 0, cancel_un, cancel_sel)
        }
    }
    view.accordian_text = 
    {
        ["QUERY"] = 
        {
            Text{
                position={15,0},
                font="KacstArt 30px",
                color="FFFFFF",
                wants_enter = false,
                text="keyword"
            }
        },
        ["LOGIN"] = 
        {
            Text{
                position={15,0},
                font="KacstArt 30px",
                color="FFFFFF",
                wants_enter = false,
                text="username"
            },
            Text{
                position={415,0},
                font="KacstArt 30px",
                color="FFFFFF",
                wants_enter = false,
                text="password"
            }
        }
    }

    view.accordian_groups = 
    {
        ["QUERY"] =  Group{name="Query Accordian",opacity = 0,
                            position = {view.ui.x+50,0}},
        ["LOGIN"] =  Group{name="Login Accordian",opacity = 0,
                            position = {view.ui.x+50,0}},
     --   "BOTH"  =  Group{name="Both Accordians"}
    }

    view.accordian_groups["QUERY"]:add(view.accordian_items["QUERY"][1].group)
    view.accordian_groups["QUERY"]:add(view.accordian_items["QUERY"][2].group)
    view.accordian_groups["QUERY"]:add(view.accordian_items["QUERY"][3].group)
    view.accordian_groups["QUERY"]:add(unpack( view.accordian_text["QUERY"]))
    view.accordian_groups["LOGIN"]:add(view.accordian_items["LOGIN"][1].group)
    view.accordian_groups["LOGIN"]:add(view.accordian_items["LOGIN"][2].group)
    view.accordian_groups["LOGIN"]:add(view.accordian_items["LOGIN"][3].group)
    view.accordian_groups["LOGIN"]:add(view.accordian_items["LOGIN"][4].group)
    view.accordian_groups["LOGIN"]:add(unpack( view.accordian_text["LOGIN"]))

    
    view.ui:add(view.accordian_groups["QUERY"])
    view.ui:add(view.accordian_groups["LOGIN"])

  
    function view:initialize()
        self:set_controller(SourceManagerController(self))
    end

    view.accordian = false

    view.acc_split = Group{name="lower half of the accordian"
                            }
    view.ui:add(view.acc_split)

    function view:enter_accordian()
        local src_sel    = view:get_controller():get_src_selected_index()
        print("Entering a",model.source_list[src_sel][2],"accordian")
        
        assert(view.accordian_groups[  model.source_list[src_sel][2]  ],"shit happened")
        view.accordian_groups[  model.source_list[src_sel][2]  ].y = 
                           view.menu_items[src_sel].y + 120
        --view.acc_split.y = view.menu_items[src_sel].y

        for i = src_sel+1,#model.source_list do

            view.menu_items[i]:unparent()
            view.menu_buttons[i][1]:unparent()
            view.menu_buttons[i][2]:unparent()

            view.acc_split:add(view.menu_items[i])
            view.acc_split:add(view.menu_buttons[i][1])
            view.acc_split:add(view.menu_buttons[i][2])
            
        end
        view.acc_split:animate
        {
            duration = CHANGE_TIME_VIEW, 
                   y = view.acc_split.y + 180,
            on_completed = function()
                view.accordian_groups[  model.source_list[src_sel][2]  ]:animate
                {
                    duration = CHANGE_VIEW_TIME,
                    opacity  = 255
                }
            end
        }
    end


    function view:leave_accordian()
        local src_sel    = view:get_controller():get_src_selected_index()
        view.accordian_groups[  model.source_list[src_sel][2]  ]:animate
        {
            duration = CHANGE_VIEW_TIME,
            opacity  = 0,
            on_completed = function()
                view.acc_split:animate
                {
                    duration = CHANGE_TIME_VIEW, 
                           y = view.acc_split.y - 180
                }
            end
        }
        for i = src_sel+1,#model.source_list do

            view.menu_items[i]:unparent()
            view.menu_buttons[i][1]:unparent()
            view.menu_buttons[i][2]:unparent()

            view.ui:add(view.menu_items[i])
            view.ui:add(view.menu_buttons[i][1])
            view.ui:add(view.menu_buttons[i][2])

        end
        
        view:get_controller():reset_acc_selected_index()
    end

    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local src_sel    = controller:get_src_selected_index()
        local acc_sel    = controller:get_acc_selected_index()

        if comp == Components.SOURCE_MANAGER  then
            if view.accordian == false then
            
                print("\n\nShowing SourceManagerView UI - Source Providers\n")

                view.ui:raise_to_top()
                view.ui.opacity = 255            

                for i = 1, #view.menu_items do
                    view.menu_buttons[i][1]:complete_animation()
                    view.menu_buttons[i][2]:complete_animation()
                    if i == src_sel then
                        view.menu_buttons[i][1]:animate{ duration = 100, opacity =   0}
                        view.menu_buttons[i][2]:animate{ duration = 100, opacity = 255}
                    else
                        view.menu_buttons[i][1]:animate{ duration = 100, opacity = 255}
                        view.menu_buttons[i][2]:animate{ duration = 100, opacity =   0}
                    end
                end
            else
                local acc = view.accordian_items[  model.source_list[src_sel][2]  ]
                for i = 1, #acc do
                    if i == acc_sel then
                        acc[i]:on_focus()
                    else
                        acc[i]:out_focus()
                    end
                end
            end
        else
            print("Hiding FrontPageView UI")
            --model.album_group:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
