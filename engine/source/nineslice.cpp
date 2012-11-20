#include <math.h>
#include "nineslice.h"

G_DEFINE_TYPE(NineSliceEffect, nineslice_effect, CLUTTER_TYPE_EFFECT);

#define NINESLICE_EFFECT_GET_PRIVATE(obj) (G_TYPE_INSTANCE_GET_PRIVATE((obj), TYPE_NINESLICE_EFFECT, NineSliceEffectPrivate))

typedef SpriteSheet::Sprite Sprite;

struct _NineSliceEffectPrivate {
    SpriteSheet  * sheet;
    Sprite       * sprites[9];
    CoglMaterial * material[9];
    //const gchar    * ids[9];
    //gint w[9],
    //     h[9];
    gboolean tile[6];
    //gboolean has_ids;
};

static gboolean nineslice_effect_pre_paint( ClutterEffect * self )
{
    float w, h;
    ClutterActor * actor = clutter_actor_meta_get_actor( CLUTTER_ACTOR_META( self ) );
    clutter_actor_get_size( actor, &w, &h );
    NineSliceEffectPrivate * priv = NINESLICE_EFFECT( self )->priv;
    
    if ( w <= 0 || h <= 0 )
    {
        return FALSE;
    }
    
    /*
    float l = (float) MAX( MAX( priv->w[0], priv->w[3] ), priv->w[6] ),
          r = (float) MAX( MAX( priv->w[2], priv->w[5] ), priv->w[8] ),
          t = (float) MAX( MAX( priv->h[0], priv->h[1] ), priv->h[2] ),
          b = (float) MAX( MAX( priv->h[6], priv->h[7] ), priv->h[8] );
    */
    
    int width[9], height[9];
    for ( unsigned i = 0; i < 9; i++ )
    {
        Sprite * sprite = priv->sprites[i];
        width[i]  = sprite ? sprite->get_w() : 0;
        height[i] = sprite ? sprite->get_h() : 0;
    }
    
    float l = (float) MAX( MAX( width[0],  width[3]  ), width[6]  ),
          r = (float) MAX( MAX( width[2],  width[5]  ), width[8]  ),
          t = (float) MAX( MAX( height[0], height[1] ), height[2] ),
          b = (float) MAX( MAX( height[6], height[7] ), height[8] );
                                     
    if ( l + r > w )
    {
        l = w * l / ( l + r );
        r = w - l;
    }
    
    if ( t + b > h )
    {
        t = h * t / ( t + b );
        b = h - t;
    }
    
    float xs[] = { 0.0, l, w - r, w },
          ys[] = { 0.0, t, h - b, h };
    
    gint i, j;
    for ( i = 0; i < 3; i++ )
        for ( j = 0; j < 3; j++ )
            if ( priv->material[i*3 + j] )
            {
                cogl_set_source( priv->material[i*3 + j] );
                gboolean tx = j == 1 && priv->tile[ (i == 0) ? 2 : (i == 1) ? 0 : 3 ],
                         ty = i == 1 && priv->tile[ (j == 0) ? 4 : (j == 1) ? 1 : 5 ];
                cogl_rectangle_with_texture_coords( xs[j], ys[i], xs[j+1], ys[i+1], 0.0, 0.0,
                         tx ? ( xs[j+1] - xs[j] ) / (float) width[i*3 + j] : 1.0,
                         ty ? ( ys[i+1] - ys[i] ) / (float) height[i*3 + j] : 1.0 ); // priv->h[i*3 + j]
            }

    return FALSE;
}

static void nineslice_effect_dispose( GObject * gobject )
{
    NineSliceEffectPrivate * priv = NINESLICE_EFFECT( gobject )->priv;
    
    gint i;
    for ( i = 0; i < 9; i++ )
    {
        //free( (void *) priv->ids[i] );
        if ( priv->material[i] )
        {
            cogl_handle_unref( priv->material[i] );
            priv->material[i] = NULL;
        }
    }
    
    G_OBJECT_CLASS( nineslice_effect_parent_class )->dispose( gobject );
}

