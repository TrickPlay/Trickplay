local small, big = ...

local big_text = Text {
                        color = "grey90",
                        text = big,
                        font = "FreeSans bold 392px",
                    }
big_text.anchor_point = { big_text.w/2, big_text.h/2 }

local small_text = Text {
                            color = "grey90",
                            text = small,
                            font = "FreeSans 192px",
                            x = big_text.x,
                        }
small_text.anchor_point = { small_text.w/2, small_text.h/2 }
small_text.y = -small_text.h/2
small_text.x = (small_text.w-big_text.w)/2

local text_group = Group { children = { big_text, small_text } }
text_group.position = { screen.w/2, screen.h/2 }

return small_text, big_text, text_group
