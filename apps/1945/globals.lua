--Game state
state =
{
    curr_mode  = "SPLASH", --
    curr_level = 0,
    paused     = false,
    set_highscore = false,
    
    --Gameplay state that sits at the top
    hud =
    {
        num_lives  = 3,
        curr_score = 0,
        high_score = settings.high_score or 0
    },
}

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

    my_plane_strip  = Image{ src = "assets/player_strip.png" },
    my_bullet       = Image{ src = "assets/bullet.png" },

    enemy_bullet    = Image{ src = "assets/enemybullet1.png" },
    explosion1      = Image{ src = "assets/explosion1_strip6.png" },
    explosion2      = Image{ src = "assets/explosion2_strip7.png" },
    smoke           = Image{ src = "assets/smoke.png"},
    enemy_1         = Image{ src = "assets/enemy1.png"   },
    zepp            = Image{ src = "assets/zeppelin.png" },

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