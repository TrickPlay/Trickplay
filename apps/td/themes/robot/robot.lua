local robot = {
		mainMenuBackground = "",
		creeps = {
			normalCreep = { hp = 1000, creepType = "assets/normalRobot.jpg", speed = 100, bounty = 100},
			mediumCreep = { hp = 2000, creepType = "assets/mediumRobot.jpg", speed = 200, bounty = 150}
		},
		towers = {
			normalTower = {towerType = "assets/robots/normalRobot/01.png", damage = 5, range = 300, cooldown = 50, cost = 50},
			wall = {}
		},
		obstacles = { },
		boardBackground = "assets/robotBackground.png"
}

return robot
