package org.frogx.service.api;

public class MUGProperty {

	private String name;
	private String value;
	private int version;
	
	public MUGProperty(String name, String value, int version) {
		super();
		this.name = name;
		this.value = value;
		this.version = version;
	}

	public MUGProperty() {
		
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public int getVersion() {
		return version;
	}

	public void setVersion(int version) {
		this.version = version;
	}
}
