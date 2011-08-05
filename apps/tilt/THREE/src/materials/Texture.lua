THREE = THREE or {}

THREE.Texture={}
THREE.Texture.types = THREE.Texture.types or {}
THREE.Texture.types[THREE.Texture] = true
setmetatable(THREE.Texture, THREE.Texture)
THREE.Texture.__index=THREE.Texture

THREE.Texture.__call=function(_, image, mapping, wrapS, wrapT, magFilter, minFilter)
	local t = {}
	setmetatable(t, THREE.Texture)
	t.image = image
	t.mapping = mapping or THREE.UVMapping()

	t.wrapS = wrapS or THREE.ClampToEdgeWrapping
	t.wrapT = wrapT or THREE.ClampToEdgeWrapping
	t.magFilter = magFilter or THREE.LinearFilter
	t.minFilter = minFilter or THREE.LinearMipMapLinearFilter

	t.offset = THREE.Vector2(0, 0)
	t.repeats = THREE.Vector2(1, 1)

	t.needsUpdate = false
	return t
end

function THREE.Texture:clone()
	return THREE.Texture(self.image, self.mapping, self.wrapS, self.wrapT, self.magFilter, self.minFilter)
end

THREE.MultiplyOperation = 0
THREE.MixOperation = 1

-- Wrapping modes

THREE.RepeatWrapping = 0
THREE.ClampToEdgeWrapping = 1
THREE.MirroredRepeatWrapping = 2

-- Filters

THREE.NearestFilter = 3
THREE.NearestMipMapNearestFilter = 4
THREE.NearestMipMapLinearFilter = 5
THREE.LinearFilter = 6
THREE.LinearMipMapNearestFilter = 7
THREE.LinearMipMapLinearFilter = 8

-- Types

THREE.ByteType = 9
THREE.UnsignedByteType = 10
THREE.ShortType = 11
THREE.UnsignedShortType = 12
THREE.IntType = 13
THREE.UnsignedIntType = 14
THREE.FloatType = 15

-- Formats

THREE.AlphaFormat = 16
THREE.RGBFormat = 17
THREE.RGBAFormat = 18
THREE.LuminanceFormat = 19
THREE.LuminanceAlphaFormat = 20
