
#include <cstdlib>

#include "sndfile.h"

#include "trickplay/audio-sampler.h"

#include "clutter_util.h"
#include "console_commands.h"
#include "common.h"
#include "context.h"
#include "profiler.h"
#include "versions.h"
#include "images.h"
#include "sysdb.h"
#include "spritesheet.h"
#include "ansi_color.h"
#include "nineslice.h"

namespace ConsoleCommands
{
#ifndef TP_PRODUCTION

//=============================================================================
// Base class for command handlers. Just create a new one of these, override
// the () operator and implement it. Then, add it to the map near the bottom
// of this file.

class Handler
{
public:

    Handler() {}

    virtual ~Handler() {}

    static void handle_command( TPContext* context , const char* command , const char* parameters , void* data )
    {
        ( * ( ( Handler* ) data ) )( context , command , parameters ? parameters : String() );
    }

protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters ) = 0;
};

#if 0

// Just an empty one you can copy and modify.

//.............................................................................

class  : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
    }
};

#endif

//=============================================================================

class Exit : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        tp_context_quit( context );
    }
};

//.............................................................................

class Config : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        StringMap config( context->get_config() );

        for ( StringMap::const_iterator it = config.begin(); it != config.end(); ++it )
        {
            g_info( "%-25.25s %s", it->first.c_str(), it->second.c_str() );
        }

    }
};

//.............................................................................

class Reload : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        context->reload_app();
    }
};

//.............................................................................

class Close : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        if ( ! context->get_current_app() )
        {
            g_info( "NO APP LOADED" );
        }
        else
        {
            context->close_current_app();
        }
    }
};

//.............................................................................

class GC : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        if ( App* app = context->get_current_app() )
        {
            if ( lua_State* L = app->get_lua_state() )
            {
                while ( true )
                {
                    int old_kb = lua_gc( L , LUA_GCCOUNT , 0 );
                    ( void ) lua_gc( L , LUA_GCCOLLECT , 0 );
                    int new_kb = lua_gc( L , LUA_GCCOUNT , 0 );
                    g_info( "GC : %d KB - %d KB = %d KB" , new_kb , old_kb , new_kb - old_kb );

                    if ( parameters == "all" )
                    {
                        if ( old_kb == new_kb )
                        {
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
    }
};

//.............................................................................

class Obj : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        PROFILER_OBJECTS;
    }
};

//.............................................................................

class Versions : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        dump_versions();
    }
};

//.............................................................................

class Images : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        ::Images::dump();
    }
};

//.............................................................................

class Cache : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        ::Images::dump_cache();
    }
};

//.............................................................................

class Mem : public Handler
{
protected:

    class MemReporter : public Action
    {
    public:

        MemReporter( bool _once )
            :
            once( _once )
        {
            gchar* fn = g_build_filename( G_DIR_SEPARATOR_S "proc" , "self" , "status" , NULL );

            filename = fn;

            g_free( fn );

            regex = g_regex_new( "^VmRSS:[^0-9]*([0-9]+).*$" , G_REGEX_MULTILINE , ( GRegexMatchFlags ) 0 , 0 );
        }

        ~MemReporter()
        {
            g_regex_unref( regex );
        }

    protected:

        virtual bool run()
        {
            bool ok = false;

            gchar* contents = 0;

            if ( g_file_get_contents( filename.c_str() , & contents , 0 , 0 ) )
            {
                GMatchInfo* mi = 0;

                if ( g_regex_match( regex , contents , ( GRegexMatchFlags ) 0 , & mi ) )
                {
                    if ( gchar* n = g_match_info_fetch( mi , 1 ) )
                    {
                        int rss = atoi( n );

                        if ( rss > peak )
                        {
                            peak = rss;
                        }

                        g_info( "RSS = %d : %+d : peak %d " , rss , last ? rss - last : 0 , peak );

                        last = rss;

                        g_free( n );

                        ok = true;
                    }
                }

                g_match_info_free( mi );

                g_free( contents );
            }

            if ( ! ok )
            {
                g_info( "FAILED TO GET MEMORY INFORMATION" );
                return false;
            }

            return ! once;
        }

        bool        once;
        String      filename;
        GRegex*     regex;
        static int  peak;
        static int  last;
    };

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        int interval = -1;

