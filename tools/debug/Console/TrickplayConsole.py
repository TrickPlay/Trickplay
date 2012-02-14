import sys
from PyQt4.QtGui import *
from PyQt4.QtCore import *
from PyQt4 import QtCore, QtGui

from UI.Console import Ui_Console

class OutLog:
    def __init__(self, edit, out=None, color=None):
        """(edit, out=None, color=None) -> can write stdout, stderr to a
        QTextEdit.
        edit = QTextEdit
        out = alternate stream ( can be the original sys.stdout )
        color = alternate color (i.e. color stderr a different color)
        """
        self.edit = edit
        self.out = None
        self.color = color

    def flush(self):
		if self.out:
			self.out.flush()

    def write(self, m):
        if self.color:
            tc = self.edit.textColor()
            self.edit.setTextColor(self.color)

        self.edit.moveCursor(QtGui.QTextCursor.End)
        self.edit.insertPlainText( m )

        if self.color:
            self.edit.setTextColor(tc)

        if self.out:
            self.out.write(m)

	
class TrickplayConsole(QWidget):

    def __init__(self, parent = None):
        QWidget.__init__(self, parent)
        self.ui = Ui_Console()
        self.ui.setupUi(self)

        #QObject.connect(self.ui.textEdit, SIGNAL("textChanged()"), self.text_changed)

        sys.stdout = OutLog( self.ui.textEdit, sys.stdout)
        sys.stderr = OutLog( self.ui.textEdit, sys.stderr, QtGui.QColor(255,0,0) )

	#def text_changed(self):
		#print ("changed !!")

