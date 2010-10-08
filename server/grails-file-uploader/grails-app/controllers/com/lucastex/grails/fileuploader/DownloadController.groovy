package com.lucastex.grails.fileuploader

import org.apache.commons.vfs.*;
import org.apache.commons.io.IOUtils;
import java.io.*;

class DownloadController {
    
    def messageSource
    
    def index = { 
	
        UFile ufile = UFile.get(params.id)
        def config = grailsApplication.config.fileuploader[ufile.fileGroup]
        if (!ufile) {
            def msg = messageSource.getMessage("fileupload.download.nofile", [params.id] as Object[], request.locale)
            log.debug msg
            flash.message = msg
            redirect controller: params.errorController, action: params.errorAction
            return
        }
        
        FileSystemManager fsManager = VFS.getManager();
        FileObject file = fsManager.resolveFile(ufile.path, config.opts.fileSystemOptions);

        if (file.exists()) {
            log.debug "Serving file id=[${ufile.id}] for the ${ufile.downloads} to ${request.remoteAddr}"
            ufile.downloads++;
            ufile.save();
            response.setContentType("application/octet-stream");
            response.setHeader("Content-disposition", "${params.contentDisposition}; filename=${file.name}");
            InputStream is = file.getContent().getInputStream();
            IOUtils.copy(is, response.outputStream);
            return
        } else {
            def msg = messageSource.getMessage("fileupload.download.filenotfound", [ufile.name] as Object[], request.locale)
            log.error msg
            flash.message = msg
            redirect controller: params.errorController, action: params.errorAction
            return
        }
    }
}
