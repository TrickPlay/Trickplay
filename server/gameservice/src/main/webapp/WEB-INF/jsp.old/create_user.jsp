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
		<form:form id="create_user_form" method="post" modelAttribute="user" cssClass="cleanform">
			<div class="header">
		  		<h2>Form</h2>
		  		<c:if test="${not empty message}">
					<div id="message" class="${message.type}">${message.text}</div>	
		  		</c:if>
		  		<s:bind path="*">
		  			<c:if test="${status.error}">
				  		<div id="message" class="error">Form has errors</div>
		  			</c:if>
		  		</s:bind>
			</div>
		  	<fieldset>
		  		<legend>User Info</legend>
		  		<form:label path="username">
		  			User Name <form:errors path="username" cssClass="error" />
		 		</form:label>
		  		<form:input path="username" />
	
		  		<form:label path="email">
		  			Email <form:errors path="email" cssClass="error" />
		  		</form:label>
		  		<form:input path="email" />
	
		  		<form:label path="password">
		  			Password <form:errors path="password" cssClass="error" />
		  		</form:label>
		  		<form:password path="password" />
	
		  	</fieldset>
	
	
	
			<p><button type="submit">Submit</button></p>
		</form:form>
	</div>
</body>
</html>