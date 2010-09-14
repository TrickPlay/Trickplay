package trickplay;

class Application {

    static constraints = {
        name(blank:false, maxSize:255, unique:true);
        description(blank:false, maxSize:4096);
        rating(nullable:true, inList:["4+", "9+", "12+", "17+", "No Rating"]);
        icon();
        websiteUrl(blank:true, url:true);
        supportEmail(email:true, maxSize:255);
        license(blank:true, maxSize:4096);
        developer(nullable:true);
        price(min:0.0, max:100.0);
        approved();
    };

    String name, description, supportEmail, license;
    String rating = "No Rating";
    Developer developer; //test
    URL websiteUrl;
    Media icon;
    BigDecimal price;
    Boolean approved = false;

    static hasMany = [categories:Category, versions:Version];
    //static hasMany = [medias:Media, categories:Category, versions:Version];
    //static hasMany = [medias:Media, categories:Category, releases:Release];
    //static belongsTo = [developer:Developer];

    def getMedias() {
        return getCurrentRelease().medias;
    }

    def getCurrentVersion() {
        Version v = null;
        versions.each() {
            if (it.current) {
                v = it;
            }
        }
        return v;
    }

    def getCurrentRelease() {
        Release r = null;
        Version v = getCurrentVersion();
        v.releases.each() {
            if (it.current) {
                r = it;
            }
        }
        return r;
    }
}
