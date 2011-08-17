from PyQt4.QtCore import *
from PyQt4.QtGui import *

from connection import getTrickplayData, CON
from data import dataToModel,  modelToData,  BadDataException
from PropertyIter import PropertyIter
from element import Element, ROW, UI_ELEMENTS

from TrickplayElement import TrickplayElement

Qt.Gid = Qt.UserRole + 3

class TrickplayElementModel(QStandardItemModel):
    
    def fill(self):
        """
        Get UI data from Trickplay and fill the tree with it.
        If no data is available, do nothing.
        """
        self.tpData = None
        data = getTrickplayData()
        if data:
        
            root = self.invisibleRootItem()
        
            child = None
            for c in data["children"]:
                if c["name"] == "screen":
                    child = c
                    break
                
            if child is None:
                print( "Could not find screen element." )
            else:
                self.tpData = data
                self.insertElement(root, child, data, True)
                
        else:
            print("Could not retreive data.")
            
    def insertElement(self, parent, data, parentData, screen):
        """
        Recursively add UI Elements to the tree
        """

        """
        Parent is the parent node
        
        Data is the property data for this node
        ParentData is a reference to the dictionary containing data
        """
        
        value = data["name"]
        title = data["type"]
        gid = data['gid']
        
        if "Texture" == title:
            title = "Image"
            
        # Set the name node to gid + name
        if '' != value:   
            gs = str(gid)
            l = len(gs)
            value =  gs + ' ' * 2 * (6 - l) + value 
        else:    
            value = str(gid)
        
        node = TrickplayElement(title)
        node.setTPJSON(data)
        node.setTPParent(parentData)
        node.setFlags(node.flags() ^ Qt.ItemIsEditable)

        # Add a checkbox for everything but screen
        if not screen:
            
            node.setCheckable(True)
            
            checkState = Qt.Unchecked
            if data['is_visible']:
                checkState = Qt.Checked
            
            node.setCheckState(checkState)
        
        # Screen has no is_visible property because changing it
        # causes problems with key presses in the app
        else:    
            del(data['is_visible'])
        
        partner = node.partner()
        partner.setData(gid, Qt.Gid)
        partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
        
        parent.appendRow([node, partner])
        
        # This may be obsolete
        node.setData(gid, Qt.Gid)
        partner.setData(value, Qt.DisplayRole)
        
        # Recurse through children
        try:
            for c in data['children']:
                self.insertElement(node, c, data, False)
        
        # Element has no children
        except KeyError:
            pass
        
app = QApplication([])
t = TrickplayElementModel()
v = QTreeView()
v.setModel(t)
v.show()
CON.set('localhost', '8888')
t.fill()