        if ( ! parameters.empty() )
        {
            interval = atoi( parameters.c_str() ) * 1000;
        }

        Action::post( new MemReporter( interval == -1 ? true : false ) , interval );
    }
};

int Mem::MemReporter::peak = 0;
int Mem::MemReporter::last = 0;

//.............................................................................

class Prof : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        if ( parameters == "reset" )
        {
            PROFILER_RESET;
        }
        else
        {
            PROFILER_DUMP;
        }
    }
};

//.............................................................................

class Screenshot : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        const gchar* home = g_getenv( "HOME" );

        if ( ! home )
        {
            home = g_get_home_dir();

            if ( ! home )
            {
                home = g_get_tmp_dir();
            }
        }

        if ( ! home )
        {
            g_warning( "FAILED TO FIND HOME OR TEMP DIR" );
        }
        else
        {
            Image* image = Image::screenshot( context->get_stage() );

            if ( ! image )
            {
                g_warning( "FAILED TO TAKE SCREENSHOT" );
            }
            else
            {
                String checksum( image->checksum() );

                GTimeVal t;

                g_get_current_time( & t );

                gchar* ts = g_strdup_printf( "trickplay-ss-%ld-%ld.png" , t.tv_sec , t.tv_usec );

                gchar* fn = g_build_filename( home , ts , NULL );

                g_free( ts );

                if ( ! image->write_to_png( fn ) )
                {
                    g_warning( "FAILED TO WRITE SCREENSHOT TO %s" , fn );
                }
                else
                {
                    g_info( "%s" , fn );
                    g_info( "%s" , checksum.c_str() );
                }

                g_free( fn );

                delete image;
            }
        }
    }
};

//.............................................................................

class AudioSampling : public Handler
{
protected:

    class AudioFeeder : private Action
    {
    public:

        static bool post( TPContext* context , const char* file_name , guint interval_s )
        {
            SF_INFO info;

            memset( & info , 0 , sizeof( info ) );

            SNDFILE* f = sf_open( file_name , SFM_READ , & info );

            if ( ! f )
            {
                return false;
            }

            g_info( "FEEDING AUDIO FROM %s EVERY %u s" , file_name , interval_s );
            g_info( "  frames      = %u"   , info.frames );
            g_info( "  sample_rate = %d"   , info.samplerate );
            g_info( "  channels    = %d"   , info.channels );
            g_info( "  format      = 0x%x" , info.format );
            g_info( "  duration    = %d s" , info.frames / info.samplerate );

            TPAudioSampler* sampler = tp_context_get_audio_sampler( context );

            tp_audio_sampler_source_changed( sampler );

            Action::post( new AudioFeeder( sampler , f , info ) , interval_s * 1000 );

            return true;
        }

    private:

        AudioFeeder( TPAudioSampler* _sampler , SNDFILE* _f , const SF_INFO& _info )
            :
            sampler( _sampler ),
            f( _f ),
            info( _info ),
            timer( g_timer_new() )
        {
        }

        virtual ~AudioFeeder()
        {
            sf_close( f );
            g_timer_destroy( timer );
            g_debug( "DESTROYED AUDIO FEEDER" );
        }

        virtual bool run()
        {
            sf_count_t frames = g_timer_elapsed( timer , 0 ) * info.samplerate;

            g_timer_start( timer );

            float* samples = g_new( float , frames * info.channels );

            sf_count_t read = sf_readf_float( f , samples , frames );

            if ( read == 0 )
            {
                g_free( samples );
                return false;
            }

            TPAudioBuffer buffer;

            memset( & buffer , 0 , sizeof( buffer ) );

            buffer.format = TP_AUDIO_FORMAT_FLOAT;
            buffer.channels = info.channels;
            buffer.sample_rate = info.samplerate;
            buffer.copy_samples = 1;
            buffer.free_samples = 0;
            buffer.samples = samples;
            buffer.size = read * info.channels * sizeof( float );

            tp_audio_sampler_submit_buffer( sampler , & buffer );

            g_free( samples );

            return true;
        }

