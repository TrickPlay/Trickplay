package trickplay;

import org.apache.commons.lang.builder.HashCodeBuilder;

class UserRole implements Serializable {

    User user;
    Role role;
    
    boolean equals(other) {
        if (!(other instanceof UserRole)) {
            return falsel
        }
        return other.user.id == user.id && other.role.id == role.id;
    }
    
    int hashCode() {
        return new HashCodeBuilder().append(user.id).append(role.id).toHashCode();
    }
    
    static UserRole create(User user, Role role, boolean flush = false) {
        new UserRole(user: user, role: role).save(flush: flush, insert: true);
    }
    
    static boolean remove(User user, Role role, boolean flush = false) {
        UserRole userRole = UserRole.findByUserAndRole(user, role);
        return userRole ? userRole.delete(flush: flush) : false;
    }
    
    static void removeAll(User user) {
        executeUpdate("DELETE FROM UserRole WHERE user=:user", [user: user]);
    }
    
    static mapping = {
        id composite: ['role', 'user'];
        version false;
        table 'role_people';
    }
}
