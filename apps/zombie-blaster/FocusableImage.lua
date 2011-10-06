FocusableImage = Class(function(focusimg, x, y, image_src, focus_src, text, ...)
    if not x then return end
    assert(x)
    assert(y)
--    assert(image_src)
--    assert(focus_src)

    if type(image_src) == "string" then
        image_src = Image{src = image_src}
    end
    if type(focus_src) == "string" then
        focus_src = Image{src = focus_src}
    end
    
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
        if type(text) == "string" then
            text = Text{text = text, font = DEFAULT_FONT, color = DEFAULT_COLOR}
        end
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
            interval = {opacity = Interval(focusimg.focus.opacity, 255)}
            gameloop:add(focusimg.focus, CHANGE_FOCUS_TIME, nil, interval)
        end
        if focusimg.image then
            interval = {opacity = Interval(focusimg.image.opacity, 100)}
            gameloop:add(focusimg.image, CHANGE_FOCUS_TIME, nil, interval)
        end
    end

    function focusimg:off_focus()
        if focusimg.focus then
            interval = {opacity = Interval(focusimg.focus.opacity, 0)}
            gameloop:add(focusimg.focus, CHANGE_FOCUS_TIME, nil, interval)
        end
        if focusimg.image then
            interval = {opacity = Interval(focusimg.image.opacity, 255)}
            gameloop:add(focusimg.image, CHANGE_FOCUS_TIME, nil, interval)
        end
    end

    function focusimg:on_focus_inst()
        if focusimg.focus then
            focusimg.focus.opacity = 255
        end
        if focusimg.image then
            focusimg.image.opacity = 0
        end
    end

    function focusimg:off_focus_inst()
        if focusimg.focus then
            focusimg.focus.opacity = 0
        end
        if focusimg.image then
            focusimg.image.opacity = 255
        end
    end

end)
