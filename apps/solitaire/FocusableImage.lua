FocusableImage = Class(function(focusimg, x, y, image_src, focus_src, text, extra, ...)
    if not x then return end
    assert(x)
    assert(y)
--    assert(image_src)
--    assert(focus_src)
    
    focusimg.image = image_src
    focusimg.focus = focus_src

    -- static, move the group and these values may not match
    focusimg.x = x
    focusimg.y = y

    focusimg.group = Group()
    focusimg.group.x = x
    focusimg.group.y = y
    focusimg.group:add(focusimg.image)
    focusimg.group:add(focusimg.focus)
    if text then
        focusimg.text = text
        focusimg.group:add(text)
        text.anchor_point = {text.width/2, text.height/2}
        text.x = image_src.width/2
        text.y = image_src.height/2
    end

    if focus_src then
        focusimg.focus.opacity = 0
    end
    
    function focusimg:on_focus()
        if focusimg.focus then
            focusimg.focus:animate{duration = CHANGE_FOCUS_TIME, opacity = 255}
        end
        if focusimg.image then
            focusimg.image:animate{duration = CHANGE_FOCUS_TIME, opacity = 100}
        end
        if text then text.color = Colors.BLACK end
    end

    function focusimg:off_focus()
        if focusimg.focus then
            focusimg.focus:animate{duration = CHANGE_FOCUS_TIME, opacity = 0}
        end
        if focusimg.image then
            focusimg.image:animate{duration = CHANGE_FOCUS_TIME, opacity = 255}
        end
        if text then text.color = Colors.WHITE end
    end

end)
