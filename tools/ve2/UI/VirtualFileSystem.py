# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'VirtualFileSystem.ui'
#
# Created: Fri Nov  9 15:27:25 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_VirtualFileSystem(object):
    def setupUi(self, VirtualFileSystem):
        VirtualFileSystem.setObjectName(_fromUtf8("VirtualFileSystem"))
        VirtualFileSystem.resize(333, 698)
        sizePolicy = QtGui.QSizePolicy(QtGui.QSizePolicy.Expanding, QtGui.QSizePolicy.Expanding)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(VirtualFileSystem.sizePolicy().hasHeightForWidth())
        VirtualFileSystem.setSizePolicy(sizePolicy)
        font = QtGui.QFont()
        font.setPointSize(9)
        VirtualFileSystem.setFont(font)
        self.gridLayout = QtGui.QGridLayout(VirtualFileSystem)
        self.gridLayout.setMargin(0)
        self.gridLayout.setSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.fileSystem = QtGui.QGridLayout()
        self.fileSystem.setObjectName(_fromUtf8("fileSystem"))
        self.fileSystemTree = QtGui.QTreeWidget(VirtualFileSystem)
        self.fileSystemTree.setObjectName(_fromUtf8("fileSystemTree"))
        self.fileSystemTree.headerItem().setText(0, _fromUtf8("1"))
        self.fileSystem.addWidget(self.fileSystemTree, 0, 0, 1, 1)
        self.buttonsLayout = QtGui.QHBoxLayout()
        self.buttonsLayout.setObjectName(_fromUtf8("buttonsLayout"))
        self.importButton = QtGui.QPushButton(VirtualFileSystem)
        self.importButton.setObjectName(_fromUtf8("importButton"))
        self.buttonsLayout.addWidget(self.importButton)
        self.deleteButton = QtGui.QPushButton(VirtualFileSystem)
        self.deleteButton.setObjectName(_fromUtf8("deleteButton"))
        self.buttonsLayout.addWidget(self.deleteButton)
        self.newFolderButton = QtGui.QPushButton(VirtualFileSystem)
        self.newFolderButton.setObjectName(_fromUtf8("newFolderButton"))
        self.buttonsLayout.addWidget(self.newFolderButton)
        self.fileSystem.addLayout(self.buttonsLayout, 1, 0, 1, 1)
        self.gridLayout.addLayout(self.fileSystem, 0, 0, 1, 1)

        self.retranslateUi(VirtualFileSystem)
        QtCore.QMetaObject.connectSlotsByName(VirtualFileSystem)

    def retranslateUi(self, VirtualFileSystem):
        VirtualFileSystem.setWindowTitle(QtGui.QApplication.translate("VirtualFileSystem", "Form", None, QtGui.QApplication.UnicodeUTF8))
        self.importButton.setText(QtGui.QApplication.translate("VirtualFileSystem", "Import...", None, QtGui.QApplication.UnicodeUTF8))
        self.deleteButton.setText(QtGui.QApplication.translate("VirtualFileSystem", "Delete", None, QtGui.QApplication.UnicodeUTF8))
        self.newFolderButton.setText(QtGui.QApplication.translate("VirtualFileSystem", "New Folder", None, QtGui.QApplication.UnicodeUTF8))

