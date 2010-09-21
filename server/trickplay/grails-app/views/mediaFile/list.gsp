
<%@ page import="trickplay.MediaFile" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'mediaFile.label', default: 'MediaFile')}" />
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
                        
                            <g:sortableColumn property="id" title="${message(code: 'mediaFile.id.label', default: 'Id')}" />
                        
                            <g:sortableColumn property="size" title="${message(code: 'mediaFile.size.label', default: 'Size')}" />
                        
                            <g:sortableColumn property="path" title="${message(code: 'mediaFile.path.label', default: 'Path')}" />
                        
                            <g:sortableColumn property="name" title="${message(code: 'mediaFile.name.label', default: 'Name')}" />
                        
                            <g:sortableColumn property="extension" title="${message(code: 'mediaFile.extension.label', default: 'Extension')}" />
                        
                            <g:sortableColumn property="dateUploaded" title="${message(code: 'mediaFile.dateUploaded.label', default: 'Date Uploaded')}" />
                        
                        </tr>
                    </thead>
                    <tbody>
                    <g:each in="${mediaFileInstanceList}" status="i" var="mediaFileInstance">
                        <tr class="${(i % 2) == 0 ? 'odd' : 'even'}">
                        
                            <td><g:link action="show" id="${mediaFileInstance.id}">${fieldValue(bean: mediaFileInstance, field: "id")}</g:link></td>
                        
                            <td>${fieldValue(bean: mediaFileInstance, field: "size")}</td>
                        
                            <td>${fieldValue(bean: mediaFileInstance, field: "path")}</td>
                        
                            <td>${fieldValue(bean: mediaFileInstance, field: "name")}</td>
                        
                            <td>${fieldValue(bean: mediaFileInstance, field: "extension")}</td>
                        
                            <td><g:formatDate date="${mediaFileInstance.dateUploaded}" /></td>
                        
                        </tr>
                    </g:each>
                    </tbody>
                </table>
            </div>
            <div class="paginateButtons">
                <g:paginate total="${mediaFileInstanceTotal}" />
            </div>
        </div>
    </body>
</html>
