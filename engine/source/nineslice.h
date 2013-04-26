#ifndef __TRICKPLAY_NINESLICE_H__
#define __TRICKPLAY_NINESLICE_H__

#include <clutter/clutter.h>
#include "spritesheet.h"

typedef SpriteSheet::Sprite Sprite;
typedef PushTexture::PingMe PingMe;

GType nineslice_effect_get_type( void );

#define TYPE_NINESLICE_EFFECT             (nineslice_effect_get_type())
#define NINESLICE_EFFECT(obj)             (G_TYPE_CHECK_INSTANCE_CAST((obj),  TYPE_NINESLICE_EFFECT, NineSliceEffect))
#define IS_NINESLICE_EFFECT(obj)          (G_TYPE_CHECK_INSTANCE_TYPE((obj),  TYPE_NINESLICE_EFFECT))
#define NINESLICE_EFFECT_CLASS(klass)     (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_EFFECT, NineSliceEffectClass))
#define IS_NINESLICE_EFFECT_CLASS(klass)  (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_EFFECT))
#define NINESLICE_EFFECT_GET_CLASS(obj)   (G_TYPE_INSTANCE_GET_CLASS((obj),   TYPE_NINESLICE_EFFECT, NineSliceEffectClass))

struct NineSliceEffect;

class Slice
{
public:
    Slice() : effect( NULL ), material( NULL ), sprite( NULL ), loaded( false ), done( true ), action( NULL ) {}

    ~Slice()
    {
        if ( done && action ) {
            Action::cancel( action );
            action = NULL;
        }

        if ( material ) cogl_handle_unref( material );
    }

    static void on_ping( PushTexture* source, void* target );
    void set_sprite( Sprite* _sprite, bool async );
    void unset_sprite();
    void update();

public:
    NineSliceEffect   * effect;
    CoglMaterial      * material;
    Sprite            * sprite;
    PingMe              ping;
    bool                loaded;
    bool                done;
    Action            * action;
};

struct NineSliceEffectPrivate
{
    Slice* slices;
    bool can_fire;
    gboolean tile[6];
};

struct NineSliceEffect
{
    ClutterEffect parent_instance;
    NineSliceEffectPrivate* priv;
};

struct NineSliceEffectClass
{
    ClutterEffectClass parent_class;
};

ClutterEffect* nineslice_effect_new();

void nineslice_effect_set_sprite( NineSliceEffect* effect, unsigned i, SpriteSheet::Sprite* sprite, bool async );

bool nineslice_effect_is_done( NineSliceEffect* effect );
bool nineslice_effect_is_loaded( NineSliceEffect* effect );
Action * nineslice_effect_signal_loaded_later( NineSliceEffect* effect );  // fires "load_finished" signal if true

// There are 6 tile parameters (see nineslice.lb); set/get them individually or as an array

bool nineslice_effect_get_tile( NineSliceEffect* effect, unsigned i );
void nineslice_effect_get_tile( NineSliceEffect* effect, gboolean tile[6] );
void nineslice_effect_set_tile( NineSliceEffect* effect, unsigned i, bool t, bool guess, bool constructing );
void nineslice_effect_set_tile( NineSliceEffect* effect, gboolean tile[6] );
void nineslice_redraw( NineSliceEffect* effect );

std::vector< int >* nineslice_effect_get_borders( NineSliceEffect* effect );

#endif
