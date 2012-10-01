/*
 * Usage: stitcher /path/to/directory
 * Flags:
 *    -i [filter]   Filter which files to include. Name filters can use the
 *                  wildcards * (zero or more chars) and ? (one char).
 *                  Multiple space-seperated name filters can be passed.
 *       [int]      One integer size filter can be passed, such as 256, to
 *                  prevent large images from being included in a spritesheet. 
 *                  
 *    -o [path]     Set the path of the output files, which will have
 *                  sequential numbers and a .png or .json extension appended.
 *       [int]      Pass an integer like 4096 to set the maximum .png size
 *                  
 *    -m            Divide sprites among multiple spritesheets if they don't fit
 *                  within the maximum dimensions
 *    
 *    -c            Copy files that fail the size filter over as single-image
 *                  spritesheets (if they fit within the maximum output size)
 *
 * Ex: stitcher assets/ui -i *.png nav/bg-?.jpg 256 -o sprites/ui 1024 -mc
 */

#define CLUTTER_DISABLE_DEPRECATION_WARNINGS
#include <glib.h>
#include <glib-object.h>
#include <gio/gio.h>
#include <magick/MagickCore.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char * basepath;

typedef struct Page {
  int width,
      height,
	    area;
} Page;
Page current, minimum = {0, 0, 0}, best = {0, 0, 0};

GFile        * base;
GPtrArray    * inputPatterns;
GSequence    * items,
             * leavesSortedByArea;
GHashTable   * leavesOfWidth,
             * leavesOfHeight;

int inputSize = 4096,
    outputSize = 4096;
	
gboolean multipleSheets = FALSE,
         copyLarge = FALSE,
		 singleJson = FALSE,
         bufferPixels = FALSE;

typedef struct Item {
  int x, y, w, h, area;
  char * id,
       * path;
  gboolean placed;
} Item;

Item * item_new(char *path) {
  Item * item = malloc(sizeof(Item));
  item->id = path;
  GString * str = g_string_new(basepath);
  g_string_append(str, "/");
  g_string_append(str, path);
  item->path = g_string_free(str, FALSE);
  item->placed = FALSE;
  
  ExceptionInfo * exception = AcquireExceptionInfo();
  ImageInfo * inputInfo = AcquireImageInfo();
  CopyMagickString(inputInfo->filename, item->path, MaxTextExtent);
  Image * tempImage = PingImage(inputInfo, exception);
  
  // handle exceptions
  
  item->x = 0;
  item->y = 0;
  item->w = (int) tempImage->columns + (bufferPixels ? 2 : 0);
  item->h = (int) tempImage->rows + (bufferPixels ? 2 : 0);
  item->area = item->w * item->h;
  minimum.area += item->area;
  minimum.width = MAX(minimum.width, item->w);
  
  DestroyImage(tempImage);
  DestroyExceptionInfo(exception);
  
  return item;
}

gint item_compare_area(gconstpointer a, gconstpointer b, gpointer user_data) {
  Item * aa = (Item *) a, * bb = (Item *) b;
  return MAX(bb->w, bb->h) - MAX(aa->w, aa->h);
}

