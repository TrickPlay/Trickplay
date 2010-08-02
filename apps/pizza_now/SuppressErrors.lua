local old_assert = assert
function assert(bool, msg)
   if not bool then
      print("\n\n\n\n\n\n\n\n\n\n\n\nASSERTION FAILED MAJORLY:", msg, "\n\n\n\n\n\n\n\n\n\n\n\n")
   end
end
local old_error = error
function error(msg)
   print("\n\n\n\n\n\n\n\n\n\n\n\nERROR ERROR:", msg, "\n\n\n\n\n\n\n\n\n\n\n\n")
end
