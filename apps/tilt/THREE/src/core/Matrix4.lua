THREE = THREE or {}
THREE.Matrix4={}
THREE.Matrix4.types = THREE.Matrix4.types or {}
THREE.Matrix4.types[THREE.Matrix4] = true
THREE.Matrix4.__v1 = THREE.Vector3()
THREE.Matrix4.__v2 = THREE.Vector3()
THREE.Matrix4.__v3 = THREE.Vector3()

setmetatable(THREE.Matrix4, THREE.Matrix4)
THREE.Matrix4.__index = THREE.Matrix4
THREE.Matrix4.__call = function (_, n11, n12, n13, n14, n21, n22, n23, n24, n31, n32, n33, n34, n41, n42, n43, n44 )
	local m3 = {}
	setmetatable(m3, THREE.Matrix4)
	m3:set(
		n11 or 1, n12 or 0, n13 or 0, n14 or 0,
		n21 or 0, n22 or 1, n23 or 0, n24 or 0,
		n31 or 0, n32 or 0, n33 or 1, n34 or 0,
		n41 or 0, n42 or 0, n43 or 0, n44 or 1
	)
	m3.flat={}
	m3.position=-1
	m3.columnX=-1
	m3.columnY=-1
	m3.columnZ=-1
	m3.m33=THREE.Matrix3()
	return m3
end

function THREE.Matrix4:set( n11, n12, n13, n14, n21, n22, n23, n24, n31, n32, n33, n34, n41, n42, n43, n44 )
	self.n11=n11; self.n12=n12; self.n13=n13; self.n14=n14
	self.n21=n21; self.n22=n22; self.n23=n23; self.n24=n24
	self.n31=n31; self.n32=n32; self.n33=n33; self.n34=n34
	self.n41=n41; self.n42=n42; self.n43=n43; self.n44=n44
	return self
end

function THREE.Matrix4:identity()
	self:set(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	)
	return self
end

function THREE.Matrix4:copy(m)
	self:set(
		m.n11, m.n12, m.n13, m.n14,
		m.n21, m.n22, m.n23, m.n24,
		m.n31, m.n32, m.n33, m.n34,
		m.n41, m.n42, m.n43, m.n44
	)
	return self
end

function THREE.Matrix4:lookAt(eye, center, up)
	local x=THREE.Matrix4.__v1
	local y=THREE.Matrix4.__v2
	local z=THREE.Matrix4.__v3
	z:sub(eye, center):normalize()
	if (z:length()==0) then z.z=1 end
	x:cross(up,z):normalize()
	if (x:length()==0) then
		z.x=z.x+.0001
		x:cross(up,z):normalize()
	end
	y:cross(z,x):normalize()
	self.n11 = x.x; self.n12 = y.x; self.n13 = z.x
	self.n21 = x.y; self.n22 = y.y; self.n23 = z.y
	self.n31 = x.z; self.n32 = y.z; self.n33 = z.z
	return self
end

function THREE.Matrix4:multiplyVector3(v)
	local vx=v.x
	local vy=v.y
	local vz=v.z
	local d=1/(self.n41*vx+self.n42*vy+self.n43*vz+self.n44)
	v.x = ( self.n11 * vx + self.n12 * vy + self.n13 * vz + self.n14 ) * d
	v.y = ( self.n21 * vx + self.n22 * vy + self.n23 * vz + self.n24 ) * d
	v.z = ( self.n31 * vx + self.n32 * vy + self.n33 * vz + self.n34 ) * d
	return v
end

function THREE.Matrix4:multiplyVector4(v)
	local vx=v.x
	local vy=v.y
	local vz=v.z
	local vw=v.w
	v.x = self.n11 * vx + self.n12 * vy + self.n13 * vz + self.n14 * vw
	v.y = self.n21 * vx + self.n22 * vy + self.n23 * vz + self.n24 * vw
	v.z = self.n31 * vx + self.n32 * vy + self.n33 * vz + self.n34 * vw
	v.w = self.n41 * vx + self.n42 * vy + self.n43 * vz + self.n44 * vw
	return v;