void gather(GFile * file) {
  GFileInfo * info = g_file_query_info(file, "standard::*", G_FILE_QUERY_INFO_NONE, NULL, NULL);
  GFileType type = g_file_info_get_file_type(info);
  
  if (type == G_FILE_TYPE_REGULAR) {
    if (file == base)
      fprintf(stderr,"error!");
    else {
	  char * path = g_file_get_relative_path(base,file);
	  int i;
	  if (inputPatterns->len > 0) {
		for (i = 0; i < inputPatterns->len; i++)
		  if (g_pattern_match_string(g_ptr_array_index(inputPatterns, i), path))
		    g_sequence_insert_sorted(items, item_new(path), item_compare_area, NULL);
	  } else
        g_sequence_insert_sorted(items, item_new(path), item_compare_area, NULL);
	  // iterate through wildcard filters, test for a match
	  // make sure is actually an image
	  // make sure it fits within inputSize
	}
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
  if (leaf->w - w > (bufferPixels ? 2 : 0)) leaf_new(leaf->x + w, leaf->y, leaf->w - w, b ? leaf->h : h);
  if (leaf->h - h > (bufferPixels ? 2 : 0)) leaf_new(leaf->x, leaf->y + h, b ? w : leaf->w, leaf->h - h);
  
  g_sequence_remove_sorted(leavesSortedByArea, leaf, leaf_compare, AREA);
  g_sequence_remove_sorted(get_sequence(leavesOfWidth, leaf->w), leaf, leaf_compare, WIDTH);
  g_sequence_remove_sorted(get_sequence(leavesOfHeight, leaf->h), leaf, leaf_compare, HEIGHT);
  
  free(leaf);
}

void insert_item(Item * item, Leaf * leaf, gboolean finalize) {
  current.width = MAX(current.width, leaf->x + item->w);
  current.height = MAX(current.height, leaf->y + item->h);
  item->x = leaf->x;
  item->y = leaf->y;
  item->placed = finalize;
  leaf_cut(leaf, item->w, item->h);
}

void recalculate_layout(int width, gboolean finalize) {
  current = (Page) {0, 0, 0};
  leavesSortedByArea = g_sequence_new(NULL);
  leavesOfWidth = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, (GDestroyNotify) g_sequence_free);
  leavesOfHeight = g_hash_table_new_full(g_direct_hash, g_direct_equal, NULL, (GDestroyNotify) g_sequence_free);
  leaf_new(0, 0, MAX(width, minimum.width), 4096);
  
  GSequenceIter * i = g_sequence_get_begin_iter(items);
  while (!g_sequence_iter_is_end(i)) {
    Item * item = (Item *) g_sequence_get(i);
    if (item->placed == TRUE)
      continue;
    
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
      insert_item(item, g_sequence_get(si), finalize);
    else {
      si = g_sequence_search(leavesSortedByArea, item, leaf_compare, AREA);
      while (!g_sequence_iter_is_end(si)) {
        leaf = g_sequence_get(si);
        if (leaf->w > item->w && leaf->h > item->h) {
          insert_item(item, leaf, finalize);
          break;
        }
        si = g_sequence_iter_next(si);
      }
    }
    i = g_sequence_iter_next(i);
  }
  
  // save this layout if it's the best so far
  
	// consider: current.area + current.width + current.height <= best.area + best.width + best.height?
  current.area = current.width * current.height;
  if (current.height <= outputSize && (best.area == 0 || current.area < best.area ||
     (current.area == best.area && current.width + current.height <= best.width + best.height) ))
    best = current;
  
  // collect garbage
  
  g_sequence_foreach(leavesSortedByArea, (GFunc) free, NULL);
  g_hash_table_destroy(leavesOfWidth);
  g_hash_table_destroy(leavesOfHeight);
  g_sequence_free(leavesSortedByArea);
}

void export_image(char * jsonPath, char * pngPath) {
  ExceptionInfo * exception   = AcquireExceptionInfo();
  ImageInfo     * outputInfo  = AcquireImageInfo();
  Image         * outputImage = AcquireImage(outputInfo);
  SetImageExtent(outputImage, best.width, best.height);
  SetImageOpacity(outputImage, QuantumRange);
  
  GString * str = g_string_new("{\n\t\"sprites\": [");
  gchar ** sprites = calloc(g_sequence_get_length(items) + 1, sizeof(gchar *));
  
  int i = 0, j;
  GSequenceIter *sj, * si = g_sequence_get_begin_iter(items);
  while (!g_sequence_iter_is_end(si)) {
    Item * item = g_sequence_get(si);
    if (item->placed == FALSE)
      continue;
	
    // write json

	//fprintf(stderr,"compositing %s\n", item->id);
    sprites[i++] = g_strdup_printf("\n\t\t{ \"x\": %i, \"y\": %i, \"w\": %i, \"h\": %i, \"id\": \"%s\" }",
								   item->x, item->y, item->w, item->h, item->id);
	
	// composite sprite onto output image
	
    ImageInfo * tempInfo = AcquireImageInfo();
    CopyMagickString(tempInfo->filename, item->path, MaxTextExtent);
    Image * tempImage = ReadImage(tempInfo, exception);
        
    CompositeImage(outputImage, ReplaceCompositeOp , tempImage,
				   item->x + (bufferPixels ? 1 : 0),
				   item->y + (bufferPixels ? 1 : 0));
    
	// composite the sprite's buffer pixels onto image
	
    if (bufferPixels == TRUE) {
      RectangleInfo rects[8] =
        { {1, item->h - 2,  0, 0},
          {1, item->h - 2,  item->w - 3, 0},
          {item->w - 2, 1,  0, 0},
          {item->w - 2, 1,  0, item->h - 3},
          {1, 1,  0, 0},
          {1, 1,  item->w - 3, 0},
          {1, 1,  0, item->h - 3},
          {1, 1,  item->w - 3, item->h - 3} };
      int points[16] =
        { 0, 1,  item->w - 1, 1,  1, 0,            1, item->h - 1,
          0, 0,  item->w - 1, 0,  0, item->h - 1,  item->w - 1, item->h - 1 };
      
      for (j = 0; j < 8; j++) {
        Image * excerptImage = ExcerptImage(tempImage, &rects[j], exception);
        CompositeImage(outputImage, ReplaceCompositeOp , excerptImage,
					   item->x + points[j * 2],
					   item->y + points[j * 2 + 1]);
        DestroyImage(excerptImage);
      }
    }
    
    DestroyImage(tempImage);
    DestroyImageInfo(tempInfo);
	
	// drop this sprite so other sheets don't worry about it
	
    sj = g_sequence_iter_next(si);
    g_sequence_remove(si);
    si = sj;
  }
  
  // collect and write out the json
  
  g_string_append(str, g_strjoinv(",", sprites));
  g_string_append(str, g_strdup_printf("\n\t],\n\t\"img\": \"%s\"\n}", pngPath));
  
  GFile *json = g_file_new_for_path(jsonPath);
  g_file_replace_contents  (json, str->str, str->len, NULL, FALSE, G_FILE_CREATE_NONE, NULL, NULL, NULL);
  g_string_free(str, TRUE);
  
  // write out the png
  
  CopyMagickString(outputInfo->filename, pngPath, MaxTextExtent);
  CopyMagickString(outputInfo->magick, "png", MaxTextExtent);
  CopyMagickString(outputImage->filename, pngPath, MaxTextExtent);
  WriteImage(outputInfo, outputImage);
  
  fprintf(stderr, "Output map to %s and image to %s\n", jsonPath, pngPath);
  
  // collect garbage
  
  DestroyExceptionInfo(exception);
  DestroyImageInfo(outputInfo);
  DestroyImage(outputImage);
}

