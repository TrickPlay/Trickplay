TutorialView = Class(View, function(self, model, ...)
   
   -- Register view
    self._base.init(self, model)
    
    -- Construct the slides
    local tutorial = {}
    self.tutorial = tutorial

    local tutorialGroup = Group{}
    self.tutorialGroup = tutorialGroup
    screen:add(tutorialGroup)

    for i=1, 4 do
        tutorial[i] = Popup:new{ group=AssetLoader:getImage("Tutorial"..i,{}), noRender = true, }
    end
    
    for i, slide in ipairs(tutorial) do
        self.tutorialGroup:add(slide.group)
        slide.group.opacity = 140
        slide.group.anchor_point = { slide.group.w/2, slide.group.h/2 } -- Anchored in the center
        slide.group.position = { screen.w * (3/2), screen.h/2 } -- They start off screen to the right
        slide.animate_start = {opacity=140, x=screen.w * (3/2), duration=500, mode="EASE_OUT_QUAD"} -- This animates them back to the start
        slide.animate_in = {opacity=255, x=screen.w/2, duration=500, mode="EASE_OUT_QUAD"} -- This animates them into the center screen
        slide.animate_out = {opacity=140, x=-screen.w/2, duration=500, mode="EASE_OUT_QUAD"} -- This animates them off to the left
        slide.on_fade_in = function() end
        slide.on_fade_out = function() end
    end
    
    function self:getBounds()
        return 1, #tutorial
    end
    
    -- Initialize
    function self:initialize()
       self:set_controller(TutorialController(self))
    end
    
    -- Update
    function self:update(p, c, n)
    
        if model:get_active_component() == Components.TUTORIAL then
            
            tutorialGroup:raise_to_top()
            tutorialGroup.opacity = 255
            
            -- Active slide moves to center
            if tutorial[c] then
                local current = tutorial[c]
                current.fade = "in"
                current:render()
                current.group:raise_to_top()
            end
            
            -- Previous should move to the left
            if tutorial[p] then
                local current = tutorial[p]
                current.fade = "out"
                current:render()
                current.group:raise_to_top()
            end
            
            -- Next slide should be waiting on the right
            if tutorial[n] then
                local current = tutorial[n]
                current.group:animate( current.animate_start )
            end
            
        else
            tutorialGroup.opacity = 0
        end
        
    end
    
end)
