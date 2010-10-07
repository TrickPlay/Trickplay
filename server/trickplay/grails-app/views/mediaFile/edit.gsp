
<%@ page import="trickplay.MediaFile" %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="main" />
        <g:set var="entityName" value="${message(code: 'mediaFile.label', default: 'MediaFile')}" />
        <title><g:message code="default.edit.label" args="[entityName]" /></title>
    </head>
    <body>
        <div class="nav">
            <span class="menuButton"><a class="home" href="${createLink(uri: '/')}">Home</a></span>
            <span class="menuButton"><g:link class="list" action="list"><g:message code="default.list.label" args="[entityName]" /></g:link></span>
            <span class="menuButton"><g:link class="create" action="create"><g:message code="default.new.label" args="[entityName]" /></g:link></span>
        </div>
        <div class="body">
            <h1><g:message code="default.edit.label" args="[entityName]" /></h1>
            <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
            </g:if>
            <g:hasErrors bean="${mediaFileInstance}">
            <div class="errors">
                <g:renderErrors bean="${mediaFileInstance}" as="list" />
            </div>
            </g:hasErrors>
            <g:form method="post" >
                <g:hiddenField name="id" value="${mediaFileInstance?.id}" />
                <g:hiddenField name="version" value="${mediaFileInstance?.version}" />
                <div class="dialog">
                    <table>
                        <tbody>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="size"><g:message code="mediaFile.size.label" default="Size" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: mediaFileInstance, field: 'size', 'errors')}">
                                    <g:textField name="size" value="${fieldValue(bean: mediaFileInstance, field: 'size')}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="path"><g:message code="mediaFile.path.label" default="Path" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: mediaFileInstance, field: 'path', 'errors')}">
                                    <g:textField name="path" value="${mediaFileInstance?.path}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="name"><g:message code="mediaFile.name.label" default="Name" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: mediaFileInstance, field: 'name', 'errors')}">
                                    <g:textField name="name" value="${mediaFileInstance?.name}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="extension"><g:message code="mediaFile.extension.label" default="Extension" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: mediaFileInstance, field: 'extension', 'errors')}">
                                    <g:textField name="extension" value="${mediaFileInstance?.extension}" />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="dateUploaded"><g:message code="mediaFile.dateUploaded.label" default="Date Uploaded" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: mediaFileInstance, field: 'dateUploaded', 'errors')}">
                                    <g:datePicker name="dateUploaded" precision="day" value="${mediaFileInstance?.dateUploaded}"  />
                                </td>
                            </tr>
                        
                            <tr class="prop">
                                <td valign="top" class="name">
                                  <label for="downloads"><g:message code="mediaFile.downloads.label" default="Downloads" /></label>
                                </td>
                                <td valign="top" class="value ${hasErrors(bean: mediaFileInstance, field: 'downloads', 'errors')}">
                                    <g:textField name="downloads" value="${fieldValue(bean: mediaFileInstance, field: 'downloads')}" />
                                </td>
                            </tr>
                        
                        </tbody>
                    </table>
                </div>
                <div class="buttons">
                    <span class="button"><g:actionSubmit class="save" action="update" value="${message(code: 'default.button.update.label', default: 'Update')}" /></span>
                    <span class="button"><g:actionSubmit class="delete" action="delete" value="${message(code: 'default.button.delete.label', default: 'Delete')}" onclick="return confirm('${message(code: 'default.button.delete.confirm.message', default: 'Are you sure?')}');" /></span>
                </div>
            </g:form>
        </div>
    </body>
</html>
