#!/bin/sh

#TRICKPLAY_PATH=/mnt/addon/trickplay
THIS_SCRIPT_PATH=`dirname $0`
TRICKPLAY_PATH=`cd $THIS_SCRIPT_PATH/..; pwd`
#LD_LIBRARY_PATH=${TRICKPLAY_PATH}/lib:$LD_LIBRARY_PATH
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${TRICKPLAY_PATH}/lib
export LD_LIBRARY_PATH

# check display mode
# --disp
#   0 TP_DISP_NONE
#   1 TP_DISP_FULL
#   2 TP_DISP_WIDGET
TP_EXTRA_OPT=""
if [ -f "$1/_widget" ]; then
	TP_EXTRA_OPT="--disp 2"
fi

echo "##### TRICKPLAY #####"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "CMD=${TRICKPLAY_PATH}/bin/trickplay $* $TP_EXTRA_OPT"
${TRICKPLAY_PATH}/bin/trickplay $* $TP_EXTRA_OPT
