package com.lucastex.grails.fileuploader;

import com.lucastex.grails.fileuploader.URIBuilder;
import java.net.URI;

class UrlGenerator {

    private String protocol = null;
    private String host = null;
    private String fragment = null;
    private String replace = null;
    private String prefix = null;

    public UrlGenerator() {}

    public UrlGenerator(String protocol, String host, String prefix, String fragment, String replace)
    {
	this.protocol = protocol;
	this.host = host;
	this.fragment = fragment;
	this.replace = replace;
	if (prefix != null && !prefix.startsWith("/")) {
	    this.prefix = "/" + prefix;
	} else {
	    this.prefix = prefix;
	}
    }

    public String getUrl(String path)
    {
	if (fragment != null && replace !=null)	path = path.replaceFirst(fragment, replace);
	try {
	    URIBuilder urib = new URIBuilder(path);
	    URI uri = new URI(path);
	    if (protocol != null) {
		urib.setScheme(protocol);
	    }
	    if (host != null) {
		urib.setHost(host);
	    }
	    if (prefix != null) {
		urib.setPath("/" + prefix + uri.getPath());
	    }
	    path = urib.toString();
	} catch (Exception e) { 
	    e.printStackTrace();
	}
	return path;
    }

}