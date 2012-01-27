from PyQt4.QtGui import *
from PyQt4.QtCore import *

from UI.Debugger import Ui_TrickplayDebugger
from UI.Backtrace import Ui_TrickplayBacktrace

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

    def populateBreakTable(self, break_info=None):
		pass

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
        print ("populateList")
		
        print(stack_info[0]+"**")

        for index in stack_info:
			print (stack_info[index])
			item = QListWidgetItem(stack_info[index])
			self.ui.listWidget.addItem(item)
        selected = item
        if selected is not None:
        	selected.setSelected(True)
        	self.ui.listWidget.setCurrentItem(selected)

