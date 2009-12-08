local_db = LocalDB.new('speed_test.tch')

value = ''
for i=1,1000 do
	value = value..math.random(0,9)
end

for j=1,1000000 do
	local_db:put(math.random(1,100000), value)
end
