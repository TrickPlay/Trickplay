# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'Search2.ui'
#
# Created: Tue Feb  7 16:39:26 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_searchDialog(object):
    def setupUi(self, searchDialog):
        searchDialog.setObjectName(_fromUtf8("searchDialog"))
        searchDialog.resize(470, 150)
        font = QtGui.QFont()
        font.setPointSize(10)
        searchDialog.setFont(font)
        searchDialog.setModal(True)
        self.buttonBox = QtGui.QDialogButtonBox(searchDialog)
        self.buttonBox.setGeometry(QtCore.QRect(280, 110, 176, 27))
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Close|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.layoutWidget = QtGui.QWidget(searchDialog)
        self.layoutWidget.setGeometry(QtCore.QRect(10, 10, 451, 28))
        self.layoutWidget.setObjectName(_fromUtf8("layoutWidget"))
        self.gridLayout = QtGui.QGridLayout(self.layoutWidget)
        self.gridLayout.setMargin(0)
        self.gridLayout.setHorizontalSpacing(10)
        self.gridLayout.setVerticalSpacing(0)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.search_txt = QtGui.QLineEdit(self.layoutWidget)
        self.search_txt.setPlaceholderText(_fromUtf8(""))
        self.search_txt.setObjectName(_fromUtf8("search_txt"))
        self.gridLayout.addWidget(self.search_txt, 0, 1, 1, 1)
        self.labelName = QtGui.QLabel(self.layoutWidget)
        font = QtGui.QFont()
        font.setPointSize(10)
        self.labelName.setFont(font)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.gridLayout.addWidget(self.labelName, 0, 0, 1, 1)
        self.verticalLayoutWidget_2 = QtGui.QWidget(searchDialog)
        self.verticalLayoutWidget_2.setGeometry(QtCore.QRect(230, 50, 231, 41))
        self.verticalLayoutWidget_2.setObjectName(_fromUtf8("verticalLayoutWidget_2"))
        self.verticalLayout_2 = QtGui.QVBoxLayout(self.verticalLayoutWidget_2)
        self.verticalLayout_2.setMargin(0)
        self.verticalLayout_2.setObjectName(_fromUtf8("verticalLayout_2"))
        self.checkBox_word = QtGui.QCheckBox(self.verticalLayoutWidget_2)
        self.checkBox_word.setChecked(True)
        self.checkBox_word.setObjectName(_fromUtf8("checkBox_word"))
        self.verticalLayout_2.addWidget(self.checkBox_word)
        self.checkBox_wrap = QtGui.QCheckBox(self.verticalLayoutWidget_2)
        self.checkBox_wrap.setChecked(True)
        self.checkBox_wrap.setObjectName(_fromUtf8("checkBox_wrap"))
        self.verticalLayout_2.addWidget(self.checkBox_wrap)
        self.verticalLayoutWidget_3 = QtGui.QWidget(searchDialog)
        self.verticalLayoutWidget_3.setGeometry(QtCore.QRect(10, 50, 221, 41))
        self.verticalLayoutWidget_3.setObjectName(_fromUtf8("verticalLayoutWidget_3"))
        self.verticalLayout_3 = QtGui.QVBoxLayout(self.verticalLayoutWidget_3)
        self.verticalLayout_3.setMargin(0)
        self.verticalLayout_3.setObjectName(_fromUtf8("verticalLayout_3"))
        self.checkBox_case = QtGui.QCheckBox(self.verticalLayoutWidget_3)
        self.checkBox_case.setChecked(True)
        self.checkBox_case.setObjectName(_fromUtf8("checkBox_case"))
        self.verticalLayout_3.addWidget(self.checkBox_case)
        self.checkBox_forward = QtGui.QCheckBox(self.verticalLayoutWidget_3)
        self.checkBox_forward.setChecked(True)
        self.checkBox_forward.setObjectName(_fromUtf8("checkBox_forward"))
        self.verticalLayout_3.addWidget(self.checkBox_forward)

        self.retranslateUi(searchDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), searchDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), searchDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(searchDialog)

    def retranslateUi(self, searchDialog):
        searchDialog.setWindowTitle(QtGui.QApplication.translate("searchDialog", "Search", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("searchDialog", "Search for:", None, QtGui.QApplication.UnicodeUTF8))
        self.checkBox_word.setText(QtGui.QApplication.translate("searchDialog", "Match entire word only", None, QtGui.QApplication.UnicodeUTF8))
        self.checkBox_wrap.setText(QtGui.QApplication.translate("searchDialog", "Wrap around", None, QtGui.QApplication.UnicodeUTF8))
        self.checkBox_case.setText(QtGui.QApplication.translate("searchDialog", "Match case", None, QtGui.QApplication.UnicodeUTF8))
        self.checkBox_forward.setText(QtGui.QApplication.translate("searchDialog", "Search forward", None, QtGui.QApplication.UnicodeUTF8))

