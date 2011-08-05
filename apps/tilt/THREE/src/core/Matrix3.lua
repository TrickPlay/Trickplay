THREE = THREE or {}
THREE.Matrix3={}
THREE.Matrix3.types = THREE.Matrix3.types or {}
THREE.Matrix3[THREE.Matrix3] = true
setmetatable(THREE.Matrix3, THREE.Matrix3)
--constuctor
THREE.Matrix3.__index = THREE.Matrix3
THREE.Matrix3.__call = function (_, t)
	local m3={}
	setmetatable(m3, THREE.Matrix3)
	m3.m = {}
	return m3
end

function THREE.Matrix3:transpose()
	local tmp=self.m[1]; self.m[1]=self.m[3]; self.m[3]=tmp;
	tmp=self.m[2]; self.m[2]=self.m[6]; self.m[6]=tmp;
	tmp=self.m[5]; self.m[5]=self.m[7]; self.m[7]=tmp;
	return self
end

function THREE.Matrix3:transposeIntoArray(r)
	r[0] = self.m[0];
	r[1] = self.m[3];
	r[2] = self.m[6];
	r[3] = self.m[1];
	r[4] = self.m[4];
	r[5] = self.m[7];
	r[6] = self.m[2];
	r[7] = self.m[5];
	r[8] = self.m[8];
	return self
end


