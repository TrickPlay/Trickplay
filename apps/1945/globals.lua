screen_h = screen.h--/4
screen_w = screen.w--/4


--Game state
state =
{
    curr_mode     = "SPLASH", 
    curr_level    = 0,
    paused        = false,
    set_highscore = false,
    in_lvl_complete = false,
    menu          = 0, 
    --Gameplay state that sits at the top
    hud =
    {
        num_lives  = 3,
        max_lives  = 5,
        curr_score = 0,
        high_score = 0
    },
    high_scores = {
        {score = 0, initials="AAA", medals = 0},
        {score = 0, initials="AAA", medals = 0},
        {score = 0, initials="AAA", medals = 0},
        {score = 0, initials="AAA", medals = 0},
        
        {score = 0, initials="AAA", medals = 0},
        {score = 0, initials="AAA", medals = 0},
        {score = 0, initials="AAA", medals = 0},
        {score = 0, initials="AAA", medals = 0},

    },
    counters =
    {
        {
            lvl_points = 0,
            lives_before = 3,
            fighters = {
                killed  = 0,
                spawned = 0
            },
            zepp = {
                killed  = 0,
                spawned = 0
            }
        },
        {
            lvl_points = 0,
            lives_before = 3,
            fighters = {
                killed  = 0,
                spawned = 0
            },
            zepp = {
                killed  = 0,
                spawned = 0
            }
        },
        {
            lvl_points = 0,
            lives_before = 3,
            fighters = {
                killed  = 0,
                spawned = 0
            },
            zepp = {
                killed  = 0,
                spawned = 0
            }
        },
        {
            lvl_points = 0,
            lives_before = 3,
            fighters = {
                killed  = 0,
                spawned = 0
            },
            zepp = {
                killed  = 0,
                spawned = 0
            }
        },
    }
}
state.counters[0] = {}
state.counters[0].lvl_points = 0

if settings.state ~= nil  and settings.state.hud ~= nil then
    state.hud.high_score = settings.state.hud.high_score
