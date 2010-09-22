package com.lucastex.grails.fileuploader;

import org.codehaus.groovy.grails.commons.ConfigurationHolder;
import org.apache.commons.vfs.*;
import java.io.*;

class UFile {
    def configService
    def grailsApplication 

    Long size
    String path
    String name
    String extension
    String fileGroup
    Date dateUploaded
    Integer downloads
    
    static constraints = {
        size(min:0L)
        path()
        name()
        extension()
        fileGroup()
        dateUploaded()
        downloads()
    }

    def getPublicUrl() {
        return ConfigurationHolder.config.fileuploader[fileGroup].opts.getPublicUrl(path);
    }
    
    def afterDelete() {
        try {
            def config = ConfigurationHolder.config.fileuploader[fileGroup];
            FileSystemManager fsManager = VFS.getManager();
            FileObject f = fsManager.resolveFile(path, config.opts.fileSystemOptions);
            f.delete();
        } catch (Exception exp) {
            log.error "Error deleting file: ${e.message}"
            log.error exp
        }
    }
}
