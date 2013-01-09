
text = "This is a sample message. This is a sample message. This is a sample message. This is a sample message. This is a sample message. "

screen:show()


t1 = WL.ToastAlert()

t2 = WL.ToastAlert{message = text,icon = "ToastAlert/load-error.png",x = 1000}
t3 = WL.ToastAlert{message = text,icon = "ToastAlert/load-error.png",x =  500, h =120}
t4 = WL.ToastAlert{style = false,message = text,icon = "ToastAlert/load-error.png",x = 1500, message_font = "Sans 30px",message_color="00ff00"}
t4.style.border.colors.default = "00ff00"


print(t1:to_json())
print(t2:to_json())
print(t3:to_json())
print(t4:to_json())

screen:add(t1,t2,t3,t4)

