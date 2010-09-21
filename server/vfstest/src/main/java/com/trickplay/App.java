package com.trickplay;

import org.apache.commons.vfs.*;
import org.apache.commons.vfs.auth.StaticUserAuthenticator;
import org.apache.commons.vfs.impl.DefaultFileSystemConfigBuilder;
import org.apache.commons.io.IOUtils;
import java.io.*;

/**
 */
public class App 
{
    public static void main(String[] argv) throws Exception
    {
	try {
	    org.apache.log4j.BasicConfigurator.configure();
	    StaticUserAuthenticator auth = new StaticUserAuthenticator(null, "<aws-access-key>", "<aws-secret-key>");
	    FileSystemOptions opts = new FileSystemOptions();
	    DefaultFileSystemConfigBuilder.getInstance().setUserAuthenticator(opts, auth);
	    FileSystemManager fsManager = VFS.getManager();

	    // Create bucket
	    if (argv[0].equals("create")) {
		FileObject dir = fsManager.resolveFile("s3://trickplay/"+argv[1]+"/", opts);
		dir.createFolder();
	    }
	    
	    // Upload file to S3
	    if (argv[0].equals("upload")) {
		FileObject src = fsManager.resolveFile(new File(argv[1]).getAbsolutePath(), opts);
		FileObject dest = fsManager.resolveFile("s3://trickplay/"+argv[2], opts);
		dest.copyFrom(src, Selectors.SELECT_SELF);
	    }
	    
	    // Download from S3
	    if (argv[0].equals("download")) {
		FileObject remote_file = fsManager.resolveFile("s3://trickplay/"+argv[1], opts);
		//File local_file = File.createTempFile("vfs.", ".s3");
		File local_file = new File(argv[2]);
		FileOutputStream out = new FileOutputStream(local_file);
		InputStream in = remote_file.getContent().getInputStream();
		IOUtils.copy(in, out);
	    }
	    
	    // Delete bucket
	    if (argv[0].equals("delete")) {
		FileObject dir = fsManager.resolveFile("s3://trickplay/"+argv[1]+"/", opts);
		dir.delete();
	    }
	} catch (Exception e) {
	    e.printStackTrace();
	}

    }
}
