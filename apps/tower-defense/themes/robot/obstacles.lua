local obstacles = {

        -- Round 1
        {
                {2,1},
                {2,16},
                {8,1},
                {8,16},
                frames = 5,
                insert = true
        },
        
        -- Round 2
        {
                {3,1},
                {3,16},
                {7,1},
                {7,16},
                frames = 5,
                insert = true
        },
        
        -- Round 3
        {
                -- this one has a maze built in
                {2,1},
                {2,16},
                {8,1},
                {8,16},
                frames = 5,
                insert = true
        },
        
        -- Round 4
        {
                {4,7},
                {7,4},
                {3,7},
                {7,3},
                
                {4,10},
                {7,14},
                {3,10},
                {7,13},
                
                frames = 5,
                insert = true
        },
        
        -- Round 5
        {
                {2,1},
                {2,16},
                {8,1},
                {8,16},
                {2,5},
                {3,5},
                {4,5},
                {5,5},
                {6,5},
                {7,5},
                {8,12},
                {7,12},
                {6,12},
                {5,12},
                {4,12},
                {3,12},
                frames = 5,
                insert = true
        },
        
        -- Round 6
        {
                {3,3},
                {3,4},
                {3,13},
                {3,14},
                
                {7,3},
                {7,4},
                {7,13},
                {7,14},
                
                frames = 5,
                insert = true
        },
        
        -- Round 7
        
        {
                {2,1},
                {2,16},
                {8,1},
                {8,16},
                -- this one has random obstacles
                {math.random(7)+1, math.random(14)+1},
                frames = 5,
                insert = true							
        },
        
        -- Round 8
        {
                {2,4},
                {4,8},
                {6,12},
                {8,16},
                
                frames = 5,
                insert = true
        },
        
        -- Round 9
        {
                {2,1},
                {2,16},
                {8,1},
                {8,16},
                -- this one has random obstacles as well
                frames = 5,
                insert = true			
        },
        
        -- Round 10
        {
                {2,1},
                {2,16},
                {8,1},
                {8,16},
                -- this one has random obstacles as well
                frames = 5,
                insert = true			
        }
}

for i=2, 16 do
	table.insert(obstacles[1], {2, i})
	table.insert(obstacles[1], {3, i})
	table.insert(obstacles[1], {7, i})
	table.insert(obstacles[1], {8, i})
end

for i=2, 16 do
	table.insert(obstacles[3], {2, i})
	table.insert(obstacles[3], {8, i})
end

for i=1, 10 do
	table.insert(obstacles[7],{math.random(7)+1, math.random(14)+1})
	table.insert(obstacles[9],{math.random(7)+1, math.random(14)+1})
end

return obstacles
