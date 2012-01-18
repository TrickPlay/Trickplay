# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'DeviceManager.ui'
#
# Created: Fri Aug 19 14:27:27 2011
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_DeviceManager(object):
    def setupUi(self, DeviceManager):
        DeviceManager.setObjectName(_fromUtf8("DeviceManager"))
        DeviceManager.resize(287, 100)
        self.gridLayout = QtGui.QGridLayout(DeviceManager)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.frame = QtGui.QFrame(DeviceManager)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Preferred, QtGui.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.frame.sizePolicy().hasHeightForWidth())
        self.frame.setSizePolicy(sizePolicy)
        self.frame.setFrameShape(QtGui.QFrame.StyledPanel)
        self.frame.setFrameShadow(QtGui.QFrame.Raised)
        self.frame.setObjectName(_fromUtf8("frame"))
        self.verticalLayout_4 = QtGui.QVBoxLayout(self.frame)
        self.verticalLayout_4.setObjectName(_fromUtf8("verticalLayout_4"))
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.label = QtGui.QLabel(self.frame)
        self.label.setObjectName(_fromUtf8("label"))
        self.horizontalLayout.addWidget(self.label)
        self.comboBox = QtGui.QComboBox(self.frame)
        self.comboBox.setObjectName(_fromUtf8("comboBox"))
        self.horizontalLayout.addWidget(self.comboBox)
        self.verticalLayout_4.addLayout(self.horizontalLayout)
        self.run = QtGui.QPushButton(self.frame)
        self.run.setObjectName(_fromUtf8("run"))
        self.verticalLayout_4.addWidget(self.run)
        self.gridLayout.addWidget(self.frame, 0, 0, 1, 1)

        self.retranslateUi(DeviceManager)
        QtCore.QMetaObject.connectSlotsByName(DeviceManager)

    def retranslateUi(self, DeviceManager):
        DeviceManager.setWindowTitle(QtGui.QApplication.translate("DeviceManager", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("DeviceManager", "Trickplay Device", None, QtGui.QApplication.UnicodeUTF8))
        self.run.setText(QtGui.QApplication.translate("DeviceManager", "Run application on selected device", None, QtGui.QApplication.UnicodeUTF8))

