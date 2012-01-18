<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">dojo.require("dijit.TitlePane");
	dojo.require("dijit.form.TextBox");  
    dojo.require("dijit.form.Button");
    dojo.require("dijit.form.DateTextBox");
    dojo.require("dijit.form.CheckBox");
    dojo.require("dijit.form.FilteringSelect");
</script>
<c:if test="${not empty game}"> 
<div dojoType="dijit.TitlePane" style="width: 100%" title="Create New Game">
    <form:form action="/gameservice/game" method="POST" modelAttribute="game">
        <div>
        	<div>
	            <c:if test="${not empty vendors}">
	                <label for="vendorId">Vendor:</label>
	                <form:select path="vendorId">
	                    <form:options itemValue="id" itemLabel="name" items="${vendors}"/>
	                </form:select>
	                <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "vendorId", widgetType: "dijit.form.FilteringSelect", widgetAttrs : {hasDownArrow : true}})); </script>
	            </c:if>
	        </div>
	        <br/>
	        <div>
	            <label for="name">Name:</label>
	            <form:input maxlength="30" path="name" size="30"/>
	            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "name", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {invalidMessage: "Enter Name", required : true}})); </script>
	        </div>
	        <br/>
	        <div>
	            <label for="appId">Application ID:</label>
	            <form:input maxlength="64" path="appId" size="64"/>
	            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "appId", widgetType : "dijit.form.ValidationTextBox", widgetAttrs : {invalidMessage: "Enter Application ID", required : true}})); </script>
	        </div>
	        <br/>
	        <div>
	            <label for="minPlayers">Minimum Players:</label>
	            <form:input maxlength="10" path="minPlayers" size="10" value="1"/>
	            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "minPlayers", widgetType : "dijit.form.NumberTextBox", widgetAttrs : {invalidMessage: "Enter Minimum Players", min:1, max:100, places:0, required : true}})); </script>
	        </div>
	        <br/>
	        <div>
	            <label for="maxPlayers">Maximum Players:</label>
	            <form:input maxlength="10" path="maxPlayers" size="10" value="1"/>
	            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "maxPlayers", widgetType : "dijit.form.NumberTextBox", widgetAttrs : {invalidMessage: "Enter Maximum Players", min:1, max:100, places:0, required : true}})); </script>
	        </div>
	        <br/>
	        <div>
	            <label for="leaderboardFlag">Leaderboard Enabled:</label>
	            <form:checkbox path="leaderboardFlag"/>
	            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "leaderboardFlag", widgetType : "dijit.form.CheckBox", widgetAttrs : {enabled:true}})); </script>
	        </div>
	        <br/>
	        <div>
	            <label for="achievementsFlag">Achievements Enabled:</label>
	            <form:checkbox path="achievementsFlag"/>
	            <script type="text/javascript">Spring.addDecoration(new Spring.ElementDecoration({elementId : "achievementsFlag", widgetType : "dijit.form.CheckBox", widgetAttrs : {enabled:true}})); </script>
	        </div>
	        <br/>
	        <div class="submit">
	            <script type="text/javascript">Spring.addDecoration(new Spring.ValidateAllDecoration({elementId:'proceed', event:'onclick'}));</script>
	            <input id="proceed" type="submit" value="Save"/>
	        </div>
		</div>

    </form:form>
</div>
</c:if>

<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
