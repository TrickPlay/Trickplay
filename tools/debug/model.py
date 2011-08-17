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
    'src',
    'source', 
    'x center', 
    'y center', 
    'z center', 
}

T = 0  # Title
V = 1  # Value
A = -1 # All

class ElementModel(QStandardItemModel):
    
    def matchChild(self, value, role = Qt.DisplayRole,
                   flags = Qt.MatchRecursive, hits = 1,
                   start = None, column = T):
        """
        Find a child in the model given a value
        """
        
        if not start:        
            start = self.index(0, 0)
        
        result = self.match(start,
                            role,
                            value,
                            hits,
                            flags)
        
        # Return rows instead of indexes (these are more useful)
        if len(result) and T != column:
            for i in range(len(result)):
                item = self.itemFromIndex(result[i])
                result[i] = item.toRow()
            
        return result
        
    def initialize(self,  headers,  populate):    
        """
        Initialize the model with JSON data
        The root of the model will be the Screen actor (instead of Stage)
        """
        
        if headers:    
            self.setHorizontalHeaderLabels(headers)
        
        root = self.invisibleRootItem()
        
        if populate:
            data = getTrickplayData()
            if data:
                child = None
            
                for c in data["children"]:
                    if c[ "name" ] == "screen":
                        child = c
                        break
                    
                if child is None:
                    print( "Could not find screen element." )
                else:
                    self.addElement(root, child, screen = True)
                                
            else:
                print("Could not retreive data.")
                
    def findAttr(self, parent, title, requiresElement = False):
        """
        Find an attribute given the index of a UIElement
        Return an index tuple (title, value)
        """
        
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

    def titleFromValue(self, valueNode): 
        """
        Return the title index of a row given the value index
        """    

        return self.getPair(valueNode)[0]

    def valueFromTitle(self, titleNode):
        """
        Return the value index of a row given the title index
        """
        
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

    def addElement(self, parent, data, screen = False):
        """
        Add a UI element to the tree as an Element
        """
        
        value = data["name"]
        
        title = data["type"]
        
        gid = data['gid']
        
        if "Texture" == title:
        
            title = "Image"
        
        
        titleNode = Element(title)
        
        titleNode.setFlags(titleNode.flags() ^ Qt.ItemIsEditable)
        
        titleNode.setData(gid, Qt.Gid)
        
        titleNode.setData(value, Qt.Name)
        
        # Add a checkbox for everything but screen
        if not screen:
            
            titleNode.setCheckable(True)
            
            checkState = Qt.Unchecked
            
            if data['is_visible']:
                
                checkState = Qt.Checked
            
            titleNode.setCheckState(checkState)

        # Screen has no is_visible property because changing it messes up the app            
        else:
            
            del(data['is_visible'])

        if '' != value:
            
            gs = str(gid)
            
            l = len(gs)
            
            value =  gs + ' ' * 2 * (6 - l) + value
            
        else:
            
            value = str(gid)

        valueNode = Element(value)
        
        valueNode.setData(gid, Qt.Gid)
        
        valueNode.setFlags(valueNode.flags() ^ Qt.ItemIsEditable)
        
        parent.appendRow([titleNode, valueNode])
        
        self.addAttrs(titleNode, data, gid, False)
    
    def addAttrs(self, parent, data, gid, nested):
        """
        Add the list of UI element attributes to the tree as a Element
        Parent is a QStandardItem (an Element), data is the JSON data,
        gid is the parent Element's gid, and nested is the name of the parent
        attribute, like 'anchor_point', if applicable ('anchor_point' has children x, y)
        """    
    
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
    
    
    def refreshRoot(self):
        """
        Refresh all Tree data from the root
        Most data will remain the same between refreshes
        """
        
        data = getTrickplayData()["children"][0]
        
        self.refreshElements(self.toItem(self.getRoot()),  data)
    
     


         
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
    
    
    def toItem(self, node):
        """
        Return an index given either an item or an index
        """    
    
        if isinstance(node, Element):        
            return node
            
        elif isinstance(node, QModelIndex):
            return self.itemFromIndex(node)
            
        else:
            raise BadDataException("toItem must be called on a node")

    
    def copyAttrs(self, original, new, isNested = False):
        """
        Copy attributes from the inspector model to the property model.
        This happens every time selection changes in the inspector model.
        """    
    
        try:
            e = self.itemFromIndex(original)
            attrs = e.attrs()
            
            for row in attrs:
                c = []
                for i in range(e.columnCount()):
                    c.append(row[i].fullClone())
                new.appendRow(c)
            
        # Nothing was selected, so no rows need be coppied
        except TypeError:
            pass

    
    def dataStructure(self, pair):
        """
        Recreate the Python data structure given a row of elements
        """
    
        data = {}
        
        self.createDataStructure(pair, data)
    
        return data
    
    
    
    def createDataStructure(self, pair, data):
        """
        Recreate the python data structure given a (title, value) pair of indexes
        """    
    
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
        """
        Return the root index
        """
        
        return self.index(0,  0)
    
    
    
    def children(self,  index):
        """
        Return a list of tuples (column 0, column 1)
        """
    
        c = []
        for i in range(self.rowCount(index)):
            c.append((index.child(i, 0),  index.child(i, 1)))
        return c

    def title(self,  index):
        return index.data(Qt.DisplayRole).toString()


    def isElement(self,  title):
        """
        Return true if title string is a UIElement name
        """
        
        return title if title in UI_ELEMENTS else None


