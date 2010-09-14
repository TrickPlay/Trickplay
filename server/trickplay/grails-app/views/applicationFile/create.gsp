
<%@ page import="trickplay.ApplicationFile" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'applicationFile.label', default: 'ApplicationFile')}" />
        <title><g:message code="default.create.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.create.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${applicationFileInstance}">
            <div class="errors">
                <g:renderErrors bean="${applicationFileInstance}" as="list" />
            </div>
            </g:hasErrors>

<div class="dialog">
  <table>
    <tbody>
      <tr class="prop">
<fileuploader:form upload="application"
successAction="create"
successController="applicationFile"
errorAction="create"
errorController="applicationFile"/> 
      </tr>
    </tbody>
  </table>
</div>

        </div>
    </body>
</html>
