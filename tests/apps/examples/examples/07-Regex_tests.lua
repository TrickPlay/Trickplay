local function compare_find(string, pattern)
    assert(string.find(string,pattern) == regex:find(string,pattern))
    print("PASS",regex:find(string,pattern))
end

local function compare_match(string, pattern)
    assert(string.match(string,pattern) == regex:match(string,pattern))
    print("PASS",regex:match(string,pattern))
end

compare_find('test','te')
compare_find('test','(t)e')
compare_find('test','(t)(e)')
compare_find('test test','te')
compare_find('test test','(t)e')
compare_find('test test','(t)(e)')

compare_match('test','te')
compare_match('test','(t)e')
compare_match('test','(t)(e)')
compare_match('test test','te')
compare_match('test test','(t)e')
compare_match('test test','(t)(e)')
