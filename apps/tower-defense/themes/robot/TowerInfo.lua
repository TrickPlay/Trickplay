TowerInfo = {}

function TowerInfo:new(args)

        local g = Group{x=1500, y=20}

	local object = {
                
		group = g
                --icon = 	AssetLoader:getImage(args.tower.prefix..args.tower.name,{x = g.x + 20, scale={.4, .4}} )
                
                level = Text{ x = g.x+100, y = g.y+20, text = "", font = "Sans 24px", color = "222222"  }
                damage = Text{ x = g.x+100, y = g.y+50, text = "", font = "Sans 24px", color = "222222"  }
                range = Text{ x = g.x+100, y = g.y+80, text = "", font = "Sans 24px", color = "222222"  }
                
                cooldown = Text{ x = g.x+200, y = g.y+20, text = "", font = "Sans 24px", color = "222222"  }
                upgrade = Text{ x = g.x+200, y = g.y+50, text = "", font = "Sans 24px", color = "222222"  }
                sell = Text{ x = g.x+200, y = g.y+80, text = "", font = "Sans 24px", color = "222222"  }
                
	}
        
        g:add(object.icon)
        g:add(object.level, object.damage, object.range, object.cooldown, object.upgrade, object.sell)
        screen:add(g)
	
   setmetatable(object, self)
   self.__index = self
   return object
end

function TowerInfo:update(tower)

        g:remove(self.icon)
        
        self.icon = AssetLoader:getImage(tower.prefix..tower.name,{x = self.group.x + 20, scale={.4, .4}} )
        
        g:add(self.icon)
        
        self.level.text = "Current Level: " .. tower.level
        self.damage.text = "Damage: " .. tower.damage
        self.range.text = "Range: " .. tower.range
        self.cooldown.text = "Cooldown time: " .. tower.cooldown
        self.upgrade.text = "Upgrade for: " .. tower.cost .. " Gold"
        self.sell.text = "Sell for: " .. tower.cost * .5 .. " Gold"

end
