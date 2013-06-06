#ifndef __TRICKPLAY_NINESLICE_H__
#define __TRICKPLAY_NINESLICE_H__

#include <clutter/clutter.h>
#include "spritesheet.h"
#include "log.h"
#include "clutter_util.h"
#include "spritesheet.h"

typedef SpriteSheet::Sprite Sprite;
typedef PushTexture::PingMe PingMe;

extern const char * keys[9];

GType nineslice_layout_get_type( void );

#define TYPE_NINESLICE_LAYOUT             (nineslice_layout_get_type())
#define NINESLICE_LAYOUT(obj)             (G_TYPE_CHECK_INSTANCE_CAST((obj),  TYPE_NINESLICE_LAYOUT, NineSliceLayout))
#define IS_NINESLICE_LAYOUT(obj)          (G_TYPE_CHECK_INSTANCE_TYPE((obj),  TYPE_NINESLICE_LAYOUT))
#define NINESLICE_LAYOUT_CLASS(klass)     (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_LAYOUT, NineSliceLayoutClass))
#define IS_NINESLICE_LAYOUT_CLASS(klass)  (G_TYPE_CHECK_CLASS_CAST((klass),   TYPE_NINESLICE_LAYOUT))
#define NINESLICE_LAYOUT_GET_CLASS(obj)   (G_TYPE_INSTANCE_GET_CLASS((obj),   TYPE_NINESLICE_LAYOUT, NineSliceLayoutClass))

#define LB_GET_SPRITESHEET(L,i) ((SpriteSheet*)lb_get_udata_check(L,i,"SpriteSheet"))

struct NineSliceLayout;

GObject* nineslice_layout_new();

void nineslice_layout_set_sprite( NineSliceLayout* layout, unsigned i, SpriteSheet::Sprite* sprite, bool async );

bool nineslice_layout_is_done( NineSliceLayout* layout );
bool nineslice_layout_is_loaded( NineSliceLayout* layout );
void nineslice_layout_signal_loaded_later( NineSliceLayout* layout );  // fires "load-finished" signal if true

// There are 6 tile parameters (see nineslice.lb); set/get them individually or as an array

bool nineslice_layout_get_tile( NineSliceLayout* layout, unsigned i );
void nineslice_layout_get_tile( NineSliceLayout* layout, gboolean tile[6] );
void nineslice_layout_set_tile( NineSliceLayout* layout, unsigned i, bool t, bool guess, bool constructing );
void nineslice_layout_set_tile( NineSliceLayout* layout, gboolean tile[6] );
void nineslice_redraw( NineSliceLayout* layout );

std::vector< int >* nineslice_layout_get_borders( NineSliceLayout* layout );

void nineslice_layout_init_tablelayout( NineSliceLayout* self, ClutterActor * _actor );

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

/* TODO: Need to make it clear how objects are destructed, instead of no code/comments
 * TODO: Leverage ClutterTableLayout to simplify the implementation
 * TODO: Need to verify calculations of coordinates of x and y in the json file. Right now if it starts from 1 instead of 0, some sprites are being missed
 * TODO: Cloning - Two instances of the same NineSlice should share SpriteSheet, Sprites
 *
 * Class heirarchy: NineSliceBinding -> NineSliceLayout -> NineSliceLayoutPrivate -> Slice
 */

struct NineSliceBinding
{
    NineSliceBinding( NineSliceLayout * _layout, ClutterActor * _actor ) : async( false ), constructing( false ), sheet( NULL ), layout( _layout ), action( NULL )
    {
        g_assert( layout );
        g_assert( _actor );

        nineslice_layout_init_tablelayout( layout, _actor );
    }

    ~NineSliceBinding()
    {
        if ( async && action )
        {
            Action::cancel( action );
            action = NULL;
        }

        unsubscrube_sprites();

        layout->priv->parent_valid = false; // NineSliceBinding is gone

        if ( sheet ) RefCounted::ref( sheet );
        sheet = NULL;
    }

    NineSliceLayout * get_layout() { return layout; }

    bool get_tile( unsigned i )
    {
        if ( i >= 6 )
        {
            tpwarn("Invalid NineSlice tile index %d. The value must be between 0 and 6", i);
            return false;
        }

        return nineslice_layout_get_tile( layout, i );
    }

    void set_tile( unsigned i, bool t, bool guess )
    {
        if ( i >= 6 )
        {
            tpwarn("Invalid NineSlice tile index %d. The value must be between 0 and 6", i);
            return;
        }

        nineslice_layout_set_tile( layout, i, t, guess, constructing );
    }

    bool is_loaded() { return sheet && nineslice_layout_is_loaded( layout ); };

    std::vector< int > * get_borders() { return nineslice_layout_get_borders( layout ); }

    std::string & get_id( unsigned i )
    {
        if ( i >= 9 )
        {
            tpwarn("Invalid NineSlice id index %d. The value must be between 0 and 9", i);

            static std::string e = "";
            return e;
        }

        return ids[i];
    }

    void set_id( unsigned i, const std::string & new_id )
    {
        if ( i >= 9 )
        {
            tpwarn("Invalid NineSlice id index %d. The value must be between 0 and 9", i);
            return;
        }

        ids[i] = new_id;

        if (!constructing) nineslice_layout_set_sprite( layout, i, sheet ? sheet->get_sprite( ids[i].c_str() ) : NULL, async );
    }

    SpriteSheet * get_sheet() { return sheet; }

    void set_sheet( SpriteSheet * _sheet )
    {
        sheet = _sheet;
        RefCounted::ref( sheet );

        if (constructing) return;

        if (sheet) set_all_sprites();
    }

    void set_all_sprites()
    {
        if (!sheet) return;

        for ( unsigned i = 0; i < 9; ++i )
        {
            if ( !(ids[i].empty()) )
            {
                nineslice_layout_set_sprite( layout, i, sheet->get_sprite( ids[i].c_str() ), async );
            }
        }
    }

    void signal_loaded_later()
    {
        if ( async )
        {
            nineslice_layout_signal_loaded_later( layout );
        }
    }

    void unsubscrube_sprites()
    {
        Slice * slices = layout->priv->slices;

        if (slices)
        {
            for (int i = 0; i < 9; i++)
            {
                slices[i].unset_sprite();
            }
        }
    }

    bool async;
    bool constructing;

private:
    SpriteSheet      * sheet;
    NineSliceLayout  * layout;
    std::string        ids[9];
    Action           * action;
};

#endif
