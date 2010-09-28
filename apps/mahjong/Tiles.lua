local tiles = {
    Image{src = "assets/tiles/TileWoodLg.png"},
    Image{src = "assets/tiles/TilePlasticLg.png"},
}
for i,image in ipairs(tiles) do screen:add(image) end

Tile = Class(function()
    
    tile.image = Clone{source = tiles[1]}
    tile.group = Group()
    tile.group:add(tile.image)

end)
