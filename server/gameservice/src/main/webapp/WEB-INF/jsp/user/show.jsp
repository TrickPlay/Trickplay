<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">
	dojo.require("dijit.TitlePane");
	dojo.require("dijit.form.MultiSelect");
	
</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="Show User">
    <c:if test="${not empty user}">       
        <div>
            <label for="username">Username:</label>
            <div id="username">${user.username}</div>
        </div>
        <br/>
        <div>
            <label for="email">Email:</label>
            <div id="email">${user.email}</div>
        </div>
        <br/>

		
	</c:if>
    <c:if test="${empty user}">No user found with this id.</c:if>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
