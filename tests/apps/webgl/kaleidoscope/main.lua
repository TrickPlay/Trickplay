--[[

	p=g.createProgram();
	function $(i,z) {
		s=g.createShader(i);
		g.shaderSource(s,z);
		g.compileShader(s);
		g.attachShader(p,s)
	}
	$(35633,"attribute vec3 v;void main(){gl_Position=vec4(v,1.);}");
	$(35632,"precision highp float;uniform float t;uniform vec2 r;void main(){vec3 col;float l,z=t;for(int i=0;i<3;i++){vec2 uv,p=gl_FragCoord.xy/r;uv=p;p-=.5;p.x*=r.x/r.y;z+=.07,l=length(p),uv+=p/l*(sin(z)+1.)*abs(sin(l*9.-z*2.)),col[i]=.01/length(abs(mod(uv,1.)-.5));}gl_FragColor=vec4(col/l,t);}");
	g.linkProgram(p);
	g.useProgram(p);
	(window.onresize=function(){
		w=b.width=innerWidth;
		h=b.height=innerHeight;
		g.viewport(0,0,w,h);
		g.uniform2f(g.getUniformLocation(p,"r"),w,h)
	})();
	g.enableVertexAttribArray(v=g.getAttribLocation(p,"v"));
	g.bindBuffer(n=34962,g.createBuffer());
	g.bufferData(n,new Float32Array([1,1,0,u=-1,1,0,1,u,0,u,u,0]),35044);
	s=new t;
	setInterval('g.uniform1f(g.getUniformLocation(p,"t"),(new t-s)/1e3);g.vertexAttribPointer(v,3,5126,0,0,0);g.drawArrays(5,0,4)',0)

]]--

local gl = WebGLCanvas{ size = screen.size }

screen:add( gl )

local function initGL()
    p = gl:createProgram()

    local function make_shader(i,z)
        local s = gl:createShader(i)
        gl:shaderSource(s,z)
        gl:compileShader(s)
        if( gl:getShaderParameter( s , gl.COMPILE_STATUS ) ) then
            print("compiled OK")
        else
            print("compile failed:",gl:getShaderInfoLog(s))
        end
        gl:attachShader(p,s)
    end

    print("Vertex shader")
    make_shader(gl.VERTEX_SHADER,readfile("kaleidoscope.vertex"))
    print("Fragment shader")
    make_shader(gl.FRAGMENT_SHADER,readfile("kaleidoscope.fragment"))
    gl:linkProgram(p)
    assert(gl:getProgramParameter( p , gl.LINK_STATUS ))
    gl:useProgram(p)

   v = gl:getAttribLocation( p , "v" )
   gl:enableVertexAttribArray( v )


   b = gl:createBuffer()
   gl:bindBuffer(gl.ARRAY_BUFFER, b)
   gl:bufferData(gl.ARRAY_BUFFER, Float32Array({1,1,0,-1,1,0,1,-1,0,-1,-1,0}), gl.STATIC_DRAW)
   gl:viewport(0,0,screen.width,screen.height)
   gl:uniform2f(gl:getUniformLocation(p,"r"),screen.width,screen.height)

end

local function drawScene(s)
    gl:uniform1f(gl:getUniformLocation(p,"t"),s)
    gl:vertexAttribPointer(v,3,gl.FLOAT,0,0,0)
    gl:drawArrays(5,0,4)
end

gl:acquire()
initGL()
gl:release()
print( "READY" )

local frames = 0
local t = Stopwatch()
local s = Stopwatch()
  s:start()
function idle.on_idle()
  gl:acquire()
  drawScene(s.elapsed_seconds)
  gl:release()

  frames = frames + 1
  if t.elapsed_seconds >= 1 then
     print( string.format( "%d fps" , frames / t.elapsed_seconds ) )
     frames = 0
     t:start()
  end
end

screen:show()
