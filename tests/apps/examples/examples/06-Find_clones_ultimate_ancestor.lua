		function get_ultimate_ancestor( src )
			-- Is this the top of the Clone chain?
			-- If object does not have a source property (only Clone objects have a "natural" source property)...
			if (src.source == nil) 
			   or
			   -- ...or object has a source property, but it's self-created, as in our Text example below
			   ((src.source ~= nil) and (src.extra.source ~= nil)) then
				-- Yes, this is the ultimate ancestor
				return src
			end
			
			-- Call function recursively, passing source property of Clone
			return( get_ultimate_ancestor( src.source ) )
		end
		
		-- ***Code to exercise the function***
		-- Create a Text object and several Clones in a "Clone chain"
		t = Text{ name="Shezzbotz", text="Some text", font="sans 60px", color="ff0000" }
		c1 = Clone{ name="Clone #1", source=t }
		c2 = Clone{ name="Clone #2", source=c1 }
		c3 = Clone{ name="Clone #3", source=c2 }
		c4 = Clone{ name="Clone #4", source=c3 }
		
		-- To make things ultra-nasty, we'll add a source property to the Text object and even set it to one of the clones
		t.source = c2
		
		-- Display name of Clone #4's ultimate ancestor
		print( "Name of Clone #4's ultimate ancestor: ", get_ultimate_ancestor( c4.source ).name )

