/*
 *  math.c
 *  Livu
 *
 *  Created by Steve on 2/7/11.
 *  Copyright 2011 Steve McFarlin. All rights reserved.
 *
 */

#include "sm_math.h"
#include "math.h"

double round(double r) {
    return (r > 0.0) ? floor(r + 0.5) : ceil(r - 0.5);
}

/* derived from FFmpeg code */

inline int64_t rescale_rnd(int64_t a, int64_t b, int64_t c, enum AVRounding rnd){
	int64_t r=0;
    assert(c > 0);
    assert(b >=0);
    assert((unsigned)rnd<=5 && rnd!=4);
	
    if(a<0 && a != INT64_MIN) return -rescale_rnd(-a, b, c, rnd ^ ((rnd>>1)&1));
	
    if(rnd==AV_ROUND_NEAR_INF) r= c/2;
    else if(rnd&1)             r= c-1;
	
    //if(b<=INT_MAX && c<=INT_MAX){
	if(a<=INT_MAX)
		return (a * b + r)/c;
	else
		return a/c*b + (a%c*b + r)/c;
}

inline int64_t rescale(int64_t a, int32_t org_den, int32_t new_den) {
    int64_t b= 1 * (int64_t)new_den;
    int64_t c= 1 * (int64_t)org_den;
	return rescale_rnd(a,b,c,AV_ROUND_NEAR_INF);
}

void hex_print(const uint8_t *bytes, int length) {
    int i;
    for (i = 0; i < length; i++) {
        if (i > 0) printf(":");
        fprintf(stderr, "%02X", *(bytes+i));
    }
    
    printf("\n");
}