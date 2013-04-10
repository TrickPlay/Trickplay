#!/usr/bin/env python

# Allow keyboard interrupt with ^C
import os, sys, signal

from wizard import Wizard
from main import MainWindow

from PyQt4.QtGui import QApplication
from PyQt4.QtCore import QCoreApplication, QSettings, QT_VERSION_STR, QProcessEnvironment


def main(argv):

    path = None
    apath = None

    try:
        path = argv[1]
    except IndexError:
        pass

    try:
        app = QApplication(argv)

        QCoreApplication.setOrganizationDomain('www.trickplay.com');
        QCoreApplication.setOrganizationName('Trickplay');
        QCoreApplication.setApplicationName('Trickplay VisalEditor 2');
        QCoreApplication.setApplicationVersion('0.0.1');
            
        s = QProcessEnvironment.systemEnvironment().toStringList()
        for item in s:
            k , v = str( item ).split( "=" , 1 )
            if k == 'PWD':
                apath = v
        
        apath = os.path.join(apath, os.path.dirname(str(argv[0])))
        main = MainWindow(app, apath)
        main.show()
        main.raise_()

        wizard = Wizard(main)
        app.main = main
        path = wizard.start(path)
        if path:
            settings = QSettings()
            settings.setValue('path', path) 
            app.setActiveWindow(main)
            main.setCurrentProject(path, wizard.filesToOpen())

        sys.exit(app.exec_())

    except KeyboardInterrupt:
		exit("Exited")

def sigint_handler(*args):
    print("Handler for the SIGINT signal.")
    app.main.exit()
    sys.exit(0)

if __name__ == '__main__':
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    signal.signal(signal.SIGINT, sigint_handler)
    main(sys.argv)

    
