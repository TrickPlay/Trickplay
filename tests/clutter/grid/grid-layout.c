/*
 * Copyright 2012 Bastian Winkler <buz@netbuz.org>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU Lesser General Public License,
 * version 2.1, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
 * more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 * Boston, MA 02111-1307, USA.
 *
 */
#include <stdlib.h>
#include <clutter/clutter.h>


static void
add_actor (ClutterActor *box,
           gint          left,
           gint          top,
           gint          width,
           gint          height, gint width2, gint height2)
{
  ClutterActor *rect;
  ClutterColor color;
  ClutterLayoutManager *layout;

  clutter_color_from_hls (&color,
                          g_random_double_range (0.0, 360.0),
                          0.5,
                          0.5);
  color.alpha = 255;

  rect = clutter_actor_new ();
  clutter_actor_set_background_color (rect, &color);

  clutter_actor_set_size (rect, width2, height2);

  clutter_actor_set_x_expand (rect, FALSE);
  clutter_actor_set_y_expand (rect, TRUE);

  clutter_actor_set_x_align (rect, CLUTTER_ACTOR_ALIGN_CENTER);
  clutter_actor_set_y_align (rect, CLUTTER_ACTOR_ALIGN_CENTER);

  //clutter_actor_add_child (box, rect);
  clutter_grid_layout_attach (
                CLUTTER_GRID_LAYOUT (
                    clutter_actor_get_layout_manager (box)
                ),
                rect,left, top, 1, 1
            );
  g_warning("CLUTTER ACTOR SIZE: %f,%f", clutter_actor_get_width(rect), clutter_actor_get_height(rect));
}

static gboolean
key_release_cb (ClutterActor *stage,
                ClutterEvent *event,
                ClutterActor *grid)
{
    g_warning("CLUTTER ACTOR SIZE: %f, %f", clutter_actor_get_width(clutter_actor_get_first_child(grid)), clutter_actor_get_height(clutter_actor_get_first_child(grid)));
    return TRUE;
}

int
main (int argc, char *argv[])
{
  ClutterActor *stage, *box, *instructions;
  ClutterLayoutManager *stage_layout, *grid_layout;
  GError *error = NULL;

  if (clutter_init (&argc, &argv) != CLUTTER_INIT_SUCCESS)
    {
      g_print ("Unable to run grid-layout: %s", error->message);
      g_error_free (error);

      return EXIT_FAILURE;
    }

  stage = clutter_stage_new ();

  ClutterActor *the_grid = clutter_actor_new();
  clutter_actor_add_child(stage, the_grid);

  clutter_stage_set_user_resizable (CLUTTER_STAGE (stage), TRUE);
  grid_layout = clutter_grid_layout_new ();
  clutter_actor_set_layout_manager (the_grid, grid_layout);
  clutter_grid_layout_set_row_homogeneous(CLUTTER_GRID_LAYOUT(grid_layout), FALSE);
  clutter_grid_layout_set_column_homogeneous(CLUTTER_GRID_LAYOUT(grid_layout), FALSE);

  add_actor (the_grid, 1, 4, 1, 1, 100,300);//-1, 4);
  //add_actor (box, 0, 1, 1, 1, 4, -1);
  //add_actor (box, 1, 1, 1, 1, -1, -1);
  //add_actor (box, 2, 1, 1, 1, 4, -1);
  //add_actor (box, 0, 2, 3, 1, -1, 4);

  g_signal_connect (stage, "destroy",
                    G_CALLBACK (clutter_main_quit), NULL);

  g_signal_connect (stage, "key-release-event",
                    G_CALLBACK (key_release_cb), the_grid);


  clutter_actor_show (stage);

  clutter_main ();

  return 0;
}
