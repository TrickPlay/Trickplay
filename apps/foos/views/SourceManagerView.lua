SourceManagerView = Class(View, function(view, model, ...)
    view._base.init(view, model)

    view.clones = Group{name="source manager clone sources",opacity = 0}
    view.ui     = Group{name="source manager ui", position = {screen.width,0}}
    screen:add(view.ui)
    screen:add(view.clones)

    

    local resume_button = Image{src="assets/source\ manager/resume_button.png",
                                position =  {0,screen.height/3}}
    view.ui:add(resume_button)
--[[
	local background = Image {src = "assets/background.jpg", x = -200 }	
	 view.ui:add(background)
--]]
    local add_sel    = Image{ src = "assets/source\ manager/Add_Sel.png"}
    local add_un      = Image{ src = "assets/source\ manager/Add_UnSel.png"}
    local ok_sel     = Image{ src = "assets/source\ manager/ok_focus.png"}
    local ok_un      = Image{ src = "assets/source\ manager/ok_nofocus.png"}
    local cancel_sel = Image{ src = "assets/source\ manager/cancel_focus.png"}
    local cancel_un  = Image{ src = "assets/source\ manager/cancel_nofocus.png"}
    local txtbx_sel  = Image{ src = "assets/source\ manager/typeinbox_focus.png"}
    local txtbx_un   = Image{ src = "assets/source\ manager/typeinbox_nofocus.png"}
    
    local queryText = Text {font = "Sans 30px" , text = "Search for: "}
    
    view.clones:add(    ok_sel )
    view.clones:add(    ok_un  )
    view.clones:add(cancel_sel )
    view.clones:add(cancel_un  )
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
            position = {500,120*i}
        }

        view.menu_buttons[i]    = {}
        view.menu_buttons[i][1] = Clone{ source = add_sel  }
        view.menu_buttons[i][2] = Clone{ source = add_un }
        view.menu_buttons[i][1].position = {200, 120*i-20}
        view.menu_buttons[i][2].position = {200, 120*i-20}

        view.ui:add(unpack(view.menu_buttons[i]))
    end
 
    view.ui:add( unpack(view.menu_items) )

    view.accordian_items  = 
    {
        ["QUERY"] = 
        {
             {FocusableImage( 200,  0,  txtbx_un,  txtbx_sel)},
             {FocusableImage( 150, 60,     ok_un,     ok_sel),
              FocusableImage( 350, 60, cancel_un, cancel_sel)}
        },
        ["LOGIN"] = 
        {
             {FocusableImage( 200, 0,   txtbx_un,  txtbx_sel)},
             {FocusableImage( 200, 60,  txtbx_un,  txtbx_sel)},
             {FocusableImage( 150, 120,     ok_un,     ok_sel),
              FocusableImage( 350, 120, cancel_un, cancel_sel)}
        }
    }
    view.accordian_text = 
    {
        ["QUERY"] = 
        {
            Text{
                position={225,30},
                font="KacstArt 30px",
                color="000000",
                wants_enter = false,
                text=""
            }
        },
        ["LOGIN"] = 
        {
            Text{
                position={225,30},
                font="KacstArt 30px",
                color="000000",
                wants_enter = false,
                text=""
            },
            Text{
                position={225,100},
                font="KacstArt 30px",
                color="000000",
                wants_enter = false,
                text=""
            }
        }
    }

    view.accordian_groups = 
    {
        ["QUERY"] =  Group{name="Query Accordian",opacity = 0,
                            position = {200,0}},
        ["LOGIN"] =  Group{name="Login Accordian",opacity = 0,
                            position = {200,0}},
     --   "BOTH"  =  Group{name="Both Accordians"}
    }

    view.accordian_groups["QUERY"]:add(Text{text="Enter Query:", 
         position = {0,30},font ="KacstArt 30px",color = "FFFFFF" })
    view.accordian_groups["QUERY"]:add(view.accordian_items["QUERY"][1][1].group)
    view.accordian_groups["QUERY"]:add(view.accordian_items["QUERY"][2][1].group)
    view.accordian_groups["QUERY"]:add(view.accordian_items["QUERY"][2][2].group)
    view.accordian_groups["QUERY"]:add(unpack( view.accordian_text["QUERY"]))
    view.accordian_groups["LOGIN"]:add(Text{text="Username:\nPassword:", 
         position = {0,30},font ="KacstArt 30px",color = "FFFFFF" })
    view.accordian_groups["LOGIN"]:add(view.accordian_items["LOGIN"][1][1].group)
    view.accordian_groups["LOGIN"]:add(view.accordian_items["LOGIN"][2][1].group)
    view.accordian_groups["LOGIN"]:add(view.accordian_items["LOGIN"][3][1].group)
    view.accordian_groups["LOGIN"]:add(view.accordian_items["LOGIN"][3][2].group)
    view.accordian_groups["LOGIN"]:add(unpack( view.accordian_text["LOGIN"]))

    
    view.ui:add(view.accordian_groups["QUERY"])
    view.ui:add(view.accordian_groups["LOGIN"])

  
    function view:initialize()
        self:set_controller(SourceManagerController(self))
    end

    view.accordian = false

    view.acc_split = Group{ name="lower half of the accordian" }
    view.ui:add(view.acc_split)

    function view:enter_accordian()
        local src_sel    = view:get_controller():get_src_selected_index()
        print("Entering a",model.source_list[src_sel][2],"accordian")
        
        assert(view.accordian_groups[  model.source_list[src_sel][2]  ],
                                                          "shit happened")
        view.accordian_groups[  model.source_list[src_sel][2]  ].y = 
                           view.menu_items[src_sel].y +80
        --view.acc_split.y = view.menu_items[src_sel].y

        for i = src_sel+1,#model.source_list do

            view.menu_items[i]:unparent()
            view.menu_buttons[i][1]:unparent()
            view.menu_buttons[i][2]:unparent()

            view.acc_split:add(view.menu_items[i])
            view.acc_split:add(view.menu_buttons[i][1])
            view.acc_split:add(view.menu_buttons[i][2])
            
        end
        view.acc_split:complete_animation()
        view.acc_split:animate
        {
            duration     = 100, 
            y            = view.menu_items[1].y + 50,
            on_completed = function()
                view.accordian_groups[  model.source_list[src_sel][2]  ]:raise_to_top()
                view.accordian_groups[  model.source_list[src_sel][2]  ]:complete_animation()
                view.accordian_groups[  model.source_list[src_sel][2]  ]:animate
                {
                    duration     = 100,
                    opacity      = 255,
                    on_completed = function()
                        view.acc_split.y = view.menu_items[1].y + 50
                        reset_keys()      
                    end
                }
            end
        }
    end


    function view:leave_accordian()
        --duration of this animation should match the duraction of the 
        --add cover timeline to ensure that reset keys occurs after it
        --finished
        local src_sel    = view:get_controller():get_src_selected_index()
        view.accordian_groups[  model.source_list[src_sel][2]  ]:complete_animation()
        view.accordian_groups[  model.source_list[src_sel][2]  ]:animate
        {
            duration = 100,
            opacity  = 0,
            on_completed = function()
                view.acc_split:complete_animation()
                view.acc_split:animate
                {
                    duration     = 100, 
                    y            = view.menu_items[1].y +0,
                    on_completed = function()
                        view.accordian_groups[  model.source_list[src_sel][2]  ].opacity = 0
                        reset_keys()  
                    end
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
        local acc_sel    = {}
        acc_sel[1], acc_sel[2] =  controller:get_acc_selected_index()

        if comp == Components.SOURCE_MANAGER  then
            
            view.ui:raise_to_top()
            view.ui.opacity = 255 
            view.ui:complete_animation()
            if view.ui.x ~= screen.width/2 then
                view.ui:animate
                {
                    duration      = 300,
                    x             = screen.width/2,
                    on_completed = function()
                        reset_keys()
                    end
                }
--[[
            else
                print("please print this\n\n\n\n")
--]]
            end
            if view.accordian == false then
            
                print("\n\nShowing SourceManagerView UI - Source Providers\n")
          

                for i = 1, #view.menu_items do
                    view.menu_buttons[i][1]:complete_animation()
                    view.menu_buttons[i][2]:complete_animation()
                    if i == src_sel then
                        view.menu_buttons[i][1]:animate{ duration = 100 ,
                                                         opacity  =   0 }
                        view.menu_buttons[i][2]:animate{ duration = 100 ,
                                                         opacity  = 255 }
                    else
                        view.menu_buttons[i][1]:animate{ duration = 100 ,
                                                         opacity  = 255 }
                        view.menu_buttons[i][2]:animate{ duration = 100 ,
                                                         opacity  =   0 }
                    end
                end
            else
                print("\n\nShowing SourceManagerView UI - Accordian\n")

                local acc = view.accordian_items[  model.source_list[src_sel][2]  ]
                for i = 1, #acc do
                    for j = 1, #acc[i] do
                        if i == acc_sel[1] and j == acc_sel[2] then
                            acc[i][j]:on_focus()
                        else
                            acc[i][j]:out_focus()
                        end  
                    end
                end

            end

        else
            print("Hiding SourceManagerView UI")
            --model.album_group:complete_animation()
            view.ui:complete_animation()
            view.ui:animate{duration =          300,
                            x        = screen.width}
            --view.ui.opacity = 0
        end
    end

end)
