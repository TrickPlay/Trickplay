<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">dojo.require("dijit.TitlePane");</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="List All Users">
    <c:if test="${not empty users}">
    	<c:if test="${not empty param['integrityViolation']}">
    		<span class="errors">${param['integrityViolation']}</span>
    	</c:if>
        <table width="300px">
            <tr>
                <thead>
                    <th>Id</th>                    
                    <th>Username</th>
                    <th>Email</th>
                    <th/>
                    <th/>
                    <th/>
                </thead>
            </tr>
            <c:forEach items="${users}" var="user">
                <tr>
                    <td>${user.id}</td>                    
                    <td>${user.username}</td>
                    <td>${user.email}</td>
                    <td>
                        <form:form action="/gameservice/user/${user.id}/buddy-list" method="GET">
                            <input alt="Show User" src="/gameservice/images/show.png" title="Show User" type="image" value="Show User"/>
                        </form:form>
                    </td>
                    <td>
                        <form:form action="/gameservice/user/${user.id}/form" method="GET">
                            <input alt="Update User" src="/gameservice/images/update.png" title="Update User" type="image" value="Update User"/>
                        </form:form>
                    </td>
                    <sec:authorize ifAllGranted="ROLE_ADMIN">
                    <td>
                        <form:form action="/gameservice/user/${user.id}" method="DELETE">
                            <input alt="Delete User" src="/gameservice/images/delete.png" title="Delete User" type="image" value="Delete User"/>
                        </form:form>
                    </td>
                    </sec:authorize>
                </tr>
            </c:forEach>
        </table>
    </c:if>
    <c:if test="${empty users}">No users found.</c:if>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
