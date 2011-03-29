/******************************************************************************
 *    (c)2008-2010 Broadcom Corporation
 *
 * This program is the proprietary software of Broadcom Corporation and/or its licensors,
 * and may only be used, duplicated, modified or distributed pursuant to the terms and
 * conditions of a separate, written license agreement executed between you and Broadcom
 * (an "Authorized License").  Except as set forth in an Authorized License, Broadcom grants
 * no license (express or implied), right to use, or waiver of any kind with respect to the
 * Software, and Broadcom expressly reserves all rights in and to the Software and all
 * intellectual property rights therein.  IF YOU HAVE NO AUTHORIZED LICENSE, THEN YOU
 * HAVE NO RIGHT TO USE THIS SOFTWARE IN ANY WAY, AND SHOULD IMMEDIATELY
 * NOTIFY BROADCOM AND DISCONTINUE ALL USE OF THE SOFTWARE.
 *
 * Except as expressly set forth in the Authorized License,
 *
 * 1.     This program, including its structure, sequence and organization, constitutes the valuable trade
 * secrets of Broadcom, and you shall use all reasonable efforts to protect the confidentiality thereof,
 * and to use this information only in connection with your use of Broadcom integrated circuit products.
 *
 * 2.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE SOFTWARE IS PROVIDED "AS IS"
 * AND WITH ALL FAULTS AND BROADCOM MAKES NO PROMISES, REPRESENTATIONS OR
 * WARRANTIES, EITHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE, WITH RESPECT TO
 * THE SOFTWARE.  BROADCOM SPECIFICALLY DISCLAIMS ANY AND ALL IMPLIED WARRANTIES
 * OF TITLE, MERCHANTABILITY, NONINFRINGEMENT, FITNESS FOR A PARTICULAR PURPOSE,
 * LACK OF VIRUSES, ACCURACY OR COMPLETENESS, QUIET ENJOYMENT, QUIET POSSESSION
 * OR CORRESPONDENCE TO DESCRIPTION. YOU ASSUME THE ENTIRE RISK ARISING OUT OF
 * USE OR PERFORMANCE OF THE SOFTWARE.
 *
 * 3.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL BROADCOM OR ITS
 * LICENSORS BE LIABLE FOR (i) CONSEQUENTIAL, INCIDENTAL, SPECIAL, INDIRECT, OR
 * EXEMPLARY DAMAGES WHATSOEVER ARISING OUT OF OR IN ANY WAY RELATING TO YOUR
 * USE OF OR INABILITY TO USE THE SOFTWARE EVEN IF BROADCOM HAS BEEN ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGES; OR (ii) ANY AMOUNT IN EXCESS OF THE AMOUNT
 * ACTUALLY PAID FOR THE SOFTWARE ITSELF OR U.S. $1, WHICHEVER IS GREATER. THESE
 * LIMITATIONS SHALL APPLY NOTWITHSTANDING ANY FAILURE OF ESSENTIAL PURPOSE OF
 * ANY LIMITED REMEDY.
 *
 * $brcm_Workfile: cmdline_args.h $
 * $brcm_Revision: 34 $
 * $brcm_Date: 10/22/10 12:17p $
 *
 * Module Description:
 *
 * Revision History:
 *
 * $brcm_Log: /nexus/utils/cmdline_args.h $
 * 
 * 34   10/22/10 12:17p vsilyaev
 * SW3548-3106: Added option to start playback in a paused state
 * 
 * 33   9/8/10 12:05p vsilyaev
 * SW7468-129: Added video decoder on ZSP
 * 
 * SW7468-129/2   3/8/10 1:03p vsilyaev
 * SW7468-129: Added decoder index to the record options
 * 
 * SW7468-129/1   3/5/10 7:31p vsilyaev
 * SW7468-129: Added hooks for soft video decoder
 * 
 * 32   8/31/10 2:44p erickson
 * SWGIGGSVIZIO-57: add -fixed_bitrate option to set
 *  NEXUS_PlaybackMode_eFixedBitrate
 *
 * 31   8/10/10 12:14p erickson
 * SW7405-4735: merge
 *
 * SW7405-4735/1   8/9/10 3:21p jtna
 * SW7405-4735: rename opts.pids to opts.otherPids. allow pid 0 in
 *  opts.otherPids. start only one playback during allpass record.
 *
 * 30   7/14/10 6:12p vsilyaev
 * SW3556-1131: Added basic support for CDXA format
 *
 * 29   5/5/10 10:43a vsilyaev
 * SW7405-1260: Added settings for size of the audio decoder buffer
 *
 * 28   2/23/10 4:50p vsilyaev
 * SW3556-913: Added code that monitors state of the playback file and
 *  restarts playback (from last good position) in case of error
 *
 * 27   2/22/10 5:33p vsilyaev
 * SW3556-913: Added option to plug  Custom File I/O routines to inject
 *  errors
 *
 * 26   2/12/10 5:56p jtna
 * SW3556-1051: added option to control playback timestamp reordering
 *
 * 25   1/20/10 5:08p erickson
 * SW7550-159: update record util for threshold and buffer control
 *
 * 24   12/30/09 3:19p vsilyaev
 * SW7408-17: Added options to select PCM and compressed audio outputs
 *
 * 23   12/30/09 2:13p erickson
 * SW7550-128: add closed caption feature (-cc on)
 *
 * 22   12/8/09 2:31p gmohile
 * SW7408-1 : Add defines for nexus had frontend
 *
 * 21   11/25/09 5:24p katrep
 * SW7405-2740: Add support for WMA pro drc
 *
 * 20   8/18/09 4:36p vsilyaev
 * PR 56809: Added option to control handling of video errors
 *
 * 19   6/19/09 5:20p vsilyaev
 * PR 56169: Added option to set max decode rate
 *
 * 18   6/18/09 4:30p jtna
 * PR54802: add frontend support to record
 *
 * 17   6/16/09 5:13p jtna
 * PR54802: added record
 *
 * 16   6/8/09 7:06a erickson
 * PR55617: add user-specific aspectRatio
 *
 * 15   5/22/09 5:21p vsilyaev
 * PR 55376 PR 52344: Added option to enable processing of AVC(H.264)
 *  Level 5.1 video
 *
 * 14   3/18/09 10:26a erickson
 * PR52350: add wxga/fha support with 50/60 hz option
 *
 * 13   3/6/09 9:33a erickson
 * PR51743: added -ar and -graphics options, default DTV apps to panel
 *  output
 *
 * 12   2/27/09 5:05p vsilyaev
 * PR 52634: Added code to handle MPEG-2 TS streams with timesampts (e.g.
 *  192 byte packets)
 *
 * 11   2/20/09 2:06p vsilyaev
 * PR 51467: Added option to set size of the video decoder buffer
 *
 * 10   1/26/09 11:26a vsilyaev
 * PR 51579: Added stream_processing and auto_bitrate options
 *
 * 9   1/22/09 7:48p vsilyaev
 * PR 50848: Don't use globals for the command line options
 *
 * 8   1/20/09 4:28p erickson
 * PR48944: add -mad and -display_format options
 *
 * 7   1/8/09 10:34p erickson
 * PR48944: add more options
 *
 * 6   1/8/09 9:36p erickson
 * PR50757: added NEXUS_VideoFrameRate support, both as a start setting
 *  and status
 *
 * 5   1/6/09 12:45a erickson
 * PR50763: added -bof, -eof options. added playback position to status.
 *  fix mkv, mp4.
 *
 * 4   11/20/08 12:50p erickson
 * PR48944: update
 *
 * 3   11/19/08 1:30p erickson
 * PR48944: update
 *
 * 2   11/17/08 2:19p erickson
 * PR48944: update
 *
 * 1   11/17/08 12:34p erickson
 * PR48944: add utils
 *
 *****************************************************************************/
