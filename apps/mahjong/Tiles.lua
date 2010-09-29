local tiles = {
    Image{src = "assets/tiles/TileWoodLg.png", opacity = 0},
    Image{src = "assets/tiles/TilePlasticLg.png", opacity = 0}
}
for i,image in ipairs(tiles) do screen:add(image) end

Tile = Class(function(tile, ...)
    
    tile.image = Clone{source = tiles[1]}
    tile.glyph = Image{
        src = "assets/glyphs/tileB"..math.random(9)..".png",
        scale = {.45,.45}
    }
    tile.group = Group()
    tile.group:add(tile.image, tile.glyph)
    
end)
