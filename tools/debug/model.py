from PyQt4.QtCore import *
from PyQt4.QtGui import *
from connection import getTrickplayData

Qt.Value = Qt.UserRole + 2
Qt.Element = Qt.UserRole + 3
Qt.ItemDepth = Qt.UserRole + 4

class ElementModel(QStandardItemModel):
    
    """
    Initialize the model with JSON data
    The root of the model will be the Screen actor (instead of Stage)
    """
    def initialize(self):
        
        self.setHorizontalHeaderLabels(["UI Element Property",  "Value"])

        root = self.invisibleRootItem()
        
        data = getTrickplayData()["children"][0]
        
        self.addElement(root, data)
    
    """
    Find an attribute given the index of a UIElement
    """
    def findAttr(self,  parent,  title):
        if self.isElement(self.title(parent)):
            n = self.rowCount(parent)
            for i in range(n):
                index = self.index(i, 0, parent)
                if title == self.data(index):
                    return (index,  self.index(i,  1,  parent))
            print("ERROR >> Node attribute " +  str(title) +  " not found.")
            print("Occurred in node:" + str(parent.data(0).toString()))
            #exit()
        else:
            #print("Only search for attributes on Elements")
            return None

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
    Add a UI element to the tree as a QStandardItem
    """
    def addElement(self, parent, data):
        
        value = data["name"]    
        title = data["type"]
        if "Texture" == title:
            title = "Image"
        
        titleNode = QStandardItem(title)
        valueNode = QStandardItem(value)
        
        parent.appendRow([titleNode, valueNode])
        self.addAttrs(titleNode, data)
    
    """
    Add the list of UI element attributes to the tree as a QStandardItem
    """
    def addAttrs(self, parent, data):
        
        for attr in data:
            
            title, value,  isSimple = dataToModel(attr, data[attr])
            
            titleNode = QStandardItem(attr)
            
            if 'children' == title:
                for child in value:
                    self.addElement(parent, child)
                
            elif isSimple:
                #print(attr,  value)
                valueNode = QStandardItem()
                valueNode.setData(value,  Qt.DisplayRole)
                parent.appendRow([titleNode, valueNode])
                
            else:
                summary = summarize(value)
                valueNode = QStandardItem(summary)
                parent.appendRow([titleNode, valueNode])
                
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
                # Data has this attr
                try: 
                    if data[str(title)]:
                        #print("Refresh",  title)
                        pass
                # Data doesn't have this attr
                except:
                    #print("Delete me",  title)
                    pass
        
        # Order of elements for rearranging later
        elementOrder = []
        
        # Add each nonexistent element of data
        for d in data:
            
            if 'children' == d:
                
                children = self.children(index)
                
                # For each child in incoming data
                for i in data[d]:
                    
                    gid = i['gid']
                    
                    elementOrder.append(gid)
                    
                    exists = False
                    
                    # Search through all the current children in the model
                    for c in children:
                        
                        # Compare the gid of the incoming child with each current child
                        r = self.findAttr(c[0], 'gid')
                        
                        if r:
                            
                            # If a match is found, this element must be refreshed
                            if int(str(r[1].data(0).toString())) == gid:
                                
                                exists = True
                                
                                break
                            
                    if not exists:
                        
                        self.addElement(self.itemFromIndex(index),  i)
                        
                    else:
                    
                        print("Refresh UI element")
                        
            else:
                
                node = self.findAttr(index, d) 
                
                if node:
                
                    print("refresh data", d)
                
                else:
                
                    print("add data", d)
                
        # Rearrange UI elements if necessary
        # (if an element was promoted in its group)
        
        pass
        
    def refreshAttrs(self):
        pass
        
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

def dataToModel(title,  value):
    t = title
    v = value
    s = True
    
    if "anchor_point" == t or \
    "clip" == t or "scale" == t or \
    "tile" == t or "source" == t or \
    "color" == t or "border_color" == t:
        s = False
        
    if "gid" == v:
        v = int(v)
    
    return (t, v, s)

def summarize(value):
    # The read-only summary of attributes
    summary = "{"
    for item in value:
        summary += item + ': ' + str(value[item]) + ', '
    summary = summary[:len(summary)-2] + '}'
    return summary

