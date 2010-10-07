package trickplay;

class Version {

    static constraints = {
        versionNumber();
        freeUpdate();
        current();
        dateCreated(blank:true, display:false);
        lastUpdated(blank:true, display:false);
    }

    BigDecimal versionNumber;
    Date dateCreated, lastUpdated;
    Boolean freeUpdate = false;
    Boolean current = false;

    static hasMany = [releases:Release, prices:Price];

}
