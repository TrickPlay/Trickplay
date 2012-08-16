import re

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from UI.Debugger import Ui_TrickplayDebugger
from UI.Backtrace import Ui_TrickplayBacktrace
from connection import *

try:
    _fromUtf8 = QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s


class MyTableWidget(QTableWidget):
    def __init__(self, debugger=None, parent=None):

        QTableWidget.__init__(self, parent)
        self.debugger = debugger
    
    def move_cursor(self, key):

        row = self.currentRow()
        col = self.currentColumn()
	
        if key == Qt.Key_Left and col > 0:
            col -= 1

        elif key == Qt.Key_Right and col < self.columnCount():
            col += 1

        elif key == Qt.Key_Up and row > 0:
            row -= 1

        elif key == Qt.Key_Down and row < self.rowCount():
            row += 1

        if not row < self.rowCount() or row < 0:
            return
        
        self.setCurrentCell(row, col)
        self.itemFromIndex(self.currentIndex()).setSelected(True)
        self.r = row
        self.c = col

    def keyPressEvent(self, event):

        if event.key() == Qt.Key_Space:

            for item in  self.selectedIndexes():
                self.r= item.row()
                self.c= item.column()

            self.debugger.cellClicked(self.r, self.c, True)
            self.setCurrentCell(self.r, self.c)
            self.itemFromIndex(self.currentIndex()).setSelected(True)

        elif event.key() == Qt.Key_Backspace:

            for item in  self.selectedIndexes():
                self.r= item.row()
                self.c= item.column()

            self.debugger.deleteBP()

            if hasattr(self, "r") == True and hasattr(self, "c") == True: 
                self.setCurrentCell(self.r, self.c)

                if self.itemFromIndex(self.currentIndex()) is not None:
                    self.itemFromIndex(self.currentIndex()).setSelected(True)

                elif self.rowCount() > 0:
                    self.setCurrentCell(self.rowCount() - 1, 0)

                    if self.itemFromIndex(self.currentIndex()) is not None:
                        self.itemFromIndex(self.currentIndex()).setSelected(True)

        elif event.key() ==  Qt.Key_Left or event.key() ==  Qt.Key_Right or event.key() == Qt.Key_Up or  event.key() == Qt.Key_Down:
            self.move_cursor(event.key())
    
