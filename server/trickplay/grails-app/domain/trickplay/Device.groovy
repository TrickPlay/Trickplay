package trickplay

class Device {
    static constraints = {
        deviceKey(blank:false, maxSize:255, unique:true);
        deviceType(blank:false, maxSize:255);
        owner(nullable:true);
        provisioned();
    };
    String deviceKey, deviceType;
    User owner;
    Boolean provisioned = false;
}
