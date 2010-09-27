wave = {
			money = 2000,
			-- Wave 1
			{
				{
					{name = "NormalCreep"},
					size = 1,
					speed = 1,
				},
				size = 1   
			},

			-- Wave 2
			{
				{
					{name = "NormalCreep"},
					{name = "MediumCreep"},
					size = 30,
					speed = 1,
				},
				{
					{name = "MediumCreep"},
					{name = "HardCreep"},
					size = 10,
					speed = 1,
				},
				size = 40

			},

			-- Wave 4
			{
				{
					{name = "NormalCreep"},
					{name = "MediumCreep"},
					{name = "HardCreep"},
					size = 75,
					speed = 1,
				},
				{
					{name = "FlyingCreep"},
					size = 10,
					speed = 1,
				},
				size = 85
			},
                       
      		-- Wave 5
			{
				  {
					  {name = "BossCreep"},
					  size = 1,
					  speed = 1,
				  },
				  size = 1
         }
		}
return wave
