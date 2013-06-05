/*
 * Copyright (C) 2012 TrickPlay Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef _CLUTTER_ALPHA_MODE_H
#define _CLUTTER_ALPHA_MODE_H

#ifdef __cplusplus
extern "C" {
#endif

    double clutter_am_linear( double progress );
    double clutter_am_ease_in_quad( double progress );
    double clutter_am_ease_out_quad( double progress );
    double clutter_am_ease_in_out_quad( double progress );
    double clutter_am_ease_in_cubic( double progress );
    double clutter_am_ease_out_cubic( double progress );
    double clutter_am_ease_in_out_cubic( double progress );
    double clutter_am_ease_in_quart( double progress );
    double clutter_am_ease_out_quart( double progress );
    double clutter_am_ease_in_out_quart( double progress );
    double clutter_am_ease_in_quint( double progress );
    double clutter_am_ease_out_quint( double progress );
    double clutter_am_ease_in_out_quint( double progress );
    double clutter_am_ease_in_sine( double progress );
    double clutter_am_ease_out_sine( double progress );
    double clutter_am_ease_in_out_sine( double progress );
    double clutter_am_ease_in_expo( double progress );
    double clutter_am_ease_out_expo( double progress );
    double clutter_am_ease_in_out_expo( double progress );
    double clutter_am_ease_in_circ( double progress );
    double clutter_am_ease_out_circ( double progress );
    double clutter_am_ease_in_out_circ( double progress );
    double clutter_am_ease_in_elastic( double progress );
    double clutter_am_ease_out_elastic( double progress );
    double clutter_am_ease_in_out_elastic( double progress );
    double clutter_am_ease_in_back( double progress );
    double clutter_am_ease_out_back( double progress );
    double clutter_am_ease_in_out_back( double progress );
    double clutter_am_ease_in_bounce( double progress );
    double clutter_am_ease_out_bounce( double progress );
    double clutter_am_ease_in_out_bounce( double progress );

#ifdef __cplusplus
}
#endif

#endif /* _CLUTTER_ALPHA_MODE_H */
