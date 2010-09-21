audio = {
    theme = "sounds/theme.wav",
    timer = Timer(),
}

audio.timer.interval = 160000
audio.timer.on_timer = function(timer)
    mediaplayer:play_sound(audio.theme)
end
mediaplayer:play_sound(audio.theme)
audio.timer:start()
