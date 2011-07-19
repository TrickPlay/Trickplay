"""
Refreshes a UI element given its index
"""
def refreshElements(self, item, data):
    
    children = item.children()

    # Update each child (in reverse, so deletions don't change indexing)
    for i in range(len(item)-1,  -1,  -1):
        
        element = children[i][ROW['T']]
        
        title = element.pyData()
        
        # Remove unused elements and update existing ones
        if element.isElement():
            
            # Check if this element still exists in the refreshed data
            found = None
            
            for child in data['children']:
            
                found = element.matchChild(child['gid'], role = Qt.Gid)
            
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
A row of items
"""
class Row:
    
    def __init__(self, items):
    
        self.last = 0
    
        self.items = items
        
        self.tNode = items[TITLE]
        
        self.t = self.tNode.pyData()
        
        self.vNode = items[ROW['V']]
        
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



ATTR = [
    'text',
    'font', 
    {'position' : ['x', 'y', 'z']}, 
    {'size' : ['w', 'h']},
    'opacity', 
    'is_visible', 
    {'color' : ['r', 'g', 'b', 'a']},
    {'border_color' : ['r', 'g', 'b', 'a']},
    {'anchor_point' : ['x', 'y']},
    {'scale' : ['x', 'y']},
    {'clip' : ['x', 'y', 'w', 'h']},
    {'x_rotation' : ['angle', 'y', 'z']},
    {'y_rotation' : ['angle', 'x', 'z']},
    {'z_rotation' : ['angle', 'x', 'y']},
]

FIND_ATTR_POSITION = {
    'text' : 0,
    'font' : 1,
    'position' : 2,
    'size' : 3,
    'opacity' : 4,
    'is_visible' : 5,
    'color' : 6,
    'border_color' : 7,
    'anchor_point' : 8,
    'scale' : 9,
    'clip' : 10,
    'x_rotation' : 11,
    'y_rotation' : 12,
    'z_rotation' : 13,
}
