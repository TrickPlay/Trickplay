package com.lucastex.grails.fileuploader;

import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.http.NameValuePair;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.message.BasicNameValuePair;

/**
 * This class implements a mutable URI.  All <code>set</code>, <code>add</code> 
 * and <code>remove</code> methods affect this class' internal URI 
 * representation.  All mutator methods support chaining, e.g.
 * <pre>
 * new URIBuilder("http://www.google.com/")
 *   .setScheme( "https" )
 *   .setPort( 443 )
 *   .setPath( "some/path" )
 *   .toString();
 * </pre>
 * A slightly more 'Groovy' version would be:
 * <pre>
 * new URIBuilder('http://www.google.com/').with {
 *    scheme = 'https'
 *    port = 443
 *    path = 'some/path'
 *    query = [p1:1, p2:'two']
 * }.toString()
 * </pre>
 * @author <a href='mailto:tomstrummer+httpbuilder@gmail.com'>Tom Nichols</a>
 */
public class URIBuilder implements Cloneable {
	protected URI base;
	private final String ENC = "UTF-8"; 
	
	public URIBuilder( String url ) throws URISyntaxException {
		base = new URI(url);
	}
	
	public URIBuilder( URL url ) throws URISyntaxException {
		this.base = url.toURI();
	}
	
	/**
	 * @throws IllegalArgumentException if uri is null
	 * @param uri
	 */
	public URIBuilder( URI uri ) throws IllegalArgumentException {
		if ( uri == null ) 
			throw new IllegalArgumentException( "uri cannot be null" );
		this.base = uri;
	}
	
	/**
	 * Utility method to convert a number of type to a URI instance. 
	 * @param uri a {@link URI}, {@link URL} or any object that produces a 
	 *   valid URI string from its <code>toString()</code> result.
	 * @return a valid URI parsed from the given object
	 * @throws URISyntaxException
	 */
	public static URI convertToURI( Object uri ) throws URISyntaxException {
		if ( uri instanceof URI ) return (URI)uri;
		if ( uri instanceof URL ) return ((URL)uri).toURI();
		if ( uri instanceof URIBuilder ) return ((URIBuilder)uri).toURI();
		return new URI( uri.toString() ); // assume any other object type produces a valid URI string
	}
	
	
	/**
	 * Set the URI scheme, AKA the 'protocol.'  e.g. 
	 * <code>setScheme('https')</code> 
	 * @throws URISyntaxException if the given scheme contains illegal characters. 
	 */
	public URIBuilder setScheme( String scheme ) throws URISyntaxException {
		this.base = new URI( scheme, base.getUserInfo(), 
				base.getHost(), base.getPort(), base.getPath(),
				base.getQuery(), base.getFragment() );
		return this;
	}
	
	public URIBuilder setPort( int port ) throws URISyntaxException {
		this.base = new URI( base.getScheme(), base.getUserInfo(), 
				base.getHost(), port, base.getPath(),
				base.getQuery(), base.getFragment() );
		return this;
	}
	
	public URIBuilder setHost( String host ) throws URISyntaxException {
		this.base = new URI( base.getScheme(), base.getUserInfo(), 
				host, base.getPort(), base.getPath(),
				base.getQuery(), base.getFragment() );
		return this;
	}
	
	/**
	 * Set the path component of this URI.  The value may be absolute or 
	 * relative to the current path.
	 * e.g. <pre>
	 *   def uri = new URIBuilder( 'http://localhost/p1/p2?a=1' )
	 *   
	 *   uri.path = '/p3/p2'
	 *   assert uri.toString() == 'http://localhost/p3/p2?a=1'
	 *   
	 *   uri.path = 'p2a'
	 *   assert uri.toString() == 'http://localhost/p3/p2a?a=1'
	 *   
	 *   uri.path = '../p4'
	 *   assert uri.toString() == 'http://localhost/p4?a=1&b=2&c=3#frag'
	 * <pre>
	 * @param path the path portion of this URI, relative to the current URI.
	 * @return this URIBuilder instance, for method chaining.
	 * @throws URISyntaxException if the given path contains characters that 
	 *   cannot be converted to a valid URI
	 */
	public URIBuilder setPath( String path ) throws URISyntaxException {
		this.base = base.resolve( new URI(null,null, path, base.getQuery(), base.getFragment()) );
//		path = base.resolve( path ).getPath();
//		this.base = new URI( base.getScheme(), base.getUserInfo(), 
//				base.getHost(), base.getPort(), path,
//				base.getQuery(), base.getFragment() );
		return this;
	}
	
