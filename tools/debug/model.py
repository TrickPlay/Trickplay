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
Qt.Save = Qt.UserRole + 5
Qt.Name = Qt.UserRole + 6

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
    Find a child in any column
    NOTE: Column parameter is for the column returned
    All columns are searched regardless of this parameter
    """
    def fullMatch(self, value, role = Qt.DisplayRole,
                  flags = Qt.MatchRecursive, hits = 1,
                  start = None, column = ROW['T']):
        
        found = []
        
        search
        
        while 0 == len(found):
            
            pass
            
            
        
        
        
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
        
        titleNode.setData(value, Qt.Name)
        
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
    Delete marked children
    """
    def deleteChildren(self, item):
    
        # Check each child (in reverse, so deletions don't change indexing)
        for i in range(len(item)-1,  -1,  -1):
            
            #print(item[i][ROW['T']].pyData(Qt.Save), item[i][ROW['T']].pyData(Qt.Gid))
            
            
            
            if not item[i][ROW['T']].pyData(Qt.Save):
                
                item[i][ROW['T']].setData('DEL', Qt.DisplayRole)
            
    
    
    """
    Refreshes a UI element given its index
    
    Refresh each child element
    Pull each child from the model
    
    Delete every attr and remaining child
    Add every attr
    
    Put the children back in the model in the correct order
    
    """
    #TODO perhaps just recreate the entire tree, record which nodes were open,
    #and reoppen them
    def refreshElements(self, item, data):
        
        # If this UI element is a group...
        if data.has_key('children'):
            
            dataToAdd = []
            
            dataOrder = []
            
            elementsTaken = {}
            
            # Mark children as 'keep' or 'delete'
            for i in range(len(data['children'])):
                
                c = data['children'][i]
                
                result = self.matchChild(c['gid'], role = Qt.Gid, column = -1,
                                         start = item.index().child(0, 0), flags = Qt.MatchWrap)
                
                # Child still exists
                if len(result) > 0:
                    
                    result = result[0]
                    
                    result[ROW['V']].setData('NEW', Qt.DisplayRole)
                    
                    result[ROW['T']].setData(True, Qt.Save)
                    
                    self.refreshElements(result[ROW['T']], c)
                    
                    dataOrder.append(c['gid'])
                    
                    elementsTaken[c['gid']] = item.takeRow(result[ROW['T']].row())
                
                # Child doesn't exist; add it
                else:
                    
                    dataToAdd.append(c['gid'])
                    
                    #item.addElement(item, c)
                    
            for i in elementsTaken:
                
                item.appendRow(elementsTaken[i])
            
        #attrs = item.attrs()
        
        # Update non-children elements
        #for attr in AttrIter():
        #    
        #    if 'children' != attr:
        #
        #        attrRow = item[attr]
        #        
        #        # Attr still exists
        #        if attrRow:
        #            
        #            attrRow[ROW['V']].setData('NEW', Qt.DisplayRole)
        #            
        #            attrRow[ROW['T']].setData(True, Qt.Save)
        #            
        #        # Attr doesn't exist; add it
        #        else:
        #            
        #            self.addAttrs(parent, data[attr], data['gid'], nested)
        #        
        #
        #
        self.deleteChildren(item)        


         
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
            
            return self.itemFromIndex(node)
            
        else:
            
            raise BadDataException("toItem must be called on a node")

    
    """
    Copy attributes from the inspector model to the property model.
    This happens every time selection changes in the inspector model.
    """
    def copyAttrs(self, original, new, isNested = False):
        
        try:
        
            e = self.itemFromIndex(original)
    
            attrs = e.attrs()
            
            for row in attrs:
    
                c = []
                
                for i in range(e.columnCount()):
                    
                    c.append(row[i].fullClone())
                
                new.appendRow(c)

        except TypeError:
            
             print("Nothing was selected")
            
            

    
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







