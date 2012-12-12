#include <math.h>
#include "nineslice.h"
#include "pushtexture.h"

G_DEFINE_TYPE(NineSliceEffect, nineslice_effect, CLUTTER_TYPE_EFFECT);

#define NINESLICE_EFFECT_GET_PRIVATE(obj) (G_TYPE_INSTANCE_GET_PRIVATE((obj), TYPE_NINESLICE_EFFECT, NineSliceEffectPrivate))

typedef SpriteSheet::Sprite Sprite;
typedef PushTexture::PingMe PingMe;

struct Slice
{
    static void on_ping( PushTexture * source, void * target )
    {
        ((Slice *) target)->update();
    }
    
    Slice() : effect( NULL ), material( NULL ), sprite( NULL ) {};
    ~Slice() { if ( material ) cogl_handle_unref( material ); }
    
    void set_sprite( Sprite * _sprite, bool async )
    {
        sprite = _sprite;
        ping.set( sprite, Slice::on_ping, this, async );
        update();
    }
    
    void update()
    {
        static ClutterActor * texture = clutter_texture_new();
        
        if ( material )
        {
            cogl_handle_unref( material );
            material = NULL;
        }
        
        if ( sprite )
        {
            clutter_texture_set_cogl_texture( CLUTTER_TEXTURE( texture ), sprite->get_texture() );
            material = cogl_material_copy( COGL_MATERIAL( clutter_texture_get_cogl_material( CLUTTER_TEXTURE( texture ) ) ) );
        }
        
        clutter_actor_queue_redraw( clutter_actor_meta_get_actor( CLUTTER_ACTOR_META( effect ) ) );
    }
    
    NineSliceEffect * effect;
    CoglMaterial * material;
    Sprite * sprite;
    PingMe ping;
};

struct _NineSliceEffectPrivate {
    SpriteSheet  * sheet;
    Slice * slices;
    gboolean tile[6];
};

ClutterEffect * nineslice_effect_new()
{
    return (ClutterEffect *) g_object_new( TYPE_NINESLICE_EFFECT, NULL );
}

void nineslice_effect_set_sprite( NineSliceEffect * effect, unsigned i, Sprite * sprite, bool async )
{
    g_assert( i < 9 );
    effect->priv->slices[i].set_sprite( sprite, async );
}

bool nineslice_effect_get_tile( NineSliceEffect * effect, unsigned i )
{
    g_assert( i < 6 );
    return effect->priv->tile[i];
}

void nineslice_effect_get_tile( NineSliceEffect * effect, gboolean tile[6] )
{
    for ( unsigned i = 0; i < 6; i++ )
    {
        tile[i] = effect->priv->tile[i];
    }
}

void nineslice_effect_set_tile( NineSliceEffect * effect, unsigned i, bool t, bool guess )
{
    g_assert( i < 6 );
    effect->priv->tile[i] = guess ? ( i ? effect->priv->tile[ MAX( i / 2 - 1, 0 ) ] : false ) : t;
    
    clutter_actor_queue_redraw( clutter_actor_meta_get_actor( CLUTTER_ACTOR_META( effect ) ) );
}

void nineslice_effect_set_tile( NineSliceEffect * effect, gboolean tile[6] )
{
    for ( unsigned i = 0; i < 6; i++ )
    {
        effect->priv->tile[i] = tile[i];
    }
    
    clutter_actor_queue_redraw( clutter_actor_meta_get_actor( CLUTTER_ACTOR_META( effect ) ) );
}

std::vector< int > * nineslice_effect_get_borders( NineSliceEffect * effect )
{
    Slice * slices = effect->priv->slices;
    
    int width[9], height[9];
    for ( unsigned i = 0; i < 9; i++ )
    {
        Sprite * sprite = slices[i].sprite;
        if ( sprite ) 
        {
            sprite->get_dimensions( & width[i], & height[i] );
        }
        else
        {
            width[i] = 0;
            height[i] = 0;
        }
    }
    
    std::vector< int > * borders = new std::vector< int >( 4, 0 );
    
    borders->at( 0 ) = MAX( MAX( width[0],  width[3]  ), width[6]  );
    borders->at( 1 ) = MAX( MAX( width[2],  width[5]  ), width[8]  );
    borders->at( 2 ) = MAX( MAX( height[0], height[1] ), height[2] );
    borders->at( 3 ) = MAX( MAX( height[6], height[7] ), height[8] );
    
    return borders;
}

/* GObject housekeeping */

static gboolean nineslice_effect_pre_paint( ClutterEffect * self )
{
    float w, h;
    ClutterActor * actor = clutter_actor_meta_get_actor( CLUTTER_ACTOR_META( self ) );
    clutter_actor_get_size( actor, &w, &h );
    NineSliceEffectPrivate * priv = NINESLICE_EFFECT( self )->priv;
    Slice * slices = priv->slices;
    
    if ( w <= 0 || h <= 0 )
    {
        return FALSE;
    }
    
    int width[9], height[9];
    for ( unsigned i = 0; i < 9; i++ )
    {
        Sprite * sprite = slices[i].sprite;
        if ( sprite ) 
        {
            sprite->get_dimensions( & width[i], & height[i] );
        }
        else
        {
            width[i] = 0;
            height[i] = 0;
        }
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
    
    for ( unsigned i = 0; i < 3; i++ )
    {
        for ( unsigned j = 0; j < 3; j++ )
        {
            if ( slices[i*3 + j].material )
            {
                cogl_set_source( slices[i*3 + j].material );
                gboolean tx = j == 1 && priv->tile[ (i == 0) ? 2 : (i == 1) ? 0 : 3 ],
                         ty = i == 1 && priv->tile[ (j == 0) ? 4 : (j == 1) ? 1 : 5 ];
                cogl_rectangle_with_texture_coords( xs[j], ys[i], xs[j+1], ys[i+1], 0.0, 0.0,
                         tx ? ( xs[j+1] - xs[j] ) / (float) width[i*3 + j] : 1.0,
                         ty ? ( ys[i+1] - ys[i] ) / (float) height[i*3 + j] : 1.0 );
            }
        }
    }

    return FALSE;
}

static void nineslice_effect_dispose( GObject * gobject )
{
    delete[] NINESLICE_EFFECT( gobject )->priv->slices;
    G_OBJECT_CLASS( nineslice_effect_parent_class )->dispose( gobject );
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
    
    self->priv->slices = new Slice[9];
    
    for ( unsigned i = 0; i < 9; ++i )
    {
        self->priv->slices[i].effect = self;
    }
}