	/* TODO null/ zero-size check if this is ever made public */
	protected URIBuilder setQueryNVP( List<NameValuePair> nvp ) throws URISyntaxException {
		/* Passing the query string in the URI constructor will 
		 * double-escape query parameters and goober things up.  So we have 
		 * to create a full path+query+fragment and use URI#resolve() to 
		 * create the new URI.  */
		StringBuilder sb = new StringBuilder();
		String path = base.getRawPath();
		if ( path != null ) sb.append( path );
		sb.append( '?' );
		sb.append( URLEncodedUtils.format( nvp, ENC ) ); 
		String frag = base.getRawFragment();
		if ( frag != null ) sb.append( '#' ).append( frag );
		this.base = base.resolve( sb.toString() );

		return this;
	}
	
	/**
	 * Set the query portion of the URI.  For query parameters with multiple 
	 * values, put the values in a list like so:
	 * <pre>uri.query = [ p1:'val1', p2:['val2', 'val3'] ]
	 * // will produce a query string of ?p1=val1&p2=val2&p2=val3</pre>
	 * 
	 * @param params a Map of parameters that will be transformed into the query string
	 * @return this URIBuilder instance, for method chaining.
	 * @throws URISyntaxException
	 */
	public URIBuilder setQuery( Map<?,?> params ) throws URISyntaxException {
		if ( params == null || params.size() < 1 ) {
			this.base = new URI( base.getScheme(), base.getUserInfo(), 
				base.getHost(), base.getPort(), base.getPath(),
				null, base.getFragment() );
		}
		else {
			List<NameValuePair> nvp = new ArrayList<NameValuePair>(params.size());
			for ( Object key : params.keySet() ) {
				Object value = params.get(key);
				if ( value instanceof List ) {
					for (Object val : (List)value )
						nvp.add( new BasicNameValuePair( key.toString(), 
								( val != null ) ? val.toString() : "" ) );
				}
				else nvp.add( new BasicNameValuePair( key.toString(), 
						( value != null ) ? value.toString() : "" ) );
			}
			this.setQueryNVP( nvp );
		}
		return this;
	}
	
	/**
	 * Get the query string as a map for convenience.  If any parameter contains
	 * multiple values (e.g. <code>p1=one&p1=two</code>) both values will be 
	 * inserted into a list for that paramter key (<code>[p1 : ['one','two']]
	 * </code>).  Note that this is not a "live" map.  Therefore, you cannot 
	 * call 
	 * <pre> uri.query.a = 'BCD'</pre>
	 * You will not modify the query string but instead the generated map of
	 * parameters.  Instead, you need to use {@link #removeQueryParam(String)}
	 * first, then {@link #addQueryParam(String, Object)}, or call 
	 * {@link #setQuery(Map)} which will set the entire query string.
	 * @return a map of String name/value pairs representing the URI's query 
	 * string.
	 */
	public Map<String,Object> getQuery() {
		Map<String,Object> params = new HashMap<String,Object>();		
		List<NameValuePair> pairs = this.getQueryNVP();
		
		for ( NameValuePair pair : pairs ) {
			
			String key = pair.getName();
			Object existing = params.get( key );

			if ( existing == null ) params.put( key, pair.getValue() );

			else if ( existing instanceof List ) 
				((List)existing).add( pair.getValue() );

			else {
				List<String> vals = new ArrayList<String>(2);
				vals.add( (String)existing );
				vals.add( pair.getValue() );
				params.put( key, vals );
			}
		}
		
		return params;
	}
	
	protected List<NameValuePair> getQueryNVP() {
		List<NameValuePair> nvps = URLEncodedUtils.parse( this.base, ENC );
		List<NameValuePair> newList = new ArrayList<NameValuePair>();
		if ( nvps != null ) newList.addAll( nvps );
		return newList;
	}
	
	/**
	 * Indicates if the given parameter is already part of this URI's query 
	 * string.
	 * @param name the query parameter name
	 * @return true if the given parameter name is found in the query string of 
	 *    the URI.
	 */
	public boolean hasQueryParam( String name ) {
		return getQuery().get( name ) != null;
	}
	
	/**
	 * Remove the given query parameter from this URI's query string.
	 * @param param the query name to remove 
	 * @return this URIBuilder instance, for method chaining.
	 * @throws URISyntaxException
	 */
	public URIBuilder removeQueryParam( String param ) throws URISyntaxException {
		List<NameValuePair> params = getQueryNVP();
		NameValuePair found = null;
		for ( NameValuePair nvp : params )  // BOO linear search.  Assume the list is small.
			if ( nvp.getName().equals( param ) ) {
				found = nvp;
				break;
			}
		
		if ( found == null ) throw new IllegalArgumentException( "Param '" + param + "' not found" );
		params.remove( found );
		this.setQueryNVP( params );
		return this;
	}
	
	protected URIBuilder addQueryParam( NameValuePair nvp ) throws URISyntaxException {
		List<NameValuePair> params = getQueryNVP();
		params.add( nvp );
		this.setQueryNVP( params );
		return this;
	}
	
