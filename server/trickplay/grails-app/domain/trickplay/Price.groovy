package trickplay;

class Price {

    static constraints = {
        amount();
        dateCreated(blank:true, display:false);
        lastUpdated(blank:true, display:false);
    };

    BigDecimal amount;
    //String market;
    Date dateCreated, lastUpdated;

}
