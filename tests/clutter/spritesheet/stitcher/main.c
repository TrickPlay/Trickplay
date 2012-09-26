#define CLUTTER_DISABLE_DEPRECATION_WARNINGS
#include <glib.h>
#include <glib-object.h>
#include <gio/gio.h>
#include <magick/MagickCore.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

char * basepath;

typedef struct Page {
  int width,
      height,
	  area;
} Page;
Page current, minimum = {0, 0, 0}, best = {0, 0, 0};

GSequence * leavesSortedByArea;
GHashTable * leavesOfWidth, * leavesOfHeight;

typedef struct Item {
  int x, y, w, h, area;
  char * id,
       * path;
} Item;

Item * item_new(char *path) {
  Item * item = malloc(sizeof(Item));
  item->id = path;
  GString * str = g_string_new(basepath);
  g_string_append(str, "/");
  g_string_append(str, path);
  item->path = g_string_free(str, FALSE);
  
  ExceptionInfo * exception = AcquireExceptionInfo();
  ImageInfo * inputInfo = AcquireImageInfo();
  CopyMagickString(inputInfo->filename, item->path, MaxTextExtent);
  Image * tempImage = PingImage(inputInfo, exception);
  
  // handle exceptions
  
  item->x = 0;
  item->y = 0;
  item->w = (int) tempImage->columns + 2;
  item->h = (int) tempImage->rows + 2;
  item->area = item->w * item->h;
  minimum.area += item->area;
  minimum.width = MAX(minimum.width, item->w);
  
  tempImage = DestroyImage(tempImage);
  exception = DestroyExceptionInfo(exception);
  
  return item;
}

gint item_compare_area(gconstpointer a, gconstpointer b, gpointer user_data) {
  Item * aa = (Item *) a, * bb = (Item *) b;
  return MAX(bb->w, bb->h) - MAX(aa->w, aa->h);
}

int array_n = 0;
GFile * base;
GSequence * items;