	/**
	 * This will append a query parameter to the existing query string.  If the given 
	 * parameter is already part of the query string, it will be appended to.  
	 * To replace the existing value of a certain parameter, either call 
	 * {@link #removeQueryParam(String)} first, or use {@link #getQuery()},
	 * modify the value in the map, then call {@link #setQuery(Map)}.
	 * @param param query parameter name 
	 * @param value query parameter value (will be converted to a string if 
	 *   not null.  If <code>value</code> is null, it will be set as the empty 
	 *   string.
	 * @return this URIBuilder instance, for method chaining.
	 * @throws URISyntaxException if the query parameter values cannot be 
	 * converted to a valid URI.
	 * @see #setQuery(Map) 
	 */
	public URIBuilder addQueryParam( String param, Object value ) throws URISyntaxException {
		List<NameValuePair> params = getQueryNVP();
		params.add( new BasicNameValuePair( param, 
				( value != null ) ? value.toString() : "" ) );
		this.setQueryNVP( params );
		return this;
	}
	
	protected URIBuilder addQueryParams( List<NameValuePair> nvp ) throws URISyntaxException {
		List<NameValuePair> params = getQueryNVP();
		params.addAll( nvp );
		this.setQueryNVP( params );
		return this;
	}
	
	/**
	 * Add these parameters to the URIBuilder's existing query string.
	 * Parameters may be passed either as a single map argument, or as a list
	 * of named arguments.  e.g. 
	 * <pre> uriBuilder.addQueryParams( [one:1,two:2] )
	 * uriBuilder.addQueryParams( three : 3 ) </pre>
	 * 
	 * If any of the parameters already exist in the URI query, these values 
	 * will <strong>not</strong> replace them.  Multiple values for the same 
	 * query parameter may be added by putting them in a list. See 
	 * {@link #setQuery(Map)}.
	 * 
	 * @param params parameters to add to the existing URI query (if any).
	 * @return this URIBuilder instance, for method chaining.
	 * @throws URISyntaxException
	 */
	@SuppressWarnings("unchecked")
	public URIBuilder addQueryParams( Map<?,?> params ) throws URISyntaxException {
		List<NameValuePair> nvp = new ArrayList<NameValuePair>();
		for ( Object key : params.keySet() ) {
			Object value = params.get( key );
			if ( value instanceof List ) {
				for ( Object val : (List)value )
					nvp.add( new BasicNameValuePair( key.toString(), 
							( val != null ) ? val.toString() : "" ) );
			}
			else nvp.add( new BasicNameValuePair( key.toString(), 
					( value != null ) ? value.toString() : "" ) );
		}
		this.addQueryParams( nvp );
		return this;
	}
	
	/**
	 * The document fragment, without a preceeding '#'
	 * @param fragment
	 * @return this URIBuilder instance, for method chaining.
	 * @throws URISyntaxException if the given value contains illegal characters. 
	 */
	public URIBuilder setFragment( String fragment ) throws URISyntaxException {
		this.base = new URI( base.getScheme(), base.getUserInfo(), 
				base.getHost(), base.getPort(), base.getPath(),
				base.getQuery(), fragment );
		return this;
	}
	
	/**
	 * Print this builder's URI representation.
	 */
	@Override public String toString() {
		return base.toString();
	}
	
	/**
	 * Convenience method to convert this object to a URL instance.
	 * @return this builder as a URL
	 * @throws MalformedURLException if the underlying URI does not represent a 
	 * valid URL.
	 */
	public URL toURL() throws MalformedURLException {
		return base.toURL();
	}
	
	/**
	 * Convenience method to convert this object to a URI instance.
	 * @return this builder's underlying URI representation
	 */
	public URI toURI() { return this.base; }
	
	/**
	 * Implementation of Groovy's <code>as</code> operator, to allow type 
	 * conversion.  
	 * @param type <code>URL</code>, <code>URL</code>, or <code>String</code>.
	 * @return a representation of this URIBuilder instance in the given type
	 * @throws MalformedURLException if <code>type</code> is URL and this 
	 * URIBuilder instance does not represent a valid URL. 
	 */
	public Object asType( Class<?> type ) throws MalformedURLException {
		if ( type == URI.class ) return this.toURI();
		if ( type == URL.class ) return this.toURL();
		if ( type == String.class ) return this.toString();
		throw new ClassCastException( "Cannot cast instance of URIBuilder to class " + type );
	}
	
	/**
	 * Create a copy of this URIBuilder instance.
	 */
	@Override
	protected URIBuilder clone() {
		return new URIBuilder( this.base );
	}
	
	/**
	 * Determine if this URIBuilder is equal to another URIBuilder instance.
	 * @see URI#equals(Object)
	 * @return if <code>obj</code> is a URIBuilder instance whose underlying 
	 *   URI implementation is equal to this one's.
	 */
	@Override
	public boolean equals( Object obj ) {
		if ( ! ( obj instanceof URIBuilder) ) return false;
		return this.base.equals( ((URIBuilder)obj).toURI() );
	}
}
