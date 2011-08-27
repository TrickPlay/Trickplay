
test_description = "Show and hide the Virtual Remote"
test_steps = "View the device."
test_verify = "Verify the remote control disappears for 5 seconds and then appears."
test_group = "acceptance"
test_area = "virtual_remote"
test_api = "hide/show_virtual_remote"


function generate_test_image (controller, factory)
	  print ("virtual_remote =",controller.has_virtual_remote)
	controller:hide_virtual_remote()

--	if controller.has_virtual_remote == true then
	local total = 0
 	function idle.on_idle( idle , seconds )
	      total = total + seconds
	      if total >= 5 then
			idle.on_idle = nil
			controller:show_virtual_remote()
	 		test_verify_txt.text = "virtual remote removed"
	      end
    end
--	end

	return nil

end

