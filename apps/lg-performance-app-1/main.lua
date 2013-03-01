
screen:show()

--dofile("delete_test")
make_grid = dofile('make_grid')
--[=[]]
-------------------------------------------------------------
local items = {}
for i=1,4 do
    items[i] = {}
    for j=1,10 do
        items[i][j] = "Icon "..i.." "..j
    end
end
grid = make_grid(items,100,100,80,80)
grid:make_icons_reactive()
grid.x = screen_w/2
grid.y = 400
screen:add(grid)

-------------------------------------------------------------
items = {}
for i=1,4 do
    items[i] = {}
    for j=1,9 do
        items[i][j] = "Icon "..i.." "..j
    end
end
modal_menu = make_grid(items,100,100,80,80)

modal_menu.x = screen_w/2
modal_menu.y = 100

r = Rectangle{w=1700,h=800,x=-50,y=-50,color = "red"}

modal_menu:add(r)
r:lower_to_bottom()

modal_menu.opacity = 0

function modal_menu:focus()
    modal_menu:animate{
        duration = 250,
        opacity = 255,
    }
    modal_menu:animate{
        duration = 300,
        mode = "EASE_OUT_BOUNCE",
        z = 0,
    }
end
function modal_menu:unfocus()
    modal_menu:animate{
        duration = 250,
        opacity = 0,
        z = -100,
    }
end

screen:add(modal_menu)
modal_menu.z = -100

controllers:start_pointer()
--]=]
dofile("cube_test")
