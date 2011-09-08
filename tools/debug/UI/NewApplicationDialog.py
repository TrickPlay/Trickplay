# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'NewApplicationDialog.ui'
#
# Created: Fri Aug 19 14:53:38 2011
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_newApplicationDialog(object):
    def setupUi(self, newApplicationDialog):
        newApplicationDialog.setObjectName(_fromUtf8("newApplicationDialog"))
        newApplicationDialog.resize(427, 174)
        newApplicationDialog.setModal(True)
        self.gridLayout_2 = QtGui.QGridLayout(newApplicationDialog)
        self.gridLayout_2.setVerticalSpacing(12)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setVerticalSpacing(16)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.labelDirectory = QtGui.QLabel(newApplicationDialog)
        self.labelDirectory.setObjectName(_fromUtf8("labelDirectory"))
        self.gridLayout.addWidget(self.labelDirectory, 0, 0, 1, 1)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setSpacing(12)
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.directory = QtGui.QLineEdit(newApplicationDialog)
        self.directory.setReadOnly(True)
        self.directory.setObjectName(_fromUtf8("directory"))
        self.horizontalLayout.addWidget(self.directory)
        self.browse = QtGui.QPushButton(newApplicationDialog)
        self.browse.setObjectName(_fromUtf8("browse"))
        self.horizontalLayout.addWidget(self.browse)
        self.gridLayout.addLayout(self.horizontalLayout, 0, 1, 1, 1)
        self.labelId = QtGui.QLabel(newApplicationDialog)
        self.labelId.setObjectName(_fromUtf8("labelId"))
        self.gridLayout.addWidget(self.labelId, 1, 0, 1, 1)
        self.id = QtGui.QLineEdit(newApplicationDialog)
        self.id.setObjectName(_fromUtf8("id"))
        self.gridLayout.addWidget(self.id, 1, 1, 1, 1)
        self.labelName = QtGui.QLabel(newApplicationDialog)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.gridLayout.addWidget(self.labelName, 2, 0, 1, 1)
        self.name = QtGui.QLineEdit(newApplicationDialog)
        self.name.setObjectName(_fromUtf8("name"))
        self.gridLayout.addWidget(self.name, 2, 1, 1, 1)
        self.gridLayout_2.addLayout(self.gridLayout, 0, 0, 1, 1)
        self.buttonBox = QtGui.QDialogButtonBox(newApplicationDialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.gridLayout_2.addWidget(self.buttonBox, 1, 0, 1, 1)

        self.retranslateUi(newApplicationDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), newApplicationDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), newApplicationDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(newApplicationDialog)

    def retranslateUi(self, newApplicationDialog):
        newApplicationDialog.setWindowTitle(QtGui.QApplication.translate("newApplicationDialog", "New Application", None, QtGui.QApplication.UnicodeUTF8))
        self.labelDirectory.setText(QtGui.QApplication.translate("newApplicationDialog", "App Directory", None, QtGui.QApplication.UnicodeUTF8))
        self.directory.setText(QtGui.QApplication.translate("newApplicationDialog", "App Directory", None, QtGui.QApplication.UnicodeUTF8))
        self.browse.setText(QtGui.QApplication.translate("newApplicationDialog", "Browse", None, QtGui.QApplication.UnicodeUTF8))
        self.labelId.setText(QtGui.QApplication.translate("newApplicationDialog", "App ID", None, QtGui.QApplication.UnicodeUTF8))
        self.id.setPlaceholderText(QtGui.QApplication.translate("newApplicationDialog", "com.organization.newapplication", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("newApplicationDialog", "App Name", None, QtGui.QApplication.UnicodeUTF8))
        self.name.setPlaceholderText(QtGui.QApplication.translate("newApplicationDialog", "New Application", None, QtGui.QApplication.UnicodeUTF8))

