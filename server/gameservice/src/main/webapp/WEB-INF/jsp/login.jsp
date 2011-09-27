<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">dojo.require("dijit.TitlePane");</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="Spring Security Login">

	<p>The default admin user is configured with username: 'admin' and password 'admin' </p>

    <%-- this form-login-page form is also used as the
         form-error-page to ask for a login again.
         --%>
    <c:if test="${not empty param.login_error}">
      <font color="red">Your login attempt was not successful, try again.<br/>
        Reason: <c:out value="${SPRING_SECURITY_LAST_EXCEPTION.message}"/>.
      </font>
    </c:if>
	<form name="f" action="<c:url value='/j_spring_security_check'/>" method="POST"> 
    	<div>
            <label for="j_username">Username:</label>
            <input id="j_username" type='text' name='j_username' style="width:150px"/>
            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "j_username", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {promptMessage: "Enter Your Username", required : true}})); </script>
        </div>
        <br/>
        <div>
            <label for="j_password">Password:</label>
            <input id="j_password" type='password' name='j_password' style="width:150px" />
            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "j_password", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {promptMessage: "Enter Your Password", required : true}})); </script>
        </div>
        <br/>
        <div class="submit">
            <script type="text/javascript">Spring.addDecoration(new Spring.ValidateAllDecoration({elementId:'proceed', event:'onclick'}));</script>
            <input id="proceed" type="submit" value="Submit"/>
            <input id="reset" type="reset" value="Reset"/>
        </div>
    </form>
    <div class="link">
    <p>Not a member? <a href="user/form">Click here</a>
    </div>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
