from PyQt4.QtCore import *
from PyQt4.QtGui import *

class ElementModel(QStandardItemModel):
    
    """
    Initialize the model with JSON data
    """
    def initializeModel(self):
        self.setHorizontalHeaderLabels(["UI Element Property",  "Value"])
        root = self.invisibleRootItem()
        
        # Use Screen as root, not Stage
        data = getTrickplayData()["children"][0]
        self.createNode(root, data)
        
        self.proxyModel = QSortFilterProxyModel()
        self.proxyModel.setSourceModel(self.model)
        
        self.ui.Inspector.setModel(self.proxyModel)
        
    def findAttr(self):
        pass
        
    def addElement(self, parent, data):
        pass
        
    def addAttr(self, parent, data):
        pass
        
    def refreshElements(self):
        pass
        
    def refreshAttrs(self):
        pass
