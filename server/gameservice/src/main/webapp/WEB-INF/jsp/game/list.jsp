<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">dojo.require("dijit.TitlePane");</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="List All Games">
    <c:if test="${not empty games}"> 
        <c:if test="${not empty param['integrityViolation']}">
    		<span class="errors">${param['integrityViolation']}</span>
    	</c:if>
        <table width="300px">
            <tr>
                <thead>
                    <th>Id</th>
                    <th>Name</th>
                    <th>Vendor</th>
                    <th>ApplicationID</th>
                    <th>Minimum Players</th>
                    <th>Maximum Players</th>
                    <th>Leaderboard</th>
                    <th>Achievements</th>
                    <th/>
                    <th/>
                    <th/>
                </thead>
            </tr>
            <c:forEach items="${games}" var="game">
                <tr>
                    <td>${game.id}</td>
                    <td>${game.name}</td>
                    <td>${game.vendorName}</td>
                    <td>${game.appId}</td>
                     <td>${game.minPlayers}</td>
                    <td>${game.maxPlayers}</td>
                    <td>${game.leaderboardFlag}</td>
                    <td>${game.achievementsFlag}</td>
                    <td>
                        <form:form action="/gameservice/game/${game.id}" method="GET">
                            <input alt="Show Game" src="/gameservice/images/show.png" title="Show Game" type="image" value="Show Game"/>
                        </form:form>
                    </td>
                    <td>
                        <form:form action="/gameservice/game/${game.id}/form" method="GET">
                            <input alt="Update Game" src="/gameservice/images/update.png" title="Update Game" type="image" value="Update Game"/>
                        </form:form>
                    </td>
                    <td>
                        <form:form action="/gameservice/game/${game.id}" method="DELETE">
                            <input alt="Delete Game" src="/gameservice/images/delete.png" title="Delete Game" type="image" value="Delete Game"/>
                        </form:form>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </c:if>
    <c:if test="${empty games}">No Games found.</c:if>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
