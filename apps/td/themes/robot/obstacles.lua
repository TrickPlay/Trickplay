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
                                                
                                                -- Round 4
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
                                                
                                                -- Round 5
                                                {
							{2,4},
							{4,8},
							{6,12},
							{8,16},
                                                        
							frames = 5,
							insert = true
						},
}

for i=2, 16 do
	table.insert(obstacles[1], {2, i})
	table.insert(obstacles[1], {3, i})
	table.insert(obstacles[1], {7, i})
	table.insert(obstacles[1], {8, i})
end

return obstacles
