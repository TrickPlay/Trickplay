package net.authorize.cim.examples;

import net.authorize.cim.GetCustomerProfileResponseType;
import net.authorize.cim.CustomerProfileMaskedType;
import net.authorize.cim.ServiceSoap;
import net.authorize.cim.CustomerPaymentProfileMaskedType;
import net.authorize.cim.ProfileTransAuthCaptureType;
import net.authorize.cim.ProfileTransactionType;
import net.authorize.cim.OrderExType;
import net.authorize.cim.CreateCustomerProfileTransactionResponseType;
import net.authorize.cim.SoapAPIUtilities;

import java.util.List;

public class CreateTransactionTest{

	public static void main(String args[]){
		System.out.println(SoapAPIUtilities.getExampleLabel("Create Transaction Test"));
		int profile_id = 0;
		int payment_profile_id = 0;
		java.math.BigDecimal amount = new java.math.BigDecimal(0);
		if(args.length > 0){
			try{
				profile_id = Integer.parseInt(args[0]);
			}
			catch(NumberFormatException e){
				System.out.println("Unexpected id " + args[0]);
			}
		}
		if(args.length > 2){
			try{
				payment_profile_id = Integer.parseInt(args[1]);
				amount = java.math.BigDecimal.valueOf(Double.parseDouble(args[2]));
			}
			catch(NumberFormatException e){
				System.out.println("Unexpected id " + args[1]);
			}
		}
		if(profile_id <= 0){
			System.out.println("Syntax: GetProfilesTest {customer-profile-id}");
			System.out.println("Syntax: GetProfilesTest {customer-profile-id} {payment-profile-id} {amount}");
			System.exit(0);
		}
		
		ServiceSoap soap = SoapAPIUtilities.getServiceSoap();
		
		if(payment_profile_id <= 0){
			CustomerProfileMaskedType customer_profile = (soap.getCustomerProfile(SoapAPIUtilities.getMerchantAuthentication(), profile_id)).getProfile();
			if(customer_profile == null){
				System.out.println("Profile with id " + profile_id + " is null");
				return;
			}
			
			List<CustomerPaymentProfileMaskedType> payment_profiles = customer_profile.getPaymentProfiles().getCustomerPaymentProfileMaskedType();
			if(payment_profiles.size() == 0){
				System.out.println("No payment profiles exist.  Please create a payment profile for customer profile #" + profile_id);
				return;
			}
			
			else if(payment_profiles.size() >= 1){
				System.out.println("Please specify which payment profile to use:");
				for(int i = 0; i < payment_profiles.size(); i++){
					
					String card_num = null;
					if(payment_profiles.get(i).getPayment().getBankAccount() != null) card_num = payment_profiles.get(i).getPayment().getBankAccount().getAccountNumber();
					else if(payment_profiles.get(i).getPayment().getCreditCard() != null) card_num = payment_profiles.get(i).getPayment().getCreditCard().getCardNumber();
					System.out.println(payment_profiles.get(i).getCustomerPaymentProfileId() + " - " + card_num);
				}
				return;
			
			}
			
		} // end if payment_profile_id <= 0
		ProfileTransAuthCaptureType auth_capture = new ProfileTransAuthCaptureType();

		auth_capture.setCustomerProfileId(profile_id);
		auth_capture.setCustomerPaymentProfileId(payment_profile_id);
		auth_capture.setAmount(amount);
		OrderExType order = new OrderExType();
		order.setInvoiceNumber("invoice1234");
		auth_capture.setOrder(order);

		ProfileTransactionType trans = new ProfileTransactionType();
		trans.setProfileTransAuthCapture(auth_capture);

		CreateCustomerProfileTransactionResponseType response = soap.createCustomerProfileTransaction(SoapAPIUtilities.getMerchantAuthentication(), trans, null);

		System.out.println("Response Code: " + response.getResultCode().value());
		for(int i = 0; i < response.getMessages().getMessagesTypeMessage().size(); i++){
			System.out.println("Message: " + response.getMessages().getMessagesTypeMessage().get(i).getText());
		}

		/*
		GetCustomerProfileResponseType response_type = soap.getCustomerProfile(SoapAPIUtilities.getMerchantAuthentication(), profile_id);
		CustomerProfileMaskedType profile = response_type.getProfile();
		if(profile == null){
			System.out.println("Profile with id " + profile_id + " is null");
		}
		else{
			System.out.println("Retrieved profile " + profile.getCustomerProfileId() + " / " + profile.getDescription());
			
			// Change the description to be the current time
			//
			profile.setDescription(new java.util.Date().toLocaleString());
			UpdateCustomerProfileResponseType response = soap.updateCustomerProfile(SoapAPIUtilities.getMerchantAuthentication(), profile);
			
			System.out.println("Response Code: " + response.getResultCode().value());
			for(int i = 0; i < response.getMessages().getMessagesTypeMessage().size(); i++){
				System.out.println("Message: " + response.getMessages().getMessagesTypeMessage().get(i).getText());
			}
		}
		*/
		
	}
}