TowerInfo = {}

function TowerInfo:new(args)

        local g = Group{x=1300, y=20,z = 10, opacity=0}

	local object = {
                
		group = g,
                background = AssetLoader:getImage("smallWindow", {scale={1.20, 1.25} } ),
                --icon = 	AssetLoader:getImage(args.tower.prefix..args.tower.name,{x = g.x + 20, scale={.4, .4}} )
                
                level = Text{ x = 130, y = 10, text = "", font = "Sans 22px", color = "000000"  },
                damage = Text{ x = 130, y = 40, text = "", font = "Sans 22px", color = "000000"  },
                range = Text{ x = 130, y = 70, text = "", font = "Sans 22px", color = "000000"  },
                
                cooldown = Text{ x = 330, y = 10, text = "", font = "Sans 22px", color = "000000"  },
                upgrade = Text{ x = 330, y = 40, text = "", font = "Sans 22px", color = "000000"  },
                sell = Text{ x = 330, y = 70, text = "", font = "Sans 22px", color = "000000"  },

					 rangeCircle = Canvas{color="00FF00", x=0, y=0, width=1920, height=1080}
                
	}
        
        g:add(object.background, object.icon)
        g:add(object.level, object.damage, object.range, object.cooldown, object.upgrade, object.sell)
        
        --object.group:add( Text { font = "Sans 30px", text = "12341243", x = 200, y = 20, z =g.z, color = "FFFFFF"} )
        
        print("Added text")
        
        screen:add(g)
	
   setmetatable(object, self)
   self.__index = self
   return object
end

function TowerInfo:update(tower, player, isNew)

        if game.board.player2 and player == game.board.player2 then self.group.x = 40 self.group.y = 20 end

        if not isNew then
                
                self.group:remove(self.icon)
                
                local name = tower.prefix..tower.name
                
                if tower.level > 0 then name = name..tower.level end
                
                self.icon = AssetLoader:getImage(name,{x=-15, y=-15, scale={.6, .6}} )
                
                self.group:add(self.icon)
                
                self.level.text = "Current Level: " .. tower.level + 1
                self.damage.text = "Damage: " .. tower.damage
                self.range.text = "Range: " .. tower.range
                self.cooldown.text = "Cooldown time: " .. tower.cooldown
                if tower.level < tower.levels then self.upgrade.text = "Upgrade for: " .. tower.upgradeCost .. " Gold" else self.upgrade.text = "" end
                self.sell.text = "Sell for: " .. tower.cost * .5 .. " Gold"
                
        else
                
                self.group:remove(self.icon)
                
                self.icon = AssetLoader:getImage(game.board.theme.themeName..tower.name,{x=-15, y=-15, scale={.6, .6}} )
                
                self.group:add(self.icon)
                
                self.level.text = "Current Level: 1"
                self.damage.text = "Damage: " .. tower.damage
                self.range.text = "Range: " .. tower.range
                self.cooldown.text = "Cooldown time: " .. tower.cooldown
                self.upgrade.text = "Price: " .. tower.cost .. " Gold"
                self.sell.text = "Sell for: " .. tower.cost * .5 .. " Gold"
        end

end

function TowerInfo:changeOpacity(seconds)

        --print(1)

        if self.fade == "in" then

                --print("2")
        
                local limit = 220
        
                if self.group.opacity <= limit then
                
                        local new = self.group.opacity + 800 * seconds
                        
                        if new > limit then
                                self.group.opacity = limit
                        else
                                self.group.opacity = new
                                self.fade = nil
                        end
                
                end
        
        else
                local new = self.group.opacity - 800 * seconds
                
                if new > 0 then
                        self.group.opacity = new
                else
                        self.group.opacity = 0
                        self.fade = nil
                end
        
        end

end