class TrickplayDebugger(QWidget):
    
    def __init__(self, main=None, parent = None, f = 0):
        QWidget.__init__(self, parent)
        
        self.main = main
        self.deviceManager = None
        self.ui = Ui_TrickplayDebugger()
        self.ui.setupUi(self)

        self.headers = ["Name","Value","Type", "Defined"]
        self.local_headers = ["Name","Value","Type"]
        self.ui.localTable.setSortingEnabled(False)
        self.ui.localTable.setColumnCount(len(self.local_headers))
        self.ui.localTable.setHorizontalHeaderLabels(self.local_headers)
        self.ui.localTable.verticalHeader().setDefaultSectionSize(18)
        
        self.ui.globalTable.setSortingEnabled(False)
        self.ui.globalTable.setColumnCount(len(self.headers))
        self.ui.globalTable.setHorizontalHeaderLabels(self.headers)
        self.ui.globalTable.verticalHeader().setDefaultSectionSize(18)

        self.ui.breakTable = MyTableWidget(self, self.ui.Breaks)
        self.ui.breakTable.setObjectName(_fromUtf8("breakTable"))
        self.ui.breakTable.setColumnCount(0)
        self.ui.breakTable.setRowCount(0)
        self.ui.breakTable.horizontalHeader().setVisible(False)
        self.ui.breakTable.horizontalHeader().setStretchLastSection(True)
        self.ui.breakTable.verticalHeader().setVisible(False)
        self.ui.gridLayout_3.addWidget(self.ui.breakTable, 0, 0, 1, 1)

        self.ui.breakTable.setSortingEnabled(False)
        self.ui.breakTable.setColumnCount(1)
        self.ui.breakTable.verticalHeader().setDefaultSectionSize(18)
        self.ui.breakTable.popupMenu = QMenu(self.ui.breakTable)
        self.ui.breakTable.popupMenu.addAction ('Delete', self.deleteBP)

        self.ui.breakTable.setContextMenuPolicy(Qt.CustomContextMenu)
        self.connect(self.ui.breakTable, SIGNAL('customContextMenuRequested(QPoint)'), self.contextMenu)
        self.connect(self.ui.breakTable, SIGNAL("cellClicked(int, int)"), self.cellClicked)
        self.connect(self.ui.localTable, SIGNAL("cellClicked(int, int)"), self.local_cellClicked)
        self.connect(self.ui.globalTable, SIGNAL("cellClicked(int, int)"), self.global_cellClicked)

        self.break_info = {}

        self.font = self.main.preference.vFont

    def contextMenu(self, point=None):
        self.ui.breakTable.popupMenu.exec_( self.ui.breakTable.mapToGlobal(point) )
    
    def deleteBP(self):
        index = 0 
        for item in  self.ui.breakTable.selectedIndexes():
            index = item.row() 

        if self.deviceManager is None:
            self.deviceManager = self.main.deviceManager

        cellItem= self.ui.breakTable.item(index, 0) 
        if cellItem is None:
            return

        fileLine = cellItem.whatsThis()
        n = re.search(":", fileLine).end()
        fileName = str(fileLine[:n-1])

        if fileName.startswith("/"):
            fileName = fileName[1:]
        elif fileName.endswith("/"):
            fileName = fileName[:len(fileName) -1]

        lineNum = int(fileLine[n:]) - 1

        fileName = os.path.join(self.deviceManager.path(), fileName)
        self.editorManager.newEditor(fileName, None, lineNum)
        editor = self.editorManager.currentEditor 
        if editor.starMark is True :
            editor.if_star_mark_exist("delete")
            return

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

        self.ui.breakTable.removeRow(index)
    
    def local_cellClicked(self, r, c, space=False):
        pass
        #cellItem= self.ui.localTable.item(r, 0) 
        #search_res = self.editorManager.tab.editors[index].findFirst(expr,re,cs,wo,wrap,forward)

        #print cellItem.text()

    def global_cellClicked(self, r, c, space=False):
        cellItem= self.ui.globalTable.item(r, 0) 
        print cellItem.text(), r 

        if self.deviceManager is None:
            self.deviceManager = self.main.deviceManager

        print self.global_info[4][r]
        fileLine = self.global_info[4][r]

        n = re.search(":", fileLine).end()
        fileName = str(fileLine[:n-1])
        if fileName.startswith("/"):
            fileName = fileName[1:]
        elif fileName.endswith("/"):
            fileName= fileName[:len(fileName) - 1]

        lineNum = int(fileLine[n:]) - 1

        print self.deviceManager.path(), fileName
        fileName = os.path.join(self.deviceManager.path(), fileName)
        self.editorManager.newEditor(fileName, None, lineNum)
        editor = self.editorManager.currentEditor 
		
        
    def cellClicked(self, r, c, space=False):

		if self.deviceManager is None:
		    self.deviceManager = self.main.deviceManager

		cellItem= self.ui.breakTable.item(r, 0) 
		cellItemState = cellItem.checkState()  
		fileLine = cellItem.whatsThis()

		n = re.search(":", fileLine).end()
		fileName = str(fileLine[:n-1])
		if fileName.startswith("/"):
		    fileName = fileName[1:]
		elif fileName.endswith("/"):
		    fileName= fileName[:len(fileName) - 1]

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
        
		if space == True:
		    onState = Qt.Checked
		    offState = Qt.Unchecked
		else :
		    onState = Qt.Unchecked
		    offState = Qt.Checked


		if itemState == "on" and cellItemState == onState:
			if editor.starMark is True :
			    if editor.if_star_mark_exist("activate") is True :
			        cellItem.setCheckState(Qt.Checked)
		            self.ui.breakTable.setItem(r, 0, cellItem) 
			    return
			if self.deviceManager.debug_mode == True:
			    self.deviceManager.send_debugger_command(DBG_CMD_BREAKPOINT+" %s"%str(r)+" off")
			else:
			    if editor.current_line != lineNum :
			        editor.markerDelete(lineNum, editor.ACTIVE_BREAK_MARKER_NUM)
			        editor.markerAdd(lineNum, editor.DEACTIVE_BREAK_MARKER_NUM)
			    else :
			        editor.markerDelete(lineNum, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)
			        editor.markerAdd(lineNum, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)

			    cellItem.setCheckState(Qt.Unchecked)
			    editor.line_click[lineNum] = 2

			self.editorManager.bp_info[1].pop(r)
			self.editorManager.bp_info[1].insert(r, "off")
			self.break_info[1].pop(r)
			self.break_info[1].insert(r, "off")

		elif itemState == "off" and cellItemState == offState:
			if editor.starMark is True :
			    if editor.if_star_mark_exist("activate") is True :
			        cellItem.setCheckState(Qt.Unchecked)
		            self.ui.breakTable.setItem(r, 0, cellItem) 
			    return
			if self.deviceManager.debug_mode == True:
			    self.deviceManager.send_debugger_command(DBG_CMD_BREAKPOINT+" %s"%str(r)+" on")
			else:
			    if editor.current_line != lineNum :
			        editor.markerDelete(lineNum, editor.DEACTIVE_BREAK_MARKER_NUM)
			        editor.markerAdd(lineNum, editor.ACTIVE_BREAK_MARKER_NUM)
			    else :
			        editor.markerDelete(lineNum, editor.ARROW_DEACTIVE_BREAK_MARKER_NUM)
			        editor.markerAdd(lineNum, editor.ARROW_ACTIVE_BREAK_MARKER_NUM)

			    cellItem.setCheckState(Qt.Checked)
			    editor.line_click[lineNum] = 1

			self.editorManager.bp_info[1].pop(r)
			self.editorManager.bp_info[1].insert(r, "on")
			self.break_info[1].pop(r)
			self.break_info[1].insert(r, "on")

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
					newitem.setFlags(newitem.flags() & ~ Qt.ItemIsEditable)
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
       
		if hasattr(self.ui.breakTable, "r") == True and hasattr(self.ui.breakTable, "c") == True: 
		    self.ui.breakTable.setCurrentCell(self.ui.breakTable.r, self.ui.breakTable.c)
		    if self.ui.breakTable.itemFromIndex(self.ui.breakTable.currentIndex()) is not None:
		        self.ui.breakTable.itemFromIndex(self.ui.breakTable.currentIndex()).setSelected(True)

		self.ui.breakTable.show()

    def clearGlobalTable(self, row_num=0):
		self.ui.globalTable.clear()
		self.ui.globalTable.setHorizontalHeaderLabels(self.headers)
		self.ui.globalTable.setRowCount(row_num)
		
    def clearLocalTable(self, row_num=0):
		self.ui.localTable.clear()
		self.ui.localTable.setHorizontalHeaderLabels(self.local_headers)
		self.ui.localTable.setRowCount(row_num)
		
    def populateLocalTable(self, local_info=None):
		
		self.clearLocalTable(len(local_info[1]))
		n = 0
		for key in local_info:
			m = 0
			for item in local_info[key]:
				newitem = QTableWidgetItem(item)
				newitem.setFlags(newitem.flags() & ~ Qt.ItemIsEditable)
				newitem.setFont(self.font)
				if n == 1 :  
				    self.ui.localTable.setItem(m, n+1, newitem)
				elif n == 2 :  
				    self.ui.localTable.setItem(m, n-1, newitem)
				else :
				    self.ui.localTable.setItem(m, n, newitem)
				m += 1
			n += 1
		self.ui.localTable.show()

    def populateGlobalTable(self, global_info=None, editorManager=None):
		
		self.global_info = global_info
		self.editorManager = editorManager

		self.clearGlobalTable(len(global_info[1]))
		n = 0
		for key in global_info:
			m = 0
			for item in global_info[key]:
				newitem = QTableWidgetItem(item)
				newitem.setFlags(newitem.flags() & ~ Qt.ItemIsEditable)
				newitem.setFont(self.font)
				if n == 1 :  
				    self.ui.globalTable.setItem(m, n+1, newitem)
				elif n == 2 :  
				    self.ui.globalTable.setItem(m, n-1, newitem)
				else :
				    self.ui.globalTable.setItem(m, n, newitem)
				m += 1
			n += 1
		self.ui.globalTable.show()

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

