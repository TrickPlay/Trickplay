package com.trickplay.gameservice.transferObj;

import org.hibernate.validator.constraints.NotBlank;


public class VendorRequestTO {
	@NotBlank
	private String name;
    
    public VendorRequestTO() {
    	
    }
    
    public VendorRequestTO(String name) {
    	this.name = name;
    }
    
    
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
}
