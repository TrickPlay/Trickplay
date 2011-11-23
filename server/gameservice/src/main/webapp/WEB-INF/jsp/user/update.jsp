<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">dojo.require("dijit.TitlePane");</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="Update User">
    <form:form action="/gameservice/user/${user.id}" method="PUT" modelAttribute="user">
        <div>
            <label for="username">Username:</label>
            <form:input cssStyle="width:250px" maxlength="30" path="username" size="30"/>
            <form:errors path="username" cssClass="errors"/>
            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "username", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {promptMessage: "Enter Username", required : true}})); </script>
        </div>
        <br/>
        <div>
            <label for="email">Email:</label>
            <form:input cssStyle="width:250px" maxlength="30" path="email" size="30"/>
            <form:errors path="email" cssClass="errors"/>
            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "email", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {invalidMessage: "Enter Email (numbers only)", regExp: "[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", required : true}})); </script>
        </div>
        <br/>        
        <div>        	
            <label for="password">Password:</label>
            <form:password cssStyle="width:250px" maxlength="30" path="password" size="30"/>
            <form:errors path="password" cssClass="errors"/><br/>
            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "password", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {invalidMessage: "Enter Account Password", required : true}})); </script>
        </div>
        <br/>     
        <div class="submit">
            <script type="text/javascript">Spring.addDecoration(new Spring.ValidateAllDecoration({elementId:'proceed', event:'onclick'}));</script>
            <input id="proceed" type="submit" value="Update"/>
        </div>
        <form:hidden path="id"/>
        <form:hidden path="version"/>
    </form:form>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
