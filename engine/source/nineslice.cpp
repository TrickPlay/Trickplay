#include <math.h>
#include "log.h"
#include "nineslice.h"

G_DEFINE_TYPE( NineSliceLayout, nineslice_layout, CLUTTER_TYPE_EFFECT );

#define NINESLICE_LAYOUT_GET_PRIVATE(obj) (G_TYPE_INSTANCE_GET_PRIVATE((obj), TYPE_NINESLICE_LAYOUT, NineSliceLayoutPrivate))

void Slice::on_ping( PushTexture* source, void* target )
{
    Slice* self = ( Slice* ) target;
    self->update();
}

void Slice::set_sprite( Sprite* _sprite, bool async )
{
    sprite = _sprite;
    loaded = false;
    done = !sprite;
    ping.assign( sprite, Slice::on_ping, this, !async );
}

void Slice::unset_sprite()
{
    ping.assign( NULL, NULL, NULL, false );
    sprite = NULL;
}

void Slice::update()
{
    static ClutterActor* texture = clutter_texture_new();

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

    nineslice_redraw(layout);

    loaded = sprite && sprite->is_real();
    done = !sprite || sprite->is_real() || sprite->is_failed();

    if ( done )
    {
        action = nineslice_layout_signal_loaded_later( layout );
    }
}

class SignalLoadedLater : public Action
{
    NineSliceLayout* self;

    public: SignalLoadedLater( NineSliceLayout* s ) : self( s ) { g_assert( s ); };

    protected: bool run()
    {
        if ( nineslice_layout_is_done( self ) )
        {
            g_signal_emit_by_name( G_OBJECT( self ), "load-finished", !nineslice_layout_is_loaded( self ) );
        }

        self->priv->can_fire = true;
        return false;
    }
};

ClutterEffect* nineslice_layout_new()
{
    return ( ClutterEffect* ) g_object_new( TYPE_NINESLICE_LAYOUT, NULL );
}

void nineslice_layout_set_sprite( NineSliceLayout* layout, unsigned i, Sprite* sprite, bool async )
{
    g_assert( i < 9 );
    layout->priv->slices[i].set_sprite( sprite, async );
}

bool nineslice_layout_is_done( NineSliceLayout* layout )
{
    Slice* slices = layout->priv->slices;

    for ( unsigned i = 0; i < 9; ++i )
    {
        if ( !slices[i].done )
        {
            return false;
        }
    }

    return true;
}

bool nineslice_layout_is_loaded( NineSliceLayout* layout )
{
    Slice* slices = layout->priv->slices;

    for ( unsigned i = 0; i < 9; ++i )
    {
        if ( slices[i].sprite && !slices[i].loaded )
        {
            return false;
        }
    }

    return true;
}

Action * nineslice_layout_signal_loaded_later( NineSliceLayout* layout )
{
    SignalLoadedLater * ret = NULL;
    if ( layout->priv->can_fire )
    {
        layout->priv->can_fire = false;

        ret = new SignalLoadedLater( layout );
        Action::post( ret );
    }

    return ret;
}

bool nineslice_layout_get_tile( NineSliceLayout* layout, unsigned i )
{
    g_assert( i < 6 );
    return layout->priv->tile[i];
}

void nineslice_layout_get_tile( NineSliceLayout* layout, gboolean tile[6] )
{
    for ( unsigned i = 0; i < 6; i++ )
    {
        tile[i] = layout->priv->tile[i];
    }
}

void nineslice_redraw( NineSliceLayout* layout )
{
    clutter_actor_queue_redraw( clutter_actor_meta_get_actor( CLUTTER_ACTOR_META( layout ) ) );
}

void nineslice_layout_set_tile( NineSliceLayout* layout, unsigned i, bool t, bool guess, bool constructing )
{
    g_assert(i < 6);
    layout->priv->tile[i] = guess ? ( i ? layout->priv->tile[ MAX( i / 2 - 1, 0 ) ] : false ) : t;

    if (!constructing) nineslice_redraw(layout);
}

