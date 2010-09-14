package trickplay

class Review {

    static constraints = {
        user();
        application();
        stars(min:0.0, max:5.0);
        comment(blank:true, maxSize:1024);
        dateCreated(blank:true, display:false);
    }

    User user;
    Application application;
    BigDecimal stars;
    String comment;
    Date dateCreated;
}
