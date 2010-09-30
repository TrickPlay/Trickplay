package trickplay;

import groovy.xml.MarkupBuilder

/**
 * test acct creds trickplay123:1Atg301Z
 * test acct keys 23Jt8cX86:2bES488Y9Ycz2pDp
 */
class AuthorizeNetRequest {

    static final String API_URL = "https://apitest.authorize.net/xml/v1/request.api";

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
            validationMode("testMode");
        }
        return writer.toString();
    }

    def createCustomerProfileTransactionRequestForAuthorizationAndCapture() {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.createCustomerProfileTransactionRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            transaction {
                profileTransAuthCapture {
                    amount("10.95");
                    addTax(xml, amount, name, description);
                    addShipping(xml, amount, name, description);
                    addLineItems(xml, itemId, name, description, quantity, unitPrice, taxable);
                    customerProfileId("10000");
                    customerPaymentProfileId("20000");
                    customerShippingAddressId("30000");
                    addOrder(xml, invoiceNumber, description, purchaseOrderNumber);
                    taxExempt(false);
                    recurringBilling(false);
                    cardCode("000");
                }
            }
            extraOptions("<![CDATA[x_customer_ip=100.0.0.1]]>");
        }
        return writer.toString();
    }

    def createCustomerProfileTransactionRequestForRefund() {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.createCustomerProfileTransactionRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            transaction {
                profileTransRefund {
                    amount("10.95");
                    addTax(xml, amount, name, description);
                    addShipping(xml, amount, name, description);
                    addLineItems(xml, itemId, name, description, quantity, unitPrice, taxable);
                    customerProfileId("10000");
                    customerPaymentProfileId("20000");
                    customerShippingAddressId("30000");
                    addOrder(xml, invoiceNumber, description, purchaseOrderNumber);
                    transId("40000")
                }
            }
        }
        return writer.toString();
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
        return writer.toString();
    }

    def deleteCustomerProfileRequest(customerProfileId) {
        def writer = new StringWriter();
        xml = new MarkupBuilder(writer);
        xml.doubleQuotes = true;
        xml.deleteCustomerProfileRequest(xmlns:"AnetApi/xml/v1/schema/AnetApiSchema.xsd") {
            addAuthentication(xml);
            customerProfileId(customerProfileId);
        }
        return writer.toString();
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
        return writer.toString();
    }

    def addAuthentication(xml) {
        xml.merchantAuthentication {
            name("23Jt8cX86");
            transactionKey("2bES488Y9Ycz2pDp");
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
