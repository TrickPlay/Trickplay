package trickplay

class Category {

    static constraints = {
        name(blank:false, unique:true, maxSize:255)
        restricted();
    }

    String name
    Boolean restricted = false;
}
