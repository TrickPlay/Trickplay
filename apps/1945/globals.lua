--Game state
state =
{
    curr_mode     = "SPLASH", 
    curr_level    = 0,
    paused        = false,
    set_highscore = false,
    
    --Gameplay state that sits at the top
    hud =
    {
        num_lives  = 3,
        max_lives  = 5,
        curr_score = 0,
        high_score = settings.high_score or 0
    },
}

layers =
{
    splash         = Group{},
    hud            = Group{}, --text bubbles go here too
    
    air_doodads_2  = Group{},
    planes         = Group{}, --explosions go here as well
    air_bullets    = Group{},
    air_doodads_1  = Group{},
    
    land_doodads_2 = Group{},
    land_targets   = Group{}, -- explostions go here as well
    land_bullets   = Group{},
    land_doodads_1 = Group{},
    ground         = Group{}
}

screen:add(
    layers.ground,
    layers.land_doodads_1,
    layers.land_bullets,
    layers.land_targets,
    layers.land_doodads_2,
    layers.air_doodads_1, 
    layers.air_bullets,   
    layers.planes,        
    layers.air_doodads_2, 
    layers.hud,           
    layers.splash
)


-- Base images for cloning
imgs =
{
    water           = Image{ src = "assets/water.png" },
    island1         = Image{ src = "assets/island1.png" },
    island2         = Image{ src = "assets/island2.png" },
    island3         = Image{ src = "assets/island3.png" },
    cloud1          = Image{ src = "assets/cloud1.png"},
    cloud2          = Image{ src = "assets/cloud2.png"},
    cloud3          = Image{ src = "assets/cloud3.png"},
    
    dock_1_1        = Image{ src = "assets/dock/harbor_1_1.png"},
    dock_1_2        = Image{ src = "assets/dock/harbor_1_2.png"},
    dock_1_3        = Image{ src = "assets/dock/harbor_1_3.png"},
    dock_1_4        = Image{ src = "assets/dock/harbor_1_4.png"},
    dock_1_5        = Image{ src = "assets/dock/harbor_1_5.png"},
    dock_1_6        = Image{ src = "assets/dock/harbor_1_6.png"},

    dock_2_1        = Image{ src = "assets/dock/harbor_2_1.png"},
    dock_2_2        = Image{ src = "assets/dock/harbor_2_2.png"},
    dock_2_3        = Image{ src = "assets/dock/harbor_2_3.png"},
    dock_2_4        = Image{ src = "assets/dock/harbor_2_4.png"},
    dock_2_5        = Image{ src = "assets/dock/harbor_2_5.png"},
    dock_2_6        = Image{ src = "assets/dock/harbor_2_6.png"},
    
    my_plane_strip  = Image{ src = "assets/player_strip.png" },
    my_bullet       = Image{ src = "assets/bullet.png" },
    life            = Image{ src = "assets/life.png"},

    enemy_bullet    = Image{ src = "assets/enemybullet1.png" },
    explosion1      = Image{ src = "assets/explosion1_strip6.png" },
    explosion2      = Image{ src = "assets/explosion2_strip7.png" },
    explosion3      = Image{ src = "assets/explosion3_strip7.png" },

    b_ship          = Image{ src = "assets/battleship.png" },
    turret          = Image{ src = "assets/battleship_cannon.png" },

    smoke           = Image{ src = "assets/smoke.png"},
    enemy_1         = Image{ src = "assets/enemy1.png"   },
    zepp            = Image{ src = "assets/zeppelin.png" },
    z_d_1           = Image{ src = "assets/zepp_dam/zep_dmg1.png"},
    z_d_2           = Image{ src = "assets/zepp_dam/zep_dmg2.png"},
    z_d_3           = Image{ src = "assets/zepp_dam/zep_dmg3.png"},
    z_d_4           = Image{ src = "assets/zepp_dam/zep_dmg4.png"},
    z_d_5           = Image{ src = "assets/zepp_dam/zep_dmg5.png"},
    z_d_6           = Image{ src = "assets/zepp_dam/zep_dmg6.png"},
    z_d_7           = Image{ src = "assets/zepp_dam/zep_dmg7.png"},
    z_d_e           = Image{ src = "assets/zepp_dam/zep_dmg_engine.png"},

    prop1           = Image{ src  = "assets/prop1.png" },
    prop2           = Image{ src  = "assets/prop2.png" },
    prop3           = Image{ src  = "assets/prop3.png" },
    cannon_l        = Image{ src  = "assets/cannon_left.png" },
    cannon_r        = Image{ src  = "assets/cannon_right.png"},
    barrel          = Image{ src  = "assets/cannon_barrel.png"}
}
txt =
{
    score = Text
    {
        font  = my_font,
        text  = "+10",
        color = "FFFF00"
    },
    g_over = Text
    {
        font  = my_font,
        text  = "GAMEOVER",
        color = "FFFFFF"
    },
    up_life = Text
    {
        font  = my_font,
        text = "+1 Life",
        color = "FFFFFF"
    },
    level2 = Text
    {
        font  = my_font,
        text = "LEVEL 2",
        color = "FFFFFF"
    },
    level1 = Text
    {
        font  = my_font,
        text  = "LEVEL 1",
        color = "FFFFFF"
    },
}
--hide the base images and add them to screen
for _ , v in pairs( imgs ) do
    screen:add( v )
    v:hide()
end
for _ , v in pairs( txt ) do
    screen:add( v )
    v:hide()
end





--returns v, unless it lies outside the bounds
--in which case the bound is printed
function clamp( v , min , max )

    if     v < min then   return min        
    elseif v > max then   return max        
    else                  return v        
    end

end