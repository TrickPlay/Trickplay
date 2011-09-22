<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="s" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%@ page session="false" %>
<html>
<head>
	<title>Create New User</title>
    <link href="<c:url value="/resources/form.css" />" rel="stylesheet"  type="text/css" />     
</head>
<body>
	<div id="forms">
		<h2>Create User</h2>
		<form:form id="login_form" method="post" cssClass="cleanform">
			<div class="header">
		  		<h2>Login</h2>
		  		<c:if test="${not empty message}">
					<div id="message" class="${message.type}">${message.text}</div>	
		  		</c:if>
			</div>
		  	<fieldset>
		  		<form:label path="username">
		  			User Name
		 		</form:label>
		  		<form:input path="username" />
	
		  		<form:label path="password">
		  			Password
		  		</form:label>
		  		<form:password path="password" />
		  	</fieldset>
	
			<p><button type="submit">Login</button></p>
		</form:form>
	</div>
</body>
</html>