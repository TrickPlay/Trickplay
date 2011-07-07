#!/usr/bin/env python

# Features to add:
#   Checkboxes for hide/show
#   Two views, one for UI elements and oen for properties
#   Drag and drop UI elements?

import sys
import urllib
import urllib2
import json
import delegate
from pprint import pprint
from PyQt4 import QtCore, QtGui
from TreeView import Ui_MainWindow
from TreeModel import *
import connection
from dataTypes import BadDataException

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
        #self.model = MyModel
        model = self.model
        
        #print(QtCore.QObject.connect(self.ui.Inspector,  QtCore.SIGNAL("itemClicked(QStandardItem)"),  self.itemChanged))
        #print('ok')
        
        # Connect it
        self.model.connect(self.model, QtCore.SIGNAL('itemChanged( QStandardItem * )'), self.itemChanged)
        
        self.delegate = delegate.MyDelegate()
        
        self.delegate.connect(self.delegate,  QtCore.SIGNAL('closeEditor( QWidget * , QAbstractItemDelegate::EndEditHint )'),  self.editorClosed)
        
        self.ui.Inspector.setItemDelegate(self.delegate)

        self.createTree()
        
        self.lastChanged = None
        
    def editorClosed(self,  lineEditor,  hint):
        if self.lastChanged:
            
            lastChanged = self.lastChanged
            self.lastChanged = None
            
            attrName = lastChanged[0]
            attrValue = lastChanged[1]
            gid = lastChanged[2]
            
            # Do a check to see if widget's text is the same as
            # lastChanged's text. If user closes editor but hasn't made a change,
            # don't send any data.
            if lineEditor.displayText() == attrValue:
                try:
                    params = connection.clean(attrName,  attrValue)
                    print("Params:",  params)
                    connection.send({'gid': gid, 'properties' : {params[0] : params[1]}})
                except BadDataException,  (e):
                    try:
                        print("Value entered:" + repr(attrValue))
                    except:
                        print("Value entered: could not represent value.")
                    print(e.value)
            else:
                print("No changed was made. Editor closed.")
                
        else:
            print("No change has been made since the program started.")
            
    def selectionChanged(self,  a,  b):
        print("SelectionChanged",  a,  b)
        i = self.InspectorSelectionModel.selection()
        i = self.proxyModel.mapSelectionToSource(i)
        self.propertySM.select(i,  QtGui.QItemSelectionModel.SelectCurrent)
        s = self.ui.propertyView.selectedIndexes()[0]
        
        #TODO: find better way to collapse by deselection perhaps?
        self.ui.propertyView.collapseAll()
        self.ui.propertyView.setExpanded(s,  True)
        self.ui.propertyView.scrollTo(s,  1)
        
        

    def itemChanged(self,  valueItem):
        row = valueItem.row()
        parent = valueItem.parent()
        attrItem = parent.child(row)
        gidNode = self.findNode('gid',  self.model.indexFromItem(parent))[1].data()
        gid = int(gidNode.toUInt()[0])
        #print("GID:",  int(gidNode.toUInt()[0]))
        #print(valueItem.data(0).toPyObject(),  attrItem.data(0).toPyObject())
        
        self.lastChanged = (str(attrItem.data(0).toString()), str(valueItem.data(0).toString()), gid)
        
        print("Changed: " + repr(self.lastChanged))
        
    def createTree(self):
        
        self.model.setHorizontalHeaderLabels(["UI Element Property",  "Value"])
        root = self.model.invisibleRootItem()
        
        # Use screen as root, not stage
        self.data = getTrickplayData()["children"][0]
        self.createNode(root, self.data)
        
        self.proxyModel = QtGui.QSortFilterProxyModel()
        self.proxyModel.setSourceModel(self.model)
        self.proxyModel.setFilterRole(0)
        #self.proxyModel.setFilterFixedString("")

        self.proxyModel.setFilterRegExp(QRegExp("(Group|Image|Text|Rectangle|Clone|children)"))
        
        
        self.ui.Inspector.setModel(self.proxyModel)
        
        # propertyView
        self.ui.propertyView.setModel(self.model)
        self.propertySM = QtGui.QItemSelectionModel(self.model)
        self.ui.propertyView.setSelectionModel(self.propertySM)
        #self.ui.propertyView.setItemDelegate(self.delegate)
        
        self.InspectorSelectionModel = QtGui.QItemSelectionModel(self.proxyModel)
        
        self.ui.Inspector.setSelectionMode(QtGui.QAbstractItemView.SingleSelection)
        
        self.ui.Inspector.setSelectionModel(self.InspectorSelectionModel)
        
        self.InspectorSelectionModel.connect(self.InspectorSelectionModel, QtCore.SIGNAL("selectionChanged(QItemSelection, QItemSelection)"), self.selectionChanged)
        
        # TODO, don't sort UIElements,
        # keep them in the order they are layered in their group
        # self.proxyModel.sort(0)
        
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
        print("ERROR >> Node attribute " +  name +  " not found.")
        print("Occurred in node:" + str(parent.data(0).toString()))
        exit()
        
    def findByGid(self,  data,  gid):
        for child in data:
            if child['gid'] == gid:
                return child
        return None
        
    # TODO
    # Current algorithm won't work if types change because
    # some types have values that other types don't.
    def refreshNodes(self,  oldData,  newData,  index):
        # attr is a tuple(number, attrName)
        for attr in list(enumerate(newData)):
            name = attr[1]
            childIndex = None
            if name != 'children':
                childIndex = self.findNode(name,  index)
                try:
                    oldValue = oldData[name]
                    newValue = newData[name]
                    
                    if oldValue != newValue:
                        # Value is a dictionary - create new summary and update children
                        # TODO, don't summarize clone's source attr
                        if isinstance(newValue, dict):
                            for attr in newValue:
                                #print(oldValue,  newValue,  name)
                                childAttrIndex = self.findNode(attr,  childIndex[0])[1]
                                self.model.setData(childAttrIndex,  newValue[attr])
                            newValue = self.summarize(newValue)
                        # Set node value
                        self.model.setData(childIndex[1],  newValue)
                        
                except:
                    exit('Problem (probably invalid attribute in newData)')
                    
            # Deal with group ClutterGroups
            else:
                
                oldType = oldData['type']
                newType = newData['type']
                
                # If both old and new are groups, refresh children
                if "Group" == oldType and "Group" == newType:
                    childIndex = self.findNode(name,  index)
                    self.refreshChildren(oldData['children'], newData['children'],  childIndex)
        
    def refreshChildren(self,  oldData,  newData,  listIndex):
        
        nOld = len(oldData); nNew = len(newData)

        # Traverse backwards so indices aren't changed when nodes are deleted
        for i in range(nOld-1,  -1,  -1):
            try:
                
                #print('searching',  i)
                if not self.findByGid(newData, oldData[i]['gid']):
                    #print('found gid',  oldData[i]['gid'])
                    self.model.removeRow(i,  listIndex[0])
            except e:
                print("ERROR",  e)

        # Update fields and add new children when necessary
        # TODO, special case for children to prevent too many comparisons
        for i in range(nNew):
            
            newChild = newData[i]
            oldChild = self.findByGid(oldData, newChild['gid'])
            
            if oldChild:
                elementType = self.model.index(i,  0,  listIndex[0])
                elementValue = self.model.index(i,  1,  listIndex[0])
                self.model.setData(elementValue,  newChild['name'])
                self.refreshNodes(oldChild,  newChild,  elementType)
            else:
                self.createNode(self.model.itemFromIndex(listIndex[0]),  newChild)
                
        if nOld != nNew:
            self.model.setData(listIndex[1],  nNew)
        
        #if self.findByGid(oldData,  newChild['gid']):
        # A change has been made
        #if not self.attrEq(oldChild, newChild):
            # TODO, better place to name child?
            # Name won't change if name is removed from attr list 
            # and name is the only attr updated                
        
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
    
        
