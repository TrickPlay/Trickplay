
<%@ page import="trickplay.ApplicationFile" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'applicationFile.label', default: 'ApplicationFile')}" />
        <title><g:message code="default.show.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.show.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <div class="dialog">
                <table>
                    <tbody>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="applicationFile.id.label" default="Id" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: applicationFileInstance, field: "id")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="applicationFile.size.label" default="Size" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: applicationFileInstance, field: "size")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="applicationFile.path.label" default="Path" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: applicationFileInstance, field: "path")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="applicationFile.name.label" default="Name" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: applicationFileInstance, field: "name")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="applicationFile.extension.label" default="Extension" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: applicationFileInstance, field: "extension")}</td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="applicationFile.dateUploaded.label" default="Date Uploaded" /></td>
                            
                            <td valign="top" class="value"><g:formatDate date="${applicationFileInstance?.dateUploaded}" /></td>
                            
                        </tr>
                    
                        <tr class="prop">
                            <td valign="top" class="name"><g:message code="applicationFile.downloads.label" default="Downloads" /></td>
                            
                            <td valign="top" class="value">${fieldValue(bean: applicationFileInstance, field: "downloads")}</td>
                            
                        </tr>
                    
                    </tbody>
                </table>
            </div>
            <div class="buttons">
                <g:form>
                    <g:hiddenField name="id" value="${applicationFileInstance?.id}" />
                    <span class="button"><g:actionSubmit class="edit" action="edit" value="${message(code: 'default.button.edit.label', default: 'Edit')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </g:form>
            </div>
        </div>
    </body>
</html>
