#include "nineslice.h"

GType nineslice_effect_get_type(void);

#define TYPE_NINESLICE_EFFECT             (nineslice_effect_get_type())
#define NINESLICE_EFFECT(obj)             (G_TYPE_CHECK_INSTANCE_CAST((obj),  TYPE_NINESLICE_EFFECT, NineSliceEffect))
#define IS_NINESLICE_EFFECT(obj)          (G_TYPE_CHECK_INSTANCE_TYPE((obj),  TYPE_NINESLICE_EFFECT))
#define NINESLICE_EFFECT_CLASS(klass)     (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_EFFECT, NineSliceEffectClass))
#define IS_NINESLICE_EFFECT_CLASS(klass)  (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_EFFECT))
#define NINESLICE_EFFECT_GET_CLASS(obj)   (G_TYPE_INSTANCE_GET_CLASS((obj),   TYPE_NINESLICE_EFFECT, NineSliceEffectClass))
#define NINESLICE_EFFECT_GET_PRIVATE(obj) (G_TYPE_INSTANCE_GET_PRIVATE((obj), TYPE_NINESLICE_EFFECT, NineSliceEffectPrivate))

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

struct _NineSliceEffectPrivate {
  CoglHandle* material[9];
  gfloat border[4];
};

G_DEFINE_TYPE(NineSliceEffect, nineslice_effect, CLUTTER_TYPE_EFFECT);

static gboolean nineslice_effect_pre_paint(ClutterEffect *self) {
  gfloat w, h;
  ClutterActor *actor = clutter_actor_meta_get_actor(CLUTTER_ACTOR_META(self));
  clutter_actor_get_size(actor, &w, &h);
  NineSliceEffectPrivate *priv = NINESLICE_EFFECT(self)->priv;
  
  gfloat xs[] = {0.0, priv->border[0], w - priv->border[1], w};
  gfloat ys[] = {0.0, priv->border[2], h - priv->border[3], h};
  
  gint i, j;
  for (i = 0; i < 3; i++) {
    for (j = 0; j < 3; j ++) {
      if (priv->material[i*3 + j] != COGL_INVALID_HANDLE) {
        cogl_set_source(priv->material[i*3 + j]);
        cogl_rectangle(xs[j], ys[i], xs[j+1], ys[i+1]);
      }
    }
  }

  return FALSE;
}

static void nineslice_effect_dispose(GObject *gobject) {
  NineSliceEffectPrivate *priv = NINESLICE_EFFECT(gobject)->priv;
  
  gint i;
  for (i = 0; i < 9; i++) {
    if (priv->material[i] != COGL_INVALID_HANDLE) {
      cogl_handle_unref(priv->material[i]);
      priv->material[i] = COGL_INVALID_HANDLE;
    }
  }
  
  G_OBJECT_CLASS(nineslice_effect_parent_class)->dispose(gobject);
}

