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

#include "nineslice.h"

static void
circle_paint_cb (ClutterActor *actor)
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

static SpriteSheet* spritesheet_new(CoglHandle *texture, gint x[], gint y[], gint w[], gint h[], gint n, gint filter) {
  SpriteSheet *sheet = malloc(sizeof(SpriteSheet));
  sheet->material = calloc(n, sizeof(CoglMaterial *));
  sheet->texture = calloc(n, sizeof(CoglHandle *));
  sheet->w = calloc(n, sizeof(gint));
  sheet->h = calloc(n, sizeof(gint));
  sheet->n = n;
  
  ClutterTextureQuality cf = (filter == 1 ? CLUTTER_TEXTURE_QUALITY_LOW : CLUTTER_TEXTURE_QUALITY_MEDIUM);

  gint i;
  for (i = 0; i < n; i++) {
    // don't know why routing through an actor is necessary
    //*
    sheet->texture[i] = cogl_texture_new_from_sub_texture(texture, x[i], y[i], w[i], h[i]);
    ClutterActor *tex = clutter_texture_new();
    clutter_texture_set_cogl_texture(CLUTTER_TEXTURE(tex), sheet->texture[i]);
    clutter_texture_set_repeat(CLUTTER_TEXTURE(tex), TRUE, TRUE);
    clutter_texture_set_filter_quality(CLUTTER_TEXTURE(tex), cf);
    sheet->material[i] = COGL_MATERIAL(clutter_texture_get_cogl_material(CLUTTER_TEXTURE(tex)));
    //*/
    /*
    sheet->material[i] = cogl_material_new();
    sheet->texture[i] = cogl_texture_new_from_sub_texture(texture, x[i], y[i], w[i], h[i]);
    cogl_material_set_layer(sheet->material[i], 0, sheet->texture[i]);
    cogl_material_set_layer_filters(sheet->material[i], 0, cf, cf);
    cogl_material_set_layer_wrap_mode(sheet->material[i], 0, COGL_MATERIAL_WRAP_MODE_REPEAT  );
    //*/
    sheet->w[i] = w[i];
    sheet->h[i] = h[i];
  }
  
  return sheet;
}

static void spritesheet_free(SpriteSheet *sheet)
{
  free(sheet->h);
  free(sheet->w);
  gint i;
  for(i=0; i < sheet->n; i++)
  {
    g_free(sheet->texture[i]);
    g_free(sheet->material[i]);
  }
  free(sheet->texture);
  free(sheet->material);
}

int
main (int argc, char **argv)
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
  
  /*
  gchar *source[] = {"slice-00.png", "slice-10.png", "slice-20.png",
                     "slice-01.png", "slice-11.png", "slice-21.png",
                     "slice-02.png", "slice-12.png", "slice-22.png"};
  //*/
  
  //gint width = 48, height = 48, left = 16, right = 16, top = 16, bottom = 16;
  //*
  gint xs[] = {16, 32, 48, 64}; //left, width-right, width};
  gint ys[] = {16, 32, 48, 64}; // top, height-bottom, bottom};
  gint x[9], y[9], w[9], h[9], j, k;
  for (i = 0; i < 3; i++) {
    for (j = 0; j < 3; j++) {
      k = i*3 + j;
      x[k] = xs[j];
      y[k] = ys[i];
      w[k] = xs[j+1] - xs[j];
      h[k] = ys[i+1] - ys[i];
    }
  }
  
  CoglHandle *texture = clutter_texture_get_cogl_texture(
      CLUTTER_TEXTURE(clutter_texture_new_from_file("spritesheet.png", NULL)) );
  SpriteSheet *sheet = spritesheet_new(texture, x, y, w, h, 9, 0);
  //*/
  ClutterActor *actor2 = clutter_group_new();
  clutter_container_add_actor (CLUTTER_CONTAINER (stage), actor2);
  clutter_actor_set_position(actor2, 10, 10);
  
  //ClutterEffect *effect2 = nineslice_effect_new_from_source(source, TRUE);
  ClutterEffect *effect2 = nineslice_effect_new_from_spritesheet(sheet, 0, TRUE);
  clutter_actor_add_effect(actor2, effect2);
  
  ClutterActor *actor = clutter_group_new();
  clutter_container_add_actor (CLUTTER_CONTAINER (actor2), actor);
  
  //ClutterEffect *effect = nineslice_effect_new_from_source(source, TRUE);
  ClutterEffect *effect = nineslice_effect_new_from_spritesheet(sheet, 0, TRUE);
  clutter_actor_add_effect(actor, effect);
  
  ClutterActor *text = clutter_text_new_with_text("Sans 40px","Example Text");
  clutter_actor_set_position(text, 0, 0);
  clutter_container_add_actor (CLUTTER_CONTAINER (actor), text);
  
  ClutterActor *rect = clutter_rectangle_new();
  clutter_actor_set_position(rect, 10, 100);
  clutter_actor_set_size(rect, 50, 50);
  clutter_container_add_actor (CLUTTER_CONTAINER (actor), rect);
  
  clutter_actor_set_position(actor, 200, 100);
  //clutter_actor_set_rotation(actor, CLUTTER_Z_AXIS, 30.0, 130, 50, 0);
  
  /*
  GValue cvalue = G_VALUE_INIT;
  g_value_init(&cvalue, CLUTTER_TYPE_ACTOR_BOX);
  g_value_set_boxed(&cvalue, clutter_actor_box_new(0.0, 0.0, 0.0, 0.0));
  
  GValue ovalue = G_VALUE_INIT;
  g_value_init(&ovalue, CLUTTER_TYPE_ACTOR_BOX);
  g_value_set_boxed(&ovalue, clutter_actor_box_new(50.0, 50.0, 50.0, 50.0));
  
  ClutterState *transition = clutter_state_new();
  clutter_state_set_duration(transition, NULL, NULL, 5000);
  clutter_state_set_key (transition, NULL, "close", G_OBJECT(effect), "padding", CLUTTER_LINEAR, &cvalue, 0.0, 0.0);
  clutter_state_set_key (transition, NULL, "open",  G_OBJECT(effect), "padding", CLUTTER_LINEAR, &ovalue, 0.0, 0.0);
  
  //clutter_state_set(transition, NULL, "close", effect, "padding_right", CLUTTER_LINEAR,  0.0, NULL);
  //clutter_state_set(transition, NULL, "open",  effect, "padding_right", CLUTTER_LINEAR, 50.0, NULL);
  
  clutter_state_warp_to_state(transition, "close");
  clutter_state_set_state(transition, "open");
  */
  
  clutter_actor_animate(rect, CLUTTER_LINEAR, 5000, "height", 200.0, NULL);
  
  clutter_actor_show_all (stage);
  
  clutter_timeline_start (timeline);
  
  clutter_main ();

  //spritesheet_free(sheet);
  
  return 0;
}
