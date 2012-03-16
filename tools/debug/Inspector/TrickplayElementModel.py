from PyQt4.QtCore import *
from PyQt4.QtGui import *

from PyQt4.QtNetwork import  QTcpSocket, QNetworkAccessManager , QNetworkRequest , QNetworkReply
from TrickplayElement import TrickplayElement
from connection import *

class TrickplayElementModel(QStandardItemModel):
    
    def __init__(self, inspector, parent=None):
        QWidget.__init__(self, parent)
        self.inspector = inspector
        self.manager = QNetworkAccessManager()
        self.reply = None

    def inspector_reply_finished(self):
        if self.reply.error()== QNetworkReply.NoError:
            pdata = json.loads(str(self.reply.readAll()))
            if pdata is not None:
                root = self.invisibleRootItem()
                child = None
                for c in pdata["children"]:
                    if c["name"] == "screen":
                        child = c
                        break
                
                if child is None:
                    print( "Could not find screen element." )
                else:
                    self.tpData = pdata
                    self.insertElement(root, child, pdata, True)
                self.inspector.ui.refresh.setText("Refresh")

            else:
                print("Could not retreive data.")

    def getInspectorData(self):
        """
        Get Trickplay UI tree data for the inspector
        """

        self.inspector.ui.refresh.setText("Retrieving...")

        if CON.address is None or CON.port is None:
            raise "NO HTTP PORT"
		
        self.manager = QNetworkAccessManager()

        url = QUrl()
        url.setScheme( "http" )
        url.setHost( CON.address )
        url.setPort( int(CON.port) )
        url.setPath( "/debug/ui" )
		    
        self.request = QNetworkRequest( url )
        self.reply = self.manager.get( self.request )

        QObject.connect( self.reply , SIGNAL( 'finished()' ) , self.inspector_reply_finished )
		
        #return None

    def fill(self):
        """
        Get UI data from Trickplay and fill the tree with it.
        If no data is available, do nothing.
        """
        self.tpData = None
        self.getInspectorData()
        """
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
        """
            
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
        self.node = node
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
        partner.setFlags(partner.flags() ^ Qt.ItemIsEditable)
        partner.setData(value, Qt.DisplayRole)
        
        parent.appendRow([node, partner])
        
        # Recurse through children
        try:
            children = data['children']
            for i in range(len(children)-1, -1, -1):
                self.insertElement(node, children[i], data, False)
        
        # Element has no children
        except KeyError:
            pass
        
    def empty(self):
        """
        Remove all nodes from the tree
        """
        
        self.invisibleRootItem().removeRow(0)
        
    def search(self, property, value, start = None):
        """
        Find an element where property == value
        """
        
        start = start or self.invisibleRootItem().child(0, 0)
        
        if start:
            return self.recSearch(property, value, start)
        else:
            return None
       
    def recSearch(self, property, value, item):
        
        if item[property] == value:
            return item
        
        # Check the item's children
        else:
            
            count = item.rowCount()
            if count > 0:
                for i in range(count):
                    result = self.recSearch(property, value, item.child(i))
                    if result:
                        return result
                        
            else:
                return None

