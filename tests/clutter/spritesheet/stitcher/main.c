#define CLUTTER_DISABLE_DEPRECATION_WARNINGS
#include <clutter/clutter.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int coveredArea = 0;
char *basepath;

//ClutterActor *sheet, *bgrect, *bestrect;
int bottom_edge, right_edge, min_width = 0, best_width = 0, best_area = 0;

GSequence *sortArea;
GHashTable *sameWidth, *sameHeight;

typedef struct Item {
  int x, y, w, h, area;
  char *path;
  //ClutterActor *rect, *group, *image;
} Item;

Item* item_new(char *path) {
  Item *item = malloc(sizeof(Item));
  item->path = path;
  
  //const ClutterColor c = { rand() % 127 + 128, rand() % 127 + 128, rand() % 127 + 128, 255 };
  //item->group = clutter_group_new();
  //item->rect = clutter_rectangle_new_with_color(&c);
  GString *str = g_string_new(basepath);
  g_string_append(str, "/");
  g_string_append(str, path);
  //item->image = clutter_texture_new_from_file(str->str, NULL);
  ClutterActor *img = clutter_texture_new_from_file(str->str, NULL);
  if (img == NULL) {
	fprintf(stderr, "failed to load %s\n", str->str);
  } else {
	//fprintf(stderr, "loaded %s\n", str->str);
  }
  
  //clutter_container_add_actor(CLUTTER_CONTAINER(item->group), item->rect);
  //clutter_container_add_actor(CLUTTER_CONTAINER(item->group), item->image);
  //g_object_ref(item->group);
  
  gfloat w, h;
  clutter_actor_get_size(img, &w, &h);
  clutter_actor_destroy(img);
  //clutter_actor_set_size(item->rect, w, h);
  item->x = 0;
  item->y = 0;
  item->w = (int) w + 2;
  item->h = (int) h + 2;
  item->area = item->w * item->h;
  coveredArea += item->area;
  min_width = MAX(min_width, item->w);
  
  return item;
}

void item_free(Item *item) {
  //clutter_actor_destroy(item->rect);
  //clutter_actor_destroy(item->image);
  //clutter_actor_destroy(item->group);
  free(item);
}

gint item_compare_area(gconstpointer a, gconstpointer b, gpointer user_data) {
  Item *aa = (Item*) a;
  Item *bb = (Item*) b;
  return MAX(bb->w, bb->h) - MAX(aa->w, aa->h);
}

int array_n = 0;
GFile *base;
GSequence *items;

