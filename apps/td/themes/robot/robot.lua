local robot = {
		themeName = "robot",
		mainMenuBackground = "",
		bullets = {
			--{id = 1, frames = 5, im = "Ringwave"},
			{id = 1, im = "Cannon", speed = 1000},
			{id = 2, im = "Laser", speed = 3000},
			{id = 3, im = "Snowball", speed = 800},
		},
		creeps = {
			{ hp = 100, speed = 20, bounty = 10, flying = false, frames = 7, x_offset = -SP/2, y_offset = -SP, name = "NormalCreep"},
			{ hp = 300, speed = 50, bounty = 15, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "MediumCreep"},
            { hp = 1000, speed = 40, bounty = 15, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "HardCreep"},
            { hp = 20000, speed = 40, bounty = 200, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "BossCreep"},
            { hp = 80, speed = 35, bounty = 40, flying = true, frames = 4,  x_offset = -SP, y_offset = 0, name = "FlyingCreep"},
            { hp = 100, speed = 20, bounty = 10, flying = false, frames = 7, x_offset = -SP/2, y_offset = -SP, name = "NormalCreep"},
		},
		towers = {
			normalTower = {
				damage = 20,
				range = 300,
				cooldown = 0.5,
				cost = 30,
				slow = false,
				splash = false,
				frames = 1,
				attacksFlying = true,
				name = "NormalTower",
				mode = "rotate",
				bullet = 1,
				upgrades = {
					{damage = 40, range = 350, cooldown = 0.5, cost = 20, slow = false},
					{damage = 90, range = 400, cooldown = 0.5, cost = 50, slow = false}
				}
			},
			slowTower = {
				damage = 5,
				range = 400, 
				cooldown = 1, 
				cost = 80, 
				slowammount = 65, 
				slow = true, 
				slowlength = 2, 
				splash = false, 
				frames = 1, 
				splashradius = 240, 
				attacksFlying = false,
				name = "SlowTower", 
				mode = "rotate", 
				bullet = 3,
				upgrades = {
					{damage = 5, range = 400, cooldown = 1, cost = 40, slowammount = 50},
					{damage = 10, range = 400, cooldown = 1, cost = 40, slowammount = 25, splash = true}
				}
			},
			nukeTower =	{
				damage = 30, 
				range = 200, 
				cooldown = .5, 
				cost = 70, 
				slowammount = 100, 
				slow = false, 
				splash = true, 
				frames = 1, 
				splashradius = 360, 
				name = "NukeTower", 
				attackMode = "fire",
				attackFrames = 4,
				attacksFlying = false,
				upgrades = {
					{damage = 40, range = 200, cooldown = 0.45, cost = 150, splash = true},
					{damage = 70, range = 230, cooldown = 0.35, cost = 200, splash = true}
				}
			},
			laserTower = {
				damage = 50, 
				range = 500, 
				cooldown = 1, 
				cost = 100, 
				slow = false, 
				splash = false, 
				frames = 1, 
				attacksFlying = true,
				name = "LaserTower", 
				mode = "rotate", 
				bullet = 2, 
				attackFrames = 5, 
				attackMode = "fire",
				upgrades = {
					{damage = 100, range = 500, cooldown = 0.8, cost = 100, slow = false},
					{damage = 200, range = 500, cooldown = 0.8, cost = 100, slow = false},
				}							
			},
			wall = { damage = 0, range = 0, cooldown = 1000, cost = 5, slowammount = 0, frames = 1, slow = false, name = "Wall",	}
		},
		boardBackground = "assets/robotBackground.png",
		obstacles = dofile("themes/robot/obstacles.lua"),
		wave = nil,
		
		waveTable = {
			["NormalCreep"] = 1,
			["MediumCreep"] = 2,
		   ["HardCreep"] = 3,
		   ["BossCreep"] = 4,
		   ["FlyingCreep"] = 5,
		   ["SlowCreep"] = 6,
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




