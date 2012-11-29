package org.frogx.service.core;

import org.frogx.service.api.MultiUserGame.RoleConfig;

public class RoleConfigImpl implements RoleConfig {
		private String role;
		private boolean notAllowedToStart;
		private boolean firstRole;
		
		public RoleConfigImpl() {
			
		}
		public RoleConfigImpl(String role) {
			this(role, false, false);
		}
		
		public RoleConfigImpl(String role, boolean cannotStart, boolean firstRole) {
			this.role = role;
			this.notAllowedToStart = cannotStart;
			this.firstRole = firstRole;
		}

		public String getRole() {
			return role;
		}
		public void setRole(String role) {
			this.role = role;
		}
		public boolean isNotAllowedToStart() {
			return notAllowedToStart;
		}
		public void setNotAllowedToStart(boolean cannotStart) {
			this.notAllowedToStart = cannotStart;
		}
		public boolean isFirstRole() {
			return firstRole;
		}
		public void setFirstRole(boolean firstRole) {
			this.firstRole = firstRole;
		}
}
