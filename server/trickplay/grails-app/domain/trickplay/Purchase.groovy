package trickplay;

class Purchase {

    static constraints = {
        user();
        application();
        paymentProfile();
        price();
        response();
        dateCreated(blank:true, display:false);
    };

    User user;
    Application application;
    PaymentProfile paymentProfile;
    BigDecimal price;
    String response;
    Date dateCreated;

}
