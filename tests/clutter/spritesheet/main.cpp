#define CLUTTER_DISABLE_DEPRECATION_WARNINGS
#include <clutter/clutter.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define N_CIRCLES 3     /* number of circles */
#define CIRCLE_W 128    /* width */
#define CIRCLE_G 32     /* gap */
#define CIRCLE_S 3      /* segments */
#define SCREEN_W 640
#define SCREEN_H 480

#ifndef CLUTTER_ANGLE_FROM_RAD
#define CLUTTER_ANGLE_FROM_RAD(x) ((x) * 180.0 / G_PI)
#endif

#include "spritesheet.cpp.h"
#include "nineslice.cpp.h"

static void circle_paint_cb (ClutterActor *actor)
{
  const CoglColor fill_color = { 0xff, 0xff, 0xff, 0x80 };
  gint i;
  gdouble angle;
  guint radius = clutter_actor_get_width (actor) / 2;

  cogl_set_source_color (&fill_color);

  angle = *((gdouble *)g_object_get_data (G_OBJECT (actor), "angle"));
  for (i = 0; i < CIRCLE_S; i++, angle += (2.0 * G_PI) / (gdouble) CIRCLE_S)
    {
      gdouble angle2 = angle + ((2.0 * G_PI) / (gdouble)CIRCLE_S) / 2.0;
      cogl_path_move_to (((radius - CIRCLE_W) * cos (angle)) + radius,
                         ((radius - CIRCLE_W) * sin (angle)) + radius);
      cogl_path_arc (radius, radius, radius, radius,
                     CLUTTER_ANGLE_FROM_RAD (angle),
                     CLUTTER_ANGLE_FROM_RAD (angle2));
      cogl_path_line_to (((radius - CIRCLE_W) * cos (angle2)) + radius,
                         ((radius - CIRCLE_W) * sin (angle2)) + radius);
      cogl_path_arc (radius, radius, radius - CIRCLE_W, radius - CIRCLE_W,
                     CLUTTER_ANGLE_FROM_RAD (angle2),
                     CLUTTER_ANGLE_FROM_RAD (angle));
      cogl_path_close ();
      cogl_path_fill ();
    }
};

