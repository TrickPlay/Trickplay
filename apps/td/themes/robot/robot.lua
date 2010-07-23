local robot = {
                themeName = "robot",
		mainMenuBackground = "",
		creeps = {
			{ hp = 100, creepType = "assets/normalRobot.jpg", speed = 30, bounty = 10, flying = false, name = "NormalCreep"},
			{ hp = 200, creepType = "assets/mediumRobot.jpg", speed = 50, bounty = 15, flying = false, name = "MediumCreep"}
		},
		towers = {
			normalTower = {towerType = "assets/robots/normalRobot/01.png", damage = 20, range = 300, cooldown = 0.5, cost = 50, slow = 0, name = "NormalTower"},
			wall = {towerType = "assets/normalTower.png", damage = 0, range = 0, cooldown = 1000, cost = 5,slow = 0, name = "Wall"},
			slowTower = {towerType = "assets/slowTower.png", damage = 1, range = 400, cooldown = 1, cost = 80, slow = 20, name = "SlowTower"}
		},
		obstacles = { },
		boardBackground = "assets/robotBackground.png",
                wave = {
                                -- Wave 1
                                {
                                                {type = "NormalCreep", num = 30}
                                },
                                
                                -- Wave 2
                                {
                                                {type = "NormalCreep", num = 15},
                                                {type = "MediumCreep", num = 15}
                                },
                                
                                -- Wave 3
                                {
                                                {type = "NormalCreep", num = 25},
                                                {type = "MediumCreep", num = 25}
                                }
                }
}

return robot
