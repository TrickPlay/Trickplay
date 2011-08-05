THREE = THREE or {}

THREE.Color = {r = 0, g = 0, b = 0, hex = 0}
THREE.Color.types = THREE.Color.types or {}
THREE.Color.types[THREE.Color] = true
setmetatable(THREE.Color, THREE.Color)
THREE.Color.__index = THREE.Color

THREE.Color.__call = function(_, hex)
	local a = {}
	setmetatable(a, THREE.Color)
	a:setHex(hex)
	return a
end

function THREE.Color:copy (color)
	self.r = color.r
	self.g = color.g
	self.b = color.b
	self.hex = color.hex
end

function THREE.Color:setHex (hex)
    --if type(hex) ~= "number" then error("this is not hex",2) end
	self.hex = math.floor(hex or 0xffffff)
	self:updateRGB()
end

function THREE.Color:setRGB (r, g, b) 
	self.r = r
	self.g = g
	self.b = b
	self:updateHex()
end

function THREE.Color:setHSV (h, s, v)
	-- based on MochiKit implementation by Bob Ippolito
	-- h,s,v ranges are < 0.0 - 1.0 >

	--r, g, b, i, f, p, q, t

	if ( v == 0.0 ) then

		r,g,b = 0,0,0

	else

		local i = math.floor( h * 6 )
		local f = ( h * 6 ) - i
		local p = v * ( 1 - s )
		local q = v * ( 1 - ( s * f ) )
		local t = v * ( 1 - ( s * ( 1 - f ) ) )
		
		if (i == 1) then
			 r, g, b = q, v, p
		elseif (i == 2) then
			 r, g, b = p, v, t			
		elseif (i == 3) then
			 r, g, b = p, q, v
		elseif (i == 4) then
			 r, g, b = t, p, v		
		elseif (i == 5) then
			 r, g, b = v, p, q		
		elseif (i == 6 or i == 0) then
			 r, g, b = v, t, p
		end
	end

	self:setRGB( r, g, b )
end

function THREE.Color:updateHex ()
	self.hex = math.floor(self.r * 255) * 65536 + math.floor(self.g * 255) * 256 + math.floor(self.b * 255)
end

function THREE.Color:updateRGB ()
--[[
	hexString = tonumber(self.hex, 16).."";
	red = String.Left(sHexString,2)
	green = String.Mid(sHexString,3,2)
	blue = String.Right(sHexString,2)
	self.r = tonumber(red, 16)
	self.g = tonumber(green, 16)
	self.b = tonumber(blue, 16)
]]
	tmp = self.hex
	tmp,self.b = math.floor(tmp/256), math.mod(tmp, 256) / 255
	tmp,self.g = math.floor(tmp/256), math.mod(tmp, 256) / 255
	self.r = tmp / 255
end

function THREE.Color:clone ()
	a = THREE.Color(self.hex)
	return a
end

--[[debug
function THREE.Color:print ()
	print(self.r, self.g, self.b, self.hex)
end

myColor = THREE.Color{hex = 0xfd072f}

myColor:print()

myColor:setRGB(0.2,0.7,0.338)

myColor:print()

secondColor = myColor:clone()

myColor:setHex(myColor.hex - 256)

myColor:print()

secondColor:print()]]

