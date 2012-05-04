
#ifndef __PERLINNOISE_H
#define __PERLINNOISE_H

#ifdef __cplusplus
extern "C" {
#endif

/* C API for OEM Noise plug-in */
void	init_noise();
double	pnoise( double, double, double );

#ifdef __cplusplus
}
#endif

#endif
