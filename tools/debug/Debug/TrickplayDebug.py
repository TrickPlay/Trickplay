import re

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from UI.Debugger import Ui_TrickplayDebugger
from UI.Backtrace import Ui_TrickplayBacktrace
from connection import *


class TrickplayDebugger(QWidget):
    
    def __init__(self, main=None, parent = None, f = 0):
        QWidget.__init__(self, parent)
        
        self.main = main
        self.deviceManager = None
        self.ui = Ui_TrickplayDebugger()
        self.ui.setupUi(self)

        self.headers = ["Name","Value","Type"]
        self.ui.localTable.setSortingEnabled(False)
        self.ui.localTable.setColumnCount(len(self.headers))
        self.ui.localTable.setHorizontalHeaderLabels(self.headers)
        self.ui.localTable.verticalHeader().setDefaultSectionSize(18)

        self.ui.breakTable.setSortingEnabled(False)
        self.ui.breakTable.setColumnCount(1)
        self.ui.breakTable.verticalHeader().setDefaultSectionSize(18)
        self.ui.breakTable.popupMenu = QMenu(self.ui.breakTable)
        self.ui.breakTable.popupMenu.addAction ('Delete', self.deleteBP)

        self.ui.breakTable.setContextMenuPolicy(Qt.CustomContextMenu)
        self.connect(self.ui.breakTable, SIGNAL('customContextMenuRequested(QPoint)'), self.contextMenu)
        self.connect(self.ui.breakTable, SIGNAL("cellClicked(int, int)"), self.cellClicked)

        self.break_info = {}

        self.font = self.main.preference.vFont
        #self.font.setStyleHint(self.font.Monospace)
        #self.font.setFamily('Inconsolata')
        #self.font.setPointSize(12)

    def contextMenu(self, point=None):
        self.ui.breakTable.popupMenu.exec_( self.ui.breakTable.mapToGlobal(point) )
    
    def deleteBP(self):
        index = 0 
        for item in  self.ui.breakTable.selectedIndexes():
            index = item.row() 
            r= item.row()
            c= item.column()

        if self.deviceManager is None:
            self.deviceManager = self.main.deviceManager

        cellItem= self.ui.breakTable.item(index, 0) 
        fileLine = cellItem.whatsThis()
        n = re.search(":", fileLine).end()
        fileName = str(fileLine[:n-1])

        if fileName.startswith("/"):
            fileName = fileName[1:]

        lineNum = int(fileLine[n:]) - 1

        fileName = os.path.join(self.deviceManager.path(), fileName)
        self.editorManager.newEditor(fileName, None, lineNum)
        editor = self.editorManager.currentEditor 
        editor.margin_nline = lineNum

        if self.deviceManager.debug_mode == True:
	    self.deviceManager.send_debugger_command(DBG_CMD_DELETE+" %s"%str(index))
        else:
            if editor.current_line != lineNum :
                editor.markerDelete(lineNum, -1)
            else :
                editor.markerDelete(lineNum, -1)
    	        editor.markerAdd(lineNum, editor.ARROW_MARKER_NUM)
            editor.line_click[lineNum] = 0

        self.editorManager.bp_info[1].pop(index)
        self.editorManager.bp_info[2].pop(index)

        self.ui.breakTable.removeRow(r)

    def cellClicked(self, r, c):
		if self.deviceManager is None:
		    self.deviceManager = self.main.deviceManager

		cellItem= self.ui.breakTable.item(r, 0) 
		cellItemState = cellItem.checkState()  
		fileLine = cellItem.whatsThis()

		n = re.search(":", fileLine).end()
		fileName = str(fileLine[:n-1])
		if fileName.startswith("/"):
		    fileName = fileName[1:]
		lineNum = int(fileLine[n:]) - 1

		fileName = os.path.join(self.deviceManager.path(), fileName)
		self.editorManager.newEditor(fileName, None, lineNum)
		editor = self.editorManager.currentEditor 
		editor.margin_nline = lineNum
		
		m = 0
		for item in self.break_info[1]:
			if m == r :
				itemState = item
				break
			m += 1

        
		if itemState == "on" and cellItemState == Qt.Unchecked:
			if self.deviceManager.debug_mode == True:
			    self.deviceManager.send_debugger_command(DBG_CMD_BREAKPOINT+" %s"%str(r)+" off")
			else:
			    if editor.current_line != lineNum :
			        editor.markerDelete(lineNum, editor.ACTIVE_BREAK_MARKER_NUM)
			        editor.markerAdd(lineNum, editor.DEACTIVE_BREAK_MARKER_NUM)
			    else :
			        editor.markerDelete(lineNum, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
			        editor.markerAdd(lineNum, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
			    editor.line_click[lineNum] = 2

			self.editorManager.bp_info[1].pop(r)
			self.editorManager.bp_info[1].insert(r, "off")

		elif itemState == "off" and cellItemState == Qt.Checked:
			if self.deviceManager.debug_mode == True:
			    self.deviceManager.send_debugger_command(DBG_CMD_BREAKPOINT+" %s"%str(r)+" on")
			else:
			    if editor.current_line != lineNum :
			        editor.markerDelete(lineNum, editor.DEACTIVE_BREAK_MARKER_NUM)
			        editor.markerAdd(lineNum, editor.ACTIVE_BREAK_MARKER_NUM)
			    else :
			        editor.markerDelete(lineNum, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
			        editor.markerAdd(lineNum, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
			    editor.line_click[lineNum] = 1

			self.editorManager.bp_info[1].pop(r)
			self.editorManager.bp_info[1].insert(r, "on")

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
					newitem.setFont(self.font)
					if item == "on":
						newitem.setCheckState(Qt.Checked)
					else :
						newitem.setCheckState(Qt.Unchecked)
					self.ui.breakTable.setItem(m, n, newitem)
				elif key == 2:
					newitem= self.ui.breakTable.item(m,0)
					newitem.setText(item)
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
				newitem.setFont(self.font)
				if n == 1 :  
				    self.ui.localTable.setItem(m, n+1, newitem)
				elif n == 2 :  
				    self.ui.localTable.setItem(m, n-1, newitem)
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

        self.font = QFont()
        self.font.setStyleHint(self.font.Monospace)
        self.font.setFamily('Inconsolata')
        self.font.setPointSize(12)


    def cellClicked(self, r, c):
		cellItem= self.ui.traceTable.item(r, 0) 
		fileLine = cellItem.whatsThis()
		n = re.search(":", fileLine).end()
		fileName = fileLine[:n-1]
		lineNum = int(fileLine[n:])

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
					newitem.setFont(self.font)
					newitem.setText(item)
					vh = self.ui.traceTable.verticalHeader()
					vh.setDefaultSectionSize(18)
					self.ui.traceTable.setItem(m, n, newitem)
				elif key == 2:
					newitem= self.ui.traceTable.item(m,0)
					newitem.setWhatsThis(item)
				else:
					pass
				m += 1
			n += 1
		self.ui.traceTable.show()

