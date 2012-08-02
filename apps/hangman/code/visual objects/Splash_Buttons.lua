local Spash_Page = Group{ name = "Splash Page", opacity = 0}

local right_side_bar, right_side_list, game_server, set_GS_username, front_page, game_definition

local keybd_w = 410

local launch_key_board = function()
    
    keyboard:show{
        { id = "username", caption = "Enter Your Screen Name:" },
        --{ id = "password", caption = "Enter Your Password:",type = "password", password_char = "*"  },
    }
    
    screen:animate{
        duration = 500,
        mode = "EASE_OUT_QUAD",
        x    = -keybd_w,
    }
    function keyboard:on_submit( results )
        assert( type(results)          == "table" )
        assert( type(results.username) == "string" )
        
        g_user.name = results.username
        
        screen:animate{
            duration = 500,
            mode = "EASE_IN_QUAD",
            x    = 0,
        }
        
        
        if # g_user.name == 0 then
            
            dolater(
                
                1000,
                
                function()
                    
                    screen:animate{
                        duration = 500,
                        mode = "EASE_OUT_QUAD",
                        x    = -keybd_w,
                    }
                    
                    keyboard:show{
                        { id = "username", caption = "Screen Name is Required:" },
                        --{ id = "password", caption = "Enter Your Password:",type = "password", password_char = "*"  },
                    }
                    
                end
            )
            
            print("User left the Screen Name field blank, prompting again")
            
        elseif g_user.name:match("^[a-zA-Z0-9]*$") ~= g_user.name then
            
            dolater(
                
                1000,
                
                function()
                    
                    screen:animate{
                        duration = 500,
                        mode = "EASE_OUT_QUAD",
                        x    = -keybd_w,
                    }
                    
                    keyboard:show{
                        { id = "username", caption = "Screen Name is aplha-numeric:" },
                        --{ id = "password", caption = "Enter Your Password:",type = "password", password_char = "*"  },
                    }
                    
                end
            )
            
            print("Screen Name is not alpha numeric, prompting again")
            --[[
        elseif # results.password == 0 then
            
            dolater(
                
                1000,
                
                function()
                    
                    screen:animate{
                        duration = 500,
                        mode = "EASE_OUT_QUAD",
                        x    = -keybd_w,
                    }
                    
                    keyboard:show{
                        { id = "username", caption = "Enter Your Username:" },
                        { id = "password", caption = "Password is required:",type = "password", password_char = "*" },
                    }
                    
                end
            )
            
            print("User left the Username field blank, prompting again")
            
        elseif results.password:match("^[a-zA-Z0-9]*$") ~= results.password then
            
            dolater(
                
                1000,
                
                function()
                    
                    screen:animate{
                        duration = 500,
                        mode = "EASE_OUT_QUAD",
                        x    = -keybd_w,
                    }
                    
                    keyboard:show{
                        { id = "username", caption = "Enter Your Username:" },
                        { id = "password", caption = "Password is aplha-numeric:",type = "password", password_char = "*"  },
                    }
                    
                end
            )
            
            print("Username is not alpha numeric, prompting again")
            --]]
        else
            
            print("User gave username: '"..g_user.name.."'")
            
            
            
            screen:grab_key_focus()
            
            game_server:login{
                user        = g_user.name,
                --pswd        = results.password,
                --email       = g_user.name.."@"..g_user.name..".com",
                game_definition = game_definition,
                session_callback = function(t)
                    
                    print("SUCCESS")
                    
                    front_page:setup_lists()
                    
                end,
                login_callback = function(t)
                    if t then
                        
                        settings.username = g_user.name
                        settings.password = results.password
                        
                        app_state.state = "MAIN_PAGE"
                    else
                        
                        print("invalid username/password")
                        
                        dolater(
                            
                            1000,
                            
                            function()
                                
                                screen:animate{
                                    duration = 500,
                                    mode = "EASE_OUT_QUAD",
                                    x    = -keybd_w,
                                }
                                
                                keyboard:show{
                                    { id = "username", caption = "Try Again, Username:" },
                                    { id = "password", caption = "Password:",type = "password", password_char = "*"  },
                                }
                                
                            end
                        )
                        
                    end
                    
                    
                end
            }
            
            
        end
        
    end
    
    function keyboard:on_cancel( results )
        
        screen:animate{
            duration = 500,
            mode = "EASE_IN_QUAD",
            x    = 0,
        }
        
    end
    
end




function Spash_Page:init(t)
    
    if type(t) ~= "table" then error("must pass a table as the parameter",2) end
    
    img_srcs        = t.img_srcs        or error( "must pass img_srcs",        2 )
    front_page      = t.front_page      or error( "must pass front_page",      2 )
    game_server     = t.game_server     or error( "must pass game_server",     2 )
    game_definition = t.game_definition or error( "must pass game_definition", 2 )
    
    
    
    right_side_list = t.side_buttons:make{
        x = 1120, y = 784, spacing = 874-784-66, buttons = {
            {name = "Log In", select = function()
                print("'Start Game' Pressed")
                launch_key_board()
            end},
            {name = "Quit", select = function()
                print("quit")
                exit()
            end},
        }
    }
    
    
    Spash_Page:add( right_side_list )
    
end

function Spash_Page:gain_focus()
    
    right_side_list:set_state( "FOCUSED" )
    
end

return Spash_Page