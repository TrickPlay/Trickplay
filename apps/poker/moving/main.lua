dofile("Class.lua")
dofile("State.lua")
dofile("Players.lua")
dofile("Control.lua")
dofile("TimerWrapper.lua")

t = TimerWrapper()
players = {
   HumanPlayer(),
   ComputerPlayer(),
   ComputerPlayer(),
   ComputerPlayer(),
   HumanPlayer(),
   ComputerPlayer()
}
texts = {
   Text{text="p1", color="FFFFFF", font="Sans 40px",y=0,opacity=255},
   Text{text="p2", color="FFFFFF", font="Sans 40px",y=100,opacity=0},
   Text{text="p3", color="FFFFFF", font="Sans 40px",y=200,opacity=0},
   Text{text="p4", color="FFFFFF", font="Sans 40px",y=300,opacity=0},
   Text{text="p5", color="FFFFFF", font="Sans 40px",y=400,opacity=0}
}


state = State()
local num = state:get_state()
state_ui = Text{text=tostring(num), color="FFFFFF", font="Sans 40px", position={960,960}}
local control = Control()
function screen:on_key_down(k)
   control:on_event(KbdEvent{key=k})
end
for _,text in ipairs(texts) do
   screen:add(text)
end
screen:add(state_ui)
screen:show()