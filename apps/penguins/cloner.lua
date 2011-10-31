local _Clone = Clone
local _Image = Image
--local cubes = {Image{src = "assets/images/cube-128.png"},
--        Image{src = "assets/images/cube-128-2.png"},
--        Image{src = "assets/images/cube-128-3.png"}}
local srcs = {}--["assets/images/cube-128.png"] = cubes[1],
            --["assets/images/cube-128-2.png"] = cubes[2],
            --["assets/images/cube-128-3.png"] = cubes[3]}
local group = Group()
--group:add(cubes[1],cubes[2],cubes[3])
group:hide()
screen:add(group)

Clone = function(i)
	while i.source.source do
		i.source = i.source.source
	end
    --if i.source.src == "assets/images/cube-128.png" then
    --    i.source = cubes[rand(3)]
    --end
	return _Clone(i)
end

Image = function(i)
	if not srcs[i.src] then 
		srcs[i.src] = _Image(i)
		group:add(srcs[i.src])
	end
	i.source = srcs[i.src]
	return _Clone(i)
end