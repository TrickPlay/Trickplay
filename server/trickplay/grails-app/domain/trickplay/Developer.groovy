package trickplay

class Developer {
    static hasMany = [applications:Application];

    static constraints = {
        user();
        vendor();
        dateCreated(blank:true, display:false);
        lastUpdated(blank:true, display:false);
        approved();
    };

    User user;
    Vendor vendor;
    Date dateCreated, lastUpdated;
    Boolean approved = false;

    String toString() {
        return "${user.userRealName} [${user.email}]";
    }
}
