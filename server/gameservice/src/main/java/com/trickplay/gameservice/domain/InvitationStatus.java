package com.trickplay.gameservice.domain;

public enum InvitationStatus {
        ACCEPTED, PENDING, RESERVED, REJECTED, CANCELLED, EXPIRED;
        
        public String getName() {
        	return name();
        }
}
