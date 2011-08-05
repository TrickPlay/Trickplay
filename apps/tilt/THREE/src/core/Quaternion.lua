THREE = THREE or {}

THREE.Quaternion = {x = 0, y = 0, z = 0, w = 1}
THREE.Quaternion.types = THREE.Quaternion.types or {}
THREE.Quaternion.types[THREE.Quaternion] = true
setmetatable(THREE.Quaternion, THREE.Quaternion)
THREE.Quaternion.__index = THREE.Quaternion

THREE.Quaternion.__call = function(_, t)
	local a = {}
	setmetatable(a, THREE.Quaternion)
	a:set(t.x or 0, t.y or 0, t.z or 0, t.w or 1)
	return a
end

function THREE.Quaternion:set(x,y,z,w)
	self.x = x
	self.y = y
	self.z = z
	self.w = w
	
	return self
end

function THREE.Quaternion:copy(q)
	self.x = q.x
	self.y = q.y
	self.z = q.z
	self.w = q.w

	return self
end

function THREE.Quaternion:setFromEuler (vec3)
	local c = 0.5 * math.pi / 360
	local x = vec3.x * c
	local y = vec3.y * c
	local z = vec3.z * c

	local c1 = math.cos(y)
	local s1 = math.sin(y)
	local c2 = math.cos(-z)
	local s2 = math.sin(-z)
	local c3 = math.cos(x)
	local s3 = math.sin(x)

	local c1c2 = c1 * c2
	local s1s2 = s1 * s2

	self.w = c1c2 * c3  - s1s2 * s3;
	self.x = c1c2 * s3  + s1s2 * c3;
	self.y = s1   * c2 * c3 + c1 * s2 * s3;
	self.z = c1   * s2 * c3 - s1 * c2 * s3;

	return self
end

function THREE.Quaternion:setFromAxisAngle ( axis, angle)
	local halfAngle = angle / 2
	local s = math.sin(halfAngle)

	self.x = axis.x * s
	self.y = axis.y * s
	self.z = axis.z * s
	self.w = math.cos(halfAngle)

	return self
end

function THREE.Quaternion:calculateW()
	self.w = - math.sqrt( math.abs( 1.0 - self.x * self.x - self.y * self.y - self.z * self.z ) );

	return self
end

function THREE.Quaternion:inverse()
	self.x = -self.x
	self.y = -self.y
	self.z = -self.z

	return self
end

function THREE.Quaternion:length()
	return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
end

function THREE.Quaternion:normalize()
	local l = self:length()
	if (l == 0) then
		self.x = 0
		self.y = 0
		self.z = 0
		self.w = 0
	else
		l = 1 / l

		self.x = self.x * l
		self.y = self.y * l
		self.z = self.z * l
		self.w = self.w * l
	end

	return self
end

function THREE.Quaternion:multiplySelf(quat2)
	local qax, qay, qaz, qaw, qbx, qby, qbz, qbw =
	self.x, self.y, self.z, self.w, quat2.x, quat2.y, quat2.z, quat2.w

	self.x = qax * qbw + qaw * qbx + qay * qbz - qaz * qby
	self.y = qay * qbw + qaw * qby + qaz * qbx - qax * qbz
	self.z = qaz * qbw + qaw * qbz + qax * qby - qay * qbx
	self.w = qaw * qbw - qax * qbx - qay * qby - qaz * qbz

	return self
end

function THREE.Quaternion:multiply(q1, q2)
	self.x =  q1.x * q2.w + q1.y * q2.z - q1.z * q2.y + q1.w * q2.x
	self.y = -q1.x * q2.z + q1.y * q2.w + q1.z * q2.x + q1.w * q2.y
	self.z =  q1.x * q2.y - q1.y * q2.x + q1.z * q2.w + q1.w * q2.z
	self.w = -q1.x * q2.x - q1.y * q2.y - q1.z * q2.z + q1.w * q2.w

	return self
end

function THREE.Quaternion:multiplyVector3 (vec, dest)
	if (not dest) then
		dest = vec
	end

	local x, y, z, qx, qy, qz, qw = vec.x, vec.y, vec.z, self.x, self.y, self.z, self.w

	-- calculate quat * vec

	local ix =  qw * x + qy * z - qz * y
	local iy =  qw * y + qz * x - qx * z
	local iz =  qw * z + qx * y - qy * x
	local iw = -qx * x - qy * y - qz * z

	-- calculate result * inverse quat

	dest.x = ix * qw + iw * -qx + iy * -qz - iz * -qy;
	dest.y = iy * qw + iw * -qy + iz * -qx - ix * -qz;
	dest.z = iz * qw + iw * -qz + ix * -qy - iy * -qx;

	return dest;
end

function THREE.Quaternion:slerp (qa, qb, qm, t)
	local cosHalfTheta = qa.w * qb.w + qa.x * qb.x + qa.y * qb.y + qa.z * qb.z;

	if ( math.abs( cosHalfTheta ) >= 1.0 ) then

		qm.w = qa.w
		qm.x = qa.x
		qm.y = qa.y
		qm.z = qa.z
		return qm
	end

	local halfTheta = math.acos( cosHalfTheta )
	local sinHalfTheta = math.sqrt( 1.0 - cosHalfTheta * cosHalfTheta )

	if ( math.abs( sinHalfTheta ) < 0.001 ) then

		qm.w = 0.5 * ( qa.w + qb.w )
		qm.x = 0.5 * ( qa.x + qb.x )
		qm.y = 0.5 * ( qa.y + qb.y )
		qm.z = 0.5 * ( qa.z + qb.z )

		return qm
	end

	local ratioA = math.sin( ( 1 - t ) * halfTheta ) / sinHalfTheta
	local ratioB = math.sin( t * halfTheta ) / sinHalfTheta

	qm.w = ( qa.w * ratioA + qb.w * ratioB )
	qm.x = ( qa.x * ratioA + qb.x * ratioB )
	qm.y = ( qa.y * ratioA + qb.y * ratioB )
	qm.z = ( qa.z * ratioA + qb.z * ratioB )

	return qm
end

--[[debug
function THREE.Quaternion:print ()
	print(self.x, self.y, self.z, self.w)
end

myQ = THREE.Quaternion{x = 2, y = 5, z = 8, w = 10}

myQ:print()

myQ2 = THREE.Quaternion{}

myQ2:copy(myQ)

myQ3 = THREE.Quaternion{}

myQ3:setFromEuler({x = 4, y = 2, z = 0})

myQ3:print()

myQ2:calculateW()

myQ2:print()

myQ2:normalize()

myQ2:print()

myQ:setFromAxisAngle({x = 1, y = 6, z = 13}, 2.7)

myQ:print()

print(myQ:length())

myQ:inverse()

myQ:print()

print("-------------------")

myQ:print()

myQ2:print()

myQ3:print()

myQ2:multiply(myQ,myQ3)

myQ:print()

myQ2:print()

myQ3:print()

myQ:multiplySelf(myQ3)

myQ:print()

--myVec = myQ3:multiplyVector3({x = 3, y = 3, z = 1}, nil)

--myVec:print()

myQ.slerp(myQ2,myQ3,myQ, 6)

myQ:print()]]

