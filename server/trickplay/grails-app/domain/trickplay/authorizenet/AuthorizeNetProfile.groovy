package trickplay.authorizenet;

import trickplay.User;

class AuthorizeNetProfile {

    static hasMany = [ profiles:AuthorizeNetPaymentProfile ];

    static constraints = {
        user();
        customerProfileId();
        enabled();
        dateCreated(blank:true, display:false);
    };

    User user;
    String customerProfileId;
    Boolean enabled = false;
    Date dateCreated;

}
