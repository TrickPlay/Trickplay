<jsp:directive.include file="/WEB-INF/jsp/includes.jsp"/>
<jsp:directive.include file="/WEB-INF/jsp/header.jsp"/>
<script type="text/javascript">dojo.require("dijit.TitlePane");</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="Show Game"> 
    <c:if test="${not empty game}">
        <div>
            <label for="name">Name:</label>
            <div id="name">${game.name}</div>
        </div>
        <br/>
        <div>
            <label for="appId">ApplicationID:</label>
            <div id="appId">${game.appId}</div>
        </div>
        <br/>
        <div>
            <label for="minPlayers">Minimum Players:</label>
            <div id="minPlayers">${game.minPlayers}</div>
        </div>
        <br/>
        <div>
            <label for="maxPlayers">Maximum Players:</label>
            <div id="maxPlayers">${game.maxPlayers}</div>
        </div>
        <br/>
        <div>
            <label for="leaderboardFlag">Leaderboard configured:</label>
            <div id="leaderboardFlag">${game.leaderboardFlag}</div>
        </div>
        <br/>
        <div>
            <label for="achievementsFlag">Achievements configured:</label>
            <div id="achievementsFlag">${game.achievementsFlag}</div>
        </div>
        <br/>
    </c:if>
    <c:if test="${empty game}">No game found with this id.</c:if>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp"/>
