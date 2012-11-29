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
		org.frogx.service.api.MUGRoom,
		org.frogx.service.api.MUGMatch,
		org.frogx.service.api.exception.*,
		org.frogx.service.core.DefaultMUGService,
		org.frogx.service.core.DefaultMUGRoom,
		org.jivesoftware.openfire.XMPPServer,
		org.jivesoftware.util.ParamUtils,
		org.jivesoftware.util.Log,
		org.xmpp.packet.JID,
		java.util.*"
	errorPage="error.jsp"
%>
<%@ page import="java.net.URLEncoder" %>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jstl/fmt_rt" prefix="fmt" %>

<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager" />
<% webManager.init(request, response, session, application, out); %>

<%
	// Handle a cancel
	if (request.getParameter("cancel") != null) {
		response.sendRedirect("mug-room-summary.jsp");
		return;
	}
%>

<%
	// Get parameters
	boolean save    = request.getParameter("save") != null;
	boolean success = request.getParameter("success") != null;
	String mugname  = ParamUtils.getParameter(request,"mugname");
	String game     = ParamUtils.getParameter(request,"game");
	String roomname = ParamUtils.getParameter(request,"roomname");
	JID user = new JID(webManager.getUser().getUsername(), webManager.getServerInfo().getXMPPDomain(), null);
	Map<String,String> errors = new HashMap<String,String>();

	// Get the plugin instance
	final MUGPlugin plugin =
		(MUGPlugin) XMPPServer.getInstance().getPluginManager().getPlugin(MUGPlugin.pluginName);
	
	int servicesCount = plugin.getServicesCount();
	
	// Load the service object
	MUGService service = null;
	if (servicesCount < 1) {
		response.sendRedirect("mug-room-summary.jsp");
		return;
	}
	else if (servicesCount == 1) {
		service = plugin.getMultiUserGameServices().get(0);
		mugname = service.getName();
	} 
	else if (mugname != null && plugin.isServiceRegistered(mugname)) {
		service = plugin.getMultiUserGameService(mugname);
	} 
	else if (roomname != null) {
		for (MUGService mugService : plugin.getMultiUserGameServices()) {
			if (mugService.hasRoom(roomname.toLowerCase())) 
				service = mugService;
		}
		if (service == null)
			errors.put("roomname","roomname");
	} 
	else {
		errors.put("roomname","roomname");
	}
