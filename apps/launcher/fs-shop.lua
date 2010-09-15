
return
function( ui )

    local section   = {}
    
    local assets    = ui.assets
    
    local factory   = ui.factory
    
    ---------------------------------------------------------------------------
    -- Shop data
    ---------------------------------------------------------------------------
    
    -- The shop API
    
    local api = dofile( "shop-api" )
    
    local function fetch_initial_data()
    
        -- The result of getting a list of featured apps from the API
        
        local featured_apps
        
        -- The result of getting a list of all apps from the API
        
        local all_apps
        
        -- Whether we have enough results to build the main UI
        
        local INITIAL_DATA_FETCHING = 1 -- We are getting the data
        local INITIAL_DATA_MISSING  = 2 -- We were unable to get all the data (store is down)
        local INITIAL_DATA_COMPLETE = 3 -- We got all the data
        
        local initial_data = INITIAL_DATA_FETCHING
        
        -- The functions that receive the initial data
        
        local function featured_apps_callback( results )
            
            if initial_data ~= INITIAL_DATA_FETCHING then
                return
            end
            
            if results.stat ~= "ok" then
                initial_data = INITIAL_DATA_MISSING
                section:data_arrived( )
                return
            end
            
            if tonumber( results.results ) < 2 then
                initial_data = INITIAL_DATA_MISSING
                section:data_arrived( )
                return
            end
            
            featured_apps = results
            
            if all_apps then
                initial_data = INITIAL_DATA_COMPLETE
                section:data_arrived( featured_apps , all_apps )
            end
        end
        
        local function all_apps_callback( results )
            if initial_data ~= INITIAL_DATA_FETCHING then
                return
            end
            
            if results.stat ~= "ok" then
                initial_data = INITIAL_DATA_MISSING
                section:data_arrived( )
                return
            end
            
            all_apps = results
            
            if featured_apps then
                initial_data = INITIAL_DATA_COMPLETE
                section:data_arrived( featured_apps , all_apps )
            end
            
        end
        
        -- Now, fetch the initial data
        
        -- TODO: Add a 'max' parameter when that is functional
        
        api:search( { category = "featured" } , featured_apps_callback )
        api:search( { } , all_apps_callback )
        
    end

    fetch_initial_data()

    ---------------------------------------------------------------------------
    -- UI
    ---------------------------------------------------------------------------
    
    local group = nil
    
    -- This builds the initial 'loading UI' until the data comes back
    
    local function build_ui()
    
        if group then
            group:raise_to_top()
            group.opacity = 255
            return
        end
        
        local client_rect = ui:get_client_rect()
        
        group = Group
        {
            size = { client_rect.w , client_rect.h } ,
            position = { client_rect.x , client_rect.y },
            clip = { 0 , 0 , client_rect.w , client_rect.h },
            children =
            {
                Text{ text = "Loading..." , color = "FFFFFF" , font = "60px" }
            }
        }
        
        screen:add( group )
        
        group:raise_to_top()
               
    end
    
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    
    function section.data_arrived( featured_apps , all_apps )
    
        if not featured_apps or not all_apps then
            group:clear()
            group:add( Text{ font = "60px" , text = "Error!" , color = "FFFFFF" } )
            return
        end
        
        -- The initial data is here, we can build the UI
    
    end
    
    ---------------------------------------------------------------------------
    -- Handlers for the main menu events
    ---------------------------------------------------------------------------
    
    function section.on_show( section )
    
        build_ui()
        
        function group.on_key_down( group , key )
            
            print( "SHOP FS" , "KEY" , key )
            
            if key == keys.Up then
            
                ui:on_exit_section()  
            
            end
        
        end
            
    end
    
    function section.on_enter( section )
    
        group:grab_key_focus()
        
        return true
        
    end
    
    function section.on_default_action( section )
    
        ui:on_section_full_screen( section )
        
        return true
    
    end

    function section.on_hide( section )
        
        if group then
            group.opacity = 0
        end
        
    end
    
    ---------------------------------------------------------------------------

    return section
        
end