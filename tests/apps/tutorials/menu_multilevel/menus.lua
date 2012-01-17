
-- menus.lua
--
-- Defines all the application's menus and movie records

local vars = {}

-- *********************************************************
-- Define each movie record

vars.godfatherMovie = {
	title = "The Godfather",
	description = " ... ",
	image = "images/TheGodfather.jpg",
}

vars.citizenKaneMovie = {
	title = "Citizen Kane",
	description = " ... ",
	image = "images/CitizenKane.jpg",
}

vars.streetcarMovie = {
	title = "A Streetcar Named Desire",
	description = " ... ",
	image = "images/StreetcarNamedDesire.jpg",
}

vars.waterfrontMovie = {
	title = "On The Waterfront",
	description = " ... ",
	image = "images/OnTheWaterfront.jpg",
}

vars.ladyEveMovie = {
	title = "The Lady Eve",
	description = " ... ",
	image = "images/TheLadyEve.jpg",
}

vars.godfreyMovie = {
	title = "My Man Godfrey",
	description = " ... ",
	image = "images/MyManGodfrey.jpg",
}

vars.strangeloveMovie = {
	title = "Dr. Strangelove",
	description = " ... ",
	image = "images/DrStrangelove.jpg",
}

vars.operaMovie = {
	title = "A Night At The Opera",
	description = " ... ",
	image = "images/NightAtTheOpera.jpg",
}

vars.bladeRunnerMovie = {
	title = "Blade Runner",
	description = " ... ",
	image = "images/BladeRunner.jpg",
}

vars.alienMovie = {
	title = "Alien",
	description = " ... ",
	image = "images/Alien.jpg",
}

vars.earthStillMovie = {
	title = "The Day The Earth Stood Still",
	description = " ... ",
	image = "images/DayTheEarthStoodStill.jpg",
}

vars.planetApesMovie = {
	title = "Planet of the Apes",
	description = " ... ",
	image = "images/PlanetOfTheApes.jpg",
}

vars.treasureMovie = {
	title = "The Treasure of the Sierra Madre",
	description = " ... ",
	image = "images/TreasureOfSierraMadre.jpg",
}

vars.unforgivenMovie = {
	title = "Unforgiven",
	description = " ... ",
	image = "images/Unforgiven.jpg",
}

vars.johnnyGuitarMovie = {
	title = "Johnny Guitar",
	description = " ... ",
	image = "images/JohnnyGuitar.jpg",
}

vars.littleBigManMovie = {
	title = "Little Big Man",
	description = " ... ",
	image = "images/LittleBigMan.jpg",
}

-- *********************************************************
-- Define the secondary menus. For now, set the parentMenu to nil. They will be
-- linked to the primaryMenu after the primaryMenu has been defined.

vars.dramaMenu = {
	parentMenu = nil,
	title = "Select Movie",
    menuItems = {
    	{ menuText = "The Godfather",
    	  childMenu = nil,
    	  info = vars.godfatherMovie,
    	},
    	{ menuText = "Citizen Kane",
    	  childMenu = nil,
    	  info = vars.citizenKaneMovie,
    	},
    	{ menuText = "A Streetcar Named Desire",
    	  childMenu = nil,
    	  info = vars.streetcarMovie,
    	},
    	{ menuText = "On The Waterfront",
    	  childMenu = nil,
    	  info = vars.waterfrontMovie,
    	},
    },
}

vars.comedyMenu = {
	parentMenu = nil,
	title = "Select Movie",
	menuItems = {
		{ menuText = "The Lady Eve",
		  childMenu = nil,
		  info = vars.ladyEveMovie,
		},
		{ menuText = "My Man Godfrey",
		  childMenu = nil,
		  info = vars.godfreyMovie,
		},
		{ menuText = "Dr. Strangelove",
		  childMenu = nil,
		  info = vars.strangeloveMovie,
		},
		{ menuText = "A Night At The Opera",
		  childMenu = nil,
		  info = vars.operaMovie,
		},
	},
}

vars.sfMenu = {
	parentMenu = nil,
	title = "Select Movie",
	menuItems = {
		{ menuText = "Blade Runner",
		  childMenu = nil,
		  info = vars.bladeRunnerMovie,
		},
		{ menuText = "Alien",
		  childMenu = nil,
		  info = vars.alienMovie,
		},
		{ menuText = "The Day The Earth Stood Still",
		  childMenu = nil,
		  info = vars.earthStillMovie,
		},
		{ menuText = "Planet of the Apes",
		  childMenu = nil,
		  info = vars.planetApesMovie,
		},
	},
}

vars.westernMenu = {
	parentMenu = nil,
	title = "Select Movie",
	menuItems = {
		{ menuText = "The Treasure of the Sierra Madre",
		  childMenu = nil,
		  info = vars.treasureMovie,
		},
		{ menuText = "Unforgiven",
		  childMenu = nil,
		  info = vars.unforgivenMovie,
		},
		{ menuText = "Johnny Guitar",
		  childMenu = nil,
		  info = vars.johnnyGuitarMovie,
		},
		{ menuText = "Little Big Man",
		  childMenu = nil,
		  info = vars.littleBigManMovie,
		},
	},
}

-- *********************************************************
-- Define the primary menu. This menu is the parent of all the secondary menus.

vars.primaryMenu = {
	parentMenu = nil,
	title = "Select Movie Genre",
	menuItems = {
		{ menuText = "Drama",
          childMenu = vars.dramaMenu,
          info = nil,
    	},
    	{ menuText = "Comedy",
          childMenu = vars.comedyMenu,
          info = nil,
    	},
    	{ menuText = "Science Fiction",
          childMenu = vars.sfMenu,
          info = nil,
    	},
    	{ menuText = "Western",
          childMenu = vars.westernMenu,
          info = nil,
    	},
    },
}

-- *********************************************************
-- Finally, link each secondary menu to its parent.

vars.dramaMenu.parentMenu   = vars.primaryMenu
vars.comedyMenu.parentMenu  = vars.primaryMenu
vars.sfMenu.parentMenu      = vars.primaryMenu
vars.westernMenu.parentMenu = vars.primaryMenu


-- Return the defined variables
return( vars )

