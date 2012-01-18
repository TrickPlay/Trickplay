local robot = Group { name = "robot" }

local Left_Hand = Image { name = "Left_Hand", src = "assets/robot-part/robot/Left_Hand.png" }
Left_Hand.z_rotation = { 0, 0, 0 }
Left_Hand:move_anchor_point(145, 10)

local Left_Foot = Image { name = "Left_Foot", src = "assets/robot-part/robot/Left_Foot.png" }
Left_Foot:move_anchor_point(217, 8)

local Left_Lower_Leg = Image { name = "Left_Lower_Leg", src = "assets/robot-part/robot/Left_Lower_Leg.png" }
Left_Lower_Leg.z_rotation = { 0, 64, 211 }
Left_Lower_Leg:move_anchor_point(52, 6)

local Left_Thigh = Image { name = "Left_Thigh", src = "assets/robot-part/robot/Left_Thigh.png" }
Left_Thigh.z_rotation = { 0, -152, 105 }
Left_Thigh:move_anchor_point(189, 31)

local Left_Hip = Image { name = "Left_Hip", src = "assets/robot-part/robot/Left_Hip.png" }
Left_Hip.z_rotation = { 0, 0, 0 }
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
Head.z_rotation = { 0, 0, 0 }
Head:move_anchor_point(800, 594)

local Jaw = Image { name = "Jaw", src = "assets/robot-part/robot/Jaw.png" }
Jaw:move_anchor_point(280, 70)

local Tire = Image { name = "Tire", src = "assets/robot-part/robot/Tire.png" }
Tire:move_anchor_point(332, 290)
z_rotation = { 0, 0, 0 }

local Right_Hip = Image { name = "Right_Hip", src = "assets/robot-part/robot/Right_Hip.png" }
Right_Hip.z_rotation = { 0, 0, 0 }
Right_Hip:move_anchor_point(282, 80)

local Right_Thigh = Image { name = "Right_Thigh", src = "assets/robot-part/robot/Right_Thigh.png" }
Right_Thigh.z_rotation = { 0, 11, 174 }
Right_Thigh:move_anchor_point(80, 40)

local Right_Lower_Leg = Image { name = "Right_Lower_Leg", src = "assets/robot-part/robot/Right_Lower_Leg.png" }
Right_Lower_Leg.z_rotation = { 0, 152, 170 }
Right_Lower_Leg:move_anchor_point(50, 32)

local Right_Foot = Image { name = "Right_Foot", src = "assets/robot-part/robot/Right_Foot.png" }
Right_Foot:move_anchor_point(392, 20)

local Right_Hand = Image { name = "Right_Hand", src = "assets/robot-part/robot/Right_Hand.png" }
Right_Hand:move_anchor_point(260, 60)
Right_Hand.z_rotation = { 0, 0, 0 }

local Shadow = Image { name = "Shadow", src = "assets/robot-part/robot/Shadow.png" }
Shadow:move_anchor_point(Shadow.w/2, Shadow.h/2)

robot.extra.collision_sensor = Rectangle {
                                        name = "collision_sensor",
                                        size = { 600, 800 },
                                        position = { 0, 200 },
                                        color = { 198, 28, 111 },
                                        opacity = 0,
                                    }

