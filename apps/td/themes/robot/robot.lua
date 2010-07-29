local robot = {
		themeName = "robot",
		mainMenuBackground = "",
		creeps = {
				{ hp = 100, speed = 20, bounty = 10, flying = false, frames = 7, x_offset = -SP/2, y_offset = -SP, name = "NormalCreep"},
				{ hp = 300, speed = 50, bounty = 15, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "MediumCreep"},
            { hp = 1000, speed = 40, bounty = 15, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "HardCreep"},
            { hp = 20000, speed = 40, bounty = 200, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "BossCreep"},
            { hp = 80, speed = 35, bounty = 40, flying = true, frames = 4,  x_offset = -SP, y_offset = 0, name = "FlyingCreep"}
		},
		towers = {
				normalTower =
						{ damage = 20, range = 300, cooldown = 0.5, cost = 50, slow = false, splash = false, frames = 1, name = "NormalTower", simpleRotate = true,
								upgrades =   	{
												{damage = 30, range = 400, cooldown = 0.5, cost = 35, slow = false},
												{damage = 40, range = 500, cooldown = 0.5, cost = 35, slow = false}
										}
						},
				slowTower =
						{ damage = 5, range = 400, cooldown = 1, cost = 80, slowammount = 75, slow = true, splash = true, frames = 8, splashradius = 240, name = "SlowTower",
								upgrades =      {
												{damage = 5, range = 400, cooldown = 1, cost = 40, slowammount = 50},
												{damage = 10, range = 400, cooldown = 1, cost = 40, slowammount = 25}
										}
						},
				nukeTower =
						{ damage = 2000, range = 600, cooldown = 5, cost = 500, slowammount = 100, slow = false, splash = true, frames = 8, splashradius = 360, name = "NukeTower"
						},
				wall =
						{ damage = 0, range = 0, cooldown = 1000, cost = 5, slowammount = 0, frames = 1, slow = false, name = "Wall"
						}
		},
		boardBackground = "assets/robotBackground.png",
		obstacles = dofile("themes/robot/obstacles.lua"),
		wave = dofile("round1.lua"),
		
		waveTable = {
			["NormalCreep"] = 1,
			["MediumCreep"] = 2,
         ["HardCreep"] = 3,
         ["BossCreep"] = 4,
         ["FlyingCreep"] = 5,
		}           
	 
}

return robot


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




