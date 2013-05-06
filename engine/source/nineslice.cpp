#include <math.h>
#include "log.h"
#include "nineslice.h"

G_DEFINE_TYPE( NineSliceLayout, nineslice_layout, G_TYPE_OBJECT );

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
    loaded = sprite && sprite->is_real();
    done = !sprite || sprite->is_real() || sprite->is_failed();

    if ( done )
    {
        nineslice_redraw(layout);
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
            g_signal_emit_by_name( G_OBJECT( self ), "load-finished", false );
        }

        self->priv->can_fire = true;
        self->priv->action = NULL;
        return false;
    }
};

GObject* nineslice_layout_new()
{
    return ( GObject* ) g_object_new( TYPE_NINESLICE_LAYOUT, NULL );
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
    unsigned counter = 0;

    for ( unsigned i = 0; i < 9; ++i )
    {
        if ( slices[i].sprite )
        {
            if ( !slices[i].loaded ) return false;
        }
        else
        {
            counter++;
        }
    }

    // When all sprites are NULL, the nineslice is not loaded
    return (counter != 9);
}

void nineslice_layout_signal_loaded_later( NineSliceLayout* layout )
{
    if ( layout->priv->can_fire )
    {
        layout->priv->can_fire = false;
        layout->priv->action = new SignalLoadedLater( layout );
        Action::post( layout->priv->action );
    }
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

void get_slice_tile( NineSliceLayout* layout, unsigned index, gboolean *h, gboolean *v)
{
    g_assert( (index >= 0) && (index < 9) );

    *h = *v = false;

    switch (index)
    {
        case 1: *h = layout->priv->tile[2]; break;
        case 3: *v = layout->priv->tile[4]; break;
        case 4: *h = layout->priv->tile[0];
                *v = layout->priv->tile[1]; break;
        case 5: *v = layout->priv->tile[5]; break;
        case 7: *h = layout->priv->tile[3]; break;
        default: ;
    }
}

void nineslice_redraw( NineSliceLayout* layout )
{
    if ( !nineslice_layout_is_loaded( layout ) ) return;

    Slice* slices = layout->priv->slices;

    for ( unsigned i = 0; i < 9; i++ )
    {
        if ( slices[i].sprite )
        {
            ClutterActor * texture = slices[i].texture;
            clutter_texture_set_cogl_texture( CLUTTER_TEXTURE( texture ), slices[i].sprite->get_texture() );

            gboolean h, v;
            get_slice_tile(layout, i, &h, &v);
            clutter_texture_set_repeat( CLUTTER_TEXTURE( texture ), h, v );
        }
    }

    g_assert( layout->priv->actor );
    clutter_actor_queue_redraw( layout->priv->actor );

    nineslice_layout_signal_loaded_later( layout );
}

void nineslice_layout_set_tile( NineSliceLayout* layout, unsigned i, bool t, bool guess, bool constructing )
{
    g_assert(i < 6);
    layout->priv->tile[i] = guess ? ( i ? layout->priv->tile[ MAX( i / 2 - 1, 0 ) ] : false ) : t;
}

void nineslice_layout_set_tile( NineSliceLayout* layout, gboolean tile[6] )
{
    for ( unsigned i = 0; i < 6; i++ )
    {
        layout->priv->tile[i] = tile[i];
    }
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

static void nineslice_layout_dispose( GObject* gobject )
{
    NineSliceLayout * layout = NINESLICE_LAYOUT( gobject );
    if ( layout->priv->slices )
    {
        delete[] NINESLICE_LAYOUT( gobject )->priv->slices;
        NINESLICE_LAYOUT( gobject )->priv->slices = NULL;
    }

    if ( layout->priv->table )
    {
        g_object_unref( layout->priv->table );
        layout->priv->table = NULL;
    }

    if ( layout->priv->action )
    {
        Action::cancel( layout->priv->action );
        layout->priv->action = NULL;
    }

    G_OBJECT_CLASS( nineslice_layout_parent_class )->dispose( gobject );
}

static void nineslice_layout_class_init( NineSliceLayoutClass* klass )
{
    g_type_class_add_private( klass, sizeof( NineSliceLayoutPrivate ) );

    GObjectClass* gklass = G_OBJECT_CLASS( klass );
    gklass->dispose = nineslice_layout_dispose;    
}

static void nineslice_layout_init( NineSliceLayout* self )
{
    self->priv = NINESLICE_LAYOUT_GET_PRIVATE( self );

    self->priv->can_fire = true;
    self->priv->slices = new Slice[9];
    self->priv->parent_valid = true;
    self->priv->action = NULL;
}

void nineslice_layout_init_tablelayout( NineSliceLayout* self, ClutterActor * _actor )
{
    NineSliceLayoutPrivate* priv = self->priv;

    priv->actor = _actor;
    priv->table = (ClutterTableLayout *) clutter_table_layout_new();

    clutter_actor_set_layout_manager( _actor, (ClutterLayoutManager *) (priv->table) );

    for ( unsigned i = 0; i < 9; ++i )
    {
        priv->slices[i].index = i;
        priv->slices[i].layout = self;
        clutter_table_layout_pack( priv->table, priv->slices[i].texture, i % 3, (gint) i / 3 );

        gboolean h, v;              // stretch
        ClutterTableAlignment x, y; // alignment
        switch (i) {
            case 0: h = false; v = false; x = CLUTTER_TABLE_ALIGNMENT_END;    y = CLUTTER_TABLE_ALIGNMENT_END;    break;
            case 1: h = true;  v = false; x = CLUTTER_TABLE_ALIGNMENT_CENTER; y = CLUTTER_TABLE_ALIGNMENT_END;    break;
            case 2: h = false; v = false; x = CLUTTER_TABLE_ALIGNMENT_START;  y = CLUTTER_TABLE_ALIGNMENT_END;    break;
            case 3: h = false; v = true;  x = CLUTTER_TABLE_ALIGNMENT_END;    y = CLUTTER_TABLE_ALIGNMENT_CENTER; break;
            case 4: h = true;  v = true;  x = CLUTTER_TABLE_ALIGNMENT_CENTER; y = CLUTTER_TABLE_ALIGNMENT_CENTER; break;
            case 5: h = false; v = true;  x = CLUTTER_TABLE_ALIGNMENT_START;  y = CLUTTER_TABLE_ALIGNMENT_CENTER; break;
            case 6: h = false; v = false; x = CLUTTER_TABLE_ALIGNMENT_END;    y = CLUTTER_TABLE_ALIGNMENT_START;  break;
            case 7: h = true;  v = false; x = CLUTTER_TABLE_ALIGNMENT_CENTER; y = CLUTTER_TABLE_ALIGNMENT_START;  break;
            case 8: h = false; v = false; x = CLUTTER_TABLE_ALIGNMENT_START;  y = CLUTTER_TABLE_ALIGNMENT_START;  break;
        }

        clutter_table_layout_set_expand   ( priv->table, priv->slices[i].texture, h, v );
        clutter_table_layout_set_alignment( priv->table, priv->slices[i].texture, x, y );
    }
}
