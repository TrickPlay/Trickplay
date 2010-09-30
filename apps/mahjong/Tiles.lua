local tiles = {
    Image{src = "assets/tiles/TileWoodLg.png", opacity = 0},
    Image{src = "assets/tiles/TilePlasticLg.png", opacity = 0}
}
for i,image in ipairs(tiles) do screen:add(image) end

Suits = {
    FIRST = 1,

    CIRCLE = 1,
    BAMBOO = 2,
    CHAR = 3,
    NUM = 3,
    WIND = 4,
    DRAGON = 5,
    FLOWER = 6,
    SEASON = 7,

    LAST = 7
}

Multiplier = {
    [Suits.CIRCLE] = 4,
    [Suits.BAMBOO] = 4,
    [Suits.CHAR] = 4,
    [Suits.WIND] = 4,
    [Suits.DRAGON] = 4,
    [Suits.FLOWER] = 1,
    [Suits.SEASON] = 1
}

local glyphs = {}
for i = Suits.FIRST, Suits.LAST do
    glyphs[i] = {}
end

-- Bamboo tiles
for i = 1,9 do
    glyphs[Suits.BAMBOO][i] = Image{src="assets/glyphs/tileB"..i..".png", opacity=0}
end
-- Circle tiles
for i = 1,9 do
    glyphs[Suits.CIRCLE][i] = Image{src="assets/glyphs/tileC"..i..".png", opacity=0}
end
-- Character/Number tiles
for i = 1,9 do
    glyphs[Suits.NUM][i] = Image{src="assets/glyphs/tileN"..i..".png", opacity=0}
end
-- Dragon tiles
for i = 1,3 do
    glyphs[Suits.DRAGON][i] = Image{src="assets/glyphs/tileD"..i..".png", opacity=0}
end
-- Flower tiles
for i = 1,4 do
    glyphs[Suits.FLOWER][i] = Image{src="assets/glyphs/tileF"..i..".png", opacity=0}
end
-- Season tiles
for i = 1,4 do
    glyphs[Suits.SEASON][i] = Image{src="assets/glyphs/tileS"..i..".png", opacity=0}
end
-- Wind tiles
for i = 1,4 do
    glyphs[Suits.WIND][i] = Image{src="assets/glyphs/tileW"..i..".png", opacity=0}
    i = i + 1
end

local tile_depth = Image{src = "assets/tiles/TileDepthLg.png", opacity = 0}
screen:add(tile_depth)

Tile = Class(function(tile, suit, number, ...)
    assert(type(suit) == "number")
    assert(type(number) == "number")
    if not glyphs[suit][number] then
        error("glyph["..suit.."]["..number.."] is not registered", 2)
    end
    
    tile.image = Clone{source = tiles[2]}
    if not glyphs[suit][number].parent then screen:add(glyphs[suit][number]) end
    tile.glyph = Clone{source = glyphs[suit][number]}
    tile.depth = Clone{source = tile_depth}

    tile.number = number
    tile.suit = suit

    tile.null = false

    tile.group = Group()
    tile.group:add(tile.image, tile.glyph, tile.depth)
    
end)

Tiles = Class(function(self, ...)

    local tiles = {}
    local index = 1
    for suit = Suits.FIRST, Suits.LAST do
        for number,glyph_type in ipairs(glyphs[suit]) do
            for multiple = 1,Multiplier[suit] do
                tiles[index] = Tile(suit, number)
                index = index + 1
            end
        end
    end

    local original_order = {}
    for i,v in ipairs(tiles) do
        original_order[i] = v
    end

    function self:get_tiles() return tiles end

    function self:shuffle()
        for i,tile in ipairs(tiles) do
            local index = math.random(#tiles)
            tiles[i], tiles[index] = tiles[index], tiles[i]
        end
    end

    function self:organize()
        for i,v in ipairs(original_order) do
            tiles[i] = v
        end
    end

end)
