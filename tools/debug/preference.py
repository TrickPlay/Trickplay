import sys
import os
import re

from connection import *
from PyQt4.QtGui import *
from PyQt4.QtCore import *
from UI.Preference import Ui_preferenceDialog

class Preference():

    def __init__(self, main = None):
        self.main= main
        self.lexerLua = ["Default", "Comment", "Line Comment", "", "Number", "Keyword", "String", "Character", "Literal String",  "", "Operator", "Identifier", "Unclosed String", "Basic Functions", "Library Functions",
        "Coroutines, I/O, etc.", "", "", "", "", "Label"] 
        self.lexerLuaDesc = ["The Default.", "A block comment.\n--[[ THIS TEXT IS A BLOCK COMMENT ]]--", "A line comment.\n-- THIS TEXT IS A LINE COMMENT", "", "A Number.", "A Keyword.", "A String.", "A Character.", "A literal string.",  "Preprocessor.", "An operator.", "An identifier.", "The end of a line where a string is not closed.", "Basic functions.", "String, table and maths functions.", "Coroutines, I/O and system facilities.", "", "", "", "", "A label."]
        self.lexerLuaFontString = []
        self.lexerLuaFont = []

        # Default Font
        font = QFont()
        font.setPointSize(9)

        # Check settings 
        settings = QSettings()
        self.fsFontString = str(settings.value("fsFontString", "Inconsolata 12").toString())
        self.fsFont = settings.value("fsFont", font).toString()
        font.fromString(self.fsFont)
        self.fsFont = font
	
        # Default Font
        font = QFont()
        font.setPointSize(12)
        font.setFamily("Inconsolata")
	
        self.inspFontString = str(settings.value("inspFontString", "Inconsolata 12").toString())
        self.inspFont = str(settings.value("inspFont", font).toString())
        font.fromString(self.inspFont)
        self.inspFont = font

        # Default Font
        font = QFont()
        font.setPointSize(12)
        font.setFamily("Inconsolata")

        self.consoleFontString = str(settings.value("consoleFontString", "Inconsolata 12").toString())
        self.consoleFont = str(settings.value("consoleFont", font).toString())
        font.fromString(self.consoleFont)
        self.consoleFont = font

        # default font
        font = QFont()
        font.setPointSize(12)
        font.setFamily("Inconsolata")

        self.btFontString = str(settings.value("btFontString", "Inconsolata 12").toString())
        self.btFont = str(settings.value("btFont", font).toString())
        font.fromString(self.btFont)
        self.btFont = font

        # default font
        font = QFont()
        font.setPointSize(12)
        font.setFamily("Inconsolata")

        self.vFontString = str(settings.value("vFontString", "Inconsolata 12").toString())
        self.vFont = str(settings.value("vFont", font).toString())
        font.fromString(self.vFont)
        self.vFont = font
	
        for index in range(0, len(self.lexerLua)):
            # default font
            font = QFont()
            font.setPointSize(13)
            font.setFamily("Inconsolata")

            self.lexerLuaFontString.append(str(settings.value(self.lexerLua[index]+"String", "Inconsolata 13").toString()))	    
            self.lexerLuaFont.append(str(settings.value(self.lexerLua[index], font).toString()))	    
            font.fromString(self.lexerLuaFont[index])
            self.lexerLuaFont[index] = font

        self.lexerIndex= 0

	
    def start(self):

        self.setpreferencedialog()
        
    def setpreferencedialog(self):
        """
        new app dialog
        """
                
        self.dialog = QDialog()
        self.ui = Ui_preferenceDialog()
        self.ui.setupUi(self.dialog)
        
        QObject.connect(self.ui.fileSystemSelect, SIGNAL('clicked()'), self.fileSystemSelect)
        QObject.connect(self.ui.inspectorSelect, SIGNAL('clicked()'), self.inspectorSelect)
        QObject.connect(self.ui.consoleSelect, SIGNAL('clicked()'), self.consoleSelect)
        QObject.connect(self.ui.backtraceSelect, SIGNAL('clicked()'), self.backtraceSelect)
        QObject.connect(self.ui.variableSelect, SIGNAL('clicked()'), self.variableSelect)

        QObject.connect(self.ui.fontSelect, SIGNAL('clicked()'), self.fontSelect)
        QObject.connect(self.ui.bColorSelect, SIGNAL('clicked()'), self.bColorSelect)
        QObject.connect(self.ui.fColorSelect, SIGNAL('clicked()'), self.fColorSelect)
        QObject.connect(self.ui.tableWidget, SIGNAL("cellClicked(int, int)"), self.cellClicked)
	
                  
        # font : show current font settings         
        self.ui.filesystemFont.setText(self.fsFontString)
        self.ui.filesystemFont.setFont(self.fsFont)
	
        self.ui.inspectorFont.setText(self.inspFontString)
        self.ui.inspectorFont.setFont(self.inspFont)

        self.ui.consoleFont.setText(self.consoleFontString)
        self.ui.consoleFont.setFont(self.consoleFont)

        self.ui.backtraceFont.setText(self.btFontString)
        self.ui.backtraceFont.setFont(self.btFont)

        self.ui.variableFont.setText(self.vFontString)
        self.ui.variableFont.setFont(self.vFont)

        # EditorStyle : Construct tableWidget 

        n = 0 
        for index in range(0, len(self.lexerLua)):
            if self.lexerLua[index] != "":
                newitem = QTableWidgetItem()
                newitem.setText(self.lexerLua[index])
                self.ui.tableWidget.setItem(n, 0, newitem)
                if n == 0 :
                    self.ui.tableWidget.setCurrentItem(newitem)
                n += 1

        self.ui.tableWidget.verticalHeader().setDefaultSectionSize(18)
        self.ui.tableWidget.horizontalHeader().setDefaultSectionSize(200)
        self.ui.tableWidget.show()
        # EditorStyle: Show description and preview of the first item of table ("default")
        self.ui.descriptionText.setText(self.lexerLuaDesc[0])
        self.ui.previewText.setText(self.lexerLuaFontString[0]+"\n"+"abcdefghijk ABCDEFGHIJK")
        self.ui.previewText.setFont(self.lexerLuaFont[0])
	
        self.dialog.exec_()
            
    def fileSystemSelect(self) :
        font, ok = QFontDialog.getFont(self.fsFont)
        if ok:
            # the user clicked OK and font is set to the font the user Selected
            family = font.family()
            size = font.pointSize()
            self.fsFontString = "%s"%family+" %i"%size
            self.ui.filesystemFont.setText(self.fsFontString)
            self.ui.filesystemFont.setFont(font)
            settings = QSettings()
            settings.setValue("fsFontString", self.fsFontString)
            settings.setValue("fsFont", font)
            self.fsFont = font
            self.main.fileSystem.ui.view.setFont(font)

        else:
            return
	
    def inspectorSelect(self):
        font, ok = QFontDialog.getFont(self.inspFont)
        if ok:
            # the user clicked OK and font is set to the font the user Selected
            family = font.family()
            size = font.pointSize()
            self.inspFontString = "%s"%family+" %i"%size
            self.ui.inspectorFont.setText(self.inspFontString)
            self.ui.inspectorFont.setFont(font)
            settings = QSettings()
            settings.setValue("inspFontString", self.inspFontString)
            settings.setValue("inspFont", font)
            self.inspFont = font
            if self.main.inspector.ui.refresh.isEnabled() == True:
                self.main.inspector.refresh()
        else:
            return

    def consoleSelect(self):
        font, ok = QFontDialog.getFont(self.consoleFont)
        if ok:
            # the user clicked OK and font is set to the font the user Selected
            family = font.family()
            size = font.pointSize()
            self.consoleFontString = "%s"%family+" %i"%size
            self.ui.consoleFont.setText(self.consoleFontString)
            self.ui.consoleFont.setFont(font)
            settings = QSettings()
            settings.setValue("consoleFontString", self.consoleFontString)
            settings.setValue("consoleFont", font)
            self.consoleFont = font
            self.main.console.ui.textEdit.setFont(font)
            self.main.ui.interactive.setFont(font)
        else:
            return

    def backtraceSelect(self):
        font, ok = QFontDialog.getFont(self.btFont)
        if ok:
            # the user clicked OK and font is set to the font the user Selected
            family = font.family()
            size = font.pointSize()
            self.btFontString = "%s"%family+" %i"%size
            self.ui.backtraceFont.setText(self.btFontString)
            self.ui.backtraceFont.setFont(font)
            settings = QSettings()
            settings.setValue("btFontString", self.btFontString)
            settings.setValue("btFont", font)
            self.btFont = font
            self.main.backtrace.ui.traceTable.setFont(font)
        else:
            return

    def variableSelect(self):
        font, ok = QFontDialog.getFont(self.vFont)
        if ok:
            # the user clicked OK and font is set to the font the user Selected
            family = font.family()
            size = font.pointSize()
            self.vFontString = "%s"%family+" %i"%size
            self.ui.variableFont.setText(self.vFontString)
            self.ui.variableFont.setFont(font)
            settings = QSettings()
            settings.setValue("vFontString", self.vFontString)
            settings.setValue("vFont", font)
            self.vFont = font
            self.main._debug.font = font

            #if debug table is not empty, redraw it with new font settings 
            if self.main._debug.ui.localTable.rowCount() > 0 or self.main._debug.ui.breakTable.rowCount() > 0:
                 self.main._deviceManager.send_debugger_command(DBG_CMD_INFO)
                 self.main._deviceManager.send_debugger_command(DBG_CMD_BREAKPOINT)
        else:
            return

    def fontSelect(self):
        pass
    def bColorSelect(self):
        pass
    def fColorSelect(self):
        pass
    
    def cellClicked(self, r, c):
        
        cellItem = self.ui.tableWidget.item(r, 0)
        lexerLua = str(cellItem.text())	
        index = self.lexerLua.index(lexerLua)

        self.ui.descriptionText.setText(self.lexerLuaDesc[index])
        self.ui.previewText.setText(self.lexerLuaFontString[index]+"\n"+"abcdefghijk ABCDEFGHIJK")
        self.ui.previewText.setFont(self.lexerLuaFont[index])
