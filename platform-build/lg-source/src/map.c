#include <stdlib.h>
#include <string.h>

#include "map.h"

#define MAP_CAPACITY		(UINT32)256


struct tagMapHandle {
	struct tagPair {
		void*	pKey;
		void*	pValue;
		BOOLEAN	bOccupied;
	} pairs[MAP_CAPACITY];

	UINT32	nCount;

	PFNALLOCFUNC_T		pfnKeyAllocFunc;
	PFNALLOCFUNC_T		pfnValueAllocFunc;
	PFNDEALLOCFUNC_T	pfnKeyDeallocFunc;
	PFNDEALLOCFUNC_T	pfnValueDeallocFunc;
	PFNCOMPAREFUNC_T	pfnCompareFunc;
};

static UINT32 _Map_FindIndex(HMAP hMap, const void* pKey)
{
	UINT32 idx;

	if ((hMap == NULL) || (hMap->pfnCompareFunc == NULL))
		return (UINT32)-1;

	for (idx = 0; idx < MAP_CAPACITY; ++idx)
	{
		if (!hMap->pairs[idx].bOccupied)
			continue;

		if (hMap->pfnCompareFunc(hMap->pairs[idx].pKey, pKey) == TRUE)
			return idx;
	}

	return (UINT32)-1;
}

static void _Map_RemoveFromIndex(HMAP hMap, UINT32 idx)
{
	if ((hMap == NULL) || (idx == (UINT32)-1) || (!hMap->pairs[idx].bOccupied))
		return;

	if (hMap->pfnKeyDeallocFunc)
		hMap->pfnKeyDeallocFunc(hMap->pairs[idx].pKey);
	hMap->pairs[idx].pKey = NULL;

	if (hMap->pfnValueDeallocFunc)
		hMap->pfnValueDeallocFunc(hMap->pairs[idx].pValue);
	hMap->pairs[idx].pValue = NULL;

	hMap->pairs[idx].bOccupied = FALSE;

	hMap->nCount -= 1;
}

HMAP API_Map_New(
		PFNALLOCFUNC_T pfnKeyAllocFunc, PFNALLOCFUNC_T pfnValueAllocFunc,
		PFNDEALLOCFUNC_T pfnKeyDeallocFunc, PFNDEALLOCFUNC_T pfnValueDeallocFunc,
		PFNCOMPAREFUNC_T pfnCompareFunc)
{
	HMAP hMap = NULL;

	if (pfnCompareFunc == NULL)
		goto done;

	hMap = (HMAP)malloc(sizeof(struct tagMapHandle));
	if (hMap == NULL)
		goto done;

	memset(hMap->pairs, 0, sizeof(hMap->pairs));

	hMap->nCount = 0;

	hMap->pfnKeyAllocFunc		= pfnKeyAllocFunc;
	hMap->pfnValueAllocFunc		= pfnValueAllocFunc;
	hMap->pfnKeyDeallocFunc		= pfnKeyDeallocFunc;
	hMap->pfnValueDeallocFunc	= pfnValueDeallocFunc;
	hMap->pfnCompareFunc		= pfnCompareFunc;

done:
	return hMap;
}

void API_Map_Destroy(HMAP hMap)
{
	API_Map_Clear(hMap);
	free(hMap);
}

UINT32 API_Map_GetSize(HMAP hMap)
{
	if (hMap == NULL)
		return (UINT32)-1;

	return hMap->nCount;
}

UINT32 API_Map_GetCapacity(HMAP hMap)
{
	if (hMap == NULL)
		return (UINT32)-1;

	return MAP_CAPACITY;
}

void API_Map_Insert(HMAP hMap, void* pKey, void* pValue)
{
	UINT32 idx;

	if (hMap == NULL)
		return;

	for (idx = 0; idx < MAP_CAPACITY; ++idx)
	{
		if (!hMap->pairs[idx].bOccupied)
		{
			hMap->pairs[idx].pKey	= (hMap->pfnKeyAllocFunc ? hMap->pfnKeyAllocFunc(pKey) : pKey);
			hMap->pairs[idx].pValue	= (hMap->pfnValueAllocFunc ? hMap->pfnValueAllocFunc(pValue) : pValue);
			hMap->pairs[idx].bOccupied = TRUE;

			hMap->nCount += 1;
			break;
		}
	}
}

void API_Map_Remove(HMAP hMap, const void* pKey)
{
	return _Map_RemoveFromIndex(hMap, _Map_FindIndex(hMap, pKey));
}

void* API_Map_Find(HMAP hMap, const void* pKey)
{
	UINT32 idx;

	if (hMap == NULL)
		return NULL;

	idx = _Map_FindIndex(hMap, pKey);
	if (idx == (UINT32)-1)
		return NULL;

	return hMap->pairs[idx].pValue;
}

void API_Map_Clear(HMAP hMap)
{
	UINT32 idx;

	if (hMap == NULL)
		return;

	for (idx = 0; idx < NELEMENTS(hMap->pairs); ++idx)
		_Map_RemoveFromIndex(hMap, idx);
}

