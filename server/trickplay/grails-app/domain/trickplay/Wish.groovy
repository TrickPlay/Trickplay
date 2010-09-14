package trickplay

class Wish {

    static constraints = {
        user();
        application();
        dateCreated(blank:true, display:false);
    }

    User user;
    Application application;
    Date dateCreated;

}
