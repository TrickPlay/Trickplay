
screen_w = screen.w
screen_h = screen.h

screen:show()

STORE_MENU_FONT_FOCUS = "InterstateProBold 40px"
STORE_MENU_FONT  = "InterstateProExtraLight 40px"
STORE_MENU_COLOR = "FFFFFF"

MAIN_MENU_FONT_FOCUS = "InterstateProBold 110px"
MAIN_MENU_FONT  = "InterstateProExtraLight 110px"
MAIN_MENU_COLOR = "FFFFFF"
function rand() return 55+20*math.ceil(10*math.random()) end
main = function()
    make_4movies_icon = dofile("FourMoviesIcon.lua")
    make_sub_menu = dofile("SubMenu.lua")
    local hidden_assets_group = Group { name = "hidden_assets" }
    hidden_assets_group:hide()
    screen:add(hidden_assets_group)
    local backdrop_maker = dofile("backdrop.lua")
    backdrop = backdrop_maker:make_backdrop()
    screen:add(backdrop)
    --floor = dofile("Floor.lua")
    main_menu = dofile("MainMenu.lua")
    screen:add(main_menu)
    main_menu.y = 600
    main_menu.name = "main_menu"
    
    local store_c_menu = dofile("StoreCategoryMenu.lua")
    store_c_menu.name = "store_c_menu"
    
    local store_m_menu = dofile("StoreSingleMovieMenu.lua")
    store_m_menu.name = "store_m_menu"
    
    store_menu = dofile("StoreMenu.lua")(store_m_menu,store_c_menu)
    screen:add(store_menu)
    store_menu.z = -300
    store_menu.name = "store_menu"
    
    main_menu:grab_key_focus()
end

dolater(main)