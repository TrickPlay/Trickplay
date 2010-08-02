wave = {
	-- This is a copy of round 4.. didn't get around to  finishing
	money = 10,
	
	-- Wave 1
	{
		{
			{name = "SlowCreep"},
			size = 5,
			speed = 1,
			buffs = {hp = 1},
		},
		size = 5,
	},
	
	 -- Wave 2
	{
		{
			{name = "HardCreep"},
			size = 5,
			speed = 3,
			buffs = {hp = .4, speed = .5},
		},
		size = 5,
	},
	
	 -- Wave 3
	{
		{
			{name = "MediumCreep"},
			size = 10,
			speed = 3,
			buffs = {hp = 1, speed = .5},
		},
                size = 10,
	},
	
	-- Wave 4
	{
		{
			{name = "NormalCreep"},
			{name = "MediumCreep"},
			size = 20,
			speed = 1.5,
			buffs = {hp = 1, speed = .75},
		},
		size = 20,
	},
	
	-- Wave 5
	{
		{
			{name = "SlowCreep"},
			{name = "MediumCreep"},
			size = 30,
			speed = 1.5,
			buffs = {hp = 1, speed = 1},
		},
		size = 30,
	},
	
	-- Wave 6
	{
		{
			{name = "HardCreep"},
			size = 3,
			speed = 4,
			buffs = {hp = 1.25, speed = .5},
		},
                {
			{name = "NormalCreep"},
                        {name = "NormalCreep"},
			size = 20,
			speed = 1,
			buffs = {hp = .75, speed = 1},
		},
		size = 20,
	},
        
	-- Wave 7
	{
		{
			{name = "HardCreep"},
			size = 20,
			speed = 1.5,
                        buffs = {hp = 1, speed = 1},
		},
		size = 20,
	},
        
        -- Wave 8
	{
		{
                        {name = "MediumCreep"},
			{name = "HardCreep"},
			size = 30,
			speed = 1.5,
                        buffs = {hp = 1, speed = 1},
		},
		size = 30,
	},
	
	-- Wave 9
	{
		{
			{name = "NormalCreep"},
			{name = "MediumCreep"},
                        {name = "MediumCreep"},
			size = 20,
			speed = 1,
		},
		{
			{name = "HardCreep"},
			size = 10,
			speed = 1,
		},
		size = 30,
	},
	
	-- Wave 10
	{
		{
			{name = "BossCreep"},
			size = 1,
			buffs = { hp = .5 }
		},
		size = 1,
	},

}
	
return wave
