gl=WebGLCanvas{size=screen.size}
screen:add(gl)

dofile("THREE/src/THREE.lua")

--debug = true

p = function (...)
	print(...)
	print("\n\n\n")
end


function render()
	gl:acquire()
	gl:clearColor(.2,.2,.2,1)
	gl:clear(gl.COLOR_BUFFER_BIT)
	camera.position.x = cx;
	camera.position.y = cy;
	camera.position.z = cz;
	--cameraLight.position.x = cx;
	--cameraLight.position.y = cy;
	--cameraLight.position.z = cz;
	sphere.position.x = p1x
	sphere.position.y = p1y
	sphere.position.z = p1z
	renderer:render( scene, camera )
	--renderer._projScreenMatrix:print()
	gl:release()
end

function init()
	gl:acquire()
	cx = 0
	cy = 400
	cz = 1000
	scene = THREE.Scene();
	print(scene,getmetatable(scene))
	camera = THREE.Camera{fov=45, aspect=screen.display_size[1] / screen.display_size[2], near=1, far=10000 };

	--camera.target = 

	makeSun()
	--makePlanets(3, 200, 1000, 1, .1)
	sphere = makeSphere(0,0,0,30,0xffffff)
    
    board = THREE.Object3D();
	base   = makeCube(0,0,0,700,15,700,0xe5aa70)--makeSphere(0,0,0,30)
	wall_f   = makeCube(0,0,0,700,40,15,0x964b00)--makeSphere(0,0,0,30)
	wall_b   = makeCube(0,0,0,700,40,15,0x964b00)--makeSphere(0,0,0,30)
	wall_r   = makeCube(0,0,0,15,40,700,0x964b00)--makeSphere(0,0,0,30)
	wall_l   = makeCube(0,0,0,15,40,700,0x964b00)--makeSphere(0,0,0,30)
    wall_f.position.z = -350
    wall_b.position.z =  350
    wall_r.position.x =  350
    wall_l.position.x = -350
    base.position.y   =  -20
    ---[[
    print(1)
	board:addChild(wall_f)
    print(2)
	board:addChild(wall_r)
	board:addChild(wall_l)
	board:addChild(wall_b)
	board:addChild(base)
    --]]
    scene:addObject(sphere)
    print(4)
	scene:addObject(board)
    print(5)
	

	renderer = THREE.WebGLRenderer();
	renderer:setSize(screen.size[1],screen.size[2])
	gl:release()
end

function makeSun()

    local corner_dist = 800
    local height      = 1200

	pointLight1 = THREE.PointLight( 0xffffff, .3 )
	pointLight1.position.y=corner_dist
	pointLight1.position.x=corner_dist
	pointLight1.position.z=height

	pointLight2 = THREE.PointLight( 0xffffff, .3 )
	pointLight2.position.y=-corner_dist
	pointLight2.position.x=corner_dist
	pointLight2.position.z=height
    
    pointLight3 = THREE.PointLight( 0xffffff, .3 )
	pointLight3.position.y=corner_dist
	pointLight3.position.x=-corner_dist
	pointLight3.position.z=height
    
    pointLight4 = THREE.PointLight( 0xffffff, .3 )
	pointLight4.position.y=-corner_dist
	pointLight4.position.x=-corner_dist
	pointLight4.position.z=height
    
	--dLight = THREE.DirectionalLight(0xffffff, 1)
	--scene:addLight(pointLight1)
    --dumptable(scene)
    --print(rawget(scene,addLight))
    scene:addLight(pointLight1)
    scene:addLight(pointLight2)
    scene:addLight(pointLight3)
    scene:addLight(pointLight4)
	--scene:addLight(dLight)
end

function makePlanets(numP, minR, maxR, minV, maxV)
	numP=3
	p={}
	for i=1,numP do
		p[i]={}
		local pi=p[i]
		local initAngle = 2*math.random()*math.pi
		pi.orbitMatrix = Three.Matrix4()
		pi.pathRadius = minR+math.random()*(maxR-minR)
		pi.pos = Vector4(pi.pathRadius*math.cos(initAngle), 0, pi.PathRadius*math.sin(initAngle), 1)
		pi.orbitMatrix:multiplyVector4(pi.pos)
		pi.obj = makeSphere(p1x,p2y,p3z, RRRRR)
		scene:addObject(p1)
	end
end


function makeSphere(x,y,z,r,c)
	local geometry = THREE.SphereGeometry( r, 15, 15);
	materials = {};
	for i = 0,length(geometry.faces)-1 do
		local face = geometry.faces[i]
		face.material = {[0]=THREE.MeshLambertMaterial{ color= c, shading= THREE.SmoothShading } }
	end
	local sphere = THREE.Mesh(geometry, THREE.MeshLambertMaterial{ color= c, shading= THREE.SmoothShading })
	return sphere
end

function makeCube(x,y,z,w,h,d,c)
	local geometry = THREE.CubeGeometry( w,h,d,20,4,20);
    
	materials = {};
	for i = 0,length(geometry.faces)-1 do
		local face = geometry.faces[i]
		face.material = {[0]=THREE.MeshLambertMaterial{ color= c, shading= THREE.SmoothShading } }
	end
	local cube = THREE.Mesh(geometry, THREE.MeshLambertMaterial{ color= c, shading= THREE.SmoothShading })
	return cube
end

function screen:on_key_down(k)
	local i =10
	if (k==119) then --w
		cz=cz-i
	elseif (k==115) then --s
		cz=cz+i
	elseif (k==97) then --a
		cx=cx-i
	elseif (k==100) then --d
		cx=cx+i
	elseif (k==113) then --q
		cy=cy+i
	elseif (k==101) then --e
		cy=cy-i
	end
end

secs = 0
function idle:on_idle(s)
	rotVel = .5
	sPathRadius = 300
	secs = secs+s
	p1x = sPathRadius*math.cos(secs/2*rotVel*math.pi)
	p1y = 20
	p1z = sPathRadius*math.sin(secs/2*rotVel*math.pi)
	if(secs>.05) then render() end
end


function main()
	screen:show()
	init()
	if (debug) then
		idle.on_idle = nil
		render()
	end
end

main()
