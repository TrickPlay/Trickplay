local robot = Group { name = "robot" }


local Left_Hand = Image { name = "Left_Hand", src = "assets/robot-part/robot/Left_Hand.png" }
Left_Hand:move_anchor_point(145, 10)

local Left_Foot = Image { name = "Left_Foot", src = "assets/robot-part/robot/Left_Foot.png" }
Left_Foot:move_anchor_point(217, 8)

local Left_Lower_Leg = Image { name = "Left_Lower_Leg", src = "assets/robot-part/robot/Left_Lower_Leg.png" }
Left_Lower_Leg:move_anchor_point(52, 6)

local Left_Thigh = Image { name = "Left_Thigh", src = "assets/robot-part/robot/Left_Thigh.png" }
Left_Thigh:move_anchor_point(189, 31)

local Left_Hip = Image { name = "Left_Hip", src = "assets/robot-part/robot/Left_Hip.png" }
Left_Hip:move_anchor_point(217, 60)

local Body_Inside = Image { name = "Body_Inside", src = "assets/robot-part/robot/Body_Inside.png" }
Body_Inside:move_anchor_point(340, 360)

local Pelvis = Image { name = "Pelvis", src = "assets/robot-part/robot/Pelvis.png" }
Pelvis:move_anchor_point(119, 90)

local Pipe_In_Front = Image { name = "Pipe_In_Front", src = "assets/robot-part/robot/Pipe_In_Front.png" }
Pipe_In_Front:move_anchor_point(405, 50)

local Pipe_On_Back = Image { name = "Pipe_On_Back", src = "assets/robot-part/robot/Pipe_On_Back.png" }
Pipe_On_Back:move_anchor_point(21, 16)

local Mouth_Inside = Image { name = "Mouth_Inside", src = "assets/robot-part/robot/Mouth_Inside.png" }
Mouth_Inside:move_anchor_point(117, 50)

local Head = Image { name = "Head", src = "assets/robot-part/robot/Head.png" }
Head:move_anchor_point(800, 594)

local Jaw = Image { name = "Jaw", src = "assets/robot-part/robot/Jaw.png" }
Jaw:move_anchor_point(280, 70)

local Tire = Image { name = "Tire", src = "assets/robot-part/robot/Tire.png" }
Tire:move_anchor_point(330, 295)

local Right_Hip = Image { name = "Right_Hip", src = "assets/robot-part/robot/Right_Hip.png" }
Right_Hip:move_anchor_point(282, 80)

local Right_Thigh = Image { name = "Right_Thigh", src = "assets/robot-part/robot/Right_Thigh.png" }
Right_Thigh:move_anchor_point(80, 40)

local Right_Lower_Leg = Image { name = "Right_Lower_Leg", src = "assets/robot-part/robot/Right_Lower_Leg.png" }
Right_Lower_Leg:move_anchor_point(50, 32)

local Right_Foot = Image { name = "Right_Foot", src = "assets/robot-part/robot/Right_Foot.png" }
Right_Foot:move_anchor_point(392, 20)

local Right_Hand = Image { name = "Right_Hand", src = "assets/robot-part/robot/Right_Hand.png" }
Right_Hand:move_anchor_point(250, 48)
--[[
local Shadow = Image { name = "Shadow", src = "assets/robot-part/robot/Shadow.png" }
Shadow:move_anchor_point(Shadow.w/2, Shadow.h/2)
robot:add(Shadow)
]]--

--  These positions done by eyeballing the original
Head.position               = {     0,    0 }
Mouth_Inside.position       = {  -164,   83 }
Jaw.position                = {   -70,   55 }
Tire.position               = {   420,  -60 }
Body_Inside.position        = {   250,  -90 }
Left_Hand.position          = {    50,  130 }
Pipe_On_Back.position       = {   440,  360 }
Pelvis.position             = {   370,  180 }
Pipe_In_Front.position      = {   340,   80 }
Right_Hand.position         = {   420,  -60 }
Right_Hip.position          = {   600,  550 }
Right_Thigh.position        = {   440,  640 }
Right_Lower_Leg.position    = {   430,  790 }
Right_Foot.position         = {   580,  960 }
Left_Hip.position           = {   400,  500 }
Left_Thigh.position         = {   240,  640 }
Left_Lower_Leg.position     = {   100,  710 }
Left_Foot.position          = {   140,  910 }

robot:add(Left_Hand)
robot:add(Left_Foot)
robot:add(Left_Lower_Leg)
robot:add(Left_Thigh)
robot:add(Left_Hip)
robot:add(Body_Inside)
robot:add(Pipe_On_Back)
robot:add(Pelvis)
robot:add(Pipe_In_Front)
robot:add(Tire)
robot:add(Mouth_Inside)
robot:add(Head)
robot:add(Jaw)
robot:add(Right_Hip)
robot:add(Right_Foot)
robot:add(Right_Lower_Leg)
robot:add(Right_Thigh)
robot:add(Right_Hand)


robot.scale = { 1/2, 1/2 }
robot.position = { 1400, 440 }

return robot
