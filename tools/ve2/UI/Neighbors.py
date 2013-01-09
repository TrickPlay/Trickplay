# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Neighbors.ui'
#
# Created: Mon Oct  1 23:18:24 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_Neighbors(object):
    def setupUi(self, Neighbors):
        Neighbors.setObjectName(_fromUtf8("Neighbors"))
        Neighbors.resize(132, 119)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(Neighbors.sizePolicy().hasHeightForWidth())
        Neighbors.setSizePolicy(sizePolicy)
        self.gridLayout = QtGui.QGridLayout(Neighbors)
        self.gridLayout.setMargin(0)
        self.gridLayout.setSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.neighborsLayout = QtGui.QGridLayout()
        self.neighborsLayout.setSizeConstraint(QtGui.QLayout.SetMinimumSize)
        self.neighborsLayout.setSpacing(0)
        self.neighborsLayout.setObjectName(_fromUtf8("neighborsLayout"))
        self.upButton = QtGui.QToolButton(Neighbors)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.upButton.sizePolicy().hasHeightForWidth())
        self.upButton.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.upButton.setFont(font)
        self.upButton.setCheckable(True)
        self.upButton.setObjectName(_fromUtf8("upButton"))
        self.neighborsLayout.addWidget(self.upButton, 0, 2, 1, 1)
        self.rightButton = QtGui.QToolButton(Neighbors)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.rightButton.sizePolicy().hasHeightForWidth())
        self.rightButton.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.rightButton.setFont(font)
        self.rightButton.setCheckable(True)
        self.rightButton.setObjectName(_fromUtf8("rightButton"))
        self.neighborsLayout.addWidget(self.rightButton, 1, 4, 1, 1)
        self.downButton = QtGui.QToolButton(Neighbors)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.downButton.sizePolicy().hasHeightForWidth())
        self.downButton.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.downButton.setFont(font)
        self.downButton.setCheckable(True)
        self.downButton.setObjectName(_fromUtf8("downButton"))
        self.neighborsLayout.addWidget(self.downButton, 2, 2, 1, 1)
        self.enterButton = QtGui.QToolButton(Neighbors)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.enterButton.sizePolicy().hasHeightForWidth())
        self.enterButton.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.enterButton.setFont(font)
        self.enterButton.setCheckable(True)
        self.enterButton.setObjectName(_fromUtf8("enterButton"))
        self.neighborsLayout.addWidget(self.enterButton, 1, 2, 1, 1)
        self.leftButton = QtGui.QToolButton(Neighbors)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.leftButton.sizePolicy().hasHeightForWidth())
        self.leftButton.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(8)
        self.leftButton.setFont(font)
        self.leftButton.setCheckable(True)
        self.leftButton.setObjectName(_fromUtf8("leftButton"))
        self.neighborsLayout.addWidget(self.leftButton, 1, 1, 1, 1)
        self.gridLayout.addLayout(self.neighborsLayout, 0, 0, 1, 1)

        self.retranslateUi(Neighbors)
        QtCore.QMetaObject.connectSlotsByName(Neighbors)

    def retranslateUi(self, Neighbors):
        Neighbors.setWindowTitle(QtGui.QApplication.translate("Neighbors", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.upButton.setWhatsThis(QtGui.QApplication.translate("Neighbors", "up", None, QtGui.QApplication.UnicodeUTF8))
        self.upButton.setText(QtGui.QApplication.translate("Neighbors", "  ", None, QtGui.QApplication.UnicodeUTF8))
        self.rightButton.setWhatsThis(QtGui.QApplication.translate("Neighbors", "right", None, QtGui.QApplication.UnicodeUTF8))
        self.rightButton.setText(QtGui.QApplication.translate("Neighbors", "  ", None, QtGui.QApplication.UnicodeUTF8))
        self.downButton.setWhatsThis(QtGui.QApplication.translate("Neighbors", "down", None, QtGui.QApplication.UnicodeUTF8))
        self.downButton.setText(QtGui.QApplication.translate("Neighbors", "  ", None, QtGui.QApplication.UnicodeUTF8))
        self.enterButton.setWhatsThis(QtGui.QApplication.translate("Neighbors", "enter", None, QtGui.QApplication.UnicodeUTF8))
        self.enterButton.setText(QtGui.QApplication.translate("Neighbors", "  ", None, QtGui.QApplication.UnicodeUTF8))
        self.leftButton.setWhatsThis(QtGui.QApplication.translate("Neighbors", "left", None, QtGui.QApplication.UnicodeUTF8))
        self.leftButton.setText(QtGui.QApplication.translate("Neighbors", "  ", None, QtGui.QApplication.UnicodeUTF8))

