<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">dojo.require("dijit.TitlePane");
dojo.require("dijit.MultiSelect");</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="Create New User">
    <form:form action="/gameservice/user" method="POST" modelAttribute="user">
    	<form:errors path="*" cssClass="errors"/><br/>
        <div>        	
            <label for="username">Username:</label>
            <form:input cssStyle="width:250px" maxlength="30" path="username" size="30"/>
            <form:errors path="username" cssClass="errors"/>
            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "username", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {promptMessage: "Enter Name", regExp: "[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+)*", required : true}})); </script>
        </div>
        <br/>
        <div>        	
            <label for="email">Email:</label>
            <form:input cssStyle="width:250px" maxlength="30" path="email" size="30"/>
            <form:errors path="email" cssClass="errors"/><br/>
            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "email", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {invalidMessage: "Enter valid email id", regExp: "[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", required : true}})); </script>
        </div>        
        <br/>
        <div>        	
            <label for="password">Password:</label>
            <form:password cssStyle="width:250px" maxlength="30" path="password" size="30"/>
            <form:errors path="password" cssClass="errors"/><br/>
            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "password", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {invalidMessage: "Enter Password", required : true}})); </script>
        </div>        
        <br/>        
        <div>
            <c:if test="${not empty authorities}">
                <label for="authorities">Authorities:</label>
                <form:select cssStyle="width:250px" path="authorities">
                    <form:options itemValue="id" items="${authorities}"/>
                </form:select>
                <form:errors path="authorities" cssClass="errors"/>
                <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "manager", widgetType: "dijit.form.MultiSelect", widgetAttrs : {hasDownArrow : true}})); </script>
            </c:if>
        </div>
        <br/>
        <div class="submit">	
            <script type="text/javascript">Spring.addDecoration(new Spring.ValidateAllDecoration({elementId:'proceed', event:'onclick'}));</script>
            <input id="proceed" type="submit" value="Save"/>
        </div>
    </form:form>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
