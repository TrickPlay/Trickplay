
local img_path = "assets/bg/"

local graveyard = Image{src = img_path.."graveyard.png" }
graveyard.y = screen_h-graveyard.h

local gallows = Image{src = img_path.."gallows.png", x = 1300, y = screen_h }
local logo = Image{src = img_path.."logo.png", x = 1250, y = 150, opacity = 0, scale = { 2,2} }
logo:move_anchor_point(logo.w*2/3,logo.h*2/3)

local victims = {
    {
        Image{src = img_path.."vic1/1-Head.png",      x =   0, y = 151},
        Image{src = img_path.."vic1/2-Torso.png",     x =   0, y = 280},
        Image{src = img_path.."vic1/3-Left-Arm.png",  x = -30, y = 305},
        Image{src = img_path.."vic1/4-Right-Arm.png", x = 176, y = 290},
        Image{src = img_path.."vic1/5-Left-Leg.png",  x =  52, y = 600},
        Image{src = img_path.."vic1/6-Right-Leg.png", x = 130, y = 560},
    },
    {
        Image{src = img_path.."vic2/1-Head.png",      x = -22, y = 151},
        Image{src = img_path.."vic2/2-Torso.png",     x = -16, y = 290},
        Image{src = img_path.."vic2/3-Left-Arm.png",  x = -70, y = 297},
        Image{src = img_path.."vic2/4-Right-Arm.png", x = 150, y = 247},
        Image{src = img_path.."vic2/5-Left-Leg.png",  x =  -4, y = 555},
        Image{src = img_path.."vic2/6-Right-Leg.png", x =  85, y = 559},
    },
}


local victim_pieces = {
    Group{opacity = 0},
    Clone{source = victims[1][2], x =   0, y = 280, opacity = 0 },
    Clone{source = victims[1][3], x = -30, y = 305, opacity = 0 },
    Clone{source = victims[1][4], x = 176, y = 290, opacity = 0 },
    Clone{source = victims[1][5], x =  52, y = 600, opacity = 0 },
    Clone{source = victims[1][6], x = 130, y = 560, opacity = 0 },
}
local victim_pieces_i = 1

local head = Clone{source = victims[1][1],  x =   0, y = 151 }
local rope_top = Image{src = img_path.."rope-top.png", x = 100-12}
local rope_mid = Image{src = img_path.."rope-repeat.png", x =rope_top.x+16,y = rope_top.y + rope_top.h,tile = {false,true}, h = 200 }

victim_pieces[1]:add(rope_top,rope_mid,head)

local victim = Group{x = 1250}
victim:add(
    victim_pieces[6],
    victim_pieces[5],
    victim_pieces[4],
    victim_pieces[3],
    victim_pieces[2],
    victim_pieces[1]
)



local hm_body     = Image{ src = img_path.."hangman-body.png",          x = 13, y =   0}
local hm_bicep    = Image{ src = img_path.."hangman-bicep.png",         x =  8, y = 157}
local hm_shoulder = Image{ src = img_path.."hangman-shoulder-cape.png", x = 47, y = 130}
local hm_handle   = Image{ src = img_path.."hangman-arm-lever.png",     x =  0, y = 226}
hm_bicep:move_anchor_point(40,15)
hm_handle:move_anchor_point(326,475)

local hangman = Group{x = screen_w,y = 387 }
local clone_srcs = Group{}
clone_srcs:add(unpack(victims[1]))
clone_srcs:add(unpack(victims[2]))
hangman:add(hm_body,hm_bicep,hm_handle,hm_shoulder)

--hm_handle.z_rotation = {7,0,0}
--hm_bicep.z_rotation = {-20,0,0}
local bg = Group{ name = "background" }

local function victim_source(i)
    victim_pieces[6]:set{ source = victims[i][6], x = victims[i][6].x, y = victims[i][6].y }
    victim_pieces[5]:set{ source = victims[i][5], x = victims[i][5].x, y = victims[i][5].y }
    victim_pieces[4]:set{ source = victims[i][4], x = victims[i][4].x, y = victims[i][4].y }
    victim_pieces[3]:set{ source = victims[i][3], x = victims[i][3].x, y = victims[i][3].y }
    victim_pieces[2]:set{ source = victims[i][2], x = victims[i][2].x, y = victims[i][2].y }
    head:set{             source = victims[i][1], x = victims[i][1].x, y = victims[i][1].y }
end

local drop_dist = 400

victim:move_anchor_point(rope_mid.x,-drop_dist)

