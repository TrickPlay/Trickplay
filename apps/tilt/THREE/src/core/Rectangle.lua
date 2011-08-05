THREE = THREE or {}

THREE.Rectangle = {_left = 0, _top = 0, _right = 0, _bottom = 0, _width = 0, _height = 0, _isEmpty = true}
THREE.Rectangle.types = THREE.Rectangle.types or {}
THREE.Rectangle.types[THREE.Rectangle] = true
setmetatable(THREE.Rectangle, THREE.Rectangle)
THREE.Rectangle.__index = THREE.Rectangle

THREE.Rectangle.__call = function(_, t)
	local a = {}
	setmetatable(a, THREE.Rectangle)
	return a
end

function THREE.Rectangle:resize()
	self._width = self._right - self._left
	self._height = self._bottom - self._top

end

function THREE.Rectangle:getX()
	return self._left
end

function THREE.Rectangle:getY()
	return self._top
end

function THREE.Rectangle:getWidth()
	return self._width
end

function THREE.Rectangle:getHeight()
	return self._height
end

function THREE.Rectangle:getLeft()
	return self._left
end

function THREE.Rectangle:getTop()
	return self._top
end

function THREE.Rectangle:getRight()
	return self._right
end

function THREE.Rectangle:getBottom()
	return self._bottom
end

function THREE.Rectangle:set(left,top,right,bottom)
	self._isEmpty = false
	self._left = left
	self._top = top
	self._right = right
	self._bottom = bottom

	self:resize()
end

function THREE.Rectangle:addPoint(x, y)
	if (self._isEmpty) then
		self._isEmpty = false;
		self._left, self._right, self._top, self._bottom = x, x, y, y
	else
		self._left = self._left < x and self._left or x
		self._top = self._top < y and self._top or y
		self._right = self._right > x and self._right or x
		self._bottom = self._bottom > y and self._bottom or y
	end

	self:resize()
end

function THREE.Rectangle:add3Points (x1, y1, x2, y2, x3, y3)
	if (not (x1 and y1 and x2 and y2 and x3 and y3)) then
		print("Invalid parameters passed to add3points")
		return
	end
	if (self._isEmpty) then
		self._isEmpty = false
		--[[
		self._left = x1 < x2 and (x1 < x3 and x1 or x3) or (x2 < x3 and x2 or x3)
		self._top = y1 < y2 and (y1 < y3 and y1 or y3) or (y2 < y3 and y2 or y3)
		self._right = x1 > x2 and (x1 > x3 and x1 or x3) or (x2 > x3 and x2 or x3)
		self._bottom = y1 > y2 and (y1 > y3 and y1 or y3) or (y2 > y3 and y2 or y3)]]
		self._left = math.min(x1,x2,x3)
		self._top = math.min(y1,y2,y3)
		self._right = math.max(x1,x2,x3)
		self._bottom = math.max(y1,y2,y3)
	else
		--[[
		self._left = x1 < x2 and ( x1 < x3 and ( x1 < self._left and x1 or self._left ) or
 					 ( x3 < self._left and x3 or self._left ) ) or
				         ( x2 < x3 and ( x2 < self._left and x2 or self._left ) or
 					 ( x3 < self._left and x3 or self._left ) )
		self._top = y1 < y2 and ( y1 < y3 and ( y1 < self._top and y1 or self._top ) or 
					( y3 < self._top and y3 or self._top ) ) or 
					( y2 < y3 and ( y2 < self._top and y2 or self._top ) or 
					( y3 < self._top and y3 or self._top ) )
		self._right = x1 > x2 and ( x1 > x3 and ( x1 > self._right and x1 or self._right ) or 
					  ( x3 > self._right and x3 or self._right ) ) or
 					  ( x2 > x3 and ( x2 > self._right and x2 or self._right ) or 
					  ( x3 > self._right and x3 or self._right ) );
		self._bottom = y1 > y2 and ( y1 > y3 and ( y1 > self._bottom and y1 or self._bottom ) or 
					   ( y3 > self._bottom and y3 or self._bottom ) ) or 
					   ( y2 > y3 and ( y2 > self._bottom and y2 or self._bottom ) or 
					   ( y3 > self._bottom and y3 or self._bottom ) ); ]]
		self._left = math.min(x1,x2,x3,self._left)
		self._top = math.min(y1,y2,y3,self._top)
		self._right = math.max(x1,x2,x3,self._right)
		self._bottom = math.max(y1,y2,y3,self._bottom)
	end

	self:resize()
end

function THREE.Rectangle:addRectangle (r)
	if ( self._isEmpty ) then

		self._isEmpty = false
		self._left = r.getLeft()
		self._top = r.getTop()
		self._right = r.getRight() 
		self._bottom = r.getBottom()

	else

		self._left = math.min(self._left, r:getLeft() )
		self._top = math.min(self._top, r:getTop() )
		self._right = math.max(self._right, r:getRight() )
		self._bottom = math.max(self._bottom, r:getBottom() )
	end

	self:resize()
end 

--inflates the rectangle by v. Deflates if a negative number is passed in. 
function THREE.Rectangle:inflate (v)
	
	self._left = self._left - v;
	self._top = self._top - v
	self._right = self._right + v
	self._bottom = self._bottom + v

	if (self._left > self._right) then
		self._left, self._right = self._right, self._left
	end
	if (self._top > self._bottom) then
		self._top, self._bottom = self._bottom, self._top
	end

	self:resize()
end

--reduces this rectangle to its intersection with the argument rectangle. If no intersection, empties the rectangle.
function THREE.Rectangle:minSelf (r)
	
	if (self:intersects (r)) then
		self._left = math.max( self._left, r:getLeft() )
		self._top = math.max( self._top, r:getTop() )
		self._right = math.min( self._right, r:getRight() )
		self._bottom = math.min( self._bottom, r:getBottom() )

		self:resize()
	else
		self:empty()
	end
end

function THREE.Rectangle:intersects (r)
	return math.min( self._right, r:getRight() ) - math.max( self._left, r:getLeft() ) >= 0 and
		        math.min( self._bottom, r:getBottom() ) - math.max( self._top, r:getTop() ) >= 0
end

function THREE.Rectangle:empty()
	self._isEmpty = true

	self._left = 0
	self._top = 0
	self._right = 0
	self._bottom = 0

	self:resize()
end

function THREE.Rectangle:isEmpty()
	return self._isEmpty
end

--[[debug
function THREE.Rectangle:print ()
	print(self:getLeft(), self:getRight(), self:getTop(), self:getBottom())
	print(self:getWidth(), self:getHeight(), self:isEmpty())
end

myRect = THREE.Rectangle{}

myRect:print()

myRect:addPoint(5, 7)

myRect:print()

myRect:addPoint(2, 10)

myRect:print()

myRect:empty()

myRect:print()

myRect:set(-1, -1, 1, 1)

myRect2 = THREE.Rectangle{}

print(myRect:intersects(myRect2), myRect2:intersects(myRect))

myRect2:set(2, 4, 7, 5)

myRect:print()
myRect2:print()

print(myRect:intersects(myRect2), myRect2:intersects(myRect))

myRect:minSelf(myRect2)

myRect:print()]]
