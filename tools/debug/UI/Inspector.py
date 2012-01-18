# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Inspector.ui'
#
# Created: Fri Aug 19 12:09:34 2011
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_TrickplayInspector(object):
    def setupUi(self, TrickplayInspector):
        TrickplayInspector.setObjectName(_fromUtf8("TrickplayInspector"))
        TrickplayInspector.resize(258, 762)
        self.gridLayout = QtGui.QGridLayout(TrickplayInspector)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.splitter = QtGui.QSplitter(TrickplayInspector)
        self.splitter.setOrientation(QtCore.Qt.Vertical)
        self.splitter.setObjectName(_fromUtf8("splitter"))
        self.inspector = QtGui.QTreeView(self.splitter)
        self.inspector.setMinimumSize(QtCore.QSize(100, 0))
        self.inspector.setAlternatingRowColors(True)
        self.inspector.setUniformRowHeights(True)
        self.inspector.setObjectName(_fromUtf8("inspector"))
        self.inspector.header().setDefaultSectionSize(150)
        self.property = QtGui.QTreeView(self.splitter)
        self.property.setMinimumSize(QtCore.QSize(100, 0))
        self.property.setEditTriggers(QtGui.QAbstractItemView.DoubleClicked|QtGui.QAbstractItemView.EditKeyPressed|QtGui.QAbstractItemView.SelectedClicked)
        self.property.setAlternatingRowColors(True)
        self.property.setUniformRowHeights(True)
        self.property.setObjectName(_fromUtf8("property"))
        self.property.header().setDefaultSectionSize(150)
        self.gridLayout.addWidget(self.splitter, 2, 0, 1, 1)
        self.refresh = QtGui.QPushButton(TrickplayInspector)
        self.refresh.setObjectName(_fromUtf8("refresh"))
        self.gridLayout.addWidget(self.refresh, 1, 0, 1, 1)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.search = QtGui.QPushButton(TrickplayInspector)
        self.search.setObjectName(_fromUtf8("search"))
        self.horizontalLayout.addWidget(self.search)
        self.lineEdit = QtGui.QLineEdit(TrickplayInspector)
        self.lineEdit.setText(_fromUtf8(""))
        self.lineEdit.setObjectName(_fromUtf8("lineEdit"))
        self.horizontalLayout.addWidget(self.lineEdit)
        self.gridLayout.addLayout(self.horizontalLayout, 0, 0, 1, 1)

        self.retranslateUi(TrickplayInspector)
        QtCore.QMetaObject.connectSlotsByName(TrickplayInspector)

    def retranslateUi(self, TrickplayInspector):
        TrickplayInspector.setWindowTitle(QtGui.QApplication.translate("TrickplayInspector", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.refresh.setText(QtGui.QApplication.translate("TrickplayInspector", "Refresh", None, QtGui.QApplication.UnicodeUTF8))
        self.search.setText(QtGui.QApplication.translate("TrickplayInspector", "Search", None, QtGui.QApplication.UnicodeUTF8))

