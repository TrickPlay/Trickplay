package net.authorize.cim.examples;

import net.authorize.cim.GetCustomerProfileResponseType;
import net.authorize.cim.CustomerPaymentProfileMaskedType;
import net.authorize.cim.CustomerProfileMaskedType;
import net.authorize.cim.ServiceSoap;
import net.authorize.cim.SoapAPIUtilities;

public class GetProfilesTest{
	public static void main(String args[]){
		System.out.println(SoapAPIUtilities.getExampleLabel("Get Profiles Test"));
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
			System.out.println("Syntax: GetProfilesTest {customer-profile-id}");
			System.exit(0);
		}
		
		ServiceSoap soap = SoapAPIUtilities.getServiceSoap();
		GetCustomerProfileResponseType response_type = soap.getCustomerProfile(SoapAPIUtilities.getMerchantAuthentication(), profile_id);
		CustomerProfileMaskedType profile = response_type.getProfile();
		if(profile == null){
			System.out.println("Profile with id " + profile_id + " is null");
		}
		else{
			System.out.println("Retrieved profile " + profile.getCustomerProfileId() + " / " + profile.getDescription());
			if (profile.getPaymentProfiles() != null){
				for(CustomerPaymentProfileMaskedType paymentProfile : profile.getPaymentProfiles().getCustomerPaymentProfileMaskedType()){
					System.out.println("With payment profile " + paymentProfile.getCustomerPaymentProfileId());
				}
			}
		}
		
	}
}