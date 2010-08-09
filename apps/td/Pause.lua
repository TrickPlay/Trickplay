local resumeFocus = AssetLoader:getImage("ResumeFocus",{})
local saveFocus = AssetLoader:getImage("SaveAndQuitFocus",{})

local list = {
        { AssetLoader:getImage("Resume",{name="resume", extra = {overlay = resumeFocus}}) },
        { AssetLoader:getImage("SaveAndQuit",{name="save", extra = {overlay = saveFocus}}) }
}
  
local g = Group{z=20}
local box = Rectangle{w=screen.w, h=300, color="000000"}
g.y = screen.h/2 - 200
g:add(box)
        
PauseMenu = Menu:new{container = g, list = list}
PauseMenu:create_key_functions()
PauseMenu:button_directions()
PauseMenu:create_buttons()	        
PauseMenu:update_cursor_position()

for i=1, #list do

        list[i][1].position = { -list[i][1].w/2 + screen.w/2, list[i][1].y } --list[i][1].h/2}

end

PauseMenu:overlay()
PauseMenu.updateOverlays()
PauseMenu.container.z = 40
PauseMenu.container.opacity = 0

screen:add(PauseMenu.container)

local p = Popup:new{group = PauseMenu.container, draw = true, fadeSpeed = 250, fade="no", on_fade_in = function() end, on_fade_out = function() end}

function PauseMenu:show()
        
        mediaplayer:pause()
        
        p.fade = "in"
        p:render()
        
        ACTIVE_CONTAINER = self
	keyboard_key_down = self.buttons.on_key_down
        
end

function PauseMenu:hide()
        
        ACTIVE_CONTAINER = BoardMenu
	keyboard_key_down = BoardMenu.buttons.on_key_down

end

PauseMenu.buttons.extra.p = function()

        p.fade = "out"

        p.on_fade_out = function()
                
                BoardMenu.buttons.extra.p()
                mediaplayer:play()
                
        end
        
        p:render()

end

PauseMenu.buttons.extra.r = function()

        PauseMenu.buttons.extra.p()

end

PauseMenu.buttons.extra.s = function()

        SOUND = not SOUND
        
        if SOUND then mediaplayer:play() else mediaplayer:pause() end

end






