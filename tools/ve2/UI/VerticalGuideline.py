# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'VerticalGuideline.ui'
#
# Created: Wed Aug 15 15:38:50 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_vertGuideDialog(object):
    def setupUi(self, vertGuideDialog):
        vertGuideDialog.setObjectName(_fromUtf8("vertGuideDialog"))
        vertGuideDialog.resize(286, 86)
        font = QtGui.QFont()
        font.setPointSize(10)
        vertGuideDialog.setFont(font)
        vertGuideDialog.setModal(True)
        self.buttonBox = QtGui.QDialogButtonBox(vertGuideDialog)
        self.buttonBox.setGeometry(QtCore.QRect(104, 56, 176, 27))
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.layoutWidget = QtGui.QWidget(vertGuideDialog)
        self.layoutWidget.setGeometry(QtCore.QRect(9, 9, 271, 44))
        self.layoutWidget.setObjectName(_fromUtf8("layoutWidget"))
        self.gridLayout = QtGui.QGridLayout(self.layoutWidget)
        self.gridLayout.setSpacing(0)
        self.gridLayout.setMargin(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.spinBox = QtGui.QSpinBox(self.layoutWidget)
        self.spinBox.setMaximum(9999)
        self.spinBox.setObjectName(_fromUtf8("spinBox"))
        self.gridLayout.addWidget(self.spinBox, 1, 0, 1, 1)
        self.labelName = QtGui.QLabel(self.layoutWidget)
        font = QtGui.QFont()
        font.setPointSize(10)
        self.labelName.setFont(font)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.gridLayout.addWidget(self.labelName, 0, 0, 1, 1)
        self.deleteButton = QtGui.QPushButton(vertGuideDialog)
        self.deleteButton.setGeometry(QtCore.QRect(10, 56, 89, 27))
        self.deleteButton.setObjectName(_fromUtf8("deleteButton"))

        self.retranslateUi(vertGuideDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), vertGuideDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), vertGuideDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(vertGuideDialog)

    def retranslateUi(self, vertGuideDialog):
        vertGuideDialog.setWindowTitle(QtGui.QApplication.translate("vertGuideDialog", "Vertical Guideline", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("vertGuideDialog", "X Position:", None, QtGui.QApplication.UnicodeUTF8))
        self.deleteButton.setText(QtGui.QApplication.translate("vertGuideDialog", "Delete", None, QtGui.QApplication.UnicodeUTF8))

