HumanPlayer = Class(nil,function(self,...)
   self.isHuman = true
end)

ComputerPlayer = Class(nil,function(self,...)
   self.isHuman = false
end)