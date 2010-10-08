package trickplay;

import groovy.xml.MarkupBuilder;
import trickplay.authorizenet.*;
import trickplay.util.CCUtils;


/**
 * test acct creds trickplay123:1Atg301Z
 * test acct keys 23Jt8cX86:2bES488Y9Ycz2pDp
 */
class AuthorizeNetService {

    static final String API_URL = "https://apitest.authorize.net/xml/v1/request.api";
    static final String API_VALIDATION_MODE = "testMode";
    static final String API_AUTH_NAME = "23Jt8cX86";
    static final String API_AUTH_TRANSACTION_KEY = "2bES488Y9Ycz2pDp";

    boolean transactional = true;

    def newPaymentProfile(user, ccNo, expDate, cvv2) {
        def profile = AuthorizeNetProfile.findByUser(user);
        def result = null;
        def customerPaymentProfileId = null;
        if (profile != null) {
            result = createCustomerPaymentProfileRequest(profile.customerProfileId, ccNo, expDate, cvv2);
             if (result.messages.resultCode.text().equals("Error")) {
                throw new Exception(result.messages.message[0].text.text());
            } else {
                customerPaymentProfileId = result.customerPaymentProfileId.text();
            }
        } else {
            result = createCustomerProfileRequest(user.id, user.username, user.email, ccNo, expDate, cvv2);
            if (result.messages.resultCode.text().equals("Error")) {
                throw new Exception(result.messages.message[0].text.text());
            } else {
                profile = new AuthorizeNetProfile(user:user,
                                                  customerProfileId:result.customerProfileId,
                                                  enabled:true);
                profile.save();
                customerPaymentProfileId = result.customerPaymentProfileIdList.numericString[0].text()
            }
        }
        def paymentProfile = new AuthorizeNetPaymentProfile(customerProfile:profile,
                                                            customerPaymentProfileId:customerPaymentProfileId,
                                                            user:user,
                                                            canonicalName:CCUtils.getCardName(ccNo),
                                                            canonicalIdentifier:CCUtils.lastFour(ccNo),
                                                            enabled:true);
        paymentProfile.save();
        return paymentProfile;
    }

    def makePurchase(user, paymentProfile, cvv2, application) {
        def result = createCustomerProfileTransactionRequestForAuthorizationAndCapture(application.price, getItem(application, application.price), paymentProfile.customerProfile.profileId, paymentProfile.customerPaymentProfileId, cvv2);
        if (result.messages.resultCode.text().equals("Error")) {
            throw new Exception(result.messages.message[0].text.text());
        } else {
            def purchase = new Purchase(user:user,
                                        application:application,
                                        paymentProfile:paymentProfile,
                                        price:price,
                                        response:result.directResponse.text());
            purchase.save();
            return purchase;
        }
    }

    /* Create an item used by the AuthorizeNetService */
    def getItem(application, price) {
        def item = [ itemId:application.id,
            name:application.name,
            description:application.description,
            quantity:1,
            unitPrice:price ]
        return item;
    }


    /* XML builders below */

    def createCustomerProfileRequest(id, username, email, ccNo, expDate, cvv2) {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.createCustomerProfileRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            profile {
                merchantCustomerId(id);
                description(username);
                email(email);
                paymentProfiles {
                    customerType("individual");
                    addPaymentProfile(ccNo, expDate, cvv2);
                }
            }
            validationMode(API_VALIDATION_MODE);
        }
        return postRequest(writer.toString());
    }

    def createCustomerProfileTransactionRequestForAuthorizationAndCapture(amount, item, profileId, paymentProfileId, cvv2) {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.createCustomerProfileTransactionRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            transaction {
                profileTransAuthCapture {
                    amount(amount);
                    //addTax(xml, amount, name, description);
                    //addShipping(xml, amount, name, description);
                    addLineItems(xml, item.itemId, item.name, item.description, item.quantity, item.unitPrice, false);
                    customerProfileId(profileId);
                    customerPaymentProfileId(profileId);
                    //customerShippingAddressId("30000");
                    //addOrder(xml, invoiceNumber, description, purchaseOrderNumber);
                    taxExempt(false);
                    recurringBilling(false);
                    cardCode(cvv2);
                }
            }
            //extraOptions("<![CDATA[x_customer_ip=100.0.0.1]]>");
        }
        return postRequest(writer.toString());
    }

    def createCustomerProfileTransactionRequestForRefund(amount, item, profileId, paymentProfileId, transactionId) {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.createCustomerProfileTransactionRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            transaction {
                profileTransRefund {
                    amount(amount);
                    //addTax(xml, amount, name, description);
                    //addShipping(xml, amount, name, description);
                    addLineItems(xml, item.itemId, item.name, item.description, item.quantity, item.unitPrice);
                    customerProfileId(profileId);
                    customerPaymentProfileId(paymentProfileId);
                    //customerShippingAddressId("30000");
                    //addOrder(xml, invoiceNumber, description, purchaseOrderNumber);
                    transId(transactionId)
                }
            }
        }
        return postRequest(writer.toString());
    }

    def createCustomerPaymentProfileRequest(customerProfileId, ccNo, expDate, cvv2) {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.createCustomerPaymentProfileRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            customerProfileId(customerProfileId);
            paymentProfile {
                addPaymentProfile(ccNo, expDate, cvv2);
            }
        }
        return postRequest(writer.toString());
    }

    def deleteCustomerProfileRequest(customerProfileId) {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.deleteCustomerProfileRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            customerProfileId(customerProfileId);
        }
        return postRequest(writer.toString());
    }

    def deleteCustomerPaymentProfileRequest(customerProfileId, customerPaymentProfileId) {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.deleteCustomerPaymentProfileRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            customerProfileId(customerProfileId);
            customerPaymentProfileId(customerPaymentProfileId);
        }
        return postRequest(writer.toString());
    }

    def addAuthentication(xml) {
        xml.merchantAuthentication {
            name(API_AUTH_NAME);
            transactionKey(API_AUTH_TRANSACTION_KEY);
        }
    }

    def addPaymentProfile(ccNo, expDate, cvv2) {
        xml.payment {
            creditCard {
                cardNumber(ccNo);
                expirationDate(expDate);
                cardCode(cvv2);
            }
        }
    }

    def addTax(xml, amount, name, description) {
        xml.tax {
            amount(amount);
            name(name);
            description(description);
        }
    }

    def addShipping(xml, amount, name, description) {
        xml.shipping {
            amount(amount);
            name(name);
            description(description);
        }
    }
     
    def addLineItems(xml, itemId, name, description, quantity, unitPrice, taxable) {
        xml.lineItems {
            itemId(itemId);
            name(name);
            description(description);
            quantity(quantity);
            unitPrice(unitPrice);
            taxable(taxable);
        }
    }

    def addOrder(xml, invoiceNumber, description, purchaseOrderNumber) {
        xml.order {
            invoiceNumber(invoiceNumber);
            description(description);
            purchaseOrderNumber(purchaseOrderNumber);
        }
    }

    def postRequest(xml) {
        URL url = new URL(API_URL);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setDoOutput(true);
        conn.setDoInput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "text/xml; charset=utf-8");
        conn.setAllowUserInteraction(false);
        OutputStreamWriter sw = new OutputStreamWriter(conn.getOutputStream(), "UTF8");
        sw.write(xml);
        sw.flush();
        sw.close();
        InputStream resultStream = conn.getInputStream();
        def result = new XmlSlurper().parse(resultStream);
        resultStream.close();
        return result;
    }
}