void gather(GFile *file) {
  GFileInfo *info = g_file_query_info(file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL);
  GFileType type = g_file_info_get_file_type(info);
  if (type == G_FILE_TYPE_REGULAR) {
	if (file == base) {
	  fprintf(stderr,"error!");
	} else {
	  g_sequence_insert_sorted(items, item_new(g_file_get_relative_path(base,file)), item_compare_area, NULL);
	}
  } else if (type == G_FILE_TYPE_DIRECTORY) {
	GFileEnumerator *children = g_file_enumerate_children(file ,"standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL);
	GFileInfo *childinfo;
	GFile *child;
	while ((childinfo = g_file_enumerator_next_file(children, NULL, NULL)) != NULL) {
	  child = g_file_get_child(file, g_file_info_get_name(childinfo));
	  gather(child);
	}
	g_file_enumerator_close(children, NULL, NULL);
  }
}

GSequence* hash_get(GHashTable *map, int key) {
  gpointer k = GINT_TO_POINTER(key+1);
  GSequence *s = g_hash_table_lookup(map, k);
  if (s == NULL) {
	s = g_sequence_new(NULL);
	g_hash_table_insert(map, k, s);
  }
  return s;
}

typedef struct Leaf {
  int x, y, w, h, area;
} Leaf;

gint leaf_compare_area(gconstpointer a, gconstpointer b, gpointer user_data) {
  return ((Leaf*) a)->area - ((Leaf*) b)->area;
}
gint leaf_compare_width(gconstpointer a, gconstpointer b, gpointer user_data) {
  return ((Leaf*) a)->w - ((Leaf*) b)->w;
}
gint leaf_compare_height(gconstpointer a, gconstpointer b, gpointer user_data) {
  return ((Leaf*) a)->h - ((Leaf*) b)->h;
}

GSequenceIter * g_sequence_lookup_exact(GSequence *seq, Leaf *leaf, GCompareDataFunc func) {
  GSequenceIter *sj, *si = g_sequence_lookup(seq, leaf, func, NULL);
  if (si != NULL) {
	Leaf *found;
	sj = si;
	while (!g_sequence_iter_is_end(sj)) {
	  found = g_sequence_get(sj);
	  if (found == leaf)
		return sj;
	  else if (func(found, leaf, NULL) != 0)
		break;
	  sj = g_sequence_iter_next(sj);
	}
	
	sj = si;
	while (!g_sequence_iter_is_begin(sj)) {
	  sj = g_sequence_iter_prev(sj);
	  found = g_sequence_get(sj);
	  if (found == leaf)
		return sj;
	  else if (func(found, leaf, NULL) != 0)
		break;
	}
  }
  return NULL;
}

Leaf* leaf_new(int x, int y, int w, int h) {
  Leaf *leaf = malloc(sizeof(Leaf));
  leaf->x = x;
  leaf->y = y;
  leaf->w = w;
  leaf->h = h;
  leaf->area = w * h;
  
  g_sequence_insert_sorted(sortArea, leaf, leaf_compare_area, NULL);
  g_sequence_insert_sorted(hash_get(sameWidth,leaf->w), leaf, leaf_compare_height, NULL);
  g_sequence_insert_sorted(hash_get(sameHeight,leaf->h), leaf, leaf_compare_width, NULL);
  
  return leaf;
}

void leaf_drop(Leaf *leaf) {
  g_sequence_remove(g_sequence_lookup_exact(sortArea, leaf, leaf_compare_area));
  g_sequence_remove(g_sequence_lookup_exact(hash_get(sameWidth, leaf->w), leaf, leaf_compare_height));
  g_sequence_remove(g_sequence_lookup_exact(hash_get(sameHeight, leaf->h), leaf, leaf_compare_width));
  
  free(leaf);
}

void leaf_cut(Leaf *leaf, int d, gboolean acrossWidth) {
  if (acrossWidth) {
	if (leaf->h - d > 2)
	  leaf_new(leaf->x, leaf->y + d, leaf->w, leaf->h - d);
  } else {
	if (leaf->w - d > 2)
	  leaf_new(leaf->x + d, leaf->y, leaf->w - d, leaf->h);
  }
  leaf_drop(leaf);
}

void leaf_bite(Leaf *leaf, int w, int h) {
  gboolean b = leaf->w > leaf->h; // or (leaf->w - w > leaf->h - h) ?
  if (leaf->w - w > 2)
    leaf_new(leaf->x + w, leaf->y, leaf->w - w, b ? leaf->h : h);
  if (leaf->h - h > 2)
    leaf_new(leaf->x, leaf->y + h, b ? w : leaf->w, leaf->h - h);
  leaf_drop(leaf);
}

void insert_rect(Item *item, Leaf *leaf) {
  right_edge = MAX(right_edge, leaf->x + item->w);
  bottom_edge = MAX(bottom_edge, leaf->y + item->h);
  item->x = leaf->x;
  item->y = leaf->y;
  //clutter_actor_set_position(item->group, leaf->x + 1, leaf->y + 1);
  //clutter_container_add_actor (CLUTTER_CONTAINER(sheet), item->group);
}

void recalculate_layout(int width) {
  bottom_edge = 0;
  right_edge = 0;
  sortArea = g_sequence_new(NULL);
  sameWidth = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, (GDestroyNotify) g_sequence_free);
  sameHeight = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, (GDestroyNotify) g_sequence_free);
  
  width = MAX(width, min_width);
  //fprintf(stderr,"recalc: %i\n", width);
  
  leaf_new(0, 0, width, 4096);
  //clutter_group_remove_all(CLUTTER_GROUP(sheet));
  
  GSequenceIter *i = g_sequence_get_begin_iter(items);
  while (!g_sequence_iter_is_end(i)) {
	Item *item = (Item*) g_sequence_get(i); 
    Leaf *leaf;
    GSequenceIter *si;
	
	// among leaves with the same width as the item, looks for the first leaf tall enough to hold it
	si = g_sequence_search(hash_get(sameWidth,item->w), item, leaf_compare_height, NULL);
	if (!g_sequence_iter_is_end(si)) {
	  leaf = g_sequence_get(si);
	  insert_rect(item, leaf);
	  leaf_cut(leaf, item->h, TRUE);
	  goto next;
	}
	
	// among leaves with the same height as the item, looks for the first leaf wide enough to hold it
	si = g_sequence_search(hash_get(sameHeight,item->h), item, leaf_compare_width, NULL);
	if (!g_sequence_iter_is_end(si)) {
	  leaf = g_sequence_get(si);
	  insert_rect(item, leaf);
	  leaf_cut(leaf, item->w, FALSE);
	  goto next;
	}
	
	// starting with the first leaf larger than the item, looks for the first leaf that can hold it
	si = g_sequence_search(sortArea, item, leaf_compare_area, NULL);
    while (!g_sequence_iter_is_end(si)) {
	  leaf = g_sequence_get(si);
	  if (leaf->w > item->w && leaf->h > item->h) {
	    insert_rect(item, leaf);
	    leaf_bite(leaf, item->w, item->h);
	    goto next;
	  }
	  si = g_sequence_iter_next(si);
	}
	
	// error to reach this point
	  //fprintf(stderr,"failed\n");
	  
	next:
	i = g_sequence_iter_next(i);
  }
  
  g_sequence_foreach(sortArea, (GFunc) free, NULL);
  g_hash_table_destroy(sameWidth);
  g_hash_table_destroy(sameHeight);
  g_sequence_free(sortArea);
  
  if (bottom_edge <= 4096 && (best_area == 0 || right_edge * bottom_edge < best_area)) {
	best_area = right_edge * bottom_edge;
    //fprintf(stderr,"best match area area: %i pixels, %f match\n", best_area, (gfloat) coveredArea / (gfloat) best_area);
	best_width = right_edge;
    //clutter_actor_set_size(bestrect, (gfloat) right_edge, (gfloat) bottom_edge);
  }
  
  //clutter_actor_set_size(bgrect, (gfloat) right_edge, (gfloat) bottom_edge);
}
/*
gboolean motion_callback(ClutterActor *actor, ClutterEvent *event, gpointer user_data) {
  gfloat x;
  clutter_event_get_coords(event, &x, NULL);
  recalculate_layout((int) x * 2);
  return FALSE;
}
 */
