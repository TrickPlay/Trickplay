#include "spritesheet.cpp.h"

//SpriteSheet::SpriteSheet(gint w, gint h, const guchar *pixels, gchar **names, gint *data, gint n, SpriteSheetFlags flags) {
SpriteSheet::SpriteSheet(CoglHandle btex, const gchar **names, gint *data, gint n, SpriteSheetFlags flags) {
  map = g_hash_table_new(g_str_hash, g_str_equal);
  material = (CoglMaterial **) calloc(n, sizeof(CoglMaterial *));
  texture = (CoglHandle*) calloc(n, sizeof(CoglHandle));
  width = (gint*) calloc(n, sizeof(gint));
  height = (gint*) calloc(n, sizeof(gint));
  num_sprites = n;
  
  gint i;
  for (i = 0; i < n; i++) {
    if (names[i] != NULL) {
      //if (data[i*4] < 0 || data[i*4+1] < 0 || w < data[i*4] + data[i*4+2] || h < data[i*4+1] + data[i*4+3]) {
        // error condition, data parameters not within bounds
      //}
      
      g_hash_table_insert(map, (void*) names[i], GINT_TO_POINTER(i+1));
      // don't know why routing through an actor fixes tiling
      texture[i] = cogl_texture_new_from_sub_texture((CoglTexture *) btex, data[i*4], data[i*4+1], data[i*4+2], data[i*4+3]);
      ClutterActor *tex = clutter_texture_new();
      clutter_texture_set_cogl_texture(CLUTTER_TEXTURE(tex), texture[i]);
      clutter_texture_set_repeat(CLUTTER_TEXTURE(tex), TRUE, TRUE);
      clutter_texture_set_filter_quality(CLUTTER_TEXTURE(tex), 
          flags & SPRITESHEET_NEAREST ? CLUTTER_TEXTURE_QUALITY_LOW : CLUTTER_TEXTURE_QUALITY_MEDIUM);
      
      material[i] = COGL_MATERIAL(clutter_texture_get_cogl_material(CLUTTER_TEXTURE(tex)));
      width[i] = data[i*4+2];
      height[i] = data[i*4+3];
    } else {
      material[i] = NULL;
      texture[i] = NULL;
      width[i] = 0;
      height[i] = 0;
    }
  }
}

CoglHandle SpriteSheet::get_subtexture( const gchar * id )
{
  gpointer p = g_hash_table_lookup( map, id );
  if ( p != NULL )
    return texture[ GPOINTER_TO_INT(p) - 1 ];
  else
		return NULL;
}

SpriteSheet::~SpriteSheet() {
  free(height);
  free(width);
  gint i;
  for(i=0; i < num_sprites; i++)
  {
    cogl_handle_unref(texture[i]);
    cogl_handle_unref(material[i]);
  }
  free(texture);
  free(material);
  g_hash_table_destroy(map);
}

void SpriteSheet::get_sprite(const gchar *name, CoglMaterial **m, CoglHandle *t, gint *w, gint *h) {
  gpointer p = g_hash_table_lookup(map, name);
  if (p != NULL) {
    gint i = GPOINTER_TO_INT(p) - 1;
    if (m != NULL) *m = material[i];
    if (t != NULL) *t = texture[i];
    if (w != NULL) *w = width[i];
    if (h != NULL) *h = height[i];
  } else {
    // error condition, sprite not found
  }
}