        TPAudioSampler*     sampler;
        SNDFILE*            f;
        SF_INFO             info;
        GTimer*             timer;
    };

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        if ( parameters == "pause" )
        {
            tp_audio_sampler_pause( tp_context_get_audio_sampler( context ) );
        }
        else if ( parameters == "resume" )
        {
            tp_audio_sampler_resume( tp_context_get_audio_sampler( context ) );
        }
        else if ( parameters == "changed" )
        {
            tp_audio_sampler_source_changed( tp_context_get_audio_sampler( context ) );
        }
        else if ( ! parameters.empty() )
        {
            if ( ! AudioFeeder::post( context , parameters.c_str() , 15 ) )
            {
                g_info( "FAILED TO OPEN '%s'" , parameters.c_str() );
            }
        }
    }
};

//.............................................................................

class Fonts : public Handler
{
protected:

    static int font_family_sort_comparator( const void* elem1, const void* elem2 )
    {
        return strcmp( pango_font_family_get_name( *( PangoFontFamily** )elem1 ), pango_font_family_get_name( *( PangoFontFamily** )elem2 ) );
    }

    static int font_face_sort_comparator( const void* elem1, const void* elem2 )
    {
        return strcmp( pango_font_face_get_face_name( *( PangoFontFace** )elem1 ), pango_font_face_get_face_name( *( PangoFontFace** )elem2 ) );
    }

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        PangoFontMap* fontmap = clutter_get_font_map();
        int i;
        PangoFontFamily** families;
        int n_families;

        pango_font_map_list_families( fontmap, & families, & n_families );
        g_info( "%d KNOWN FONT FAMILIES:", n_families );
        qsort( families, n_families, sizeof( PangoFontFamily* ), font_family_sort_comparator );

        for ( i = 0; i < n_families; i++ )
        {
            PangoFontFamily* family = families[i];
            const char* family_name;
            int n_faces = 0;
            PangoFontFace** faces;

            family_name = pango_font_family_get_name( family );
            pango_font_family_list_faces( family, &faces, &n_faces );

            if ( n_faces > 0 )
            {
                qsort( faces, n_faces, sizeof( PangoFontFace* ), font_face_sort_comparator );
                GString* faces_string = g_string_new( pango_font_face_get_face_name( faces[0] ) );

                for ( int face = 1; face < n_faces; face++ )
                {
                    g_string_append_printf( faces_string, ", %s", pango_font_face_get_face_name( faces[face] ) );
                }

                g_info( "%32s HAS %2d FACES: (%s)", family_name, n_faces, faces_string->str );
                g_string_free( faces_string, TRUE );
            }

            g_free( faces );
        }

        g_free( families );
    }
};

//.............................................................................

class UI : public Handler
{
protected:

    struct DumpInfo
    {
        DumpInfo()
            :
            indent( 0 )
        {}

        guint indent;

        std::map< String, std::list<ClutterActor*> > actors_by_type;
    };

    static void dump_nineslice( ClutterActor* actor, guint indent, const gchar* type, const gchar* name, ClutterGeometry &g, String &details, String &extra )
    {
        if ( !actor ) return;

        String ns_detail;

        NineSliceBinding * nineslice = ( NineSliceBinding * ) g_object_get_data( G_OBJECT( actor ), "tp-binding" );

        SpriteSheet * sheet = nineslice->get_sheet();

        /* Add spritesheet uri */
        ns_detail = ( sheet && strlen( sheet->get_json_uri() ) > 0 )
                  ? String( " sheet = \"" )
                    + sheet->get_json_uri()
                    + String( "\"," )
                  : String( "]" );

        g_info( "%s%s%s%s:%s [%p]: (%d,%d %ux%u)%s%s [%s%s",
            CLUTTER_ACTOR_IS_VISIBLE( actor ) ? "" : SAFE_ANSI_COLOR_FG_WHITE,
            clutter_actor_has_key_focus( actor ) ? "> " : "  ",
            String( indent, ' ' ).c_str(),
            type,
            name ? String( String( " " ) + SAFE_ANSI_COLOR_FG_WHITE + String( name ) + ( CLUTTER_ACTOR_IS_VISIBLE( actor ) ? SAFE_ANSI_COLOR_RESET : SAFE_ANSI_COLOR_FG_WHITE ) + " : " ).c_str()  : " ",
            actor,
            g.x,
            g.y,
            g.width,
            g.height,
            details.empty() ? "" : details.c_str(),
            extra.empty() ? "" : extra.c_str(),
            ns_detail.c_str(),
            SAFE_ANSI_COLOR_RESET );

        if ( !sheet ) return;

        /* add 9 ids */

        gboolean all_empty = true;
        int last_nonempty = -1;
        for ( int i = 8; i >= 0 && all_empty; i-- )
        {
            if ( !nineslice->get_id(i).empty() )
            {
                all_empty = false;
                last_nonempty = i;
            }
        }

        if ( all_empty ) return;

        for ( int i = 0; i < 9; i++ )
        {
            if ( nineslice->get_id(i).empty() ) continue;

            ns_detail = String( indent + 4, ' ' ).c_str()
                      + String(keys[i])
                      + String( 3 - strlen( keys[i] ), ' ' ).c_str()
                      + "= \""
                      + nineslice->get_layout()->priv->slices[i].sprite->get_id()
                      + "\"";

            if ( i == last_nonempty )
            {
                g_info( "%s ]", ns_detail.c_str() );
            }
            else
            {
                g_info( "%s,", ns_detail.c_str() );
            }
        }
    }

