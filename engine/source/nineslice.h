#ifndef __TRICKPLAY_NINESLICE_H__
#define __TRICKPLAY_NINESLICE_H__

#include <clutter/clutter.h>
#include "spritesheet.h"

typedef SpriteSheet::Sprite Sprite;
typedef PushTexture::PingMe PingMe;

GType nineslice_layout_get_type( void );

#define TYPE_NINESLICE_LAYOUT             (nineslice_layout_get_type())
#define NINESLICE_LAYOUT(obj)             (G_TYPE_CHECK_INSTANCE_CAST((obj),  TYPE_NINESLICE_LAYOUT, NineSliceLayout))
#define IS_NINESLICE_LAYOUT(obj)          (G_TYPE_CHECK_INSTANCE_TYPE((obj),  TYPE_NINESLICE_LAYOUT))
#define NINESLICE_LAYOUT_CLASS(klass)     (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_LAYOUT, NineSliceLayoutClass))
#define IS_NINESLICE_LAYOUT_CLASS(klass)  (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_LAYOUT))
#define NINESLICE_LAYOUT_GET_CLASS(obj)   (G_TYPE_INSTANCE_GET_CLASS((obj),   TYPE_NINESLICE_LAYOUT, NineSliceLayoutClass))

struct NineSliceLayout;

class Slice
{
public:
    Slice() : layout( NULL ), sprite( NULL ), loaded( false ), done( false )
    {
        texture = clutter_texture_new();
    }

    ~Slice()
    {
        clutter_actor_destroy( texture );
    }

    static void on_ping( PushTexture* source, void* target );
    void set_sprite( Sprite* _sprite, bool async );
    void unset_sprite();
    void update();

public:
    NineSliceLayout   * layout;
    ClutterActor      * texture;
    Sprite            * sprite;
    PingMe              ping;
    bool                loaded;
    bool                done;
    unsigned            index;
};

struct NineSliceLayoutPrivate
{
    Slice               * slices;
    bool                  can_fire;
    gboolean              tile[6];
    gboolean              parent_valid;
    ClutterActor        * actor;
    ClutterTableLayout  * table;
    Action              * action;
};

struct NineSliceLayout
{
    GObject parent_instance;
    NineSliceLayoutPrivate* priv;
};

struct NineSliceLayoutClass
{
    GObjectClass parent_class;
};

GObject* nineslice_layout_new();

void nineslice_layout_set_sprite( NineSliceLayout* layout, unsigned i, SpriteSheet::Sprite* sprite, bool async );

bool nineslice_layout_is_done( NineSliceLayout* layout );
bool nineslice_layout_is_loaded( NineSliceLayout* layout );
void nineslice_layout_signal_loaded_later( NineSliceLayout* layout );  // fires "load_finished" signal if true

// There are 6 tile parameters (see nineslice.lb); set/get them individually or as an array

bool nineslice_layout_get_tile( NineSliceLayout* layout, unsigned i );
void nineslice_layout_get_tile( NineSliceLayout* layout, gboolean tile[6] );
void nineslice_layout_set_tile( NineSliceLayout* layout, unsigned i, bool t, bool guess, bool constructing );
void nineslice_layout_set_tile( NineSliceLayout* layout, gboolean tile[6] );
void nineslice_redraw( NineSliceLayout* layout );

std::vector< int >* nineslice_layout_get_borders( NineSliceLayout* layout );

void nineslice_layout_init_tablelayout( NineSliceLayout* self, ClutterActor * _actor );

#endif