void nineslice_effect_set_sprites( NineSliceEffect * effect, gboolean set_sheet, SpriteSheet * sheet, const gchar * ids[] )
{
    NineSliceEffectPrivate * priv = effect->priv;
    
    if ( set_sheet && priv->sheet != sheet )
    {
        priv->sheet = sheet;
    }
    
    ClutterActor * texture;
    
    if ( priv->sheet )
    {
        texture = clutter_texture_new();
    }
    
    for ( unsigned i = 0; i < 9; i++ )
    {
        if ( priv->material[i] )
        {
            cogl_handle_unref( priv->material[i] );
            priv->material[i] = NULL;
        }
        
        if ( priv->sprites[i] )
        {
            priv->sprites[i]->deref_subtexture();
            priv->sprites[i] = NULL;
        }
        
        if ( priv->sheet && ids && ids[i] )
        {
            if (( priv->sprites[i] = priv->sheet->get_sprite( ids[i] ) ))
            {
                clutter_texture_set_cogl_texture( CLUTTER_TEXTURE( texture ), priv->sprites[i]->ref_subtexture() );
                priv->material[i] = cogl_material_copy( COGL_MATERIAL(
                    clutter_texture_get_cogl_material( CLUTTER_TEXTURE( texture ) ) ) );
            }
        }
    }
    
    if ( priv->sheet )
    {
        clutter_actor_destroy( texture );
    }
}
/*
static void nineslice_effect_reevaluate( NineSliceEffect * effect )
{
    NineSliceEffectPrivate * priv = effect->priv;
    gboolean ready = priv->sheet && priv->has_ids;
    ClutterActor * texture;
    
    if ( ready )
        texture = clutter_texture_new();
        
    gint i;
    for ( i = 0; i < 9; i++ )
    {
        if ( priv->material[i] != NULL )
        {
            cogl_handle_unref( priv->material[i] );
            priv->material[i] = NULL;
            priv->w[i] = 0;
            priv->h[i] = 0;
        }
        
        if ( ready && priv->ids[i] )
        {
            Sprite * sprite = priv->sheet->get_sprite( priv->ids[i] );
            CoglHandle subtexture = priv->sheet->get_subtexture( priv->ids[i] );
            if ( cogl_is_texture( subtexture ) )
            {
                clutter_texture_set_cogl_texture( CLUTTER_TEXTURE( texture ), subtexture );
                
                priv->material[i] = cogl_material_copy( COGL_MATERIAL(
                        clutter_texture_get_cogl_material( CLUTTER_TEXTURE( texture ) ) ) );
                clutter_texture_get_base_size( CLUTTER_TEXTURE( texture ), &priv->w[i], &priv->h[i] );
            }
        }
    }
    
    if ( ready )
        clutter_actor_destroy( texture );
}
*/
void nineslice_effect_set_tile( NineSliceEffect * effect, gboolean tile[6] )
{
    int i;
    for ( i = 0; i < 6; i++ )
        effect->priv->tile[i] = tile[i];
}

void nineslice_effect_get_tile( NineSliceEffect * effect, gboolean tile[6] )
{
    int i;
    for ( i = 0; i < 6; i++ )
        tile[i] = effect->priv->tile[i];
}
/*
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
        if( priv->ids[i] )
            free( (void *) priv->ids[i] );
            
        if ( ids )
        {
            if( ids[i] )
                priv->ids[i] = strdup( ids[i] );
            else
                priv->ids[i] = NULL;
        }
    }
    
    priv->has_ids = ids ? TRUE : FALSE;
    nineslice_effect_reevaluate( effect );
}
*/
void nineslice_effect_get_borders( NineSliceEffect * effect, int borders[4] )
{
    /*
    int * w = effect->priv->w, * h = effect->priv->h;
    borders[0] = MAX( MAX( w[0], w[3] ), w[6] );
    borders[1] = MAX( MAX( w[2], w[5] ), w[8] );
    borders[2] = MAX( MAX( h[0], h[1] ), h[2] );
    borders[3] = MAX( MAX( h[6], h[7] ), h[8] );
    */
    int width[9], height[9];
    for ( unsigned i = 0; i < 9; i++ )
    {
        Sprite * sprite = effect->priv->sprites[i];
        width[i]  = sprite ? sprite->get_w() : 0;
        height[i] = sprite ? sprite->get_h() : 0;
    }
    
    borders[0] = MAX( MAX( width[0],  width[3]  ), width[6]  );
    borders[1] = MAX( MAX( width[2],  width[5]  ), width[8]  );
    borders[2] = MAX( MAX( height[0], height[1] ), height[2] );
    borders[3] = MAX( MAX( height[6], height[7] ), height[8] );
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

ClutterEffect * nineslice_effect_new_from_ids( const gchar * ids[], SpriteSheet * sheet, gboolean tile[6] )
{
    ClutterEffect * self = (ClutterEffect *) g_object_new( TYPE_NINESLICE_EFFECT, NULL );
    //NineSliceEffectPrivate * priv = NINESLICE_EFFECT( self )->priv;
    
    //priv->sheet = sheet;
    //nineslice_effect_set_ids( NINESLICE_EFFECT( self ), ids );
    nineslice_effect_set_tile( NINESLICE_EFFECT( self ), tile );
    nineslice_effect_set_sprites( NINESLICE_EFFECT( self ), TRUE, sheet, ids );
    
    return self;
}
