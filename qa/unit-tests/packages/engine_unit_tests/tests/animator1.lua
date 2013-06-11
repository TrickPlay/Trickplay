--[[
Filename: animator1.lua
Author: Peter von dem Hagen
Date: October 13, 2011
Description:  Create an animator and test verify its setters.
--]]


-- Test Set up --
local timeline_completed_called = false

local rect1 = Rectangle {
        size = {50, 50},
        position = { 300, 150, 0},
        color = "002EB8"
        }

local rect2 = Rectangle {
        size = {100, 100},
        position = { 700, 150, 0},
        border_width = 10,
        border_color = "red",
        color = "44AA44"
        }

local rect3 = Rectangle {
        size = {100, 100},
        position = { 800, 150, 0},
        color = "AAAAAA"
        }
test_group:add (rect1, rect2, rect3)


--Animator
local ani0 = Animator
{
        duration = 1000,
        properties =
        {
            {
            source = rect1,
            name = "x",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 900}
                    }
            },
            {
            source = rect1,
            name = "y",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 650}
                    }
            },
            {
            source = rect1,
            name = "z",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 10}
                    }
            },
            {
            source = rect2,
            name = "depth",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 10}
                    }
            },
            {
            source = rect2,
            name = "border_color",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", "green"}
                    }
            },
            {
            source = rect2,
            name = "border_width",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 20}
                    }
            },
            {
            source = rect1,
            name = "width",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 50}
                    }
            },
            {
            source = rect1,
            name = "height",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 50}
                    }
            },
            {
            source = rect2,
            name = "w",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 200}
                    }
            },
            {
            source = rect2,
            name = "h",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 200}
                    }
            },
            {
            source = rect3,
            name = "size",
            ease_in = true,
            keys = {
                {0.9, "LINEAR", { 200, 200}}
                    }
            },
            {
            source = rect3,
            name = "scale",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", { 2.0, 0.5 }}
                    }
            },
            {
            source = rect1,
            name = "x_rotation",
            ease_in = true,
            keys = {
                {0.4, "LINEAR", 90}
                    }
            },
            {
            source = rect1,
            name = "y_rotation",
            ease_in = true,
            keys = {
                {0.4, "LINEAR", 90}
                    }
            },
            {
            source = rect1,
            name = "z_rotation",
            ease_in = true,
            keys = {
                {0.4, "LINEAR", -45}
                    }
            },
            {
            source = rect1,
            name = "opacity",
            ease_in = true,
            keys = {
                {0.1, "LINEAR", 0},
                {0.2, "LINEAR", 0},
                {0.5, "LINEAR", 255},
                {0.9, "LINEAR", 50},
                    }
            },
            {
            source = rect3,
            name = "color",
            ease_in = true,
            keys = {
                {0.2, "LINEAR", { 100, 20, 190, 255}}
                    }
            },
        }

}

ani0:start()

function ani0.timeline.on_completed()
    animator_timeline_completed_called = true
end



-- Tests --

function test_animator_duration ()
    assert_equal( ani0.timeline.duration , 1000 , "ani0.timeline.duration failed" )
end

function test_animator_end_state ()
    assert_equal( rect1.position[1], 900, "rect1.position[1] returned  ".. rect1.position[1].." Expected 900")
    assert_equal( rect1.position[2], 650, "rect1.position[2] returned  "..rect1.position[1].." Expected 650")
    assert_equal( rect1.z, 10, "rect1.z returned  ".. rect1.z.." Expected 10")
    assert_equal( rect1.opacity, 50,  "rect1.opacity returned  ".. rect1.opacity.." Expected 50")
    assert_equal( rect2.depth, 10,  "rect2.depth returned  ".. rect1.depth.." Expected 10")
    assert_equal( rect2.border_width, 20, "rect2.border_width returned ".. rect2.border_width.." Expected 20")
    assert_equal( rect3.size[1], 200,  "rect3.size[1] returned  ".. rect1.size[1].." Expected 200")
    assert_equal( rect3.size[2], 200,"rect3.size[2] returned  "..rect1.size[2].." Expected 200")
    assert_equal( rect2.w, 200, "rect2.w returned  ".. rect2.w.." Expected 200")
    assert_equal( rect2.h, 200, "rect2.h returned  ".. rect2.h.." Expected 200")
    assert_equal( rect1.width, 50, "rect1.width returned  ".. rect1.width.." Expected 50")
    assert_equal( rect1.height, 50, "rect1.height returned  ".. rect1.height.." Expected 50")
    assert_equal( rect3.scale[1], 2, "rect3.scale[1] returned  ".. rect1.scale[1].." Expected 2")
    assert_equal( rect3.scale[2], 0.5, "rect3.scale[2] returned  ".. rect1.scale[2].." Expected 0.5")
    assert_equal( rect1.z_rotation[1], -45, "rect1.z_rotation[1] returned  ".. rect1.z_rotation[1].." Expected -45")
    assert_equal( rect1.y_rotation[1], 90,  "rect1.y_rotation[1] returned  ".. rect1.y_rotation[1].." Expected 90")
    assert_equal( rect1.x_rotation[1], 90,  "rect1.x_rotation[1] returned  ".. rect1.x_rotation[1].." Expected 90")
    assert_equal( rect3.color[1], 100, "rect3.color[1] returned  ".. rect3.color[1].." Expected 100")
    assert_equal( rect3.color[2], 20,  "rect3.color[2] returned  ".. rect3.color[1].." Expected 20")
    assert_equal( rect3.color[3], 190, "rect3.color[3] returned  ".. rect3.color[1].." Expected 190")
    assert_equal( rect3.color[4], 255, "rect3.color[4] returned "..rect3.color[1].." Expected 255")
        rect1 = nil
end

function test_animator_timeline_completed ()
    assert_true ( animator_timeline_completed_called, "ani0.timeline.completed failed" )
end



-- Test Tear down --













