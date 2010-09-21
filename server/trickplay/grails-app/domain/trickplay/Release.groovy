package trickplay;

import com.lucastex.grails.fileuploader.UFile;

class Release {

    static constraints = {
        releaseFile(nullable:true);
        notes(blank:true);
        requirements(blank:true);
        releaseNumber();
        autoUpdate();
        approved();
        current();
        dateCreated(blank:true, display:false);
        lastUpdated(blank:true, display:false);
    }

    String notes, requirements;
    BigDecimal releaseNumber;
    Date dateCreated, lastUpdated;
    Boolean autoUpdate = false;
    Boolean approved = false;
    Boolean current = false;
    UFile releaseFile;

    static hasMany = [medias:Media];

}