robot.extra.states = AnimationState( {
                                        duration = 200,
                                        mode = "EASE_IN_OUT_SINE", -- natural movement is sinusoidal
                                        transitions = {
                                            {
                                                --  These positions done by eyeballing the original
                                                source = "*",
                                                target = "base",
                                                keys = {
                                                    { robot, "y", 440 },

                                                    { Right_Foot,       "position",     {  580,  960 } },
                                                    { Right_Lower_Leg,  "position",     {  430,  790 } },
                                                    { Right_Lower_Leg,  "z_rotation",   0              },
                                                    { Right_Thigh,      "position",     {  440,  640 } },
                                                    { Right_Thigh,      "z_rotation",   0              },
                                                    { Right_Hip,        "position",     {  600,  550 } },
                                                    { Right_Hip,        "z_rotation",   0              },

                                                    { Left_Foot,        "position",     {  140,  910 } },
                                                    { Left_Lower_Leg,   "position",     {  100,  710 } },
                                                    { Left_Lower_Leg,   "z_rotation",   0              },
                                                    { Left_Thigh,       "position",     {  240,  640 } },
                                                    { Left_Thigh,       "z_rotation",   0              },
                                                    { Left_Hip,         "position",     {  400,  500 } },
                                                    { Left_Hip,         "z_rotation",   0              },

                                                    { Pelvis,           "position",     {  370,  180 } },
                                                    { Pipe_In_Front,    "position",     {  340,   80 } },
                                                    { Pipe_On_Back,     "position",     {  440,  360 } },

                                                    { Body_Inside,      "position",     {  250,  -90 } },

                                                    { Head,             "position",     {    0,    0 } },
                                                    { Head,             "z_rotation",   0              },
                                                    { Jaw,              "position",     {  -70,   55 } },
                                                    { Mouth_Inside,     "position",     { -164,   83 } },

                                                    { Left_Hand,        "position",     {   50,  130 } },
                                                    { Left_Hand,        "z_rotation",   0              },
                                                    { Right_Hand,       "position",     {  420,  -60 } },
                                                    { Right_Hand,       "z_rotation",   0              },
                                                    { Tire,             "position",     {  420,  -60 } },
                                                    { Tire,             "z_rotation",   0              },

                                                    { Shadow,           "opacity",      200            },
                                                    { Shadow,           "position",     {  100, 1100 } },
                                                    { Shadow,           "scale",        {    1,    1 } },
                                                },
                                            },
                                            {
                                                source = "*",
                                                target = "bounce",
                                                keys = {
                                                    { robot,            "y",            440            },

                                                    { Right_Foot,       "position",     {  580,  960 } },
                                                    { Right_Lower_Leg,  "position",     {  430,  788 } },
                                                    { Right_Lower_Leg,  "z_rotation",   0              },
                                                    { Right_Thigh,      "position",     {  440,  630 } },
                                                    { Right_Hip,        "position",     {  600,  540 } },

                                                    { Left_Foot,        "position",     {  140,  910 } },
                                                    { Left_Lower_Leg,   "position",     {  100,  708 } },
                                                    { Left_Thigh,       "position",     {  240,  630 } },
                                                    { Left_Hip,         "position",     {  400,  490 } },

                                                    { Pelvis,           "position",     {  370,  160 } },
                                                    { Pipe_In_Front,    "position",     {  340,   60 } },
                                                    { Pipe_On_Back,     "position",     {  440,  340 } },

                                                    { Body_Inside,      "position",     {  250, -100 } },

                                                    { Head,             "position",     {    0,  -20 } },
                                                    { Jaw,              "position",     {  -60,    0 } },
                                                    { Mouth_Inside,     "position",     { -154,   28 } },

                                                    { Left_Hand,        "position",     {   40,  110 } },
                                                    { Right_Hand,       "z_rotation",   10             },
                                                    { Tire,             "z_rotation",    2             },

                                                    { Shadow,           "y",            1100           },
                                                    { Shadow,           "scale",        {    1,    1 } },
                                                    { Shadow,           "opacity",       200           },
                                                },
                                            },
                                            {
                                                source = "*",
                                                target = "crouch",
                                                keys = {
                                                    { robot,            "y",            440            },

                                                    { Right_Lower_Leg,  "z_rotation",   -40            },
                                                    { Right_Thigh,      "position",     {  320,  800 } },
                                                    { Right_Thigh,      "z_rotation",   40             },
                                                    { Right_Hip,        "position",     {  600,  820 } },
                                                    { Right_Hip,        "z_rotation",   30             },

                                                    { Left_Lower_Leg,   "position",     {  100,  710 } },
                                                    { Left_Lower_Leg,   "z_rotation",   -40            },
                                                    { Left_Thigh,       "position",     {  100,  730 } },
                                                    { Left_Thigh,       "z_rotation",   20             },
                                                    { Left_Hip,         "position",     {  300,  750 } },
                                                    { Left_Hip,         "z_rotation",   20             },

                                                    { Pelvis,           "position",     {  370,  410 } },
                                                    { Pipe_In_Front,    "position",     {  340,  310 } },
                                                    { Pipe_On_Back,     "position",     {  440,  590 } },

                                                    { Body_Inside,      "position",     {  250, 150 } },

                                                    { Head,             "position",     {    0,  330 } },
                                                    { Head,             "z_rotation",   -15            },
                                                    { Jaw,              "position",     {  -40,  350 } },
                                                    { Mouth_Inside,     "position",     { -134,  378 } },

                                                    { Left_Hand,        "position",     {   40,  260 } },
                                                    { Left_Hand,        "z_rotation",   -75            },
                                                    { Right_Hand,       "position",     {  420,  190 } },
                                                    { Right_Hand,       "z_rotation",   -75            },
                                                    { Tire,             "z_rotation",   -30            },
                                                    { Tire,             "position",     {  420,  190 } },

                                                    { Shadow,           "y",            1100           },
                                                    { Shadow,           "scale",        {     1.1,    1.1 } },
                                                    { Shadow,           "opacity",      220            },
                                                },
                                            },
                                            {
                                                source = "*",
                                                target = "jump",
                                                mode = "EASE_OUT_QUAD", -- Gravity, good ol' inverse-square law
                                                keys = {
                                                    { robot,    "y",        -600         },
                                                    { Shadow,   "y",        3180         },
                                                    { Shadow,   "scale",    { 1/4, 1/4 } },
                                                    { Shadow,   "opacity",  100          },
                                                },
                                            },
                                            {
                                                source = "jump",
                                                target = "hover",
                                                mode = "LINEAR", -- Linear is fractionally cheaper
                                                duration = 3000,
                                                keys = {
                                                    { robot,    "y",        -600         },
                                                    { Shadow,   "y",        3180         },
                                                    { Shadow,   "scale",    { 1/4, 1/4 } },
                                                    { Shadow,   "opacity",  100          },
                                                },
                                            },
                                            {
                                                source = "*",
                                                target = "fall",
                                                mode = "EASE_IN_QUAD", -- Gravity, good ol' inverse-square law
                                                keys = {
                                                    { robot,    "y",        440          },
                                                    { Shadow,   "y",        1110         },
                                                    { Shadow,   "scale",    { 1.1, 1.1 } },
                                                    { Shadow,   "opacity",  100          },
                                                },
                                            },
                                        },
})

