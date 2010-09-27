wave = {
	
	money = 15,
	
	-- Wave 1
	{
		{
			{name = "SlowCreep"},
			size = 10,
			speed = 1.5,
			buffs = {hp = 1},
		},
		size = 10,
	},
	
	 -- Wave 2
	{
		{
			{name = "SlowCreep"},
			size = 10,
			speed = 1.5,
			buffs = {hp = 1.5, speed = 1.5},
		},
		size = 10,
	},
	
	 -- Wave 3
	{
		{
			{name = "SlowCreep"},
			size = 5,
			speed = 1.5,
			buffs = {hp = 1.75, speed = 1.5},
		},
		{
			{name = "MediumCreep"},
			size = 5,
			speed = 2.5,  
		},
		size = 10,
	},
	
	-- Wave 4
	{
		{
			{name = "SlowCreep"},
			{name = "MediumCreep"},
			size = 20,
			speed = 1.5,
			buffs = {hp = 1, speed = 1.25},
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
			buffs = {hp = 1.25, speed = 1.25},
		},
		size = 30,
	},
	
	-- Wave 6
	{
		{
			{name = "SlowCreep"},
                        {name = "SlowCreep"},
			{name = "MediumCreep"},
			size = 41,
			speed = 2,
			buffs = {hp = 1, speed = 1},
		},
		size = 41,
	},
	
        
	-- Wave 7
	{
		{
			{name = "HardCreep"},
			size = 20,
			speed = 1.5,
                        buffs = {hp = 1.5, speed = 1},
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
