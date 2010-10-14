package net.authorize.cim.examples;

import net.authorize.cim.DeleteCustomerProfileResponseType;
import net.authorize.cim.ServiceSoap;
import net.authorize.cim.SoapAPIUtilities;

public class DeleteProfilesTest{
	public static void main(String args[]){
		System.out.println(SoapAPIUtilities.getExampleLabel("Delete Profiles Test"));
		int profile_id = 0;
		
		if(args.length > 0){
			try{
				profile_id = Integer.parseInt(args[0]);
			}
			catch(NumberFormatException e){
				System.out.println("Unexpected id " + args[0]);
			}
		}
		if(profile_id <= 0){
			System.out.println("Syntax: DeleteProfilesTest {customer-profile-id}");
			System.exit(0);
		}
		
		ServiceSoap soap = SoapAPIUtilities.getServiceSoap();
		DeleteCustomerProfileResponseType response = soap.deleteCustomerProfile(SoapAPIUtilities.getMerchantAuthentication(), profile_id);
		
		System.out.println("Response Code: " + response.getResultCode().value());
		for(int i = 0; i < response.getMessages().getMessagesTypeMessage().size(); i++){
			System.out.println("Message: " + response.getMessages().getMessagesTypeMessage().get(i).getText());
		}
		
	}
}