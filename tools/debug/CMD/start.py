import os, sys, re
from connection import *
from discovery import *
from debugger import *
from PyQt4.QtCore import QCoreApplication, QSettings

def main(argv):

	app = QCoreApplication(argv)
	discovery = TrickplayDiscovery()
	debugger = CLDebuger()

	try:

		debugger.start(discovery)
		sys.exit(app.exec_())

	except (KeyboardInterrupt, EOFError):

		debugger.disconnect()

if __name__ == '__main__':
	main(sys.argv)

