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
				AssetLoader:preloadImage(themeName..v.name.."Fire"..key, "themes/"..themeName.."/assets/"..v.name.."Fire"..key..".png")
				print(themeName..v.name..key)
			end
		end
		
	end
	
	AssetLoader:preloadImage(themeName.."Background", "themes/"..themeName.."/assets/Background.png")
	AssetLoader:preloadImage(themeName.."Overlay", "themes/"..themeName.."/assets/Overlay.png")

end

AssetLoader:preloadImage("MainMenuPressEnter","assets/MainMenuPressEnter.png")

AssetLoader:preloadImage("MainMenuOverlay","assets/MainMenuOverlay.png")
AssetLoader:preloadImage("MainMenuSmallButton","assets/MainMenuSmallButton.png")
AssetLoader:preloadImage("MainMenuSmallFocus","assets/MainMenuSmallFocus.png")
AssetLoader:preloadImage("MainMenuResume","assets/MainMenuResume.png")
AssetLoader:preloadImage("MainMenuSingle","assets/MainMenuSingle.png")
AssetLoader:preloadImage("MainMenuDouble","assets/MainMenuDouble.png")
AssetLoader:preloadImage("MainMenuFocus","assets/MainMenuFocus.png")

AssetLoader:preloadImage("RedArrow","assets/RedArrow.png")
AssetLoader:preloadImage("MainMenu","assets/MainMenu.png")
AssetLoader:preloadImage("DescriptionRight","themes/robot/assets/DescriptionRight.png")
AssetLoader:preloadImage("bloodyhand","themes/robot/assets/bloodyhand.png")
AssetLoader:preloadImage("BuyFocus","themes/robot/assets/BuyFocus.png")

AssetLoader:preloadImage("ProgressBar","assets/ProgressBar.png")
AssetLoader:preloadImage("WaveProgress", "themes/robot/assets/WaveProgress.png")
AssetLoader:preloadImage("TitleBackground","themes/robot/background.png")
AssetLoader:preloadImage("smallWindow","assets/SmallWindow.png")
AssetLoader:preloadImage("largeWindow","assets/LargeWindow.png")
AssetLoader:preloadImage("InfoBar2","assets/player2InfoBar.png")

--AssetLoader:preloadImage("levelWindow","assets/levelWindow.png")
--AssetLoader:preloadImage("levelWindowLocked","assets/levelWindowLocked.png")
--AssetLoader:preloadImage("levelWindowCompleted","assets/levelWindowCompleted.png")

AssetLoader:preloadImage("levelWindowFocus","themes/robot/assets/levelselector/selectorFocus.png")
AssetLoader:preloadImage("levelWindow","themes/robot/assets/levelselector/empty.png")
AssetLoader:preloadImage("levelWindowLocked","themes/robot/assets/levelselector/locked.png")
AssetLoader:preloadImage("levelWindowLock","themes/robot/assets/levelselector/lock.png")
AssetLoader:preloadImage("levelWindowCompleted","themes/robot/assets/levelselector/check.png")


AssetLoader:preloadImage("select","assets/Selector.png")
AssetLoader:preloadImage("select2","assets/Selector2.png")
AssetLoader:preloadImage("death","themes/robot/assets/NormalCreepBlood.png")
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
AssetLoader:preloadImage("obstacles","themes/robot/assets/obstacles.png")
AssetLoader:preloadImage("shadow","themes/robot/assets/CreepShadow.png")	
AssetLoader:preloadImage("sellIcon","assets/sell.png")
AssetLoader:preloadImage("PlayerRight","themes/robot/assets/PlayerRight.png")

AssetLoader:preloadImage("NotEnoughMoney","themes/robot/assets/NotEnoughMoney.png")


