package com.trickplay.gameservice.dao.impl;

import java.io.Serializable;
import java.lang.reflect.ParameterizedType;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.Example;
import org.hibernate.ejb.HibernateEntityManager;

import com.trickplay.gameservice.dao.GenericDAO;

/**
 * Implements the generic CRUD data access operations using Java Persistence APIs.
 * <p>
 * To write a DAO, subclass and parameterize this class with your entity.
 * Of course, assuming that you have a traditional 1:1 appraoch for
 * Entity:DAO design. This is actually an implementation that uses some
 * extensions for Java Persistence from Hibernate - you can see how the
 * packages for the extensions are not imported, but named inline.
 *
 * @author Christian Bauer
 */
public abstract class GenericEJB3DAO<T, ID extends Serializable> implements
        GenericDAO<T, ID> {
    //private Class<T> entityBeanType;

    private EntityManager em;

    public GenericEJB3DAO() {
    }

    // If this DAO is wired in as a Seam component, Seam injects the right persistence context
    // if a method on this DAO is called. If the caller is a conversational stateful component,
    // the persistence context will be scoped to the conversation, not to the method call.
    // You can call this method and set the EntityManager manually, in an integration test.
    @PersistenceContext
    public void setEntityManager(EntityManager em) {
        this.em = em;
    }

    protected EntityManager getEntityManager() {
        if (em == null)
            throw new IllegalStateException("EntityManager has not been set on DAO before usage");
        return em;
    }

    public abstract Class<T> getEntityBeanType();

    public T findById(ID id, boolean lock) {
        T entity;
        if (lock) {
            entity = getEntityManager().find(getEntityBeanType(), id);
            em.lock(entity, javax.persistence.LockModeType.WRITE);
        } else {
            entity = getEntityManager().find(getEntityBeanType(), id);
        }
        return entity;
    }

    @SuppressWarnings("unchecked")
    public List<T> findAll() {
        return getEntityManager().createQuery("from " + getEntityBeanType().getName() ).getResultList();
    }


    @SuppressWarnings("unchecked")
    public List<T> findByExample(T exampleInstance, String... excludeProperty) {
        // Using Hibernate, more difficult with EntityManager and EJB-QL
        Criteria crit = ((HibernateEntityManager)getEntityManager())
                            .getSession()
                            .createCriteria(getEntityBeanType());
        Example example =
                Example.create(exampleInstance);
        for (String exclude : excludeProperty) {
            example.excludeProperty(exclude);
        }
        crit.add(example);
        return crit.list();
    }

    public T makePersistent(T entity) {
        return getEntityManager().merge(entity);
    }

    public void makeTransient(T entity) {
        getEntityManager().remove(entity);
    }

    public void flush() {
        getEntityManager().flush();
    }

    public void clear() {
        getEntityManager().clear();
    }

    /**
     * Use this inside subclasses as a convenience method.
     */
    @SuppressWarnings("unchecked")
    protected List<T> findByCriteria(org.hibernate.criterion.Criterion... criterion) {
        // Using Hibernate, more difficult with EntityManager and EJB-QL
        Session session = getSession();
        Criteria crit
                = session.createCriteria(getEntityBeanType());
        for (Criterion c : criterion) {
            crit.add(c);
        }
        return crit.list();
   }
    
    protected Session getSession() {
        return ((HibernateEntityManager)getEntityManager()).getSession();
    }

}