end

function THREE.Matrix4:rotateAxis(v)
	local vx=v.x
	local vy=v.y
	local vz=v.z
	v.x = vx * self.n11 + vy * self.n12 + vz * self.n13
	v.y = vx * self.n21 + vy * self.n22 + vz * self.n23
	v.z = vx * self.n31 + vy * self.n32 + vz * self.n33
	v:normalize()
	return v
end

function THREE.Matrix4:crossVector(a)
	local v=THREE.Vector4()
	v.x = self.n11 * a.x + self.n12 * a.y + self.n13 * a.z + self.n14 * a.w
	v.y = self.n21 * a.x + self.n22 * a.y + self.n23 * a.z + self.n24 * a.w
	v.z = self.n31 * a.x + self.n32 * a.y + self.n33 * a.z + self.n34 * a.w
	v.w =  a.w and self.n41 * a.x + self.n42 * a.y + self.n43 * a.z + self.n44 * a.w or 1
	return v
end

function THREE.Matrix4:multiply(a,b)
	local a11 = a.n11; local a12 = a.n12; local a13 = a.n13; local a14 = a.n14;
	local a21 = a.n21; local a22 = a.n22; local a23 = a.n23; local a24 = a.n24;
	local a31 = a.n31; local a32 = a.n32; local a33 = a.n33; local a34 = a.n34;
	local a41 = a.n41; local a42 = a.n42; local a43 = a.n43; local a44 = a.n44;

	local b11 = b.n11; local b12 = b.n12; local b13 = b.n13; local b14 = b.n14;
	local b21 = b.n21; local b22 = b.n22; local b23 = b.n23; local b24 = b.n24;
	local b31 = b.n31; local b32 = b.n32; local b33 = b.n33; local b34 = b.n34;
	local b41 = b.n41; local b42 = b.n42; local b43 = b.n43; local b44 = b.n44

	self.n11 = a11 * b11 + a12 * b21 + a13 * b31 + a14 * b41
	self.n12 = a11 * b12 + a12 * b22 + a13 * b32 + a14 * b42
	self.n13 = a11 * b13 + a12 * b23 + a13 * b33 + a14 * b43
	self.n14 = a11 * b14 + a12 * b24 + a13 * b34 + a14 * b44

	self.n21 = a21 * b11 + a22 * b21 + a23 * b31 + a24 * b41
	self.n22 = a21 * b12 + a22 * b22 + a23 * b32 + a24 * b42
	self.n23 = a21 * b13 + a22 * b23 + a23 * b33 + a24 * b43
	self.n24 = a21 * b14 + a22 * b24 + a23 * b34 + a24 * b44

	self.n31 = a31 * b11 + a32 * b21 + a33 * b31 + a34 * b41
	self.n32 = a31 * b12 + a32 * b22 + a33 * b32 + a34 * b42
	self.n33 = a31 * b13 + a32 * b23 + a33 * b33 + a34 * b43
	self.n34 = a31 * b14 + a32 * b24 + a33 * b34 + a34 * b44

	self.n41 = a41 * b11 + a42 * b21 + a43 * b31 + a44 * b41
	self.n42 = a41 * b12 + a42 * b22 + a43 * b32 + a44 * b42
	self.n43 = a41 * b13 + a42 * b23 + a43 * b33 + a44 * b43
	self.n44 = a41 * b14 + a42 * b24 + a43 * b34 + a44 * b44

	return self;
end

function THREE.Matrix4:multiplyToArray(a,b,r)
	self:multiply(a,b)
	r[ 0 ] = self.n11; r[ 1 ] = self.n21; r[ 2 ] = self.n31; r[ 3 ] = self.n41
	r[ 4 ] = self.n12; r[ 5 ] = self.n22; r[ 6 ] = self.n32; r[ 7 ] = self.n42
	r[ 8 ] = self.n13; r[ 9 ] = self.n23; r[ 10 ] = self.n33; r[ 11 ] = self.n43
	r[ 12 ] = self.n14; r[ 13 ] = self.n24; r[ 14 ] = self.n34; r[ 15 ] = self.n44
	return self
