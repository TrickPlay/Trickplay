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

	We make some assumptions to make the math tractable:

	We assume that the matrix is composed of:

	Z = RotationTransform[z, {0, 0, 1}
	S = ScalingTransform[{sx, sy, 1}]
	L = TranslationTransform[{dx, dy, 0}]
	M = L.S.Z;

	In other words, the matrix is a combination of a rotation about the Z-axis, a scaling in x- and y- directions, and an (x,y) translation ONLY.  There are no rotations in other axes, and no scaling in z.  In other words, the transformed actor will remain completly in the same x-y plane that is started in.

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


function apply_matrix_to_actor( M, actor )

	local sx,sy,dx,dy,z

	sx = math.sqrt(M[1]*M[1]+M[5]*M[5])
	sy = M[2]/M[5] * sx

	dx = M[13]
	dy = M[14]

	z = 2 * math.atan2((M[1] - sx),M[5])

	print("Transform was: (",sx,sy,dx,dy,360+math.deg(z),")")

	actor.z_rotation = {actor.z_rotation[1]+360+math.deg(z), 0, 0}

	actor.scale = { actor.scale[1]*sx, actor.scale[2]*sy }

	actor.x = actor.x + dx
	actor.y = actor.y + dy

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


