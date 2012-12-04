	-- Show the blank screen
	screen:show()

	-- Define the form
    sampleForm = {
	    -- Define a standard text field where the user enters his name
    	{ id          = "01",
    	  caption     = "Name:",
    	  placeholder = "Enter your user name",
        },

    	-- Define a password field; use an asterisk as the password char
    	{ id            = "02",
    	  caption       = "Password:",
    	  type          = "password",
    	  password_char = "*",
    	  placeholder   = "Enter a password",
        },

    	-- Define a list field, including possible values
    	{ id      = "03",
    	  caption = "Access Type:",
    	  type    = "list",
    	  choices = {
    	  	  { "01", "Global access" },
    	  	  { "02", "Local access" },
    	  	  { "03", "Temporary access" },
    	  	  { "04", "Private access" },
    	  	  { "05", "VIP access" },
    	  },
    	  value   = "05"  -- Make "VIP access" the starting value
    	},
    }
	keyboard:show( sampleForm )

	-- Define an on_field_changed event handler
	function handleOnFieldChanged( keybrd, id, value )
		-- Output a message to the TrickPlay Console
		print( "Field ID:", id, ", New Value:", value )
	end

	-- Register handler with keyboard variable
	changeHandler = keyboard:add_onfieldchanged_listener( handleOnFieldChanged )

	-- Define an on_cancel event handler
	function handleOnCancel( keybrd )
		print( "User cancelled the form" )
	end

	-- Register handler with keyboard variable
	cancelHandler = keyboard:add_oncancel_listener( hookOnCancel )

	-- Define an on_submit event handler
	function handleOnSubmit( keybrd, results )
		-- Print the final settings of each field
		print( "User accepted the form" )
		for id, setting in pairs( results ) do
			print( "Field ID:", id, ", Setting:", setting )
		end
	end

	-- Register handler with keyboard variable
	submitHandler = keyboard:add_onsubmit_listener( hookOnSubmit )
