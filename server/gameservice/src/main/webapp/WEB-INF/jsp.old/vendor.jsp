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
<li><a href="<c:url value="/vendor/form" />">Create Vendor</a></li>
</ul>
<p>Number of Vendors: ${numberOfVendors}</p>
<table border=1>
	<thead><tr>
		<th>ID</th>
		<th>Name</th>
		<th>Contact Name</th>
		<th>Contact Email</th>
	</tr></thead>
	<c:forEach var="vendor" items="${allVendors}">
	<tr>
		<td>${vendor.id}</td>
		<td>${vendor.name}</td>
		<td>${vendor.user.username}</td>
		<td>${vendor.user.email}</td>
	</tr>
	</c:forEach>
</table>
</body>
</html>