#ifndef CMDLINE_ARGS_H__
#define CMDLINE_ARGS_H__

#include "nexus_types.h"
#include "nexus_display.h"
#include "nexus_video_window.h"
#include "nexus_pid_channel.h"
#include "nexus_stc_channel.h"
#include "nexus_playback.h"

typedef struct {
    const char *name;
    int value;
} namevalue_t;

struct util_opts_t {
    const char *filename;
    const char *indexname;
    NEXUS_TransportType transportType;
    unsigned short videoPid, pcrPid, audioPid;
    unsigned videoCdb;
    unsigned audioCdb;
    NEXUS_VideoCodec videoCodec;
    NEXUS_AudioCodec audioCodec;
    NEXUS_VideoFormat displayFormat;
    NEXUS_DisplayType displayType;
    NEXUS_VideoWindowContentMode contentMode;
    bool useCompositeOutput;
    bool useComponentOutput;
    bool usePanelOutput;
    bool useScart1CompositeOutput;
    bool stcTrick;
    bool astm;
    bool sync;
    bool mad;
    bool streamProcessing;
    bool autoBitrate;
    unsigned fixedBitrate; /* non-zero */
    bool avc51;
    bool closedCaptionEnabled;
    bool compressedAudio;
    bool decodedAudio;
    bool cdxaFile;
    bool startPaused;
    NEXUS_TransportTimestampType tsTimestampType;
    NEXUS_StcChannelAutoModeBehavior stcChannelMaster;
    NEXUS_PlaybackLoopMode beginningOfStreamAction;
    NEXUS_PlaybackLoopMode endOfStreamAction;
    NEXUS_VideoFrameRate videoFrameRate;
    NEXUS_AspectRatio aspectRatio;
    NEXUS_VideoDecoderErrorHandling videoErrorHandling;
    struct {
        unsigned x, y;
    } sampleAspectRatio;
    bool graphics;
    bool probe;
    bool playpumpTimestampReordering;
    bool customFileIo;
    bool playbackMonitor;
    NEXUS_VideoDecoderTimestampMode decoderTimestampMode;
    unsigned maxDecoderRate;
    unsigned videoDecoder;
    /* asf wma drc */
#if B_HAS_ASF
    bool dynamicRangeControlValid;
    struct {
        unsigned peakReference;
        unsigned peakTarget;
        unsigned averageReference;
        unsigned averageTarget;
    } dynamicRangeControl;
#endif
};

