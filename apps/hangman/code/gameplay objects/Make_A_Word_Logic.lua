
local logic = {}

local letter_slot_i = 1

local ls_add_letter

function logic:init(t)
    
    if type(t) ~= "table" then error("must pass table as parameter",2) end
    
    ls = t.letter_slots
    
end

function logic:append_letter(l)
    
    if letter_slot_i > ls:num_slots() then return end
    
    ls:put_letter(l,letter_slot_i)
    
    letter_slot_i = letter_slot_i + 1
    
end

function logic:reset()
    
    letter_slot_i = 1
    
    ls:reset()
    
end

return logic