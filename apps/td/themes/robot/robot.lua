local robot = {
		mainMenuBackground = "",
		creeps = {
			normalCreep = { hp = 50, creepType = "assets/normalRobot.jpg", speed = 100}
		},
		towers = {
			normalTower = {towerType = "assets/normalTower.png", damage = 10, range = 100, cd = 1000}
		},
		obstacles = { },
		boardBackground = "assets/robotBackground.jpg"						
}

return robot
