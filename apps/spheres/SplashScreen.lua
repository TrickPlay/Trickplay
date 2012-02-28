
local animated_in = false

--------------------------------------------------------------------------------

local title        = Image{ src = "assets/splash_screen/logo-large.png",   opacity = 0 }

local start_txt    = Image{ src = "assets/splash_screen/start-text.png",   opacity = 0}

local start_circle = Image{ src = "assets/splash_screen/start-circle.png", opacity = 0}

title.anchor_point        = {        title.w/2,        title.h/2 }
start_txt.anchor_point    = {    start_txt.w/2,    start_txt.h/2 }
start_circle.anchor_point = { start_circle.w/2, start_circle.h/2 }


title.position        = {screen_w/2,screen_h/2-100}
start_txt.position    = {screen_w/2,screen_h/2+200}
start_circle.position = {screen_w/2,screen_h/2+200}

menu_layer:add(title,start_txt,start_circle)

--------------------------------------------------------------------------------

local function start_circle_idle_spin(p)
    
    start_circle.y_rotation = {180*p}
    
end

local start_circle_idle_spin = Timer{
    
    interval = 2000,
    
    on_timer = function()
        
        add_step_func( 500, start_circle_idle_spin )
        
    end
    
}

start_circle_idle_spin:stop()

--------------------------------------------------------------------------------

local function fade_in_circle()
    
    add_step_func(
        
        500 ,
        
        function ( p )
            
            start_circle.opacity = 255*p
            
        end,
        
        function ( )
            
            start_circle_idle_spin:on_timer()
            start_circle_idle_spin:start()
            
        end
        
    )
    
end



local function fade_in_text(callback)
    
    add_step_func(
        
        500 ,
        
        function ( p )
            
            start_txt.opacity = 255*p
            
        end,
        
        callback
        
    )
    
end

--------------------------------------------------------------------------------

STATE:add_state_change_function("OFFLINE","INTRO",
    
    function()
        
        add_step_func(
            
            500 ,
            
            function ( p )
                
                title.scale = p
                
                title.opacity = 255*p
                
            end,
            
            function ( )
                
                dolater(500,fade_in_circle)
                dolater(600,fade_in_text, function() STATE:change_state_to("SPLASH") end )
                
            end
            
        )
        
    end
)

--------------------------------------------------------------------------------

STATE:add_state_change_function("SPLASH",nil,
    
    function()
        
        start_circle_idle_spin:stop()
        
        add_step_func(
            
            500 ,
            
            function ( p )
                
                p = 255*(1-p)
                
                title.opacity        = p
                start_txt.opacity    = p
                start_circle.opacity = p
                
            end,
            
            function ( )
                
                title:unparent()
                start_txt:unparent()
                start_circle:unparent()
                
                title        = nil
                start_txt    = nil
                start_circle = nil
                
                STATE:add_state_change_function("SPLASH",nil,function()
                    
                    error("This shouldn't be possible, attempted to got back to the splash screen",2)
                    
                end)
            end
            
        )
        
    end
)








