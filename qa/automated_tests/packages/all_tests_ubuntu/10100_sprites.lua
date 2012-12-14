
test_description = "Display various sprites."
test_group = "smoke"
test_area = "sprites"
test_api = "sprite"


function generate_test_image ()

    local sheet = SpriteSheet { map = "packages/assets/test-sprites.json" }

    local g = Group
    {
        children = {
            Sprite {
                sheet = sheet,
                id = "logo.png",
                position = { 100, screen.h/6},
            },
            Sprite {
                sheet = sheet,
                id = "jack.jpg",
                position = { 500, screen.h/6},
            },
            Sprite {
                sheet = sheet,
                id = "alpha_channel1.png",
                position = { 1000, screen.h/6},
            },
        }
    }

    return g
end















