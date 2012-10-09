#include <math.h>
#include "nineslice.h"

G_DEFINE_TYPE(NineSliceEffect, nineslice_effect, CLUTTER_TYPE_EFFECT);

#define NINESLICE_EFFECT_GET_PRIVATE(obj) (G_TYPE_INSTANCE_GET_PRIVATE((obj), TYPE_NINESLICE_EFFECT, NineSliceEffectPrivate))

struct _NineSliceEffectPrivate {
  CoglMaterial* material[9];
  gint w[9];
  gint h[9];
  gboolean tiled;
};

enum {
  PROP_0,
  
  //PROP_PADDING,
  
  N_PROPERTIES
};

//static GParamSpec *obj_props[N_PROPERTIES];

static gboolean nineslice_effect_pre_paint(ClutterEffect *self) {
  gfloat w, h;
  ClutterActor *actor = clutter_actor_meta_get_actor(CLUTTER_ACTOR_META(self));
  clutter_actor_get_size(actor, &w, &h);
  NineSliceEffectPrivate *priv = NINESLICE_EFFECT(self)->priv;
  
  gfloat xs[] = {0.0, (gfloat) MAX(MAX(priv->w[0], priv->w[1]), priv->w[2]),
                  w - (gfloat) MAX(MAX(priv->w[6], priv->w[7]), priv->w[8]), w};
  gfloat ys[] = {0.0, (gfloat) MAX(MAX(priv->h[0], priv->h[3]), priv->h[6]),
                  h - (gfloat) MAX(MAX(priv->h[2], priv->h[5]), priv->h[8]), h};
  
  gint i, j;
  for (i = 0; i < 3; i++) {
    for (j = 0; j < 3; j++) {
      if (priv->material[i*3 + j] != COGL_INVALID_HANDLE) {
        cogl_set_source(priv->material[i*3 + j]);
        if (priv->tiled)
          cogl_rectangle_with_texture_coords(xs[j], ys[i], xs[j+1], ys[i+1], 0.0, 0.0,
              j == 1 ? (xs[j+1] - xs[j]) / (gfloat) priv->w[i*3 + j] : 1.0,
              i == 1 ? (ys[i+1] - ys[i]) / (gfloat) priv->h[i*3 + j] : 1.0);
        else
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
}

ClutterEffect* nineslice_effect_new_from_names(gchar* names[], SpriteSheet *sheet, gboolean tiled) {
  ClutterEffect* self = g_object_new(TYPE_NINESLICE_EFFECT, NULL);
  NineSliceEffectPrivate *priv = NINESLICE_EFFECT(self)->priv;
  priv->tiled = tiled;
  
  GError *error = NULL;
  ClutterActor *texture;
  gint i;
  for (i = 0; i < 9; i++) {
    if (sheet != NULL) {
      //spritesheet_get_sprite(sheet, names[i], &priv->material[i], NULL, &priv->w[i], &priv->h[i]);
      sheet->get_sprite(names[i], &priv->material[i], NULL, &priv->w[i], &priv->h[i]);
    } else {
      texture = clutter_texture_new_from_file(names[i], &error);
      priv->material[i] = COGL_MATERIAL(clutter_texture_get_cogl_material(CLUTTER_TEXTURE(texture)));
      clutter_texture_get_base_size(CLUTTER_TEXTURE(texture), &priv->w[i], &priv->h[i]);
    }
    if (priv->material[i] != NULL) cogl_handle_ref(priv->material[i]);
  }
  
  return self;
}