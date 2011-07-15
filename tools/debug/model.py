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

TITLE = 0
VALUE = 1
GID = 2

"""
A row of items
"""
class Row:
    
    def __init__(self, items):
    
        self.last = 0
    
        self.items = items
        
        self.tNode = items[TITLE]
        
        self.t = self.tNode.pyData()
        
        self.vNode = items[VALUE]
        
        self.v = self.vNode.pyData()
        
        try:
        
            self.gNode = items[GID]
        
            self.g = self.gNode.pyData()
            
        except:
            
            gid = 0
    
    def valueNode(self): return self.vNode
    
    def value(self): return self.v
    
    def titleNode(self): return self.tNode
    
    def title(self): return self.t
    
    def gidNode(self): return self.gidNode
    
    def gid(self): return self.g
        
    def __len__(self):
        
        len(self.items)

    def next(self):
        
        if self.last < len(self):
        
            self.last += 1
            
            return self.items(self.last)

        else:

            self.last = 0
            
            raise StopIteration



    def __iter__(self):
        
        return self

    

class Element(QStandardItem):
    
    def __init__(self, value=None):
        
        self.lastChild = 0
        
        if value:
        
            super(QStandardItem, self).__init__(value)
            
        else:
            
            super(QStandardItem, self).__init__()
            
    
#    def title(self): return self.title
#    
#    def setTitle(self, title): self.title = title
#    
    def gid(self): return self.gid
#    
    def setGid(self, gid): self.gid = gid
