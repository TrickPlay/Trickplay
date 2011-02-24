screen:show()

sun1 = Image{src="test-sun.png",x=300,y=100}
sun2 = Image{src="test-sun.png",x=300,y=100,opacity=127}

sun1:move_anchor_point(sun1.w/2,sun1.h/2)
sun2:move_anchor_point(sun2.w/2,sun2.h/2)

cloud1 = Image{src="test-cloud-3.png",x=100,y=300}
cloud2 = Image{src="test-cloud-2.png",x=100,y=400}
cloud3 = Image{src="test-cloud-1.png",x=sun1.w+20,y=300}

screen:add(sun1,sun2,cloud1,cloud2,cloud3)
tl=Timeline{
	duration=10000,
	loop=true,
}
tl.on_new_frame = function(self,msecs,p)
	sun1.z_rotation={ 30*p,0,0}
	sun2.z_rotation={-30*p,0,0}

	cloud1.x=100 + (sun1.w-100)*p
	cloud2.x=100 + (sun1.w+100)*p
	cloud3.x=sun1.w+20-(sun1.w+50)*p
end


tl:start()

