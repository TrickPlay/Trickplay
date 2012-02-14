
from PyQt4 import QtGui, QtCore

class DockAwareToolBar(QtGui.QToolBar):
    def __init__(self, parent=None):
        QtGui.QToolBar.__init__(self, parent)
        self.setToolButtonStyle(QtCore.Qt.ToolButtonTextBesideIcon)
        self.setObjectName("DockAwareToolbar") #for QSettings
        
        # this should happen by default IMO.
        #self.toggleViewAction().setText(_("&ToolBar"))

    def add_mini_menu(self, menu_button):
        self._menu_button = menu_button
        if self.actions():
            self.insertWidget(self.actions()[0], menu_button)
        else:
            self.addWidget(menu_button)
        self.show()
    
    def clear_mini_menu(self):
        self._menu_button.hide()
        self._menu_button.setParent(None)
        self._menu_button.deleteLater()
        self._menu_button = None