/*
static gboolean nineslice_effect_get_paint_volume(ClutterEffect *self, ClutterPaintVolume *volume) {
  gfloat w, h;
  NineSliceEffectPrivate *priv = NINESLICE_EFFECT(self)->priv;
  
  ClutterVertex origin;
  clutter_paint_volume_get_origin(volume, &origin);
  origin.x += -priv->border[0] - priv->padding->x1;
  origin.y += -priv->border[2] - priv->padding->y1;
  clutter_paint_volume_set_origin(volume, &origin);
  
  w = clutter_paint_volume_get_width( volume );
  h = clutter_paint_volume_get_height( volume );
  
  clutter_paint_volume_set_width (volume, w + priv->border[0] + priv->padding->x1
                                            + priv->border[1] + priv->padding->x2);
  clutter_paint_volume_set_height(volume, h + priv->border[2] + priv->padding->y1
                                            + priv->border[3] + priv->padding->y2);
  

  return TRUE;
}

enum {
  PROP_0,
  
  PROP_PADDING,
  
  N_PROPERTIES
};

static GParamSpec *obj_props[N_PROPERTIES];

static gboolean nineslice_padding_interval(const GValue *a, const GValue *b, gdouble progress, GValue *r) {
  ClutterActorBox *rbox = clutter_actor_box_new(0.0, 0.0, 0.0, 0.0);
  clutter_actor_box_interpolate(g_value_get_boxed(a), g_value_get_boxed(b), progress, rbox);
  g_value_set_boxed(r, rbox);
  
  return TRUE;
}

void nineslice_effect_set_padding(NineSliceEffect* effect, ClutterActorBox* value) {
  clutter_actor_box_free(effect->priv->padding);
  effect->priv->padding = value;
}

static void nineslice_effect_set_property(GObject *gobject, guint prop_id,
                                          const GValue *value, GParamSpec *pspec) {
  NineSliceEffect *effect = NINESLICE_EFFECT(gobject);
  
  switch (prop_id) {
    case PROP_PADDING:
      nineslice_effect_set_padding(effect, clutter_actor_box_copy(g_value_get_boxed(value)));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(gobject, prop_id, pspec);
      break;
  }
}

static void nineslice_effect_get_property(GObject *gobject, guint prop_id,
                                          GValue *value, GParamSpec *pspec) {
  NineSliceEffectPrivate *priv = NINESLICE_EFFECT(gobject)->priv;
  
  switch (prop_id) {
    case PROP_PADDING:
      g_value_set_boxed(value, clutter_actor_box_copy(priv->padding));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(gobject, prop_id, pspec);
      break;
  }
}
 */

static void nineslice_effect_class_init(NineSliceEffectClass *klass) {
  g_type_class_add_private(klass, sizeof(NineSliceEffectPrivate));
  
  ClutterEffectClass *cklass = CLUTTER_EFFECT_CLASS(klass);
  cklass->pre_paint = nineslice_effect_pre_paint;
  //cklass->get_paint_volume = nineslice_effect_get_paint_volume;
  
  GObjectClass *gklass = G_OBJECT_CLASS(klass);
  gklass->dispose = nineslice_effect_dispose;
  
  /*
  gklass->set_property = nineslice_effect_set_property;
  gklass->get_property = nineslice_effect_get_property;
  
  obj_props[PROP_PADDING] = g_param_spec_boxed("padding", "Padding",
            "Padding all around", CLUTTER_TYPE_ACTOR_BOX, G_PARAM_READWRITE);
  clutter_interval_register_progress_func(CLUTTER_TYPE_ACTOR_BOX, nineslice_padding_interval);
  
  g_object_class_install_properties(gklass, N_PROPERTIES, obj_props);
  */
}

static void nineslice_effect_init (NineSliceEffect *self) {
  NineSliceEffectPrivate *priv;
  priv = self->priv = NINESLICE_EFFECT_GET_PRIVATE(self);
  //priv->padding = clutter_actor_box_new(20.0, 20.0, 20.0, 20.0);
}

ClutterEffect* nineslice_effect_new_from_source(gchar* source[]) {
  ClutterEffect* self = g_object_new(TYPE_NINESLICE_EFFECT, NULL);
  NineSliceEffectPrivate *priv = NINESLICE_EFFECT(self)->priv;
  
  GError *error = NULL;
  ClutterActor *texture;
  gint i, w, h;
  for (i = 0; i < 9; i++) {
    texture = clutter_texture_new_from_file(source[i], &error);
    clutter_texture_get_base_size(CLUTTER_TEXTURE(texture), &w, &h);
    
    priv->material[i] = clutter_texture_get_cogl_material(CLUTTER_TEXTURE(texture));
    if ((gfloat) w > priv->border[0] && i % 3 == 0) priv->border[0] = (gfloat) w; else
    if ((gfloat) w > priv->border[1] && i % 3)      priv->border[1] = (gfloat) w;
    if ((gfloat) h > priv->border[2] && i < 3)      priv->border[2] = (gfloat) h; else
    if ((gfloat) h > priv->border[3] && i >= 6)     priv->border[3] = (gfloat) h;
  }
  
  return self;
}