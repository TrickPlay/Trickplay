# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'FileSystem.ui'
#
# Created: Thu Jan 19 15:25:35 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_FileSystem(object):
    def setupUi(self, FileSystem):
        FileSystem.setObjectName(_fromUtf8("FileSystem"))
        FileSystem.resize(286, 715)
        self.verticalLayout = QtGui.QVBoxLayout(FileSystem)
        self.verticalLayout.setSpacing(0)
        self.verticalLayout.setMargin(0)
        self.verticalLayout.setObjectName(_fromUtf8("verticalLayout"))
        self.view = QtGui.QTreeView(FileSystem)
        font = QtGui.QFont()
        font.setPointSize(10)
        self.view.setFont(font)
        self.view.setEditTriggers(QtGui.QAbstractItemView.NoEditTriggers)
        self.view.setDragEnabled(True)
        self.view.setDragDropMode(QtGui.QAbstractItemView.DragOnly)
        self.view.setUniformRowHeights(True)
        self.view.setObjectName(_fromUtf8("view"))
        self.verticalLayout.addWidget(self.view)

        self.retranslateUi(FileSystem)
        QtCore.QMetaObject.connectSlotsByName(FileSystem)

    def retranslateUi(self, FileSystem):
        FileSystem.setWindowTitle(QtGui.QApplication.translate("FileSystem", "Form", None, QtGui.QApplication.UnicodeUTF8))

