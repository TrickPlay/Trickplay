from PyQt4.QtCore import *
from PyQt4.QtGui import *
from connection import getTrickplayData
from data import dataToModel,  modelToData,  BadDataException

Qt.Pointer = Qt.UserRole + 1
Qt.Value = Qt.UserRole + 2
Qt.Element = Qt.UserRole + 3
Qt.ItemDepth = Qt.UserRole + 4
Qt.Gid = Qt.UserRole + 5
Qt.Data = Qt.UserRole + 6
Qt.Nested = Qt.UserRole + 7

class ElementModel(QStandardItemModel):
    
    """
    Initialize the model with JSON data
    The root of the model will be the Screen actor (instead of Stage)
    """
    def initialize(self,  headers,  populate):
        
        if headers:
    
            self.setHorizontalHeaderLabels(headers)
        
        root = self.invisibleRootItem()
        
        if populate:
        
            data = getTrickplayData()["children"][0]
            
            self.addElement(root, data)
            
    
    """
    Find an attribute given the index of a UIElement
    Return an index tuple (title, value)
    """
    def findAttr(self,  parent,  title):
    
    #TODO: separate into 2 functions,
    #one that will just return if the parent is not an Element.
    #Most of the time searches are done on Elements for gid.
    #Only in dataChanged do I look for nested attributes on a
    #nonelement node.
    #if self.isElement(self.title(parent)):
        
        n = self.rowCount(parent)
        
        for i in range(n):
            
            index = self.index(i, 0, parent)
            
            if title == self.data(index):
                
                return (index,  self.index(i,  1,  parent))
                
        print("ERROR >> Node attribute " +  str(title) +  " not found in " + str(parent.data(0).toString()) + ".")

    #else:
        
    #    return None
        
    
    """
    Find the associated data for a child UI element
    If the UI element could not be found (by gid) then return None,
    otherwise return the child data
    """
    def findChildData(self,  index,  data):
        
        exists = None
        
        for child in data['children']:
            
            node = self.findAttr(index,  'gid')[1]
            
            if child['gid'] == node.data(Qt.DisplayRole).toPyObject():
            
                exists = child
        
        return exists
    
    """
    Return the title index of a row given the value index
    """
    def titleFromValue(self, valueNode):
        
        #print(pyData(valueNode, 0), pyData(valueNode.parent(),  0), valueNode.row())
        
        parentIndex = valueNode.parent()
        
        row = valueNode.row()
        
        column = 0
        
        # Screen
        if not parentIndex.isValid():

            return self.indexFromItem(self.invisibleRootItem().child(row, column))

        # Everything else
        else:
        
            return parentIndex.child(row, column)
        

    """
    Add a UI element to the tree as a QStandardItem
    """
    def addElement(self, parent, data):
        
        value = data["name"]
        
        title = data["type"]
        
        gid = data['gid']
        
        if "Texture" == title:
        
            title = "Image"
        
        
        
        titleNode = QStandardItem(title)
        
        titleNode.setFlags(titleNode.flags() ^ Qt.ItemIsEditable)
        
        titleNode.setData(gid, Qt.Gid)
        
        titleNode.setCheckable(True)
        
        checkState = Qt.Unchecked
        
        if data['is_visible']:
            
            checkState = Qt.Checked
        
        titleNode.setCheckState(checkState)

        valueNode = QStandardItem(value)
        
        valueNode.setData(gid, Qt.Gid)
        
        parent.appendRow([titleNode, valueNode])
        
        self.addAttrs(titleNode, data, gid, False)
    
    
    """
    Add the list of UI element attributes to the tree as a QStandardItem
    """
    def addAttrs(self, parent, data, gid, isNested):
        
        for attr in data:
            
            title, value, isSimple = dataToModel(attr, data[attr])
            
            if isNested:
                
                print( title,  value,  isSimple )
            
            titleNode = QStandardItem(attr)
            
            titleNode.setFlags(titleNode.flags() ^ Qt.ItemIsEditable)
            
            titleNode.setData(gid, Qt.Gid)
            
            valueNode = None
            
            # Add children in reverse order, so the top of the element stack 
            # is the first in the list
            if 'children' == title:
                
                for child in range(len(value)-1,  -1,  -1):
                #for child in value:
                    
                    self.addElement(parent, value[child])
                
            elif isSimple:
                
                valueNode = QStandardItem()
                
                valueNode.setData(value,  Qt.DisplayRole)
                
                valueNode.setData(value,  Qt.Data)
                
                parent.appendRow([titleNode, valueNode])
                
            else:
                
                # TODO, construct summary from child nodes? 
                # Maybe not, could be harder to compare w/ new data..
                summary = summarize(value)
                
                valueNode = QStandardItem(summary)
                
                valueNode.setData(summary,  Qt.Data)
                
                valueNode.setFlags(Qt.NoItemFlags)
                
                parent.appendRow([titleNode, valueNode])
                
                self.addAttrs(titleNode, value, gid, True)
            
            if 'gid' == title or 'source' == title or 'type' == title:
                
                valueNode.setFlags(Qt.NoItemFlags)
                
            if isNested:
                
                valueNode.setData(True, Qt.Nested)
    
    
    """
    Refresh all Tree data from the root
    Most data will remain the same between refreshes
    """
    def refreshRoot(self):
        
        data = getTrickplayData()["children"][0]
        
        self.refreshElements(self.getRoot(),  data)
    
    
    """
    Refreshes a UI element given its index
    """
    def refreshElements(self,  index,  data):
        
        children = self.children(index)

        # Update each child (in reverse, so deletions don't change indexing)
        for i in range(len(children)-1,  -1,  -1):
            
            element = children[i][0]
            
            title = self.title(element)
            
            # Removed unused elements and update existing ones
            if self.isElement(title):
                
                childData = self.findChildData(element,  data)
                
                if not childData:
                    
                    self.removeRow(i,  index)
                
                else:
                    
                    self.refreshElements(element,  childData)
            
            else:                
                
                self.refreshAttr(element, data, str(title))
        
        # Order of elements for rearranging later
        dataElementOrder = []
        
        # Add each nonexistent element of data
        for d in data:
            
            if 'children' == d:
                
                children = self.children(index)
                
                # For each child in incoming data
                for i in data[d]:
                    
                    gid = i['gid']
                    
                    dataElementOrder.append(gid)
                    
                    exists = False
                    
                    # Search through all the current children in the model
                    for c in children:
                        
                        # Compare the gid of the incoming child with each current child
                        r = self.findAttr(c[0], 'gid')
                        
                        if r:
                            
                            # If a match is found, this element must be refreshed
                            if int(pyData(r[1], 0)) == gid:
                                
                                exists = True
                                
                                break
                    
                    # If element doesn't exist, add it. If it exists, it was already refreshed
                    if not exists:
                        
                        self.addElement(self.itemFromIndex(index),  i)
                        
            else:
                
                node = self.findAttr(index, d) 
                
                if not node:
                
                    print("add data", d)
                
        # Rearrange UI elements if necessary (by taking then inserting rows)
        children = self.children(index)
        
        modelElementOrder = []
        
        # First get the old element order
        for pair in children:
            
            if self.isElement(pyData(pair[0], 0)):
            
                gid = pyData(pair[0], Qt.Gid)
                
                modelElementOrder.append(gid)
        
        # Reverse the order to keep the top of the stack as the first element listed
        dataElementOrder.reverse()
        
        if modelElementOrder != dataElementOrder:
            
            print("Re-ordering children")
        
            ordered = []
            
            item = self.itemFromIndex(index)
        
            # For each Gid
            for e in dataElementOrder:
                
                i = None
                
                # Find the row with the correct Gid
                for c in children:
                    
                    if e == pyData(c[0], Qt.Gid):
                        
                        i = c[0].row()
                        
                        break
                
                # Cut each row, and store them in the correct order
                ordered.append(item.takeRow(i))
            
                # Paste each row
                for r in ordered:
            
                    item.appendRow(r)
                    
                # TODO: select the appropriate node (by searching the entire tree for gid)
                # after the cut & paste
    
    
    """
    Refresh or delete one attribute by title
    """    
    def refreshAttr(self, index, data, title):
        
        # Data has this attr
        try: 
            
            if data[title]:
                
                #print("Refresh",  title)
                pass
        
        # Data doesn't have this attr
        except:
            
            #print("Delete me",  title)
            pass
    
    
    def copyAttrs(self, original, new):
        
        for i in self.children(original):
            
            originalItem = self.itemFromIndex(i[0])
            
            titleNode = originalItem.clone()
            
            if not self.isElement(pyData(titleNode, 0)):
            
                titleNode.setData(pyData(i[0], Qt.Gid), Qt.Gid)
            
                valueNode = self.itemFromIndex(i[1]).clone()
            
                new.appendRow([titleNode,  valueNode])
            
                if originalItem.hasChildren():
                    
                    self.copyAttrs(i[0], titleNode)
    
    
    def getRoot(self):
        
        return self.index(0,  0)
    
    
    """
    Return a list of tuples (column 0, column 1)
    """
    def children(self,  index):
        c = []
        for i in range(self.rowCount(index)):
            c.append((index.child(i, 0),  index.child(i, 1)))
        return c

    def title(self,  index):
        return index.data(Qt.DisplayRole).toString()


    """
    Returns true if title (string or index) is a UIElement name
    """
    def isElement(self,  title):
        #if not isinstance(title,  str) or not isinstance(title,  QString):
        #    title = self.title(title)
        #print(title)
        if "Text" == title or \
        "Group" == title or \
        "Image" == title or \
        "Rectangle" == title or \
        "Clone" == title:
        
            return title
        
        else:
            
            return None


def summarize(value):
    
    # The read-only summary of attributes
    summary = "{"
    
    for item in value:
        
        summary += item + ': ' + str(value[item]) + ', '
    
    summary = summary[:len(summary)-2] + '}'
    
    return summary


"""
Get node data and return the result as a Python object,
as opposed to data which returns the result as a QVariant
If the data is a QString, return a Python str
"""
def pyData(index, role):
    
    i = index.data(role).toPyObject()
    
    if isinstance(i,  QString):
        
        i = str(i)
    
    return i
