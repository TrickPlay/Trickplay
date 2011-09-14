--[[
Filename: Timeline1.lua
Author: Peter von dem Hagen
Date: January 20, 2011
Description:  
--]]


-- Test Set up --
local canvas = Canvas ( 500, 100 )

canvas:round_rectangle( 10, 10, 100, 100, 10 )
canvas:text_path ("DejaVu Sans 38px", "History repeating")
canvas:set_source_color( "FF6633" )
canvas:fill( true )
canvas:set_source_color( "00FF00" )
canvas:stroke()
test_group:add(canvas:Image() )


-- Tests --


function test_canvas_size ()
    assert_equal( canvas.size[1] , 500, "canvas_size failed" )
    assert_equal( canvas.size[2] , 100, "canvas_size failed" )
end

function test_canvas_current_point ()
    assert_equal( canvas.current_point[1] , 0, "canvas.current_point failed" )
    assert_equal( canvas.current_point[2] , 0, "canvas.current_point failed" )
end


-- Test Tear down --













