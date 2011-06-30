import sys
import urllib
import urllib2
import json
import delegate
from pprint import pprint
from PyQt4 import QtCore, QtGui
from TreeView import Ui_MainWindow
from TreeModel import *

Qt.ElementTypeRole = Qt.UserRole + 1

#List of roles, ItemDataRole

#print dir(screenItem)
#pprint(dir (QtGui.QTreeView))

model = None

class MyDataModel(QtGui.QStandardItemModel):
    def __init__(self, parent=None):
        super(MyDataModel, self).__init__(parent)
        
    def data(self, index, role=Qt.DisplayRole):
        #if role == 33:
            #print("found")
            #print(super(MyDataModel, self).data(index, role).isValid())
        return super(MyDataModel, self).data(index, role)
        
    def setData(self, index, value, role=Qt.UserRole + 1):
        result = super(MyDataModel, self).setData(index, value, role)
        print("setting", role, "to", value, "with result", result)
        return result
        
class MyStandardItem(QtGui.QStandardItem):
    def __init__(self, a):
        super(MyStandardItem, self).__init__(a)
        
    def addData(self, data):
        self.myAddedData = data
        print(self.myAddedData)
        
    def getData(self):
        print(self.myAddedData)
        return self.myAddedData
        
    def data(self, role):
        #print("Role queried", role)
        #if role ==33:
        #    print("result", super(MyStandardItem, self).data(role).isValid())
        #    return QtCore.QVariant(QString("Hello"))
        return super(MyStandardItem, self).data(role)
    

class MyProxyModel(QtGui.QSortFilterProxyModel):
    def __init__(self, parent=None):
        super(MyProxyModel, self).__init__(parent)
        
    def data(self, index, role):
        #print(role)
        if role == Qt.BackgroundRole:
            print(role)
            var = super(MyProxyModel, self).data(index, role)
            color = QtGui.QColor(var)
            print(color.getRgb())
    #    if role == Qt.ElementTypeRole:
    #        return super(MyProxyModel, self).data(index, role)
    #    elif role == Qt.BackgroundRole:
    #        q = QtGui.QPalette()
    #        #print('hi')
    #        t = super(MyProxyModel, self).data(index, role)
    #        #print(dir(t))
    #        v = QtCore.QVariant(QtGui.QColor(0,0,0,0))
    #        return v
        return super(MyProxyModel, self).data(index, role)        
   
#class MyModelIndex(QtCore.QModelIndex):
#    def __init__(self, parent=None):
#        super(MyModelIndex, self).__init__(parent)
#    
#    def data(self, role=Qt.DisplayRole):
#        return super(MyModelIndex, self).data(role)
    
class MyTreeView(QtGui.QTreeView):
    def __init__(self, parent=None):
        super(QtGui.QTreeView, self).__init__(parent)
        
    def drawRow(self, painter, styleopt, index):
        q = QtGui.QPalette()
        painter.setPen(QtGui.QColor(255, 255, 255))
        super(MyTreeView, self).drawRow(painter, styleopt, index)
        
        #print(index)
        #pprint(dir(index))
        variant = index.data(33)
        color = QtGui.QColor(variant)
        #print(variant.toString())

        print(variant.isValid())        
        
        #print("data", model.itemData(index))
        #
        #print(str(variant))
        #print(variant.isValid())
        #
        ##painter.save()
        ##r = styleopt.rect
        ###print(r.top(), r.right(), r.bottom(), r.left(), "x", r.x(), "y", r.y())
        ###w = sum(self.columnWidth(x) for x in range(self.header().count()))
        ##painter.setBrush(color)
        ##painter.drawRect(r.left(), r.top(), r.right(), r.bottom())
        ##painter.restore()
        
    #ef drawBranches(self, painter, rect, index):
    #    pass

class StartQT4(QtGui.QMainWindow):
    def __init__(self, parent=None):
        global model
        
        QtGui.QWidget.__init__(self, parent)
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        
        # Set up TreeView
        self.ui.Inspector = MyTreeView(self.ui.centralwidget)
        self.ui.Inspector.setGeometry(QtCore.QRect(10, 50, 1920, 1080))
        self.ui.Inspector.setAlternatingRowColors(True)
        
        
        QtCore.QObject.connect(self.ui.button_Refresh, QtCore.SIGNAL("clicked()"), self.refresh)
        QtCore.QObject.connect(self.ui.action_Exit, QtCore.SIGNAL("triggered()"),  self.exit)
        self.model = MyDataModel()
        model = self.model
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
        
        #self.proxyModel = MyProxyModel()
        #self.proxyModel.setSourceModel(self.model)
        
        self.ui.Inspector.setModel(self.model)
        
        #self.proxyModel.sort(0)
        
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
            
        node = MyStandardItem(nodeData["type"] + ': ' + nodeData["name"])
        parent.appendRow([node])
        self.createAttrList(node, nodeData)
            
    def createAttrList(self, parent, data):
        #print(data)
        for attr in data:
            #print(attr)
            attrTitle = attr
            attrValue = data[attr]
            
            title = MyStandardItem(attr)
            
            # Value is the list of children
            if isinstance(attrValue, list):
                value = MyStandardItem(str(len(attrValue)))
                parent.appendRow([title, value])
                for child in attrValue:
                    self.createNode(title, child, False)
            
            # Value is a string/number/etc
            elif not isinstance(attrValue, dict):
                value = MyStandardItem(str(data[attr]))
                parent.appendRow([title, value])    
                value.setData("Hi")
                                
            # Value is a dictionary, like scale
            else:
                # The read-only summary of attributes
                summary = "{"
                for item in attrValue:
                    summary += item + ': ' + str(attrValue[item]) + ', '
                summary = summary[:len(summary)-2] + '}'
                
                value = MyStandardItem(summary)
                parent.appendRow([title, value])
                self.createAttrList(title, attrValue)
    
    

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
    
        