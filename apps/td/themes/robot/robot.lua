local robot = {
		mainMenuBackground = "",
		creeps = {
			{ hp = 2000, creepType = "assets/normalRobot.jpg", speed = 30, bounty = 10,flying = false},
			{ hp = 5000, creepType = "assets/mediumRobot.jpg", speed = 50, bounty = 15, flying = false}
		},
		towers = {
			normalTower = {towerType = "assets/robots/normalRobot/01.png", damage = 20, range = 300, cooldown = 35, cost = 50, slow = 0},
			wall = {towerType = "assets/normalTower.png", damage = 0, range = 0, cooldown = 1000, cost = 5,slow = 0},
			slowTower = {towerType = "assets/slowTower.png", damage = 1, range = 400, cooldown = 35, cost = 80, slow = 20}
		},
		obstacles = { },
		boardBackground = "assets/robotBackground.png"
}

return robot
