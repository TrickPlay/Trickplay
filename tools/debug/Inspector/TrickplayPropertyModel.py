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

Qt.Subtitle = Qt.UserRole + 2

class TrickplayPropertyModel(QStandardItemModel):
    
    def fill(self, data):
        """
        Fill the model with data from a dictionary
        """
        
        self.empty()
        
        root = self.invisibleRootItem()
        self.insertProperties(root, data, data, None)
            
    def insertProperties(self, parent, data, parentData, subtitle):
        """
        Recursively add property Items to the tree
        """

        """
        Parent is the parent node
        
        Data is the property data for this node
        
        parentData is the dictionary containing Data
        
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
            
            # Reference to the UI Element data
            valueNode.setTPJSON(parentData)
            
            # The name of this property... not editable
            nameNode = valueNode.partner()
            nameNode.setData(name, Qt.DisplayRole)
            nameNode.setFlags(nameNode.flags() ^ Qt.ItemIsEditable)
            
            if subtitle:
                valueNode.setData(subtitle, Qt.Subtitle)
            else:
                valueNode.setData('', Qt.Subtitle)
            
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
                self.insertProperties(nameNode, value, data, p)
                
            if name in NOT_EDITABLE or (subtitle and subtitle in NOT_EDITABLE):
                valueNode.setFlags(Qt.NoItemFlags)
                
    def empty(self):
        """
        Remove all nodes from the tree
        """
        
        i = self.invisibleRootItem()
        i.removeRows(0, i.rowCount())
        
    def subtitle(self, item):
        """
        Get the subtitle of a given property, like 'size' or 'anchor_point'
        """
        
        return str( item.data(Qt.Subtitle).toString() )
        
    def title(self, item):
        """
        Get the title of a given property, like 'opacity'
        """
        
        return str( item.partner().data(Qt.DisplayRole).toString() )
        
    def value(self, item):
        """
        Get the value of this item's property
        """
        
        v = item.data(Qt.DisplayRole).toPyObject()
        
        if isinstance(v, QString):
            v = str(v)
        
        return v
        
    def prepareData(self, item):
        """
        Copy the data dictionary for sending to Trickplay
        """
        
        copy = {}
        
        subtitle = self.subtitle(item)
        title = self.title(item)
        value = self.value(item)
        
        # Copy each necessary value, and insert the changed value
        # Don't overwrite the original value until we know Trickplay received it
        orig = None
        if '' == subtitle:
            copy = value
        else:
            orig = item[subtitle]
            for k in orig:
                copy[k] = orig[k]
            copy[title] = value
            
        print(copy)
            
        return copy
    
    def updateData(self, item):
        """
        Send data from this item to the original JSON dictionary
        """
        
        subtitle = self.subtitle(item)
        title = self.title(item)
        value = self.value(item)
        
        if '' == subtitle:
            item[title] = value
        else:
            item[subtitle][title] = value
    
    def revertData(self, item):
        """
        Revert this item to the original value from the JSON dictionary
        """

        subtitle = self.subtitle(item)
        title = self.title(item)
        
        if '' == subtitle:
            item.setData(item[title], Qt.DisplayRole)
        else:
            item.setData(item[subtitle][title], Qt.DisplayRole)
        
    
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


