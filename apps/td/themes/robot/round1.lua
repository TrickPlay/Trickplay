wave = {

        -- temp wave
        
        money = 1000,
        {
                {
                        {name = "MediumCreep"},
                        size = 1,
                        speed = .1,
                        buffs = {hp = .01, speed = 100},
                },
                size = 1,
        },

                        --[[
			-- Wave 1
			money = 5,
			{
				{
					{name = "SlowCreep"},
					size = 5,
					speed = 4,
					buffs = {hp = 1},
				},
				size = 5,
			},
			
                        
			-- Wave 2
			{
				{
					{name = "SlowCreep"},
					size = 10,
					speed = 3.5,
				},
				size = 10,
			},
			
			-- Wave 3
			{
				{
					{name = "SlowCreep"},
					size = 10,
					speed = 3,
					buffs = {speed = 1.3},
				},
				size = 10,
			},
			
			-- Wave 4
			{
				{
					{name = "SlowCreep"},
					size = 10,
					speed = 2.5,
					buffs = {hp = 1.3, speed = 1.5},
				},
				size = 10,
			},
			
			-- Wave 5
			{
				{
					{name = "SlowCreep"},
					size = 10,
					speed = 2.5,
					buffs = {hp = 1.5, speed = 1.5},
				},
				size = 10,
			},
                        ]]

		}
return wave
