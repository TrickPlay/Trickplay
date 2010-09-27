wave = {
			-- Wave 1
			money = 15,
	
			{
				{
					{name = "NormalCreep"},
					size = 10,
					speed = 2.5,
					buffs = {hp = 1, speed = 1.5},
				},
				size = 10,
			},

			-- Wave 2
			{
				{
					{name = "NormalCreep"},
					size = 10,
					speed = 2.5,
					buffs = {hp = 1, speed = 2.3},
				},
				size = 10,
			},
			
			-- Wave 3
			{
				{
					{name = "FlyingCreep"},
					size = 15,
					speed = 2.0,
				},
				size = 15,
			},
			
			-- Wave 4
			{
				{
					{name = "MediumCreep"},
					size = 10,
					speed = 3,
				},
				size = 10,
			},
			-- Wave 5
			{
				{
					{name = "NormalCreep"},
					size = 10,
					speed = 2.0,
					buffs = {hp = 1.3, speed = 1.5},
				},
				{
					{name = "MediumCreep"},
					size = 10,
					speed = 2.0,
				},
				size = 20,
			},

			-- Wave 6

			{
				{
					{name = "SlowCreep"},
					{name = "MediumCreep"},
					size = 20,
					speed = 2.0,
				},
				size = 20,
			},
			
			-- Wave 7
			{
				{
					{name = "FlyingCreep"},
					size = 15,
					speed = 0.6,
				},
				size = 15,
			},
		}
return wave
