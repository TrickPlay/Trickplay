AudioFiles = {
    ["BIRD"] = "assets/audio/bird-impact1.mp3",
    ["TNT"] = "assets/audio/explosion.mp3",
    ["POWER_LINE"] = "assets/audio/power-lines.mp3",
    ["TRAMPOLINE"] = "assets/audio/trampoline.mp3",
    ["TRASH"] = "assets/audio/trashcan.mp3"
}

AudioFilesByNumber = {
    [1] = "assets/audio/bird-impact1.mp3",
    [2] = "assets/audio/explosion.mp3",
    [3] = "assets/audio/power-lines.mp3",
    [4] = "assets/audio/trampoline.mp3",
    [5] = "assets/audio/trashcan.mp3"
}

AudioLengths = {
    ["BIRD"] = 500,
    ["TNT"] = 1300,
    ["POWER_LINE"] = 700,
    ["TRAMPOLINE"] = 300,
    ["TRASH"] = 300
}

AudioLengthsByNumber = {
    [1] = 500,
    [2] = 1300,
    [3] = 700,
    [4] = 300,
    [5] = 300
}

TOTAL_AUDIO_FILES = #AudioFilesByNumber

TOTAL_CHANNELS = 3
AudioManager = Class(function(audio, ...)

    local taken_channels = 0

    function audio:play_file(file, length)
        if type(file) ~= "string" then error("file must be a string", 2) end
        if not length or type(length) ~= "number" then
            error("must have a length that is a number", 2)
        end
        if taken_channels >= TOTAL_CHANNELS then return end

        if AudioFiles[file] then
            length = AudioLengths[file]
            file = AudioFiles[file]
        end
        if file == "HIT" then
            file = "assets/audio/ZombieHit"..math.random(3)..".mp3"
            length = 1300
        end

        taken_channels = taken_channels + 1
        mediaplayer:play_sound(file)
        intervals = {val = Interval(0, 100)}
        local timer = {}
        gameloop:add(timer, length, 0, intervals, true,
            function() taken_channels = taken_channels - 1 end)
    end

end)
