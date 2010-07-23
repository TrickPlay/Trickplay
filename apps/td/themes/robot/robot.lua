local robot = {
                themeName = "robot",
		mainMenuBackground = "",
		creeps = {
                                { hp = 100, speed = 30, bounty = 10, flying = false, name = "NormalCreep"},
                                { hp = 200, speed = 50, bounty = 15, flying = false, name = "MediumCreep"},
                                { hp = 300, speed = 50, bounty = 15, flying = false, name = "MediumCreep"}
		},
		towers = {
                                normalTower =
                                                { damage = 20, range = 300, cooldown = 0.5, cost = 50, slow = 100, name = "NormalTower",
                                                                upgrades =      {
                                                                                                {damage = 30, range = 400, cooldown = 0.5, cost = 35, slow = 100},
                                                                                                {damage = 40, range = 500, cooldown = 0.5, cost = 35, slow = 100}
                                                                                }
                                                },
                                slowTower =
                                                { damage = 1, range = 400, cooldown = 1, cost = 80, slow = 75, name = "SlowTower",
                                                                upgrades =      {
                                                                                                {damage = 1, range = 400, cooldown = 1, cost = 40, slow = 50},
                                                                                                {damage = 10, range = 400, cooldown = 1, cost = 40, slow = 25}
                                                                                }
                                                },
                                wall =
                                                { damage = 0, range = 0, cooldown = 1000, cost = 5,slow = 0, name = "Wall"
                                                }
		},
		obstacles = { },
		boardBackground = "assets/robotBackground.png",
		wave = {
				        -- Wave 1
				        {
				                        {name = "NormalCreep", num = 1},
				                        {name = "MediumCreep", num = 20},
				                        size = 21
				        },
				        
				        -- Wave 2
				        {
				                        {name = "NormalCreep", num = 15},
				                        {name = "MediumCreep", num = 15},
				                        size = 30
				        },
				        
				        -- Wave 3
				        {
				                        {name = "NormalCreep", num = 25},
				                        {name = "MediumCreep", num = 25},
				                        size = 50
				        }
		},
		waveTable = {
			["NormalCreep"] = 1,
			["MediumCreep"] = 2
		}           
         
}

return robot

