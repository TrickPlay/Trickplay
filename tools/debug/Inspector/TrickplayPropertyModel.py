from PyQt4.QtCore import *
from PyQt4.QtGui import *

from PropertyIter import PropertyIter
from TrickplayElement import TrickplayElement
from data import dataToModel

NOT_EDITABLE = {
    'clip',
    'src',
    'source', 
    'x center', 
    'y center', 
    'z center', 
}

class TrickplayPropertyModel(QStandardItemModel):
    
    def fill(self, data):
        """
        Fill the model with data from a dictionary
        """
        
        root = self.invisibleRootItem()
        self.insertProperties(root, data, False)
            
    def insertProperties(self, parent, data, subtitle):
        """
        Recursively add property Items to the tree
        """

        """
        Parent is the parent node
        
        Data is the property data for this node
        
        Subtitle is the name of the parent node, if the parent node
        was a Lua table like 'anchor_point' as opposed to a value
        like 'x'.
        """
        
        for p in PropertyIter(subtitle):
            
            if not data.has_key(p):
                continue
            
            name, value, isSimple = dataToModel(p, data[p])
            
            # The value of this property... editable
            valueNode = TrickplayElement()
            valueNode.setTPJSON(data)
            
            # The name of this property... not editable
            nameNode = valueNode.partner()
            nameNode.setData(name, Qt.DisplayRole)
            nameNode.setFlags(nameNode.flags() ^ Qt.ItemIsEditable)
            
            # A simple value, like int or string
            if isSimple:
                valueNode.setData(value, Qt.DisplayRole)
                parent.appendRow([nameNode, valueNode])
            
            # A dictionary value
            else:
                summary = summarize(value, p)
                valueNode.setData(summary, Qt.DisplayRole)
                valueNode.setFlags(Qt.NoItemFlags)
                parent.appendRow([nameNode, valueNode])
                self.insertProperties(nameNode, value, p)
                
            if name in NOT_EDITABLE or (subtitle and subtitle in NOT_EDITABLE):
                valueNode.setFlags(Qt.NoItemFlags)
                
def summarize(value, subtitle = None):
    """
    The read-only summary of attributes
    """    

    try:
        a = PropertyIter(subtitle)
        summary = "{"
        for item in a:
            summary += item + ': ' + str(value[item]) + ', '
        summary = summary[:len(summary)-2] + '}'
        return summary

    except:
        print(value,  subtitle)
        raise Exception

#app = QApplication([])
#m = TrickplayPropertyModel()
#d = {"anchor_point":{"x":0,"y":0},"children":[],"gid":2,"is_visible":True,"name":"screen","opacity":255,"position":{"x":0,"y":0,"z":0},"scale":{"x":0.5,"y":0.5},"size":{"h":1080,"w":1920},"type":"Group","x_rotation":{"angle":0,"y center":0,"z center":0},"y_rotation":{"angle":0,"x center":0,"z center":0},"z_rotation":{"angle":0,"x center":0,"y center":0}}
#m.fill(d)
#v = QTreeView()
#v.setModel(m)
#v.show()
#
#e = m.invisibleRootItem().child(0,0).child(0,1)
#print(e.partner().data(Qt.DisplayRole).toPyObject(), e.data(Qt.DisplayRole).toPyObject())