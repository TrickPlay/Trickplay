local Spash_Page = Group{ name = "Splash Page", opacity = 0}

local right_side_bar, right_side_list, game_server, set_GS_username, main_menu_list, game_definition



local launch_key_board = function()
    
    keyboard:show{
        { id = "username", caption = "Enter Your Username:" }
    }
    
    function keyboard:on_submit( results )
        assert( type(results)          == "table" )
        assert( type(results.username) == "string" )
        
        g_username = results.username
        
        
        if # g_username == 0 then
            
            dolater(
                
                1000,
                keyboard.show,
                keyboard,
                {
                    { id = "username", caption = "Username is Required:" }
                }
            )
            
            print("User left the Username field blank, prompting again")
            
        else
            
            print("User gave username: '"..g_username.."'")
            
            app_state.state = "MAIN_PAGE"
            
            screen:grab_key_focus()
            
            game_server:login{
                user        = g_username,
                pswd        = g_username,
                email       = g_username.."@"..g_username..".com",
                game_definition = game_definition,
                callback = function(t)
                    
                    print("SUCCESS")
                    
                    set_GS_username( gsm:user_id())
                    
                    main_menu_list:init_sessions()
                    
                    
                    
                end
            }
            
            
        end
        
    end
    
    function keyboard:on_cancel( results )
        
        dolater(
            800,
            exit
        )
        
    end
    
end




function Spash_Page:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    img_srcs        = t.img_srcs       or error( "must pass img_srcs",         2 )
    main_menu_list  = t.main_menu_list  or error( "must pass main_menu",       2 )
    game_server     = t.game_server     or error( "must pass game_server",     2 )
    game_definition = t.game_definition or error( "must pass game_definition", 2 )
    set_GS_username = t.set_GS_username or error( "must pass set_GS_username", 2 )
    
    
    right_side_bar = {}
    right_side_bar[1] =make_button{
        clone           = true,
        unfocus_fades   = false,
        select_function = function()
            print("'Start Game' Pressed")
            launch_key_board()
        end,
        unfocused_image = img_srcs.button_r,
        focused_image   = img_srcs.button_f,
    }
    right_side_bar[1].x = 1190
    right_side_bar[1].y = 750
    right_side_bar[1]:add(Text{
        color = "ffffff",
        text  = "Start Game",
        font  = t.font .. " Bold 28px",
        x     = 30,
        y     = 15,
    })
    
    right_side_bar[2] =make_button{
        clone           = true,
        unfocus_fades   = false,
        select_function = function()
            print("quit")
            exit()
        end,
        unfocused_image = img_srcs.button_b,
        focused_image   = img_srcs.button_f,
    }
    right_side_bar[2].x = right_side_bar[1].x
    right_side_bar[2].y = right_side_bar[1].y + img_srcs.button_f.h + 20
    right_side_bar[2]:add(Text{
        color = "ffffff",
        text  = "Quit",
        font  = t.font .. " Bold 28px",
        x     = 30,
        y     = 15,
    })
    
    right_side_list = t.make_list{
        orientation = "VERTICAL",
        elements = right_side_bar,
        display_passive_focus = false,
        resets_focus_to = 1,
    }
    
    right_side_list:define_key_event(keys.RED,  right_side_bar[1].select)
    right_side_list:define_key_event(keys.BLUE, right_side_bar[2].select)
    
    Spash_Page:add( right_side_list )
    
end

function Spash_Page:gain_focus()
    
    right_side_list:set_state( "FOCUSED" )
    
end

return Spash_Page