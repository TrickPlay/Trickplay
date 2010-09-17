
return
function( ui , api )

    local assets    = ui.assets
    local factory   = ui.factory
    
    local Encapsulate = dofile( "Encapsulate" )
    
    local section = {}
   
    local ui = nil
    
    local function build_ui()
    
        local APP_TITLE_STYLE   = { font = "DejaVu Sans 48px" , color = "000000FF" }
        local APP_TITLE_X       = 514
        local APP_TITLE_Y       = 7 
        local APP_TITLE_W       = 974
        local APP_TITLE_H       = 50
        
        local APP_DESC_STYLE    = { font = "DejaVu Sans 34px" , color = "FFFFFFFF" }
        local APP_DESC_X        = 514
        local APP_DESC_Y        = 94
        local APP_DESC_W        = 974
        local APP_DESC_H        = 330
        
        local BACKGROUND_FADE_DURATION  = 500
        
        local ANIMATE_IN_DURATION       = 200
        
        local ANIMATE_OUT_DURATION      = 200
        
        local SCRIM_HIDDEN_Y    = screen.h * 1.25
        
        
    
        local group = Group{ position = { 0 , 0 } , size = screen.size , opacity = 0 }
                

        local scrim_background = assets( "assets/app-screen-scrim.png" )
                
        local SCRIM_Y           = group.h - scrim_background.h

        local app_title = Text( APP_TITLE_STYLE )
        
        local app_desc = Text( APP_DESC_STYLE )
        
        local scrim = Group
        {
            position = { 0 , SCRIM_Y } ,
            
            children =
            {
                scrim_background:set
                {
                    position = { 0 , 0 }
                },
                
                app_title:set
                {
                    position = { APP_TITLE_X , APP_TITLE_Y },
                    size = { APP_TITLE_W , APP_TITLE_H },
                    clip = { 0 , 0 , APP_TITLE_W , APP_TITLE_H },
                    ellipsize = "END",
                },
                
                app_desc:set
                {
                    position = { APP_DESC_X , APP_DESC_Y },
                    wrap = true,
                    size = { APP_DESC_W , APP_DESC_H },
                    clip = { 0 , 0 , APP_DESC_W , APP_DESC_H },
                    ellipsize = "END"
                }
            }
        }
        
        group:add( scrim )
        
        local ui = { readonly = { group = function() return group end } }
        
        local background = nil
        
        function ui:populate( shop_app )
        
            -- Remove and let go of an old background if it is there
            
            if background then
                backgroun:unparent()
                background = nil
            end
            
            -- If there is a background URL, start loading a new background
            -- but only add it when it arrives.
            
            local background_url = shop_app.medias[ "background" ]
            
            if background_url then
            
                background = Image
                {
                    src = background_url ,
                    async = true,
                    size = screen.size ,
                    position = { 0 , 0 },
                    opacity = 0
                }
                
                function background.on_loaded( image , failed )
                    image.on_loaded = nil
                    if not failed then
                        group:add( image )
                        image:lower_to_bottom()
                        image:animate{ duration = BACKGROUND_FADE_DURATION , opacity = 255 }
                    else
                        background = nil
                    end
                end
                
            end
        
            -- Now, populate the text
            
            app_title.text = shop_app.name
            
            app_desc.text = shop_app.description or ""
            
        end
        
        function ui:animate_in( callback )
        
            if not group.parent then
                screen:add( group )
            end
            
            group:lower_to_bottom()
            
            group.opacity = 255
            
            local to_animate = {}
            
            scrim.y = SCRIM_HIDDEN_Y
            local interval = Interval( SCRIM_HIDDEN_Y , SCRIM_Y )
            table.insert( to_animate , function( progress ) scrim.y = interval:get_value( progress ) end )
            
            local timeline = FunctionTimeline{ duration = ANIMATE_IN_DURATION , functions = to_animate }
            
            function timeline.on_completed( timeline )
                callback()
            end
            
            timeline:start()

        end
        
        function ui:animate_out( callback )
        
            local to_animate = {}
            
            do
                local interval = Interval( scrim.y , SCRIM_HIDDEN_Y )
                table.insert( to_animate , function( progress ) scrim.y = interval:get_value( progress ) end )
            end
            
            if background then
                background.on_loaded = nil
                if background.parent and background.opacity > 0 then
                    local interval = Interval( background.opacity , 0 )
                    table.insert( to_animate , function( progress ) background.opacity = interval:get_value( progress ) end )
                end
            end

            local timeline = FunctionTimeline{ duration = ANIMATE_OUT_DURATION , functions = to_animate }
            
            function timeline.on_completed( timeline )
                if background then
                    background:unparent()
                    background = nil
                end
                group.opacity = 0
            
                callback()
            end
            
            timeline:start()
        
        end
        
        return Encapsulate( ui )
        
    end
    
    function section:show_app( shop_app , back_callback )
    
        if not ui then
            ui = build_ui()
        end
        
        local group = ui.group
        
        local function finished_in()
            group:grab_key_focus()
            function group.on_key_down( group , key )
                group.on_key_down = nil
                ui:animate_out( back_callback )
            end
        end
        
        ui:populate( shop_app )
        ui:animate_in( finished_in )
    
    end
    
    
    return Encapsulate( section )
    
end
    