import re

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from UI.Debugger import Ui_TrickplayDebugger
from UI.Backtrace import Ui_TrickplayBacktrace
from connection import *

class TrickplayDebugger(QWidget):
    
    def __init__(self, parent = None, f = 0):
        QWidget.__init__(self, parent)
        
        self.ui = Ui_TrickplayDebugger()
        self.ui.setupUi(self)

        self.headers = ["Name","Type","Value"]
        self.ui.localTable.setSortingEnabled(False)
        self.ui.localTable.setColumnCount(len(self.headers))
        self.ui.localTable.setHorizontalHeaderLabels(self.headers)
        self.ui.breakTable.setSortingEnabled(False)
        self.ui.breakTable.setColumnCount(1)
        self.connect(self.ui.breakTable, SIGNAL("cellClicked(int, int)"), self.cellClicked)
        self.break_info = {}


    def cellClicked(self, r, c):
		cellItem= self.ui.breakTable.item(r, 0) 
		cellItemState = cellItem.checkState()  
		#fileLine = cellItem.text()
		fileLine = cellItem.whatsThis()

		n = re.search(":", fileLine).end()
		fileName = fileLine[:n-1]
		lineNum = int(fileLine[n:])-1

		self.editorManager.newEditor(fileName, None, lineNum)
		editor = self.editorManager.currentEditor 
		
		m = 0
		for item in self.break_info[1]:
			if m == r :
				itemState = item
				break
			m += 1

		if itemState == "on" and cellItemState == Qt.Unchecked:
			sendTrickplayDebugCommand("9876", "b "+str(r)+" "+"off", False)
			if editor.current_line != lineNum :
				editor.markerDelete(lineNum, editor.ACTIVE_BREAK_MARKER_NUM)
				editor.markerAdd(lineNum, editor.DEACTIVE_BREAK_MARKER_NUM)
			else :
				editor.markerDelete(lineNum, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
				editor.markerAdd(lineNum, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
			editor.line_click[lineNum] = 2
			data = sendTrickplayDebugCommand("9876", "b",False)
			self.break_info = printResp(data, "b")
		elif itemState == "off" and cellItemState == Qt.Checked:
			sendTrickplayDebugCommand("9876", "b "+str(r)+" "+"on", False)
			if editor.current_line != lineNum :
				editor.markerDelete(lineNum, editor.DEACTIVE_BREAK_MARKER_NUM)
				editor.markerAdd(lineNum, editor.ACTIVE_BREAK_MARKER_NUM)
			else :
				editor.markerDelete(lineNum, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
				editor.markerAdd(lineNum, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
			editor.line_click[lineNum] = 1
			data = sendTrickplayDebugCommand("9876", "b",False)
			self.break_info = printResp(data, "b")
		
    def clearBreakTable(self, row_num=0):
		self.ui.breakTable.clear()
		self.ui.breakTable.setRowCount(row_num)
		
    def populateBreakTable(self, break_info=None, editorManager=None):

		self.break_info = break_info

		self.editorManager = editorManager

		if len(break_info) > 0 :
			self.clearBreakTable(len(break_info[1]))
		else :
			self.clearBreakTable()

		n = 0
		for key in break_info:
			m = 0
			for item in break_info[key]:
				if key == 1:
					newitem = QTableWidgetItem()
					if item == "on":
						newitem.setCheckState(Qt.Checked)
					else :
						newitem.setCheckState(Qt.Unchecked)
					self.ui.breakTable.setItem(m, n, newitem)
				elif key == 2:
					newitem= self.ui.breakTable.item(m,0)
					newitem.setText(item)
				elif key == 3:
					newitem= self.ui.breakTable.item(m,0)
					newitem.setWhatsThis(item)
				else:
					pass
				m += 1
			n += 1
		self.ui.breakTable.show()

    def clearLocalTable(self, row_num=0):
		self.ui.localTable.clear()
		self.ui.localTable.setHorizontalHeaderLabels(self.headers)
		self.ui.localTable.setRowCount(row_num)
		
    def populateLocalTable(self, local_info=None):
		
		self.clearLocalTable(len(local_info[1]))
		n = 0
		for key in local_info:
			m = 0
			for item in local_info[key]:
				newitem = QTableWidgetItem(item)
				self.ui.localTable.setItem(m, n, newitem)
				m += 1
			n += 1
		self.ui.localTable.show()

class TrickplayBacktrace(QWidget):
    
    def __init__(self, parent = None, f = 0):
        QWidget.__init__(self, parent)
        
        self.ui = Ui_TrickplayBacktrace()
        self.ui.setupUi(self)
        self.ui.traceTable.setSortingEnabled(False)
        self.ui.traceTable.setColumnCount(1)
        self.connect(self.ui.traceTable, SIGNAL("cellClicked(int, int)"), self.cellClicked)
        self.stack_info = {}

    def cellClicked(self, r, c):
		cellItem= self.ui.traceTable.item(r, 0) 
		fileLine = cellItem.whatsThis()
		n = re.search(":", fileLine).end()
		fileName = fileLine[:n-1]
		lineNum = int(fileLine[n:])-1

		self.editorManager.newEditor(fileName, None, lineNum)
		editor = self.editorManager.currentEditor 
		
    def clearTraceTable(self, row_num=0):
		self.ui.traceTable.clear()
		self.ui.traceTable.setRowCount(row_num)
		
    def populateTraceTable(self, stack_info=None, editorManager=None):

		self.stack_info = stack_info
		self.editorManager = editorManager

		if len(stack_info) > 0 :
			self.clearTraceTable(len(stack_info[1]))
		else :
			self.clearTraceTable()

		n = 0
		for key in stack_info:
			m = 0
			for item in stack_info[key]:
				if key == 1:
					newitem = QTableWidgetItem()
					newitem.setText(item)
					self.ui.traceTable.setItem(m, n, newitem)
				elif key == 2:
					newitem= self.ui.traceTable.item(m,0)
					newitem.setWhatsThis(item)
				else:
					pass
				m += 1
			n += 1
		self.ui.traceTable.show()

