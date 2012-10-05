local t = Text()
t.text='hello'

local changed1 = false
local changed2 = false
local changed3 = false
t.on_text_changed = function() changed1=true end
ref = t:add_ontextchanged_listener( function() changed2=true end )
t:add_ontextchanged_listener( function() changed3=true end )
t:remove_ontextchanged_listener( ref )

t.text='goodbye'

function test_cluttertext_multi_called ()
    assert_true( changed1 , "got: "..tostring(changed1).." expected: true")
    assert_true( not changed2 , "got: "..tostring(changed2).." expected: false")
    assert_true( changed3 , "got: "..tostring(changed3).." expected: true")
end
