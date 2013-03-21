-- Make a progress bar at bottom of the screen
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

-- Text for the progress bar
local MY_TEXT = "<span weight='600'>Updating Guide Data...</span>"

local pb_text = Text {
                    color = "white",
                    markup = MY_TEXT,
                    font = "FreeSans "..(13*pb.h/36).."px",
                    x = 60,
                    y = pb.y + pb.h/2,
                }

pb_text.anchor_point = { 0, pb_text.h/2 }

-- Text shadow for progress bar
local pb_text_bg = Text {
                    color = "black",
                    opacity = 255 * 0.7,
                    markup = MY_TEXT,
                    font = pb_text.font,
                    x = pb_text.x - 2,
                    y = pb_text.y - 2,
                }
pb_text_bg.anchor_point = { 0, pb_text.h/2 }

return pb,pb_text,pb_text_bg
