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
		org.jivesoftware.util.ParamUtils,
		org.jivesoftware.util.LocaleUtils,
		org.jivesoftware.openfire.XMPPServer,
		org.jivesoftware.openfire.container.Plugin,
		org.jivesoftware.openfire.container.PluginManager,
		org.xmpp.packet.JID,
		java.net.URLEncoder,
		java.util.List,
		java.io.File"
%>

<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>

<%!
	final int DEFAULT_RANGE = 15;
	final int[] RANGE_PRESETS = {15, 25, 50, 75, 100};
%>

<html>
<head>
	<title><fmt:message key="mug.service.summary.title"/></title>
	<meta name="pageID" content="mug-service-summary"/>
</head>
<body>

<%
	// Get parameters
	int start = ParamUtils.getIntParameter(request,"start",0);
	int range = ParamUtils.getIntParameter(request,"range",DEFAULT_RANGE);
	
	// Get the plugin instance
	final MUGPlugin plugin =
		(MUGPlugin) XMPPServer.getInstance().getPluginManager().getPlugin(MUGPlugin.pluginName);
	
	// Get the number of registered services
	int servicesCount = plugin.getServicesCount();
	
	// Naginator vars
	int numPages = (int)Math.ceil((double)servicesCount/(double)range);
	int curPage = (start/range) + 1;
	
	if (request.getParameter("deletesuccess") != null) {
%>
<div class="jive-success">
	<table cellpadding="0" cellspacing="0" border="0"><tbody>
		<tr><td class="jive-icon"><img src="images/success-16x16.gif" width="16" height="16" border="0" alt=""></td>
		<td class="jive-icon-label">
			<fmt:message key="mug.service.summary.deleted" />
		</td></tr>
	</tbody></table>
</div><br>	
<%
	}
	if (plugin.getServicesCount() < 1) {
%>
<div class="jive-info">
	<table cellpadding="0" cellspacing="0" border="0"><tbody>
		<tr><td class="jive-icon"><img src="images/info-16x16.gif" width="16" height="16" border="0" alt=""></td>
		<td class="jive-icon-label"><fmt:message key="mug.service.summary.no_services_warning" /></td></tr>
	</tbody></table>
</div><br>
<%
	}
%>
<p><fmt:message key="mug.service.summary.total_services" />:
<b><%= LocaleUtils.getLocalizedNumber(servicesCount) %></b> --
<%
	if (numPages > 1) {
%>
<fmt:message key="global.showing" />
<%= LocaleUtils.getLocalizedNumber(start+1) %>-<%= LocaleUtils.getLocalizedNumber(start+range > servicesCount ? servicesCount:start+range) %>,
<%
	}
%>
<fmt:message key="mug.service.summary.sorted" />
-- <fmt:message key="mug.service.summary.services_per_page" />:
<select size="1" onchange="location.href='mug-service-summary.jsp?start=0&range=' + this.options[this.selectedIndex].value;">
<%
	for (int aRANGE_PRESETS : RANGE_PRESETS) {
%>
<option value="<%= aRANGE_PRESETS %>"<%= (aRANGE_PRESETS == range ? "selected" : "") %>><%= aRANGE_PRESETS %></option>
<%
	}
%>
</select>
</p>

<%
	if (numPages > 1) {
%>
<p>
<fmt:message key="global.pages" />: [
<%
	int num = 15 + curPage;
	int s = curPage-1;
	if (s > 5) {
		s -= 5;
	}
	if (s < 5) {
		s = 0;
	}
	if (s > 2) {
%>
<a href="mug-service-summary.jsp?start=0&range=<%= range %>">1</a> ...
<%
	}
	
	int i;
	for (i=s; i<numPages && i<num; i++) {
		String sep = ((i+1)<numPages) ? " " : "";
		boolean isCurrent = (i+1) == curPage;
%>
<a href="mug-service-summary.jsp?start=<%= (i*range) %>&range=<%= range %>"
	class="<%= ((isCurrent) ? "jive-current" : "") %>"
	><%= (i+1) %></a><%= sep %>
<%
		}
		if (i < numPages) {
%>
... <a href="mug-service-summary.jsp?start=<%= ((numPages-1)*range) %>&range=<%= range %>"><%= numPages %></a>
<%
		}
%>
]</p>
<%
	}
