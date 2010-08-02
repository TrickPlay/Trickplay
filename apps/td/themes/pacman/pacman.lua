local pacman = {
        themeName = "pacman",
        mainMenuBackground = "",
        bullets = {
                {id = 1, frames = 5, im = "Ringwave"},
                {id = 2, im = "PelletBig", speed = 1000},
        },
        creeps = {
                { hp = 100, speed = 20, bounty = 10, flying = false, frames = 3, name = "NormalCreep"},
                { hp = 300, speed = 30, bounty = 15, flying = false, frames = 3, name = "MediumCreep"},
                { hp = 1000, speed = 25, bounty = 15, flying = false, frames = 3, name = "HardCreep"},
                { hp = 20000, speed = 20, bounty = 200, flying = false, frames = 3, name = "BossCreep"},
                { hp = 80, speed = 20, bounty = 40, flying = true, frames = 3, name = "FlyingCreep"}
        },
        towers = {
                normalTower =
                                {
                                damage = 20,
                                range = 800,
                                cooldown = 0.5,
                                cost = 5,
                                slow = false,
                                splash = false,
                                frames = 8,
                                name = "NormalTower",
                                bullet = 2,
                                mode = "sprite",        
                                upgrades =
                                        {
                                        {damage = 30, range = 400, cooldown = 0.5, cost = 5, slow = false},
                                        {damage = 40, range = 500, cooldown = 0.5, cost = 5, slow = false}
                                        }
                                },
                slowTower =
                                { damage = 5, range = 400, cooldown = 1, cost = 10, slowammount = 75, slow = true, splash = true, frames = 8, splashradius = 240, name = "SlowTower", mode = "sprite",
                                                upgrades =      {
                                                                                {damage = 5, range = 400, cooldown = 1, cost = 10, slowammount = 50},
                                                                                {damage = 10, range = 400, cooldown = 1, cost = 10, slowammount = 25}
                                                                }
                                },
                nukeTower =
                                { damage = 400, range = 600, cooldown = 2, cost = 500, slowammount = 100, slow = true, splash = true, frames = 8, splashradius = 360, name = "NukeTower", bullet = 1, bulletframes = 5,
                                },
                wall =
                                { damage = 0, range = 0, cooldown = 1000, cost = 5, slowammount = 0, frames = 1, slow = false, name = "Wall"
                                }
        },
        obstacles = dofile("themes/pacman/obstacles.lua"),
        boardBackground = "themes/pacman/assets/bg.png",

        wave = dofile("themes/pacman/round1.lua"),
        
        waveTable = {
        ["NormalCreep"] = 1,
        ["MediumCreep"] = 2,
        ["HardCreep"] = 3,
        ["BossCreep"] = 4,
        ["FlyingCreep"] = 5,
		}           
}

return pacman


--[[
	{
		{
			{},
			{},
			{},
			size = n
		},
		size = n
	},
]]




