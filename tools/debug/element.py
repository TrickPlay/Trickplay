from PyQt4.QtCore import *
from PyQt4.QtGui import *

UI_ELEMENTS = {
    "Group", 
    "Canvas", 
    "Rectangle", 
    "Image", 
    "Clone", 
    "Bitmap", 
    "Text", 
}

# The different columns in a row, Title, Value, All

ROW = {'T' : 0, 'V' : 1, 'A' : -1}

"""
Provides better functionality for traversing elements than the QStandardItem
"""
class Element(QStandardItem):
    
    def __init__(self, value=None):
        
        self.lastChild = 0
        
        if value:
        
            super(QStandardItem, self).__init__(value)
            
        else:
            
            super(QStandardItem, self).__init__()
    
    
    # TODO, what is this?
    def type(self):
        
        return QStandardItem.UserType


    
    def clone(self):
        
        new = Element()
        
        new.setData(self.data(Qt.DisplayRole), Qt.DisplayRole)
        
        for i in range(10):
            
            role = i + Qt.UserRole - 1   
            
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
            
            if not c[ROW['T']].isElement():

                print(c[ROW['T']].pyData())

                for i in range(len(c)):
                    
                    newRow.append(c[i].copy())
                
            new.append(newRow)
            
        return new


    """
    Get the row that this element belongs in... because
    most of the time you need the title and value at the same time
    """
    def toRow(self):
        
        p = self.parent()
        
        #print(self.parent, self.parent())
        
        if not p:
            
            p = self.model().invisibleRootItem()
            
            return [p.child(0, ROW['T']), p.child(0, ROW['V'])]
        
        r = self.row()
        
        result = []
        
        for i in range(p.columnCount()):
            
            result.append(p.child(r, i))
            
        return result
        
        

    def childrenAsDict(self):
        
        d = {}
        
        for c in self:
            
            d[c[ROW['T']].pyData(Qt.Gid)] = c
            
        return d


    """
    Returns a list of child items
    """
    def children(self):
        
        children = []
        
        for c in self:
        
            children.append(c)
    
    """
    Return child with the given gid
    """
    def childByGid(self, gid):
            
        for c in self:
            
            if gid == c[ROW['T']].pyData(Qt.Gid):
                
                return c
            
        return None


    """
    Get the child with the given attribute if one exists
    """
    def childByAttr(self, attr):
        
        for c in self:
            
            if attr == c[0].pyData():
            
                return c
            
        return None
    
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
        
        if title in UI_ELEMENTS:
            
            return True
            
        else:
        
            return False


    """
    Returns any UI Elements owned by this item
    """
    def elements(self, isElement = True):
        
        children = []
        
        for c in self:
            
            if c[ROW['T']].isElement() == isElement:
                
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
    Returns row given an int or
    Returns a row given the string title
    """
    def __getitem__(self, row):
        
        if isinstance(row, int):
        
            r = []
            
            for i in range(self.columnCount()):
                
                r.append(self.child(row, i))
            
            return r
        
        elif isinstance(row, str):
            
            result = self.model().matchChild(row, column = -1,
                                             flags = Qt.MatchWrap, start = self.index())
            
            if len(result) > 0:
                
                return result[0]
                
            else:
            
                return None
            
        else:
            
            exit("Elements can only be indexed by ints and strs")

    
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

