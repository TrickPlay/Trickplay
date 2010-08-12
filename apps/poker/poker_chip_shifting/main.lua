chip = Image{
    position = {-1000, -1000},
    src = "assets/blue_chip.png"
}
screen:add(chip)

function chips_on_table(number)
    local chipGroup = Group{position = {900, 500}}
    local clone = false
    for i = 1,number do
        clone = Clone{source = chip}
        clone.x = math.random(100)
        clone.y = math.random(100)
        chipGroup:add(clone)
    end

    return chipGroup
end

function chips_go_to(playerNumber)
end

chipGroup = chips_on_table(60)

screen:add(chipGroup)
screen:show()
