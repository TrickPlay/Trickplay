#make the program quit on Ctrl+C
import signal
signal.signal(signal.SIGINT, signal.SIG_DFL)

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from math import sin, cos

class StarDelegate(QStyledItemDelegate):
    def __init__(self, parent = None):
        QStyledItemDelegate.__init__(self, parent)
        self.currentIndex = -1
        self.updateSize = True
    
    def paint(self, painter, option, index):
        self.updateSize = False
        if option.state & QStyle.State_Selected:
            modelIndex = index.row()
            if modelIndex != self.currentIndex:
                model = index.model()
                self.currentIndex = modelIndex
                self.updateSize = True
                model.wantsUpdate()
        
        starRating = index.data().toPyObject()
        if isinstance(starRating, StarRating):
            if option.state & QStyle.State_Selected:
                painter.fillRect(option.rect, option.palette.highlight())
            starRating.paint(painter, option.rect, option.palette, 'ReadOnly')
        else:
            QStyledItemDelegate.paint(self, painter, option, index)

    def sizeHint(self, option, index):
        starRating = index.data().toPyObject()
        if isinstance(starRating, StarRating):
            r = starRating.sizeHint()
            if self.currentIndex == index.row():
                r.setHeight(2*r.height())
            return r
        else:
            return QStyledItemDelegate.sizeHint(self, option, index)
    
    def createEditor(self, parent, option, index):
        starRating = index.data().toPyObject()
        if isinstance(starRating, StarRating):
            editor = StarEditor(parent)
            editor.editingFinished.connect(self.commitAndCloseEditor)
            return editor
        else:
            QStyledItemDelegate.createEditor(self, parent, option, index)
        
    def setEditorData(self, editor, index):
        starRating = index.data().toPyObject()
        if isinstance(starRating, StarRating):
            starEditor = editor
            starEditor.setStarRating(starRating)
        else:
            QStyledItemDelegate.setEditorData(self, editor, index)

    def setModelData(self, editor, model, index):
        starRating = index.data().toPyObject()
        if isinstance(starRating, StarRating):
            starEditor = editor
            model.setData(index, starEditor.starRating())
        else:
            QStyledItemDelegate.setModelData(self, editor, model, index)

    def commitAndCloseEditor(self):
       editor = sender()
       self.commitData.emit(editor)
       self.closeEditor.emit(editor)

class StarEditor(QWidget):
    editingFinished = pyqtSignal()
    
    def __init__(self, parent = None):
        QWidget.__init__(self, parent)
        print "StarEditor"
    
    def sizeHint(self):
        r = self.myStarRating.sizeHint()
        r.setHeight(2*r.height())
        return r
    
    def setStarRating(self, starRating):
        self.myStarRating = starRating
        self.setMouseTracking(True);
        self.setAutoFillBackground(True);
    
    def starRating(self):
        return self.myStarRating
        
    def paintEvent(self, e):
        painter = QPainter(self)
        self.myStarRating.paint(painter, self.rect(), self.palette(), 'Editable')
        
    def mouseMoveEvent(self, event):
        star = self.starAtPosition(event.x())
        if star != self.myStarRating.starCount() and star != -1:
            self.myStarRating.setStarCount(star)
            self.update()

    def mouseReleaseEvent(self, event):
        self.editingFinished.emit()
        
    def starAtPosition(self, x):
        star = (x / (self.myStarRating.sizeHint().width() / self.myStarRating.maxStarCount())) + 1;
        if star <= 0 or star > self.myStarRating.maxStarCount():
            return -1
        return star

class StarRating:
    def __init__(self, starCount = -1, maxStarCount = 5):
        self.PaintingScaleFactor = 20
        
        self.myStarCount = starCount;
        self.myMaxStarCount = maxStarCount;
    
        self.starPolygon = QPolygonF()
        self.diamondPolygon = QPolygonF()
        self.starPolygon.append(QPointF(1.0, 0.5))
        for i in range(1,5):
            self.starPolygon.append(QPointF(0.5 + 0.5 * cos(0.8 * i * 3.14), 0.5 + 0.5 * sin(0.8 * i * 3.14)))
        
        self.diamondPolygon.append(QPointF(0.4, 0.5))
        self.diamondPolygon.append(QPointF(0.5, 0.4))
        self.diamondPolygon.append(QPointF(0.6, 0.5))
        self.diamondPolygon.append(QPointF(0.5, 0.6))
        self.diamondPolygon.append(QPointF(0.4, 0.5))

    def sizeHint(self):
        return self.PaintingScaleFactor * QSize(self.myMaxStarCount, 1)

    def starCount(self):
        return self.myStarCount
        
    def maxStarCount(self):
        return self.myMaxStarCount
    
    def setStarCount(self, starCount):
        self.myStarCount = starCount
        
    def setMaxStarCount(self, maxStarCount):
        self.maxStarCount = maxStarCount

    def paint(self, painter, rect, palette, mode):
        painter.save()
        painter.setRenderHint(QPainter.Antialiasing, True)
        painter.setPen(Qt.NoPen)
        
        if mode == 'Editable':
            painter.setBrush(palette.highlight())
        else:
            painter.setBrush(palette.foreground())
        
        yOffset = (rect.height() - self.PaintingScaleFactor) / 2
        painter.translate(rect.x(), rect.y() + yOffset)
        painter.scale(self.PaintingScaleFactor, self.PaintingScaleFactor)
        
        for i in range(0, self.myMaxStarCount):
            if i < self.myStarCount:
                painter.drawPolygon(self.starPolygon, Qt.WindingFill)
            elif mode == 'Editable':
                painter.drawPolygon(self.diamondPolygon, Qt.WindingFill)
            painter.translate(1.0, 0.0)
        painter.restore()