void nineslice_layout_set_tile( NineSliceLayout* layout, gboolean tile[6] )
{
    for ( unsigned i = 0; i < 6; i++ )
    {
        layout->priv->tile[i] = tile[i];
    }

    nineslice_redraw(layout);
}

std::vector< int >* nineslice_layout_get_borders( NineSliceLayout* layout )
{
    Slice* slices = layout->priv->slices;

    int width[9], height[9];

    for ( unsigned i = 0; i < 9; i++ )
    {
        Sprite* sprite = slices[i].sprite;

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

    std::vector< int >* borders = new std::vector< int >( 4, 0 );

    borders->at( 0 ) = MAX( MAX( width[0],  width[3] ), width[6] );
    borders->at( 1 ) = MAX( MAX( width[2],  width[5] ), width[8] );
    borders->at( 2 ) = MAX( MAX( height[0], height[1] ), height[2] );
    borders->at( 3 ) = MAX( MAX( height[6], height[7] ), height[8] );

    return borders;
}

/* GObject housekeeping */

static gboolean nineslice_layout_pre_paint( ClutterEffect* self )
{
    float w, h;
    ClutterActor* actor = clutter_actor_meta_get_actor( CLUTTER_ACTOR_META( self ) );
    clutter_actor_get_size( actor, &w, &h );
    NineSliceLayoutPrivate* priv = NINESLICE_LAYOUT( self )->priv;
    Slice* slices = priv->slices;

    if ( w <= 0 || h <= 0 )
    {
        return FALSE;
    }

    int width[9], height[9];

    for ( unsigned i = 0; i < 9; i++ )
    {
        Sprite* sprite = slices[i].sprite;

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

    float l = ( float ) MAX( MAX( width[0],  width[3] ), width[6] ),
          r = ( float ) MAX( MAX( width[2],  width[5] ), width[8] ),
          t = ( float ) MAX( MAX( height[0], height[1] ), height[2] ),
          b = ( float ) MAX( MAX( height[6], height[7] ), height[8] );

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
            if ( slices[i * 3 + j].material )
            {
                cogl_set_source( slices[i * 3 + j].material );
                gboolean tx = j == 1 && priv->tile[( i == 0 ) ? 2 : ( i == 1 ) ? 0 : 3 ],
                         ty = i == 1 && priv->tile[( j == 0 ) ? 4 : ( j == 1 ) ? 1 : 5 ];
                cogl_rectangle_with_texture_coords( xs[j], ys[i], xs[j + 1], ys[i + 1], 0.0, 0.0,
                        tx ? ( xs[j + 1] - xs[j] ) / ( float ) width[i * 3 + j] : 1.0,
                        ty ? ( ys[i + 1] - ys[i] ) / ( float ) height[i * 3 + j] : 1.0 );
            }
        }
    }

    return FALSE;
}

static void nineslice_layout_dispose( GObject* gobject )
{
    if (NINESLICE_LAYOUT( gobject )->priv->slices)
    {
        delete[] NINESLICE_LAYOUT( gobject )->priv->slices;
        NINESLICE_LAYOUT( gobject )->priv->slices = NULL;
    }

    G_OBJECT_CLASS( nineslice_layout_parent_class )->dispose( gobject );
}

static void nineslice_layout_class_init( NineSliceLayoutClass* klass )
{
    g_type_class_add_private( klass, sizeof( NineSliceLayoutPrivate ) );

    ClutterEffectClass* cklass = CLUTTER_EFFECT_CLASS( klass );
    cklass->pre_paint = nineslice_layout_pre_paint;

    GObjectClass* gklass = G_OBJECT_CLASS( klass );
    gklass->dispose = nineslice_layout_dispose;
}

static void nineslice_layout_init( NineSliceLayout* self )
{
    self->priv = NINESLICE_LAYOUT_GET_PRIVATE( self );

    self->priv->can_fire = true;
    self->priv->slices = new Slice[9];

    for ( unsigned i = 0; i < 9; ++i )
    {
        self->priv->slices[i].layout = self;
    }
}