end
layers =
{
    splash         = Group{},
    hud            = Group{}, --text bubbles go here too
    
    air_doodads_2  = Group{},
    planes         = Group{}, --explosions go here as well
    air_bullets    = Group{},
    air_doodads_1  = Group{},
    
    land_doodads_2 = Group{},
    land_targets   = Group{}, -- explosions go here as well
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
    grass1          = Image{ src = "assets/lvls/bg_tiles/grass1.png"},
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
    --LVL3
    dirt_full       = Image{ src = "assets/lvls/bg_tiles/dirt1.png"},
    dirt_half       = Image{ src = "assets/lvls/bg_tiles/dirt2.png"},
    dirt_diag_big   = Image{ src = "assets/lvls/bg_tiles/dirt3.png"},
    dirt_diag_sm    = Image{ src = "assets/lvls/bg_tiles/dirt4.png"},
    dirt_area_1     = Image{ src = "assets/lvls/bg_tiles/dirt_area1.png"},
    dirt_area_2     = Image{ src = "assets/lvls/bg_tiles/dirt_area2.png"},
    dirt_area_3     = Image{ src = "assets/lvls/bg_tiles/dirt_area3.png"},
    --[[
    road_straight   = Image{ src = "assets/lvls/bg_tiles/road1.png"},
    road_diagonal1  = Image{ src = "assets/lvls/bg_tiles/road2.png"},
    road_diagonal2  = Image{ src = "assets/lvls/bg_tiles/road3.png"},
    --]]
    road_ver        = Image{ src = "assets/lvls/road/road-vertical.png"},
    road_hor        = Image{ src = "assets/lvls/road/road-horizontal.png"},
    road_left          = Image{ src = "assets/lvls/road/road-left.png"},
    road_right          = Image{ src = "assets/lvls/road/road-right.png"},
    building_sm     = Image{ src = "assets/lvls/buildings/building1.png"},
    building_1_1    = Image{ src = "assets/lvls/buildings/building1_1.png"},
    building_1_1_d  = Image{ src = "assets/lvls/buildings/building1_1_destroyed.png"},
    building_1_2    = Image{ src = "assets/lvls/buildings/building1_2.png"},
    building_1_2_d  = Image{ src = "assets/lvls/buildings/building1_2_destroyed.png"},
    building_big    = Image{ src = "assets/lvls/buildings/building2.png"},
    building_big_d  = Image{ src = "assets/lvls/buildings/building2_destroyed.png"},
    trees           = Image{ src = "assets/lvls/bg_tiles/trees.png"},

    
    --PLAYER ASSETS
    my_plane_strip  = Image{ src = "assets/player/player_strip.png" },
    my_bullet       = Image{ src = "assets/player/bullet.png" },
    my_bomb         = Image{ src = "assets/player/fat_man.png" },
    life            = Image{ src = "assets/player/life.png"},
    my_shadow       = Image{ src = "assets/player/player_shadow.png"},
    my_prop         = Image{ src = "assets/player/player_prop.png"},
    target          = Image{ src = "assets/player/target_strip.png"},
    smoke           = Image{ src = "assets/fx/smoke.png"},
    medal_1         = Image{ src = "assets/splash/WingmanMedal.png"},
    medal_1_sm      = Image{ src = "assets/splash/WingmanMedal_sm.png"},
    medal_2         = Image{ src = "assets/splash/PilotMedal.png"},
    medal_2_sm      = Image{ src = "assets/splash/PilotMedal_sm.png"},
    medal_3         = Image{ src = "assets/splash/AceMedal.png"},
    medal_3_sm      = Image{ src = "assets/splash/AceMedal_sm.png"},
    medal_4         = Image{ src = "assets/splash/MedalofVictory.png"},
    medal_4_sm      = Image{ src = "assets/splash/MedalofVictory_sm.png"},

    --POWERUPS
    health          = Image{ src="assets/player/health.png"},
    guns            = Image{ src="assets/player/2xfire.png"},
    up_life         = Image{ src="assets/player/up_life.png"},
    health_g        = Image{ src="assets/player/health_g.png"},
    guns_g          = Image{ src="assets/player/2xfire_g.png"},
    up_life_g       = Image{ src="assets/player/up_life_g.png"},

    --EXPLOSIONS
    explosion1      = Image{ src = "assets/fx/explosion1_strip6.png" },
    explosion3      = Image{ src = "assets/fx/explosion3_strip7.png" },
    
    --TURRET ASSETS
    turret          = Image{ src = "assets/enemies/turret/turret.png" },
    t_bullet        = Image{ src = "assets/enemies/turret/turret_bullet.png" },
    flak            = Image{ src = "assets/fx/flak.png"},
    
    --DESTROYER ASSETS
    dest            = Image{ src = "assets/enemies/dest/destroyer.png"},
    dest_sunk       = Image{ src = "assets/enemies/dest/destroyer_sunk.png"},
    --BATTLESHIP ASSETS
    b_ship          = Image{ src = "assets/enemies/b_ship/battleship.png" },
    b_ship_sunk     = Image{ src = "assets/enemies/b_ship/battleship_sunk.png" },
    ---[[
    bbow_wake_1      = Image{ src = "assets/enemies/b_ship/bow_wake1.png"},
    bbow_wake_2      = Image{ src = "assets/enemies/b_ship/bow_wake2.png"},
    bbow_wake_3      = Image{ src = "assets/enemies/b_ship/bow_wake3.png"},
    bbow_wake_4      = Image{ src = "assets/enemies/b_ship/bow_wake4.png"},
    --]]
    laminar         = Image{ src = "assets/enemies/b_ship/bship_laminar.png"},

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
    fighter_r       = Image{ src = "assets/enemies/fighter/fighter_r.png"   },
    fighter_w       = Image{ src = "assets/enemies/fighter/fighter_w.png"   },
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
    engine_fire     = Image{ src = "assets/fx/engine-fire.png"},

    --TANK ASSETS
    tank_strip      = Image{ src = "assets/enemies/tank/flaktank.png"},
    tank_turret     = Image{ src = "assets/enemies/tank/tankturret.png"},
    --JEEP ASSETS
    jeep            = Image{ src = "assets/enemies/jeep/jeep.png"},
    jeep_b          = Image{ src = "assets/enemies/jeep/jeep_b.png"},
    --TRENCH
    trench_l        = Image{ src = "assets/enemies/trench/trench1.png"},
    trench_gun      = Image{ src = "assets/enemies/trench/trench2.png"},
    trench_crater   = Image{ src = "assets/enemies/trench/trench2_crater.png"},
    trench_reg      = Image{ src = "assets/enemies/trench/trench3.png"},
    trench_r        = Image{ src = "assets/enemies/trench/trench4.png"},
    trench_bullet   = Image{ src = "assets/enemies/trench/mortar_round.png"},
    
    --FINAL BOSS ASSETS
    final_boss      = Image{ src = "assets/enemies/final_boss/boss3.png"},
    boss_prop       = Image{ src = "assets/enemies/final_boss/prop-big-strip-2x118px.png"},
    boss_prop_d     = Image{ src = "assets/enemies/final_boss/prop-big-strip-2x118px_destroyed.png"},
    boss_turret     = Image{ src = "assets/enemies/final_boss/boss_turret.png"},
    splash          = Image{ src = "assets/fx/splash.png"},
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

recurse_and_apply = nil

recurse_and_apply = function(table1,table2)
    
    assert(type(table1) == "table" or type(table1) == "userdata")
    assert(type(table2) == "table" or type(table2) == "userdata")
    
    --move through all of the items of table 2
    for k,v in pairs(table2) do
        
        --fields of trickplay items where you can't just index into
        --them in order to assign values
        if k == "z_rotation" or k == "y_rotation" or k == "x_rotation" then
            table1[k] = {v[1],v[2],v[3]}
        elseif k == "position" or k == "scale" then
            table1[k] = {v[1],v[2]}
        elseif k == "clip" then
            table1[k] = {v[1],v[2],v[3],v[4]}
            
        --if an item is a table, recurse
        elseif type(v) == "table" then
            --if that table did not exist in table 1, create it
            if type(table1[k]) ~= "table" and type(table1[k]) ~= "userdata" then
                --if the key was some other kind of variable, then it is
                --now overwritten
                --print("making",k)
                table1[k] = {} 
            end
            print("in ",k)
            --recurse into that table
            recurse_and_apply(table1[k], v)
            
        --otherwise, copy the value over
        else
            table1[k] = v
            --print(k,"=",v)
        end
    end
end

if settings.state ~= nil and settings.state.high_scores ~= nil then
    recurse_and_apply(state.high_scores,settings.state.high_scores)
end