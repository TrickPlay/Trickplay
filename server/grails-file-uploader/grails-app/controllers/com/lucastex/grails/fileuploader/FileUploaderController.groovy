package com.lucastex.grails.fileuploader;

import org.apache.commons.vfs.*;
import org.apache.commons.io.IOUtils;
import java.io.*;

class FileUploaderController {
	
    //messagesource
    def messageSource
    
    //defaultaction
    def defaultAction = "process"
    
    def process = {
        
        //upload group
        def upload = params.upload
        println "params.upload = ${upload}"
        //config handler
        def config = grailsApplication.config.fileuploader[upload]
        
        //request file
        def file = request.getFile("file")
        
        //base path to save file
        def path = config.path
        //println "config.path ${config.path}"
        
        if (!path.endsWith("/"))
        path = path+"/"
        
        /**************************
			check if file exists
		**************************/
        if (file.size == 0) {
            def msg = messageSource.getMessage("fileupload.upload.nofile", null, request.locale)
            log.debug msg
            flash.message = msg
            redirect controller: params.errorController, action: params.errorAction
            return
        }
        
        /***********************
			check extensions
		************************/
        def fileExtension = file.originalFilename.substring(file.originalFilename.lastIndexOf('.')+1)
        if (!config.allowedExtensions[0].equals("*")) {
            if (!config.allowedExtensions.contains(fileExtension)) {
                def msg = messageSource.getMessage("fileupload.upload.unauthorizedExtension", [fileExtension, config.allowedExtensions] as Object[], request.locale)
                log.debug msg
                flash.message = msg
                redirect controller: params.errorController, action: params.errorAction
                return
            }
        }
        
        
        /*********************
			check file size
		**********************/
        if (config.maxSize) { //if maxSize config exists
            def maxSizeInKb = ((int) (config.maxSize/1024))
            if (file.size > config.maxSize) { //if filesize is bigger than allowed
                log.debug "FileUploader plugin received a file bigger than allowed. Max file size is ${maxSizeInKb} kb"
                flash.message = messageSource.getMessage("fileupload.upload.fileBiggerThanAllowed", [maxSizeInKb] as Object[], request.locale)
                redirect controller: params.errorController, action: params.errorAction
                return
            }
        } 
        
        //reaches here if file.size is smaller or equal config.maxSize or if config.maxSize is not configured. In this case
        ///plugin will accept any size of files.
            
            //sets new path
        def currentTime = System.currentTimeMillis()
        path = path+currentTime+"/"
        path = path+file.originalFilename
        
        //move file
        log.debug "FileUploader plugin received a ${file.size}b file. Moving to ${path}"
        FileSystemManager fsManager = VFS.getManager();
        FileObject dest = fsManager.resolveFile(path, config.opts.fileSystemOptions);
        FileContent destContent = dest.getContent();
        InputStream srcStream = file.getInputStream();
        IOUtils.copy(srcStream, destContent.getOutputStream());
        destContent.close();
        srcStream.close();

        //save it on the database
        def ufile = new UFile()
        ufile.name = file.originalFilename
        ufile.size = file.size
        ufile.extension = fileExtension
        ufile.fileGroup = upload
        ufile.dateUploaded = new Date(currentTime)
        ufile.path = path
        ufile.downloads = 0
        ufile.save()
        
        redirect controller: params.successController, action: params.successAction, params:[ufileId:ufile.id]
    }
}
