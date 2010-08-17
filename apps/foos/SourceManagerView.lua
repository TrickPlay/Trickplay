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

    view.clones:add(  add_sel )
    view.clones:add(  add_un  )
    view.clones:add( hide_sel )
    view.clones:add( hide_un  )

    view.menu_buttons = {}
    view.menu_items   = {}

    for i = 1,#model.source_list do

        view.menu_items[i] = Text{
            text = model.source_list[i][1],
            font = "KacstArt 42px",
            color = "FFFFFF",
            opacity = 255,
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

  
    function view:initialize()
        self:set_controller(SourceManagerController(self))
    end

           
    function view:update()
        local controller = view:get_controller()
        local comp       = model:get_active_component()
        local  sel       = controller:get_selected_index()
        if comp == Components.SOURCE_MANAGER  then

            print("\n\nShowing SourceManagerView UI\n")

            view.ui:raise_to_top()
            view.ui.opacity = 255            

            for i = 1, #view.menu_items do
                view.menu_buttons[i][1]:complete_animation()
                view.menu_buttons[i][2]:complete_animation()
                if i == sel then
                    view.menu_buttons[i][1]:animate{ duration = 100, opacity =   0}
                    view.menu_buttons[i][2]:animate{ duration = 100, opacity = 255}
                else
                    view.menu_buttons[i][1]:animate{ duration = 100, opacity = 255}
                    view.menu_buttons[i][2]:animate{ duration = 100, opacity =   0}
                end
            end
        else
            print("Hiding FrontPageView UI")
            --model.album_group:complete_animation()
            view.ui.opacity = 0
        end
    end

end)
