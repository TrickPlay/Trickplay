#include "pango-color-table-crh.h"

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

const char* WHITE="white";
const char* BLACK="black";

unsigned char MAX(unsigned char a,unsigned char b, unsigned char c)
{
    if(a>b)
    {
        if(a>c) return a;
        return c;
    }
    if(b>c) return b;
    return c;
}

unsigned char MIN(unsigned char a,unsigned char b, unsigned char c)
{
    if(a<b)
    {
        if(a<c) return a;
        return c;
    }
    if(b<c) return b;
    return c;
}

static const float W_R = 0.299;
static const float W_G = 0.587;
static const float W_B = 0.114;
static const float U_MAX = 0.499;
static const float V_MAX = 0.499;

void rgb_to_yuv(unsigned char r, unsigned char g, unsigned char b, float *y, float *u, float *v)
{
    float R = ((float)r)/255;
    float G = ((float)g)/255;
    float B = ((float)b)/255;
    if(y) *y = W_R*R + W_G*G + W_B*B;

    if(u) *u = U_MAX*(B-*y)/(1-W_B);
    if(v) *v = V_MAX*(R-*y)/(1-W_R);
}

void rgb_to_hsl(unsigned char r, unsigned char g, unsigned char b, float *h, float *s, float *l)
{
    unsigned char max_color = MAX(r, g, b);
    unsigned char min_color = MIN(r, g, b);

    if(l) *l = ((float)MAX(r,g,b)+(float)MIN(r,g,b))/1024.0;

    if(s)
    if(max_color == min_color)
    {
        *s = 0.0;
    } else {
        if(*l<0.5)
        {
            *s = ((float)(max_color-min_color))/((float)(max_color+min_color));
        } else {
            *s = ((float)(max_color-min_color))/(2.0-(float)(max_color-min_color));
        }
    }

    if(h)
    if(max_color == min_color)
    {
        *h = -2.0;
    } else if(r == max_color)
    {
        *h = ((float)(g-b))/((float)(max_color-min_color));
    } else if(g == max_color) {
        *h = 2.0 + ((float)(b-r))/((float)(max_color-min_color));
    } else {
        *h = 4.0 + ((float)(r-g))/((float)(max_color-min_color));
    }
}

int compare_func(const ColorEntry* ce_a, const ColorEntry* ce_b)
{
//    ColorEntry *ce_a = (ColorEntry *)a;
//    ColorEntry *ce_b = (ColorEntry *)b;
    
    float y_a, u_a, v_a, h_a, s_a, l_a;
    float y_b, u_b, v_b, h_b, s_b, l_b;
    rgb_to_yuv(ce_a->red, ce_a->green, ce_a->blue, &y_a, &u_a, &v_a);
    rgb_to_hsl(ce_a->red, ce_a->green, ce_a->blue, &h_a, &s_a, &l_a);
    
    rgb_to_yuv(ce_b->red, ce_b->green, ce_b->blue, &y_b, &u_b, &v_b);
    rgb_to_hsl(ce_b->red, ce_b->green, ce_b->blue, &h_b, &s_b, &l_b);

    // Sort by hue then by brightness
    return -((fabs(h_a - h_b) > 0.01) ? ((h_a < h_b) ? -1 : 1)
    : ((fabs(s_a - s_b) > 0.001) ? (( s_a < s_b ) ? -1 : 1)
    : (fabs(y_a - y_b) > 0.001) ? (( y_a < y_b ) ? -1 : 1) : 0 ));
}

int main(int argc, char **argv)
{
    qsort(  (void *)&(color_entries[0]),
            sizeof(color_entries)/sizeof(color_entries[0]),
            sizeof(color_entries[0]),
            (int (*)(const void *, const void *))compare_func);

    printf("<style>.column1 {"
" width: 12em;"
" padding:2px 0 1px 0;"
" margin:1px;"
" float:left;"
" text-align:center;"
" line-height:12px;"
" font-size:9px;"
" font-family:Lato,helvetica,sans-serif;"
" vertical-align:baseline;"
" border:1px solid black;"
"}"
"</style>\n<div style='padding:0 5em 0 5em;overflow:hidden'>\n");
    for(unsigned row=0; row<(sizeof(color_entries)/sizeof(color_entries[0]))/8; row++)
    {
        for(unsigned col=0; col<8; col++)
        {
            printf("\t<div class='column1' ");
            unsigned i = row * 8 + col;
            ColorEntry ce = color_entries[i];
            float y;
            rgb_to_yuv(ce.red,ce.green,ce.blue,&y,NULL,NULL);
            const char* text_color = (y<0.5) ? WHITE : BLACK;
            printf("style='background-color:rgb(%d,%d,%d);color:%s'><span style='font-size:11px'>%s</span><br />rgb(%d,%d,%d)<br />#%02x%02x%02x</div>\n", ce.red,ce.green,ce.blue,text_color,&(color_names[ce.name_offset]), ce.red, ce.green, ce.blue, ce.red, ce.green, ce.blue);
        }
    }
    printf("</div>\n");
}
