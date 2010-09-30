
<%@ page import="trickplay.ApplicationFile" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'applicationFile.label', default: 'ApplicationFile')}" />
        <title><g:message code="default.list.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}">Home</a></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.list.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="list">
                <table>
                    <thead>
                        <tr>
                        
                            <g:sortableColumn property="id" title="${message(code: 'applicationFile.id.label', default: 'Id')}" />
                        
                            <g:sortableColumn property="size" title="${message(code: 'applicationFile.size.label', default: 'Size')}" />
                        
                            <g:sortableColumn property="path" title="${message(code: 'applicationFile.path.label', default: 'Path')}" />
                        
                            <g:sortableColumn property="name" title="${message(code: 'applicationFile.name.label', default: 'Name')}" />
                        
                            <g:sortableColumn property="extension" title="${message(code: 'applicationFile.extension.label', default: 'Extension')}" />
                        
                            <g:sortableColumn property="dateUploaded" title="${message(code: 'applicationFile.dateUploaded.label', default: 'Date Uploaded')}" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${applicationFileInstanceList}" status="i" var="applicationFileInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${applicationFileInstance.id}">${fieldValue(bean: applicationFileInstance, field: "id")}</g:link></td>
                        
                            <td>${fieldValue(bean: applicationFileInstance, field: "size")}</td>
                        
                            <td>${fieldValue(bean: applicationFileInstance, field: "path")}</td>
                        
                            <td>${fieldValue(bean: applicationFileInstance, field: "name")}</td>
                        
                            <td>${fieldValue(bean: applicationFileInstance, field: "extension")}</td>
                        
                            <td><g:formatDate date="${applicationFileInstance.dateUploaded}" /></td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${applicationFileInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
