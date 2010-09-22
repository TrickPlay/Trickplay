package com.lucastex.grails.fileuploader;

import org.apache.commons.vfs.FileSystemOptions;
import org.apache.commons.vfs.auth.StaticUserAuthenticator;
import org.apache.commons.vfs.impl.DefaultFileSystemConfigBuilder;

class VFSOptions {

    private String domain;
    private String username;
    private String password;
    private FileSystemOptions opts = new FileSystemOptions();
    private UrlGenerator ugen;

    public VFSOptions(String domain, String username, String password, UrlGenerator ugen)
    {
        this.domain = domain;
        this.username = username;
        this.password = password;
        if (username != null && password != null) {
            StaticUserAuthenticator auth = new StaticUserAuthenticator(domain, username, password);
            DefaultFileSystemConfigBuilder.getInstance().setUserAuthenticator(opts, auth);
        }
        if (ugen == null) {
            this.ugen = new UrlGenerator();
        } else {
            this.ugen = ugen;
        }
    }

    public FileSystemOptions getFileSystemOptions() {
        return this.opts;
    }

    public String getPublicUrl(String path)
    {
        return ugen.getUrl(path);
    }
}
