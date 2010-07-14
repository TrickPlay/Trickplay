ClockConstants = {
    clock_tick_src = "img/timer/on.png",  
    clock_tock_src = "img/timer/off.png",  
    clock_num_ticks = BarneyConstants.intervals,
    clock_z = 2,
    clock_x = 750,
    clock_y = 0,
    tick_width  = 70,
    tick_height = 100
}

ClockView = class(function(self, parent_group)

    self.group = Group{
        x = ClockConstants.clock_x,
        y = ClockConstants.clock_y,
        z = ClockConstants.clock_z,
    }

    self.ticks = {}
    self.tick_img = Images:load(ClockConstants.clock_tick_src)
    
    self.tocks = {}
    self.tock_img = Images:load(ClockConstants.clock_tock_src)


    for i=1,ClockConstants.clock_num_ticks do

        local image_property = {
            x      = (i-1) * ClockConstants.tick_width,
            height = ClockConstants.tick_height,
            width  = ClockConstants.tick_width
        }

        self.ticks[i] = Images:load(ClockConstants.clock_tick_src, image_property)
        
        self.tocks[i] = Images:load(ClockConstants.clock_tock_src, image_property)

        self.tocks[i]:hide()

        self.group:add(self.ticks[i])
        self.group:add(self.tocks[i])
    end

    self.tock_count = ClockConstants.clock_num_ticks
    parent_group:add(self.group)

end)

function ClockView:tock()
    self.ticks[self.tock_count]:hide()
    self.tocks[self.tock_count]:show()
    self.tock_count = self.tock_count - 1
end

function ClockView:reset()
    self.tock_count = ClockConstants.clock_num_ticks
    for i=1,ClockConstants.clock_num_ticks do
        local tick = self.ticks[i]
        local tock = self.tocks[i]
        tick:show()
        tock:hide()
    end
end
