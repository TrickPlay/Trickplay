package com.trickplay.gameservice.domain;

import java.io.Serializable;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

import org.hibernate.validator.constraints.NotBlank;

@Entity
@XmlRootElement(name = "vendor")
public class Vendor extends BaseEntity implements Serializable {
    private static final long serialVersionUID = 1L;

//    private Long id;
    
    @NotBlank(message = "Name is a required field")
    private String name;
    
    private List<Game> games;
    
    @NotNull(message = "Primary Contact is a required field")
    private User primaryContact;
    

    public Vendor() {

    }

    public Vendor(String name, User primaryContact, List<Game> games) {
        this.setName(name);
        this.primaryContact = primaryContact;
        this.setGames(games);
    }

//    @Id
//    @GeneratedValue
//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }    

    @OneToOne
    @JoinColumn(name="primary_contact_id", nullable=false)
    public User getPrimaryContact() {
        return primaryContact;
    }

    public void setPrimaryContact(User user) {
        this.primaryContact = user;
    }

    @Column(nullable=false, unique=true)
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return "Vendor [id=" + getId() + ", name=" + name + ", games="
                + games + ", primaryContact=" + primaryContact + "]";
    }

    @OneToMany(mappedBy="vendor", cascade={CascadeType.ALL}, fetch=FetchType.LAZY)
    public List<Game> getGames() {
        return games;
    }

    public void setGames(List<Game> games) {
        this.games = games;
    }

}
