
test_description = "Render a set of curves with different line_widths and alphas."
test_group = "acceptance"
test_area = "canvas"
test_api = "curve_to"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
        for i = 1, 11 do
            local x = i + 25.6
            local y = i + 128
            local x1 = i + 102.4
            local x2 = i +  153.6
            local x3 = i +  230.4
            local y1 = i +  230.4
            local y2 = i +  25.6
            local y3 = i + 128
    
 
          --  test_image:scale (3, 3)
            test_image:move_to (x * i/2, y * i/2)
            test_image:set_source_color((i-2)..(i-2)..(i-2)..(i-2)..(i-2)..(i-2)..(i-2)..(i-2))
            test_image:curve_to (x1 * i, y1 * i, x2 * i, y2 * i, x3 * i, y3 * i)
            test_image.line_width = i * 2
            
            test_image:stroke()
        end

	return test_image:Image ()
end















