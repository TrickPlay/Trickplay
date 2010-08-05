-- levels

function createLevelMenu(l)
        
        local list =	{
                                {
                                AssetLoader:getImage("levelWindow",{ extra = {level = 1}, }),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 2}, x=-40}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 3}, x=-40})
                                },
                                {
                                AssetLoader:getImage("levelWindow",{ extra = {level = 4}, y=-40}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 5}, x=-40, y=-40}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 6}, x=-40, y=-40})
                                },
                                {
                                AssetLoader:getImage("levelWindow",{ extra = {level = 7}, y=-40}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 8}, x=-40, y=-40}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 9}, x=-40, y=-40})
                                },
                                {
                                Group{name = "null"},
                                AssetLoader:getImage("levelWindow", {extra = {level = 10}, x=-40, y=-40}),
                                Group{name = "null"}
                                }
                        }
        
        
        local a = 1
        for i=1, #list do
                for j=1, #list[i] do
                
                        local b = list[i][j]
                
                        if a < l then
                                list[i][j] = AssetLoader:getImage("levelWindowCompleted",{extra={level=b.extra.level}, x = b.x, y = b.y})
                        elseif a == l then
                                list[i][j] = AssetLoader:getImage("levelWindow",{extra={level=b.extra.level}, x = b.x, y = b.y})
                        else
                                list[i][j] = AssetLoader:getImage("levelWindowLocked",{extra={level=b.extra.level}, x = b.x, y = b.y})
                        end
                        
                        a = a + 1
                        if a > 9 then a = 10 end
                end
        end
        
        list[4][1] = Group{name = "null"}
        list[4][3] = Group{name = "null"}
        
        local g = Group{}
        
        screen:add(g)
        
        
        local levelFocus = Rectangle{color="FF00CC", w=320, h=220}
        
        LevelMenu = Menu.create(g, list, levelFocus)
        LevelMenu.container.opacity = 0
        LevelMenu:create_key_functions()
        LevelMenu:button_directions()
        LevelMenu:create_buttons(10, "Sans 62px")
        LevelMenu:apply_color_change("FFFFFF", "000000")
        
        LevelMenu.container.x = 450
        LevelMenu.container.y = 70
        LevelMenu.container.scale = {.7, .7}
        
        LevelMenu.buttons.extra.space = function()
        
                LevelMenu.container.opacity = 0
                MainMenu.container.opacity = 255
                
                ACTIVE_CONTAINER = MainMenu
                keyboard_key_down = MainMenu.buttons.on_key_down
        
        end
        
        LevelMenu.buttons.extra.r = function()
        
                --dofile("Globals.lua")
                
                round = settings.round or tonumber( list[LevelMenu.y][LevelMenu.x].extra.level )
                
                -- Global current level
                currentLevel = round
                savedRound = round
                --LevelMenu.theme.wave = dofile("themes/"..LevelMenu.theme.themeName.."/round"..round..".lua")
                LevelMenu.theme.wave = dofile("themes/"..LevelMenu.theme.themeName.."/round"..round..".lua")
        
                game = Game:new{ theme = LevelMenu.theme , gold = LevelMenu.theme.wave.money}
                game:startGame()
                
                screen:add(countdowntimer, phasetext, playertext, goldtext,livestext)
                screen:add(bulletImage, healthbar, shootAnimation, healthbarblack, bloodGroup, obstaclesGroup)
                
                
        
        end
        
end
