if not OVERRIDEMETATABLE then dofile("lib/__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("lib/__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("lib/__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("lib/__UTILITIES/Canvas.lua")              end
if not MISC              then dofile("lib/__UTILITIES/Misc.lua")                end
if not COLORSCHEME       then dofile("lib/__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("lib/__CORE/Style.lua")                    end
if not WIDGET            then dofile("lib/__CORE/Widget.lua")                   end
if not PROGRESSBAR       then dofile("lib/ProgressBar/ProgressBar.lua")         end


if not OVERRIDEMETATABLE then dofile("lib/__UTILITIES/OverrideMetatable.lua")   end
if not TYPECHECKING      then dofile("lib/__UTILITIES/TypeChecking.lua")        end
if not TABLEMANIPULATION then dofile("lib/__UTILITIES/TableManipulation.lua")   end
if not CANVAS            then dofile("lib/__UTILITIES/Canvas.lua")              end
if not MISC              then dofile("lib/__UTILITIES/Misc.lua")                end
if not COLORSCHEME       then dofile("lib/__CORE/ColorScheme.lua")              end
if not STYLE             then dofile("lib/__CORE/Style.lua")                    end
if not WIDGET            then dofile("lib/__CORE/Widget.lua")                   end
if not LISTMANAGER       then dofile("lib/__UTILITIES/ListManagement.lua")      end
if not LAYOUTMANAGER     then dofile("lib/LayoutManager/LayoutManager.lua")     end
if not NINESLICE         then dofile("lib/NineSlice/NineSlice.lua")             end


local pb = ProgressBar {
                            width = screen.w,
                            h = 110,
                            x = 0,
                            y = screen.h-110,
                            style = {
                                fill_colors = {
                                            focus_upper = { 72, 97, 123 },
                                            focus_lower = { 30, 58, 86 },
                                            default_upper   = "gray24",
                                            default_lower   = "grey15",
                                },
                                border = {
                                    width = 0,
                                    corner_radius = 0,
                                },
                            },
            }

local MY_TEXT = "<span weight='600'>Updating Guide Data...</span>"

local pb_text = Text {
                    color = "white",
                    markup = MY_TEXT,
                    font = "FreeSans "..(13*pb.h/36).."px",
                    x = 60,
                    y = pb.y + pb.h/2,
                }

pb_text.anchor_point = { 0, pb_text.h/2 }

local pb_text_bg = Text {
                    color = "black",
                    opacity = 255 * 0.7,
                    markup = MY_TEXT,
                    font = pb_text.font,
                    x = pb_text.x - 2,
                    y = pb_text.y - 2,
                }
pb_text_bg.anchor_point = { 0, pb_text.h/2 }


local movie_poster = NineSlice{
    anchor_point = { 150, 200 },
    x = screen.w/2,
    y = screen.h/2,
    w = 300,
    h = 400,
    scale = { 0.1, 0.1 },
    cells = {
        default = {
            {
                Widget_Rectangle{w=3,h=3,color="white", opacity=255 * 0.7},
                Widget_Rectangle{w=3,h=3,color="white", opacity=255 * 0.7},
                Widget_Rectangle{w=3,h=3,color="white", opacity=255 * 0.7},
            },
            {
                Widget_Rectangle{w=3,h=3,color="white", opacity=255 * 0.7},
                Widget_Image { src = "assets/movie_posters/Kick_Ass.jpg" },
                Widget_Rectangle{w=3,h=3,color="white", opacity=255 * 0.7},
            },
            {
                Widget_Rectangle{w=3,h=3,color="white", opacity=255 * 0.7},
                Widget_Rectangle{w=3,h=3,color="white", opacity=255 * 0.7},
                Widget_Rectangle{w=3,h=3,color="white", opacity=255 * 0.7},
            },
        },
    }
}


screen:add(movie_poster)
screen:add(pb)
screen:add(pb_text_bg)
screen:add(pb_text)
screen:show()

local strings = {
                    "Updating Guide Data...",
                    "Calibrating Capacitors...",
                    "Going to Warp Speed...",
                    "Done",
                }

local as = AnimationState {
                    duration = 2000,            -- default transition duration
                    mode = "LINEAR",  -- default Ease mode for all transitions
                    transitions = {
                        {
                          source = "*",
                          target = "1",
                          keys = {
                                { pb, "x", 0 },
                          }
                        },
                        {
                          source = "*",
                          target = "2",
                          keys = {
                                { movie_poster, "x", 2*(math.random(0,screen.w)-screen.w/2) },
                                { movie_poster, "y", math.random(-screen.h-movie_poster.h, screen.h+movie_poster.h) },
                                { movie_poster, "scale", { 1.0, 1.0 } },
                          }
                        },
                        {
                          source = "*",
                          target = "3",
                          keys = {
                                { pb, "x", 0 },
                          }
                        },
                        {
                          source = "*",
                          target = "4",
                          keys = {
                                { pb, "x", 0 },
                          }
                        },
                    }
                }

function as:on_completed()
    pb_text_bg.markup = "<span weight='600'>"..strings[as.state+0].."</span>"
    pb_text.markup = "<span weight='600'>"..strings[as.state+0].."</span>"
    local next_state = (as.state+1)
    if(strings[next_state]) then as.state = next_state end
end

function as.timeline:on_new_frame(ms, p)
    collectgarbage("collect")
    local num_strings = #strings-1
    local start = as.state - 2
    pb.progress = (p + start)/num_strings
end

as:warp("1")
