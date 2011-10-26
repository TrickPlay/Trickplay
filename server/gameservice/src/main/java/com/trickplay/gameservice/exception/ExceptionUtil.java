package com.trickplay.gameservice.exception;

import java.util.HashMap;
import java.util.Map;

import javax.validation.ConstraintViolationException;
import javax.validation.ValidationException;

import com.trickplay.gameservice.domain.InvitationStatus;
import com.trickplay.gameservice.exception.GameServiceException.Reason;

public class ExceptionUtil {

    private static Map<String, Object> convertToMap(Object[] args) {
        Map<String, Object> retval = new HashMap<String, Object>();
        if (args == null)
            return retval;
        int i = 0;
        while (i < args.length) {
            if (i + 1 < args.length) {
                retval.put(args[i].toString(), args[i + 1]);
            } else {
                retval.put(args[i].toString(), null);
            }
            i += 2;
        }
        return retval;
    }

    /*
     * entityNotFound=Failed to find an entity of type '{0}' using criteria
     * '{1}'
     */
    public static GameServiceException newEntityNotFoundException(Class<?> entityClass,
            Object... args) {
        return new GameServiceException(Reason.ENTITY_NOT_FOUND,
                entityClass.getSimpleName(), convertToMap(args));
    }

    /*
     * entityNotFound=Failed to find an entity of type '{0}' using criteria
     * '{1}'
     */
    public static GameServiceException newEntityExistsException(Class<?> entityClass,
            Object... args) {
        return new GameServiceException(Reason.ENTITY_EXISTS_EXCEPTION,
                entityClass.getSimpleName(), convertToMap(args));
    }

    /*
     * recipientSameAsRequestor=Invalid request. The recipient and requestor
     * cannot be same. Requestor='{0}', Recipient='{1}'
     */
    public static GameServiceException newRequestorAndRecipientMatchException(
            Long requestorId, Long recipientId) {
        return new GameServiceException(Reason.GP_RECIPIENT_SAME_AS_REQUESTOR,
                requestorId, recipientId);
    }

    /*
     * alreadyBuddy=User '{0}' is already in your buddy list.
     */
    public static GameServiceException newAlreadyBuddyException(String userName) {
        return new GameServiceException(Reason.ALREADY_BUDDY, userName);
    }
    
    /*
     * invitationPreviouslySent=An invitation was already sent to user '{0}'
     */
    public static GameServiceException newInvitationPreviouslySentException(Long userId) {
        return new GameServiceException(Reason.INVITATION_PREVIOUSLY_SENT, userId);
    }
    
    /*
     * cancelBuddyListInvitationFailed=Failed to cancel BuddyList invitation '{0}'. \
Can only cancel invitation when its status is 'PENDING', but invitation's status is '{1}'
acceptBuddyListInvitationFailed=Failed to accept BuddyList invitation '{0}'. \
Can only accept invitation when its status is 'PENDING', but invitation's status is '{1}'
rejectBuddyListInvitationFailed=Failed to decline BuddyList invitation '{0}'. \
Can only reject invitation when its status is 'PENDING', but invitation's status is '{1}'
     */
    public static GameServiceException newUpdateBLInvitationStatusFailedException(Long invitationId, InvitationStatus toStatus, InvitationStatus currentStatus) {
        switch (toStatus) {
        case ACCEPTED:
            return new GameServiceException(Reason.BL_INVITATION_ACCEPT_FAILED, invitationId, currentStatus.name());
        case REJECTED:
            return new GameServiceException(Reason.BL_INVITATION_REJECT_FAILED, invitationId, currentStatus.name());
        case CANCELLED:
            return new GameServiceException(Reason.BL_INVITATION_CANCEL_FAILED, invitationId, currentStatus.name());
        }
        return new GameServiceException(Reason.BL_INVITATION_STATUS_UPDATE_FAILED, invitationId, toStatus.name(), currentStatus.name());
    }
    
    /*
     * gameplayinvitationInvalidStatus=Failed to perform requested operation on
     * invitation '{0}'. Operation only allowed when invitation's status is
     * '{0}', but invitation's status is '{1}' 
     */
    public static GameServiceException newGPInvitationInvalidStatusException(Long invitationId, InvitationStatus requiredStatus, InvitationStatus currentStatus) {
        return new GameServiceException(Reason.GP_INVITATION_INVALID_STATUS, invitationId, requiredStatus.name(), currentStatus.name());
    }
    
    
    /*
     * gameAlreadyStarted=Operation failed. Game Session '{0}' of game '{1}' was started previously.
     */
    public static GameServiceException newGameAlreadyStartedException(String gameName, Long gameSessionId) {
        return new GameServiceException(Reason.GAME_ALREADY_STARTED, gameSessionId, gameName);
    }
    
