
mediaplayer:reset()
if mediaplayer.reset_viewport_geometry then
    mediaplayer:reset_viewport_geometry()
end

local OEM = "trickplay"

dofile( "globals" )

dofile( "audio-detection/main" )

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
    local SECTION_SEARCH    = 5 -- special

    -------------------------------------------------------------------------------
    -- Style constants
    -------------------------------------------------------------------------------
    
    local BUTTON_TEXT_STYLE = { font = "DejaVu Sans 32px" , color = "FFFFFFFF" }

    -------------------------------------------------------------------------------
    -- The asset cache
    -------------------------------------------------------------------------------
    
    local assets = dofile( "assets-cache" )
        
    -------------------------------------------------------------------------------
    -- All the initial assets
    -------------------------------------------------------------------------------
    
    local ui =
    {
        assets              = assets,
        
        factory             = dofile( "ui-factory" ),
        
        fs_focus            = nil,
        
        bar                 = Group {},
        
        bar_background      = assets( "assets/menu-background.png" ),
        
        button_focus        = assets( "assets/button-focus.png" ),
        
        search_button       = assets( "assets/button-search.png" ),
        
        search_focus        = assets( "assets/button-search-focus.png" ),
        
        logo                = assets( "assets/logo.png" ),
                
        sections =
        {
            [SECTION_APPS] =
            {
                button  = assets( "assets/button-red.png" ),
                text    = Text  { text = strings[ "My Apps" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 120 ,  21 ,  21 , 230 }, -- RED
                height  = 900 - 60 - 30  ,
                init    = dofile( "section-apps" )
            },
            
            [SECTION_SHOWCASE] =
            {
                button  = assets( "assets/button-green.png" ),
                text    = Text  { text = strings[ "Showcase" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {   5 ,  72 ,  18 , 230 }, -- GREEN
                height  = 820,
                init    = dofile( "section-showcase" )
            },
            
            [SECTION_SHOP] =
            {
                button  = assets( "assets/button-yellow.png" ),
                text    = Text  { text = strings[ "App Shop" ] }:set( BUTTON_TEXT_STYLE ),
                color   = { 173 , 178 ,  30 , 230 }, -- YELLOW
                height  = 900 - 60 - 30 ,
                init    = dofile( "section-shop" )
            },
            
            [SECTION_SETTINGS] =
            {
                button  = assets( "assets/button-blue.png" ),
                text    = Text  { text = strings[ "More" ] }:set( BUTTON_TEXT_STYLE ),
                color   = {  24 ,  67 ,  72 , 230 },  -- BLUE
                height  = 380,
                init    = dofile( "section-settings" )
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
    local SEARCH_BUTTON_X_OFFSET    = 4
    local DROPDOWN_POINT_Y_OFFSET   = -2                    -- how far to raise or lower the drop downs
    local DROPDOWN_WIDTH_OFFSET     = -8                   -- The width of the dropdown in relation to its button
    
    -------------------------------------------------------------------------------
    -- Now, create structure and position everything
    -------------------------------------------------------------------------------
    
    ----------------------------------------------------------------------------
    -- The group that holds the bar background and the buttons
    
    ui.bar:set
    {
        name = "menu_bar",
        
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
    
        section.dropdown_bg = ui.factory.make_dropdown( { section.button.w + DROPDOWN_WIDTH_OFFSET , section.height } , section.color )
    
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
    
    ui.search_focus.position = ui.search_button.position
    ui.search_focus.opacity = 0

    ui.bar:add( ui.search_button , ui.search_focus )
    
    
    ui.logo.position = { screen.w - ( ui.logo.w + FIRST_BUTTON_X ) , FIRST_BUTTON_Y }
    
    ui.bar:add( ui.logo )

    -------------------------------------------------------------------------------
    -- UI state information
    -------------------------------------------------------------------------------
    
    local DROPDOWN_TIMEOUT = 200    -- How many milliseconds one has to stay
                                    -- on a button for the dropdown to show up
                        
    ui.strings = strings            -- Store the string table

    ui.focus = SECTION_APPS         -- The section # that has focus
    
    ui.dropdown_timer = Timer( DROPDOWN_TIMEOUT )
    
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
    
        if ui.dropdown_timer then
        
            ui.dropdown_timer:stop()
            ui.dropdown_timer:start()
            
        end
    
    end

    local function animate_out_dropdown( callback )
        
        local ANIMATION_DURATION = 200
        
        local section = ui.sections[ ui.focus ]
        
        if not section then
            return
        end
        
        if not section.dropdown then
            if callback then
                callback( section )
            end
            return
        end
        
        if not section.dropdown.is_visible then return end
        
        section.dropdown:animate
        {
            duration = ANIMATION_DURATION,
            opacity = 0,
            y_rotation = -90,
            on_completed =
                function()
                    section.dropdown:hide()
                    if callback then
                        callback( section )
                    end
                end
        }
    
    end

    local function animate_in_dropdown( )
        
        local ANIMATION_DURATION = 150
        
        local section = ui.sections[ ui.focus ]
        
        if not section then
            return
        end
        
        if not section.dropdown then
            return
        end
        
        if section.dropdown.is_visible then return end
        
        -- If the section has not been initialized, do it now
        
        if section.init then
        
            section:init( )
            
            section.init = nil
        
        end
        
        -- Call its on_show method
        
        if section.on_show then
            section:on_show()
        end
        
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
        
        if not new_focus then
            return
        end
        
        -- Same focus. Laser focus.
        
        if new_focus == ui.focus then
            return
        end
        
        local section = ui.sections[ new_focus ]
        
        -- Focus out of range. Blurred.
        
        if not section and new_focus ~= SECTION_SEARCH then
            return -- The new section is out of range
        end 
        
        animate_out_dropdown()
        
        if ui.focus == SECTION_SEARCH then
        
            ui.search_focus.opacity = 0
            
            ui.button_focus.opacity = 255
            
        end            
        
        ui.focus = new_focus
        
        if ui.focus == SECTION_SEARCH then
        
            ui.search_focus.opacity = 255
            
            ui.button_focus.opacity = 0
            
        else
        
            ui.button_focus.position = section.button.position
            
            reset_dropdown_timer()    
        end
        
    end

    -------------------------------------------------------------------------------
    
    local function enter_section()

        local section = ui.sections[ ui.fs_focus or ui.focus ]
        
        if not section then return end

        if section.init then
            section:init()
            section.init = nil
        end
                
        if section:on_enter() then
        
            if ui.focus == SECTION_SEARCH then
                ui.search_focus.opacity = 0
            else
                ui.button_focus.opacity = 0
            end
            
        end
    
    end

    -------------------------------------------------------------------------------
    -- Invoke the default action for the current section    
    -------------------------------------------------------------------------------
    
    local return_to_dropdown = true
    
    local function do_default_for_section()
    
        if ui.fs_focus and ( ui.focus == ui.fs_focus ) then
            
            if not return_to_dropdown then
                return
            end
            
            -- If they hit enter on the section that is currently full screen
            
            ui.sections[ ui.fs_focus ]:on_hide()
            
            do
            
                local old_sections = ui.sections
                
                local timer = Timer( 1000 )
                
                function timer.on_timer()
                    print( "CLEARING SECTIONS" )
                    for _ , section in ipairs( old_sections ) do
                        if section.on_clear then
                            section:on_clear()
                        end
                    end
                    return false;
                end
                
                timer:start()
                
            end
            
            
            ui.sections = ui.dropdowns
            
            for _ , section in ipairs( ui.sections ) do
                screen:add( section.dropdown )
                section.dropdown:hide()
            end

            ui.fs_focus = nil
            
            animate_in_dropdown()
            
            ui.dropdowns = nil
            
        
        else
        
            -- Otherwise, we are going to ask the currently focused section
            -- to take itself into full screen mode
            
            local section = ui.sections[ ui.focus ]
            
            if not section then
                return
            end
            
            if section.init then
                section:init()
                section.init = nil
            end
            
            if not section.on_default_action then
                return
            end
            
            return_to_dropdown = false
            
            Timer{ interval = 500 , on_timer = function() return_to_dropdown = true return false end }
            
            if section:on_default_action() then
                
                --ui.button_focus.opacity = 0
                
                --ui.fs_focus = ui.focus
                
            end
        
        end
    
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
        
        [ keys.Return   ] = function() do_default_for_section() end,
        
        [ keys.Down     ] = function() enter_section() end,
    }
    
    function ui.bar.on_key_down( _ , key )
    
        local f = key_map[ key ]
        
        if f then
            f()
        end    
    
    end
    
    function ui.dropdown_timer.on_timer( )
    
        animate_in_dropdown()
        
        return false
    
    end
    
    -------------------------------------------------------------------------------
    -- Define ui functions
    -------------------------------------------------------------------------------
    
    function ui:get_client_rect( )
        return { x = 0 , y = ui.bar.h , w = screen.w , h = screen.h - ui.bar.h }
    end
    
    
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
        
        if ui.focus == SECTION_SEARCH then
        
            self.search_focus.opacity = 255
            
        else
        
            self.button_focus.opacity = 255
            
        end
    
    end

    ----------------------------------------------------------------------------
    -- Called by a section when it goes full screen. This spells the end of
    -- dropdowns.
    ----------------------------------------------------------------------------
    
    function ui:on_section_full_screen( new_section )
    
        -- Give the key focus to the screen so we are not interrupted
        
        --screen:grab_key_focus()
        
        -- Kill the dropdown timer
        
        ui.dropdown_timer:stop()
        
        -- Function to show the new section
        
        local function show_new_section( old_section )
        
            -- Get rid of all the dropdowns
            
            if not ui.dropdowns then
            
                ui.dropdowns = {}
            
                for _ , section in ipairs( ui.sections ) do
                    table.insert( ui.dropdowns , section )
                    if section.dropdown then
                        section.dropdown:unparent()
                    end
                end
                
            end
            
                    
            -- TODO: don't like this - I should move the buttons somewhere else
            new_section.button = ui.sections[ ui.focus ].button

            -- Attach the new section
            
            ui.sections[ ui.focus ] = new_section
        
            -- Hide the old one
            
            if ui.fs_focus then
            
                local prev_fs_focus = ui.sections[ ui.fs_focus ]
                
                if prev_fs_focus and prev_fs_focus.on_hide then
                    prev_fs_focus:on_hide()
                end
            
            end
        
        
            -- Make it the full screen focus
            
            ui.fs_focus = ui.focus
            
            -- Tell it to show itself
            
            new_section:on_show()
        
        end
        
        -- Now, animate the dropdown out
        
        local section = ui.sections[ ui.focus ]
        
        if section and section.dropdown then
        
            animate_out_dropdown( show_new_section )
           
        else
            
            show_new_section()
            
        end
    
    end

    ----------------------------------------------------------------------------
    
    function ui:lower( element )
        element:lower( ui.bar )
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


--[[
local assets = dofile( "assets-cache" )

local f = dofile( "ui-factory" )

t = f.make_star( 800 , 0.5 , "FFFFFF" , "FF0000" )

screen:add( t:set{ position = { 200 , 200 } } )


screen:show()
]]