void gather(GFile * file) {
  GFileInfo * info = g_file_query_info(file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL);
  GFileType type = g_file_info_get_file_type(info);
  
  if (type == G_FILE_TYPE_REGULAR) {
	if (file == base)
	  fprintf(stderr,"error!");
	else
	  g_sequence_insert_sorted(items, item_new(g_file_get_relative_path(base,file)), item_compare_area, NULL);
	  
  } else if (type == G_FILE_TYPE_DIRECTORY) {
	GFileEnumerator * children = g_file_enumerate_children(file ,"standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL);
	GFileInfo * childInfo;
	GFile * child;
	
	while ((childInfo = g_file_enumerator_next_file(children, NULL, NULL)) != NULL) {
	  child = g_file_get_child(file, g_file_info_get_name(childInfo));
	  gather(child);
	  g_object_unref(child);
	  g_object_unref(childInfo);
	}
	
	g_file_enumerator_close(children, NULL, NULL);
	g_object_unref(children);
  }
}

GSequence * get_sequence(GHashTable * table, int key) {
  gpointer ptr = GINT_TO_POINTER(key + 1);
  
  GSequence * seq = g_hash_table_lookup(table, ptr);
  if (seq == NULL)
	g_hash_table_insert(table, ptr, (seq = g_sequence_new(NULL)) );
	
  return seq;
}

#define AREA GINT_TO_POINTER(1)
#define WIDTH GINT_TO_POINTER(2)
#define HEIGHT GINT_TO_POINTER(3)

typedef struct Leaf {
  int x, y, w, h, area;
} Leaf;

int leaf_compare(gconstpointer a, gconstpointer b, gpointer user_data) {
  Leaf * aa = (Leaf *) a, * bb = (Leaf *) b;
  return user_data == AREA   ? aa->area - bb->area :
	     user_data == WIDTH  ? aa->w    - bb->w    :
		 user_data == HEIGHT ? aa->h    - bb->h    : 0;
}

void g_sequence_remove_sorted(GSequence * seq, gpointer data, GCompareDataFunc cmp_func, gpointer cmp_data) {
  GSequenceIter * sj, * si = g_sequence_lookup(seq, data, cmp_func, cmp_data);
  if (si != NULL) {
	gpointer found;
	sj = si;
	while (!g_sequence_iter_is_end(sj)) {
	  found = g_sequence_get(sj);
	  if (found == data)
		return g_sequence_remove(sj);
	  else if (cmp_func(found, data, cmp_data) != 0)
		break;
	  sj = g_sequence_iter_next(sj);
	}
	
	sj = si;
	while (!g_sequence_iter_is_begin(sj)) {
	  sj = g_sequence_iter_prev(sj);
	  found = g_sequence_get(sj);
	  if (found == data)
		return g_sequence_remove(sj);
	  else if (cmp_func(found, data, cmp_data) != 0)
		break;
	}
  }
}

Leaf * leaf_new(int x, int y, int w, int h) {
  Leaf * leaf = malloc(sizeof(Leaf));
  leaf->x = x;
  leaf->y = y;
  leaf->w = w;
  leaf->h = h;
  leaf->area = w * h;
  
  g_sequence_insert_sorted(leavesSortedByArea, leaf, leaf_compare, AREA);
  g_sequence_insert_sorted(get_sequence(leavesOfWidth, leaf->w), leaf, leaf_compare, WIDTH);
  g_sequence_insert_sorted(get_sequence(leavesOfHeight, leaf->h), leaf, leaf_compare, HEIGHT);
  
  return leaf;
}

void leaf_cut(Leaf * leaf, int w, int h) {
  gboolean b = leaf->w - w > leaf->h - h;
  if (leaf->w - w > 2) leaf_new(leaf->x + w, leaf->y, leaf->w - w, b ? leaf->h : h);
  if (leaf->h - h > 2) leaf_new(leaf->x, leaf->y + h, b ? w : leaf->w, leaf->h - h);
  
  g_sequence_remove_sorted(leavesSortedByArea, leaf, leaf_compare, AREA);
  g_sequence_remove_sorted(get_sequence(leavesOfWidth, leaf->w), leaf, leaf_compare, WIDTH);
  g_sequence_remove_sorted(get_sequence(leavesOfHeight, leaf->h), leaf, leaf_compare, HEIGHT);
  
  free(leaf);
}

void insert_item(Item * item, Leaf * leaf) {
  current.width = MAX(current.width, leaf->x + item->w);
  current.height = MAX(current.height, leaf->y + item->h);
  item->x = leaf->x;
  item->y = leaf->y;
  leaf_cut(leaf, item->w, item->h);
}

void recalculate_layout(int width) {
  current = (Page) {0, 0, 0};
  leavesSortedByArea = g_sequence_new(NULL);
  leavesOfWidth = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, (GDestroyNotify) g_sequence_free);
  leavesOfHeight = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, (GDestroyNotify) g_sequence_free);
  leaf_new(0, 0, MAX(width, minimum.width), 4096);
  
  GSequenceIter * i = g_sequence_get_begin_iter(items);
  while (!g_sequence_iter_is_end(i)) {
	Item * item = (Item *) g_sequence_get(i); 
    Leaf * leaf;
    GSequenceIter * si;
	
	/* among leaves exactly as wide as the item, looks for the first leaf tall enough to hold it
	 * else, among leaves exactly as tall as the item, looks for the first leaf wide enough to hold it
	 * else, starting with the first leaf larger than the item, looks for the first leaf that can hold it
	 */
	
	si = g_sequence_search(get_sequence(leavesOfWidth, item->w), item, leaf_compare, HEIGHT);
	if (g_sequence_iter_is_end(si))
	  si = g_sequence_search(get_sequence(leavesOfHeight, item->h), item, leaf_compare, WIDTH);
	  
	if (!g_sequence_iter_is_end(si))
	  insert_item(item, g_sequence_get(si));
	else {
	  si = g_sequence_search(leavesSortedByArea, item, leaf_compare, AREA);
      while (!g_sequence_iter_is_end(si)) {
	    leaf = g_sequence_get(si);
	    if (leaf->w > item->w && leaf->h > item->h) {
	      insert_item(item, leaf);
	      break;
	    }
	    si = g_sequence_iter_next(si);
	  }
	}
	
	i = g_sequence_iter_next(i);
  }
  
  g_sequence_foreach(leavesSortedByArea, (GFunc) free, NULL);
  g_hash_table_destroy(leavesOfWidth);
  g_hash_table_destroy(leavesOfHeight);
  g_sequence_free(leavesSortedByArea);
  
  current.area = current.width * current.height;
  if (current.height <= 4096 && (best.area == 0 || current.area < best.area))
	best = current;
}