%>
<div class="jive-table">
<table cellpadding="0" cellspacing="0" border="0" width="100%"><thead>
	<tr>
		<th>&nbsp;</th>
		<th nowrap><fmt:message key="mug.service.summary.subdomain" /></th>
		<th nowrap><fmt:message key="mug.service.summary.descr" /></th>
		<th nowrap><fmt:message key="mug.service.summary.numrooms" /></th>
		<th nowrap><fmt:message key="mug.service.summary.numsessions" /></th>
		<th nowrap><fmt:message key="global.edit" /></th>
		<th nowrap><fmt:message key="global.delete" /></th>
	</tr>
</thead><tbody>
<%
	// Print the list of users
	List<MUGService> services = plugin.getMultiUserGameServices();
	if (services.isEmpty()) {
%>
<tr><td align="center" colspan="7"><fmt:message key="mug.service.summary.no_services" /></td></tr>
<%
	}
	int i = 0;
	for (MUGService service : services) {
		i++;
		if ( (start < i ) && (i <= (start+range)) ) {
%>
<tr class="jive-<%= (((i%2)==0) ? "even" : "odd") %>">
	<td width="1%">
		<%= i %>
	</td>
	<td width="23%">
		<a href="mug-service-edit-form.jsp?mugname=<%= URLEncoder.encode(service.getName(), "UTF-8") %>"><%= JID.unescapeNode(service.getName()) %></a>
	</td>
	<td width="33%">
		<%= service.getDescription() %> &nbsp;
	</td>
	<td width="5%">
		<a href="mug-room-summary.jsp?mugname=<%= URLEncoder.encode(service.getName(), "UTF-8") %>"><%= service.getNumberRooms() %></a>
	</td>
	<td width="5%">
		<%= service.getNumberUserSessions() %>
	</td>
	<td width="1%" align="center">
		<a href="mug-service-edit-form.jsp?mugname=<%= URLEncoder.encode(service.getName(), "UTF-8") %>"
			title="<fmt:message key="global.click_edit" />"
			><img src="images/edit-16x16.gif" width="16" height="16" border="0" alt="<fmt:message key="global.click_edit" />"></a>
	</td>
	<td width="1%" align="center" style="border-right:1px #ccc solid;">
		<a href="mug-service-delete.jsp?mugname=<%= URLEncoder.encode(service.getName(), "UTF-8") %>"
			title="<fmt:message key="global.click_delete" />"
			><img src="images/delete-16x16.gif" width="16" height="16" border="0" alt="<fmt:message key="global.click_delete" />"></a>
	</td>
</tr>
<%
		}
	}
%>
</tbody></table>
</div>
<%
	if (numPages > 1) {
%>
<p><fmt:message key="global.pages" />:[
<%
		int num = 15 + curPage;
		int s = curPage-1;
		if (s > 5) {
			s -= 5;
		}
		if (s < 5) {
			s = 0;
		}
		if (s > 2) {
%>
<a href="mug-service-summary.jsp?start=0&range=<%= range %>">1</a> ...
<%
		}
		for (i=s; i<numPages && i<num; i++) {
			String sep = ((i+1)<numPages) ? " " : "";
			boolean isCurrent = (i+1) == curPage;
%>
<a href="mug-service-summary.jsp?start=<%= (i*range) %>&range=<%= range %>"
	class="<%= ((isCurrent) ? "jive-current" : "") %>"
	><%= (i+1) %></a><%= sep %>
<%
		}
		if (i < numPages) {
%>
... <a href="mug-service-summary.jsp?start=<%= ((numPages-1)*range) %>&range=<%= range %>"><%= numPages %></a>
<%
		}
%>
]</p>
<%
	}
%>
</body>
</html>
