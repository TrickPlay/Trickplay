package trickplay

class PaymentProfile {

    static constraints = {
        user();
        canonicalName();
        canonicalIdentifier();
        enabled();
        dateCreated(blank:true, display:false);
    };

    static mapping = {
        tablePerHierarchy false
    };

    User user;
    String canonicalName; //e.g. "Citibank Visa"
    String canonicalIdentifier; // last +4
    Boolean enabled = false;
    Date dateCreated;
}
