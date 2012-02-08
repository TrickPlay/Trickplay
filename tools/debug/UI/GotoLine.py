# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'GotoLine.ui'
#
# Created: Wed Feb  8 12:30:58 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_gotoLineDialog(object):
    def setupUi(self, gotoLineDialog):
        gotoLineDialog.setObjectName(_fromUtf8("gotoLineDialog"))
        gotoLineDialog.resize(224, 85)
        font = QtGui.QFont()
        font.setPointSize(10)
        gotoLineDialog.setFont(font)
        gotoLineDialog.setModal(True)
        self.gridLayout_2 = QtGui.QGridLayout(gotoLineDialog)
        self.gridLayout_2.setVerticalSpacing(12)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.buttonBox = QtGui.QDialogButtonBox(gotoLineDialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.gridLayout_2.addWidget(self.buttonBox, 1, 0, 1, 1)
        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setHorizontalSpacing(10)
        self.gridLayout.setVerticalSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.line_txt = QtGui.QLineEdit(gotoLineDialog)
        self.line_txt.setPlaceholderText(_fromUtf8(""))
        self.line_txt.setObjectName(_fromUtf8("line_txt"))
        self.gridLayout.addWidget(self.line_txt, 0, 1, 1, 1)
        self.labelName = QtGui.QLabel(gotoLineDialog)
        font = QtGui.QFont()
        font.setPointSize(10)
        self.labelName.setFont(font)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.gridLayout.addWidget(self.labelName, 0, 0, 1, 1)
        self.gridLayout_2.addLayout(self.gridLayout, 0, 0, 1, 1)

        self.retranslateUi(gotoLineDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), gotoLineDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), gotoLineDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(gotoLineDialog)

    def retranslateUi(self, gotoLineDialog):
        gotoLineDialog.setWindowTitle(QtGui.QApplication.translate("gotoLineDialog", "Go to Line", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("gotoLineDialog", "Enter line number:", None, QtGui.QApplication.UnicodeUTF8))

