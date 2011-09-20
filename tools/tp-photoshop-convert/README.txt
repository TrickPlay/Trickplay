README for tp-photoshop-convert script

This script converts Photoshop-generated HTML pages and their associated
sliced images into a new Trickplay application for use with the Trickplay
SDK Editor.


IMPORTANT:

HTML files must be generated with the Inline CSS option. This setting
is under Save-for-web-and-devices output settings. Start by going to Output
Settings and choosing default from the dropdown menu. In the Slice Output
settings, turn on the radio button "Generate CSS," then choose the "Inline"
option. All other settings should be left unchanged from default. In
particular, it is assumed that the image files will be in the directory images/
in the same directory as the html file.


TYPICAL USAGE:

./tp-photoshop-convert htmlfile1 htmlfile2 htmlfile3 outputDirectory/

An additional option -n screenName.lua specifies the name of the screen file
and images generated.

The output directory must then be moved into the editor directory. By default,
this directory is ~/trickplay-editor/