enum {
  DEFAULT,
  SET_INPUT = 'i',
  SET_OUTPUT = 'o',
  SET_OPTIMIZATION = 'p'
};

int main (int argc, char ** argv) {
  if (argc == 1)
    return 1;

  g_type_init();
  MagickCoreGenesis(* argv, MagickTrue);
  
  // handle command-line arguments
  
  int i, j, l, state = DEFAULT;
  char * arg, * outputPath = NULL;
  
  inputPatterns = g_ptr_array_new_with_free_func((GDestroyNotify) g_pattern_spec_free);
  
  for (i = 1; i < argc; i++) {
    arg = argv[i];
    l = strlen(arg);
    if ((char) arg[0] == '-') {
      for (j = 1; j < l; j++) {
        switch((char) arg[j]) {
          case 'i':
          case 'o':
          case 'p':
            state = arg[j];
            break;
          case 'b':
            bufferPixels = TRUE;
            state = DEFAULT;
            break;
          case 'c':
            copyLarge = TRUE;
            state = DEFAULT;
            break;
          case 'm':
            multipleSheets = TRUE;
            state = DEFAULT;
            break;
          case 's':
            singleJson = TRUE;
            state = DEFAULT;
            break;
          default:
            state = DEFAULT;
            break;
        }
      }
    } else {
      switch(state) {
        case SET_INPUT:
          for (j = 0; j < l; j++)
            if (!g_ascii_isdigit(arg[j]))
              break;
          if (j == l)
            inputSize = (int) strtol(arg, NULL, 10);
          else
            g_ptr_array_add(inputPatterns, g_pattern_spec_new(arg));
          break;
        case SET_OUTPUT:
          for (j = 0; j < l; j++)
            if (!g_ascii_isdigit(arg[j]))
              break;
          if (j == l)
            outputSize = (int) strtol(arg, NULL, 10);
          else
            outputPath = arg;
          break;
        case SET_OPTIMIZATION:
          // how much to optimize the result, if possible
          break;
        default:
          if (i == 1)
            basepath = arg;
          else {
            fprintf(stderr, "Error: ambiguous input path\n");
            exit(1);
          }
        break;
      }
    }
  }
  
  if (outputPath == NULL)
    outputPath = basepath;
  char * jsonPath = g_strdup_printf("%s.json", outputPath),
       * pngPath  = g_strdup_printf("%s.png", outputPath);
  
  base = g_file_new_for_commandline_arg(basepath);
  items = g_sequence_new((GDestroyNotify) free);
  gather(base);
  
  // iterate to find the best layout
  
  for (i = minimum.width; i <= outputSize; i++)
    recalculate_layout(i, FALSE);
  recalculate_layout(best.width, TRUE);
  
  fprintf(stderr,"Best match coverage: %i x %i pixels, %f%% match\n",
		  best.width, best.height, 100.0 * (gfloat) minimum.area / (gfloat) best.area);
  
  export_image(jsonPath, pngPath);
  
  g_ptr_array_free(inputPatterns, TRUE);
  g_sequence_free(items);
  
  MagickCoreTerminus();
  
  return 0;
}