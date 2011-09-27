package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import javax.xml.bind.annotation.XmlRootElement;

import org.hibernate.validator.constraints.NotBlank;

@Entity
@XmlRootElement(name="game")
public class Game extends BaseEntity implements Serializable {
    
    private static final long serialVersionUID = 1L;

//    private Long id;
    @NotBlank
    private String name;
    @NotBlank
    private String appId;
    @Max(100)
    @Min(1)
    private int minPlayers;
    @Max(100)
    @Min(1)
    private int maxPlayers;
    private boolean leaderboardFlag;
    private boolean achievementsFlag;
    @NotNull
    private Vendor vendor;

    public Game() {        
    }

    public Game(Vendor vendor, String name, String appId, int minPlayers, int maxPlayers, boolean leaderboardFlag, boolean achievementsFlag) {
      this.vendor = vendor;
      this.setName(name);
      this.appId = appId;
      this.setMinPlayers(minPlayers);
      this.maxPlayers = maxPlayers;
      this.leaderboardFlag = leaderboardFlag;
      this.achievementsFlag = achievementsFlag;
    }

//    @Id
//    @GeneratedValue
//    public Long getId() {
//      return id;
//    }
//
//    public void setId(Long id) {
//      this.id = id;
//    }
    
    @Column(unique=true)
    public String getAppId() {
        return appId;
    }
    
    public void setAppId(String appId) {
        this.appId = appId;
    }
    
    public boolean isLeaderboardFlag() {
        return leaderboardFlag;
    }

    public void setLeaderboardFlag(boolean leaderboardFlag) {
        this.leaderboardFlag = leaderboardFlag;
    }

    public boolean isAchievementsFlag() {
        return achievementsFlag;
    }

    public void setAchievementsFlag(boolean achievementsFlag) {
        this.achievementsFlag = achievementsFlag;
    }

    public void setMinPlayers(int minPlayers) {
		this.minPlayers = minPlayers;
	}

	public int getMinPlayers() {
		return minPlayers;
	}

	@Column(nullable=false)
    public int getMaxPlayers() {
        return maxPlayers;
    }
    
    public void setMaxPlayers(int maxPlayers) {
        this.maxPlayers = maxPlayers;
    }

    @ManyToOne
    @JoinColumn(name="vendor_id", nullable=false)
    public Vendor getVendor() {
        return vendor;
    }

    public void setVendor(Vendor vendor) {
        this.vendor = vendor;
    }

    @Column(unique=true)
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
    
    
}
