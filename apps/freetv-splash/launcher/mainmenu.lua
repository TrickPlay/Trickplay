
local functional_areas = { "Live TV", "On Demand", "Apps", "Store", "Search" }

local menubar = Group {}

local bar_highlight, blue_overlay
local bar_slice

bar_slice = Canvas( 1, 45 )
-- 1 pixel of #0E1924, gradient for 43 pixels from (75,75,75) to (0,0,0), then one pixel of #0E1924
bar_slice:rectangle(-1,1, 3,43)
bar_slice:set_source_color( "#0E1924" )
bar_slice.line_width = 1
bar_slice:stroke(true)
bar_slice:set_source_linear_pattern(1,2, 1,42)
bar_slice:add_source_pattern_color_stop( 0, "#4B4B4B" )
bar_slice:add_source_pattern_color_stop( 1, "#000000" )
bar_slice:fill()

bar_slice = bar_slice:Image( { width = screen.w, tile = { true, false } } )

bar_highlight = Image { src = "assets/menubar/bar-highlight.png", x = 100 }
bar_highlight.y = -bar_highlight.h/2

blue_overlay = Image { src = "assets/menubar/blue-overlay.png", x = 100 }

menubar:add(bar_slice)
menubar:add(bar_highlight)
menubar:add(blue_overlay)

-- Outter labels group is used to bringing it on and off screen
local labels = Group { }
-- Inner labels group is for sliding the menu depending on the selected item
local inner_labels = Group { }
labels:add(inner_labels)
for _,i in pairs(functional_areas) do
    local sub_menu = dofile("launcher/"..i..".lua")
    local label = Text { font = FONT_NAME.." 34px", text = sub_menu.label, color = "AliceBlue", opacity = 128 }
    label.x = inner_labels.w + 100
    label.extra.activate = sub_menu.activate
    label.extra.deactivate = sub_menu.deactivate
    label.extra.sleep = sub_menu.sleep
    label.extra.wake = sub_menu.wake
    label.on_key_down = sub_menu.on_key_down
    inner_labels:add(label)
end
local active_label = 1
inner_labels.children[active_label]:activate()
menubar:add(labels)

local menubar_animationstate = AnimationState( {
                                                    duration = 500,
                                                    mode = EASE_IN_OUT_SINE,
                                                    transitions = {
                                                        {
                                                            source = "*",
                                                            target = "visible",
                                                            keys = {
                                                                { bar_slice, "y", "EASE_IN_OUT_SINE", 0, 0.0, 0.5 },
                                                                { labels, "x", "EASE_IN_OUT_SINE", 180, 0.5, 0 },
                                                                { bar_highlight, "opacity", "EASE_IN_OUT_SINE", 255, 0.5, 0 },
                                                                { blue_overlay, "opacity", "EASE_IN_OUT_SINE", 255, 0.5, 0 },
                                                            },
                                                        },
                                                        {
                                                            source = "*",
                                                            target = "hidden",
                                                            keys = {
                                                                { bar_slice, "y", "EASE_IN_OUT_SINE", 200, 0.5, 0 },
                                                                { labels, "x", "EASE_IN_OUT_SINE", -labels.w, 0, 0.5 },
                                                                { bar_highlight, "opacity", "EASE_IN_OUT_SINE", 0, 0, 0.5 },
                                                                { blue_overlay, "opacity", "EASE_IN_OUT_SINE", 0, 0, 0.5 },
                                                            },
                                                        },
                                                    },
} )


menubar_animationstate:warp("hidden")

menubar.appear = function(self)
    menubar_animationstate.state = "visible"
end

menubar.goaway = function(self)
    menubar_animationstate.state = "hidden"
    inner_labels.children[active_label]:sleep()
end

function menubar:start_item(item)
    for i,v in pairs(functional_areas) do
        if( v == item ) then
            local orig_active = active_label
            active_label = i
            inner_labels.x = 100-inner_labels.children[active_label].x
            inner_labels.children[orig_active]:deactivate(inner_labels.children[active_label])
        end
    end
end

local submenu_active = false
function menubar:on_key_down(key)
    -- By default, dispatch the keypress to the submenu
    -- If the submenu doesn't handle the keypress, it's because it wants us to do so
    if( not submenu_active or not inner_labels.children[active_label]:on_key_down(key)) then
        -- We can move left or right, which changes the active menu
        if(keys.Left == key or keys.Right == key) then
            local orig_active = active_label
            if(keys.Left == key) then
                active_label = ((active_label - 2) % #functional_areas) + 1
            else
                active_label = (active_label % #functional_areas) + 1
            end

            inner_labels:animate({ duration = 250, x = 100-inner_labels.children[active_label].x })

            inner_labels.children[orig_active]:deactivate(inner_labels.children[active_label])
        elseif(keys.Up == key or keys.OK == key) then
            -- We handle "Up" by waking the submenu so that it will know to navigate internally
            inner_labels.children[active_label]:wake()
            submenu_active = true
        elseif(keys.Down == key) then
            if( not submenu_active ) then screen:on_key_down(keys.BACK) end
            -- We handle "Down" by telling the submenu to sleep, which means it'll tend to refuse on_key_downs till it wakes
            inner_labels.children[active_label]:sleep()
            submenu_active = false
        end
    end
end

menubar.y = 925

return menubar