robot.extra.sequence = {
                            'base',
                            'bounce',
                            'base',
                            'bounce',
                            'base',
                            'bounce',
                            'base',
                            'crouch',
                            'base',
                            'jump',
                            'hover',
                            'fall',
                            'crouch'
                        }
robot.extra.current_pos = 1

-- Dummy callback which should be replaced by caller
function robot.extra:score_callback()
    print("You're supposed to replace this function with something that records a score")
end

local did_collide = false
function robot.extra:collision()
    mediaplayer:play_sound("assets/robot-part/audio/puck_bad-1.mp3")
    did_collide = true
end

function robot.extra:next_position()
    robot.extra.current_pos = (robot.current_pos % #robot.sequence) + 1
    robot.states.state = robot.sequence[robot.current_pos]
    if(robot.sequence[robot.current_pos] == "hover") then
        robot:hover()
    elseif(robot.sequence[robot.current_pos] == "jump") then
        mediaplayer:play_sound("assets/robot-part/audio/Robot_Takeoff.mp3")
        did_collide = false
    end
end

function robot.states:on_completed()
    if(not did_collide and robot.current_pos == #robot.sequence) then
        robot:score_callback()
    end
    robot:next_position()
end

local robot_x_positions = {
                                screen.w  * 2/10,
                                screen.w  * 1/2,
                                screen.w  * 8/10
                            }

function robot.extra:hover()
    local sequence = {
                        math.random(1,3),
                        math.random(1,3),
                        math.random(1,3),
                        math.random(1,3)
                    }
    local cur = 1

    local animator = AnimationState( {
                                    duration = 600,
                                    mode = "EASE_IN_OUT_SINE",
                                    transitions = {
                                                    {
                                                        source = "*",
                                                        target = "1",
                                                        keys = {
                                                            { self, "x", robot_x_positions[1] },
                                                        },
                                                    },
                                                    {
                                                        source = "*",
                                                        target = "2",
                                                        keys = {
                                                            { self, "x", robot_x_positions[2] },
                                                        },
                                                    },
                                                    {
                                                        source = "*",
                                                        target = "3",
                                                        keys = {
                                                            { self, "x", robot_x_positions[3] },
                                                        },
                                                    },
                                                },
                                })
    animator.on_completed = function()
        cur = cur + 1
        if(cur <= #sequence) then
            animator.state = sequence[cur]
        else
            cur = 1
        end
    end

    animator.state = math.random(1,3)
end

robot.states:warp(robot.sequence[robot.current_pos])
robot:next_position()

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
robot:add(robot.collision_sensor)

robot.scale = { 1/2, 1/2 }
robot.position = { robot_x_positions[2], 440 }


return robot
