screen_h = screen.h
screen_w = screen.w


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
    --BACKGROUND/SCENERY/LEVEL OBJECTS/ETC
    water1          = Image{ src = "assets/lvls/bg_tiles/water1.png" },
    water2          = Image{ src = "assets/lvls/bg_tiles/water2.png" },
    --LVL 1
    island1         = Image{ src = "assets/lvls/islands/island1.png" },
    island2         = Image{ src = "assets/lvls/islands/island2.png" },
    island3         = Image{ src = "assets/lvls/islands/island3.png" },
    cloud1          = Image{ src = "assets/lvls/clouds/cloud1.png"},
    cloud2          = Image{ src = "assets/lvls/clouds/cloud2.png"},
    cloud3          = Image{ src = "assets/lvls/clouds/cloud3.png"},
    --LVL 2
    dock_1_1        = Image{ src = "assets/lvls/harbor/harbor_1_1.png"},
    dock_1_2        = Image{ src = "assets/lvls/harbor/harbor_1_2.png"},
    dock_1_3        = Image{ src = "assets/lvls/harbor/harbor_1_3.png"},
    dock_1_4        = Image{ src = "assets/lvls/harbor/harbor_1_4.png"},
    dock_1_5        = Image{ src = "assets/lvls/harbor/harbor_1_5.png"},
    dock_1_6        = Image{ src = "assets/lvls/harbor/harbor_1_6.png"},
    dock_1_7        = Image{ src = "assets/lvls/harbor/harbor_1_7.png"},
    dock_2_1        = Image{ src = "assets/lvls/harbor/harbor_2_1.png"},
    dock_2_2        = Image{ src = "assets/lvls/harbor/harbor_2_2.png"},
    dock_2_3        = Image{ src = "assets/lvls/harbor/harbor_2_3.png"},
    dock_2_4        = Image{ src = "assets/lvls/harbor/harbor_2_4.png"},
    dock_2_5        = Image{ src = "assets/lvls/harbor/harbor_2_5.png"},
    dock_2_6        = Image{ src = "assets/lvls/harbor/harbor_2_6.png"},
    dock_2_7        = Image{ src = "assets/lvls/harbor/harbor_2_7.png"},
    
    --PLAYER ASSETS
    my_plane_strip  = Image{ src = "assets/player/player_strip.png" },
    my_bullet       = Image{ src = "assets/player/bullet.png" },
    my_bomb         = Image{ src = "assets/player/fat_man.png" },
    life            = Image{ src = "assets/player/life.png"},
    my_shadow       = Image{ src = "assets/player/player_shadow.png"},
    my_prop         = Image{ src = "assets/player/player_prop.png"},
    engine_fire     = Image{ src = "assets/fx/engine-fire.png"},

    --EXPLOSIONS
    explosion1      = Image{ src = "assets/fx/explosion1_strip6.png" },
    explosion3      = Image{ src = "assets/fx/explosion3_strip7.png" },
    
    --TURRET ASSETS
    turret          = Image{ src = "assets/enemies/turret/turret.png" },
    t_bullet        = Image{ src = "assets/enemies/turret/turret_bullet.png" },
    flak            = Image{ src = "assets/fx/flak.png"},
    
    --BATTLESHIP ASSETS
    b_ship          = Image{ src = "assets/enemies/b_ship/battleship.png" },
    --[[
    bow_wake_1      = Image{ src = "assets/enemies/b_ship/bow_wake1.png"},
    bow_wake_2      = Image{ src = "assets/enemies/b_ship/bow_wake2.png"},
    bow_wake_3      = Image{ src = "assets/enemies/b_ship/bow_wake3.png"},
    bow_wake_4      = Image{ src = "assets/enemies/b_ship/bow_wake4.png"},
    --]]
    bow_wake_1      = Image{ src = "assets/enemies/b_ship/bw1.png"},
    bow_wake_2      = Image{ src = "assets/enemies/b_ship/bw2.png"},
    bow_wake_3      = Image{ src = "assets/enemies/b_ship/bw3.png"},
    bow_wake_4      = Image{ src = "assets/enemies/b_ship/bw4.png"},
    bow_wake_5      = Image{ src = "assets/enemies/b_ship/bw5.png"},
    bow_wake_6      = Image{ src = "assets/enemies/b_ship/bw6.png"},
    bow_wake_7      = Image{ src = "assets/enemies/b_ship/bw7.png"},
    bow_wake_8      = Image{ src = "assets/enemies/b_ship/bw8.png"},
    stern_wake_1    = Image{ src = "assets/enemies/b_ship/stern_wake1.png"},
    stern_wake_2    = Image{ src = "assets/enemies/b_ship/stern_wake2.png"},
    stern_wake_3    = Image{ src = "assets/enemies/b_ship/stern_wake3.png"},
    stern_wake_4    = Image{ src = "assets/enemies/b_ship/stern_wake4.png"},
    stern_wake_5    = Image{ src = "assets/enemies/b_ship/stern_wake5.png"},

    --FIGHTER ASSETS
    fighter         = Image{ src = "assets/enemies/fighter/fighter.png"   },
    fighter_bullet  = Image{ src = "assets/enemies/fighter/fighter_bullet.png" },
    fighter_prop    = Image{ src = "assets/enemies/fighter/fighter_prop.png" },
    
    --ZEPPELIN ASSETS
    zepp            = Image{ src = "assets/enemies/zepp/zeppelin.png" },
    z_bullet        = Image{ src = "assets/enemies/zepp/zepp_bullet.png" },
    zepp_prop       = Image{ src = "assets/enemies/zepp/zepp_prop.png" },
    z_cannon_l      = Image{ src = "assets/enemies/zepp/cannon_left.png" },
    z_cannon_r      = Image{ src = "assets/enemies/zepp/cannon_right.png"},
    z_barrel        = Image{ src = "assets/enemies/zepp/cannon_barrel.png"},
    z_d_1           = Image{ src = "assets/enemies/zepp/zep_dmg1.png"},
    z_d_2           = Image{ src = "assets/enemies/zepp/zep_dmg2.png"},
    z_d_3           = Image{ src = "assets/enemies/zepp/zep_dmg3.png"},
    z_d_4           = Image{ src = "assets/enemies/zepp/zep_dmg4.png"},
    z_d_5           = Image{ src = "assets/enemies/zepp/zep_dmg5.png"},
    z_d_6           = Image{ src = "assets/enemies/zepp/zep_dmg6.png"},
    z_d_7           = Image{ src = "assets/enemies/zepp/zep_dmg7.png"},
    z_d_e           = Image{ src = "assets/enemies/zepp/zep_dmg_engine.png"},
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