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
		<h2>Create Vendor</h2>
		<form:form id="create_vendor_form" method="post" modelAttribute="vendor" cssClass="cleanform">
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
		  		<form:label path="name">
		  			Vendor Name <form:errors path="name" cssClass="error" />
		 		</form:label>
		  		<form:input path="name" />
		  	</fieldset>
	
	
	
			<p><button type="submit">Submit</button></p>
		</form:form>
	</div>
</body>
</html>