end


function THREE.Matrix4:multiplySelf(m)
	self:multiply(self, m)
	return self
end

function THREE.Matrix4:multiplyScalar(s)
	self.n11=self.n11*s; self.n12=self.n12*s; self.n13=self.n13*s; self.n14=self.n14*s
	self.n21=self.n21*s; self.n22=self.n22*s; self.n23=self.n23*s; self.n24=self.n24*s
	self.n31=self.n31*s; self.n32=self.n32*s; self.n33=self.n33*s; self.n34=self.n34*s
	self.n41=self.n41*s; self.n42=self.n42*s; self.n43=self.n43*s; self.n44=self.n44*s
	return self
end

function THREE.Matrix4:determinant()
	return (self.n14 * self.n23 * self.n32 * self.n41-
		self.n13 * self.n24 * self.n32 * self.n41-
		self.n14 * self.n22 * self.n33 * self.n41+
		self.n12 * self.n24 * self.n33 * self.n41+
	
		self.n13 * self.n22 * self.n34 * self.n41-
		self.n12 * self.n23 * self.n34 * self.n41-
		self.n14 * self.n23 * self.n31 * self.n42+
		self.n13 * self.n24 * self.n31 * self.n42+
	
		self.n14 * self.n21 * self.n33 * self.n42-
		self.n11 * self.n24 * self.n33 * self.n42-
		self.n13 * self.n21 * self.n34 * self.n42+
		self.n11 * self.n23 * self.n34 * self.n42+
	
		self.n14 * self.n22 * self.n31 * self.n43-
		self.n12 * self.n24 * self.n31 * self.n43-
		self.n14 * self.n21 * self.n32 * self.n43+
		self.n11 * self.n24 * self.n32 * self.n43+
	
		self.n12 * self.n21 * self.n34 * self.n43-
		self.n11 * self.n22 * self.n34 * self.n43-
		self.n13 * self.n22 * self.n31 * self.n44+
		self.n12 * self.n23 * self.n31 * self.n44+
	
		self.n13 * self.n21 * self.n32 * self.n44-
		self.n11 * self.n23 * self.n32 * self.n44-
		self.n12 * self.n21 * self.n33 * self.n44+
		self.n11 * self.n22 * self.n33 * self.n44
	)
end

function THREE.Matrix4:transpose()
	local tmp = self.n21; self.n21 = self.n12; self.n12 = tmp
	tmp = self.n31; self.n31 = self.n13; self.n13 = tmp
	tmp = self.n32; self.n32 = self.n23; self.n23 = tmp
	tmp = self.n41; self.n41 = self.n14; self.n14 = tmp
	tmp = self.n42; self.n42 = self.n24; self.n24 = tmp
	tmp = self.n43; self.n43 = self.n34; self.n43 = tmp
return self;
end

function THREE.Matrix4:clone()
	local m = THREE.Matrix4()
	m.n11 = self.n11; m.n12 = self.n12; m.n13 = self.n13; m.n14 = self.n14
	m.n21 = self.n21; m.n22 = self.n22; m.n23 = self.n23; m.n24 = self.n24
	m.n31 = self.n31; m.n32 = self.n32; m.n33 = self.n33; m.n34 = self.n34
	m.n41 = self.n41; m.n42 = self.n42; m.n43 = self.n43; m.n44 = self.n44
	return m;
end

function THREE.Matrix4:flatten()
	self.flat[ 0 ] = self.n11; self.flat[ 1 ] = self.n21; self.flat[ 2 ] = self.n31; self.flat[ 3 ] = self.n41;
	self.flat[ 4 ] = self.n12; self.flat[ 5 ] = self.n22; self.flat[ 6 ] = self.n32; self.flat[ 7 ] = self.n42;
	self.flat[ 8 ] = self.n13; self.flat[ 9 ] = self.n23; self.flat[ 10 ] = self.n33; self.flat[ 11 ] = self.n43;
	self.flat[ 12 ] = self.n14; self.flat[ 13 ] = self.n24; self.flat[ 14 ] = self.n34; self.flat[ 15 ] = self.n44;
	return self.flat;
