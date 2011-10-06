package com.trickplay.gameservice.transferObj;

public final class BooleanResponse {

    private boolean value;
    public static final BooleanResponse TRUE = new BooleanResponse(true);
    public static final BooleanResponse FALSE = new BooleanResponse(false);
    private BooleanResponse(boolean value) {
        this.setValue(value);
    }

    public BooleanResponse() {       
    }
    public boolean isValue() {
        return value;
    }
    public void setValue(boolean value) {
        this.value = value;
    }
    
    public boolean equals(Object obj) {
        if (obj instanceof BooleanResponse) {
            BooleanResponse other = (BooleanResponse)obj;
            return value == other.isValue();
        }
        return false;
    }
    
}
