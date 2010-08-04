Player = {}

function Player:new(args)

	local object = {
		name = args.name,
		gold = settings.gold or args.gold,
		lives = settings.lives or args.lives,
		color = args.color,
		towerInfo = TowerInfo:new{}
	}
	
   setmetatable(object, self)
   self.__index = self
   return object
end

function Player:render(seconds)

		local x
		local y
		
		if self == game.board.player then
			x = BoardMenu.x
			y = BoardMenu.y
			
		else
			x = BoardMenu.hl2.extra.x
			y = BoardMenu.hl2.extra.y
		end
		local current = game.board.squareGrid[ y ][ x ]

	if not self.circle or not self.circle.list[1][self.circle.x].extra.t then
	
		
		if current.hasTower then
			current.tower.rangeCircle.opacity = 25
			self.towerInfo.fade = "in"
			self.towerInfo:update( current.tower , self )
		else
			self.towerInfo.fade = "out"
			
		end
		
	else
		
		if self.circle.list[1][self.circle.x].extra.t then
						
			self.towerInfo.fade = "in"
			
			self.towerInfo:update( self.circle.list[1][self.circle.x].extra.t , self , true, GTP(x), GTP(y), 300 )
			
		else
			self.towerInfo.fade = "out"
		end
		
	end
	
	if self.towerInfo then
		
		if self.towerInfo.fade then
			
			self.towerInfo:changeOpacity(seconds)
			
		end
		
	end

end