    static void dump_actors( ClutterActor* actor, gpointer dump_info )
    {
        if ( !actor ) return;

        DumpInfo* info = ( DumpInfo* ) dump_info;

        ClutterGeometry g;

        gfloat x, y, width, height;
        clutter_actor_get_position( actor, &x, &y );
        clutter_actor_get_size( actor, &width, &height );
        g.x = x;
        g.y = y;
        g.width = width;
        g.height = height;

        const gchar* name = clutter_actor_get_name( actor );
        const gchar* type = ClutterUtil::get_actor_type( actor );

        info->actors_by_type[type].push_back( actor );

        // Get extra info about the actor

        String extra;

        if ( CLUTTER_IS_TEXT( actor ) )
        {
            extra = String( "[text='" ) + clutter_text_get_text( CLUTTER_TEXT( actor ) ) + "'";

            ClutterColor color;

            clutter_text_get_color( CLUTTER_TEXT( actor ), &color );

            gchar* c = g_strdup_printf( "color=(%u,%u,%u,%u)", color.red, color.green, color.blue, color.alpha );

            gchar* f = g_strdup_printf( "font=(%s)", clutter_text_get_font_name( CLUTTER_TEXT( actor ) ) );

            extra = extra + "," + c + "," + f + "]";

            g_free( c );
            g_free( f );

        }
        else if ( CLUTTER_IS_TEXTURE( actor ) )
        {
            const gchar* src = ( const gchar* )g_object_get_data( G_OBJECT( actor ) , "tp-src" );

            if ( src )
            {
                extra = String( "[src='" ) + src + "']";
            }
        }
        else if ( !g_strcmp0(type, "Rectangle") )
        {
            ClutterColor color, border_color;
            guint border_width;

            clutter_actor_get_background_color( clutter_container_find_child_by_name(CLUTTER_CONTAINER(actor), "inner"), &color );
            clutter_actor_get_background_color( clutter_container_find_child_by_name(CLUTTER_CONTAINER(actor), "top"), &border_color);
            border_width = clutter_actor_get_height(clutter_container_find_child_by_name(CLUTTER_CONTAINER(actor), "top"));

            gchar* c = g_strdup_printf( "[color=(%u,%u,%u,%u), border=%ux(%u,%u,%u,%u)]", color.red, color.green, color.blue, color.alpha,
                                                                                            border_width, border_color.red, border_color.green, border_color.blue, border_color.alpha );

            extra = c;

            g_free( c );
        }
        else if ( CLUTTER_IS_CLONE( actor ) )
        {
            ClutterActor* other = clutter_clone_get_source( CLUTTER_CLONE( actor ) );

            if ( other )
            {
                gchar* c = g_strdup_printf( "[source=%p]" , other );

                extra = c;

                g_free( c );
            }
        }

        String details;

        gdouble sx;
        gdouble sy;

        clutter_actor_get_scale( actor, &sx, &sy );

        if ( sx != 1 || sy != 1 )
        {
            gchar* c = g_strdup_printf( " scale(%1.2f,%1.2f)", sx, sy );

            details = c;

            g_free( c );
        }

        gfloat ax;
        gfloat ay;

        clutter_actor_get_anchor_point( actor, &ax, &ay );

        if ( ax != 0 || ay != 0 )
        {
            gchar* c = g_strdup_printf( " anchor(%1.0f,%1.0f)", ax, ay );

            details += c;

            g_free( c );
        }

        guint8 o = clutter_actor_get_opacity( actor );

        if ( o < 255 )
        {
            gchar* c = g_strdup_printf( "  opacity(%u)" , o );
            details += c;
            g_free( c );
        }

        if ( !extra.empty() )
        {
            extra = String( " : " ) + extra;
        }

        if ( !CLUTTER_ACTOR_IS_VISIBLE( actor ) )
        {
            details += " HIDDEN";
        }

        /* Detailed information for Nineslice. Skip information about children
         */
        if ( g_strcmp0(type, "Nineslice") )
        {
            g_info( "%s%s%s%s:%s [%p]: (%d,%d %ux%u)%s%s%s",
                CLUTTER_ACTOR_IS_VISIBLE( actor ) ? "" : SAFE_ANSI_COLOR_FG_WHITE,
                clutter_actor_has_key_focus( actor ) ? "> " : "  ",
                String( info->indent, ' ' ).c_str(),
                type,
                name ? String( String( " " ) + SAFE_ANSI_COLOR_FG_YELLOW + String( name ) + ( CLUTTER_ACTOR_IS_VISIBLE( actor ) ? SAFE_ANSI_COLOR_RESET : SAFE_ANSI_COLOR_FG_WHITE ) + " : " ).c_str()  : " ",
                    actor,
                    g.x,
                    g.y,
                    g.width,
                    g.height,
                    details.empty() ? "" : details.c_str(),
                    extra.empty() ? "" : extra.c_str(),
                    SAFE_ANSI_COLOR_RESET );
        }
        else
        {
            dump_nineslice( actor, info->indent, type, name, g, details, extra );
        }

        if ( CLUTTER_IS_CONTAINER( actor ) &&
              g_strcmp0(type, "Nineslice") && // Ignore these types and do not recurse into them
              g_strcmp0(type, "Rectangle"))
        {
            info->indent += 2;
            ClutterActorIter iter;
            ClutterActor* child;
            clutter_actor_iter_init( &iter, actor );

            while ( clutter_actor_iter_next( &iter, &child ) )
            {
                dump_actors( child, info );
            }

            info->indent -= 2;
        }
    }

