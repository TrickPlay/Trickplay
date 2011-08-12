# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'NewApplicationDialog.ui'
#
# Created: Fri Aug 12 15:57:25 2011
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
        newApplicationDialog.resize(387, 212)
        newApplicationDialog.setModal(True)
        self.buttonBox = QtGui.QDialogButtonBox(newApplicationDialog)
        self.buttonBox.setGeometry(QtCore.QRect(30, 160, 341, 32))
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.widget = QtGui.QWidget(newApplicationDialog)
        self.widget.setGeometry(QtCore.QRect(20, 20, 351, 123))
        self.widget.setObjectName(_fromUtf8("widget"))
        self.gridLayout = QtGui.QGridLayout(self.widget)
        self.gridLayout.setMargin(0)
        self.gridLayout.setVerticalSpacing(20)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.label = QtGui.QLabel(self.widget)
        self.label.setObjectName(_fromUtf8("label"))
        self.gridLayout.addWidget(self.label, 0, 0, 1, 1)
        self.directory = QtGui.QLineEdit(self.widget)
        self.directory.setReadOnly(True)
        self.directory.setObjectName(_fromUtf8("directory"))
        self.gridLayout.addWidget(self.directory, 0, 1, 1, 1)
        self.label_2 = QtGui.QLabel(self.widget)
        self.label_2.setObjectName(_fromUtf8("label_2"))
        self.gridLayout.addWidget(self.label_2, 1, 0, 1, 1)
        self.id = QtGui.QLineEdit(self.widget)
        self.id.setObjectName(_fromUtf8("id"))
        self.gridLayout.addWidget(self.id, 1, 1, 1, 1)
        self.label_3 = QtGui.QLabel(self.widget)
        self.label_3.setObjectName(_fromUtf8("label_3"))
        self.gridLayout.addWidget(self.label_3, 2, 0, 1, 1)
        self.name = QtGui.QLineEdit(self.widget)
        self.name.setObjectName(_fromUtf8("name"))
        self.gridLayout.addWidget(self.name, 2, 1, 1, 1)

        self.retranslateUi(newApplicationDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), newApplicationDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), newApplicationDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(newApplicationDialog)

    def retranslateUi(self, newApplicationDialog):
        newApplicationDialog.setWindowTitle(QtGui.QApplication.translate("newApplicationDialog", "New Application", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("newApplicationDialog", "App Directory", None, QtGui.QApplication.UnicodeUTF8))
        self.directory.setText(QtGui.QApplication.translate("newApplicationDialog", "App Directory", None, QtGui.QApplication.UnicodeUTF8))
        self.label_2.setText(QtGui.QApplication.translate("newApplicationDialog", "App ID", None, QtGui.QApplication.UnicodeUTF8))
        self.id.setPlaceholderText(QtGui.QApplication.translate("newApplicationDialog", "com.organization.newapplication", None, QtGui.QApplication.UnicodeUTF8))
        self.label_3.setText(QtGui.QApplication.translate("newApplicationDialog", "App Name", None, QtGui.QApplication.UnicodeUTF8))
        self.name.setPlaceholderText(QtGui.QApplication.translate("newApplicationDialog", "New Application", None, QtGui.QApplication.UnicodeUTF8))

