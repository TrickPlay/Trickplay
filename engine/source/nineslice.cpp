#include <math.h>
#include "nineslice.h"

G_DEFINE_TYPE(NineSliceEffect, nineslice_effect, CLUTTER_TYPE_EFFECT);

#define NINESLICE_EFFECT_GET_PRIVATE(obj) (G_TYPE_INSTANCE_GET_PRIVATE((obj), TYPE_NINESLICE_EFFECT, NineSliceEffectPrivate))

struct _NineSliceEffectPrivate {
  SpriteSheet  * sheet;
  const gchar  * ids[9];
  CoglMaterial * material[9];
  gint w[9],
       h[9];
  gboolean tile_x,
           tile_y;
  gboolean has_ids;
};

static gboolean nineslice_effect_pre_paint( ClutterEffect * self )
{
  gfloat w, h;
  ClutterActor * actor = clutter_actor_meta_get_actor( CLUTTER_ACTOR_META( self ) );
  clutter_actor_get_size( actor, &w, &h );
  NineSliceEffectPrivate * priv = NINESLICE_EFFECT( self )->priv;
  
  gfloat xs[] = { 0.0, (float) MAX( MAX( priv->w[0], priv->w[1] ), priv->w[2] ),
                   w - (float) MAX( MAX( priv->w[6], priv->w[7] ), priv->w[8] ), w };
  gfloat ys[] = { 0.0, (float) MAX( MAX( priv->h[0], priv->h[3] ), priv->h[6] ),
                   h - (float) MAX( MAX( priv->h[2], priv->h[5] ), priv->h[8] ), h };
  
  gint i, j;
  for ( i = 0; i < 3; i++ )
    for ( j = 0; j < 3; j++ )
      if ( priv->material[i*3 + j] )
      {
        cogl_set_source( priv->material[i*3 + j] );
        cogl_rectangle_with_texture_coords( xs[j], ys[i], xs[j+1], ys[i+1], 0.0, 0.0,
            j == 1 && priv->tile_x ? ( xs[j+1] - xs[j] ) / (float) priv->w[i*3 + j] : 1.0,
            i == 1 && priv->tile_y ? ( ys[i+1] - ys[i] ) / (float) priv->h[i*3 + j] : 1.0);
      }

  return FALSE;
}

static void nineslice_effect_dispose( GObject * gobject )
{
  NineSliceEffectPrivate * priv = NINESLICE_EFFECT( gobject )->priv;
  
  gint i;
  for ( i = 0; i < 9; i++ )
  {
    free( priv->ids[i] );
    if ( priv->material[i] )
    {
      cogl_handle_unref( priv->material[i] );
      priv->material[i] = NULL;
    }
  }
  
  G_OBJECT_CLASS( nineslice_effect_parent_class )->dispose( gobject );
}

static void nineslice_effect_reevaluate( NineSliceEffect * effect )
{
  NineSliceEffectPrivate * priv = effect->priv;
  GError * error = NULL;
  ClutterActor * texture = clutter_texture_new();
  gint i;
  for ( i = 0; i < 9; i++ )
  {
    cogl_handle_unref( priv->material[i] );
    priv->material[i] = NULL;
    
    if ( priv->sheet && priv->has_ids && priv->ids[i] )
    {
      //if ( priv->sheet != NULL )
        clutter_texture_set_cogl_texture( CLUTTER_TEXTURE( texture ), priv->sheet->get_subtexture( priv->ids[i] ) );
      //else
      //  clutter_texture_set_from_file( CLUTTER_TEXTURE( texture ), priv->ids[i], &error );
        
      priv->material[i] = cogl_material_copy( COGL_MATERIAL(
          clutter_texture_get_cogl_material( CLUTTER_TEXTURE( texture ) ) ) );
      clutter_texture_get_base_size( CLUTTER_TEXTURE( texture ), &priv->w[i], &priv->h[i] );
    }
  }
  clutter_actor_destroy( texture );
}

void nineslice_effect_set_tile( NineSliceEffect * effect, gboolean tile_x, gboolean tile_y )
{
  effect->priv->tile_x = tile_x;
  effect->priv->tile_y = tile_y;
}

void nineslice_effect_get_tile( NineSliceEffect * effect, gboolean * tile_x, gboolean * tile_y )
{
  * tile_x = effect->priv->tile_x;
  * tile_y = effect->priv->tile_y;
}

void nineslice_effect_set_sheet( NineSliceEffect * effect, SpriteSheet * sheet )
{
  NineSliceEffectPrivate * priv = effect->priv;
  if ( priv->sheet != sheet )
  {
    priv->sheet = sheet;
    nineslice_effect_reevaluate( effect );
  }
}

void nineslice_effect_set_ids( NineSliceEffect * effect, const gchar * ids[] )
{
  NineSliceEffectPrivate * priv = effect->priv;
  gint i;
  for ( i = 0; i < 9; i++ )
  {
    free( priv->ids[i] );
    if ( ids )
      priv->ids[i] = strdup( ids[i] );
  }
  
  priv->has_ids = ids ? TRUE : FALSE;
  nineslice_effect_reevaluate( effect );
}

void nineslice_effect_get_borders( NineSliceEffect * effect, int borders[4] )
{
  int * w = effect->priv->w, * h = effect->priv->h;
  borders[0] = MAX( MAX( w[0], w[1] ), w[2] );
  borders[1] = MAX( MAX( w[6], w[7] ), w[8] );
  borders[2] = MAX( MAX( h[0], h[3] ), h[6] );
  borders[3] = MAX( MAX( h[2], h[5] ), h[8] );
}

static void nineslice_effect_class_init( NineSliceEffectClass * klass )
{
  g_type_class_add_private( klass, sizeof( NineSliceEffectPrivate ) );
  
  ClutterEffectClass * cklass = CLUTTER_EFFECT_CLASS( klass );
  cklass->pre_paint = nineslice_effect_pre_paint;
  
  GObjectClass * gklass = G_OBJECT_CLASS( klass );
  gklass->dispose = nineslice_effect_dispose;
}

static void nineslice_effect_init ( NineSliceEffect * self )
{
  self->priv = NINESLICE_EFFECT_GET_PRIVATE( self );
}

ClutterEffect * nineslice_effect_new()
{
  return (ClutterEffect *) g_object_new( TYPE_NINESLICE_EFFECT, NULL );
}

ClutterEffect * nineslice_effect_new_from_ids( const gchar * ids[], SpriteSheet * sheet, gboolean tile_x, gboolean tile_y )
{
  ClutterEffect * self = (ClutterEffect *) g_object_new( TYPE_NINESLICE_EFFECT, NULL );
  NineSliceEffectPrivate * priv = NINESLICE_EFFECT( self )->priv;
  
  priv->sheet = sheet;
  nineslice_effect_set_ids( NINESLICE_EFFECT( self ), ids );
  priv->tile_x = tile_x;
  priv->tile_y = tile_y;
  
  return self;
}