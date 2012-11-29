/*
 *  math.h
 *  Livu
 *
 *  Created by Steve on 2/7/11.
 *  Copyright 2011 Steve McFarlin. All rights reserved.
 *
 */

enum AVRounding {
    AV_ROUND_ZERO     = 0, ///< Round toward zero.
    AV_ROUND_INF      = 1, ///< Round away from zero.
    AV_ROUND_DOWN     = 2, ///< Round toward -infinity.
    AV_ROUND_UP       = 3, ///< Round toward +infinity.
    AV_ROUND_NEAR_INF = 5, ///< Round to nearest and halfway cases away from zero.
};

static const int kAVBaseTime		= 1000000000;
static const int kRTPAVCBaseTime	= 90000;


double round(double r) ; 
int64_t rescale_rnd(int64_t a, int64_t b, int64_t c, enum AVRounding rnd);
int64_t rescale(int64_t a, int32_t org_den, int32_t new_den);
void hex_print(const uint8_t *bytes, int length);
