#ifndef __MAP_H__
#define __MAP_H__

#include <addon_types.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct tagMapHandle		*HMAP;

typedef void*	(*PFNALLOCFUNC_T)(const void* ptr);
typedef void	(*PFNDEALLOCFUNC_T)(void* ptr);
typedef BOOLEAN (*PFNCOMPAREFUNC_T)(const void* pKeyA, const void* pKeyB);
typedef void	(*PFNFOREACHFUNC_T)(void* pKey, void* pValue, void* pUserData);

/* Create and destroy map */
HMAP	API_Map_New(
		PFNALLOCFUNC_T pfnKeyAllocFunc, PFNALLOCFUNC_T pfnValueAllocFunc,
		PFNDEALLOCFUNC_T pfnKeyDeallocFunc, PFNDEALLOCFUNC_T pfnValueDeallocFunc,
		PFNCOMPAREFUNC_T pfnCompareFunc);
void	API_Map_Destroy(HMAP hMap);

/* Get status of map */
UINT32	API_Map_GetSize(HMAP hMap);
UINT32	API_Map_GetCapacity(HMAP hMap);

/* Control map */
void	API_Map_Insert(HMAP hMap, void* pKey, void* pValue);
void	API_Map_Remove(HMAP hMap, const void* pKey);
void*	API_Map_Find(HMAP hMap, const void* pKey);
void	API_Map_Clear(HMAP hMap);

#ifdef __cplusplus
}
#endif

#endif /* __MAP_H__ */

