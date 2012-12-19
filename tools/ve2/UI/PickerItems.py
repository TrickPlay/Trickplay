# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'PickerItems.ui'
#
# Created: Tue Aug 21 10:36:04 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_PickerItemTable(object):
    def setupUi(self, PickerItemTable):
        PickerItemTable.setObjectName(_fromUtf8("PickerItemTable"))
        PickerItemTable.resize(213, 127)
        PickerItemTable.setMinimumSize(213, 127)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(PickerItemTable.sizePolicy().hasHeightForWidth())
        PickerItemTable.setSizePolicy(sizePolicy)
        self.gridLayout = QtGui.QGridLayout(PickerItemTable)
        self.gridLayout.setMargin(0)
        self.gridLayout.setSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.gridLayout_2 = QtGui.QGridLayout()
        self.gridLayout_2.setSizeConstraint(QtGui.QLayout.SetMinimumSize)
        self.gridLayout_2.setSpacing(0)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.itemTable = QtGui.QTableWidget(PickerItemTable)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Minimum)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.itemTable.sizePolicy().hasHeightForWidth())
        self.itemTable.setSizePolicy(sizePolicy)
        self.itemTable.setMinimumSize(QtCore.QSize(211, 10))
        font = QtGui.QFont()
        font.setPointSize(9)
        self.itemTable.setFont(font)
        self.itemTable.setAutoScrollMargin(0)
        self.itemTable.setShowGrid(False)
        self.itemTable.setObjectName(_fromUtf8("itemTable"))
        self.itemTable.setColumnCount(0)
        self.itemTable.setRowCount(0)
        self.itemTable.horizontalHeader().setVisible(False)
        self.itemTable.horizontalHeader().setCascadingSectionResizes(True)
        self.itemTable.horizontalHeader().setStretchLastSection(True)
        self.itemTable.verticalHeader().setVisible(False)
        self.itemTable.verticalHeader().setDefaultSectionSize(100)
        self.itemTable.resizeColumnsToContents()
        self.itemTable.resizeRowsToContents()
        self.gridLayout_2.addWidget(self.itemTable, 2, 0, 1, 3)
        self.gridLayout_2.rowMinimumHeight(1)
        self.gridLayout_2.setRowMinimumHeight(2, 100)
        self.addItem = QtGui.QToolButton(PickerItemTable)
        self.addItem.setObjectName(_fromUtf8("addItem"))
        self.gridLayout_2.addWidget(self.addItem, 0, 0, 1, 1)
        self.deleteItem = QtGui.QToolButton(PickerItemTable)
        self.deleteItem.setObjectName(_fromUtf8("deleteItem"))
        self.gridLayout_2.addWidget(self.deleteItem, 0, 1, 1, 1)
        self.gridLayout.addLayout(self.gridLayout_2, 1, 0, 1, 1)

        self.retranslateUi(PickerItemTable)
        QtCore.QMetaObject.connectSlotsByName(PickerItemTable)

    def retranslateUi(self, PickerItemTable):
        PickerItemTable.setWindowTitle(QtGui.QApplication.translate("PickerItemTable", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.addItem.setText(QtGui.QApplication.translate("PickerItemTable", "+", None, QtGui.QApplication.UnicodeUTF8))
        self.deleteItem.setText(QtGui.QApplication.translate("PickerItemTable", "-", None, QtGui.QApplication.UnicodeUTF8))

