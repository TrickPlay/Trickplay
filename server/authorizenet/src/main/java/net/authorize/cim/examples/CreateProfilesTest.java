package net.authorize.cim.examples;

import net.authorize.cim.*;

public class CreateProfilesTest {

	public static void main(String[] args){
		
		System.out.println(SoapAPIUtilities.getExampleLabel("Create Profiles Test"));
		ServiceSoap soap = SoapAPIUtilities.getServiceSoap();

		CustomerPaymentProfileType new_payment_profile = new CustomerPaymentProfileType();
		
		PaymentType new_payment = new PaymentType();
		BankAccountType new_bank = new BankAccountType();
		new_bank.setAccountNumber("4111111");
		
		CreditCardType new_card = new CreditCardType();
		new_card.setCardNumber("4111111111111111");
		
		try{
			javax.xml.datatype.XMLGregorianCalendar cal = javax.xml.datatype.DatatypeFactory.newInstance().newXMLGregorianCalendar();
			cal.setMonth(2);
			cal.setYear(2009);
			new_card.setExpirationDate(cal);
			// System.out.println(new_card.getExpirationDate().toXMLFormat());
		}
		catch(javax.xml.datatype.DatatypeConfigurationException dce){
			System.out.println(dce.getMessage());
		}
		
		new_payment.setCreditCard(new_card);
		//new_payment.setBankAccount(new_bank);
		
		new_payment_profile.setPayment(new_payment);

		CustomerProfileType m_new_cust = new CustomerProfileType();
		m_new_cust.setEmail("here@there.com");
		m_new_cust.setDescription("Example customer: " + Long.toString(System.currentTimeMillis()));

		
		ArrayOfCustomerPaymentProfileType pay_list = new ArrayOfCustomerPaymentProfileType();
		pay_list.getCustomerPaymentProfileType().add(new_payment_profile);
		
		m_new_cust.setPaymentProfiles(pay_list);
		
		CreateCustomerProfileResponseType response = soap.createCustomerProfile(SoapAPIUtilities.getMerchantAuthentication(),m_new_cust,ValidationModeEnum.LIVE_MODE);
		if(response != null){
			
			System.out.println("Response Code: " + response.getResultCode().value());
			for(int i = 0; i < response.getMessages().getMessagesTypeMessage().size(); i++){
				System.out.println("Message: " + response.getMessages().getMessagesTypeMessage().get(i).getText());
			}
			long new_cust_id = response.getCustomerProfileId();
			if(new_cust_id > 0){
				System.out.println("New ID = " + new_cust_id);
			}
			if (response.getCustomerPaymentProfileIdList() != null){
				for(long paymentProfileId : response.getCustomerPaymentProfileIdList().getLong()){
					System.out.println("With payment profile ID = " + paymentProfileId);
				}
			}
		
		}
		else{
			System.out.println("Null response from server");
		}
		
	}
	
}
