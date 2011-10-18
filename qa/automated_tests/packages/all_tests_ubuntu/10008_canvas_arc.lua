
test_description = "Create a variety of arcs with different, alpha fill, radius size and line_width."
test_group = "acceptance"
test_area = "canvas"
test_api = "arc"


function generate_test_image ()

	local test_image = Canvas (screen.w, screen.h)
        
        for i=1, 11 do
            test_image.line_width = ((i+1)/2) * i
            test_image:save()
            test_image:arc(i * i * 14 + 100 , i * 79 + 100, i * 12, 0, 396 - i * 36)
            test_image:set_source_color((i-2)..(i-2)..(i-2)..(i-2)..(i-2)..(i-2)..(i-2)..(i-2))
            test_image:fill(true)
            test_image:restore()
            test_image:stroke()
        end
	

	return test_image:Image ()
end















