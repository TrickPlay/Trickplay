<jsp:directive.include file="/WEB-INF/jsp/includes.jsp" />
<jsp:directive.include file="/WEB-INF/jsp/header.jsp" />
<script type="text/javascript">
	dojo.require("dijit.TitlePane");
	dojo.require("dijit.form.MultiSelect");
	dojo.require("dijit.form.Button");
</script>
<div dojoType="dijit.TitlePane" style="width: 100%" title="Show User Buddies">
	<div>
		<form:form id="invitationErrors" modelAttribute="invitation">
			<form:errors path="*" cssClass="errors" />
		</form:form>
	</div>
	<br />
	<c:if test="${not empty userBuddies}">
		<div>
			<label for="username">Username:</label>
			<div id="username">${userBuddies.user.username}</div>
		</div>
		<br />
		<div>
			<label for="email">Email:</label>
			<div id="email">${userBuddies.user.email}</div>
		</div>
		<br />
		<div>
			<form:form id="buddyListForm" modelAttribute="userBuddies">
				<c:if test="${not empty userBuddies.buddies}">
					<label for="buddies">Buddies:</label>
					<form:select path="buddies">
						<form:options itemValue="id" itemLabel="username"
							items="${userBuddies.buddies}" />
					</form:select>
					<script type="text/javascript">
						Spring.addDecoration(new Spring.ElementDecoration({
							elementId : "buddies",
							widgetType : "dijit.form.MultiSelect",
							widgetAttrs : {
								hasDownArrow : true
							}
						}));
					</script>
				</c:if>
			</form:form>
		</div>
		<br />
		<c:if test="${not empty userBuddies.invitationsSent}">
			<div>Invitations Sent
			<table width="300px">
				<tr>
				<thead>
					<th>Recipient</th>
					<th />
				</thead>
				</tr>
				<c:forEach items="${userBuddies.invitationsSent}" var="invitationSent">
					<tr>
						<td>${invitationSent.recipient}</td>
						<td><form:form
								action="/gameservice/user/${userBuddies.user.id}/invitation/${invitationSent.id}"
								method="POST" modelAttribute="invitation">
								<form:hidden path="status" value="CANCELLED"/>
								<input alt="Cancel" src="/gameservice/images/delete.png"
									title="Cancel" type="image"/>
							</form:form></td>
					</tr>
				</c:forEach>
			</table>
			</div>
		</c:if>
		<c:if test="${not empty userBuddies.invitationsReceived}">
			<div>Invitations Received
			<table width="300px">
				<tr>
					<thead>
					<th>Requestor</th>
					<th />
					<th />
				</thead>
				</tr>
				<c:forEach items="${userBuddies.invitationsReceived}" var="invitationReceived">
					<tr>
						<td>${invitationReceived.requestor}</td>
						<td><form:form
								action="/gameservice/user/${userBuddies.user.id}/invitation/${invitationReceived.id}"
								method="POST"
								modelAttribute="invitation">
								<form:hidden path="status" value="ACCEPTED"/>
								<input alt="Accept" src="/gameservice/images/accept.png"
									title="Accept" type="image" />
							</form:form>
						</td>
						<td><form:form
								action="/gameservice/user/${userBuddies.user.id}/invitation/${invitationReceived.id}"
								method="POST"
								modelAttribute="invitation">
								<form:hidden path="status" value="REJECTED"/>
								<input alt="Decline" src="/gameservice/images/delete.png"
									title="Decline" type="image" />
							</form:form>
						</td>
					</tr>
				</c:forEach>
			</table>
			</div>
		</c:if>
		<br />
		<div>
			<label for="newBuddyInvitation"></label>
			<div id="newBuddyInvitation" dojoType="dijit.form.DropDownButton">
				<span>Send Buddy Invitation</span>
				<div dojoType="dijit.TooltipDialog" id="tooltipDlg"
								title="Enter Buddy's GameCenter username">
					<form:form
									action="/gameservice/user/${userBuddies.user.id}/invitation"
									method="POST" modelAttribute="invitation">
						<div>
							<label for="recipient">Recipient Username:</label>
							<form:input cssStyle="width:250px" maxlength="30"
											path="recipient" size="30" />
							<script type="text/javascript">
								Spring
										.addDecoration(new Spring.ElementDecoration(
												{
													elementId : "recipient",
													widgetType : "dijit.form.ValidationTextBox",
													regExp: "[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&amp;'*+/=?^_`{|}~-]+)*{3,15}",
													widgetAttrs : {
														invalidMessage : "Enter valid GameCenter username",
														required : true
													}
												}));
							</script>
						</div>
						<br />
						<div class="submit">
						<!-- 
							<script type="text/javascript">
								Spring
										.addDecoration(new Spring.ValidateAllDecoration(
												{
													elementId : 'proceed',
													event : 'onclick'
												}));
							</script>
							 -->
							<input id="proceed" type="submit" value="Send" />
						</div>
					</form:form>
							</div>
			</div>
		</div>
	
			
				</c:if>
	<c:if test="${empty userBuddies}">No user found with this id.</c:if>
</div>
<jsp:directive.include file="/WEB-INF/jsp/footer.jsp" />