#    
#    def value(self): return value
#    
#    def setValue(self, value): self.value = value


    def type(self):
        
        return QStandardItem.UserType


    
    def clone(self):
        
        new = Element(self.data(Qt.DisplayRole).toString())
        
        for i in range(10):
            
            role = i + Qt.UserRole
            
            if self.pyData(role):
                
                new.setData(self.pyData(role), role)
        
        new.setFlags(self.flags())
        
        return new


    """
    Clone including children
    """
    def fullClone(self):
        
        new = self.clone()
        
        for child in self:
            
            r = []
            
            for i in child:
                
                r.append(i.clone())
            
            new.appendRow(r)
            
        return new


    """
    Clone this item's attributes
    """
    def copy(self):
        
        new = []
        
        for c in self:
            
            print("copying")
            
            newRow = []
            
            if not c[TITLE].isElement():

                print(c[TITLE].pyData())

                for i in range(len(c)):
                    
                    newRow.append(c[i].copy())
                
            new.append(newRow)
            
        return new


    """
    Returns a list of child items
    """
    def children(self):
        
        children = []
        
        for c in self:
        
            children.append(c)
    
    
    """
    Returns data at a given role as a python object
    """
    def pyData(self, role = Qt.DisplayRole):
        
        v = self.data(role).toPyObject()
        
        if isinstance(v, QString):
            
            v = str(v)
        
        return v


    """
    Returns true if this object has a UI Element name
    """
    def isElement(self):
        
        title = self.pyData(Qt.DisplayRole)
        
        #print(title)
        
        if 'Group' == title or 'Image' == title or \
        'Rectangle' == title or 'Clone' == title or 'Text' == title:
            
            return True
            
        else:
        
            return False


    """
    Returns any UI Elements owned by this item
    """
    def elements(self, isElement = True):
        
        children = []
        
        for c in self:
            
            if c[TITLE].isElement() == isElement:
                
                children.append(c)
                
        return children


    """
    Returns any attributes owned by this item
    """
    def attrs(self):

        return self.elements(False)


    """
    Returns the number of children of this item
    """
    def __len__(self):
        
        return self.rowCount()

    
    """
    Return the next row
    """
    def next(self):
        
        if self.lastChild < self.rowCount():
            
            row = []
            
            # For each column, get the children of the row
            for c in range(self.columnCount()):
            
                row.append(self.child(self.lastChild, c))
                
            self.lastChild += 1
                
            return row
         
        else:
            
            self.lastChild = 0
            
            raise StopIteration


    """
    Allow iteration of child nodes
    """
    def __iter__(self):
        
        return self


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
    def findAttr(self, parent, title, requiresElement = False):
    
        # Set requiresElement if this search should only take place on a UI element
        # Speed will improve significantly
        if requiresElement and not self.isElement(self.title(parent)):
            
            return None
        
        n = self.rowCount(parent)
        
        for i in range(n):
            
            index = self.index(i, 0, parent)
            
            if title == self.data(index):
                
                return (index,  self.index(i,  1,  parent))
                
        print("ERROR >> Node attribute " +  str(title) +  " not found in " + str(parent.data(0).toString()) + ".")

    
    """
    Find the associated data for a child UI element
    If the UI element could not be found (by gid) then return None,
    otherwise return the child data
    """
    def findChildData(self,  index,  data):
        
        exists = None
        
        for child in data['children']:
            
            node = self.findAttr(index,  'gid', True)[1]
            
            if child['gid'] == node.data(Qt.DisplayRole).toPyObject():
            
                exists = child
        
        return exists
    
    """
    Return the title index of a row given the value index
    """
    def titleFromValue(self, valueNode):
        
        return self.getPair(valueNode)[0]


    """
    Return the value index of a row given the title index
    """
    def valueFromTitle(self, titleNode):
        
        return self.getPair(titleNode)[1]

    
    """
    Return a (title, value) tuple of indexes given one of the pair
    """
    def getPair(self, index):
        
        if isinstance(index, Element):
            
            index = self.indexFromItem(index)
        
        parentIndex = index.parent()
        
        row = index.row()
        
        originalColumn = index.column()
        
        column = None
        
        if originalColumn:
        
            column = 0
            
        else:
            
            column = 1
        
        partnerIndex = None
        
        # Screen
        if not parentIndex.isValid():

            partnerIndex = self.indexFromItem(self.invisibleRootItem().child(row, column))

        # Everything else
        else:
        
            partnerIndex = parentIndex.child(row, column)
        
        if originalColumn:
            
            return (partnerIndex, index)
            
        else:
            
            return (index, partnerIndex)


    """
    Add a UI element to the tree as a Element
    """
    def addElement(self, parent, data):
        
        value = data["name"]
        
        title = data["type"]
        
        gid = data['gid']
        
        if "Texture" == title:
        
            title = "Image"
        
        
        
        titleNode = Element(title)
        
        titleNode.setFlags(titleNode.flags() ^ Qt.ItemIsEditable)
        
        titleNode.setData(gid, Qt.Gid)
        
        titleNode.setCheckable(True)
        
        checkState = Qt.Unchecked
        
        if data['is_visible']:
            
            checkState = Qt.Checked
        
        titleNode.setCheckState(checkState)

        if '' != value:
            
            gs = str(gid)
            
            l = len(gs)
            
            value =  gs + ' ' * 2 * (8 - l) + value
            
        else:
            
            value = str(gid)
            
            

        valueNode = Element(value)
        
        valueNode.setData(gid, Qt.Gid)
        
        valueNode.setFlags(valueNode.flags() ^ Qt.ItemIsEditable)
        
        #gidNode = Element(str(gid))
        
        #gidNode.setData(gid, Qt.Gid)
        
        parent.appendRow([titleNode, valueNode])
        
        self.addAttrs(titleNode, data, gid, False)
    
    """
    Add the list of UI element attributes to the tree as a Element
    """
    def addAttrs(self, parent, data, gid, isNested):
        
        for attr in data:
            
            title, value, isSimple = dataToModel(attr, data[attr])
            
            if isNested:
                
                pass
                #print( title,  value,  isSimple )
            
            titleNode = Element(attr)
            
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
                
                valueNode = Element()
                
                valueNode.setData(value,  Qt.DisplayRole)
                
                valueNode.setData(value,  Qt.Data)
                
                parent.appendRow([titleNode, valueNode])
                
            else:
                
                # TODO, construct summary from child nodes? 
                # Maybe not, could be harder to compare w/ new data..
                summary = summarize(value)
                
                valueNode = Element(summary)
                
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
                        r = self.findAttr(c[0], 'gid', True)
                        
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
            
    
    """
    Return an index given either an item or an index
    """
    def toIndex(self, node):
        
        if isinstance(node, Element):
            
            return self.indexFromItem(node)
            
        elif isinstance(node, QModelIndex):
            
            return node
            
        else:
            
            raise BadDataException("toIndex must be called on a node")
    
    
    """
    Return an index given either an item or an index
    """
    def toItem(self, node):
        
        if isinstance(node, Element):
            
            return node
            
        elif isinstance(node, QModelIndex):
            
            return self.indexFromItem(node)
            
        else:
            
            raise BadDataException("toItem must be called on a node")
    
    
    """
    Clone an item with children, return the item
    """
    def clone(self, node):
        
        node = self.toItem(node)
    
    
    
    """
    Copy attributes from the inspector model to the property model.
    This happens every time selection changes in the inspector model.
    """
    
    attrStructure = {
        'position' : ['x', 'y', 'z'], 
        'size' : ['w', 'h'], 
        'color' : ['r', 'g', 'b', 'a'], 
        'text' : 'text'
    }
    
    def copyAttrs(self, original, new, isNested = False):
        
        e = self.itemFromIndex(original)

        attrs = e.attrs()
        
        for row in attrs:
            
            c = []
            
            for i in range(2):
                
                c.append(row[i].fullClone())
            
            title = c[TITLE].pyData()
            
            if 'name' != title and 'gid' != title and 'type' != title:
            
                new.appendRow(c)

        return
        
        for attr in ['position', 'size', 'opacity', 'is_visible', 'color']:
            
            originalItem = None
            
            if not isNested:
                
                originalItem = self.itemFromIndex(self.findAttr(original, attr)[0])
                
            #else:
                
            #    originalItem = 
        
            i = self.getPair(originalItem)
            
            titleNode = originalItem.clone()
            
            title = pyData(titleNode, 0)
            
            if not self.isElement(title) and 'name' != title and 'gid' != title and 'type' != title:
            
                titleNode.setData(pyData(i[0], Qt.Gid), Qt.Gid)
            
                valueNode = self.itemFromIndex(i[1]).clone()
            
                new.appendRow([titleNode,  valueNode])
            
                if originalItem.hasChildren():
                    
                    self.copyAttrs(i[0], titleNode)
    
    
    def dataStructure(self, pair):
    
        data = {}
        
        self.createDataStructure(pair, data)
    
        return data
    
    
    """
    Recreate the python data structure given a (title, value) pair of indexes
    """
    def createDataStructure(self, pair, data):
        
        titleIndex, valueIndex = pair
        
        title = pyData(titleIndex, 0)
        
        value = pyData(valueIndex, 0)
        
        titleItem = self.itemFromIndex(titleIndex)
        
        if titleItem.hasChildren():
            
            childData = {}
                
            data[title] = childData
            
            for i in range(titleItem.rowCount()):
                
                self.createDataStructure((titleIndex.child(i, 0), titleIndex.child(i, 1)), childData)
                
        else:
            
            data[title] = value
            
        return data
    
    
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
    Returns true if title string is a UIElement name
    """
    def isElement(self,  title):

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
    
    if isinstance(i, QString):
        
        i = str(i)
    
    return i







