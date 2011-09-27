<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">dojo.require("dijit.TitlePane");</script> 
<div dojoType="dijit.TitlePane" style="width: 100%" title="List All Vendors">
    <c:if test="${not empty vendors}">
        <table width="300px">
        	<thead>
            	<tr>                
                    <th>Id</th>
                    <th>Name</th>
                    <th/>
                    <th/>
                    <th/>                
            	</tr>
            </thead>
            <c:forEach items="${vendors}" var="vendor">
                <tr>
                    <td>${vendor.id}</td>
                    <td>${vendor.name}</td>
                    <td>
                        <form:form action="/gameservice/vendor/${vendor.id}" method="GET">
                            <input alt="Show Account" src="/gameservice/images/show.png" title="Show Vendor" type="image" value="Show Vendor"/>
                        </form:form>
                    </td>
                    <sec:authorize ifAllGranted="ROLE_ADMIN">
                    <td>
                        <form:form action="/gameservice/vendor/${vendor.id}/form" method="GET">
                            <input alt="Update Vendor" src="/gameservice/images/update.png" title="Update Vendor" type="image" value="Update Vendor"/>
                        </form:form>
                    </td>
                    <td>
                        <form:form action="/gameservice/vendor/${vendor.id}" method="DELETE">
                            <input alt="Delete Vendor" src="/gameservice/images/delete.png" title="Delete Vendor" type="image" value="Delete Vendor"/>
                        </form:form>
                    </td>
                    </sec:authorize>
                </tr>
            </c:forEach>
        </table>
    </c:if>
    <c:if test="${empty vendors}">No vendors found.</c:if>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
