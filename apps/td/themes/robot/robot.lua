local robot = {
		mainMenuBackground = "",
		creeps = {
			normalCreep = { hp = 1000, creepType = "assets/normalRobot.jpg", speed = 50, bounty = 100,flying = false},
			mediumCreep = { hp = 2000, creepType = "assets/mediumRobot.jpg", speed = 100, bounty = 150, flying = false}
		},
		towers = {
			normalTower = {towerType = "assets/robots/normalRobot/01.png", damage = 10, range = 300, cooldown = 50, cost = 50},
			wall = {towerType = "assets/normalTower.png", damage = 0, range = 0, cooldown = 1000, cost = 5}
		},
		obstacles = { },
		boardBackground = "assets/robotBackground.png"
}

return robot
