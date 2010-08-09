-- levels

function createLevelMenu(l)

			--debug()
        
        local list =	{
                                {
                                AssetLoader:getImage("levelWindow",{ extra = {level = 1} }),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 2} }),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 3} })
                                },
                                {
                                AssetLoader:getImage("levelWindow",{ extra = {level = 4}}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 5}}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 6}})
                                },
                                {
                                AssetLoader:getImage("levelWindow",{ extra = {level = 7}}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 8}}),
                                AssetLoader:getImage("levelWindow",{ extra = {level = 9}})
                                },
                                {
                                Group{name = "null"},
                                AssetLoader:getImage("levelWindow", {extra = {level = 10}}),
                                Group{name = "null"}
                                }
                        }
        
        
        local a = 1
        for i=1, #list do
                for j=1, #list[i] do
                
                        local b = list[i][j]
                
                        if a < l then
                                list[i][j] = Group{ extra={level=b.extra.level}, x = b.x, y = b.y}
                                local window = AssetLoader:getImage("levelWindow",{})
                                local text = Text{font = "Sans 90px", text = "Level "..b.extra.level, color = "000000"}
                                text.anchor_point = {text.w/2, text.h/2}
                                text.position = {window.w/2, window.h/2}
                                
                                list[i][j]:add( window, text )
                                list[i][j]:add( AssetLoader:getImage("levelWindowCompleted",{}) )
                        elseif a == l then
                                list[i][j] = Group{ extra={level=b.extra.level}, x = b.x, y = b.y}
                                local window = AssetLoader:getImage("levelWindow",{})
                                local text = Text{font = "Sans 90px", text = "Level "..b.extra.level, color = "000000"}
                                text.anchor_point = {text.w/2, text.h/2}
                                text.position = {window.w/2, window.h/2}
                                
                                list[i][j]:add( window, text )
                                --list[i][j]:add( AssetLoader:getImage("levelWindowCompleted",{}) )
                        else
                                if b.extra.level then
                                        list[i][j] = Group{ extra={level=b.extra.level}, x = b.x, y = b.y}
                                        local window = AssetLoader:getImage("levelWindowLocked",{})
                                        local text = Text{font = "Sans 90px", text = "Level "..b.extra.level, color = "000000"}
                                        text.anchor_point = {text.w/2, text.h/2}
                                        text.position = {window.w/2, window.h/2}
                                        
                                        list[i][j]:add( window, text )
                                        list[i][j]:add( AssetLoader:getImage("levelWindowLock",{}) )
                                end
                        end
                        
                        print(b.w)
                        
                        a = a + 1
                        if a > 9 then a = 10 end
                end
        end
        
        for i=1, #list do
                for j=1, #list[i] do
                        list[i][j].w = 550
                end
        end
        
        list[4][1] = Group{name = "null"}
        list[4][3] = Group{name = "null"}
        
        local g = Group{}
        
        screen:add(g)
        
        
        local levelFocus = AssetLoader:getImage("levelWindowFocus",{})
        
        --LevelMenu = Menu.create(g, list, levelFocus)
        
        LevelMenu = Menu:new{container = g, list = list, hl = levelFocus}
        
        LevelMenu.container.opacity = 0
        LevelMenu:create_key_functions()
        LevelMenu:button_directions()
        --debug()
        LevelMenu:create_buttons(0)
        --debug()
        --LevelMenu:apply_color_change("FFFFFF", "000000")
        
        
        LevelMenu.container.x = 215
        LevelMenu.container.y = 40
        LevelMenu.container.scale = {.9, .9}
        
        LevelMenu.buttons.extra.space = function()
        
                LevelMenu.container.opacity = 0
                MainMenu.container.opacity = 255
                ThemeMenu.container.opacity = 255
                
                ACTIVE_CONTAINER = MainMenu
                keyboard_key_down = MainMenu.buttons.on_key_down
        
        end
        
        LevelMenu.buttons.extra.r = function()
        
                --dofile("Globals.lua")
					 if (resumed) then
					 	round = settings.round
					 else
	               round = tonumber( list[LevelMenu.y][LevelMenu.x].extra.level )
                end
                -- Global current level
                currentLevel = round
                savedRound = round
                --LevelMenu.theme.wave = dofile("themes/"..LevelMenu.theme.themeName.."/round"..round..".lua")
                LevelMenu.theme.wave = dofile("themes/"..LevelMenu.theme.themeName.."/round"..round..".lua")
                
                game = Game:new{ theme = LevelMenu.theme , gold = LevelMenu.theme.wave.money}
                game:startGame()
                
                local infobar = AssetLoader:getImage("PlayerRight",{})
                local playerInfo = Group{opacity = 0, z=2.5}
                playerInfo:add(infobar, game.board.player.playertext, game.board.player.goldtext)
                playerInfo.anchor_point = {infobar.w, infobar.h}
                playerInfo.position = {screen.w, screen.h - 25}
                screen:add(playerInfo)
                
                game.board.player.info = Popup:new{group = playerInfo, fadeSpeed = 800, on_fade_in = function() end, on_fade_out = function() end}
                Popup:new{text = "Round "..round}
                
                screen:add(bulletImage, healthbar, shootAnimation, healthbarblack, bloodGroup, obstaclesGroup, leveltext, livestext)
        
        end
        
        LevelMenu:addSound("themes/robot/sounds/BeepHigh.wav", "themes/robot/sounds/BeepLow.wav")
        
end