    static ClutterActor* check_children( ClutterActor* parent, ClutterActor* child )
    {
        ClutterActorIter iter;
        ClutterActor* check;
        clutter_actor_iter_init( &iter, parent );

        while ( clutter_actor_iter_next( &iter, &check ) )
        {
            // Check if this one matches, or it contains child
            if ( check == child || check_children( check, child ) == child )
            {
                return child;
            }
        }

        // If nothing matched above, then return NULL
        return NULL;
    }

    static ClutterActor* validate_pointer( ClutterActor* first, const gchar* pointer_str )
    {
        // Convert string to a pointer; next we NEED to validate that this pointer is indeed an actor
        ClutterActor* actor = check_children( first, ( ClutterActor* ) g_ascii_strtoull( pointer_str, NULL, 16 ) );

        // Can't use clutter_actor_contains because it will call CLUTTER_IS_ACTOR which will
        // attempt to de-ref actor, which could explode.  We have to walk the list manually.
        if ( actor )
        {
            return actor;
        }

        return NULL;
    }

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        DumpInfo info;

        ClutterActor* first = context->get_stage();

        if ( ! parameters.empty() )
        {
            first = clutter_container_find_child_by_name( CLUTTER_CONTAINER( first ) , parameters.c_str() );

            if ( ! first )
            {
                first = validate_pointer( context->get_stage(), parameters.c_str() );
            }
        }