class OverlayStackModel(QAbstractListModel):
    def __init__(self, parent = None):
        QAbstractListModel.__init__(self, parent)
        self.overlayStack = [StarRating(1), StarRating(2), StarRating(3), StarRating(4), StarRating(5)]
    
    def rowCount(self, parent = QModelIndex()):
        if not parent.isValid():
            return len(self.overlayStack)
        return 0
    
    def insertRows(self, row, count, parent = QModelIndex()):
        if parent.isValid():
            return False
        
        beginRow = max(0,row)
        endRow   = min(row+count-1, len(self.overlayStack)-1)
        self.beginInsertRows(parent, beginRow, endRow) 
        while(beginRow <= endRow):
            self.overlayStack.insert(row, StarRating(5))
            beginRow += 1
        self.endInsertRows()
        return True
            
    def removeRows(self, row, count, parent = QModelIndex()):
        if parent.isValid():
            return False
        if row+count <= 0 or row >= len(self.overlayStack):
            return False
        
        beginRow = max(0,row)
        endRow   = min(row+count-1, len(self.overlayStack)-1)
        self.beginRemoveRows(parent, beginRow, endRow)
        while(beginRow <= endRow):
            del self.overlayStack[row]
            beginRow += 1
        
        self.endRemoveRows()
        return True
    
    def flags(self, index):
        defaultFlags = Qt.ItemIsSelectable | Qt.ItemIsEditable | Qt.ItemIsEnabled
        if index.isValid():
            return Qt.ItemIsDragEnabled | defaultFlags
        else:
            return Qt.ItemIsDropEnabled | defaultFlags
    
    def supportedDropActions(self):
        return Qt.MoveAction
    
    def data(self, index, role):
        if not index.isValid():
            return None
        if index.row() > len(self.overlayStack):
            return None
        
        if role == Qt.DisplayRole or role == Qt.EditRole:
            return self.overlayStack[index.row()]
        
        return None
    
    def setData(self, index, value, role = Qt.EditRole):
        starRating = value
        if not isinstance(value, StarRating):
            print type(value)
            starRating = value.toPyObject()
        
        self.overlayStack[index.row()] = value
        self.dataChanged.emit(index, index)
        return True
    
    def headerData(section, orientation, role = Qt.DisplayRole):
        if role != Qt.DisplayRole:
            return None
        if orientation == Qt.Horizontal:
            return QString("Column %1").arg(section)
        else:
            return QString("Row %1").arg(section)
        
    def wantsUpdate(self):
        self.layoutChanged.emit()

class ListView(QListView):
    def __init__(self, parent = None):
        QListWidget.__init__(self, parent)
        self.setDragDropMode(self.InternalMove)
        self.installEventFilter(self)
        self.setDragDropOverwriteMode(False)
        
    def eventFilter(self, sender, event):
        #http://stackoverflow.com/questions/1224432/
        #how-do-i-respond-to-an-internal-drag-and-drop-operation-using-a-qlistwidget
        if (event.type() == QEvent.ChildRemoved):
            self.onOrderChanged()
        return False
        
    def onOrderChanged(self):
        print "ordering changed"

if __name__ == "__main__":
    import sys
    app = QApplication(sys.argv)

    model = OverlayStackModel()

    view = ListView()
    view.setModel(model)
    view.setItemDelegate(StarDelegate())
    view.setEditTriggers(QAbstractItemView.DoubleClicked | QAbstractItemView.SelectedClicked)
    #view.setEditTriggers(QAbstractItemView.CurrentChanged)
    view.show()

    def onIndexesMoved(self, i):
        print "indexes moved"

    view.indexesMoved.connect(onIndexesMoved)

    app.exec_()