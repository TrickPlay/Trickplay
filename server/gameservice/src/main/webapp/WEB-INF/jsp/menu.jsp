<ul>

	<li>
	<c:choose>
  		<c:when test="${not empty pageContext.request.userPrincipal}">
			<h2>Welcome <c:out value="${request.remoteUser}" /></h2>
			<ul>
			<li><a href="/gameservice/logout">Logout</a></li>
			</ul>
		</c:when>	
		<c:otherwise>
			<h2>Security</h2>
			<ul>
			<li><a href="/gameservice/login.jsp">Login</a></li>
			</ul>
			<ul>
			<li><a href="/gameservice/user/form">Register me</a></li>
			</ul>
		</c:otherwise>
	</c:choose>
	</li>
	<sec:authorize ifAnyGranted="ROLE_USER,ROLE_ADMIN">
	<li>
	<h2>User</h2>
	<ul>
		<li><a href="/gameservice/user">List</a></li>
		<sec:authorize ifAllGranted="ROLE_ADMIN">
			<li><a href="/gameservice/user/form">Create</a></li>
		</sec:authorize>
	</ul>
	</li>
	
	<li>
	<h2>Vendor</h2>
	<ul>
		<li><a href="/gameservice/vendor">List</a></li>
		<li><a href="/gameservice/vendor/form">Create</a></li>
	</ul>
	</li>	
	<li>
	<h2>Game</h2>
	<ul>
		<li><a href="/gameservice/game">List</a></li>
		<li><a href="/gameservice/game/form">Create</a></li>
	</ul>
	</li>
	</sec:authorize>
</ul>
