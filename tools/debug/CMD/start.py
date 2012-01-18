import os, sys, re, signal
from connection import *
from discovery import *
from debugger import *
from PyQt4.QtCore import QCoreApplication, QSettings

signal.signal(signal.SIGINT, signal.SIG_DFL)

def main(argv):

	app = QCoreApplication(argv)
	discovery = TrickplayDiscovery()
	debugger = CLDebuger()

	try:
		debugger.start(discovery) 

	except (KeyboardInterrupt, EOFError):
		sys.exit()

if __name__ == '__main__':
	main(sys.argv)

