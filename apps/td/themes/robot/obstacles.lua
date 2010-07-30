local obstacles = {
						{
							{2,1},
							{2,16},
							{8,1},
							{8,16},
							frames = 5,
							insert = true
						},
						{
							{3,1},
							{3,16},
							{7,1},
							{7,16},
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
