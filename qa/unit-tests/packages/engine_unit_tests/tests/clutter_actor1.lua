local r = Rectangle{w=100,h=100,y=200,color='GREEN'}
r.reactive=true
controllers:start_pointer()

---[[
local focusin1 = false
local focusin2 = false
local ref = r:add_onkeyfocusin_listener( function() focusin1=true end )
r:add_onkeyfocusin_listener( function() focusin2=true end )
r:remove_onkeyfocusin_listener( ref )

local focusout1 = false
local focusout2 = false
ref = r:add_onkeyfocusout_listener( function() focusout1=true end )
r:add_onkeyfocusout_listener( function() focusout2=true end )
r:remove_onkeyfocusout_listener( ref )

local show1 = false
local show2 = false
ref = r:add_onshow_listener( function() show1=true end )
r:add_onshow_listener( function() show2=true end )
r:remove_onshow_listener( ref )

local hide1 = false
local hide2 = false
ref = r:add_onhide_listener( function() hide1=true end )
r:add_onhide_listener( function() hide2=true end )
r:remove_onhide_listener( ref )

local parent1 = false
local parent2 = false
ref = r:add_onparentchanged_listener( function() parent1=true end )
r:add_onparentchanged_listener( function() parent2=true end )
r:remove_onparentchanged_listener( ref )
--]]

--[[
ref = r:add_onkeydown_listener( function() print('a') end )
r:add_onkeydown_listener( function() print('b') end )
r:remove_onkeydown_listener( ref )

ref = r:add_onkeyup_listener( function() print('c') end )
r:add_onkeyup_listener( function() print('d') end )
r:remove_onkeyup_listener( ref )

ref = r:add_onbuttondown_listener( function() print('e') end )
r:add_onbuttondown_listener( function() print('f') end )
r:remove_onbuttondown_listener( ref )

ref = r:add_onbuttonup_listener( function() print('g') end )
r:add_onbuttonup_listener( function() print('h') end )
r:remove_onbuttonup_listener( ref )

ref = r:add_onmotion_listener( function() print('i') end )
r:add_onmotion_listener( function() print('j') end )
r:remove_onmotion_listener( ref )

ref = r:add_onenter_listener( function() print('k') end )
r:add_onenter_listener( function() print('l') end )
r:remove_onenter_listener( ref )

ref = r:add_onleave_listener( function() print('m') end )
r:add_onleave_listener( function() print('n') end )
r:remove_onleave_listener( ref )
--]]

collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()
collectgarbage()

screen:show()
screen:add(r)
r:hide()

---[[
dolater(100 , function()
    r:grab_key_focus()
    screen:grab_key_focus()
    r:grab_key_focus()
end )
--]]

function test_clutteractor_multi_called ()
    --on_new_frame
    assert_true ( not focusin1 , "returned: "..tostring(focusin1).." Expected false")
    assert_true ( focusin2, "returned: "..tostring(focusin2).." Expected true")
    assert_true ( not focusout1 , "returned: "..tostring(focusout1).." Expected false")
    assert_true ( focusout2, "returned: "..tostring(focusout2).." Expected true")
    assert_true ( not show1 , "returned: "..tostring(show1).." Expected false")
    assert_true ( show2, "returned: "..tostring(show2).." Expected true")
    assert_true ( not hide1 , "returned: "..tostring(hide1).." Expected false")
    assert_true ( hide2, "returned: "..tostring(hide2).." Expected true")
    assert_true ( not parent1 , "returned: "..tostring(parent1).." Expected false")
    assert_true ( parent2, "returned: "..tostring(parent2).." Expected true")
end

-- Test Tear down --
