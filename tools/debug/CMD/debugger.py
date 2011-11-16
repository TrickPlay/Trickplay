import sys, re
from connection import *
from discovery import *

	
class CLDebuger():

	def __init__(self):
	
		self.device_name = ""
		self.debug_port = ""

	def start(self, discovery):

		command_list = ['bn', 'r', 'w', 'l', 'bt', 'q', 'c', 's', 'n', 'a' ]
		command_list_b = ['bn', 'r', 'w', 'l', 'bt', 'q', 'c', 's', 'n', 'b', 'a', 'f', 'd' ]

		while 1:

			data = None
			cmd = None
			arg = None
			command = raw_input("(db) ")

			m = re.match('\s*(\w+)\s+(\S+)\s*', command)

			if m:
				cmd = m.group(1)
				arg = m.group(2)
		
			if re.search('ld', command):

				for k in discovery.devices:
					if self.device_name == k:
						print '\t'+k+":"+discovery.devices[k][0]+":"+discovery.devices[k][1]+" (connected)"
					else:
						print '\t'+k+":"+discovery.devices[k][0]+":"+discovery.devices[k][1]

			elif re.search('help', command):

				print '\t'+'help is not ready. '

			elif re.search('quit', command) or re.search('exit', command):

				self.disconnect()
				sys.exit()

			elif re.search('cn',command) or re.search('connect',command): 

				if CON.get() != ":":

					print '\t'+'The debugger is connected to '+self.device_name+":"+CON.get()
					print '\t'+'Try \'q\' command to quit the current debugging app'

				else:

					if not arg:
						
						print "\tArgument required.(device name)"
						print '\t'+'Try ld" to get a list of available remote devices.'

					elif not arg in discovery.devices:
						
						print '\t'+re.search('\w+', re.search('\s\w+', command).group()).group()+' is not available.'
						print '\t'+'Try "ld" to get a list of available remote devices.'

					else:
						self.device_name = arg
						discovery.service_selected(self.device_name)
						self.debug_port = str(getTrickplayDebug()['port'])
						data = sendTrickplayDebugCommand(self.debug_port, "bn", True)

			elif command != "":

				if not arg :
					if re.search('\s*\w+\s*', command):
						command = re.search('\w+', command).group()
						if not command in command_list_b : 
							print '\t'+'Undefined command: '+command+'. '+'Try \"help\".'
						elif ( re.search('d', command) or re.search('f', command) ) :
							print "\tArgument required."
							if re.search('d', command): 
								print "\tTry \"d\" <breakpoint index> or \"d\" all."
							elif re.search('f', command):
								print "\tTry \"f\" <file name>."
						elif CON.get() == ":":
							print '\t'+'Please connect the debugger to a remote device to send debug command.'
							print '\t'+'Try "connect" or "cn" followed by device name.'
							print '\t'+'Try "ld" to get a list of available remote devices.'
						else:
							data = sendTrickplayDebugCommand(self.debug_port, command, False)
				elif arg : 
					if cmd in command_list : 
						print '\t'+cmd+' does not require argument'
					elif not cmd in ['b', 'd', 'f']:
						print '\t'+'Undefined command: '+cmd+'. '+'Try \"help\".'
					elif CON.get() == ":":
						print '\t'+'Please connect the debugger to a remote device to send debug command.'
						print '\t'+'Try "connect" or "cn" followed by device name.'
						print '\t'+'Try "ld" to get a list of available remote devices.'
					else: 
						data = sendTrickplayDebugCommand(self.debug_port, cmd+' '+arg, False)

			if data:

				self.printResp(data, command)

				if command == 'q':
					CON.set("", "")
					self.device_name = ""
					self.debug_port = ""
				elif command == 'r' or command == 'c':
					self.printResp(sendTrickplayDebugCommand(self.debug_port, "bn", True), "bn")
				
	def disconnect(self):

		if CON.get() != ":":
			sendTrickplayDebugCommand(self.debug_port, 'q', False)

	def printResp(self, data, command):

		pdata = json.loads(data)

		file_name = pdata["file"] 
		tp_id = pdata["id"] 
		line_num = pdata["line"]

		if "locals" in pdata:
			local_vars = ""
			for c in pdata["locals"]:
				if c["name"] != "(*temporary)":
					c_v = None
					if local_vars != "":
						local_vars = local_vars+"\n\t"

					local_vars = local_vars+str(c["name"])+"("+str(c["type"])+")"
					try:
						c_v = c["value"]	
					except KeyError: 
						pass

					if c_v:
						local_vars = local_vars+" = "+str(c["value"])

			print "\t"+local_vars
			print "\t"+"Break at "+file_name+":"+str(line_num)

		elif "error" in pdata:
			print "\t"+pdata["error"] 
		
		elif "stack" in pdata:
			stack_info = ""
			index = 0
			for s in pdata["stack"]:
				if "file" in s and "line" in s:
					stack_info = stack_info+"["+str(index)+"] "+s["file"]+":"+str(s["line"])+"\n\t"
					index = index + 1
			print "\t"+stack_info

		elif "breakpoints" in pdata:
			breakpoints_info = ""
			index = 0
			if len(pdata["breakpoints"]) == 0:
				print "\t"+"No breakpoints set"
			else:
				for b in pdata["breakpoints"]:
					if "file" in b and "line" in b:
						breakpoints_info = breakpoints_info+"["+str(index)+"] "+b["file"]+":"+str(b["line"])+"\n\t"
						index = index + 1

			print "\t"+breakpoints_info
		
		elif "source" in pdata:
			source_info = ""
			for l in pdata["source"]:
				if "line" in l and "text" in l:
					if l["line"] == line_num:
						source_info = source_info+str(l["line"])+" >>"+str(l["text"])+"\n\t"
					else:
						source_info = source_info+str(l["line"])+"   "+str(l["text"])+"\n\t"
			print "\t"+source_info
		
		elif "lines" in pdata:
			fetched_lines = ""
			
			for l in pdata["lines"]:
				fetched_lines = fetched_lines+l+"\n\t"
			print "\t"+fetched_lines

		elif "app" in pdata:
			app_info = ""
			for key in pdata["app"].keys():
				if key != "contents":
					app_info = app_info+str(key)+" : "+str(pdata["app"][key])+"\n\t"
				else:
					app_info = app_info+key+" : "
					for c in pdata["app"]["contents"]:
						app_info = app_info + str(c) + ","
					app_info = app_info+"\n\t"					
			print "\t"+app_info

		if command in ['n','s','bn']:
			print "\t"+"Break at "+file_name+":"+str(line_num)



