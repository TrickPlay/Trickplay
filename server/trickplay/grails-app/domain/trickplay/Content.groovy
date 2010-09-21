package trickplay;

class Content {

    static constraints = {
        name(blank:false, maxSize:255, unique:true);
        description(blank:false, maxSize:4096);
        contentUrl(blank:true, url:true);
        vendorUniqueId(blank:false, maxSize:255);
        purchaseType(blank:false, inList:["consumable", "subscription"]);
        approved();
    }

    String name, description;
    URL contentUrl;
    String vendorUniqueId;
    String purchaseType = "consumable";
    Boolean approved = false;

    static hasMany = [prices:Price];
    static belongsTo = [vendor:Vendor];
    //static hasMany = [medias:Media, prices:Price];
    //static belongsTo = [application:Application];


}