%>
<%
	// Load game room
	MUGRoom room = null;
	if ((roomname != null) && (errors.size() == 0) && service.hasRoom(roomname.toLowerCase())) {
		roomname = roomname.toLowerCase();
		if (service instanceof DefaultMUGService) {
			room = ((DefaultMUGService) service).getGameRoom(roomname);
		}
		else {
			if (game == null || game.length() < 1 || !plugin.isGameRegistered(game)) {
				errors.put("game","game");
			}
			try {
				//room = service.getGameRoom(roomname, game, user);
				room = service.createGameRoom(game, user);
			}
			catch (UnsupportedGameException e) {
				errors.put("game","game");
			}
			catch (NotAllowedException e) {
				errors.put("policy","policy");
			}
		}
	}
	else {
		errors.put("roomname","roomname");
	}

	// Handle a save
	if (save && (errors.size() == 0)) {
		// Get config parameters
		String roomconfig_roomname = ParamUtils.getParameter(request,"roomconfig_roomname");
		String roomconfig_matchdesc = ParamUtils.getParameter(request,"roomconfig_matchdesc");
		String roomconfig_maxusers = ParamUtils.getParameter(request,"roomconfig_maxusers");
		String roomconfig_anonymity = ParamUtils.getParameter(request,"roomconfig_anonymity");
		String roomconfig_password = ParamUtils.getParameter(request,"roomconfig_password");
		String roomconfig_passwd_confirm = ParamUtils.getParameter(request,"roomconfig_passwd_confirm");
		boolean roomconfig_moderated = request.getParameter("roomconfig_roompolicy") != null;
		boolean roomconfig_allowinvites = request.getParameter("roomconfig_allowinvites") != null;
		boolean roomconfig_publicroom = request.getParameter("roomconfig_publicroom") != null;
		boolean roomconfig_membersonly = request.getParameter("roomconfig_membersonly") != null;
		int maxUsers = 0;
		DefaultMUGRoom localRoom = null;
		
		// do validation
		if (room instanceof DefaultMUGRoom) {
			localRoom = (DefaultMUGRoom) room;
			if (roomconfig_maxusers != null || roomconfig_maxusers.trim().length() > 0 ) {
				try {
					maxUsers = Integer.parseInt(roomconfig_maxusers.trim());
					if (maxUsers < 0) 
						errors.put("roomconfig_maxusers","roomconfig_maxusers");
				}
				catch (NumberFormatException e) {
					errors.put("roomconfig_maxusers","roomconfig_maxusers");
				}
			}
			if ((roomconfig_anonymity != null) && 
					!roomconfig_anonymity.equals("fully-anonymous") &&
					!roomconfig_anonymity.equals("semi-anonymous") &&
					!roomconfig_anonymity.equals("non-anonymous")) 
				errors.put("roomconfig_anonymity","roomconfig_anonymity");
			if ((roomconfig_password != null && roomconfig_password.trim().length() > 0) || 
					(roomconfig_passwd_confirm != null && roomconfig_passwd_confirm.trim().length() > 0)) 
				if (!roomconfig_password.equals(roomconfig_passwd_confirm))
					errors.put("roomconfig_password","roomconfig_password");
			if ((localRoom.getMatch().getStatus() != MUGMatch.Status.created) &&
					(localRoom.getMatch().getStatus() != MUGMatch.Status.inactive)) 
				errors.put("match_status","match_status");
		}
		else
			errors.put("implementation","implementation");
		
		// submit changes
		if (errors.size() == 0) {
			localRoom.setNaturalLanguageName(roomconfig_roomname);
			localRoom.setDescription(roomconfig_matchdesc);
			localRoom.setModerated(roomconfig_moderated);
			localRoom.setAllowInvites(roomconfig_allowinvites);
			localRoom.setMaxOccupants(maxUsers);
			localRoom.setPublicRoom(roomconfig_publicroom);
			localRoom.setMembersOnly(roomconfig_membersonly);
			if (roomconfig_password != null)
				localRoom.setPassword(roomconfig_password);
			if (roomconfig_anonymity != null) {
				if (roomconfig_anonymity.equals("fully-anonymous"))
					localRoom.setAnonymity(DefaultMUGRoom.Anonymity.fullyAnonymous);
				else if (roomconfig_anonymity.equals("non-anonymous"))
					localRoom.setAnonymity(DefaultMUGRoom.Anonymity.nonAnonymous);
				else
					localRoom.setAnonymity(DefaultMUGRoom.Anonymity.semiAnonymous);
			}
			
			localRoom.getMatch().setConfiguration(null);
			localRoom.broadcastRoomPresence();
			
			// Log the event
			Log.debug("MUG Room Configuration Changed for "+roomname);
			
			response.sendRedirect("mug-room-settings.jsp?success=true&mugname="+mugname+"&roomname="+roomname+"&game="+game);
			return;
		}
	}
%>

<html>
<head>
<title><fmt:message key="mug.room.properties.title"/></title>
<meta name="subPageID" content="mug-room-settings"/>
<%
	if (room != null) {
%>
<meta name="extraParams" content="mugname=<%= URLEncoder.encode(room.getMUGService().getName(), "UTF-8") %>&roomname=<%= URLEncoder.encode(room.getName(), "UTF-8") %>&game=<%= URLEncoder.encode(room.getGame().getGameID().getNamespace(), "UTF-8") %>"/>
<%
	}
%>
</head>
<body>

