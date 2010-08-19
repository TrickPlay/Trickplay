Tutorial = {}

Tutorial[1] = Popup:new{
        group=AssetLoader:getImage("TutorialGameplay",{opacity=0}),
        animate_in = {opacity=255, duration=500},
        on_fade_in = function()
        end
}

Tutorial[2] = Popup:new{ group=AssetLoader:getImage("TutorialGameplay",{opacity=0}),
        noRender = true,
        animate_in = {opacity=255, duration=500},
        on_fade_in = function() end
}

--[[
        TUTORIAL[1].fade = "out"
        TUTORIAL[1].on_fade_out = function()
            screen:remove(TUTORIAL.group)
            TUTORIAL = nil
        end
        TUTORIAL[1]:render()
end
--]]