end

function THREE.Matrix4:flattenToArray(flat)
	flat[ 0 ] = self.n11; flat[ 1 ] = self.n21; flat[ 2 ] = self.n31; flat[ 3 ] = self.n41;
	flat[ 4 ] = self.n12; flat[ 5 ] = self.n22; flat[ 6 ] = self.n32; flat[ 7 ] = self.n42;
	flat[ 8 ] = self.n13; flat[ 9 ] = self.n23; flat[ 10 ] = self.n33; flat[ 11 ] = self.n43;
	flat[ 12 ] = self.n14; flat[ 13 ] = self.n24; flat[ 14 ] = self.n34; flat[ 15 ] = self.n44;
	return flat
end

function THREE.Matrix4:flattenToArrayOffset(flat, offset)
	flat[ offset ] = self.n11;
	flat[ offset + 1 ] = self.n21;
	flat[ offset + 2 ] = self.n31;
	flat[ offset + 3 ] = self.n41;

	flat[ offset + 4 ] = self.n12;
	flat[ offset + 5 ] = self.n22;
	flat[ offset + 6 ] = self.n32;
	flat[ offset + 7 ] = self.n42;

	flat[ offset + 8 ] = self.n13;
	flat[ offset + 9 ] = self.n23;
	flat[ offset + 10 ] = self.n33;
	flat[ offset + 11 ] = self.n43;

	flat[ offset + 12 ] = self.n14;
	flat[ offset + 13 ] = self.n24;
	flat[ offset + 14 ] = self.n34;
	flat[ offset + 15 ] = self.n44;
	return flat;
end

function THREE.Matrix4:setTranslation(x,y,z)
	self:set(
		1, 0, 0, x,
		0, 1, 0, y,
		0, 0, 1, z,
		0, 0, 0, 1
	)
	return self
end

function THREE.Matrix4:setScale(x,y,z)
	self:set(
		x, 0, 0, 0,
		0, y, 0, 0,
		0, 0, z, 0,
		0, 0, 0, 1
	)
	return self
end

function THREE.Matrix4:setRotationX(theta)
	local c = math.cos(theta)
	local s = math.sin(theta)
	self:set(
		1, 0, 0, 0,
		0, c, -s, 0,
		0, s, c, 0,
		0, 0, 0, 1
	)
	return self
end

function THREE.Matrix4:setRotationY(theta)
	local c = math.cos(theta)
	local s = math.sin(theta)
	self:set(
		c, 0, s, 0,
		0, 1, 0, 0,
		-s, 0, c, 0,
		0, 0, 0, 1
	)
	return self
end

function THREE.Matrix4:setRotationZ(theta)
	local c = math.cos(theta)
	local s = math.sin(theta)
	self:set(
		c, -s, 0, 0,
		s, c, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	)
	return self
end

