package com.trickplay.gameservice.dao;

import java.io.Serializable;
import java.util.List;

/**
 *
 */
public interface GenericDAO<T, ID extends Serializable> {
    
    public T find(ID id);

    public void persist(T entity);

    public void merge(T entity);

    public void remove(T entity);

    public List<T> findAll();

    public List<T> findInRange(int firstResult, int maxResults);

}