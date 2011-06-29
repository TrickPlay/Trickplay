import sys
import urllib
import urllib2
import json
from PyQt4 import QtCore, QtGui
from TreeView import Ui_MainWindow
from TreeModel import *

class StartQT4(QtGui.QMainWindow):
    def __init__(self, parent=None):
        QtGui.QWidget.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        QtCore.QObject.connect(self.ui.button_Refresh, QtCore.SIGNAL("clicked()"), self.refresh)
        QtCore.QObject.connect(self.ui.action_Exit, QtCore.SIGNAL("triggered()"),  self.exit)
        self.model = QtGui.QStandardItemModel()
        self.createTree()
        self.model.item(0).setData(QtGui.QBrush(QtGui.QColor.yellow))
    
    def createTree(self):
        #self.model.setColumnCount(2)
        self.model.setHorizontalHeaderLabels(["UI Element Property",  "Value"])
        root = self.model.invisibleRootItem()
        data = getTrickplayData()
        createNode(root, data, True)    
        self.ui.Inspector.setModel(self.model)
        
    def refresh(self):
        self.model.clear()
        self.createTree()
        
    def exit(self):
        sys.exit()
        
def createNode(parent, data, isStage):
    
    # If the node is the Stage, instead set it to Screen
    nodeData = None;
    if isStage:
        nodeData = data["children"][0]
    else:
        nodeData = data
        
    node = QtGui.QStandardItem(nodeData["type"] + ': ' + nodeData["name"])
    parent.appendRow([node])
    createAttrList(node, nodeData)
        
def createAttrList(parent, data):
    #print(data)
    for attr in data:
        #print(attr)
        attrTitle = attr
        attrValue = data[attr]
        
        title = QtGui.QStandardItem(attr)
        
        # Value is the list of children
        if isinstance(attrValue, list):
            value = QtGui.QStandardItem(str(len(attrValue)))
            parent.appendRow([title, value])
            for child in attrValue:
                createNode(title, child, False)
        
        # Value is a string/number/etc
        elif not isinstance(attrValue, dict):
            value = QtGui.QStandardItem(str(data[attr]))
            parent.appendRow([title, value])    
            
        # Value is a dictionary, like scale
        else:
            # The read-only summary of attributes
            summary = "{"
            for item in attrValue:
                summary += item + ': ' + str(attrValue[item]) + ', '
            summary = summary[:len(summary)-2] + '}'
            
            value = QtGui.QStandardItem(summary)
            parent.appendRow([title, value])
            createAttrList(title, attrValue)
    
    

def getTrickplayData():
    r = urllib2.Request("http://localhost:8888/debug/ui")
    f = urllib2.urlopen(r)
    return decode(f.read())

def decode(input):
    return json.loads(input)

if __name__ == "__main__":
    app = QtGui.QApplication(sys.argv)
    myapp = StartQT4()
    myapp.show()
    sys.exit(app.exec_())
    
#QtCore.QAbstractItemModel.insertRow(1)
