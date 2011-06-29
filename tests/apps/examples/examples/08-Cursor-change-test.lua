

local my_cursor = 1

local cursors = {
                    editor.CURSOR_LEFT_PTR,
                    editor.CURSOR_XTERM,
                    editor.CURSOR_CROSSHAIR,
                    editor.CURSOR_TOP_SIDE,
                    editor.CURSOR_BOTTOM_SIDE,
                    editor.CURSOR_LEFT_SIDE,
                    editor.CURSOR_RIGHT_SIDE,
                    editor.CURSOR_SB_H_DOUBLE_ARROW,
                    editor.CURSOR_SB_V_DOUBLE_ARROW,
                    editor.CURSOR_SB_FLEUR,
                }

local t = Timer(2000);
t.on_timer = function()
    if(my_cursor == #cursors) then my_cursor = 1 else my_cursor = my_cursor+1 end
    print("Setting cursor to ",cursors[my_cursor])
    editor:set_cursor(cursors[my_cursor])
end

t:start()
