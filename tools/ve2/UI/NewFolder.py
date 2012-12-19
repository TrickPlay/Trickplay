# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'NewFolder.ui'
#
# Created: Thu Nov 15 11:36:20 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_newFolderDialog(object):
    def setupUi(self, newFolderDialog):
        newFolderDialog.setObjectName(_fromUtf8("newFolderDialog"))
        newFolderDialog.resize(427, 85)
        font = QtGui.QFont()
        font.setPointSize(10)
        newFolderDialog.setFont(font)
        newFolderDialog.setModal(True)
        self.gridLayout_2 = QtGui.QGridLayout(newFolderDialog)
        self.gridLayout_2.setVerticalSpacing(12)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.buttonBox = QtGui.QDialogButtonBox(newFolderDialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.gridLayout_2.addWidget(self.buttonBox, 1, 0, 1, 1)
        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setHorizontalSpacing(10)
        self.gridLayout.setVerticalSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.folder_name = QtGui.QLineEdit(newFolderDialog)
        self.folder_name.setPlaceholderText(_fromUtf8(""))
        self.folder_name.setObjectName(_fromUtf8("folder_name"))
        self.gridLayout.addWidget(self.folder_name, 0, 1, 1, 1)
        self.labelName = QtGui.QLabel(newFolderDialog)
        font = QtGui.QFont()
        font.setPointSize(10)
        self.labelName.setFont(font)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.gridLayout.addWidget(self.labelName, 0, 0, 1, 1)
        self.gridLayout_2.addLayout(self.gridLayout, 0, 0, 1, 1)

        self.retranslateUi(newFolderDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), newFolderDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), newFolderDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(newFolderDialog)
        newFolderDialog.setTabOrder(self.folder_name, self.buttonBox)

    def retranslateUi(self, newFolderDialog):
        newFolderDialog.setWindowTitle(QtGui.QApplication.translate("newFolderDialog", "New Folder", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("newFolderDialog", "New Folder", None, QtGui.QApplication.UnicodeUTF8))

