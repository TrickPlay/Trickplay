
s1 = WL.ScrollPane()
s1:add(Rectangle{w=1000,h=1000,color="ffff00"},Rectangle{w=100,h=100,color="ff0000"},Rectangle{x = 300,y=300,w=100,h=100,color="00ff00"})
s2 = WL.ScrollPane{slider_thickness = 200,pane_h = 700,x = 600}
s2:add(Rectangle{w=1000,h=1000,color="ffff00"},Rectangle{w=100,h=100,color="ff0000"},Rectangle{x = 300,y=300,w=100,h=100,color="00ff00"})
screen:add(s1,s2)

screen.reactive = true