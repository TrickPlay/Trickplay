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

        QtGui.QWidget.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
        QtCore.QObject.connect(self.ui.button_Refresh, QtCore.SIGNAL("clicked()"), self.refresh)
        QtCore.QObject.connect(self.ui.action_Exit, QtCore.SIGNAL("triggered()"),  self.exit)
        self.model = QtGui.QStandardItemModel()
        model = self.model
        
        self.ui.Inspector.setItemDelegate(delegate.MyDelegate())
        
        self.createTree()
        
    def createTree(self):
        
        self.model.setHorizontalHeaderLabels(["UI Element Property",  "Value"])
        root = self.model.invisibleRootItem()
        
        # Use screen as root, not stage
        self.data = getTrickplayData()["children"][0]
        self.createNode(root, self.data)
        
        self.proxyModel = QtGui.QSortFilterProxyModel()
        self.proxyModel.setSourceModel(self.model)
        
        self.ui.Inspector.setModel(self.proxyModel)
        
        self.proxyModel.sort(0)
        
    def attrEq(self,  oldData,  newData):
        for attr in newData:
            if 'children' != attr:
                if oldData[attr] != newData[attr]:
                    return False
        return True
    
    # Return a tuple of nodes, (column0, column1)
    def findNode(self,  name,  parent):
        nChildren = self.model.rowCount(parent)
        for i in range(nChildren):
            index = self.model.index(i, 0, parent)
            if name == self.model.data(index):
                return (index,  self.model.index(i,  1,  parent))
        exit("Node not found")
    
    def refreshNodes(self,  oldData,  newData,  index):
        # attr is a tuple(number, attrName)
        for attr in list(enumerate(newData)):
            name = attr[1]
            childIndex = self.findNode(name,  index)
            if name != 'children':
                try:
                    oldValue = oldData[name]
                    newValue = newData[name]
                    
                    if oldValue != newValue:
                        # Value is a dictionary - create new summary and update children
                        if isinstance(newValue, dict):
                            for attr in newValue:
                                childAttrIndex = self.findNode(attr,  childIndex[0])[1]
                                self.model.setData(childAttrIndex,  newValue[attr])
                            newValue = self.summarize(newValue)
                        # Set node value
                        self.model.setData(childIndex[1],  newValue)
                        
                except:
                    exit('Problem (probably invalid attribute in newData)')
                    pass
                    
            # Deal with children
            else:
                if newData['type'] == "Group":
                    oldChildren = oldData['children']; newChildren = newData['children']
                    nOldChildren = len(oldChildren); nNewChildren = len(newChildren)
                    
                    # Number of children has not changed
                    if nOldChildren == nNewChildren:
                        for i in range(nNewChildren):
                            oldChild = oldChildren[i]
                            newChild = newChildren[i]
                            # A change has been made
                            if not self.attrEq(oldChild, newChild):
                                # TODO, better place to name child?
                                # Name won't change if name is removed from attr list 
                                # and name is the only attr updated
                                elementType = self.model.index(i,  0,  childIndex[0])
                                elementValue = self.model.index(i,  1,  childIndex[0])
                                self.model.setData(elementValue,  newChild['name'])
                                self.refreshNodes(oldChild,  newChild,  elementType)
                        
                pass

    def refresh(self):
        newData = getTrickplayData()["children"][0]
        self.refreshNodes(self.data,  newData,  self.model.index(0,  0))
        self.data = newData
        #self.model.clear()
        #self.createTree()
        #screenIndex = self.model.index(0, 0)
        #self.model.setData(screenIndex, QString("hello"))
        pass
        
    def exit(self):
        sys.exit()
        
    def createNode(self, parent, data):
        
        name = data["name"]    
        type = data["type"]
        if "Texture" == type:
            type = "Image"
        
        typeNode = QtGui.QStandardItem(type)
        typeNode.setData(0, 34)
        
        # Blank node used to color full row without double coloring
        valueNode = QtGui.QStandardItem(name)
        valueNode.setData(1, 34)
        valueNode.setData(type)
        
        parent.appendRow([typeNode, valueNode])
        self.createAttrList(typeNode, type, data)
            
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
                    self.createNode(title, child)
            
            # Value is a string/number/etc
            elif not isinstance(attrValue, dict):
                value = QtGui.QStandardItem(str(data[attr]))
                value.setData(parentType)
                value.setData(1, 34)
                parent.appendRow([title, value])    
                
            # Value is a dictionary, like scale
            else:
                summary = self.summarize(attrValue)
                value = QtGui.QStandardItem(summary)
                value.setData(parentType)
                value.setData(1, 34)
                parent.appendRow([title, value])
                self.createAttrList(title, parentType, attrValue)
    
    def summarize(self,  value):
        # The read-only summary of attributes
        summary = "{"
        for item in value:
            summary += item + ': ' + str(value[item]) + ', '
        summary = summary[:len(summary)-2] + '}'
        return summary

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
    
        
