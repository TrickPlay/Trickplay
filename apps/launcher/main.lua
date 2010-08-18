local OEM = "trickplay"
-------------------------------------------------------------------------------
-- Build the UI
-------------------------------------------------------------------------------

local function build_ui( show_it )

    -------------------------------------------------------------------------------
    -- Localized string table
    -------------------------------------------------------------------------------
    
    local strings = dofile( "localized:strings.lua" ) or {}

    -- Set an __index function to warn and return the original string
    
    local function missing_localized_string( t , s )
        print( "\t*** MISSING LOCALIZED STRING '"..s.."'" )
        rawset(t,s,s) -- only warn once per string
        return s
    end
    
    setmetatable( strings , { __index = missing_localized_string } )

    -------------------------------------------------------------------------------
    -- Style constants
    -------------------------------------------------------------------------------
    
    local BUTTON_FONT               = "DejaVu Sans 28px"
    local BUTTON_FONT_COLOR         = "FFFFFFFF"
     
    -------------------------------------------------------------------------------
    -- Section index constants
    -------------------------------------------------------------------------------
    
    local SECTION_APPS      = 1
    local SECTION_SHOWCASE  = 2
    local SECTION_SHOP      = 3
    local SECTION_SETTINGS  = 4
    
    -------------------------------------------------------------------------------
    -- All the initial assets
    -------------------------------------------------------------------------------
    
    local ui =
    {
        bar                 = Group {},
        
        bar_background      = Image { src = "assets/menu-background-"..OEM..".png" },
        
        button_focus        = Image { src = "assets/button-focus.png" },
    
        apps_button         = Image { src = "assets/button-myapps-blank.png" },
        
        apps_text           = Text  {
                                        font = BUTTON_FONT ,
                                        color = BUTTON_FONT_COLOR ,
                                        text = strings[ "My Apps" ]
                                    },
                                    
        apps_dropdown       = Image { src = "assets/dropdown-myapps.png" },
        
        shop_button         = Image { src = "assets/button-appshop-blank.png" },
        
        shop_text           = Text  {
                                        font = BUTTON_FONT ,
                                        color = BUTTON_FONT_COLOR ,
                                        text = strings[ "App Shop" ]
                                    },
                                    
        shop_dropdown       = Image { src = "assets/dropdown-appshop.png" },
        
        settings_button     = Image { src = "assets/button-settings-blank.png" },
        
        settings_text       = Text  {
                                        font = BUTTON_FONT ,
                                        color = BUTTON_FONT_COLOR ,
                                        text = strings[ "Settings" ]                                        
                                    },
                                    
        settings_dropdown   = Image { src = "assets/dropdown-settings.png" },
    
        showcase_button     = Image { src = "assets/button-showcase-blank.png" },
        
        showcase_text       = Text  {
                                        font = BUTTON_FONT ,
                                        color = BUTTON_FONT_COLOR ,
                                        text = strings[ "Heineken Showcase" ]
                                    },
                                    
        showcase_dropdown   = Image { src = "assets/dropdown-showcase.png" }
    }
    
    -------------------------------------------------------------------------------
    -- Position constants
    -------------------------------------------------------------------------------
    
    local BUTTON_TEXT_X_OFFSET      = 20
    local BUTTON_TEXT_Y_OFFSET      = 22
    local FIRST_BUTTON_X            = 13                    -- x coordinate of first button
    local FIRST_BUTTON_Y            = 9                     -- y coordinate of first button
    local BUTTON_X_OFFSET           = ui.apps_button.w + 5  -- distance between left side of buttons
    local DROPDOWN_POINT_Y_OFFSET   = -4                     -- how far to raise or lower the drop downs
    
    -------------------------------------------------------------------------------
    -- Now, create structure an position everything
    -------------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
    -- The group that holds the bar background and the buttons
    
    ui.bar:set
    {
        size = ui.bar_background.size,
        
        position = { 0 , 0 },
        
        children =
        {
            ui.bar_background:set
            {
                position = { 0 , 0 }
            },
            
            ui.button_focus:set
            {
                position = { FIRST_BUTTON_X , FIRST_BUTTON_Y },        
            }
        }
    }

    screen:add( ui.bar )    
    
    ----------------------------------------------------------------------------
    -- Put the buttons, dropdowns and text into an array, in order of appearance
    
    ui.sections =
    {
        [SECTION_APPS] =
        {
            button = ui.apps_button,
            dropdown_bg = ui.apps_dropdown,
            text = ui.apps_text
        },
        
        [SECTION_SHOWCASE]=
        {
            button = ui.showcase_button,
            dropdown_bg = ui.showcase_dropdown,
            text = ui.showcase_text
        },
        
        [SECTION_SHOP]=
        {
            button = ui.shop_button,
            dropdown_bg = ui.shop_dropdown,
            text = ui.shop_text
        },
        
        [SECTION_SETTINGS]=
        {
            button = ui.settings_button,
            dropdown_bg = ui.settings_dropdown,
            text = ui.settings_text
        }
    }
    
    ----------------------------------------------------------------------------
    -- Now, add and position everything
    
    for i , section in ipairs( ui.sections ) do
    
        section.button.position =
        {
            FIRST_BUTTON_X + ( BUTTON_X_OFFSET * ( i - 1 ) ),
            FIRST_BUTTON_Y
        }
    
        section.text.position =
        {
            section.button.x + BUTTON_TEXT_X_OFFSET ,
            section.button.y + BUTTON_TEXT_Y_OFFSET
        }
        
        section.dropdown = Group
        {
            size = section.dropdown_bg.size,
            anchor_point = { section.dropdown_bg.w / 2 , 0 },
            position = 
            {
                section.button.x + section.button.w / 2,
                ui.bar.h + DROPDOWN_POINT_Y_OFFSET
            },
            children =
            {
                section.dropdown_bg
            }
        }
                
        ui.bar:add( section.button , section.text )
        
        section.button:lower( ui.button_focus )
        
        section.text:raise( ui.button_focus )
        
        screen:add( section.dropdown )
        
    end

    -------------------------------------------------------------------------------
    -- UI state information
    -------------------------------------------------------------------------------
    
    local DROPDOWN_TIMEOUT = 200    -- How many milliseconds one has to stay
                                    -- on a button for the dropdown to show up
                        
    ui.strings = strings    -- Store the string table

    ui.focus = SECTION_APPS     -- The section # that has focus
    
    ui.dropdown_timer = Timer( DROPDOWN_TIMEOUT / 1000 )
    
    ui.color_keys =             -- Which section # to focus with the given key
    {
        [ keys.YELLOW ] = SECTION_APPS,
        [ keys.GREEN  ] = SECTION_SHOWCASE,
        [ keys.RED    ] = SECTION_SHOP,
        [ keys.BLUE   ] = SECTION_SETTINGS
    }

    -------------------------------------------------------------------------------
    -- Internal functions
    -------------------------------------------------------------------------------

    local function reset_dropdown_timer()
    
        ui.dropdown_timer:stop()
        ui.dropdown_timer:start()
    
    end

    local function animate_out_dropdown( )
        
        local ANIMATION_DURATION = 200
        
        local section = ui.sections[ ui.focus ]
        
        if not section.dropdown.is_visible then return end
        
        section.dropdown:animate
        {
            duration = ANIMATION_DURATION,
            opacity = 0,
            y_rotation = -90,
            on_completed = function() section.dropdown:hide() end
        }
    
    end

    local function animate_in_dropdown( )
        
        local ANIMATION_DURATION = 150
        
        local section = ui.sections[ ui.focus ]
        
        if section.dropdown.is_visible then return end
        
        section.dropdown.opacity = 0
        
        section.dropdown:show()
        
        section.dropdown.y_rotation = { 90 , 0 , 0 }
        
        section.dropdown:animate
        {
            duration = ANIMATION_DURATION,
            opacity = 255,
            y_rotation = 0
        }
    
    end
    
    local function move_focus( new_focus )

        -- Bad focus. Your focus needs more focus.
        
        if not new_focus then return end
        
        -- Same focus. Laser focus.
        
        if new_focus == ui.focus then return end
        
        local section = ui.sections[ new_focus ]
        
        -- Focus out of range. Blurred.
        
        if not section then return end -- The new section is out of range
        
        animate_out_dropdown()
        
        ui.focus = new_focus
        
        ui.button_focus.position = section.button.position
        
        reset_dropdown_timer()    
    end


    -------------------------------------------------------------------------------
    -- Handlers
    -------------------------------------------------------------------------------
        
    local key_map =
    {
        [ keys.Left     ] = function() move_focus( ui.focus - 1 ) end,
        [ keys.Right    ] = function() move_focus( ui.focus + 1 ) end,
        
        [ keys.YELLOW   ] = function() move_focus( ui.color_keys[ key ] ) end,
        [ keys.GREEN    ] = function() move_focus( ui.color_keys[ key ] ) end,
        [ keys.RED      ] = function() move_focus( ui.color_keys[ key ] ) end,
        [ keys.BLUE     ] = function() move_focus( ui.color_keys[ key ] ) end,
        
        -- For keyboards
        
        [ keys.F5       ] = function() move_focus( ui.color_keys[ keys.YELLOW ] ) end,
        [ keys.F6       ] = function() move_focus( ui.color_keys[ keys.GREEN ] ) end,
        [ keys.F7       ] = function() move_focus( ui.color_keys[ keys.RED ] ) end,
        [ keys.F8       ] = function() move_focus( ui.color_keys[ keys.BLUE ] ) end,
        
        -- TODO : Pressing OK on a button may do something else
        
        [ keys.Return   ] = function() animate_in_dropdown() end,
    }
    
    function ui.bar.on_key_down( _ , key )
        
        if not pcall( key_map[ key ] ) then
        
            print( keys[ key ] )
        
        end
    
    end
    
    function ui.dropdown_timer.on_timer( )
    
        animate_in_dropdown()
        
        return false
    
    end
    
    -------------------------------------------------------------------------------
    -- Define ui functions
    -------------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
    -- Utility to iterate over all sections
    
    function ui:foreach_section( f )
    
        if f then for _,section in ipairs( self.sections ) do f( section ) end end
    
    end
    
    ----------------------------------------------------------------------------
    -- Hides everything with no animation
    
    function ui:hide()
    
        self.button_focus:hide()

        self.bar:hide()
        
        self:foreach_section( function( section ) section.dropdown:hide() end )
            
    end
    
    ----------------------------------------------------------------------------
    -- Animates the bar into view
    
    function ui:animate_in( callback )
    
        -- Make sure everthing that needs to be hidden is hidden
        
        self:hide()
        
        self.bar:show()
        
        self.button_focus:show()
        
        -- Constants

        local INITIAL_BAR_ANGLE     = -120
        local ANIMATION_DURATION    = 250
        
        -- Set the initial values for the bar and the focus ring
        
        self.bar:set
        {
            x_rotation = { INITIAL_BAR_ANGLE , 0 , 0 },
            opacity = 0
        }
        
        self.button_focus.opacity = 0
        
        -- Completion function
            
        local function animation_completed()
        
            -- The bar gets key focus after we animate
            
            self.bar:grab_key_focus()
            
            self.dropdown_timer:start()
            
            if callback then
            
                callback( self )
                
            end
            
        end
        
        -- Animate
        
        self.bar:animate
        {
            duration = ANIMATION_DURATION,
            x_rotation = 0,
            opacity = 255,
            on_completed = animation_completed
        }
        
        self.button_focus:animate
        {
            duration = ANIMATION_DURATION,
            opacity = 255
        }
        
    end
    
    ----------------------------------------------------------------------------
    -- Hide everything unless show_it is true (only for debugging)
    
    if not show_it then
    
        ui:hide()
    
    end


    ----------------------------------------------------------------------------
    -- Load the apps and the most used apps
    ----------------------------------------------------------------------------
    
    local top_apps = settings.top_apps or {}
    
    ui.all_apps = apps:get_for_current_profile()
    
    ui.top_apps = {}
    
    -- Look for each top app in all_apps and, if it is there, add it to
    -- ui.top_apps until we have 3.
    
    -- This ensures that the ids we have saved previously in top apps still
    -- exist.
    
    for _ , app_id in ipairs( top_apps ) do
    
        local app = ui.all_apps[ app_id ]
        
        if app then
        
            app.is_top = true
    
            table.insert( ui.top_apps , app_id )
            
            if # ui.top_apps == 3 then
                break
            end
        end
    
    end

    -- If ui.top_apps has less than 3, then add some from all_apps.
    --
    -- In a cold start, top apps will be empty - this fills it. 
    
    if # ui.top_apps < 3 then
    
        for app_id , app in pairs( ui.all_apps ) do
        
            if not app.is_top then
            
                app.is_top = true
                
                table.insert( ui.top_apps , app_id )
                
                if # ui.top_apps == 3 then
                    break
                end
            end
        end
    end
    
    -- Now, get the icons for the top apps
    
    for _ , app_id in ipairs( ui.top_apps ) do
    
        local image = Image()
        
        -- If we cannot load the app icon, we use the generic one
        
        if not image:load_app_icon( app_id , "launcher-icon.png" ) then
        
            if not ui.generic_app_icon then
            
                ui.generic_app_icon = Image{ src = "assets/generic-app-icon.png" , opacity = 0 }
                
                screen:add( ui.generic_app_icon )
                
            end
            
            image = Clone{ source = ui.generic_app_icon , opacity = 255 }
        
        end
        
        -- Now we have either the icon or a clone of the generic icon
        
        local group = ui.sections[ SECTION_APPS ].dropdown
        
        
    
    end

    
    ----------------------------------------------------------------------------
    
    return ui
    
end

-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------

function main()

    screen:show()

    local ui = build_ui()
       
    ui:animate_in()
    
end

dolater( main )



