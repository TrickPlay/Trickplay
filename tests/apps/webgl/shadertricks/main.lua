local gl = WebGLCanvas{ size = screen.size }

screen:add( gl )

program = nil

local function make_shader(i,z)
    local s = gl:createShader(i)
    gl:shaderSource(s,z)
    gl:compileShader(s)
    if( gl:getShaderParameter( s , gl.COMPILE_STATUS ) ) then
        print("compiled OK")
    else
        print("compile failed:",gl:getShaderInfoLog(s))
    end
    gl:attachShader(program,s)
    gl:deleteShader(s)
end

-- http://www.iquilezles.org/apps/shadertoy/
local shaders = { "monjori", "metablob", "heart", "flower", "julia", "mandelbrot", "kaleidoscope", "plasma", "disco", "clod", "ribbon", "704",  }
local current_shader = #shaders
local function next_shader()
    if(program) then
        gl:deleteProgram(program)
    end
    program = gl:createProgram()
    current_shader = (current_shader % #shaders)+1
    print("Loading shader ",current_shader)
    make_shader(gl.VERTEX_SHADER,readfile("generic.vertex"))
    make_shader(gl.FRAGMENT_SHADER,readfile(shaders[current_shader]..".fragment"))
    gl:linkProgram(program)
    assert(gl:getProgramParameter( program , gl.LINK_STATUS ))
    gl:useProgram(program)

   v = gl:getAttribLocation( program , "v" )
   gl:enableVertexAttribArray( v )
   gl:uniform2f(gl:getUniformLocation(program,"resolution"),screen.width,screen.height)
end

local function initGL()
   next_shader()

   b = gl:createBuffer()
   gl:bindBuffer(gl.ARRAY_BUFFER, b)
   gl:bufferData(gl.ARRAY_BUFFER, Float32Array({1,1,0,-1,1,0,1,-1,0,-1,-1,0}), gl.STATIC_DRAW)
   gl:viewport(0,0,screen.width,screen.height)
end

local function drawScene(s)
    gl:uniform1f(gl:getUniformLocation(program,"time"),s)
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

function screen:on_key_down()
    gl:acquire()
    next_shader()
    gl:release()
end

screen:show()
