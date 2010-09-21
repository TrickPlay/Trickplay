
   math.randomseed(os.time())
   
   local texts = {}
   for i=1, 10 do
      local text = Text{
         text="whatever " .. tostring(i),
         font="Sans 30px",
         color="FFFFFF"
      }
      table.insert(texts, text)
   end
   
   screen:add(unpack(texts))
   screen:show()
   
   function screen:on_key_down(k)
   
      for i,text in ipairs(texts) do
         text:complete_animation()
         text:animate{
            duration=math.random(200)+50,
            x=math.random(1920),
            y=math.random(1080),
            opacity=math.random(255),
         }
         text.color = {math.random(128)+127, math.random(128)+127, math.random(128)+127}
      end
   end
   
   
  

