from PyQt4.QtCore import *
from PyQt4.QtGui import *
from connection import getTrickplayData
from data import dataToModel,  modelToData,  BadDataException
from attriter import AttrIter
from element import Element, ROW, UI_ELEMENTS


# Custom ItemDataRoles

Qt.Pointer = Qt.UserRole + 1
Qt.Element = Qt.UserRole + 2
Qt.Gid = Qt.UserRole + 3
Qt.Nested = Qt.UserRole + 4

NOT_EDITABLE = {
    'clip',
    'source', 
    'x center', 
    'y center', 
    'z center', 
}


class ElementModel(QStandardItemModel):
    
    
    """
    Find a child in the model given a value
    """
    def matchChild(self, value, role = Qt.DisplayRole,
                   flags = Qt.MatchRecursive, hits = 1,
                   start = None, column = ROW['T']):
        
        if not start:
            
            start = self.index(0, 0)
        
        result = self.match(start, role, value, hits, flags)
        
        if len(result) and ROW['T'] != column:
            
            for i in range(len(result)):
    
                item = self.itemFromIndex(result[i])
                
                result[i] = item.toRow()
            
        return result
        
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
    #TODO, this function makes very little sense..
    def findChildData(self,  item,  data):
        
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
            
            value =  gs + ' ' * 2 * (6 - l) + value
            
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
    Parent is a QStandardItem (an Element), data is the JSON data,
    gid is the parent Element's gid, and nested is the name of the parent
    attribute, like 'anchor_point', if applicable ('anchor_point' has children x, y)
    """
    def addAttrs(self, parent, data, gid, nested):
        
        a = AttrIter(nested)
        
        for attr in a:
            
            if not data.has_key(attr):
                
                continue
            
            title, value, isSimple = dataToModel(attr, data[attr])
            
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
                
                parent.appendRow([titleNode, valueNode])
                
            else:
                
                summary = summarize(value, attr)
                
                valueNode = Element(summary)
                
                valueNode.setFlags(Qt.NoItemFlags)
                
                parent.appendRow([titleNode, valueNode])
                
                self.addAttrs(titleNode, value, gid, attr)
            
            if title in NOT_EDITABLE or (nested and nested in NOT_EDITABLE):
                
                valueNode.setFlags(Qt.NoItemFlags)
                
            if nested:
                
                valueNode.setData(True, Qt.Nested)
    
    
    """
    Refresh all Tree data from the root
    Most data will remain the same between refreshes
    """
    def refreshRoot(self):
        
        data = getTrickplayData()["children"][0]
        
        self.refreshElements(self.toItem(self.getRoot()),  data)
    
    
    """
    Refreshes a UI element given its index
    """
    def refreshElements(self,  item,  data):
        
        children = item.children()

        # Update each child (in reverse, so deletions don't change indexing)
        for i in range(len(item)-1,  -1,  -1):
            
            element = children[i][0]
            
            title = element.pyData()
            
            # Removed unused elements and update existing ones
            if element.isElement():
                
                # Check if this element still exists in the refreshed data
                found = None
                
                for child in data['children']:
                
                    found = element.childByGid(child['gid'])
                
                
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
    def copyAttrs(self, original, new, isNested = False):
        
        e = self.itemFromIndex(original)

        attrs = e.attrs()
        
        for row in attrs:
            
            print('attr', row)
            
            c = []
            
            for i in range(2):
                
                c.append(row[i].fullClone())
            
            new.appendRow(c)

    
    """
    Recreate the Python data structure given a row of elements
    """
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

        if title in UI_ELEMENTS:
        
            return title
        
        else:
            
            return None


"""
The read-only summary of attributes
"""
def summarize(value, nested = None):
    
    try:
    
        a = AttrIter(nested)
        
        summary = "{"
        
        for item in a:
            
            summary += item + ': ' + str(value[item]) + ', '
        
        summary = summary[:len(summary)-2] + '}'
        
        return summary

    except:
        
        print(value,  nested)
        
        raise Exception

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







