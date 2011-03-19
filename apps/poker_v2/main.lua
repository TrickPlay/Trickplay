Components = {
    COMPONENTS_FIRST = 1,
    CHARACTER_SELECTION = 1,
    PLAYER_BETTING = 2,
    GAME = 3,
    TUTORIAL = 4,
    SPLASH = 5,
    COMPONENTS_LAST = 5
}

Events = {
    KEYBOARD = 1,
    TIMER = 2,
    NOTIFY = 3
}

dofile("Class.lua")
dofile("AssetManager.lua")
assetman = AssetManager()
dofile("DoFiles.lua")


-- Router initialization
router = Router()
dofile("EventHandling.lua")
add_to_key_handler(keys.a, assetman.show_all)

screen:show()
-- Animation loop initialization
--gameloop = GameLoop()

-- View/Controller initialization
--game = GameControl(router, Components.GAME)
--[[
game_menu = MenuView(router)
game_menu:initialize()
local no_moves_dialog = DialogBox("Sorry!\nThere are no\nmore moves", Components.NO_MOVES_DIALOG, router)
local new_map_dialog = DialogBox("Start a new game\non this layout?", Components.NEW_MAP_DIALOG, router)
--]]

local game = GameControl(router)
local character_selection = CharacterSelectionController(router)
local splash = SplashController(router)
router:start_app(Components.SPLASH)
--router:start_app(Components.NO_MOVES_DIALOG)
--router:start_app(Components.NEW_MAP_DIALOG)
