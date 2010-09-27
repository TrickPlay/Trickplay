TowerInfo = {}

function TowerInfo:new(args)

        local g = Group{x=1300, y=20,z = 10, opacity=0}
					 

	local object = {
                
                x = g.x,
                y = g.y,
		group = g,
                background = AssetLoader:getImage("smallWindow", {scale={1.20, 1.25} } ),
                --icon = 	AssetLoader:getImage(args.tower.prefix..args.tower.name,{x = g.x + 20, scale={.4, .4}} )
                rangeCircle = Canvas{color="00FF00", x=-1300, y=-20, width=1920, height=1080, z = 0, opacity = 25},
                level = Text{ x = 130, y = 10, text = "", font = "Sans 22px", color = "000000"  },
                damage = Text{ x = 130, y = 40, text = "", font = "Sans 22px", color = "000000"  },
                range = Text{ x = 130, y = 70, text = "", font = "Sans 22px", color = "000000"  },
                
                cooldown = Text{ x = 330, y = 10, text = "", font = "Sans 22px", color = "000000"  },
                upgrade = Text{ x = 330, y = 40, text = "", font = "Sans 22px", color = "000000"  },
                sell = Text{ x = 330, y = 70, text = "", font = "Sans 22px", color = "000000"  },

	}
        
        g:add(object.background, object.icon, object.rangeCircle)
        g:add(object.level, object.damage, object.range, object.cooldown, object.upgrade, object.sell)
        
        --object.group:add( Text { font = "Sans 30px", text = "12341243", x = 200, y = 20, z =g.z, color = "FFFFFF"} )
        
        print("Added text")
        
        screen:add(g)
	
   setmetatable(object, self)
   self.__index = self
   return object
end

function TowerInfo:update(tower, player, isNew, x, y, range)

        if game.board.player2 and player == game.board.player2 then self.group.x = 40 self.group.y = 20 end

        if not isNew then
        
                self.group.x = self.x
                self.group.y = self.y
                
                self.group:remove(self.icon)
--					 self.group:remove(self.rangeCircle)                
                local name = tower.prefix..tower.name
                
                if tower.level > 0 then name = name..tower.level end
                
                self.icon = AssetLoader:getImage(name,{x=-15, y=-15, scale={.6, .6}} )
--[[					 self.rangeCircle = Canvas{color="00FF00", x=-1300, y=-20, width=1920, height=1080, z = 10, opacity = 65}
			
                self.rangeCircle:begin_painting()
					 self.rangeCircle:set_source_color("00FF00")
					 self.rangeCircle:arc(tower.x,tower.y,tower.range,0,360)
		   		 self.rangeCircle:fill() -- or c:stroke()
   				 self.rangeCircle:finish_painting()]]
                self.group:add(self.icon)
					                
                self.level.text = "Current Level: " .. tower.level + 1
                self.damage.text = "Damage: " .. tower.damage
                self.range.text = "Range: " .. tower.range
                self.cooldown.text = "Cooldown time: " .. tower.cooldown
                if tower.level < tower.levels then self.upgrade.text = "Upgrade for: " .. tower.upgradeCost .. " Gold" else self.upgrade.text = "" end
                self.sell.text = "Sell for: " .. tower.cost * .5 .. " Gold"
                
        else
        
                --self.group.y = player.circle.container.h * player.circle.container.scale[2] - 30
                --self.group.x = self.x - 100
                
                self.group.x = 1920 - player.circle.container.w*2 * player.circle.container.scale[1]
                
                --print("rendering towerinfo")
                
                self.group:remove(self.icon)
                --self:drawRangeCircle(x,y,range)
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
--[[
function TowerInfo:drawRangeCircle(x,y,range)
		self.rangeCircle:clear_surface()
		self.rangeCircle:begin_painting()
		self.rangeCircle:set_source_color("00FF00")
		self.rangeCircle:arc(x+SP/2,y+SP/2,range,0,360)
		self.rangeCircle:fill() -- or c:stroke()
		self.rangeCircle:finish_painting()
end]]

function TowerInfo:changeOpacity(seconds)

        local limit = 220

        if self.fade == "in" and self.group.opacity ~= limit then
                
                if self.group.opacity <= limit then
	                        
                        local new = self.group.opacity + 800 * seconds
                        if new > limit then
                                self.group.opacity = limit
                                --print("Fade should now be nil")
                                self.fade = nil
                        else
                                self.group.opacity = new                                
                        end
                
                end
        
        elseif self.fade == "out" and self.group.opacity ~= 0 then
                
                local new = self.group.opacity - 800 * seconds
                
                if new > 0 then
                        self.group.opacity = new
                else
                        self.group.opacity = 0
                        --print("Fade should now be nil")
                        self.fade = nil
                end
        
        else
        
                self.fade = nil
        
        end

end
