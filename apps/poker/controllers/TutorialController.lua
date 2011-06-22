-- TODO: fix the completely screwed up phone controls
-- uses keypresses but touches come simultaneously!

TutorialController = Class(Controller, function(self, view, router, ...)
    self._base.init(self, router, Components.TUTORIAL)
    
    local controller = self
    
    local selector = 2

    -- Position in tutorial
    local p = 0 -- Previous slide
    local c = 1 -- Current slide
    local n = 2 -- Next slide

    local function leave_help()
        selector = 2
        p = 0
        c = 1
        n = 2
        ctrlman:disable_on_key_down()
        router:set_active_component(router.previous_component)
        router:notify()
    end

    local keyTable = {
        [keys.Left] = function(self) self:move(Directions.LEFT) end,
        [keys.Right] = function(self) self:move(Directions.RIGHT) end,
        [keys.Return] = function(self)
        --[[
            if selector == 1 and c == 1 
            or selector == 2 and c == 2 then leave_help()
            elseif selector == 2 and c == 1 then self:move_slide_right()
            elseif selector == 1 and c == 2 then self:move_slide_left()
            else error("wtf")
            end
        --]]
        end,
    }
    keyTable[keys.OK] = keyTable[keys.Return]

    function self:handle_click(controller, x, y)
        if selector == 1 and c == 1 
        or selector == 2 and c == 2 then leave_help()
        elseif selector == 2 and c == 1 then self:move_slide_right()
        elseif selector == 1 and c == 2 then self:move_slide_left()
        else error("wtf")
        end
    end
    
    function self:on_key_down(k)
        print("Tutorial on_key_down")
        if keyTable[k] then
            keyTable[k](self)
        end
    end

    function self:move(dir)
        screen:grab_key_focus()
        
        if(0 ~= dir[1]) then
            selector = Utils.clamp(1, selector+dir[1], 2)
            view:move_focus(selector)
            do return end
        
            local new_c = c + dir[1]
            local lower, upper = view:getBounds()
            if new_c >= lower and new_c <= upper then
                p = p + dir[1]
                c = c + dir[1]
                n = n + dir[1]
            else
                leave_help()
            end
        
        elseif(0 ~= dir[2]) then
        
        end
        
        router:notify()
    end

    function self:move_slide_left()
        p = p - 1
        c = c - 1
        n = n - 1

        router:notify()
    end
    
    function self:move_slide_right()
        p = p + 1
        c = c + 1
        n = n + 1

        router:notify()
    end

    function self:update(event)
        if event:is_a(KbdEvent) then
            self:on_key_down(event.key)
        elseif event:is_a(NotifyEvent) then
            self:update_view()
        end
    end
    
    function self:update_view()
        if router:get_active_component() == Components.TUTORIAL then
            ctrlman:enable_on_key_down()
            view:move_focus(selector)
            view:update(p, c, n)
        end
    end

    function self:on_controller_disconnected()
        leave_help()
        local disconnect_timer = Timer()
        disconnect_timer.interval = 1000
        function disconnect_timer:on_timer()
            disconnect_timer:stop()
            disconnect_timer.on_timer = nil
            router:get_active_controller():on_controller_disconnected()
        end
        disconnect_timer:start()
    end

end)
