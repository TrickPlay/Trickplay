local robot = {
        themeName = "robot",
        mainMenuBackground = "",
        bullets = {
                {id = 1, im = "Cannon", speed = 1000},
                {id = 2, im = "Laser", speed = 3000},
                {id = 3, im = "Snowball", speed = 800},
        },
        creeps = {
                { hp = 100, speed = 20, bounty = 1, flying = false, frames = 7, x_offset = -SP/2, y_offset = -SP+60, name = "NormalCreep", deathSound = "ZombieCrunch.mp3"},
                { hp = 300, speed = 30, bounty = 1, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP+60, name = "MediumCreep", deathSound = "ZombieCrunch.mp3"},
                { hp = 1000, speed = 25, bounty = 2, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP+60, name = "HardCreep", deathSound = "ZombieCrunch.mp3"},
                { hp = 20000, speed = 20, bounty = 20, flying = false, frames = 7,  x_offset = -SP/2, y_offset = -SP, name = "BossCreep", deathSound = "ZombieCrunch.mp3"},
                { hp = 80, speed = 35, bounty = 1, flying = true, frames = 4,  x_offset = -SP, y_offset = 0+60, name = "FlyingCreep", deathSound = "ZombieCrunch.mp3"},
                { hp = 100, speed = 20, bounty = 1, flying = false, frames = 7, x_offset = -SP/2, y_offset = -SP+60, name = "NormalCreep", deathSound = "ZombieCrunch.mp3"},
        },
        towers = {
                
                normalTower = {
                        name = "normalTower",
                        damage = 20,
                        range = 300,
                        cooldown = 0.5,
                        cost = 5,
                        slow = false,
                        splash = false,
                        frames = 1,
                        attacksFlying = true,
                        name = "NormalTower",
                        mode = "rotate",
                        bullet = 1,
                        upgrades = {
                                {damage = 40, range = 350, cooldown = 0.5, cost = 4, slow = false},
                                {damage = 90, range = 400, cooldown = 0.5, cost = 10, slow = false}
                        },
                        sound = "Gun.mp3"
                },
                
                slowTower = {
                        name = "slowTower",
                        damage = 5,
                        range = 400, 
                        cooldown = 1, 
                        cost = 10, 
                        slowammount = 70, 
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
                                {damage = 10, range = 450, cooldown = 1, cost = 10, slowammount = 55},
                                {damage = 10, range = 450, cooldown = 1, cost = 50, slowammount = 40, splash = true}
                        },
                        sound = "SnowBullet.mp3"
                },
                
                nukeTower =	{
                        name = "nukeTower",
                        damage = 160, 
                        range = 200, 
                        cooldown = 2, 
                        cost = 25, 
                        slow = false, 
                        splash = true,
                        damageAroundSelf = true, 
                        frames = 1, 
                        splashradius = 360, 
                        name = "NukeTower", 
                        attackMode = "fire",
                        attackFrames = 4,
                        attacksFlying = false,
                        upgrades = {
                                {damage = 320, range = 250, cooldown = 1.8, cost = 35, splash = true},
                                {damage = 480, range = 300, cooldown = 1.6, cost = 45, splash = true}
                        },
                        sound = "Explosion.mp3"
                },
                
                laserTower = {
                        name = "laserTower",
                        damage = 100, 
                        range = 500, 
                        cooldown = 0.25, 
                        cost = 70, 
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
                                {damage = 200, range = 550, cooldown = 0.20, cost = 70, slow = false},
                                {damage = 450, range = 700, cooldown = 0.15, cost = 250, slow = false},
                        },
                        sound = "Laser.mp3"							
                },
                
                --wall = { damage = 0, range = 0, cooldown = 1000, cost = 5, slowammount = 0, frames = 1, slow = false, name = "Wall",	}
                
        },
        boardBackground = "assets/robotBackground.jpg",
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