        if ( ! first )
        {
            g_info( "NO SUCH ACTOR" );
        }
        else
        {
            dump_actors( first, & info );

            g_info( "" );
            g_info( "SUMMARY" );

            std::map< String, std::list< ClutterActor* > >::const_iterator it;

            for ( it = info.actors_by_type.begin(); it != info.actors_by_type.end(); ++it )
            {
                g_info( "%15s %5u", it->first.c_str(), it->second.size() );
            }
        }
    }
};

//.............................................................................

class Profile : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        if ( parameters.empty() )
        {
            SystemDatabase::Profile p = context->get_db()->get_current_profile();

            g_info( "%d '%s' '%s'", p.id, p.name.c_str(), p.pin.c_str() );

            return;
        }

        StringVector parts = split_string( parameters , " " , 2 );

        guint count = parts.size();

        if ( count == 2 && parts[0] == "new" )
        {
            int id = context->get_db()->create_profile( parts[1] , "" );

            g_info( "CREATED PROFILE %d", id );
        }
        else if ( count == 2 && parts[0] == "switch" )
        {
            int id = atoi( parts[1].c_str() );

            if ( context->profile_switch( id ) )
            {
                g_info( "SWITCHED TO PROFILE %d", id );
            }
            else
            {
                g_info( "NO SUCH PROFILE" );
            }
        }
        else
        {
            g_info( "USAGE: '/profile new <name>' OR '/profile switch <id>'" );
        }
    }
};

//.............................................................................

class Globals : public Handler
{
protected:

    virtual void operator()( TPContext* context , const String& command , const String& parameters )
    {
        App* app = context->get_current_app();

        if ( ! app )
        {
            return;
        }

        lua_State* L = app->get_lua_state();

        if ( ! L )
        {
            return;
        }

        const StringMap& globals( app->get_globals() );

        lua_rawgeti( L , LUA_REGISTRYINDEX , LUA_RIDX_GLOBALS );
        int g = lua_gettop( L );

        for ( StringMap::const_iterator it = globals.begin(); it != globals.end(); ++it )
        {
            lua_pushstring( L , it->first.c_str() );
            lua_rawget( L , g );

            if ( ! lua_isnil( L , -1 ) )
            {
                g_info( "%s (%s) = %s [%s]" , it->first.c_str() , lua_typename( L , lua_type( L , -1 ) ) , Util::describe_lua_value( L , -1 ).c_str() , it->second.c_str() );
            }

            lua_pop( L , 1 );
        }

        lua_pop( L , 1 );
    }
};

//=============================================================================

class Handlers
{
public:

    Handlers( TPContext* _context )
        :
        context( _context )
    {

#define H( a , b ) list.push_back( HandlerPair( a , new ConsoleCommands::b ) )

        H( "exit"   , Exit );
        H( "quit"   , Exit );
        H( "bye"    , Exit );
        H( "config" , Config );
        H( "reload" , Reload );
        H( "close"  , Close );
        H( "gc"     , GC );
        H( "obj"    , Obj );
        H( "ver"    , Versions );
        H( "images" , Images );
        H( "cache"  , Cache );
        H( "mem"    , Mem );
        H( "prof"   , Prof );
        H( "ss"     , Screenshot );
        H( "as"     , AudioSampling );
        H( "fonts"  , Fonts );
        H( "ui"     , UI );
        H( "profile", Profile );
        H( "globals", Globals );

#undef H

        for ( HandlerList::iterator it = list.begin(); it != list.end(); ++it )
        {
            context->add_console_command_handler( it->first.c_str() , Handler::handle_command , it->second );
        }
    }

    static void destroy( gpointer handlers )
    {
        delete( Handlers* ) handlers;
    }

private:

    Handlers()
    {}

    Handlers( const Handlers& )
    {}

    virtual ~Handlers()
    {
        for ( HandlerList::iterator it = list.begin(); it != list.end(); ++it )
        {
            // We don't really need to remove them because the context is already being destroyed

            delete it->second;
        }
    }

    TPContext* context;

    typedef std::pair< String , Handler* > HandlerPair;
    typedef std::list< HandlerPair > HandlerList;

    HandlerList list;
};

#endif // TP_PRODUCTION

//=============================================================================

void add_all( TPContext* context )
{
#ifndef TP_PRODUCTION

    static char key = 0;

    context->add_internal( & key , new Handlers( context ) , Handlers::destroy );

#endif
}

}
