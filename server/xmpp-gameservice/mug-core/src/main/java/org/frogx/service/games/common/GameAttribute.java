package org.frogx.service.games.common;

public final class GameAttribute {
		private String name;
		private String defaultValue;
		
		public GameAttribute(String name, String defaultValue) {
			if (name == null || name.trim().isEmpty())
				throw new IllegalArgumentException("invalid attribute name:"+name);
			this.name = name.trim();
			this.defaultValue = defaultValue;
		}
		
		public String getName() {
			return name;
		}

		public String getDefaultValue() {
			return defaultValue;
		}

		@Override
		public boolean equals(Object other) {
			return this == other ||
			(other instanceof GameAttribute && ((GameAttribute)other).getName().equals(name));
		}
		
		@Override
		public int hashCode() {
			return name.hashCode();
		} 	
}
