<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>GameService</title>
    <link href="<c:url value="/resources/form.css" />" rel="stylesheet"  type="text/css" />     
</head>
<body>
<ul>
<li><a href="<c:url value="/user/new" />">Create User</a></li>
</ul>
<p>Number of Users: ${numberOfUsers}</p>
<table border=1>
	<thead><tr>
		<th>ID</th>
		<th>Name</th>
		<th>Email</th>
	</tr></thead>
	<c:forEach var="user" items="${allUsers}">
	<tr>
		<td>${user.id}</td>
		<td>${user.username}</td>
		<td>${user.email}</td>
	</tr>
	</c:forEach>
</table>
</body>
</html>