int main (int argc, char ** argv) {
  if (argc == 1)
	return 1;

  g_type_init();
  basepath = argv[1];
  base = g_file_new_for_commandline_arg(basepath);
  items = g_sequence_new(NULL);
  gather(base);
  
  int i;
  for (i = minimum.width; i <= 4096; i++)
	recalculate_layout(i);
  recalculate_layout(best.width);
  
  fprintf(stderr,"best match coverage: %i x %i pixels, %f%% match\n", best.width, best.height, (gfloat) minimum.area / (gfloat) best.area);
  
  MagickCoreGenesis(* argv, MagickTrue);

  MagickPixelPacket * bg = malloc(sizeof(MagickPixelPacket));
  ExceptionInfo * exception = AcquireExceptionInfo();
  ImageInfo * outputInfo = AcquireImageInfo(),
			* tempInfo;
  Image * outputImage = NewMagickImage(outputInfo, best.width, best.height, bg),
        * tempImage,
		* excerptImage;
  SetImageOpacity(outputImage, QuantumRange);
  Item * item;
	
  GString * str = g_string_new("{\n\t\"sprites\": [");
  
  gchar ** sprites = calloc(g_sequence_get_length(items), sizeof(gchar));
  i = 0;
  
  GSequenceIter * si = g_sequence_get_begin_iter(items);
  while (!g_sequence_iter_is_end(si)) {
	item = g_sequence_get(si);
	sprites[i] = g_strdup_printf("\n\t\t{ \"x\": %i, \"y\": %i, \"w\": %i, \"h\": %i, \"id\": \"%s\" }", item->x, item->y, item->w, item->h, item->id);
	tempInfo = AcquireImageInfo();
	CopyMagickString(tempInfo->filename, item->path, MaxTextExtent);
	tempImage = ReadImage(tempInfo, exception);
	if (exception->severity != UndefinedException)
      CatchException(exception);
	  
	CompositeImage(outputImage, ReplaceCompositeOp , tempImage, item->x + 1, item->y + 1);
	
	RectangleInfo rects[8] =
	  { {1, item->h - 2, 0, 0},
	    {1, item->h - 2, item->w - 3, 0},
	    {item->w - 2, 1, 0, 0},
	    {item->w - 2, 1, 0, item->h - 3},
	    {1, 1, 0, 0},
	    {1, 1, item->w - 3, 0},
	    {1, 1, 0, item->h - 3},
	    {1, 1, item->w - 3, item->h - 3} };
	int points[16] =
	  { 0, 1, item->w - 1, 1, 1, 0, 1, item->h - 1,
	    0, 0, item->w - 1, 0, 0, item->h - 1, item->w - 1, item->h - 1 };
	
	int j;
	for (j = 0; j < 8; j++) {
	  excerptImage = ExcerptImage(tempImage, &rects[j], exception);
	  CompositeImage(outputImage, ReplaceCompositeOp , excerptImage, item->x + points[j*2], item->y + points[j*2+1]);
	  excerptImage = DestroyImage(excerptImage);
	}
	
	tempImage = DestroyImage(tempImage);
	tempInfo = DestroyImageInfo(tempInfo);
	si = g_sequence_iter_next(si);
	i++;
  }
  
  char * pngPath = g_strdup_printf("%s.png", basepath),
       * jsonPath = g_strdup_printf("%s.json", basepath);
	   
  g_string_append(str, g_strjoinv(",", sprites));
  g_string_append(str, g_strdup_printf("\n\t],\n\t\"img\": \"%s\"\n}", pngPath));
  
  GFile *json = g_file_new_for_path(jsonPath);
  g_file_replace_contents  (json, str->str, str->len, NULL, FALSE, G_FILE_CREATE_NONE, NULL, NULL, NULL);
  g_string_free(str, TRUE);
  
  CopyMagickString(outputInfo->filename, pngPath, MaxTextExtent);
  CopyMagickString(outputInfo->magick, "png", MaxTextExtent);
  outputInfo->file = fopen(pngPath, "w+b");
  WriteImage(outputInfo, outputImage);
  
  fprintf(stderr, "Output map to %s and image to %s\n", jsonPath, pngPath);

  free(bg);
  exception = DestroyExceptionInfo(exception);
  outputInfo = DestroyImageInfo(outputInfo);
  outputImage = DestroyImage(outputImage);
  MagickCoreTerminus();
  
  return 0;
}