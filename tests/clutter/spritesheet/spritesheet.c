#include "spritesheet.h"

SpriteSheet* spritesheet_new(CoglHandle *texture, gchar* names[], gint data[], gint n, gint filter) {
  SpriteSheet *sheet = malloc(sizeof(SpriteSheet));
  sheet->map = g_hash_table_new(g_str_hash, g_str_equal);
  sheet->material = calloc(n, sizeof(CoglMaterial *));
  sheet->texture = calloc(n, sizeof(CoglHandle *));
  sheet->w = calloc(n, sizeof(gint));
  sheet->h = calloc(n, sizeof(gint));
  sheet->n = n;

  gint i;
  for (i = 0; i < n; i++) {
    g_hash_table_insert(sheet->map, names[i], GINT_TO_POINTER(i+1));
    
    // don't know why routing through an actor fixes tiling
    sheet->texture[i] = cogl_texture_new_from_sub_texture(texture, data[i*4], data[i*4+1], data[i*4+2], data[i*4+3]);
    ClutterActor *tex = clutter_texture_new();
    clutter_texture_set_cogl_texture(CLUTTER_TEXTURE(tex), sheet->texture[i]);
    clutter_texture_set_repeat(CLUTTER_TEXTURE(tex), TRUE, TRUE);
    clutter_texture_set_filter_quality(CLUTTER_TEXTURE(tex), 
        filter == 1 ? CLUTTER_TEXTURE_QUALITY_LOW : CLUTTER_TEXTURE_QUALITY_MEDIUM);
    
    sheet->material[i] = COGL_MATERIAL(clutter_texture_get_cogl_material(CLUTTER_TEXTURE(tex)));
    sheet->w[i] = data[i*4+2];
    sheet->h[i] = data[i*4+3];
  }
  
  return sheet;
}

void spritesheet_get_sprite(SpriteSheet *sheet, gchar *name, CoglMaterial **material, CoglHandle **texture, gint *w, gint *h) {
  gpointer p = g_hash_table_lookup(sheet->map, name);
  if (p != NULL) {
    gint i = GPOINTER_TO_INT(p) - 1;
    if (material != NULL) *material = sheet->material[i];
    if (texture != NULL) *texture = sheet->texture[i];
    if (w != NULL) *w = sheet->w[i];
    if (h != NULL) *h = sheet->h[i];
  }
}

void spritesheet_free(SpriteSheet *sheet) {
  free(sheet->h);
  free(sheet->w);
  gint i;
  for(i=0; i < sheet->n; i++)
  {
    cogl_handle_unref(sheet->texture[i]);
    cogl_handle_unref(sheet->material[i]);
  }
  free(sheet->texture);
  free(sheet->material);
  g_hash_table_destroy(sheet->map);
  free(sheet);
}