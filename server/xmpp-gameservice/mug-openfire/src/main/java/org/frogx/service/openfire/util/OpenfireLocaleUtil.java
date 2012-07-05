/**
 * Copyright (C) 2009 Guenther Niess. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package org.frogx.service.openfire.util;


import org.frogx.service.api.util.LocaleUtil;
import org.frogx.service.openfire.MUGPlugin;
import org.jivesoftware.util.LocaleUtils;

/**
 * A wrapper for the LocaleUtils from Openfire.
 * 
 * @author G&uuml;nther Nie&szlig;
 */
public class OpenfireLocaleUtil implements LocaleUtil {
	
	public String getLocalizedString(String key) {
		return LocaleUtils.getLocalizedString(key, MUGPlugin.pluginName);
	}
}
