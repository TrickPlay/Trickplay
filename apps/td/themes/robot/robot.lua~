local robot = {
		themeName = "robot",
		mainMenuBackground = "",
		bullets = {
			--{id = 1, frames = 5, im = "Ringwave"},
			{id = 1, im = "Cannon", speed = 1000},
			{id = 2, im = "Laser", speed = 1000},
		},
		creeps = {
			{ hp = 100, speed = 20, bounty = 10, flying = false, frames = 7, x_offset = -SP/2, y_offset = -SP, name = "NormalCreep"},
			{ hp = 300, speed = 50, bounty = 15, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "MediumCreep"},
            { hp = 1000, speed = 40, bounty = 15, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "HardCreep"},
            { hp = 20000, speed = 40, bounty = 200, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "BossCreep"},
            { hp = 80, speed = 35, bounty = 40, flying = true, frames = 4,  x_offset = -SP, y_offset = 0, name = "FlyingCreep"}
		},
		towers = {
				normalTower =
						{ damage = 20, range = 300, cooldown = 0.5, cost = 50, slow = false, splash = false, frames = 1, name = "NormalTower", simpleRotate = true, mode = "rotate", bullet = 1,
								upgrades = {
												{damage = 30, range = 400, cooldown = 0.5, cost = 35, slow = false},
												{damage = 40, range = 500, cooldown = 0.5, cost = 35, slow = false}
										}
						},
				slowTower =
						{ damage = 5, range = 400, cooldown = 1, cost = 80, slowammount = 75, slow = true, splash = true, frames = 8, splashradius = 240, name = "SlowTower", mode = "rotate",
								upgrades = {
												{damage = 5, range = 400, cooldown = 1, cost = 40, slowammount = 50},
												{damage = 10, range = 400, cooldown = 1, cost = 40, slowammount = 25}
										}
						},
				nukeTower =
						{ damage = 30, range = 200, cooldown = .5, cost = 70, slowammount = 100, slow = false, splash = true, frames = 1, splashradius = 360, name = "NukeTower", mode = "fire", attackFrames = 4,
						},
				laserTower = 
						{damage = 50, range = 500, cooldown = 1, cost = 100, slow = false, splash = false, frames = 1, name = "LaserTower", simpleRotate = true, mode = "rotate", bullet = 2,
								upgrades = {
											{damage = 100, range = 500, cooldown = 0.8, cost = 100, slow = false},
											{damage = 200, range = 500, cooldown = 0.8, cost = 100, slow = false},
								}							
				},
				wall =
						{ damage = 0, range = 0, cooldown = 1000, cost = 5, slowammount = 0, frames = 1, slow = false, name = "Wall",
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




