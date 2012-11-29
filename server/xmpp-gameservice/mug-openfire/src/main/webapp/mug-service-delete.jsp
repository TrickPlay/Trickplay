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
		org.frogx.service.api.MUGService,
		org.jivesoftware.openfire.XMPPServer,
		org.jivesoftware.util.*,
		java.net.URLEncoder"
	errorPage="error.jsp"
%>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>

<%
	// Get parameters //
	boolean cancel = request.getParameter("cancel") != null;
	boolean delete = request.getParameter("delete") != null;
	String mugname = ParamUtils.getParameter(request,"mugname");
	String reason = ParamUtils.getParameter(request,"reason");
	
	// Handle a cancel
	if (cancel) {
		response.sendRedirect("mug-service-summary.jsp");
		return;
	}
	
	// Get the plugin instance
	final MUGPlugin plugin =
		(MUGPlugin) XMPPServer.getInstance().getPluginManager().getPlugin(MUGPlugin.pluginName);
	
	// Load the room object
	MUGService mug = plugin.getMultiUserGameService(mugname);
	
	// Handle a room delete:
	if (delete) {
		// Delete the service
		//TODO: If we support saving we must delete the rooms too.
		if (mug != null) {
			plugin.removeMultiUserGameService(mugname);
		}
		// Done, so redirect
		response.sendRedirect("mug-service-summary.jsp?deletesuccess=true");
		return;
	}
%>

<html>
<head>
	<title><fmt:message key="mug.service.delete.title"/></title>
	<meta name="subPageID" content="mug-service-delete"/>
	<meta name="extraParams" content="<%= "mugname="+URLEncoder.encode(mugname, "UTF-8") %>"/>
</head>
<body>
	<p>
		<fmt:message key="mug.service.delete.info" />
		<b><a href="mug-service-edit-form.jsp?mugname=<%= URLEncoder.encode(mugname, "UTF-8") %>"><%= mugname %></a></b>
		<fmt:message key="mug.service.delete.detail" />
	</p>
	
	<form action="mug-service-delete.jsp">
		<input type="hidden" name="mugname" value="<%= mugname %>">
		<fieldset>
			<legend><fmt:message key="mug.service.delete.destructon_title" /></legend>
			<div>
				<table cellpadding="3" cellspacing="0" border="0" width="100%"><tbody>
					<tr>
						<td class="c1">
							<fmt:message key="mug.service.delete.service_name" />
						</td>
						<td>
							<%= mugname %>
						</td>
					</tr>
					<tr>
						<td class="c1">
							<fmt:message key="mug.service.delete.reason" />
						</td>
						<td>
							<input type="text" size="50" maxlength="150" name="reason">
						</td>
					</tr>
				</tbody></table>
			</div>
		</fieldset>
		<br><br>
		<input type="submit" name="delete" value="<fmt:message key="mug.service.delete.destroy_service" />">
		<input type="submit" name="cancel" value="<fmt:message key="global.cancel" />">
	</form>
</body>
</html>