def summarize(value, nested = None):
    """
    The read-only summary of attributes
    """    

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

def pyData(index, role):
    """
    Get node data and return the result as a Python object,
    as opposed to data which returns the result as a QVariant
    If the data is a QString, return a Python str
    """
    
    i = index.data(role).toPyObject()
    
    if isinstance(i, QString):
        i = str(i)
    
    return i



### For refreshing nodes instead of recreating the entire tree...
### But this doesn't actually gain anything?


#def deleteChildren(self, item):
#    """
#    Delete marked children
#    """
#    # Check each child (in reverse, so deletions don't change indexing)
#    for i in range(len(item)-1,  -1,  -1):
#        
#        #print(item[i][T].pyData(Qt.Save), item[i][T].pyData(Qt.Gid))
#        
#        
#        
#        if not item[i][T].pyData(Qt.Save):
#            
#            item[i][T].setData('DEL', Qt.DisplayRole)
#
#
#"""
#TODO:
#    This function doesn't actually work. There is (mostly) working (but slow)
#    version back in git somewhere... however, given that we will likely not
#    refresh every node all at once, this will wait till later.
#
#Refreshes a UI element given its index
#
#Refresh each child element
#Pull each child from the model
#
#Delete every attr and remaining child
#Add every attr
#
#Put the children back in the model in the correct order
#
#"""
##TODO perhaps just recreate the entire tree, record which nodes were open,
##and reoppen them
#def refreshElements(self, item, data):
#    
#    # If this UI element is a group...
#    if data.has_key('children'):
#        
#        dataToAdd = []
#        
#        dataOrder = []
#        
#        elementsTaken = {}
#        
#        # Mark children as 'keep' or 'delete'
#        for i in range(len(data['children'])):
#            
#            c = data['children'][i]
#            
#            result = self.matchChild(c['gid'], role = Qt.Gid, column = -1,
#                                     start = item.index().child(0, 0), flags = Qt.MatchWrap)
#            
#            # Child still exists
#            if len(result) > 0:
#                
#                result = result[0]
#                
#                result[V].setData('NEW', Qt.DisplayRole)
#                
#                result[T].setData(True, Qt.Save)
#                
#                self.refreshElements(result[T], c)
#                
#                dataOrder.append(c['gid'])
#                
#                elementsTaken[c['gid']] = item.takeRow(result[T].row())
#            
#            # Child doesn't exist; add it
#            else:
#                
#                dataToAdd.append(c['gid'])
#                
#                #item.addElement(item, c)
#                
#        for i in elementsTaken:
#            
#            item.appendRow(elementsTaken[i])
#        
#    #attrs = item.attrs()
#    
#    # Update non-children elements
#    #for attr in AttrIter():
#    #    
#    #    if 'children' != attr:
#    #
#    #        attrRow = item[attr]
#    #        
#    #        # Attr still exists
#    #        if attrRow:
#    #            
#    #            attrRow[V].setData('NEW', Qt.DisplayRole)
#    #            
#    #            attrRow[T].setData(True, Qt.Save)
#    #            
#    #        # Attr doesn't exist; add it
#    #        else:
#    #            
#    #            self.addAttrs(parent, data[attr], data['gid'], nested)
#    #        
#    #
#    #
#    self.deleteChildren(item)       

