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

-- handles ipods/pads/HIDs/etc
ctrlman = ControllerManager(false, true, nil, 7)

local betting = BettingController(router)
TutorialView(router):initialize()
local game = GameControl(router)
local character_selection = CharacterSelectionController(router)
local splash = SplashController(router)
router:start_app(Components.SPLASH)

ctrlman:initialize()