<% 
	if (success) {
%>
		<div class="jive-success">
		<table cellpadding="0" cellspacing="0" border="0">
		<tbody>
		<tr><td class="jive-icon"><img src="images/success-16x16.gif" width="16" height="16" border="0" alt=""></td>
		<td class="jive-icon-label"><fmt:message key="mug.room.properties.saved_successfully" /></td></tr>
		</tbody>
		</table>
		</div><br>
<% 
	} 
	else if (errors.size() > 0) { 
%>
		<div class="jive-error">
		<table cellpadding="0" cellspacing="0" border="0">
		<tbody>
		<tr><td class="jive-icon"><img src="images/error-16x16.gif" width="16" height="16" border="0" alt=""></td>
		<td class="jive-icon-label">
<% 
		if (errors.get("implementation") != null) { 
%>
			<fmt:message key="mug.room.properties.error_unsupported_implementation" />
<%
		}

		if (errors.get("roomname") != null) { 
%>
			<fmt:message key="mug.room.properties.error_room_name" />
<%
		}

		if (errors.get("game") != null) { 
%>
			<fmt:message key="mug.room.properties.error_game" />
<%
		} 

		if (errors.get("policy") != null) { 
%>
			<fmt:message key="mug.room.properties.error_room_policy" />
<%
		}

		if (errors.get("roomconfig_maxusers") != null) { 
%>
			<fmt:message key="mug.room.properties.error_maxusers" />
<%
		} 

		if (errors.get("roomconfig_anonymity") != null) { 
%>
			<fmt:message key="mug.room.properties.error_anonymity" />
<%
		} 

		if (errors.get("roomconfig_password") != null) { 
%>
			<fmt:message key="mug.room.properties.error_password" />
<%
		} 
		if (errors.get("match_status") != null) { 
%>
			<fmt:message key="mug.room.properties.error_match_status" />
<%
		} 
%>
		</td></tr>
		</tbody>
		</table>
		</div><br>
<%
	} 
	if (room != null) {
		if ((room instanceof DefaultMUGRoom) && 
			((room.getMatch().getStatus() == MUGMatch.Status.created) || 
			(room.getMatch().getStatus() == MUGMatch.Status.inactive))) {
%>
<p><fmt:message key="mug.room.properties.edit.introduction" /></p>
<form action="mug-room-settings.jsp" method="post">
<input type="hidden" name="save" value="true">
<input type="hidden" name="mugname" value="<%= mugname %>">
<input type="hidden" name="roomname" value="<%= roomname %>">
<input type="hidden" name="game" value="<%= room.getGame().getGameID().getNamespace() %>">
<table cellpadding="3" cellspacing="0" border="0">
<tr>
<td class="c1"><fmt:message key="mug.room.properties.label_address" /></td>
<td><%= room.getJID().toBareJID() %></td>
</tr>
<tr>
<td class="c1"><fmt:message key="mug.room.properties.label_game" /></td>
<td><%= room.getGame().getDescription() %></td>
</tr>
<tr>
<td class="c1"><fmt:message key="mug.room.properties.label_name" /></td>
<td><input type="text" size="30" maxlength="150" name="roomconfig_roomname" value="<%= room.getNaturalLanguageName() %>"></td>
</tr>
<tr>
<td class="c1"><fmt:message key="mug.room.properties.label_description" /></td>
<td><input type="text" size="30" maxlength="150" name="roomconfig_matchdesc" value="<%= room.getDescription() %>"></td>
</tr>
<tr>
<td class="c1"><fmt:message key="mug.room.properties.label_maxusers" /></td>
<td>
<select name="roomconfig_maxusers">
<option value="10" <%= (room.getMaxOccupants() == 10) ? "selected='selected'" : "" %>>10</option>
<option value="20" <%= (room.getMaxOccupants() == 20) ? "selected='selected'" : "" %>>20</option>
<option value="30" <%= (room.getMaxOccupants() == 30) ? "selected='selected'" : "" %>>30</option>
<option value="40" <%= (room.getMaxOccupants() == 40) ? "selected='selected'" : "" %>>40</option>
<option value="50" <%= (room.getMaxOccupants() == 50) ? "selected='selected'" : "" %>>50</option>
</select>
</td>
</tr>
<tr>
<td class="c1"><fmt:message key="mug.room.properties.label_anonymity" /></td>
<td>
<select name="roomconfig_anonymity">
<option value="fully-anonymous" <%= room.isFullyAnonymous() ? "selected='selected'" : "" %>><fmt:message key="mug.room.properties.fully-anonymous" /></option>
<option value="semi-anonymous" <%= room.isSemiAnonymous() ? "selected='selected'" : "" %>><fmt:message key="mug.room.properties.semi-anonymous" /></option>
<option value="non-anonymous" <%= room.isNonAnonymous() ? "selected='selected'" : "" %>><fmt:message key="mug.room.properties.non-anonymous" /></option>
</select>
</td>
</tr>
<tr>
<td class="c1"><fmt:message key="mug.room.properties.label_password" /></td>
<td><input type="password" size="30" maxlength="30" name="roomconfig_password" value="<%= (room.getPassword() != null) ? room.getPassword() : "" %>"></td>
</tr>
<tr>
<td class="c1"><fmt:message key="mug.room.properties.label_passwd_confirm" /></td>
<td><input type="password" size="30" maxlength="30" name="roomconfig_passwd_confirm" value="<%= (room.getPassword() != null) ? room.getPassword() : "" %>"></td>
</tr>
<tr>
<td colspan="2">
<fieldset>
<legend><fmt:message key="mug.room.properties.label_options" /></legend>
<input type="checkbox" name="roomconfig_roompolicy" value="roomconfig_moderated" <%= (room.isModerated())?"checked":"" %>>
<label for="roomconfig_roompolicy"><fmt:message key="mug.room.properties.label_moderated" /></label>
<br />
<input type="checkbox" name="roomconfig_allowinvites" value="true" <%= (room.canOccupantsInvite())?"checked":"" %>>
<label for="roomconfig_allowinvites"><fmt:message key="mug.room.properties.label_allowinvites" /></label>
<br />
<input type="checkbox" name="roomconfig_publicroom" value="true" <%= (room.isPublicRoom())?"checked":"" %>>
<label for="roomconfig_publicroom"><fmt:message key="mug.room.properties.label_publicroom" /></label>
<br />
<input type="checkbox" name="roomconfig_membersonly" value="true" <%= (room.isMembersOnly())?"checked":"" %>>
<label for="roomconfig_membersonly"><fmt:message key="mug.room.properties.label_members_only" /></label>
</fieldset>
</td>
</tr>
</table>
<input type="submit" name="submit" value="<fmt:message key="mug.room.properties.save" />">
<input type="submit" name="cancel" value="<fmt:message key="global.cancel" />">
</form>
<%
		}
		else {
%>
<p><fmt:message key="mug.room.properties.introduction" /></p>
<table cellpadding="3" cellspacing="0" border="0">
<tr><td class="c1"><fmt:message key="mug.room.properties.label_address" /></td><td><%= room.getJID().toBareJID() %></td></tr>
<tr><td class="c1"><fmt:message key="mug.room.properties.label_game" /></td><td><%= room.getGame().getDescription() %></td></tr>
<tr><td class="c1"><fmt:message key="mug.room.properties.label_name" /></td><td><%= room.getNaturalLanguageName() %></td></tr>
<tr><td class="c1"><fmt:message key="mug.room.properties.label_description" /></td><td><%= room.getDescription() %></td></tr>
<tr><td class="c1"><fmt:message key="mug.room.properties.label_maxusers" /></td><td><%= room.getMaxOccupants() %></td></tr>
<tr><td class="c1"><fmt:message key="mug.room.properties.label_anonymity" /></td>
<td>
<%
			if (room.isFullyAnonymous()) {
%>
<fmt:message key="mug.room.properties.fully-anonymous" />
<%
			}
			else if (room.isSemiAnonymous()) {
%>
<fmt:message key="mug.room.properties.semi-anonymous" />
<%
			}
			else {
%>
<fmt:message key="mug.room.properties.non-anonymous" />
<%
			}
%>
</td></tr>
<%
			if (room.isModerated() || room.canOccupantsInvite() || room.isPublicRoom() || room.isMembersOnly()) {
%>
<tr><td class="c1"><fmt:message key="mug.room.properties.label_options" /></td><td>
<%
				if (room.isModerated()) {
%>
<fmt:message key="mug.room.properties.label_moderated" /><br />
<%
				}
				if (room.canOccupantsInvite()) {
%>
<fmt:message key="mug.room.properties.label_allowinvites" /><br />
<%
				}
				if (room.isPublicRoom()) {
%>
<fmt:message key="mug.room.properties.label_publicroom" /><br />
<%
				}
				if (room.isMembersOnly()) {
%>
<fmt:message key="mug.room.properties.label_members_only" /><br />
<%
				}
%>
</td></tr>
<%
			}
%>
</table>
<%
		}
	}
%>
</body>
</html>
