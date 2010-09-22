package trickplay

class SessionKey {

    static constraints = {
        user();
        device();
        token(unique:true);
        expires(nullable:true);
        dateCreated(blank:true, display:false);
    };

    User user;
    Device device;
    String token;
    Date dateCreated, expires;

    boolean expired() {
        return (expires != null && expires.time < new Date().time);
    }
}
