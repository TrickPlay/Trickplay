--[[
	This file provides one function: apply_matrix_to_actor()
	This function takes argument of a 4x4 homogenous transform matrix, and and an actor,
	and applies that transform to the actor

	The incoming 4x4 matrix should be structured as a 16-element array, where the indices correspond to:
	
	[	1	5	9	13	]
	[	2	6	10	14	]
	[	3	7	11	15	]
	[	4	8	12	16	]

	would be expressed as: { 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 }

]]--

local function matrix_to_string( a )
	local result = "\n"
	for j=1,4 do
		result = result.."["
		for i=1,4 do
			result = result.."\t"..serialize(a[(i-1)*4+j])
		end
		result = result.."\t]\n"
	end
	return result
end

local function matrix_multiply( a, b )
	local result = { 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0 }
	for j = 1,4 do
		for i = 1,4 do
			local pos = (i-1)*4+j
			for k=1,4 do
				result[pos] = result[pos]  +  a[(i-1)*4+k] * b[(k-1)*4+j]
			end
		end
	end

	return result
end


function apply_matrix_to_actor( matrix, actor )

	local A = math.cos(math.rad(actor.x_rotation[1]))
	local B = math.sin(math.rad(actor.x_rotation[1]))
	local C = math.cos(math.rad(actor.y_rotation[1]))
	local D = math.sin(math.rad(actor.y_rotation[1]))
	local E = math.cos(math.rad(actor.z_rotation[1]))
	local F = math.sin(math.rad(actor.z_rotation[1]))

	local current = {
								actor.scale[1] * C*E,
								B*D*E + A*F,
								-A*D*E + B*F,
								0,
								-C*F,
								actor.scale[2] * (-B*D*F + A*E),
								A*D*F + B*E,
								0,
								D,
								-B*C,
								A*C,
								0,
								actor.x,
								actor.y,
								actor.z,
								1
							}


	local result = matrix_multiply( matrix, current )


	assert(
				result[4] == 0 and
				result[8] == 0 and
				result[12] == 0 and
				result[16] == 1,
				"Bottom row of compound matrix is not (0,0,0,1):\n"..matrix_to_string(result)
		)

	actor.x = result[13]
	actor.y = result[14]
	actor.z = result[15]

	local angle_x,angle_y,angle_z
	angle_y = math.asin(result[3])
	local D = angle_y
	local C = math.cos(angle_y)
	if(math.abs(C) > 0.005) then
		local trx = result[11] / C;
		local try = -result[7] / C;
		angle_x = math.atan2(try, trx)

		trx = result[1] / C;
		try = -result[2] / C;
		angle_z = math.atan2(try, trx)
	else
		angle_x = 0
		local trx = result[6]
		local try = result[5]
		angle_z = math.atan2(try, trx)
	end

	actor.z_rotation = { -math.deg(angle_z), 0, 0 }
	actor.y_rotation = { math.deg(angle_y), 0, 0 }
	actor.x_rotation = { math.deg(angle_x), 0, 0 }

end



--[[
	Some examples:
	
	Rotated 45 degrees about 0,0
2311 [ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 50, 410, 0, 1 ]

	[	1	0	0	50	]
	[	0	1	0	410	]
	[	0	0	1	0	]
	[	0	0	0	1	]

2311 [ 0.707107, 0.707107, 0, 0, -0.707107, 0.707107, 0, 0, 0, 0, 1, 0, 50, 410, 0, 1 ]

	[	0.707107	-0.707107	0	50	]
	[	0.707107	0.707107	0	410	]
	[	0			0			1	0	]
	[	0			0			0	1	]

Rotated 45 degrees about center
2315 [ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 400, 410, 0, 1 ]

	[	1	0	0	400	]
	[	0	1	0	410	]
	[	0	0	1	0	]
	[	0	0	0	1	]

2315 [ 0.707107, 0.707107, 0, 0, -0.707107, 0.707107, 0, 0, 0, 0, 1, 0, 500, 368.578644, 0, 1 ]

	[	0.707107	-0.707107	0	500			]
	[	0.707107	0.707107	0	368.578644	]
	[	0			0			1	0			]
	[	0			0			0	1			]


Relative Coordinates app
3579 [ 1.010000, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ]
	- Scales by 1.01 in the x-axis

3579 [ 1.009950, 0, 0, 0, -0.010100, 0.999950, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ]

	[	1.00995	-0.0101		0	0	]
	[	0		0.999950	0	0	]
	[	0		0			1	0	]
	[	0		0			0	1	]

3579 [ 1.009950, 0, 0, 0, -0.010100, 0.999950, 0, 0, 0, 0, 1, 0, 50.497475, 0.499992, 0, 1 ]
3579 [ 1.009950, 0, 0, 0, -0.010100, 0.999950, 0, 0, 0, 0, 1, 0, 49.487492, 100.494992, 0, 1 ]

3581 [ 0.980067, -0.198669, 0, 0, 0.198669, 0.980067, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 ]
3581 [ 0.980067, -0.198669, 0, 0, 0.198669, 0.980067, 0, 0, 0, 0, 1, 0, 98.006658, -19.866933, 0, 1 ]
3581 [ 0.980067, -0.198669, 0, 0, 0.198669, 0.980067, 0, 0, 0, 0, 1, 0, 99.993351, -10.066267, 0, 1 ]

m[1]=x*cos(a)*cos(b), m[2]=sin(a)*cos(b), m[3]=-sin(b), m[5]=cos(a)*sin(b)*sin(c)-sin(a)*cos(c), m[6]=y*sin(a)*sin(b)*sin(c)+cos(a)*cos(c), m[7]=cos(b)*sin(c), m[9]=cos(a)*sin(b)*cos(c)+sin(a)*sin(c), m[10]=sin(a)*sin(b)*cos(c)-cos(a)*sin(c), m[11]=z*cos(b)*cos(c)
]]--


