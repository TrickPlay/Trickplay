from PyQt4.QtGui import *
from PyQt4.QtCore import *

class InspectorDelegate(QItemDelegate):
    def __init__(self, parent=None, *args):
        QItemDelegate.__init__(self, parent, *args)
    
    def paint(self, painter, option, index):
        painter.save()
        
        itemType = index.data(33).toPyObject()
        col = index.data(34).toPyObject()
        
        #print(itemType)
        
        if "Rectangle" == itemType:
            painter.setBrush(QBrush(QColor(0, 195, 255, 40)))
        elif "Group" == itemType:
            painter.setBrush(QBrush(QColor(0, 255, 0, 40)))
        elif "Image" == itemType:
            painter.setBrush(QBrush(QColor(132, 0, 255, 40)))
        elif "Clone" == itemType:
            painter.setBrush(QBrush(QColor(255, 0, 208, 40)))
        elif "Text" == itemType:
            painter.setBrush(QBrush(QColor(212, 205, 23, 40)))
            
        painter.setPen(QPen(Qt.NoPen))
        if option.state & QStyle.State_Selected:
            painter.setBrush(QBrush(QColor(224, 129, 27, 150)))
        
        r = option.rect
        #print(r.top(), r.bottom(), r.left(), r.right())
        
        if option.state & QStyle.State_Selected:
            if (col == 0):
                painter.drawRect(r.x() - r.left(), r.y(), r.width() + r.left(), r.height())
            else:
                painter.drawRect(option.rect)
        elif col == 1:
            painter.drawRect(r.x() - r.left(), r.y(), r.width() + r.left(), r.height())
        else:
            painter.drawRect(option.rect)
        
        #
        ## set text color
        #if option.state & QStyle.State_Selected:
        #    painter.setPen(QPen(Qt.white))
        #else:
        painter.setPen(QPen(Qt.black))
        
        
        value = index.data(Qt.DisplayRole)
        if value.isValid():
            text = value.toString()
            painter.drawText(option.rect, Qt.AlignLeft, text)

        painter.restore()
