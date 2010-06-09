	credits = {
		{
			 { { "Co-Producer" } },
			 { { "BRUCE DUNN" } },
		},
		{
			 { { "Associate Producer" } },
			 { { "CHRISTINA JOKANOVICH" } },
		},
		{
			 { { "Executive Story Editor" } },
			 { { "CHRIS OFFUTT" } },
		},
		{
			 { { "Guest Starring" } },
			 { { "Pam" }, { "KRISTIN BAUER" } },
			 { { "Longshadow" }, { "RAOUL TRUJILLO" } },
		},
		{
			 { { "Maxine Foretnberry" }, { "DALE RAOUL" } },
			 { { "Mike Spencer" }, { "JOHN BILLINGSLEY" } },
		},
		{
			 { { "Co-Starring" } },
			 { { "Dr. Offutt" }, { "SCOTT ALAN SMITH" } },
			 { { "State Trooper" }, { "DAVID PEASE" } },
			 { { "Faye Lebvre" }, { "MELANIE" } },
			 { { "" }, { " MCQUEEN" } },
			 { { "Neil Jones" }, { "KEVIN MCHALE" } },
		},
		{
			 { { "Young Tara" }, { "AVION BAKER" } },
			 { { "Young Jason" }, { "LABON K. HESTER" } },
			 { { "Sheriff's Deputy" }, { "JOHN REZIG" } },
			 { { "Fangbanger" }, { "JACK HARDING" } },
			 { { "Taryn" }, { "KATELIN CHESNA" } },
			 { { "" }, { " HENKE" } },
		},
		{
			 { { "Woman in Booth" }, { "SUSAN MERSON" } },
			 { { "Undercover Cop" }, { "JEFFREY DAVIS" } },
			 { { "Woman in Bar" }, { "JEANINE ANDERSON" } },
			 { { "Man in Bar" }, { "STEPHEN JARED" } },
			 { { "Man in Bar" }, { "GARY KRAUS" } },
		},
		{
			 { { "Man in Bar" }, { "JONATHAN WALKER" } },
			 { { "" }, { " SPENCER" } },
			 { { "Woman in Bar" }, { "PATTIE TIERCE" } },
			 { { "Woman in Bar" }, { "JUDI WALSTRUM" } },
			 { { "Vampire Dancer" }, { "CHERYL MCLISH" } },
			 { { "Vampire Dancer" }, { "JULL WEBER" } },
		},
		{
			 { { "Stunt Coordinator" } },
			 { { "BEN SCOTT" } },
			 { { "" } },
			 { { "Stunts" } },
			 { { "JEFF DANOFF" } },
			 { { "JAYSON W. DUMENIGO" } },
			 { { "ANN R. SCOTT" } },
			 { { "WESLEY SCOTT" } },
			 { { "TRAMPAS A. THOMPSON" } },
		},
		{
			 { { "Unit Production Manager" } },
			 { { "HOWARD GRIFFITH" } },
			 { { "" } },
			 { { "First Assistant Director" } },
			 { { "ROMNEY PEARL" } },
			 { { "" } },
			 { { "Second Assistant Director" } },
			 { { "BRADLEY MORRIS" } },
		},
		{
			 { { "Costume Designer" } },
			 { { "AUDREY FISHER" } },
		},
		{
			 { { "Music Supervisor" } },
			 { { "GARY CALAMAR" } },
		},
		current_page = 1,

		get_page = function ( this, next )
			if next then
				this.current_page = (this.current_page % #this) + 1
			end

			return this:build_page(this[this.current_page])
		end,

		build_page = function ( this, the_page )
			local page_group = Group {}

			print("Forming page",serialize(the_page))

			for i,the_line in pairs(the_page) do
				local line_group = this:build_line(the_line)

				-- Position the element in the group vertically
				line_group.y = 80 * (i-1)

				page_group:add(line_group)
			end

			return page_group
		end,
		
		build_line = function ( this, the_line)
			local line_group = Group {}

			print("Forming line",serialize(the_line))

			for i,the_element in pairs(the_line) do
				local text_element = this:build_element(the_element)

				-- If there's only one element on the line, then center it.
				-- If there are 2 elements, then the first is placed with negative x, and the 2nd with position x
				if(#the_line > 1) then
					if(1 == i) then
						text_element.x = -20 + -text_element.w
					else
						text_element.x = 20
					end
				else
					text_element.x = -text_element.w/2
				end

				line_group:add(text_element)
			end

			return line_group
		end,

		build_element = function ( this, the_element )
			print("Forming element",serialize(the_element))
			return Text { font = "Fontin 54px", color = "ffffff", text = the_element[1] }
		end,
	}

