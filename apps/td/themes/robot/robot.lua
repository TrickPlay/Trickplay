local robot = {
		mainMenuBackground = "",
		creeps = {
			normalCreep = { hp = 50, creepType = "assets/normalRobot.jpg", speed = 100},
			mediumCreep = { hp = 100, creepType = "assets/mediumRobot.jpg", speed = 200}
		},
		towers = {
			normalTower = {towerType = "assets/normalTower.png", damage = 10, range = 100, cooldown = 50, cost = 50}
		},
		obstacles = { },
		boardBackground = "assets/robotBackground.jpg"
}

return robot