function THREE.Matrix4:setRotationAxis(axis, angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	local t = 1-c
	local x = axis.x; local y = axis.y; local z = axis.z
	local tx = t*x; local ty = t*y
	self:set(
		tx * x + c,     tx * y - s * z, tx * z + s * y, 0,
		tx * y + s * z, ty * y + c,     ty * z - s * x, 0,
		tx * z - s * y, ty * z + s * x,  t * z * z + c, 0,
		0, 0, 0, 1
	)
	return self
end

function THREE.Matrix4:setPosition(v)
	self.n14=v.x
	self.n24=v.y
	self.n34=v.z
	return self
end

function THREE.Matrix4:getPosition()
	if (self.position==-1) then
		self.position = THREE.Vector3()
	end
	self.position:set(self.n14, self.n24, self.n34)
	return self.position
end

function THREE.Matrix4:getColumnX()
	if (self.columnX==-1) then
		self.columnX = THREE.Vector3()
	end
	self.columnX:set(self.n11, self.n21, self.n31)
	return self.columnX
end

function THREE.Matrix4:getColumnY()
	if (self.columnY==-1) then
		self.columnY = THREE.Vector3()
	end
	self.columnY:set(self.n12, self.n22, self.n32)
	return self.columnY
end

function THREE.Matrix4:getColumnZ()
	if (self.columnZ==-1) then
		self.columnZ = THREE.Vector3()
	end
	self.columnZ:set(self.n13, self.n23, self.n33)
	return self.columnZ
end

function THREE.Matrix4:setRotationFromEuler(v,order)
	local x=v.x; local y=v.y; local z=v.z
	local a=math.cos(x); local b=math.sin(x)
	local c=math.cos(y); local d=math.sin(y)
	local e=math.cos(z); local f=math.sin(z)
	if (order=="YXZ") then
		local ce = c * e; local cf = c * f; local de = d * e; local df = d * f
		self.n11 = ce + df * b
		self.n12 = de * b - cf
		self.n13 = a * d
		self.n21 = a * f
		self.n22 = a * e
		self.n23 = - b
		self.n31 = cf * b - de
		self.n32 = df + ce * b
		self.n33 = a * c
	elseif (order=="ZXY") then
		local ce = c * e; local cf = c * f; local de = d * e; local df = d * f
		self.n11 = ce - df * b
		self.n12 = - a * f
		self.n13 = de + cf * b
		self.n21 = cf + de * b
		self.n22 = a * e
		self.n23 = df - ce * b
		self.n31 = - a * d
		self.n32 = b
		self.n33 = a * c
	elseif (order=="ZYX") then
		local ae = a * e; local af = a * f; local be = b * e; local bf = b * f
		self.n11 = c * e
		self.n12 = be * d - af
		self.n13 = ae * d + bf
		self.n21 = c * f
		self.n22 = bf * d + ae
		self.n23 = af * d - be
		self.n31 = - d
		self.n32 = b * c
		self.n33 = a * c
	elseif (order=="YZX") then
		local ac = a * c; local ad = a * d; local bc = b * c; local bd = b * d
		self.n11 = c * e
		self.n12 = bd - ac * f
		self.n13 = bc * f + ad
		self.n21 = f
		self.n22 = a * e
		self.n23 = - b * e
		self.n31 = - d * e
		self.n32 = ad * f + bc
		self.n33 = ac - bd * f
	elseif (order=="XZY") then
		local ac = a * c; local ad = a * d; local bc = b * c; local bd = b * d
		self.n11 = c * e;
		self.n12 = - f;
		self.n13 = d * e;
		self.n21 = ac * f + bd;
		self.n22 = a * e;
		self.n23 = ad * f - bc;
		self.n31 = bc * f - ad;
		self.n32 = b * e;
		self.n33 = bd * f + ac;
	else
		local ae = a * e; local af = a * f; local be = b * e; local bf = b * f
		self.n11 = c * e;
		self.n12 = - c * f;
		self.n13 = d;
		self.n21 = af + be * d;
		self.n22 = ae - bf * d;
		self.n23 = - b * c;
		self.n31 = bf - ae * d;
		self.n32 = be + af * d;
		self.n33 = a * c;
	end

	return self
end

function THREE.Matrix4:setRotationFromQuaternion(q)
	local x = q.x;     local y = q.y; local z = q.z; local w = q.w
	local x2 = x + x;  local y2 = y + y; local z2 = z + z
	local xx = x * x2; local xy = x * y2; local xz = x * z2
	local yy = y * y2; local yz = y * z2; local zz = z * z2
	local wx = w * x2; local wy = w * y2; local wz = w * z2
	self.n11 = 1 - ( yy + zz );
	self.n12 = xy - wz;
	self.n13 = xz + wy;
	self.n21 = xy + wz;
	self.n22 = 1 - ( xx + zz );
	self.n23 = yz - wx;
	self.n31 = xz - wy;
	self.n32 = yz + wx;
	self.n33 = 1 - ( xx + yy );
	return self;
end

function THREE.Matrix4:scale(v)
	local x = v.x; local y = v.y; local z = v.z
	self.n11 = self.n11*x; self.n12 = self.n12*y; self.n13 = self.n13*z
	self.n21 = self.n21*x; self.n22 = self.n22*y; self.n23 = self.n23*z
	self.n31 = self.n31*x; self.n32 = self.n32*y; self.n33 = self.n33*z
	self.n41 = self.n41*x; self.n42 = self.n42*y; self.n43 = self.n43*z
	return self;
end

function THREE.Matrix4:extractPosition(m)
	self.n14 = m.n14
	self.n24 = m.n24
	self.n34 = m.n34
end

function THREE.Matrix4:extractRotation(m,s)
	local invScaleX = 1 / s.x; local invScaleY = 1 / s.y; local invScaleZ = 1 / s.z
	self.n11 = m.n11 * invScaleX;
	self.n21 = m.n21 * invScaleX;
	self.n31 = m.n31 * invScaleX;
	self.n12 = m.n12 * invScaleY;
	self.n22 = m.n22 * invScaleY;
	self.n32 = m.n32 * invScaleY;
	self.n13 = m.n13 * invScaleZ;
	self.n23 = m.n23 * invScaleZ;
	self.n33 = m.n33 * invScaleZ;
end

--static functions
function THREE.Matrix4.makeInvert(m1,m2)
	local n11 = m1.n11; local n12 = m1.n12; local n13 = m1.n13; local n14 = m1.n14
	local n21 = m1.n21; local n22 = m1.n22; local n23 = m1.n23; local n24 = m1.n24
	local n31 = m1.n31; local n32 = m1.n32; local n33 = m1.n33; local n34 = m1.n34
	local n41 = m1.n41; local n42 = m1.n42; local n43 = m1.n43; local n44 = m1.n44
	if (not m2) then m2 = THREE.Matrix4() end
	m2.n11 = n23*n34*n42 - n24*n33*n42 + n24*n32*n43 - n22*n34*n43 - n23*n32*n44 + n22*n33*n44
	m2.n12 = n14*n33*n42 - n13*n34*n42 - n14*n32*n43 + n12*n34*n43 + n13*n32*n44 - n12*n33*n44
	m2.n13 = n13*n24*n42 - n14*n23*n42 + n14*n22*n43 - n12*n24*n43 - n13*n22*n44 + n12*n23*n44
	m2.n14 = n14*n23*n32 - n13*n24*n32 - n14*n22*n33 + n12*n24*n33 + n13*n22*n34 - n12*n23*n34
	m2.n21 = n24*n33*n41 - n23*n34*n41 - n24*n31*n43 + n21*n34*n43 + n23*n31*n44 - n21*n33*n44
	m2.n22 = n13*n34*n41 - n14*n33*n41 + n14*n31*n43 - n11*n34*n43 - n13*n31*n44 + n11*n33*n44
	m2.n23 = n14*n23*n41 - n13*n24*n41 - n14*n21*n43 + n11*n24*n43 + n13*n21*n44 - n11*n23*n44
	m2.n24 = n13*n24*n31 - n14*n23*n31 + n14*n21*n33 - n11*n24*n33 - n13*n21*n34 + n11*n23*n34
	m2.n31 = n22*n34*n41 - n24*n32*n41 + n24*n31*n42 - n21*n34*n42 - n22*n31*n44 + n21*n32*n44
	m2.n32 = n14*n32*n41 - n12*n34*n41 - n14*n31*n42 + n11*n34*n42 + n12*n31*n44 - n11*n32*n44
	m2.n33 = n13*n24*n41 - n14*n22*n41 + n14*n21*n42 - n11*n24*n42 - n12*n21*n44 + n11*n22*n44
	m2.n34 = n14*n22*n31 - n12*n24*n31 - n14*n21*n32 + n11*n24*n32 + n12*n21*n34 - n11*n22*n34
	m2.n41 = n23*n32*n41 - n22*n33*n41 - n23*n31*n42 + n21*n33*n42 + n22*n31*n43 - n21*n32*n43
	m2.n42 = n12*n33*n41 - n13*n32*n41 + n13*n31*n42 - n11*n33*n42 - n12*n31*n43 + n11*n32*n43
	m2.n43 = n13*n22*n41 - n12*n23*n41 - n13*n21*n42 + n11*n23*n42 + n12*n21*n43 - n11*n22*n43
	m2.n44 = n12*n23*n31 - n13*n22*n31 + n13*n21*n32 - n11*n23*n32 - n12*n21*n33 + n11*n22*n33
	m2:multiplyScalar( 1 / m1:determinant() )
	return m2
end

function THREE.Matrix4.makeInvert3x3(m1)
	local m33 = m1.m33
	local m33m = m33.m
	local a11 = m1.n33 * m1.n22 - m1.n32 * m1.n23
	local a21 = - m1.n33 * m1.n21 + m1.n31 * m1.n23
	local a31 = m1.n32 * m1.n21 - m1.n31 * m1.n22
	local a12 = - m1.n33 * m1.n12 + m1.n32 * m1.n13
	local a22 = m1.n33 * m1.n11 - m1.n31 * m1.n13
	local a32 = - m1.n32 * m1.n11 + m1.n31 * m1.n12
	local a13 = m1.n23 * m1.n12 - m1.n22 * m1.n13
	local a23 = - m1.n23 * m1.n11 + m1.n21 * m1.n13
	local a33 = m1.n22 * m1.n11 - m1.n21 * m1.n12
	local det = m1.n11 * a11 + m1.n21 * a12 + m1.n31 * a13
	if ( det == 0 ) then
		print("THREE.Matrix4:makeInvert3x3: error: matrix is not invertible")
		exit()
	end
	local idet = 1.0 / det;
	m33m[ 0 ] = idet * a11; m33m[ 1 ] = idet * a21; m33m[ 2 ] = idet * a31;
	m33m[ 3 ] = idet * a12; m33m[ 4 ] = idet * a22; m33m[ 5 ] = idet * a32;
	m33m[ 6 ] = idet * a13; m33m[ 7 ] = idet * a23; m33m[ 8 ] = idet * a33;
	return m33;
end

function THREE.Matrix4.makeFrustum(left,right,bottom,top,near,far)
	local m = THREE.Matrix4()
	local x = 2 * near / ( right - left )
	local y = 2 * near / ( top - bottom )
	local a = ( right + left ) / ( right - left )
	local b = ( top + bottom ) / ( top - bottom )
	local c = - ( far + near ) / ( far - near )
	local d = - 2 * far * near / ( far - near )
	m.n11 = x; m.n12 = 0; m.n13 = a; m.n14 = 0
	m.n21 = 0; m.n22 = y; m.n23 = b; m.n24 = 0
	m.n31 = 0; m.n32 = 0; m.n33 = c; m.n34 = d
	m.n41 = 0; m.n42 = 0; m.n43 = - 1; m.n44 = 0
	return m
end

function THREE.Matrix4.makePerspective(fov,aspect,near,far)
	local ymax = near * math.tan( fov * math.pi / 360 )
	local ymin = - ymax
	local xmin = ymin * aspect
	local xmax = ymax * aspect
	return THREE.Matrix4.makeFrustum(xmin, xmax, ymin, ymax, near, far)
end

function THREE.Matrix4.makeOrtho(left,right,top,bottom,near,far)
	local m = THREE.Matrix4()
	local w = right - left
	local h = top - bottom
	local p = far - near
	local x = ( right + left ) / w
	local y = ( top + bottom ) / h
	local z = ( far + near ) / p
	m.n11 = 2 / w; m.n12 = 0; m.n13 = 0; m.n14 = -x
	m.n21 = 0; m.n22 = 2 / h; m.n23 = 0; m.n24 = -y
	m.n31 = 0; m.n32 = 0; m.n33 = -2 / p; m.n34 = -z
	m.n41 = 0; m.n42 = 0; m.n43 = 0; m.n44 = 1
	return m;
end

function THREE.Matrix4:print()
    print(self.n11, self.n12, self.n13, self.n14)
    print(self.n21, self.n22, self.n23, self.n24)
    print(self.n31, self.n32, self.n33, self.n34)
    print(self.n41, self.n42, self.n43, self.n44)
end
