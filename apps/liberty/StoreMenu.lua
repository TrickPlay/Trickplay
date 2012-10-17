
return function(upper,lower)
    
    local instance = Group()
    
    instance:add(upper,lower)
    
    local upper_y = 300
    local lower_y = 900
    local upper_z = -200
    local lower_z = 0
    
    upper.y = upper_y
    upper.z = upper_z
    lower.y = lower_y
    lower.z = lower_z
    
    local dosado_1 = Animator{
        duration = 600,
        properties = {
            {
                source = upper, name = "y",
                keys = {
                    {0.0,"LINEAR",upper_y},
                    {0.6,"LINEAR",lower_y},
                    {1.0,"LINEAR",lower_y},
                }
            },
            {
                source = upper, name = "z",
                keys = {
                    {0.0,"LINEAR",upper_z},
                    {0.4,"LINEAR",upper_z},
                    {1.0,"LINEAR",lower_z},
                }
            },
            {
                source = lower, name = "y",
                keys = {
                    {0.0,"LINEAR",lower_y},
                    {0.6,"LINEAR",upper_y},
                    {1.0,"LINEAR",upper_y},
                }
            },
            {
                source = lower, name = "z",
                keys = {
                    {0.0,"LINEAR",lower_z},
                    {0.4,"LINEAR",lower_z},
                    {1.0,"LINEAR",upper_z},
                }
            },
        }
    }
    
    dosado_1.timeline.on_completed = function()
        upper:raise_to_top()
        upper.z = lower_z
        upper:grab_key_focus()
    end
    
    local dosado_2 = Animator{
        duration = 600,
        properties = {
            {
                source = lower, name = "y",
                keys = {
                    {0.0,"LINEAR",upper_y},
                    {0.6,"LINEAR",lower_y},
                    {1.0,"LINEAR",lower_y},
                }
            },
            {
                source = lower, name = "z",
                keys = {
                    {0.0,"LINEAR",upper_z},
                    {0.4,"LINEAR",upper_z},
                    {1.0,"LINEAR",lower_z},
                }
            },
            {
                source = upper, name = "y",
                keys = {
                    {0.0,"LINEAR",lower_y},
                    {0.6,"LINEAR",upper_y},
                    {1.0,"LINEAR",upper_y},
                }
            },
            {
                source = upper, name = "z",
                keys = {
                    {0.0,"LINEAR",lower_z},
                    {0.4,"LINEAR",lower_z},
                    {1.0,"LINEAR",upper_z},
                }
            },
        }
    }
    
    dosado_2.timeline.on_completed = function()
        lower:raise_to_top()
        lower.z = lower_z
        lower:grab_key_focus()
    end
    
    local switched = false
    local keypresses = {
        [keys.Up] = function()
            if not switched then
                dosado_1:start()
            else
                dosado_2:start()
            end
            switched = not switched
            instance:grab_key_focus()
        end,
        [keys.Down] = function()
            if not switched then
                dosado_1:start()
            else
                dosado_2:start()
            end
            switched = not switched
            instance:grab_key_focus()
        end,
        [keys.BACK] = function()
            print("here")
            instance:animate{
                duration = 300,
                z = -300,
                opacity = 0,
            }
            main_menu:grab_key_focus()
            main_menu:animate{
                duration = 300,
                z = 0,
                opacity = 255,
            }
            
        end,
    }
    
    function instance:on_key_down(k)
    
        return keypresses[k] and keypresses[k]()
    end
    function instance:on_key_focus_in(self)
        instance:animate{
            duration = 300,
            z = 0,
            opacity = 255,
        }
        if not switched then
            lower:on_key_focus_in()
        else
            upper:on_key_focus_in()
        end
    end
    function instance:on_key_focus_out(self)
        if not switched then
            lower:on_key_focus_out()
        else
            upper:on_key_focus_out()
        end
    end
    --instance.z = -300
    instance.opacity = 0
    return instance
end