package com.trickplay.gameservice.domain;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Transient;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author bhaskar
 *
 */
@Entity
@XmlRootElement
public class Event extends BaseEntity implements Serializable {
    /**
     * 
     */
    private static final long serialVersionUID = 1L;

	public enum EventType { 
		BUDDY_LIST_INVITATION(BuddyListInvitation.class),
		GAME_PLAY_INVITATION(GamePlayInvitation.class),
		GAME_SESSION_MESSAGE(ChatMessage.class),
		GAME_SESSION_STATE_CHANGE(GamePlayState.class),
		GAME_SESSION_START(GamePlayState.class),
		GAME_SESSION_END(GamePlayState.class),
		GAME_SESSION_EXPIRED(GamePlayState.class),
		ACHIEVEMENT_EVENT(RecordedAchievement.class),
		HIGH_SCORE_EVENT(RecordedScore.class);
		
		private Class<? extends BaseEntity> clazz;
		public Class<? extends BaseEntity> getEventDetailClass() {
			return clazz;
		}
		private EventType(Class<? extends BaseEntity> clazz) {
			this.clazz = clazz;
		}
	}

//    private Long id;
    private EventType eventType;
    private User source;
    private Long recipientId;
    private String subject;
    private BaseEntity eventDetail;
    private Long eventDetailId;

	public Event() {
        super();
    }
    
    public Event(EventType etype, User source, Long recipient, String subject, BaseEntity eventDetailObj) {
        super();
        this.eventType = etype;
        this.source = source;
        this.eventDetail = eventDetailObj;
        this.subject = subject;
        this.recipientId = recipient;
        if (!etype.getEventDetailClass().isAssignableFrom(eventDetailObj.getClass())) {
        	throw new IllegalArgumentException("EventType."+etype.name()
        			+"requires target object to be an instanceof "+etype.getEventDetailClass().getSimpleName()
        			+". Passed eventDetailObject is of type "+eventDetailObj.getClass().getSimpleName()
        			);
        }
    }
    
    @Column(name="recipient_id")
    public Long getRecipientId() {
		return recipientId;
	}

	public void setRecipientId(Long recipient) {
		this.recipientId = recipient;
	}

	public String getSubject() {
		return subject;
	}

	public void setSubject(String subject) {
		this.subject = subject;
	}

	@Enumerated(EnumType.STRING)
    public EventType getEventType() {
		return eventType;
	}

	public void setEventType(EventType eventType) {
		this.eventType = eventType;
	}

	@ManyToOne(fetch=FetchType.LAZY)
	@JoinColumn(name="source_id", updatable=false, nullable=false)
	public User getSource() {
		return source;
	}

	public void setSource(User source) {
		this.source = source;
	}

	@Column(name="event_detail_id", nullable=false, updatable=false)
    public Long getEventDetailId() {
    	return eventDetail!=null ? eventDetail.getId() : eventDetailId;
    }
    
    public void setEventDetailId(Long eventDetailId) {
       this.eventDetailId = eventDetailId;
    }

//    public void setId(Long id) {
//        this.id = id;
//    }
//
//    public Long getId() {
//        return id;
//    }
    
    @Transient
    public BaseEntity getEventDetail() {
    	return eventDetail;
    }
    
    public void setEventDetail(BaseEntity e) {
    	eventDetail = e;
    }
    
    
}
