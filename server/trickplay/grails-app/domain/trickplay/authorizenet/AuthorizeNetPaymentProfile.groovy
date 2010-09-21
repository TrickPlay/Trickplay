package trickplay.authorizenet;

import trickplay.PaymentProfile;

class AuthorizeNetPaymentProfile extends PaymentProfile {

    static constraints = {
        customerProfile();
        customerPaymentProfileId();
    };

    AuthorizeNetProfile customerProfile;
    String customerPaymentProfileId;

}
