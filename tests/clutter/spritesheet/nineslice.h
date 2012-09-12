/*

    nineslice.h

*/

#ifndef __TRICKPLAY_NINESLICE_H__
#define __TRICKPLAY_NINESLICE_H__

#include <clutter/clutter.h>
#include "spritesheet.h"

GType nineslice_effect_get_type(void);

#define TYPE_NINESLICE_EFFECT             (nineslice_effect_get_type())
#define NINESLICE_EFFECT(obj)             (G_TYPE_CHECK_INSTANCE_CAST((obj),  TYPE_NINESLICE_EFFECT, NineSliceEffect))
#define IS_NINESLICE_EFFECT(obj)          (G_TYPE_CHECK_INSTANCE_TYPE((obj),  TYPE_NINESLICE_EFFECT))
#define NINESLICE_EFFECT_CLASS(klass)     (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_EFFECT, NineSliceEffectClass))
#define IS_NINESLICE_EFFECT_CLASS(klass)  (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_EFFECT))
#define NINESLICE_EFFECT_GET_CLASS(obj)   (G_TYPE_INSTANCE_GET_CLASS((obj),   TYPE_NINESLICE_EFFECT, NineSliceEffectClass))

typedef struct _NineSliceEffect NineSliceEffect;
typedef struct _NineSliceEffectClass NineSliceEffectClass;
typedef struct _NineSliceEffectPrivate NineSliceEffectPrivate;

struct _NineSliceEffect {
  ClutterEffect parent_instance;
  NineSliceEffectPrivate *priv;
};

struct _NineSliceEffectClass {
  ClutterEffectClass parent_class;
};

ClutterEffect* nineslice_effect_new_from_names(gchar* names[], SpriteSheet *sheet, gboolean tiled);

#endif
