package trickplay;

class Vendor {
    static hasMany = [developers:Developer];

    static constraints = {
        name(blank:false, maxSize:255);
        dateCreated(blank:true, display:false);
        lastUpdated(blank:true, display:false);
        approved();
    };

    String name;
    Boolean approved = false;
    Date dateCreated, lastUpdated;
}
