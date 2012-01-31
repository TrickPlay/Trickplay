import re

from PyQt4.QtGui import *
from PyQt4.QtCore import *

from UI.Debugger import Ui_TrickplayDebugger
from UI.Backtrace import Ui_TrickplayBacktrace
from connection import *

class TrickplayDebugger(QWidget):
    
    def __init__(self, parent = None, f = 0):
        """
        UI Element property inspector made up of two QTreeViews
        """
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
		print ("TABLE CHANGED"+str(r)+":"+str(c))
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
			editor.markerDelete(lineNum, editor.ACTIVE_BREAK_MARKER_NUM)
			editor.markerAdd(lineNum, editor.DEACTIVE_BREAK_MARKER_NUM)
			editor.line_click[lineNum] = 2
			data = sendTrickplayDebugCommand("9876", "b",False)
			self.break_info = printResp(data, "b")
		elif itemState == "off" and cellItemState == Qt.Checked:
			sendTrickplayDebugCommand("9876", "b "+str(r)+" "+"on", False)
			editor.markerDelete(lineNum, editor.DEACTIVE_BREAK_MARKER_NUM)
			editor.markerAdd(lineNum, editor.ACTIVE_BREAK_MARKER_NUM)
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

    def populateTable(self, debug_info=None):
		selected = None
		self.ui.tableWidget.clear()
		"""
		self.ui.tableWidget.setSortingEnabled(False)
		self.ui.tableWidget.setRowCount(len(debug_info))
		headers = ["Name","Type","Value"]
		self.ui.tableWidget.setColumnCount(len(headers))
		self.ui.tableWidget.setHorizontalHeaderLabels(headers)
		for index in debug_info:
			item = QTableWidgetItem(debug_info[index][0])
			#item.setData(Qt.UserRole, 

		for row, ship in enumerate(self.ships):
            item = QTableWidgetItem(ship.name)
            item.setData(Qt.UserRole, int(id(ship)))
            if selectedShip is not None and selectedShip == id(ship):
                selected = item
            self.tableWidget.setItem(row, ships.NAME, item)
            self.tableWidget.setItem(row, ships.OWNER,
                    QTableWidgetItem(ship.owner))
            self.tableWidget.setItem(row, ships.COUNTRY,
                    QTableWidgetItem(ship.country))
            self.tableWidget.setItem(row, ships.DESCRIPTION,
                    QTableWidgetItem(ship.description))
            item = QTableWidgetItem("{:10}".format(ship.teu))
            item.setTextAlignment(Qt.AlignRight|Qt.AlignVCenter)
            self.tableWidget.setItem(row, ships.TEU, item)
        self.tableWidget.setSortingEnabled(True)
        self.tableWidget.resizeColumnsToContents()
        if selected is not None:
            selected.setSelected(True)
            self.tableWidget.setCurrentItem(selected)
		"""

class TrickplayBacktrace(QWidget):
    def __init__(self, parent = None, f = 0):
        QWidget.__init__(self, parent)
        
        self.ui = Ui_TrickplayBacktrace()
        self.ui.setupUi(self)

    def populateList(self, stack_info=None):
        selected = None
        self.ui.listWidget.clear()

        for index in stack_info:
			print (stack_info[index])
			item = QListWidgetItem(stack_info[index])
			self.ui.listWidget.addItem(item)
        selected = item
        if selected is not None:
        	selected.setSelected(True)
        	self.ui.listWidget.setCurrentItem(selected)

