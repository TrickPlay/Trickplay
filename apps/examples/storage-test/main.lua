local db = LocalHash()

db:put("Craig","Hughes")
db:put("Pablo","Pissanetzky")

print (db:get("Craig"), db:get("Pablo"))
