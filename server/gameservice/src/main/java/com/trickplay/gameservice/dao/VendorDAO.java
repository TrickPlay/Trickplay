package com.trickplay.gameservice.dao;


import com.trickplay.gameservice.domain.Vendor;

public interface VendorDAO extends GenericDAO<Vendor, Long> {

  public Vendor findByName(String name);

}