int main (int argc, char **argv) {
  if (clutter_init (NULL, NULL) != CLUTTER_INIT_SUCCESS)
    return 1;

  /*
  ClutterActor *stage = clutter_stage_new();
  clutter_actor_set_reactive(stage, TRUE);
  g_signal_connect(stage, "motion-event", G_CALLBACK(motion_callback), NULL);
  const ClutterColor bg_color = { 0x00, 0x00, 0x00, 0xff };
  const ClutterColor br_color = { 0xff, 0xff, 0xff, 0xff };
  const ClutterColor best_color = { 0xff, 0x00, 0x00, 0x88 };
  
  clutter_stage_set_title (CLUTTER_STAGE (stage), "GeneratorDebug");
  clutter_stage_set_color (CLUTTER_STAGE (stage), &bg_color);
  clutter_actor_set_size (stage, 1600, 900);
  g_signal_connect (stage, "destroy", G_CALLBACK (clutter_main_quit), NULL);
  
  bgrect = clutter_rectangle_new_with_color(&br_color);
  clutter_actor_set_position(bgrect, 10, 10);
  clutter_container_add_actor (CLUTTER_CONTAINER (stage), bgrect);
  
  sheet = clutter_group_new();
  clutter_actor_set_position(sheet, 10, 10);
  clutter_container_add_actor (CLUTTER_CONTAINER (stage), sheet);
  
  bestrect = clutter_rectangle_new_with_color(&best_color);
  clutter_actor_set_position(bestrect, 10, 10);
  clutter_container_add_actor (CLUTTER_CONTAINER (stage), bestrect);
  //*/
  
  
  if (argc == 1)
	return 1;

  basepath = argv[1];
  //fprintf(stderr,"path: %s\n", basepath);
  base = g_file_new_for_commandline_arg(basepath);
  items = g_sequence_new(NULL);
  gather(base);
  //fprintf(stderr,"covered area: %i pixels\n", coveredArea);
  
  gint i;
  for (i = min_width; i <= 4096; i++)
	recalculate_layout(i);
  recalculate_layout(best_width);
  
  fprintf(stderr,"best match coverage: %i x %i pixels, %f match\n", best_width, bottom_edge, (gfloat) coveredArea / (gfloat) best_area);
  
  
  //clutter_actor_show_all (stage);
  //clutter_main ();
  
  return 0;
}