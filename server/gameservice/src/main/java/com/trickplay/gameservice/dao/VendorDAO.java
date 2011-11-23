package com.trickplay.gameservice.dao;


import java.util.List;

import com.trickplay.gameservice.domain.Vendor;

public interface VendorDAO extends GenericDAO<Vendor, Long> {

  public Vendor findByName(String name);

  public List<Vendor> findByContactName(String contactName);
}
