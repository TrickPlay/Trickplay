import sys
import urllib
import urllib2
import json
import delegate
from pprint import pprint
from PyQt4 import QtCore, QtGui
from TreeView import Ui_MainWindow
from TreeModel import *

Qt.Element = Qt.UserRole + 3
Qt.Value = Qt.UserRole + 2

#List of roles, ItemDataRole

#print dir(screenItem)
#pprint(dir (QtGui.QTreeView))
        
class StartQT4(QtGui.QMainWindow):
    def __init__(self, parent=None):
        global model
        
        QtGui.QWidget.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
        # Set up TreeView
        #self.ui.Inspector = MyTreeView(self.ui.centralwidget)
        #self.ui.Inspector.setGeometry(QtCore.QRect(10, 50, 1920, 1080))
        #self.ui.Inspector.setAlternatingRowColors(True)
        
        
        QtCore.QObject.connect(self.ui.button_Refresh, QtCore.SIGNAL("clicked()"), self.refresh)
        QtCore.QObject.connect(self.ui.action_Exit, QtCore.SIGNAL("triggered()"),  self.exit)
        self.model = QtGui.QStandardItemModel()
        model = self.model
        
        self.ui.Inspector.setItemDelegate(delegate.MyDelegate())
        
        self.createTree()
        
        #q = QtGui.QPalette()
        #print(q)
        #print(q.base())
        
        #self.model.item(0).setData(QtGui.QBrush(QtGui.QColor.yellow))
    
        
    def createTree(self):
        
        self.model.setHorizontalHeaderLabels(["UI Element Property",  "Value"])
        root = self.model.invisibleRootItem()
        data = getTrickplayData()
        self.createNode(root, data, True)
        
        self.proxyModel = QtGui.QSortFilterProxyModel()
        self.proxyModel.setSourceModel(self.model)
        
        self.ui.Inspector.setModel(self.proxyModel)
        
        self.proxyModel.sort(0)
        
    def refresh(self):
        self.model.clear()
        self.createTree()
        
    def exit(self):
        sys.exit()
        
    def createNode(self, parent, data, isStage):
        
        # If the node is the Stage, instead set it to Screen
        nodeData = None;
        if isStage:
            nodeData = data["children"][0]
        else:
            nodeData = data
            
        type = nodeData["type"]
        if "Texture" == type:
            type = "Image"
        
        name = nodeData["name"]
        
        node = QtGui.QStandardItem(type + ': ' + name)
        node.setData(0, 34)
        
        blank = QtGui.QStandardItem('')
        blank.setData(1, 34)
        blank.setData(type)
        
        parent.appendRow([node, blank])
        self.createAttrList(node, type, nodeData)
            
    def createAttrList(self, parent, parentType, data):
        #print(data)
        for attr in data:
            #print(attr)
            attrTitle = attr
            attrValue = data[attr]
            
            title = QtGui.QStandardItem(attr)
            title.setData(0, 34)
            
            # Value is the list of children
            if isinstance(attrValue, list):
                value = QtGui.QStandardItem(str(len(attrValue)))
                value.setData(parentType)
                value.setData(1, 34)
                parent.appendRow([title, value])
                for child in attrValue:
                    self.createNode(title, child, False)
            
            # Value is a string/number/etc
            elif not isinstance(attrValue, dict):
                value = QtGui.QStandardItem(str(data[attr]))
                value.setData(parentType)
                value.setData(1, 34)
                parent.appendRow([title, value])    
                                
            # Value is a dictionary, like scale
            else:
                # The read-only summary of attributes
                summary = "{"
                for item in attrValue:
                    summary += item + ': ' + str(attrValue[item]) + ', '
                summary = summary[:len(summary)-2] + '}'
                
                value = QtGui.QStandardItem(summary)
                value.setData(parentType)
                value.setData(1, 34)
                parent.appendRow([title, value])
                self.createAttrList(title, parentType, attrValue)
    
    

def getTrickplayData():
    r = urllib2.Request("http://localhost:8888/debug/ui")
    f = urllib2.urlopen(r)
    return decode(f.read())

def decode(input):
    return json.loads(input)
    
def main(argv):
    app = QtGui.QApplication(argv)
    myapp = StartQT4()
    myapp.show()
    sys.exit(app.exec_())
    
if __name__ == "__main__":
    main(sys.argv)
    
#QtCore.QAbstractItemModel.insertRow(1)
#self.ui.Inspector.setItemDelegateForRow(0, delegate.MyDelegate())

#def setColors(self):
    #pass
    #screenItem = self.model.findItems("Group: screen")[0]
    #screenIndex = self.model.indexFromItem(screenItem)
    #childIndex = self.model.index(0, 0, screenIndex)
    
    #brush = QtGui.QBrush(QtGui.QColor(0, 255, 0, 255))
    #painter = QtGui.QPainter()
    #painter.setBrush(brush)
    
    #self.ui.Inspector.drawBranches(painter, QtCore.QRect(0,0,25,25), childIndex)
    #self.model.setData(childIndex, brush, Qt.BackgroundColorRole)
    
    #print(self.model.rowCount(screenIndex))
    
        