<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">
	dojo.require("dijit.TitlePane");	
</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="Show Vendor">
    <c:if test="${not empty vendor}">
        <div>
            <label for="name">Name:</label>
            <div>${vendor.name}</div>
        </div>
        <br/>
        <div>
           <label for="games">Number of Games:</label>
            <a href="/gameservice/vendor/${vendor.id}/game">${fn:length(vendor.games)}</a>
        </div>
        <br/>
        
    </c:if>
    <c:if test="${empty vendor}">No vendor found with this id.</c:if>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
