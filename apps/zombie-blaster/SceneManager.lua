-- The different types of scenes
Scenes = {
    HOUSE_1 = 1,
    HOUSE_2 = 2,
    HOUSE_3 = 3,
    FOREST_1 = 4,
    FOREST_2 = 5
}
Total_Scenes = 0
for _,__ in pairs(Scenes) do
    Total_Scenes = Total_Scenes + 1
end

-- The different backgrounds associated with the scenes
 Backgrounds = {
    [Scenes.HOUSE_1] = Image{
        src = "assets/background/background-1.png",
        name = "house_1",
        opacity = 0
    },
    [Scenes.HOUSE_2] = Image{
        src = "assets/background/background-2.png",
        name = "house_1",
        opacity = 0
    },
    [Scenes.HOUSE_3] = Image{
        src = "assets/background/background-3.png",
        name = "house_1",
        opacity = 0
    },
    [Scenes.FOREST_1] = Image{
        src = "assets/background/background-4.png",
        name = "house_1",
        opacity = 0
    },
    [Scenes.FOREST_2] = Image{
        src = "assets/background/background-5.png",
        name = "house_1",
        opacity = 0
    },
}
for _,bg in ipairs(Backgrounds) do
    screen:add(bg)
    bg:hide()
end
BG_WIDTH = Backgrounds[Scenes.HOUSE_1].w*2
BG_HEIGHT = Backgrounds[Scenes.HOUSE_1].h*2

SceneManager = Class(function(scene, camera, the_objects, ...)

    local collidable_objects = the_objects

    local current_scene = Scenes.HOUSE_1
    local function next_scene(bg_x, bg_y, no_objects)
        assert(bg_x)
        assert(bg_y)

        local new_scene = {}
        new_scene.bg = Clone{
            source = Backgrounds[current_scene],
            name = Backgrounds[current_scene].name,
            scale = {2, 2},
            x = bg_x,
            y = bg_y
        }

        if not no_objects then
            new_scene.objs = collidable_objects:get_objects(current_scene)
            for i,obj in ipairs(new_scene.objs) do
                for j,image in ipairs(obj.images) do
                    image.x = bg_x + image.x
                end
            end
        else
            new_scene.objs = {}
        end
        
        current_scene = current_scene + 1
        if current_scene > Total_Scenes then current_scene = 1 end
        return new_scene
    end
  
    -- scenes contain scenes[n].bg for the background and scenes[n].objs for the
    -- collidable objects
    local scenes = {}
    -- fist few scenes contain nothing
    for i = 1,3 do
        scenes[i] = next_scene(BG_WIDTH*(i-3), screen.h-BG_HEIGHT, true)
    end
    for i = 4,5 do
        scenes[i] = next_scene(BG_WIDTH*(i-3), screen.h-BG_HEIGHT)
    end

    function scene:slide_backgrounds()
        if scenes[1].bg.x < BG_WIDTH*(-2) then
            local a_scene = table.remove(scenes, 1)
            local bg = a_scene.bg
            camera:remove(bg)
            screen:remove(bg)
            for i,obj in ipairs(a_scene.objs) do
                obj:delete()
            end
            a_scene = next_scene(BG_WIDTH + scenes[#scenes].bg.x, bg.y)
            table.insert(scenes, a_scene)
            screen:add(a_scene.bg)
            camera:add(a_scene.bg)
            a_scene.bg:lower_to_bottom()

            router:notify()
            scenes[1].bg:hide()
            scenes[3].bg:show()
            scenes[5].bg:hide()
        end
    end

    function scene:start()
        for _,a_scene in ipairs(scenes) do
            screen:add(a_scene.bg)
            camera:add(a_scene.bg)
            a_scene.bg:lower_to_bottom()
        end

        gameloop:add_idle(scene.slide_backgrounds)
    end

    function scene:stop()
        gameloop:remove_idle(scene.slide_backgrounds)
        scene:clear()
    end

    function scene:clear()
        for _,a_scene in ipairs(scenes) do
            camera:remove(a_scene.bg)
            screen:remove(a_scene.bg)
            a_scene.bg = nil
            for i,obj in ipairs(a_scene.objs) do
                obj:delete()
            end
        end
    end

    function scene:reset(the_objects)
        assert(the_objects)
        collidable_objects = the_objects

        current_scene = 1

        scene:stop()
        -- fist few scenes contain nothing
        for i = 1,3 do
            scenes[i] = next_scene(BG_WIDTH*(i-3), screen.h-BG_HEIGHT, true)
        end
        for i = 4,5 do
            scenes[i] = next_scene(BG_WIDTH*(i-3), screen.h-BG_HEIGHT)
        end
    end

end)
