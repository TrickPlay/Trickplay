#include <iostream>
#include <constants.h>
#include <logging.h>
#include "xmppregisterclient.h"

#include "xmppmugconstants.h"
#include "registeraccounttask.h"


namespace libgameservice {

extern const txmpp::Jid getXmppServerJid();

static const std::string REGISTER_ACCOUNT_PART_1_PREFIX("register-account-part1-");
static const std::string REGISTER_ACCOUNT_PART_2_PREFIX("register-account-part2-");

// RegisterAccount task
RegisterAccountTask::RegisterAccountTask(txmpp::TaskParent *parent, const AccountInfo & account_info) :
	txmpp::XmppRegisterTask(parent, txmpp::XmppEngine::HL_SINGLE), account_info_(account_info) {

	std::cout << "Inside RegisterAccountTask constructor" << std::endl;
}

RegisterAccountTask::~RegisterAccountTask() {
}

int RegisterAccountTask::ProcessStart() {

	std::cout << "RegisterAccountTask taskid is " << task_id() << std::endl;

	std::string id = REGISTER_ACCOUNT_PART_1_PREFIX + task_id();
	set_task_id(id);



	txmpp::scoped_ptr<txmpp::XmlElement> iqStanza(
			MakeIq("get", getXmppServerJid(), id));
	txmpp::XmlElement *registerElement = new txmpp::XmlElement(
			QN_IQ_REGISTER_QUERY);
	iqStanza->AddElement(registerElement);

	SendStanza(iqStanza.get());

	return STATE_RESPONSE;
}

int RegisterAccountTask::ProcessResponse() {

	const txmpp::XmlElement* stanza = NextStanza();

	if (stanza == NULL) {
		return STATE_BLOCKED;
	}

	StatusCode status_code = OK;
	std::string error_msg("");

	std::string from = "Someone";

	if (stanza->HasAttr(txmpp::QN_FROM))
		from = stanza->Attr(txmpp::QN_FROM);

	const std::string& id = stanza->Attr(txmpp::QN_ID);
	const char* id_str = id.c_str();
	const char* idx = NULL;
	if ((idx = strstr(id_str, REGISTER_ACCOUNT_PART_1_PREFIX.c_str())) != NULL && idx == id_str)
	{
		// check if the user is already registered. in this case return an error
		if ( stanza->FirstNamed(QN_IQ_REGISTER_REGISTERED_TAG) != NULL ) {
			// user is already registered
			status_code = ALREADY_REGISTERED;
			error_msg = "A new account can be only registered by anonymous users.";
		}
		else
		{
			const txmpp::XmlElement * errorElement = stanza->FirstNamed(txmpp::QN_ERROR);
			if (errorElement != NULL) {
				status_code = FAILED;
				error_msg = "IQ register query part 1 failed.";
			}
			else
			{
				// register the account
				/*
				 * <query xmlns="jabber:iq:register">
						<x xmlns="jabber:x:data" type="form">
							<field type="hidden" var="FORM_TYPE">
								<value>jabber:iq:register</value>
							</field>
							<field type="text-single" var="username">
								<value>test1</value>
							</field>
							<field type="text-single" var="name">
								<value>test1</value>
							</field>
							<field type="text-single" var="email">
								<value>test1</value>s
							</field>
							<field type="text-private" var="password">
								<value>test1</value>
							</field>
						</x>
					</query>
				 */
				std::string id = REGISTER_ACCOUNT_PART_2_PREFIX + task_id();
				set_task_id(id);

				txmpp::scoped_ptr<txmpp::XmlElement> iqStanza(
							MakeIq("set", getXmppServerJid(), id));
				txmpp::XmlElement *registerElement = new txmpp::XmlElement(
							QN_IQ_REGISTER_QUERY, true);

				txmpp::XmlElement* x_form = new txmpp::XmlElement(QN_XDATA_X, true);
				x_form->SetAttr(txmpp::QN_TYPE, "form");

				txmpp::XmlElement* formtype_field =
				      new txmpp::XmlElement(QN_XDATA_FIELD, false);
				formtype_field->SetAttr(txmpp::QN_VAR, "FORM_TYPE");
				formtype_field->SetAttr(txmpp::QN_TYPE, "hidden");

				txmpp::XmlElement* formtype_field_value = new txmpp::XmlElement(QN_XDATA_VALUE, false);
				formtype_field_value->AddText(NS_IQ_REGISTER);
				formtype_field->AddElement(formtype_field_value);

				x_form->AddElement(formtype_field);


				txmpp::XmlElement* username_field = new txmpp::XmlElement(
						QN_XDATA_FIELD, false);
				username_field->SetAttr(txmpp::QN_VAR, "username");
				username_field->SetAttr(txmpp::QN_TYPE, "text-single");

				txmpp::XmlElement* username_field_value =
						new txmpp::XmlElement(QN_XDATA_VALUE, false);
				username_field_value->AddText(account_info_.user_id());
				username_field->AddElement(username_field_value);

				x_form->AddElement(username_field);

				txmpp::XmlElement* password_field = new txmpp::XmlElement(
						QN_XDATA_FIELD, false);
				password_field->SetAttr(txmpp::QN_VAR, "password");
				password_field->SetAttr(txmpp::QN_TYPE, "text-private");

				txmpp::XmlElement* password_field_value =
						new txmpp::XmlElement(QN_XDATA_VALUE, false);
				password_field_value->AddText(account_info_.password());
				password_field->AddElement(password_field_value);

				x_form->AddElement(password_field);


				if (!account_info_.email().empty()) {
					txmpp::XmlElement* email_field = new txmpp::XmlElement(
							QN_XDATA_FIELD, false);
					email_field->SetAttr(txmpp::QN_VAR, "email");
					email_field->SetAttr(txmpp::QN_TYPE, "text-single");

					txmpp::XmlElement* email_field_value =
							new txmpp::XmlElement(QN_XDATA_VALUE, false);
					email_field_value->AddText(account_info_.email());
					email_field->AddElement(email_field_value);

					x_form->AddElement(email_field);
				}

				if (!account_info_.full_name().empty()) {
					txmpp::XmlElement* name_field = new txmpp::XmlElement(
							QN_XDATA_FIELD, false);
					name_field->SetAttr(txmpp::QN_VAR, "name");
					name_field->SetAttr(txmpp::QN_TYPE, "text-single");

					txmpp::XmlElement* name_field_value =
							new txmpp::XmlElement(QN_XDATA_VALUE, false);
					name_field_value->AddText(account_info_.full_name());
					name_field->AddElement(name_field_value);

					x_form->AddElement(name_field);
				}

				registerElement->AddElement(x_form);
				iqStanza->AddElement(registerElement);

				SendStanza(iqStanza.get());

				return STATE_RESPONSE;
			}
		}
	}
	else if ((idx = strstr(id_str, REGISTER_ACCOUNT_PART_2_PREFIX.c_str())) != NULL && idx == id_str)
	{
		const txmpp::XmlElement * errorElement = stanza->FirstNamed(txmpp::QN_ERROR);
		if (errorElement != NULL) {
			const std::string& code = errorElement->Attr(txmpp::QN_CODE);
			if (code == "409") {
				status_code = USER_ID_CONFLICT;
				error_msg = "A user with the requested username already exists";
			}
			else if (code == "406") {
				status_code = REQUIRED_FIELD_MISSING;
				error_msg = "some required field information not provided for registration";
			} else {
				status_code = FAILED;
				error_msg = "IQ register part 2 failed. server returned error code=" + code;
			}
		}
	}
	else
	{
		status_code = FAILED;
		error_msg = "IQ register failed";
	}
	std::cout << "RegisterAccount results follow: " << std::endl;
	std::cout << stanza->Str() << std::endl;

	//const txmpp::XmlElement* discoInfoResponse = stanza->FirstNamed(txmpp::QN_DISCO_INFO_QUERY);
	ResponseStatus rs(status_code, error_msg);

	SignalDone(rs);

	return STATE_DONE;
}

bool RegisterAccountTask::HandleStanza(const txmpp::XmlElement *stanza) {

	//std::cout << "ListGamesTask::HandleStanza. processing stanza:" << stanza->Str() << std::endl;

	if (MatchResponseIq(stanza, getXmppServerJid(), task_id())) {
		QueueStanza(stanza);
		return true;
	}

	return false;
}


}

