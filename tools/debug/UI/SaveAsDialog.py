# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'SaveAsDialog.ui'
#
# Created: Mon Feb 27 13:42:24 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_saveAsDialog(object):
    def setupUi(self, saveAsDialog):
        saveAsDialog.setObjectName(_fromUtf8("saveAsDialog"))
        saveAsDialog.resize(427, 120)
        font = QtGui.QFont()
        font.setPointSize(10)
        saveAsDialog.setFont(font)
        saveAsDialog.setModal(True)
        self.gridLayout_2 = QtGui.QGridLayout(saveAsDialog)
        self.gridLayout_2.setVerticalSpacing(12)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.buttonBox = QtGui.QDialogButtonBox(saveAsDialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.gridLayout_2.addWidget(self.buttonBox, 1, 0, 1, 1)
        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setHorizontalSpacing(10)
        self.gridLayout.setVerticalSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setSpacing(3)
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.directory = QtGui.QLineEdit(saveAsDialog)
        self.directory.setText(_fromUtf8(""))
        self.directory.setReadOnly(True)
        self.directory.setPlaceholderText(_fromUtf8(""))
        self.directory.setObjectName(_fromUtf8("directory"))
        self.horizontalLayout.addWidget(self.directory)
        self.browse = QtGui.QPushButton(saveAsDialog)
        self.browse.setObjectName(_fromUtf8("browse"))
        self.horizontalLayout.addWidget(self.browse)
        self.gridLayout.addLayout(self.horizontalLayout, 1, 1, 1, 1)
        self.filename = QtGui.QLineEdit(saveAsDialog)
        self.filename.setPlaceholderText(_fromUtf8(""))
        self.filename.setObjectName(_fromUtf8("filename"))
        self.gridLayout.addWidget(self.filename, 0, 1, 1, 1)
        self.labelDirectory = QtGui.QLabel(saveAsDialog)
        self.labelDirectory.setObjectName(_fromUtf8("labelDirectory"))
        self.gridLayout.addWidget(self.labelDirectory, 1, 0, 1, 1)
        self.labelName = QtGui.QLabel(saveAsDialog)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.gridLayout.addWidget(self.labelName, 0, 0, 1, 1)
        self.gridLayout_2.addLayout(self.gridLayout, 0, 0, 1, 1)

        self.retranslateUi(saveAsDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), saveAsDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), saveAsDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(saveAsDialog)
        saveAsDialog.setTabOrder(self.filename, self.directory)
        saveAsDialog.setTabOrder(self.directory, self.browse)
        saveAsDialog.setTabOrder(self.browse, self.buttonBox)

    def retranslateUi(self, saveAsDialog):
        saveAsDialog.setWindowTitle(QtGui.QApplication.translate("saveAsDialog", "Save As", None, QtGui.QApplication.UnicodeUTF8))
        self.browse.setText(QtGui.QApplication.translate("saveAsDialog", "Browse", None, QtGui.QApplication.UnicodeUTF8))
        self.labelDirectory.setText(QtGui.QApplication.translate("saveAsDialog", "Folder", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("saveAsDialog", "File Name", None, QtGui.QApplication.UnicodeUTF8))

