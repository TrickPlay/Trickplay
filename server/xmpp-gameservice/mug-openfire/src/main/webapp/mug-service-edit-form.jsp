<%--
 - Copyright (C) 2008-2009 Guenther Niess. All rights reserved.
 - Copyright (C) 2004-2008 Jive Software. All rights reserved.
 - 
 - This program is free software: you can redistribute it and/or modify
 - it under the terms of the GNU General Public License as published by
 - the Free Software Foundation, either version 3 of the License, or
 - (at your option) any later version.
 - 
 - This program is distributed in the hope that it will be useful,
 - but WITHOUT ANY WARRANTY; without even the implied warranty of
 - MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 - GNU General Public License for more details.
 - 
 - You should have received a copy of the GNU General Public License
 - along with this program.  If not, see <http://www.gnu.org/licenses/>.
--%>

<%@
	page import="org.frogx.service.openfire.MUGPlugin,
		org.jivesoftware.openfire.XMPPServer,
		org.jivesoftware.util.ParamUtils,
		org.jivesoftware.util.Log,
		org.jivesoftware.util.AlreadyExistsException,
		java.util.*"
	errorPage="error.jsp"
%>
<%@ page import="java.net.URLEncoder" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>

<%
	// Handle a cancel
	if (request.getParameter("cancel") != null) {
		response.sendRedirect("mug-service-summary.jsp");
		return;
	}
%>

<%
	// Get parameters
	boolean create  = ParamUtils.getBooleanParameter(request,"create");
	boolean save    = request.getParameter("save") != null;
	boolean success = request.getParameter("success") != null;
	String mugname  = ParamUtils.getParameter(request,"mugname");
	String mugdesc  = ParamUtils.getParameter(request,"mugdesc");
	
	// Get the plugin instance
	final MUGPlugin plugin =
			(MUGPlugin) XMPPServer.getInstance().getPluginManager().getPlugin(MUGPlugin.pluginName);
	
	// Load the service object
	if (!create && !plugin.isServiceRegistered(mugname)) {
		// The requested service name does not exist so return to the list of the existing services
		response.sendRedirect("mug-service-summary.jsp");
		return;
	}
	
	// Handle a save
	Map<String,String> errors = new HashMap<String,String>();
	if (save) {
		// Check if we received a name
		if (mugname == null || mugname.indexOf('.') >= 0 || mugname.length() < 1) {
			errors.put("mugname","mugname");
		}
		// Make sure that the MUG Service is lower cased.
		mugname = mugname.toLowerCase();
		
		if (errors.size() == 0) {
			if (!create) {
				plugin.updateMultiUserGameService(mugname, mugname, mugdesc);
				// Log the event
				Log.debug("updated MUG service configuration for "+mugname + "\n" + "name = "+mugname+"\ndescription = "+mugdesc);
				response.sendRedirect("mug-service-edit-form.jsp?success=true&mugname="+mugname);
				return;
			}
			else {
				try {
					plugin.createMultiUserGameService(mugname, mugdesc);
					// Log the event
					Log.debug("created MUG service "+mugname+ "\n" + "name = "+mugname+"\ndescription = "+mugdesc);
					response.sendRedirect("mug-service-edit-form.jsp?success=true&mugname="+mugname);
					return;
				}
				catch (IllegalArgumentException e) {
					errors.put("mugname","mugname");
				}
				catch (AlreadyExistsException e) {
					errors.put("already_exists","already_exists");
				}
			}
		}
	}
	if (!create && errors.size() == 0)
		mugdesc = plugin.getMultiUserGameService(mugname).getDescription();
%>

<html>
<head>
<title><fmt:message key="mug.service.properties.title"/></title>
<%
	if (create) {
%>
<meta name="pageID" content="mug-service-create"/>
<%
	}
	else {
%>
<meta name="subPageID" content="mug-service-edit-form"/>
<meta name="extraParams" content="<%= "mugname="+URLEncoder.encode(mugname, "UTF-8") %>"/>
<%
	}
%>
</head>
<body>

<p><fmt:message key="mug.service.properties.introduction" /></p>

<%
	if (success) {
%>
<div class="jive-success"><table cellpadding="0" cellspacing="0" border="0"><tbody>
	<tr>
		<td class="jive-icon"><img src="images/success-16x16.gif" width="16" height="16" border="0" alt=""></td>
		<td class="jive-icon-label"><fmt:message key="mug.service.properties.saved_successfully" /></td>
	</tr>
</tbody></table></div><br>
<%
	}
	else if (errors.size() > 0) {
%>
<div class="jive-error"><table cellpadding="0" cellspacing="0" border="0"><tbody>
	<tr>
		<td class="jive-icon"><img src="images/error-16x16.gif" width="16" height="16" border="0" alt=""></td>
		<td class="jive-icon-label">
<%
		if (errors.get("mugname") != null) {
%>
			<fmt:message key="mug.service.properties.error.service_name" />
<%
		}
		else if (errors.get("already_exists") != null) {
%>
			<fmt:message key="mug.service.properties.error.already_exists" />
<%
		}
%>
		</td>
	</tr>
</tbody></table></div><br>
<%
	}
%>

<form action="mug-service-edit-form.jsp" method="post">
<input type="hidden" name="save" value="true">
<%
	if (!create) {
%>
<input type="hidden" name="mugname" value="<%= mugname %>">
<%
	}
	else {
%>
<input type="hidden" name="create" value="true" />
<%
	}
%>
<div class="jive-contentBoxHeader"><fmt:message key="mug.service.properties.legend" /></div>
<div class="jive-contentBox">
<table cellpadding="3" cellspacing="0" border="0">
<tr>
<td class="c1"><fmt:message key="mug.service.properties.label_service_name" /></td>
<td>
<%
	if (create) {
%>
<input type="text" size="30" maxlength="150" name="mugname" value="<%= (mugname != null ? mugname : "") %>">
<%
		if (errors.get("mugname") != null) {
%>
<span class="jive-error-text"><br><fmt:message key="mug.service.properties.error.service_name" /></span>
<%
		}
	}
	else {
%>
<%= mugname %>
<%
	}
%>
</td>
</tr>
<tr>
<td class="c1"><fmt:message key="mug.service.properties.label_service_description" /></td>
<td><input type="text" size="30" maxlength="150" name="mugdesc" value="<%= (mugdesc != null ? mugdesc : "") %>"></td>
</tr>
</table>
</div>
<input type="submit" value="<fmt:message key="mug.service.properties.save" />">
</form>
</body>
</html>
