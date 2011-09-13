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
z_rotation = { 0, 330, 295 }
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
Right_Hand.z_rotation = { 0, 250, 48 }
Right_Hand:move_anchor_point(250, 48)

local Shadow = Image { name = "Shadow", src = "assets/robot-part/robot/Shadow.png" }
Shadow:move_anchor_point(Shadow.w/2, Shadow.h/2)


robot.extra = {}

robot.extra.states = AnimationState( {
                                        duration = 250,
                                        transitions = {
                                            {
                                                --  These positions done by eyeballing the original
                                                source = "*",
                                                target = "start",
                                                keys = {
                                                    { Head, "position", "EASE_IN_OUT_SINE",             {     0,    0 }, 0, 0 },
                                                    { Jaw, "position", "EASE_IN_OUT_SINE",              {   -70,   55 }, 0, 0 },
                                                    { Mouth_Inside, "position", "EASE_IN_OUT_SINE",     {  -164,   83 }, 0, 0 },
                                                    { Left_Foot, "position", "EASE_IN_OUT_SINE",        {   140,  910 }, 0, 0 },
                                                    { Left_Hand, "position", "EASE_IN_OUT_SINE",        {    50,  130 }, 0, 0 },
                                                    { Left_Hip, "position", "EASE_IN_OUT_SINE",         {   400,  500 }, 0, 0 },
                                                    { Left_Lower_Leg, "position", "EASE_IN_OUT_SINE",   {   100,  710 }, 0, 0 },
                                                    { Left_Thigh, "position", "EASE_IN_OUT_SINE",       {   240,  640 }, 0, 0 },
                                                    { Pelvis, "position", "EASE_IN_OUT_SINE",           {   370,  180 }, 0, 0 },
                                                    { Pipe_In_Front, "position", "EASE_IN_OUT_SINE",    {   340,   80 }, 0, 0 },
                                                    { Pipe_On_Back, "position", "EASE_IN_OUT_SINE",     {   440,  360 }, 0, 0 },
                                                    { Right_Foot, "position", "EASE_IN_OUT_SINE",       {   580,  960 }, 0, 0 },
                                                    { Right_Hand, "position", "EASE_IN_OUT_SINE",       {   420,  -60 }, 0, 0 },
                                                    { Right_Hand, "z_rotation", "EASE_IN_OUT_SINE",     0,               0, 0 },
                                                    { Right_Hip, "position", "EASE_IN_OUT_SINE",        {   600,  550 }, 0, 0 },
                                                    { Right_Lower_Leg, "position", "EASE_IN_OUT_SINE",  {   430,  790 }, 0, 0 },
                                                    { Right_Thigh, "position", "EASE_IN_OUT_SINE",      {   440,  640 }, 0, 0 },
                                                    { Body_Inside, "position", "EASE_IN_OUT_SINE",      {   250,  -90 }, 0, 0 },
                                                    { Tire, "position", "EASE_IN_OUT_SINE",             {   420,  -60 }, 0, 0 },
                                                    { Tire, "z_rotation", "EASE_IN_OUT_SINE",           0,               0, 0 },
                                                    { Shadow, "position", "EASE_IN_OUT_SINE",           {   100, 1100 }, 0, 0 },
                                                },
                                            },
                                            {
                                                source = "*",
                                                target = "jiggle",
                                                keys = {
                                                    { Head, "position", "EASE_IN_OUT_SINE",             {     0,  -20 }, 0, 0 },
                                                    { Jaw, "position", "EASE_IN_OUT_SINE",              {   -60,    0 }, 0, 0 },
                                                    { Mouth_Inside, "position", "EASE_IN_OUT_SINE",     {  -154,   28 }, 0, 0 },
                                                    { Left_Foot, "position", "EASE_IN_OUT_SINE",        {   140,  910 }, 0, 0 },
                                                    { Left_Hand, "position", "EASE_IN_OUT_SINE",        {    40,  110 }, 0, 0 },
                                                    { Left_Hip, "position", "EASE_IN_OUT_SINE",         {   400,  490 }, 0, 0 },
                                                    { Left_Lower_Leg, "position", "EASE_IN_OUT_SINE",   {   100,  708 }, 0, 0 },
                                                    { Left_Thigh, "position", "EASE_IN_OUT_SINE",       {   240,  630 }, 0, 0 },
                                                    { Pelvis, "position", "EASE_IN_OUT_SINE",           {   370,  160 }, 0, 0 },
                                                    { Pipe_In_Front, "position", "EASE_IN_OUT_SINE",    {   340,   60 }, 0, 0 },
                                                    { Pipe_On_Back, "position", "EASE_IN_OUT_SINE",     {   440,  340 }, 0, 0 },
                                                    { Right_Foot, "position", "EASE_IN_OUT_SINE",       {   580,  960 }, 0, 0 },
                                                    { Right_Hand, "z_rotation", "EASE_IN_OUT_SINE",     5,               0, 0 },
                                                    { Right_Hip, "position", "EASE_IN_OUT_SINE",        {   600,  540 }, 0, 0 },
                                                    { Right_Lower_Leg, "position", "EASE_IN_OUT_SINE",  {   430,  788 }, 0, 0 },
                                                    { Right_Thigh, "position", "EASE_IN_OUT_SINE",      {   440,  630 }, 0, 0 },
                                                    { Body_Inside, "position", "EASE_IN_OUT_SINE",      {   250, -100 }, 0, 0 },
                                                    { Tire, "position", "EASE_IN_OUT_SINE",             {   420,  -70 }, 0, 0 },
                                                    { Tire, "z_rotation", "EASE_IN_OUT_SINE",           10,              0, 0 },
                                                    { Shadow, "position", "EASE_IN_OUT_SINE",           {   100, 1100 }, 0, 0 },
                                                },
                                            },
                                        },
})

robot.extra.states:warp("start")

robot:add(Shadow)
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
robot.position = { screen.w/2, 440 }


robot.extra.states.on_completed = function()
    robot.extra.jiggle()
end

robot.extra.jiggle = function()
    if(robot.extra.states.state == "start") then
        robot.extra.states.state = "jiggle"
    elseif(robot.extra.states.state == "jiggle") then
        robot.extra.states.state = "start"
    end
end

return robot