int main (int argc, char **argv)
{
  const ClutterColor transp = { 0x00, 0x00, 0x00, 0x00 };
  const ClutterColor bg_color = { 0xe0, 0xf2, 0xfc, 0xff };
  ClutterTimeline *timeline;
  ClutterActor *stage;
  gint i;

  if (clutter_init (&argc, &argv) != CLUTTER_INIT_SUCCESS)
    return 1;

  stage = clutter_stage_new ();
  clutter_stage_set_title (CLUTTER_STAGE (stage), "SpriteSheet");
  clutter_stage_set_color (CLUTTER_STAGE (stage), &bg_color);
  clutter_actor_set_size (stage, SCREEN_W, SCREEN_H);
  g_signal_connect (stage, "destroy", G_CALLBACK (clutter_main_quit), NULL);

  timeline = clutter_timeline_new (5000);
  clutter_timeline_set_loop (timeline, TRUE);
  for (i = 0; i < N_CIRCLES; i++)
    {
      gint size;
      gdouble *angle;
      ClutterActor *actor;
      ClutterAlpha *alpha;
      ClutterBehaviour *behaviour;
      
      actor = clutter_rectangle_new_with_color (&transp);
      
      size = (i + 1) * (CIRCLE_W + CIRCLE_G) * 2;
      clutter_actor_set_size (actor, size, size);
      clutter_actor_set_position (actor,
                                  SCREEN_W - size / 2.0,
                                  SCREEN_H - size / 2.0);
      
      clutter_container_add_actor (CLUTTER_CONTAINER (stage), actor);
      
      angle = g_slice_new (gdouble);
      *angle = g_random_double_range (0.0, 90.0);
      g_object_set_data (G_OBJECT (actor), "angle", angle);
      g_signal_connect (actor, "paint", G_CALLBACK (circle_paint_cb), NULL);
      
      /* Animate */
      alpha = clutter_alpha_new_full (timeline, CLUTTER_LINEAR);
      behaviour = clutter_behaviour_rotate_new (alpha, CLUTTER_Z_AXIS,
                                                (i % 2) ? CLUTTER_ROTATE_CW
                                                        : CLUTTER_ROTATE_CCW,
                                                0.0, 0.0);
      clutter_behaviour_rotate_set_center (CLUTTER_BEHAVIOUR_ROTATE (behaviour),
                                           size / 2,
                                           size / 2,
                                           0);
      clutter_behaviour_apply (behaviour, actor);
    }
  
  const gchar *ids[] = {"slice-00.png", "slice-10.png", "slice-20.png",
                        "slice-01.png", "slice-11.png", "slice-21.png",
                        "slice-02.png", "slice-12.png", "slice-22.png"};
  
  gint xs[] = {16, 32, 48, 64};
  gint ys[] = {16, 32, 48, 64};
  gint data[9 * 4], j, k;
  for (i = 0; i < 3; i++) {
    for (j = 0; j < 3; j++) {
      k = (i*3 + j) * 4;
      data[k+0] = xs[j];
      data[k+1] = ys[i];
      data[k+2] = xs[j+1] - xs[j];
      data[k+3] = ys[i+1] - ys[i];
    }
  }
  
  ClutterActor *actor3 = clutter_texture_new_from_file("spritesheet.png", NULL);
  CoglHandle texture = clutter_texture_get_cogl_texture( CLUTTER_TEXTURE( actor3 ) );
  SpriteSheet *sheet = new SpriteSheet(texture, ids, data, 9, SPRITESHEET_NONE); 
  
  ClutterActor *actor2 = clutter_group_new();
  clutter_container_add_actor (CLUTTER_CONTAINER (stage), actor2);
  clutter_actor_set_position(actor2, 10, 10);
  
  ClutterEffect *effect2 = nineslice_effect_new_from_ids(ids, sheet, TRUE);
  
  SpriteSheet *sheet2 = new SpriteSheet(texture, ids, data, 9, SPRITESHEET_NONE); 
  nineslice_effect_set_sheet( NINESLICE_EFFECT(effect2), sheet2 );
  
  clutter_actor_add_effect(actor2, effect2);
  
  fprintf(stderr, "tile: %i\n", nineslice_effect_get_tile(NINESLICE_EFFECT(effect2)));
  
  nineslice_effect_set_tile( NINESLICE_EFFECT(effect2), FALSE );
  
  int * array = (int *) malloc( sizeof( int ) * 4 );
  nineslice_effect_get_borders( NINESLICE_EFFECT(effect2), array );
  for (i = 0; i < 4; i++)
    fprintf(stderr, "border %i: %i\n", i, array[i]);
    
  fprintf(stderr, "tile: %i\n", nineslice_effect_get_tile(NINESLICE_EFFECT(effect2)));
  
  ClutterActor *actor = clutter_group_new();
  clutter_container_add_actor (CLUTTER_CONTAINER (actor2), actor);
  clutter_actor_set_position(actor, 200, 100);
  
  ClutterEffect *effect = nineslice_effect_new_from_ids(ids, sheet, TRUE);
  clutter_actor_add_effect(actor, effect);
  
  ClutterActor *text = clutter_text_new_with_text("Sans 40px","Example Text");
  clutter_actor_set_position(text, 0, 0);
  clutter_container_add_actor (CLUTTER_CONTAINER (actor), text);
  
  ClutterActor *rect = clutter_rectangle_new();
  clutter_actor_set_position(rect, 10, 100);
  clutter_actor_set_size(rect, 50, 50);
  clutter_container_add_actor (CLUTTER_CONTAINER (actor), rect);
  
  clutter_actor_animate(rect, CLUTTER_LINEAR, 5000, "height", 200.0, NULL);
  
  clutter_actor_show_all (stage);
  clutter_timeline_start (timeline);
  clutter_main ();

  delete sheet;
  
  return 0;
}