local hangman_kill = Animator{
    duration   = 1000,
    properties = {
        {
            source = hm_handle,
            name = "z_rotation",
            
            keys = {
                {0.0, "LINEAR",  0},
                {0.1, "LINEAR",  0},
                {0.2, "LINEAR", 16},
                {0.5, "LINEAR", 16},
                {0.8, "LINEAR",  0},
            }
        },
        {
            source = hm_bicep,
            name = "z_rotation",
            
            keys = {
                {0.0, "LINEAR",   0},
                {0.1, "LINEAR",   0},
                {0.2, "LINEAR", -45},
                {0.5, "LINEAR", -45},
                {0.8, "LINEAR",   0},
            }
        },
        {
            source = victim,
            name = "y",
            
            keys = {
                {0.0, "LINEAR",  victim.y},
                {0.25, "LINEAR",  victim.y},
                {0.4, "LINEAR", victim.y+drop_dist},
                {1.0, "LINEAR", victim.y+drop_dist},
            }
        },
        {
            source = rope_top,
            name = "y",
            
            keys = {
                {0.0, "LINEAR", rope_top.y},
                {0.25, "LINEAR", rope_top.y},
                {0.4, "LINEAR", rope_top.y-drop_dist},
                {1.0, "LINEAR", rope_top.y-drop_dist},
            }
        },
        {
            source = rope_mid,
            name = "y",
            
            keys = {
                {0.0, "LINEAR", rope_mid.y},
                {0.25, "LINEAR", rope_mid.y},
                {0.4, "LINEAR", rope_mid.y-drop_dist},
                {1.0, "LINEAR", rope_mid.y-drop_dist},
            }
        },
        {
            source = rope_mid,
            name = "height",
            
            keys = {
                {0.0, "LINEAR", rope_mid.h},
                {0.25, "LINEAR", rope_mid.h},
                {0.4, "LINEAR", rope_mid.h+drop_dist},
                {1.0, "LINEAR", rope_mid.h+drop_dist},
            }
        },
        {
            source = victim,
            name = "z_rotation",
            
            keys = {
                {0.0,  "LINEAR",  0},
                {0.4,  "LINEAR",  0},
                {0.6, "LINEAR",   .5},
                {0.8, "LINEAR",  .25},
                {1.0,  "LINEAR",  0},
            }
        },
        --]]
    }
}

local z_rot_t = {0,0,0}

local sway_tl = Timeline{
    duration = 1500,
    loop     = true,
    on_new_frame = function(self,ms,p)
        
        z_rot_t[1] = .25*math.sin(math.pi*2*p)
        
        victim.z_rotation = z_rot_t
        
    end,
}

function bg:killing()
    
    return hangman_kill.timeline.duration - hangman_kill.timeline.elapsed
    
end
function bg:fade_in_victim(i)
    print("fade in ",i)
    victim_pieces[i]:animate{
        duration = 200,
        opacity  = 255
    }
    
end
function bg:fill_in_victim()
    
    for i,v in ipairs(victim_pieces) do
        print(v.opacity)
        if v.opacity == 0 then  bg:fade_in_victim(i)  end
        
    end
    
end

function bg:reset()
    
    victim_source(math.random(1,#victims))
    
    for i,child in ipairs(victim.children) do
        
        child.opacity = 0
        
    end
    sway_tl:stop()
    
    victim.opacity = 255
    
    victim.y = victim.anchor_point[2]
    
    rope_top.y = 0
    rope_mid.y = rope_top.y + rope_top.h
    rope_mid.h = 200
    
end
function bg:fade_out_vic()
    
    victim:animate{
        duration = 200,
        opacity  = 0,
        on_completed = function()
            
            bg:reset()
        end
    }
    
end

function bg:kill()
    
    print("kill")
    
    if victim.opacity ~= 0 and victim_pieces[1].opacity ~= 0 then
        
        mediaplayer:play_sound("audio/hanging.mp3")
        
    end
    
    hangman_kill:start()
    
end

local gallow_y = AnimationState{
    duration = 300,
    transitions = {
        {
            source = "*",          target = "VISIBLE", duration = 300,
            keys = {
                {gallows, "y", 0},
            }
        },
        {
            source = "*",        target = "HIDDEN", duration = 300,
            keys = {
                {gallows, "y", screen_h},
            }
        },
    }
}
function bg:slide_in_gallows()
    
    gallow_y.state = "VISIBLE"
    
end

function bg:slide_out_gallows()
    
    gallow_y.state = "HIDDEN"
    
end

local hangman_x = AnimationState{
    duration = 700,
    transitions = {
        {
            source = "*",          target = "VISIBLE", duration = 300,
            keys = {   {hangman, "x",     1463},  }
        },
        {
            source = "*",        target = "HIDDEN", duration = 300,
            keys = {   {hangman, "x", screen_w}, }
        },
    }
}
hangman_x.on_completed = function()
    
    if hangman_x.state == "VISIBLE" then
        bg:kill()
    end
    
end

function bg:slide_in_hangman(on_c,p)
    hangman_x.state = "VISIBLE"
    
    hangman_kill.timeline.on_completed = function()
        if on_c then on_c(p) end
        sway_tl:start()
    end
end

function bg:slide_out_hangman()
    hangman_x.state = "HIDDEN"
    sway_tl:stop()
    hangman_kill.on_completed = nil
end
local logo_anim = Animator{
    duration   = 500,
    properties = {
        {
            source = logo,
            name = "scale",
            
            keys = {
                {0.0, "LINEAR",  {0,0}},
                {1.0, "LINEAR",  {1.0,1.0}},
            }
        },
        {
            source = logo,
            name = "opacity",
            
            keys = {
                {0.0, "LINEAR",   0},
                {1.0, "LINEAR", 255},
            }
        },
    }
}
function bg:scale_in_logo()

    logo_anim:start()
    
end

bg:add(clone_srcs,graveyard,gallows,victim,hangman,logo)
clone_srcs:hide()

return bg, logo