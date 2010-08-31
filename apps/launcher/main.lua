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
    -- Section index constants. These also determine their order.
    -------------------------------------------------------------------------------
    
    local SECTION_APPS      = 1
    local SECTION_SHOWCASE  = 2
    local SECTION_SHOP      = 3
    local SECTION_SETTINGS  = 4

    -------------------------------------------------------------------------------
    -- Style constants
    -------------------------------------------------------------------------------
    
    local BUTTON_TEXT_STYLE = { font = "DejaVu Sans 32px" , color = "FFFFFFFF" }
    
    -------------------------------------------------------------------------------
    -- All the initial assets
    -------------------------------------------------------------------------------
    
    local ui =
    {
        bar                 = Group {},
        
        bar_background      = Image { src = "assets/menu-background.png" },
        
        button_focus        = Image { src = "assets/button-focus.png" },
        
        search_button       = Image { src = "assets/button-search.png" },
        
        search_focus        = Image { src = "assets/button-search-focus.png" },
        
        logo                = Image { src = "assets/logo.png" },
                
        sections =
        {
            [SECTION_APPS] =
            {
                button  = Image { src = "assets/button-red.png" },
                text    = Text  { text = strings[ "My Apps" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 120 ,  21 ,  21 , 230 }, -- RED
                height  = 870,
                init    = dofile( "section-apps.lua" )
            },
            
            [SECTION_SHOWCASE] =
            {
                button  = Image { src = "assets/button-green.png" },
                text    = Text  { text = strings[ "Showcase" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {   5 ,  72 ,  18 , 230 }, -- GREEN
                height  = 620,
                init    = dofile( "section-showcase.lua" )
            },
            
            [SECTION_SHOP] =
            {
                button  = Image { src = "assets/button-yellow.png" },
                text    = Text  { text = strings[ "App Shop" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 173 , 178 ,  30 , 230 }, -- YELLOW
                height  = 620,
                init    = dofile( "section-shop.lua" )
            },
            
            [SECTION_SETTINGS] =
            {
                button  = Image { src = "assets/button-blue.png" },
                text    = Text  { text = strings[ "More" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {  24 ,  67 ,  72 , 230 },  -- BLUE
                height  = 320,
                init    = dofile( "section-settings.lua" )
            }
        }
    }
    
    -------------------------------------------------------------------------------
    -- Position constants
    -------------------------------------------------------------------------------
    
    local BUTTON_TEXT_X_OFFSET      = 20
    local BUTTON_TEXT_Y_OFFSET      = 22
    local FIRST_BUTTON_X            = 13                    -- x coordinate of first button
    local FIRST_BUTTON_Y            = 9                     -- y coordinate of first button
    local BUTTON_X_OFFSET           = 7                     -- distance between left side of buttons
    local SEARCH_BUTTON_X_OFFSET    = 5
    local DROPDOWN_POINT_Y_OFFSET   = -2                    -- how far to raise or lower the drop downs
    local DROPDOWN_WIDTH_OFFSET     = -16                   -- The width of the dropdown in relation to its button
    
    -------------------------------------------------------------------------------
    -- The function that makes drop downs - it returns a Canvas.
    -------------------------------------------------------------------------------
    
    local make_dropdown = dofile( "dropdown.lua" )
    
    -------------------------------------------------------------------------------
    -- Now, create structure and position everything
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
    
    local i = 0
    
    local left = FIRST_BUTTON_X
    
    for _ , section in ipairs( ui.sections ) do
    
        section.ui = ui
        
        -- Create the dropdown background
    
        section.dropdown_bg = make_dropdown( { section.button.w + DROPDOWN_WIDTH_OFFSET , section.height } , section.color )
    
        -- Position the button and text for this section
        
        section.button.position =
        {
            left,
            FIRST_BUTTON_Y
        }
        
        left = left + BUTTON_X_OFFSET + section.button.w
    
        section.text.position =
        {
            section.button.x + BUTTON_TEXT_X_OFFSET ,
            section.button.y + BUTTON_TEXT_Y_OFFSET
        }
        
        -- Create the dropdown group
        
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
        
        -- Add the text and button
        
        ui.bar:add( section.button , section.text )
        
        -- Make sure its Z is correct with respect to the focus image
        
        section.button:lower( ui.button_focus )
        
        section.text:raise( ui.button_focus )
        
        -- Add the section dropdown to the screen
        
        screen:add( section.dropdown )
        
        i = i + 1
        
    end

    -------------------------------------------------------------------------------
    -- Add the search button and the logo
    -------------------------------------------------------------------------------
    
    ui.search_button.position = { left + SEARCH_BUTTON_X_OFFSET , FIRST_BUTTON_Y }
    
    ui.bar:add( ui.search_button )
    
    
    ui.logo.position = { screen.w - ( ui.logo.w + FIRST_BUTTON_X ) , FIRST_BUTTON_Y }
    
    ui.bar:add( ui.logo )

    -------------------------------------------------------------------------------
    -- UI state information
    -------------------------------------------------------------------------------
    
    local DROPDOWN_TIMEOUT = 200    -- How many milliseconds one has to stay
                                    -- on a button for the dropdown to show up
                        
    ui.strings = strings            -- Store the string table

    ui.focus = SECTION_APPS         -- The section # that has focus
    
    ui.dropdown_timer = Timer( DROPDOWN_TIMEOUT / 1000 )
    
    ui.color_keys =             -- Which section # to focus with the given key
    {
        [ keys.RED    ] = SECTION_APPS,
        [ keys.GREEN  ] = SECTION_SHOWCASE,
        [ keys.YELLOW ] = SECTION_SHOP,
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
        
        -- If the section has not been initialized, do it now
        
        if section.init then
        
            section:init( ui )
            
            section.init = nil
        
        end
        
        -- Call its on_show method
        
        pcall( section.on_show , section )
        
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
    
    local function enter_section()
    
        local section = ui.sections[ ui.focus ]
        
        if not section then return end
        
        ui.button_focus.opacity = 0
        
        section:on_enter()
    
    end


    -------------------------------------------------------------------------------
    -- Handlers
    -------------------------------------------------------------------------------
        
    local key_map =
    {
        [ keys.Left     ] = function() move_focus( ui.focus - 1 ) end,
        [ keys.Right    ] = function() move_focus( ui.focus + 1 ) end,
        
        [ keys.RED      ] = function() move_focus( ui.color_keys[ keys.RED ] ) end,
        [ keys.GREEN    ] = function() move_focus( ui.color_keys[ keys.GREEN ] ) end,
        [ keys.YELLOW   ] = function() move_focus( ui.color_keys[ keys.YELLOW ] ) end,
        [ keys.BLUE     ] = function() move_focus( ui.color_keys[ keys.BLUE ] ) end,
        
        -- For keyboards
        
        [ keys.F5       ] = function() move_focus( ui.color_keys[ keys.RED ] ) end,
        [ keys.F6       ] = function() move_focus( ui.color_keys[ keys.GREEN ] ) end,
        [ keys.F7       ] = function() move_focus( ui.color_keys[ keys.YELLOW ] ) end,
        [ keys.F8       ] = function() move_focus( ui.color_keys[ keys.BLUE ] ) end,
        
        -- TODO : Pressing OK on a button may do something else
        
        [ keys.Return   ] = function() animate_in_dropdown() end,
        
        [ keys.Down     ] = function() enter_section() end,
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
    -- Called by a section when it wants to lose focus
    -- (When you press UP at the top selection of a dropdown)
    ----------------------------------------------------------------------------    
    
    function ui:on_exit_section()
    
        self.bar:grab_key_focus()
        self.button_focus.opacity = 255
    
    end
    
    ----------------------------------------------------------------------------
    -- Hide everything unless show_it is true (only for debugging)
    
    if not show_it then
    
        ui:hide()
    
    end

    ----------------------------------------------------------------------------
    
    return ui
    
end

-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------

function main()

    screen:show()

    --local
    
    ui = build_ui( true)
       
    ui:animate_in()
    
end

main()



