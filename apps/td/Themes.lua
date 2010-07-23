Themes = {
	zombie = dofile("themes/zombie/zombie.lua"),
	robot = dofile("themes/robot/robot.lua")
}

-- Load images
AssetLoader:construct()

-- For each theme file
for themeName, t in pairs(Themes) do

	for i=1, #t.creeps do
		AssetLoader:preloadImage(themeName..t.creeps[i].name,"themes/"..themeName.."/assets/"..t.creeps[i].name..".png")
		print(themeName..t.creeps[i].name)
	end
	
	for k, v in pairs(t.towers) do
		print("themes/"..themeName.."/assets/"..t.towers[k].name..".png")
		AssetLoader:preloadImage(themeName..t.towers[k].name,"themes/"..themeName.."/assets/"..t.towers[k].name..".png")
	end
end

AssetLoader:preloadImage("normal","assets/normalRobot.png")
AssetLoader:preloadImage("mediumRobot","assets/mediumRobot.png")
	
AssetLoader:preloadImage("normalRobotBuy","assets/robots/normalRobot/buy.png")
AssetLoader:preloadImage("normalRobot","assets/robots/normalRobot/strip8.png")
AssetLoader:preloadImage("wall","assets/wall.jpg")
AssetLoader:preloadImage("slowTower","assets/slowTowerstrip8.png")
AssetLoader:preloadImage("slowTowerIcon","assets/slowTower.png")
AssetLoader:preloadImage("backIcon","assets/backIcon.png")

	
AssetLoader:preloadImage("sellIcon","assets/sell.png")
