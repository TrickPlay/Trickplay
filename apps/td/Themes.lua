Themes = {
	zombie = dofile("themes/zombie/zombie.lua"),
	robot = dofile("themes/robot/robot.lua"),
	pacman = dofile("themes/pacman/pacman.lua")
}

-- Load images
AssetLoader:construct()

-- For each theme file
for themeName, t in pairs(Themes) do

	for i=1, #t.creeps do
		AssetLoader:preloadImage(themeName..t.creeps[i].name, "themes/"..themeName.."/assets/"..t.creeps[i].name..".png")
		--print(themeName..t.creeps[i].name)
	end
	
	if t.bullets then
		for k, v in pairs(t.bullets) do
			AssetLoader:preloadImage(themeName.."Bullet"..k, "themes/"..themeName.."/assets/"..v.im..".png")
		end
	end
	
	for k, v in pairs(t.towers) do
		--print("themes/"..themeName.."/assets/"..v.name..".png")
		AssetLoader:preloadImage(themeName..v.name, "themes/"..themeName.."/assets/"..v.name..".png")
		AssetLoader:preloadImage(themeName..v.name.."Icon", "themes/"..themeName.."/assets/"..v.name.."Icon.png")
		AssetLoader:preloadImage(themeName..v.name.."Fire", "themes/"..themeName.."/assets/"..v.name.."Fire.png")
		
		if v.upgrades then
			for key,val in ipairs(v.upgrades) do
				AssetLoader:preloadImage(themeName..v.name..key, "themes/"..themeName.."/assets/"..v.name..key..".png")
				print(themeName..v.name..key)
			end
		end
		
	end
	
	AssetLoader:preloadImage(themeName.."Background", "themes/"..themeName.."/assets/Background.png")
	AssetLoader:preloadImage(themeName.."Overlay", "themes/"..themeName.."/assets/Overlay.png")

end

AssetLoader:preloadImage("normal","assets/normalRobot.png")
AssetLoader:preloadImage("mediumRobot","assets/mediumRobot.png")
AssetLoader:preloadImage("explosion","themes/robot/assets/explosion.png")
AssetLoader:preloadImage("normalRobotBuy","assets/robots/normalRobot/buy.png")
AssetLoader:preloadImage("normalRobot","assets/robots/normalRobot/strip8.png")
AssetLoader:preloadImage("wall","assets/wall.jpg")
AssetLoader:preloadImage("slowTower","assets/slowTowerstrip8.png")
AssetLoader:preloadImage("slowTowerIcon","assets/slowTower.png")
AssetLoader:preloadImage("backIcon","assets/backIcon.png")
AssetLoader:preloadImage("upgradeIcon","assets/upgradeIcon.png")

	
AssetLoader:preloadImage("sellIcon","assets/sell.png")
