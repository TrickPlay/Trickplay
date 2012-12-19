# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'NewProjectDialog.ui'
#
# Created: Mon Jun 11 10:05:22 2012
#      by: PyQt4 UI code generator 4.8.3
#
# WARNING! All changes made in this file will be lost!

from PyQt4 import QtCore, QtGui

try:
    _fromUtf8 = QtCore.QString.fromUtf8
except AttributeError:
    _fromUtf8 = lambda s: s

class Ui_newProjectDialog(object):
    def setupUi(self, newProjectDialog):
        newProjectDialog.setObjectName(_fromUtf8("newProjectDialog"))
        newProjectDialog.resize(456, 158)
        font = QtGui.QFont()
        font.setPointSize(10)
        newProjectDialog.setFont(font)
        newProjectDialog.setModal(True)
        self.gridLayout_2 = QtGui.QGridLayout(newProjectDialog)
        self.gridLayout_2.setVerticalSpacing(12)
        self.gridLayout_2.setObjectName(_fromUtf8("gridLayout_2"))
        self.gridLayout = QtGui.QGridLayout()
        self.gridLayout.setHorizontalSpacing(16)
        self.gridLayout.setVerticalSpacing(8)
        self.gridLayout.setObjectName(_fromUtf8("gridLayout"))
        self.labelDirectory = QtGui.QLabel(newProjectDialog)
        self.labelDirectory.setObjectName(_fromUtf8("labelDirectory"))
        self.gridLayout.addWidget(self.labelDirectory, 0, 0, 1, 1)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setSpacing(6)
        self.horizontalLayout.setSizeConstraint(QtGui.QLayout.SetMinimumSize)
        self.horizontalLayout.setObjectName(_fromUtf8("horizontalLayout"))
        self.directory = QtGui.QLineEdit(newProjectDialog)
        self.directory.setReadOnly(True)
        self.directory.setObjectName(_fromUtf8("directory"))
        self.horizontalLayout.addWidget(self.directory)
        self.browse = QtGui.QPushButton(newProjectDialog)
        self.browse.setObjectName(_fromUtf8("browse"))
        self.horizontalLayout.addWidget(self.browse)
        self.gridLayout.addLayout(self.horizontalLayout, 0, 1, 1, 1)
        self.labelId = QtGui.QLabel(newProjectDialog)
        self.labelId.setObjectName(_fromUtf8("labelId"))
        self.gridLayout.addWidget(self.labelId, 1, 0, 1, 1)
        self.id = QtGui.QLineEdit(newProjectDialog)
        self.id.setObjectName(_fromUtf8("id"))
        self.gridLayout.addWidget(self.id, 1, 1, 1, 1)
        self.labelName = QtGui.QLabel(newProjectDialog)
        self.labelName.setObjectName(_fromUtf8("labelName"))
        self.gridLayout.addWidget(self.labelName, 2, 0, 1, 1)
        self.name = QtGui.QLineEdit(newProjectDialog)
        self.name.setObjectName(_fromUtf8("name"))
        self.gridLayout.addWidget(self.name, 2, 1, 1, 1)
        self.gridLayout_2.addLayout(self.gridLayout, 0, 0, 1, 1)
        self.horizontalLayout_2 = QtGui.QHBoxLayout()
        self.horizontalLayout_2.setObjectName(_fromUtf8("horizontalLayout_2"))
        self.projectDirName = QtGui.QLabel(newProjectDialog)
        self.projectDirName.setText(_fromUtf8(""))
        self.projectDirName.setObjectName(_fromUtf8("projectDirName"))
        self.horizontalLayout_2.addWidget(self.projectDirName)
        self.buttonBox = QtGui.QDialogButtonBox(newProjectDialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName(_fromUtf8("buttonBox"))
        self.horizontalLayout_2.addWidget(self.buttonBox)
        self.gridLayout_2.addLayout(self.horizontalLayout_2, 1, 0, 1, 1)

        self.retranslateUi(newProjectDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("accepted()")), newProjectDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL(_fromUtf8("rejected()")), newProjectDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(newProjectDialog)
        newProjectDialog.setTabOrder(self.directory, self.browse)
        newProjectDialog.setTabOrder(self.browse, self.id)
        newProjectDialog.setTabOrder(self.id, self.name)

    def retranslateUi(self, newProjectDialog):
        newProjectDialog.setWindowTitle(QtGui.QApplication.translate("newProjectDialog", "New Project", None, QtGui.QApplication.UnicodeUTF8))
        self.labelDirectory.setText(QtGui.QApplication.translate("newProjectDialog", "Directory", None, QtGui.QApplication.UnicodeUTF8))
        self.directory.setText(QtGui.QApplication.translate("newProjectDialog", "Project Directory", None, QtGui.QApplication.UnicodeUTF8))
        self.browse.setText(QtGui.QApplication.translate("newProjectDialog", "Browse", None, QtGui.QApplication.UnicodeUTF8))
        self.labelId.setText(QtGui.QApplication.translate("newProjectDialog", "Company Identifier", None, QtGui.QApplication.UnicodeUTF8))
        self.id.setPlaceholderText(QtGui.QApplication.translate("newProjectDialog", "com.organization", None, QtGui.QApplication.UnicodeUTF8))
        self.labelName.setText(QtGui.QApplication.translate("newProjectDialog", "App Name", None, QtGui.QApplication.UnicodeUTF8))
        self.name.setPlaceholderText(QtGui.QApplication.translate("newProjectDialog", "newapplication", None, QtGui.QApplication.UnicodeUTF8))

    def paintEvent(self, event):
        """create a painting canvas"""
        painter = QPainter()
        painter.begin(self)
        painter.setRenderHint(QPainter.Antialiasing)
        # use the brush for a texture/wallpaper background
        # supply a background image file you have (add needed path)
        painter.setBrush(QBrush(QPixmap("BG_GoldSwirl.gif")))
        painter.drawRect(event.rect())
        # optionally write something in the wallpaper
        # (check the fonts available on your computer)
        painter.setFont(QFont('Freestyle Script', 48))
        painter.drawText(50, 160, "Hello World!")
        painter.end()


