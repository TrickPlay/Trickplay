PLAYER_STATUS_POSITIONS = {
    [1] = {20, 640},
    [2] = {20, 20},
    [3] = {300, 20},
    [4] = {1350, 20},
    [5] = {1630, 20},
    [6] = {1630, 900}
}

PlayerStatusView = Class(nil,
function(self, player, args, ...)
   
    -- Show player info
    self.player = player
    self.show = true

    local color
    if player.is_human then
        color = "green"
    else
        color = "black"
    end

    if not assetman:has_image_of_name("bubble_gray") then
        assetman:load_image("assets/balloons/Bubble-active.png", "bubble_red")
        assetman:load_image("assets/balloons/Bubble-green.png", "bubble_green")
        assetman:load_image("assets/balloons/Bubble-message.png", "bubble_gray")
        assetman:load_image("assets/balloons/Bubble-nonactive.png", "bubble_black")
    end
    self.top = assetman:get_clone("bubble_"..color)
    self.bottom = assetman:get_clone("bubble_gray")
    self.bottom_group = assetman:create_group({y = 60})
    self.bottom_group:add(self.bottom)

--[[
    function self:switch_intelligence()
        if player.is_human then
            color = "green"
        else
            color = "black"
        end

        self.top:dealloc()
        self.top = assetman:get_clone("bubble_"..color)
        self.group:add(self.top)
        
        self.focus:raise_to_top()
        self.title:raise_to_top()
    end
--]]

    self.group = assetman:create_group({
        children = {self.bottom_group, self.top},
        opacity = 0,
        position = PLAYER_STATUS_POSITIONS[player.dog_number],
        name = "player_status_group"..player.dog_number
    })

    -- Blinking red focus
    self.focus = assetman:create_group{
        children = {assetman:get_clone("bubble_red")},
        opacity = 0
    }
    self.group:add(self.focus)
    self.popup = Popup:new{
        group = self.focus,
        noRender = true,
        animate_in = {duration=800, opacity=255},
        animate_out = {duration=800, opacity=0},
        loop = true,
        --on_fade_in = function() end,
        --on_fade_out = function() end,
    }

    function self:startFocus()
        self.popup:start_loop()
        --self.popup.fade = "in"
        --self.popup:render()
    end

    function self:stopFocus()
        self.popup:pause_loop()
        --self.popup.fade = "out"
        --self.popup:render()
    end

    -- Player text
    self.title = assetman:create_text{
        font = PLAYER_NAME_FONT,
        color = Colors.WHITE,
        name = "Player "..player.player_number,
        text = ""
    }
    self.title.on_text_changed = function()
        self.title.anchor_point = {self.title.w/2, self.title.h/2}
        self.title.position = {self.top.w/2, self.top.h/2}
    end
    self.title.text = "Player "..player.player_number
    self.name = self.title.text
    self.title.anchor_point = {self.title.w/2, self.title.h/2}
    self.title.position = {self.top.w/2, self.top.h/2}

    self.action = assetman:create_text{
        font = PLAYER_ACTION_FONT,
        color = Colors.BLACK,
        name = "dog_"..player.dog_number.."_speaking_bubble",
        text = GET_IMIN_STRING()
    }
    self.action.on_text_changed = function()
        self.action.anchor_point = {self.action.w/2, self.action.h/2}
        self.action.position = {
            self.bottom.w/2 + self.bottom.x,
            self.bottom.h/2 + self.bottom.y
        }
    end

    -- Align player attributes
    self.attributes = {self.title, self.action}
    self.group:add(self.title)
    self.bottom_group:add(self.action)

    for i,v in ipairs(self.attributes) do
        v.anchor_point = {v.w/2, v.h/2}
    end
    self.action.position = {
        self.bottom.w/2 + self.bottom.x,
        self.bottom.h/2 + self.bottom.y
    }

    screen:add(self.group)

    if args then
        for k,v in pairs(args) do
            self[k] = v
        end
    end

    function self:update_text(text)
        --if self.show then self.group.opacity = 240 else self.group.opacity = 0 end
        self.title.text = self.name.."  $"..self.player.money
        self.title.anchor_point = {self.title.w/2, self.title.h/2}
        self.title.position = {self.top.w/2, self.top.h/2}

        if text then
            self.action.text = text 
            self.bottom_group:animate{opacity = 255, duration = 300, y = 60}
        end
        self.action.anchor_point = {self.action.w/2, self.action.h/2}
        self.action.position = {self.bottom.w/2, self.bottom.h/2 + self.bottom.y}
    end

    function self:update_name(name)
        if type(name) ~= "string" then return end
        self.name = string.sub(name, 1, 1)..string.lower(string.sub(name, 2, 8))
        self:update_text()
    end

    function self:hide_bottom()
        self.bottom_group:animate{opacity = 0,duration = 300, y = 0}
    end

    function self:dim()
        self.group.opacity = 100
        --self.show = 2
    end

    function self:hide()
        self.group:animate{opacity = 0, duration = 300}
        --self.show = 0
    end

    function self:display()
        self.group:animate{opacity = 240, duration=300}
        --self.show = 1
    end

    function self:dealloc()
    print("status dealloc", self)
    if not self.top then error("wtf",2 ) end
        self.top:dealloc()
        self.top = nil
        self.bottom:dealloc()
        self.bottom = nil
        self.action:dealloc()
        self.action = nil
        self.bottom_group:dealloc()
        self.bottom_group = nil
        self.popup = nil
        self.focus:dealloc()
        self.focus = nil
        self.title:dealloc()
        self.title = nil
        self.group:dealloc()
        self.group = nil
    end

end)