#define MAX_RECORD_PIDS 16
struct util_opts_record_t {
    /* record options */
    NEXUS_TransportType transportType;
    unsigned short videoPid, pcrPid, audioPid;
    unsigned short otherPids[MAX_RECORD_PIDS];
    unsigned numOtherPids;
    NEXUS_VideoCodec videoCodec;
    NEXUS_AudioCodec audioCodec;
    bool allpass;
    bool acceptNullPackets;
    struct {
        unsigned bufferSize;
        unsigned dataReadyThreshold;
    } data, index;

    /* display */
    NEXUS_VideoFormat displayFormat;
    NEXUS_DisplayType displayType;
    NEXUS_VideoWindowContentMode contentMode;
    bool usePanelOutput;
    bool useCompositeOutput;
    bool useComponentOutput;
    bool useScart1CompositeOutput;
    struct util_opts_t opts;
    bool decode;

    /* output */
    const char *recfname;
    const char *recidxname;

    /* source */
    bool streamer;
    bool probe;
    const char *playfname;
    unsigned videoDecoder;
#if NEXUS_HAS_FRONTEND
    NEXUS_FrontendVsbMode vsbMode;
    NEXUS_FrontendQamMode qamMode;
    NEXUS_FrontendSatelliteMode satMode;
    unsigned freq; /* in MHz */
#endif
};

extern const float g_frameRateValues[NEXUS_VideoFrameRate_eMax];
extern const namevalue_t g_videoFrameRateStrs[];

/*
cmdline_parse should be called before NEXUS_Platform_Init
returns non-zero if app should exit
*/
int cmdline_parse(int argc, const char *argv[], struct util_opts_t *opts);
int cmdline_parse_record(int argc, const char *argv[], struct util_opts_record_t *opts);

/*
cmdline_probe should be called after NEXUS_Platform_Init
*/
int cmdline_probe(struct util_opts_t *opts);

/*
print_usage can be called if cmdline_parse fails
*/
void print_usage(const char *app /* argv[0] */);
void print_usage_record(const char *app /* argv[0] */);

#endif
