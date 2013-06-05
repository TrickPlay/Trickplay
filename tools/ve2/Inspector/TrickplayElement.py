from PyQt4.QtGui import *
from PyQt4.QtCore import *

Qt.TP = Qt.UserRole + 1
Qt.Partner = Qt.UserRole + 2

class TrickplayData(object):

    def __init__(self, JSON = None, parent = None):
        self._JSON = JSON
        self._parent = parent

    def JSON(self):
        """
        A reference to the dictionary containing the UI Element data for
        this object
        """
        return self._JSON

    def setJSON(self, v):
        """
        Set the reference to the dictionary of JSON data
        """
        self._JSON = v

    def parent(self):
        """
        A reference to the dictionary containing this objects data
        """
        return self._parent

    def setParent(self, v):
        """
        Set the reference to the parent dictionary
        """
        self.parent = v

class TrickplayElement(QStandardItem):
    """
    A Trickplay UI Element (Group, Rectangle, etc) for a Qt model.

    Keeps track of JSON data by storing a reference to the dictionary
    of JSON data returned to the app from Trickplay.

    Note:
    JSON data must be stored in a dictionary with non-string keys, otherwise
    PyQt will copy the dictionary to a QStringList (not good, can segfault
    with recursive data... also we need to make changes to the original data,
    not a copy)
    """

    def __init__(self, *args):
        """
        Create a new Trickplay Element
        """

        QStandardItem.__init__(self, *args)

        monofont = QFont()
        monofont.setStyleHint(monofont.Monospace)
        monofont.setFamily('Ubuntu')
        monofont.setPointSize(9)



        settings = QSettings()
        inspFont = str(settings.value("inspFont", monofont).toString())
        monofont.fromString(inspFont)
        self.inspFont = monofont

        self.setFont(monofont)
        self.setData(TrickplayData(), Qt.TP)

        self._partner = QStandardItem()
        self._partner.setFont(monofont)

    def partner(self):
        """
        Get this element's partner Item
        """

        return self._partner

    def setPartner(self, p):
        """
        Set this element's partner Item
        """

        self._partner = p

    def _TP(self):
        """
        Get the data associated with this Item and convert it
        to a python object
        """

        return self.data(Qt.TP).toPyObject()

    def TPJSON(self):
        """
        Get a reference to the dictionary containing the UI Element data for
        this object
        """

        return self._TP().JSON()

    def TPParent(self):
        """
        Get the reference to the parent dictionary for this element
        """

        return self._TP().parent()

    def setTPJSON(self, v):
        """
        Set the reference to the dictionary containing UI Element data
        """

        self._TP().setJSON(v)

    def setTPParent(self, v):
        """
        Set the reference to the parent dictionary for this element
        """

        self._TP().setParent(v)

    def __getitem__(self, key):
        """
        Get a property of this UI element
        """
        if not self.TPJSON():
            return None

        return self.TPJSON()[key]

    def __setitem__(self, key, value):
        """
        Set a property of this UI element
        """

        self.TPJSON()[key] = value

    def __iter__(self):
        """
        Iterate over UI element properties
        """

        return self.TPJSON().__iter__()
