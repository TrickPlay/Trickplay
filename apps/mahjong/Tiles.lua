local tiles = {
    Image{src = "assets/tiles/TileMarbleLg.png", opacity = 0, name = "Marble"},
    Image{src = "assets/tiles/TileWoodLg.png", opacity = 0, name = "Wood"},
    Image{src = "assets/tiles/TilePlasticLg.png", opacity = 0, name = "Porcelain"},
}

TILE_IMAGES = tiles

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
local tile_highlight_yellow = Image{
    src="assets/tiles/TileHighlightYellowLg.png",
    opacity = 0
}
local tile_highlight_red = Image{
    src="assets/tiles/TileHighlightRedLg.png",
    opacity = 0
}
local tile_highlight_green = Image{
    src="assets/tiles/TileHighlightGreenLg.png",
    opacity = 0
}
tile_shadow = Image{
    src = "assets/tiles/shadow.png",
--    opacity = 0
}
local sparkle = Image{
    src="assets/tiles/Sparkle.png",
    opacity = 0
}
screen:add(
    tile_depth, tile_highlight_yellow, tile_highlight_green, tile_highlight_red,
    sparkle, tile_shadow
)

Tile = Class(function(tile, suit, number, ...)
    assert(type(suit) == "number")
    assert(type(number) == "number")
    if not glyphs[suit][number] then
        error("glyph["..suit.."]["..number.."] is not registered", 2)
    end
    
    tile.images = {
        Clone{source = tiles[1], opacity = 0},
        Clone{source = tiles[2]},
        Clone{source = tiles[3], opacity = 0}
    }

    tile.shadow = Clone{source = tile_shadow, position={8,10}, opacity = 178}

    if not glyphs[suit][number].parent then screen:add(glyphs[suit][number]) end
    tile.glyph = Clone{source = glyphs[suit][number]}
    tile.focus = {
        green = Clone{source = tile_highlight_green, x = -21, y = -27, opacity = 0},
        red = Clone{source = tile_highlight_red, x = -21, y = -27, opacity = 0},
        yellow = Clone{source = tile_highlight_yellow, x = -21, y = -27, opacity = 0}
    }
    tile.depth = Clone{source = tile_depth}
    tile.sparkle = Clone{source = sparkle, opacity = 0}
    tile.sparkle.clip = {0, 0, tile.sparkle.width/5, tile.sparkle.height}

    tile.number = number
    tile.suit = suit

    -- determines if the tile is eliminated from the current game
    tile.null = false
    -- determines if the tile is set in the current game
    tile.set = false
    -- the position of the tile in the game grid
    tile.position = nil

    tile.group = Group{}--clip = {0,0,tile.images[1].width,tile.images[1].height}}
    tile.group:add(tile.shadow)
    tile.group:add(unpack(tile.images))
    tile.group:add(
        tile.depth, tile.focus.green, tile.focus.yellow,
        tile.focus.red, tile.glyph, tile.sparkle, shadow
    )

    TILE_HEIGHT = tile.images[1].height
    TILE_WIDTH = tile.images[1].width

    function tile:is_a_match(match)
        if tile == match then return false end

        if tile.suit == Suits.FLOWER or tile.suit == Suits.SEASON then
            if match.suit == tile.suit then return true end
        else
            if match.suit == tile.suit and match.number == tile.number then
                return true
            end
        end

        return false
    end

    function tile:change_image(number)
        if number < 1 or number > #tile.images then
            error("tile image number must be between 1 and "..#tile.images, 2)
        end

        for i,image in pairs(tile.images) do
            if i == number then image.opacity = 255
            else image.opacity = 0
            end
        end
    end

    function tile:reset()
        tile:focus_reset()
        tile.null = false
        tile.set = false
        tile.position = nil
        tile.group.opacity = 255
        if tile.group.parent then tile.group:unparent() end
    end

    function tile:focus_reset()
        self.focus.red.opacity = 0
        self.focus.yellow.opacity = 0
        self.focus.green.opacity = 0
    end

    function tile:set_green()
        tile.focus.green.opacity = 220
    end
    
end)

Tiles = Class(function(self, ...)

    local tiles = {}
    local matches = {}
    local index = 1
    for suit = Suits.FIRST, Suits.LAST do
        for number,glyph_type in ipairs(glyphs[suit]) do
            for multiple = 1,Multiplier[suit] do
                tiles[index] = Tile(suit, number)
                if not matches[suit] then matches[suit] = {} end
                if not matches[suit][number] then matches[suit][number] = {} end
                table.insert(matches[suit][number], tiles[index])
                index = index + 1
            end
        end
    end

    local original_order = {}
    for i,v in ipairs(tiles) do
        original_order[i] = v
    end

    local current_tile_image = 2

    function self:get_tiles() return tiles end
    function self:get_matches() return matches end
    function self:get_current_tile_image() return current_tile_image end

    function self:shuffle(number)
        if not number then number = 144 end
        assert(number <= #tiles)

        local index = nil
        local tile = nil
        for i = 1,number do
            tile = tiles[i]
            index = math.random(number)
            tiles[i], tiles[index] = tiles[index], tiles[i]
        end
    end

    function self:organize()
        for i,v in ipairs(original_order) do
            tiles[i] = v
        end
    end

    function self:reset()
        for i,v in ipairs(tiles) do
            v:reset()
        end
    end

    function self:change_images(number)
        if number < 1 or number > #TILE_IMAGES then
            error("tile image number must be between 1 and "..#tile.images, 2)
        end

        current_tile_image = number

        for i,a_tile in ipairs(tiles) do
            a_tile:change_image(number)
        end
    end

    add_to_key_handler(keys.i, function() self:change_images(3) end)

end)