    /*
     * gameAlreadyEnded=Operation failed. Game Session '{0}' of game '{1}'  has already ended.
     */
    public static GameServiceException newGameAlreadyEndedException(String gameName, Long gameSessionId) {
        return new GameServiceException(Reason.GAME_ALREADY_ENDED, gameSessionId, gameName);
    }
    
    /*
     * gameAlreadyStarted=Operation failed. Game Session '{0}' of game '{1}' has not yet started.
     */
    public static GameServiceException newGameNotStartedException(String gameName, Long gameSessionId) {
        return new GameServiceException(Reason.GAME_NOT_STARTED, gameSessionId, gameName);
    }
    
    /*
     * sendInvitationFailed=Failed to send invitation. Error is '{0}'
     */
    public static GameServiceException newSendInvitationFailedException(String error) {
        return new GameServiceException(Reason.SEND_INVITATION_FAILED, error);
    }
    
    /*
     * sendInvitationFailed=Failed to send invitation. Error is '{0}'
     */
    public static GameServiceException newPairAlreadyInGamePlaySessionException(Long recipientId) {
        return new GameServiceException(Reason.PAIR_ALREADY_IN_GAME_PLAY_SESSION, recipientId);
    }
    /*
     * unauthorized=User doesn't have the necessary privileges to carry out this operation.
     */
    public static GameServiceException newUnauthorizedException() {
        return new GameServiceException(Reason.UNAUTHORIZED);
    }
    
    /*
     * failedToCreateSession=Failed to create session. Error is '{0}'
     */
    public static GameServiceException newFailedToCreateSessionException(Exception ex) {
        return new GameServiceException(ex, Reason.FAILED_TO_CREATE_SESSION, ex.getMessage());
    }

    /*
     * sessionExpired=Session '{0}' has already expired. Please login again.
     */
    public static GameServiceException newSessionExpiredException(String sessionToken) {
        return new GameServiceException(Reason.SESSION_EXPIRED, sessionToken);
    }
    
    /*
     * illegalArgument=Invalid parameter value passed.. Parameter '{0}' is assigned a value of '{1}'. Value should be '{2}'.
     */
    public static GameServiceException newIllegalArgumentException(String parameterName, Object currentValue, Object expectedValue) {
        return new GameServiceException(Reason.ILLEGAL_ARGUMENT, parameterName, currentValue, expectedValue);
    }
    

    /*
     * exceedsMaxPlayersAllowed=Operation failed. Game session for game '{0}' supports a maximum of '{1}' players. Maximum player limit reached.
     */
    public static GameServiceException newExceedsMaxPlayersLimitException(String game, int maxPlayers) {
        return new GameServiceException(Reason.GP_VIOLATES_MAX_PLAYERS_LIMIT, game, maxPlayers);
    }

    /*
     * unsupportedOperationException=The requested operation '{0}' is not
     * supported at this time. 
     */
    public static GameServiceException newUnsupportedOperationException(String operation) {
        return new GameServiceException(Reason.UNSUPPORTED_OPERATION_EXCEPTION, operation);
    }

    /*
     * wildcardInvitationNotAllowed=Game '{0}' does not support Wildcard Invitations.
     */
    public static GameServiceException newWildcardInvitationNotAllowedException(String gameName) {
        return new GameServiceException(Reason.WILDCARD_INVITATION_NOT_ALLOWED, gameName);
    }
    
    /*
     * invitationReserved=Invitation '{0}' reserved by a different user. 
     */
    public static GameServiceException newInvitationReservedException(Long invitationId) {
        return new GameServiceException(Reason.INVITATION_RESERVED, invitationId);
    }
    
    
    /*
     * notInvitationRecipient=Attempt to update invitation '{0}' sent to someone else. 
     */
    public static GameServiceException newNotInvitationRecipientException(Long invitationId) {
        return new GameServiceException(Reason.NOT_INVITATION_RECIPIENT, invitationId);
    }
    
    /*
     * invitationToSelf=Cannot send invitation to self.
     */
    public static GameServiceException newInvitationToSelfException() {
        return new GameServiceException(Reason.INVITATION_TO_SELF);
    }
    /*
     * unknown=Unknown error. Error info '{0}'
     */
    public static GameServiceException newUnknownException(String error) {
        return new GameServiceException(Reason.UNKNOWN, error);
    }
    
    public static RuntimeException convertToSupportedException(Exception e) {
        if (e instanceof GameServiceException)
            return (GameServiceException)e;
        else if (e instanceof ConstraintViolationException)
            return new GameServiceException(e, Reason.CONSTRAINT_VIOLATION);
        else if (e instanceof IllegalArgumentException)
            return (IllegalArgumentException)e;
        return new GameServiceException(e, Reason.UNKNOWN, e.getMessage());
    }
    
}
