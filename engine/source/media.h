#include <clutter-gst/clutter-gst.h>

class Media
{
  public:
    Media();
    ~Media();
  private:
    int             mute;
    double          volume;
    ClutterMedia  * cm;
};

