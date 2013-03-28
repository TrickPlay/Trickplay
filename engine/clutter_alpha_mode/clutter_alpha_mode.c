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

#include <math.h>
#include "clutter_alpha_mode.h"

#define G_PI    3.1415926535897932384626433832795028841971693993751
#define G_PI_2  1.5707963267948966192313216916397514420985846996876

double clutter_am_linear( double progress )
{
    return progress;
}

double clutter_am_ease_in_quad( double progress )
{
    return progress * progress;
}

double clutter_am_ease_out_quad( double progress )
{
    return -1.0 * progress * ( progress - 2 );
}

double clutter_am_ease_in_out_quad( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / ( d / 2 );

    if ( p < 1 )
    {
        return 0.5 * p * p;
    }

    p -= 1;

    return -0.5 * ( p * ( p - 2 ) - 1 );
}

double clutter_am_ease_in_cubic( double progress )
{
    return progress * progress * progress;
}

double clutter_am_ease_out_cubic( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / d - 1;

    return p * p * p + 1;
}

double clutter_am_ease_in_out_cubic( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / ( d / 2 );

    if ( p < 1 )
    {
        return 0.5 * p * p * p;
    }

    p -= 2;

    return 0.5 * ( p * p * p + 2 );
}

double clutter_am_ease_in_quart( double progress )
{
    return progress * progress * progress * progress;
}

double clutter_am_ease_out_quart( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / d - 1;

    return -1.0 * ( p * p * p * p - 1 );
}

double clutter_am_ease_in_out_quart( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / ( d / 2 );

    if ( p < 1 )
    {
        return 0.5 * p * p * p * p;
    }

    p -= 2;

    return -0.5 * ( p * p * p * p - 2 );
}

double clutter_am_ease_in_quint( double progress )
{
    return progress * progress * progress * progress * progress;
}

double clutter_am_ease_out_quint( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / d - 1;

    return p * p * p * p * p + 1;
}

double clutter_am_ease_in_out_quint( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / ( d / 2 );

    if ( p < 1 )
    {
        return 0.5 * p * p * p * p * p;
    }

    p -= 2;

    return 0.5 * ( p * p * p * p * p + 2 );
}

double clutter_am_ease_in_sine( double progress )
{
    double t = progress;
    double d = 1;

    return -1.0 * cos( t / d * G_PI_2 ) + 1.0;
}

double clutter_am_ease_out_sine( double progress )
{
    double t = progress;
    double d = 1;

    return sin( t / d * G_PI_2 );
}

double clutter_am_ease_in_out_sine( double progress )
{
    double t = progress;
    double d = 1;

    return -0.5 * ( cos( G_PI * t / d ) - 1 );
}

double clutter_am_ease_in_expo( double progress )
{
    double t = progress;
    double d = 1;

    return ( t == 0 ) ? 0.0 : pow( 2, 10 * ( t / d - 1 ) );
}

double clutter_am_ease_out_expo( double progress )
{
    double t = progress;
    double d = 1;

    return ( t == d ) ? 1.0 : -pow( 2, -10 * t / d ) + 1;
}

double clutter_am_ease_in_out_expo( double progress )
{
    double t = progress;
    double d = 1;
    double p;

    if ( t == 0 )
    {
        return 0.0;
    }

    if ( t == d )
    {
        return 1.0;
    }

    p = t / ( d / 2 );

    if ( p < 1 )
    {
        return 0.5 * pow( 2, 10 * ( p - 1 ) );
    }

    p -= 1;

    return 0.5 * ( -pow( 2, -10 * p ) + 2 );
}

double clutter_am_ease_in_circ( double progress )
{
    return -1.0 * ( sqrt( 1 - progress * progress ) - 1 );
}

double clutter_am_ease_out_circ( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / d - 1;

    return sqrt( 1 - p * p );
}

double clutter_am_ease_in_out_circ( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / ( d / 2 );

    if ( p < 1 )
    {
        return -0.5 * ( sqrt( 1 - p * p ) - 1 );
    }

    p -= 2;

    return 0.5 * ( sqrt( 1 - p * p ) + 1 );
}

double clutter_am_ease_in_elastic( double progress )
{
    double t = progress;
    double d = 1;
    double p = d * .3;
    double s = p / 4;
    double q = t / d;

    if ( q == 1 )
    {
        return 1.0;
    }

    q -= 1;

    return -( pow( 2, 10 * q ) * sin( ( q * d - s ) * ( 2 * G_PI ) / p ) );
}

double clutter_am_ease_out_elastic( double progress )
{
    double t = progress;
    double d = 1;
    double p = d * .3;
    double s = p / 4;
    double q = t / d;

    if ( q == 1 )
    {
        return 1.0;
    }

    return pow( 2, -10 * q ) * sin( ( q * d - s ) * ( 2 * G_PI ) / p ) + 1.0;
}

double clutter_am_ease_in_out_elastic( double progress )
{
    double t = progress;
    double d = 1;
    double p = d * ( .3 * 1.5 );
    double s = p / 4;
    double q = t / ( d / 2 );

    if ( q == 2 )
    {
        return 1.0;
    }

    if ( q < 1 )
    {
        q -= 1;

        return -.5 * ( pow( 2, 10 * q ) * sin( ( q * d - s ) * ( 2 * G_PI ) / p ) );
    }
    else
    {
        q -= 1;

        return pow( 2, -10 * q )
                * sin( ( q * d - s ) * ( 2 * G_PI ) / p )
                * .5 + 1.0;
    }
}

double clutter_am_ease_in_back( double progress )
{
    return progress * progress * ( ( 1.70158 + 1 ) * progress - 1.70158 );
}

double clutter_am_ease_out_back( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / d - 1;

    return p * p * ( ( 1.70158 + 1 ) * p + 1.70158 ) + 1;
}

double clutter_am_ease_in_out_back( double progress )
{
    double t = progress;
    double d = 1;
    double p = t / ( d / 2 );
    double s = 1.70158 * 1.525;

    if ( p < 1 )
    {
        return 0.5 * ( p * p * ( ( s + 1 ) * p - s ) );
    }

    p -= 2;

    return 0.5 * ( p * p * ( ( s + 1 ) * p + s ) + 2 );
}

static double ease_out_bounce_internal( double t, double d )
{
    double p = t / d;

    if ( p < ( 1 / 2.75 ) )
    {
        return 7.5625 * p * p;
    }
    else if ( p < ( 2 / 2.75 ) )
    {
        p -= ( 1.5 / 2.75 );

        return 7.5625 * p * p + .75;
    }
    else if ( p < ( 2.5 / 2.75 ) )
    {
        p -= ( 2.25 / 2.75 );

        return 7.5625 * p * p + .9375;
    }
    else
    {
        p -= ( 2.625 / 2.75 );

        return 7.5625 * p * p + .984375;
    }
}

static double ease_in_bounce_internal( double t, double d )
{
    return 1.0 - ease_out_bounce_internal( d - t, d );
}

double clutter_am_ease_in_bounce( double progress )
{
    return ease_in_bounce_internal( progress, 1 );
}

double clutter_am_ease_out_bounce( double progress )
{
    return ease_out_bounce_internal( progress, 1 );
}

double clutter_am_ease_in_out_bounce( double progress )
{
    double t = progress;
    double d = 1;

    if ( t < d / 2 )
    {
        return ease_in_bounce_internal( t * 2, d ) * 0.5;
    }
    else
    {
        return ease_out_bounce_internal( t * 2 - d, d ) * 0.5 + 1.0 * 0.5;
    }
}
