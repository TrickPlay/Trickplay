# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'focusDestination.ui'
#
# Created: Wed Sep 26 11:02:08 2012
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
        PickerItemTable.resize(132, 119)
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
        self.toolButton_2 = QtGui.QToolButton(PickerItemTable)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.toolButton_2.sizePolicy().hasHeightForWidth())
        self.toolButton_2.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.toolButton_2.setFont(font)
        self.toolButton_2.setObjectName(_fromUtf8("toolButton_2"))
        self.gridLayout_2.addWidget(self.toolButton_2, 1, 4, 1, 1)
        self.toolButton_4 = QtGui.QToolButton(PickerItemTable)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.toolButton_4.sizePolicy().hasHeightForWidth())
        self.toolButton_4.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.toolButton_4.setFont(font)
        self.toolButton_4.setObjectName(_fromUtf8("toolButton_4"))
        self.gridLayout_2.addWidget(self.toolButton_4, 2, 2, 1, 1)
        self.toolButton_5 = QtGui.QToolButton(PickerItemTable)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.toolButton_5.sizePolicy().hasHeightForWidth())
        self.toolButton_5.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.toolButton_5.setFont(font)
        self.toolButton_5.setObjectName(_fromUtf8("toolButton_5"))
        self.gridLayout_2.addWidget(self.toolButton_5, 0, 2, 1, 1)
        self.toolButton_3 = QtGui.QToolButton(PickerItemTable)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.toolButton_3.sizePolicy().hasHeightForWidth())
        self.toolButton_3.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.toolButton_3.setFont(font)
        self.toolButton_3.setObjectName(_fromUtf8("toolButton_3"))
        self.gridLayout_2.addWidget(self.toolButton_3, 1, 2, 1, 1)
        self.toolButton = QtGui.QToolButton(PickerItemTable)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.toolButton.sizePolicy().hasHeightForWidth())
        self.toolButton.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.toolButton.setFont(font)
        self.toolButton.setObjectName(_fromUtf8("toolButton"))
        self.gridLayout_2.addWidget(self.toolButton, 1, 1, 1, 1)
        self.gridLayout.addLayout(self.gridLayout_2, 0, 0, 1, 1)

        self.retranslateUi(PickerItemTable)
        QtCore.QMetaObject.connectSlotsByName(PickerItemTable)

    def retranslateUi(self, PickerItemTable):
        PickerItemTable.setWindowTitle(QtGui.QApplication.translate("PickerItemTable", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.toolButton_2.setText(QtGui.QApplication.translate("PickerItemTable", "Right", None, QtGui.QApplication.UnicodeUTF8))
        self.toolButton_4.setText(QtGui.QApplication.translate("PickerItemTable", "Down", None, QtGui.QApplication.UnicodeUTF8))
        self.toolButton_5.setText(QtGui.QApplication.translate("PickerItemTable", "   Up   ", None, QtGui.QApplication.UnicodeUTF8))
        self.toolButton_3.setText(QtGui.QApplication.translate("PickerItemTable", "Enter", None, QtGui.QApplication.UnicodeUTF8))
        self.toolButton.setText(QtGui.QApplication.translate("PickerItemTable", "Left", None, QtGui.QApplication.UnicodeUTF8))

