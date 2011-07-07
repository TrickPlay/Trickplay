from PyQt4.QtCore import *
from PyQt4.QtGui import *
from connection import getTrickplayData

Qt.Value = Qt.UserRole + 2
Qt.Element = Qt.UserRole + 3
Qt.ItemDepth = Qt.UserRole + 4

class ElementModel(QStandardItemModel):
    
    """
    Initialize the model with JSON data
    """
    def initializeModel(self):
        
        self.setHorizontalHeaderLabels(["UI Element Property",  "Value"])
        
        # Set up the root to use screen (not stage)
        root = self.invisibleRootItem()
        data = getTrickplayData()["children"][0]
        self.addElement(root, data)
        
        #self.proxyModel = QSortFilterProxyModel()
        #self.proxyModel.setSourceModel(self.model)
        
        #self.ui.Inspector.setModel(self.proxyModel)
        
    def findAttr(self,  name,  parent):
        pass
    
    """
    Add a UI element to the tree
    """
    def addElement(self, parent, data):
        
        value = data["name"]    
        title = data["type"]
        if "Texture" == title:
            title = "Image"
        
        titleNode = QStandardItem(title)
        valueNode = QStandardItem(value)
        
        parent.appendRow([titleNode, valueNode])
        self.addAttrs(titleNode, data)
    
    """
    Add the list of UI element attributes to the tree
    """
    def addAttrs(self, parent, data):
        
        for attr in data:
            
            title, value,  isSimple = dataToModel(attr, data[attr])
            
            titleNode = QStandardItem(attr)
            
            if 'children' == title:
                for child in value:
                    self.addElement(parent, child)
                
            elif isSimple:
                valueNode = QStandardItem(repr(value))
                parent.appendRow([titleNode, valueNode])
                
            else:
                summary = summarize(value)
                valueNode = valueNode = QStandardItem(repr(value))
                parent.appendRow([titleNode, valueNode])
        
    def refreshElements(self):
        pass
        
    def refreshAttrs(self):
        pass

def dataToModel(title,  value):
    return (title,  value,  True)

def summarize(self,  value):
    # The read-only summary of attributes
    summary = "{"
    for item in value:
        summary += item + ': ' + str(value[item]) + ', '
    summary = summary[:len(summary)-2] + '}'
    return summary

