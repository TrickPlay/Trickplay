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
		AssetLoader:preloadImage(themeName..t.creeps[i].name, "themes/"..themeName.."/assets/"..t.creeps[i].name..".jpg")
		--print(themeName..t.creeps[i].name)
	end
	
	if t.bullets then
		for k, v in pairs(t.bullets) do
			AssetLoader:preloadImage(themeName.."Bullet"..k, "themes/"..themeName.."/assets/"..v.im..".jpg")
		end
	end
	
	for k, v in pairs(t.towers) do
		--print("themes/"..themeName.."/assets/"..v.name..".jpg")
		AssetLoader:preloadImage(themeName..v.name, "themes/"..themeName.."/assets/"..v.name..".jpg")
		AssetLoader:preloadImage(themeName..v.name.."Icon", "themes/"..themeName.."/assets/"..v.name.."Icon.jpg")
		AssetLoader:preloadImage(themeName..v.name.."Fire", "themes/"..themeName.."/assets/"..v.name.."Fire.jpg")
		
		if v.upgrades then
			for key,val in ipairs(v.upgrades) do
				AssetLoader:preloadImage(themeName..v.name..key, "themes/"..themeName.."/assets/"..v.name..key..".jpg")
				AssetLoader:preloadImage(themeName..v.name.."Fire"..key, "themes/"..themeName.."/assets/"..v.name.."Fire"..key..".jpg")
				print(themeName..v.name..key)
			end
		end
		
	end
	
	AssetLoader:preloadImage(themeName.."Background", "themes/"..themeName.."/assets/Background.jpg")
	AssetLoader:preloadImage(themeName.."Overlay", "themes/"..themeName.."/assets/Overlay.jpg")

end

AssetLoader:preloadImage("Resume","assets/Resume.jpg")
AssetLoader:preloadImage("ResumeFocus","assets/ResumeFocus.jpg")
AssetLoader:preloadImage("SaveAndQuit","assets/SaveAndQuit.jpg")
AssetLoader:preloadImage("SaveAndQuitFocus","assets/SaveAndQuitFocus.jpg")

AssetLoader:preloadImage("FocusBan","assets/FocusBan.jpg")



AssetLoader:preloadImage("TowerShadow1","assets/TowerShadow1.jpg")
AssetLoader:preloadImage("TowerShadow2","assets/TowerShadow2.jpg")
AssetLoader:preloadImage("win","themes/robot/assets/win.jpg")


AssetLoader:preloadImage("MainMenuPressEnter","assets/MainMenuPressEnter.jpg")

AssetLoader:preloadImage("MainMenuOverlay","assets/MainMenuOverlay.jpg")
AssetLoader:preloadImage("MainMenuSmallButton","assets/MainMenuSmallButton.jpg")
AssetLoader:preloadImage("MainMenuSmallFocus","assets/MainMenuSmallFocus.jpg")
AssetLoader:preloadImage("MainMenuResume","assets/MainMenuResume.jpg")
AssetLoader:preloadImage("MainMenuSingle","assets/MainMenuSingle.jpg")
AssetLoader:preloadImage("MainMenuDouble","assets/MainMenuDouble.jpg")
AssetLoader:preloadImage("MainMenuFocus","assets/MainMenuFocus.jpg")

AssetLoader:preloadImage("RedArrow","assets/RedArrow.jpg")
AssetLoader:preloadImage("MainMenu","assets/MainMenu.jpg")
AssetLoader:preloadImage("DescriptionRight","themes/robot/assets/DescriptionRight.jpg")
AssetLoader:preloadImage("DescriptionLeft","themes/robot/assets/DescriptionLeft.jpg")

AssetLoader:preloadImage("bloodyhand","themes/robot/assets/bloodyhand.jpg")

AssetLoader:preloadImage("BuyFocus","themes/robot/assets/BuyFocus.jpg")
AssetLoader:preloadImage("BuyFocusCircle","themes/robot/assets/BuyFocusCircle.jpg")

AssetLoader:preloadImage("ProgressBar","assets/ProgressBar.jpg")
AssetLoader:preloadImage("WaveProgress", "themes/robot/assets/WaveProgress.jpg")

AssetLoader:preloadImage("TitleBackground","themes/robot/assets/TitleBackground.jpg")

AssetLoader:preloadImage("smallWindow","assets/SmallWindow.jpg")
AssetLoader:preloadImage("largeWindow","assets/LargeWindow.jpg")
AssetLoader:preloadImage("InfoBar2","assets/player2InfoBar.jpg")

--AssetLoader:preloadImage("levelWindow","assets/levelWindow.jpg")
--AssetLoader:preloadImage("levelWindowLocked","assets/levelWindowLocked.jpg")
--AssetLoader:preloadImage("levelWindowCompleted","assets/levelWindowCompleted.jpg")

AssetLoader:preloadImage("levelWindowFocus","themes/robot/assets/levelselector/selectorFocus.jpg")
AssetLoader:preloadImage("levelWindow","themes/robot/assets/levelselector/empty.jpg")
AssetLoader:preloadImage("levelWindowLocked","themes/robot/assets/levelselector/locked.jpg")
AssetLoader:preloadImage("levelWindowLock","themes/robot/assets/levelselector/lock.jpg")
AssetLoader:preloadImage("levelWindowCompleted","themes/robot/assets/levelselector/check.jpg")


AssetLoader:preloadImage("select","assets/Selector.jpg")
AssetLoader:preloadImage("select2","assets/Selector2.jpg")
AssetLoader:preloadImage("death","themes/robot/assets/NormalCreepBlood.jpg")
AssetLoader:preloadImage("flydeath","themes/robot/assets/FlyingCreepBlood.jpg")
AssetLoader:preloadImage("normal","assets/normalRobot.jpg")
AssetLoader:preloadImage("mediumRobot","assets/mediumRobot.jpg")
AssetLoader:preloadImage("explosion","themes/robot/assets/explosion.jpg")
AssetLoader:preloadImage("normalRobotBuy","assets/robots/normalRobot/buy.jpg")
AssetLoader:preloadImage("normalRobot","assets/robots/normalRobot/strip8.jpg")
AssetLoader:preloadImage("wall","assets/wall.jpg")
AssetLoader:preloadImage("slowTower","assets/slowTowerstrip8.jpg")
AssetLoader:preloadImage("slowTowerIcon","assets/slowTower.jpg")
AssetLoader:preloadImage("backIcon","assets/backIcon.jpg")
AssetLoader:preloadImage("upgradeIcon","assets/upgradeIcon.jpg")
AssetLoader:preloadImage("obstacles","themes/robot/assets/obstacles.jpg")
AssetLoader:preloadImage("shadow","themes/robot/assets/CreepShadow.jpg")	
AssetLoader:preloadImage("sellIcon","assets/sell.jpg")

AssetLoader:preloadImage("PlayerRight","themes/robot/assets/PlayerRight.jpg")
AssetLoader:preloadImage("PlayerLeft","themes/robot/assets/PlayerLeft.jpg")

AssetLoader:preloadImage("NotEnoughMoney","themes/robot/assets/NotEnoughMoney.jpg")


