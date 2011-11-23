<%@ include file="/WEB-INF/jsp/includes.jsp" %>
<%@ include file="/WEB-INF/jsp/header.jsp" %>

<c:if test="${exception ne null}">
<%
Exception ex = (Exception) request.getAttribute("exception");
%>

<h2>Exception: <%= ex.getMessage() %></h2>
<p/>

<%
ex.printStackTrace(new java.io.PrintWriter(out));
%>

<p/>
<br/>
</c:if>
<a href="<c:url value="/index.jsp" />">Home</a>

<%@ include file="/WEB-INF/jsp/footer.jsp" %>