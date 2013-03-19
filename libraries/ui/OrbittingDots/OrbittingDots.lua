
local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local canvas_dot = function(self)
	--[[
	local c = Canvas(self.dot_size,self.dot_size)

	c.line_width = self.style.border.width

	local c1 = self.style.border.colors.default
	local c2 = self.style.fill_colors.default
	c:arc(c.w/2,c.h/2,c.w/2 - c.line_width/2,0,360)
	c:set_source_color(c2)
	c:fill(true)
	c:set_source_color(c1)
	c:stroke()

	--]]
	return Sprite{w=self.dot_size,h=self.dot_size,sheet = self.style.spritesheet,id="OrbitingDots/icon.png"}--c:Image()

end

local default_parameters = {w = 100, h = 100, num_dots = 12}

OrbittingDots = setmetatable(
    {},
    {
        __index = function(self,k)

            return getmetatable(self)[k]

        end,
        __call = function(self,p)

            return self:declare():set(p or {})

        end,
        subscriptions = {
        },
        public = {
            properties = {
                image = function(instance,_ENV)
                    return function(oldf) return image     end,
                    function(oldf,self,v)
                        if type(v) == "string" then

                            if image == nil or image == false or image.src ~= v then

                                setup_image(Image{ src = v })

                            end

                        elseif type(v) == "userdata" and v.__types__.actor then

                            if v ~= image then

                                setup_image(v)

                            end

                        elseif v == nil then

                            if not canvas then

                                flag_for_redraw = true

                                return

                            end

                        else

                            error("OrbittingDots.image expected type 'table'. Received "..type(v),2)

                        end

                    end
                end,
                animating = function(instance,_ENV)
                    return function(oldf) return animating     end,
                    function(oldf,self,v)

                        if type(v) ~= "boolean" then

                            error("OrbittingDots.animating expects type boolean. Received "..type(v),2)

                        elseif animating == v then

                            return

                        end

                        animating = v

                        if animating then
                            start_animation = true
                        else
                            stop_animation = true
                        end
                    end
                end,
                w = function(instance,_ENV)
                    return function(oldf) return w     end,
                    function(oldf,self,v) reposition = true w = v end
                end,
                width = function(instance,_ENV)
                    return function(oldf) return w     end,
                    function(oldf,self,v) reposition = true w = v end
                end,
                h = function(instance,_ENV)
                    return function(oldf) return h     end,
                    function(oldf,self,v) reposition = true h = v end
                end,
                height = function(instance,_ENV)
                    return function(oldf) return h     end,
                    function(oldf,self,v) reposition = true h = v end
                end,
                size = function(instance,_ENV)
                    return function(oldf) return {w,h}     end,
                    function(oldf,self,v)
                        reposition = true
                        w = v[1]
                        h = v[2]
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function() return "OrbittingDots" end
                end,
                dot_size = function(instance,_ENV)
                    return function(oldf) return dot_size     end,
                    function(oldf,self,v)

                        size_is_set = true

                        dot_size = v

                        reanchor_clones()
                    end
                end,
                num_dots = function(instance,_ENV)
                    return function(oldf) return num     end,
                    function(oldf,self,v)
                        if v == num then return end

                        --if new number is smaller than the previous number
                        if num > v then

                            --toss the excess
                            for i = num,v+1,-1 do
                                clones[i]:unparent()
                                clones[i] = nil
                            end

                        --if new number is larger than the previous number
                        else

                            --add more
                            for i = num+1,v do
                                clones[i] = Clone{
                                    source       = image,
                                    anchor_point = {dot_size/2,dot_size/2},
                                    w            = dot_size,
                                    h            = dot_size,
                                }
                                add( instance, clones[i])
                            end

                        end

                        num = v

                        reposition_clones()

                    end
                end,
                duration = function(instance,_ENV)
                    return function(oldf) return load_timeline.duration     end,
                    function(oldf,self,v)
                        load_timeline.duration = v
                    end
                end,
                duration = function(instance,_ENV)
                    return function(oldf) return load_timeline.duration     end,
                    function(oldf,self,v)
                        load_timeline.duration = v
                    end
                end,
                attributes = function(instance,_ENV)
                    return function(oldf,self)
                        local t = oldf(self)

                        t.animating = self.animating
                        t.duration = self.duration
                        t.num_dots = instance.num_dots
                        t.dot_size = instance.dot_size

                        if (not canvas) and image.src and image.src ~= "[canvas]" then

                            t.image = image.src

                        end
                        t.type = "OrbittingDots"

                        return t
                    end
                end,

            },
            functions = {
            },
        },
        private = {
            reanchor_clones = function(instance,_ENV)
                local rad
                return function()
                    for i,d in ipairs(clones) do
                        d:set{
                            anchor_point = {dot_size/2,dot_size/2},
                            w            =  dot_size,
                            h            =  dot_size,
                        }
                    end

                end
            end,
            reposition_clones = function(instance,_ENV)
                local rad
                return function()
                    for i,d in ipairs(clones) do
                        --they're radial position
                        rad = (2*math.pi)/(num) * i

                        clones[i].position = {
                            math.floor( instance.w/2 * math.cos(rad) )+instance.w/2+dot_size/2,
                            math.floor( instance.h/2 * math.sin(rad) )+instance.h/2+dot_size/2
                        }

                    end
                end
            end,
            make_canvas = function(instance,_ENV)
                return function()

                    canvas = true

                    if image then image:unparent() end

                    image = canvas_dot(instance)

                    add( instance, image )

                    image:hide()

                    for i,d in ipairs(clones) do d.source = image end

                    return true
                end
            end,
            resize_images = function(instance,_ENV)
                return function()
                    if not size_is_set then return end

                    image.w = instance.w
                    image.h = instance.h
                end
            end,
            setup_image = function(instance,_ENV)
                return function(v)

                    canvas = false

                    if image then image:unparent() end

                    image = v

                    add( instance, v )

                    v:hide()

                    for i,d in ipairs(clones) do d.source = image end

                    if not instance.is_size_set() then

                        instance.dot_size = image.w

                        instance:reset_size_flag()

                    end

                    return true
                end
            end,
            update = function(instance,_ENV)
                return function()
                    if flag_for_redraw then
                        flag_for_redraw = false
                        if canvas then
                            make_canvas()
                        else
                            resize_images()
                        end
                    end
                    if reposition then
                        reposition = false
                        reposition_clones()
                    end
                    if reanimate then
                        reanimate = false

                        stop_animation = true
                        start_animation = true

                    end
                    if  stop_animation then
                        stop_animation = false
                        load_timeline:stop()
                    end
                    if start_animation then
                        start_animation = false
                        load_timeline:start()

                    end
                end
            end,
        },
        declare = function(self,parameters)

            parameters = parameters or {}

            local instance, _ENV = Widget()

            duration  = 1000
            image     = false
            animating = false

            dot_size = 20
            num = 0
            clones = {}
            canvas = true
            flag_for_redraw = true
            load_timeline = Timeline{
                loop =  true,
                on_new_frame = function(tl,ms,p)

                    for i,d in ipairs(clones) do
                        d.opacity = 255*((1-p)-i/num)
                    end
                end
            }
            reposition = true
            w = 1
            h = 1
            style_flags = {
                border      = "flag_for_redraw",
                fill_colors = "flag_for_redraw",
            }

            setup_object(self,instance,_ENV)

            updating = true
            instance:set(parameters)
            updating = false

            return instance, _ENV

        end
    }
)
external.OrbittingDots = OrbittingDots
