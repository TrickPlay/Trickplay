package com.intridea.io.vfs.provider.s3;

import org.apache.commons.vfs.FileName;
import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSystemException;
import org.apache.commons.vfs.FileSystemOptions;
import org.apache.commons.vfs.provider.AbstractFileSystem;
import org.apache.log4j.Logger;

import org.jets3t.service.S3Service;
import org.jets3t.service.S3ServiceException;
import org.jets3t.service.model.S3Bucket;


import java.util.Collection;

/**
 * An S3 file system.
 * 
 * @author Marat Komarov
 * @author Matthias L. Jugel
 */
public class S3FileSystem extends AbstractFileSystem {
	private S3Service service;
	private S3Bucket bucket;

	private Logger logger = Logger.getLogger(S3FileSystem.class);
	
	public S3FileSystem(S3FileName fileName, S3Service service,
			FileSystemOptions fileSystemOptions) throws FileSystemException {
		super(fileName, null, fileSystemOptions);
		String bucketId = fileName.getRootFile();
		try {
			this.service = service;
			bucket = new S3Bucket(bucketId);
			if (!service.isBucketAccessible(bucketId)) {
				bucket = service.createBucket(bucketId);
			}
			logger.info(String.format("Created new S3 FileSystem %s", bucketId));
		} catch (S3ServiceException e) {
			String s3message = e.getS3ErrorMessage();
			if (s3message != null) {
				throw new FileSystemException(s3message);	
			} else {
				throw new FileSystemException(e);
			}
		}
	}
	
	@SuppressWarnings("unchecked")
	protected void addCapabilities(Collection caps) {
		caps.addAll(S3FileProvider.capabilities);
	}

	protected FileObject createFile(FileName fileName) throws Exception {
		return new S3FileObject(fileName, this, service, bucket);
	}
}
