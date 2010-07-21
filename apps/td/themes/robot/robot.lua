local robot = {
		mainMenuBackground = "",
		creeps = {
			normalCreep = { hp = 6000, creepType = "assets/normalRobot.jpg", speed = 50},
			mediumCreep = { hp = 2000, creepType = "assets/mediumRobot.jpg", speed = 200}
		},
		towers = {
			normalTower = {towerType = "assets/robots/normalRobot/01.png", damage = 5, range = 300, cooldown = 50, cost = 50}
		},
		obstacles = { },
		boardBackground = "assets/robotBackground.png"
}

return robot
