package net.authorize.cim;

import java.net.MalformedURLException;
import java.net.URL;

import javax.xml.namespace.QName;

import net.authorize.cim.MerchantAuthenticationType;
import net.authorize.cim.Service;
import net.authorize.cim.ServiceSoap;

public class SoapAPIUtilities{
	
	public static final String EXAMPLE_WSDL_URL = "https://apitest.authorize.net/soap/v1/Service.asmx?wsdl";
	
	// TODO: Specify you merchant account name
	//
	public static final String EXAMPLE_MERCHANT_NAME = "YourMerchantAccountName";

	// TODO: Specify you merchant transaction key
	//
	public static final String EXAMPLE_TRANSACTION_KEY = "YourMerchantTransactionKey";
	
	private static MerchantAuthenticationType m_auth = null;
	
	public static String getExampleLabel(String example_name){
		
		return "\r\nAuthorize.Net Customer API: " + example_name + "\r\nURL: " + EXAMPLE_WSDL_URL + "\r\nMERCHANT: " + EXAMPLE_MERCHANT_NAME + "\r\n\r\n";
	}
	
	public static MerchantAuthenticationType getMerchantAuthentication(){
		if(m_auth == null){
			m_auth = new MerchantAuthenticationType();

			// TODO: Specify Merchant Name
			//
			//m_auth.setName("MerchantName");
			m_auth.setName(EXAMPLE_MERCHANT_NAME);
			
			// TODO: Specify Transaction Key
			//
			//m_auth.setTransactionKey("TransactionKey");
			m_auth.setTransactionKey(EXAMPLE_TRANSACTION_KEY);
		}
		return m_auth;
	}
	
	private static ServiceSoap service_soap = null;
	public static ServiceSoap getServiceSoap(){
		if(service_soap != null) return service_soap;
		return getServiceSoap(EXAMPLE_WSDL_URL);
	}
	public static ServiceSoap getServiceSoap(String url){
	
		URL wsdl_url = null;
		try {
			wsdl_url = new URL(url);
		}
		catch (MalformedURLException e) {
			e.printStackTrace();
		}
		if(wsdl_url == null){
			return null;
		}

		Service rebill_ws = new Service(wsdl_url, new QName("https://api.authorize.net/soap/v1/", "Service"));
		service_soap = rebill_ws.getServiceSoap();
		return service_soap;
	}

}
