
local vowels = {
    ["A"] = 4,
    ["E"] = 4,
    ["I"] = 4,
    ["O"] = 4,
    ["U"] = 2,
}

local consonants = {
    ["B"] = 4,
    ["C"] = 4,
    ["D"] = 4,
    ["F"] = 4,
    ["G"] = 3,
    ["H"] = 3,
    ["J"] = 1,
    ["K"] = 1,
    ["L"] = 4,
    ["M"] = 2,
    ["N"] = 4,
    ["P"] = 4,
    ["Q"] = 1,
    ["R"] = 3,
    ["S"] = 4,
    ["T"] = 4,
    ["V"] = 1,
    ["W"] = 1,
    ["X"] = 1,
    ["Y"] = 1,
    ["Z"] = 1,
}
local values = {
    ["A"] = 1,
    ["E"] = 1,
    ["I"] = 1,
    ["O"] = 1,
    ["U"] = 1,
    ["B"] = 3,
    ["C"] = 3,
    ["D"] = 2,
    ["F"] = 2,
    ["G"] = 2,
    ["H"] = 4,
    ["J"] = 6,
    ["K"] = 6,
    ["L"] = 1,
    ["M"] = 3,
    ["N"] = 1,
    ["P"] = 3,
    ["Q"] = 6,
    ["R"] = 4,
    ["S"] = 1,
    ["T"] = 1,
    ["V"] = 6,
    ["W"] = 6,
    ["X"] = 8,
    ["Y"] = 4,
    ["Z"] = 8,
}


local get_letters = function(num_letters)
    
    math.randomseed(os.time())
    
    --return val
    local letters = {}
    
    --number of vowels is about a third of the number of letters
    local num_vowels = math.ceil(num_letters/3) + math.random(1,2)-1
    
    ----------------------------------------------------------------------------
    --VOWELS
    local copy_table = {}
    
    --make an array of the consonants
    for k,v in pairs(vowels) do
        
        for i = 1, v do
            
            table.insert(copy_table,k)
            
        end
        
    end
    
    --pull out random ones
    for i = 1,num_vowels do
        
        letters[#letters+1] = table.remove(copy_table,math.random(1,#copy_table))
        
    end
    
    
    ----------------------------------------------------------------------------
    --CONSONANTS
    copy_table = {}
    
    --make an array of the consonants
    for k,v in pairs(consonants) do
        
        for i = 1, v do
            
            table.insert(copy_table,k)
            
        end
        
    end
    
    --pull out random ones
    for i = 1, num_letters - num_vowels do
        
        letters[#letters+1] = table.remove(copy_table,math.random(1,#copy_table))
        
    end
    
    return letters
    
end

return get_letters, values