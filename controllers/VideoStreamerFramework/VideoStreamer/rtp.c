/*
 * FILE:     rtp.c
 * AUTHOR:   Colin Perkins   <csp@isi.edu>
 * MODIFIED: Orion Hodson    <o.hodson@cs.ucl.ac.uk>
 *           Markus Germeier <mager@tzi.de>
 *           Bill Fenner     <fenner@research.att.com>
 *           Timur Friedman  <timur@research.att.com>
 *			 Steve McFarlin  <steve@stevemcfarlin.com>
 *
 * The routines in this file implement the Real-time Transport Protocol,
 * RTP, as specified in RFC1889 with current updates under discussion in
 * the IETF audio/video transport working group. Portions of the code are
 * derived from the algorithms published in that specification.
 *
 * $Revision: 3862 $ 
 * $Date: 2006-09-13 14:26:20 +0100 (Wed, 13 Sep 2006) $
 * 
 * Copyright (c) 1998-2001 University College London
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, is permitted provided that the following conditions 
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *      This product includes software developed by the Computer Science
 *      Department at University College London.
 * 4. Neither the name of the University nor of the Department may be used
 *    to endorse or promote products derived from this software without
 *    specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

#include <stddef.h> //SV-XXX: needed by Win for offsetof(), removed from config_unix.h too
#include "config_unix.h"
#include "rtp.h"
#include "net_udp.h"
#include "net_tcp.h"
#include "debug.h"
#include "drand48.h"
#include "memory.h"
 #include "ntp.h"

/*
 #include "crypt_random.h"
 #include "rijndael-api-fst.h"
 #include "gettimeofday.h"
 #include "qfDES.h"
 #include "md5.h"
 */


/*
 * Encryption stuff.
 */
#define MAX_ENCRYPTION_PAD 16
/*
 static int rijndael_initialize(struct rtp *session, u_char *hash, int hash_len);
 static int rijndael_decrypt(struct rtp *session, unsigned char *data,
 unsigned int size, unsigned char *initVec);
 static int rijndael_encrypt(struct rtp *session, unsigned char *data,
 unsigned int size, unsigned char *initVec);
 
 static int des_initialize(struct rtp *session, u_char *hash, int hash_len);
 static int des_decrypt(struct rtp *session, unsigned char *data,
 unsigned int size, unsigned char *initVec);
 static int des_encrypt(struct rtp *session, unsigned char *data,
 unsigned int size, unsigned char *initVec);
 
 */

#define MAX_DROPOUT    3000
#define MAX_MISORDER   100
#define MIN_SEQUENTIAL 2

/*
 * Definitions for the RTP/RTCP packets on the wire...
 */

#define RTP_SEQ_MOD        0x10000
#define RTP_MAX_SDES_LEN   256

#define RTP_LOWER_LAYER_OVERHEAD 28	/* IPv4 + UDP */

#define RTCP_SR   200
#define RTCP_RR   201
#define RTCP_SDES 202
#define RTCP_BYE  203
#define RTCP_APP  204

typedef struct {
#ifdef WORDS_BIGENDIAN
	unsigned short  version:2;	/* packet type            */
	unsigned short  p:1;		/* padding flag           */
	unsigned short  count:5;	/* varies by payload type */
	unsigned short  pt:8;		/* payload type           */
#else
	unsigned short  count:5;	/* varies by payload type */
	unsigned short  p:1;		/* padding flag           */
	unsigned short  version:2;	/* packet type            */
	unsigned short  pt:8;		/* payload type           */
#endif
	uint16_t        length;		/* packet length          */
} rtcp_common;

typedef struct {
	rtcp_common   common;	
	union {
		struct {
			rtcp_sr			sr;
			rtcp_rr       	rr[1];		/* variable-length list */
		} sr;
		struct {
			uint32_t        ssrc;		/* source this RTCP packet is coming from */
			rtcp_rr       	rr[1];		/* variable-length list */
		} rr;
		struct rtcp_sdes_t {
			uint32_t	ssrc;
			rtcp_sdes_item 	item[1];	/* list of SDES */
		} sdes;
		struct {
			uint32_t        ssrc[1];	/* list of sources */
			/* can't express the trailing text... */
		} bye;
		struct {
			uint32_t        ssrc;           
			uint8_t         name[4];
			uint8_t         data[1];
		} app;
	} r;
} rtcp_t;

typedef struct _rtcp_rr_wrapper {
	struct _rtcp_rr_wrapper	*next;
	struct _rtcp_rr_wrapper	*prev;
	uint32_t                 reporter_ssrc;
	rtcp_rr			*rr;
	struct timeval		*ts;	/* Arrival time of this RR */
} rtcp_rr_wrapper;

/*
 * The RTP database contains source-specific information needed 
 * to make it all work. 
 */

typedef struct _source {
	struct _source	*next;
	struct _source	*prev;
	uint32_t	 ssrc;
	char		*cname;
	char		*name;
	char		*email;
	char		*phone;
	char		*loc;
	char		*tool;
	char		*note;
	char		*priv;
	rtcp_sr		*sr;
	struct timeval	 last_sr;
	struct timeval	 last_active;
	int		 should_advertise_sdes;	/* TRUE if this source is a CSRC which we need to advertise SDES for */
	int		 sender;
	int		 got_bye;		/* TRUE if we've received an RTCP bye from this source */
	uint32_t	 base_seq;
	uint16_t	 max_seq;
	uint32_t	 bad_seq;
	uint32_t	 cycles;
	int		 received;
	int		 received_prior;
	int		 expected_prior;
	int		 probation;
	uint32_t	 jitter;
	uint32_t	 transit;
	uint32_t	 magic;			/* For debugging... */
} source;

/* The size of the hash table used to hold the source database. */
/* Should be large enough that we're unlikely to get collisions */
/* when sources are added, but not too large that we waste too  */
/* much memory. Sedgewick ("Algorithms", 2nd Ed, Addison-Wesley */
/* 1988) suggests that this should be around 1/10th the number  */
/* of entries that we expect to have in the database and should */
/* be a prime number. Everything continues to work if this is   */
/* too low, it just goes slower... for now we assume around 100 */
/* participants is a sensible limit so we set this to 11.       */   
#define RTP_DB_SIZE	11

/*
 *  Options for an RTP session are stored in the "options" struct.
 */

typedef struct {
	int 	promiscuous_mode;
	int	wait_for_rtcp;
	int	filter_my_packets;
	int	reuse_bufs;
} options;

/*
 * Encryption function types
 */
typedef int (*rtp_encrypt_func)(struct rtp *, unsigned char *data,
								unsigned int size, unsigned char *initvec);
typedef int (*rtp_decrypt_func)(struct rtp *, unsigned char *data,
								unsigned int size, unsigned char *initvec);

/*
 * The "struct rtp" defines an RTP session.
 */


struct rtp {
	rtp_transport_t transport;
	
	socket_udp	*rtp_socket;
	socket_udp	*rtcp_socket;
	socket_tcp	*rtsp_socket; // RTP over RTSP.
	
	char		*addr;
	uint16_t	rx_port;
	uint16_t	tx_port;
	uint8_t		rtsp_rtp;	//RTP interleave line over RTSP
	uint8_t		rtsp_rtcp;	//RTCP interleave line over RTSP
	
	int		 ttl;
	uint32_t	 my_ssrc;
	int		 last_advertised_csrc;
	source		*db[RTP_DB_SIZE];
	rtcp_rr_wrapper  rr[RTP_DB_SIZE][RTP_DB_SIZE]; 	/* Indexed by [hash(reporter)][hash(reportee)] */
	options		*opt;
	void		*userdata;
	int		 invalid_rtp_count;
	int		 invalid_rtcp_count;
	int		 bye_count;
	int		 csrc_count;
	int		 ssrc_count;
	int		 ssrc_count_prev;		/* ssrc_count at the time we last recalculated our RTCP interval */
	int		 sender_count;
	int		 initial_rtcp;
	int		 sending_bye;			/* TRUE if we're in the process of sending a BYE packet */
	double		 avg_rtcp_size;
	int		 we_sent;
	double		 rtcp_bw;			/* RTCP bandwidth fraction, in octets per second. */
	struct timeval	 last_update;
	struct timeval	 last_rtp_send_time;
	struct timeval	 last_rtcp_send_time;
	struct timeval	 next_rtcp_send_time;
	double		 rtcp_interval;
	int		 sdes_count_pri;
	int		 sdes_count_sec;
	int		 sdes_count_ter;
	uint16_t	 rtp_seq;
	uint32_t	 rtp_pcount;
	uint32_t	 rtp_bcount;
	
	/*
	 char 		*encryption_algorithm;
	 int 		 encryption_enabled;
	 rtp_encrypt_func encrypt_func;
	 rtp_decrypt_func decrypt_func;
	 int 		 encryption_pad_length;
	 union {
	 struct {
	 keyInstance keyInstEncrypt;
	 keyInstance keyInstDecrypt;
	 cipherInstance cipherInst;
	 } rijndael;
	 struct {
	 unsigned char  *encryption_key;
	 } des;
	 } crypto_state;
	 */
	rtp_callback	 callback;
	uint32_t	 magic;				/* For debugging...  */
};

static inline int 
filter_event(struct rtp *session, uint32_t ssrc)
{
	return session->opt->filter_my_packets && (ssrc == rtp_my_ssrc(session));
}

static inline double 
tv_diff(struct timeval curr_time, struct timeval prev_time)
{
    /* Return curr_time - prev_time */
    double	ct, pt;
	
    ct = (double) curr_time.tv_sec + (((double) curr_time.tv_usec) / 1000000.0);
    pt = (double) prev_time.tv_sec + (((double) prev_time.tv_usec) / 1000000.0);
    return (ct - pt);
}

static void tv_add(struct timeval *ts, double offset)
{
	/* Add offset seconds to ts */
	double offset_sec, offset_usec;
	
	offset_usec = modf(offset, &offset_sec) * 1000000;
	ts->tv_sec  += (long) offset_sec;
	ts->tv_usec += (long) offset_usec;
	if (ts->tv_usec > 1000000) {
		ts->tv_sec++;
		ts->tv_usec -= 1000000;
	}
}

static int tv_gt(struct timeval a, struct timeval b)
{
	/* Returns (a>b) */
	if (a.tv_sec > b.tv_sec) {
		return TRUE;
	}
	if (a.tv_sec < b.tv_sec) {
		return FALSE;
	}
	assert(a.tv_sec == b.tv_sec);
	return a.tv_usec > b.tv_usec;
}

static uint32_t next_csrc(struct rtp *session)
{
	/* This returns each source marked "should_advertise_sdes" in turn. */
	int	 chain, cc;
	source	*s;
	
	cc = 0;
	for (chain = 0; chain < RTP_DB_SIZE; chain++) {
		/* Check that the linked lists making up the chains in */
		/* the hash table are correctly linked together...     */
		for (s = session->db[chain]; s != NULL; s = s->next) {
			if (s->should_advertise_sdes) {
				if (cc == session->last_advertised_csrc) {
					session->last_advertised_csrc++;
					if (session->last_advertised_csrc == session->csrc_count) {
						session->last_advertised_csrc = 0;
					}
					return s->ssrc;
				} else {
					cc++;
				}
			}
		}
	}
	/* We should never get here... */
	abort();
}

static int ssrc_hash(uint32_t ssrc)
{
	/* Hash from an ssrc to a position in the source database.   */
	/* Assumes that ssrc values are uniformly distributed, which */
	/* should be true but probably isn't (Rosenberg has reported */
	/* that many implementations generate ssrc values which are  */
	/* not uniformly distributed over the space, and the H.323   */
	/* spec requires that they are non-uniformly distributed).   */
	/* This routine is written as a function rather than inline  */
	/* code to allow it to be made smart in future: probably we  */
	/* should run MD5 on the ssrc and derive a hash value from   */
	/* that, to ensure it's more uniformly distributed?          */
	return ssrc % RTP_DB_SIZE;
}

static void insert_rr(struct rtp *session, uint32_t reporter_ssrc, rtcp_rr *rr, struct timeval *ts)
{
	/* Insert the reception report into the receiver report      */
	/* database. This database is a two dimensional table of     */
	/* rr_wrappers indexed by hashes of reporter_ssrc and        */
	/* reportee_src.  The rr_wrappers in the database are        */
	/* sentinels to reduce conditions in list operations.        */
	/* The ts is used to determine when to timeout this rr.      */
	
	rtcp_rr_wrapper *cur, *start;
	
	start = &session->rr[ssrc_hash(reporter_ssrc)][ssrc_hash(rr->ssrc)];
	cur   = start->next;
	
	while (cur != start) {
		if (cur->reporter_ssrc == reporter_ssrc && cur->rr->ssrc == rr->ssrc) {
			/* Replace existing entry in the database  */
			xfree(cur->rr);
			xfree(cur->ts);
			cur->rr = rr;
			cur->ts = (struct timeval *) xmalloc(sizeof(struct timeval));
			memcpy(cur->ts, ts, sizeof(struct timeval));
			return;
		}
		cur = cur->next;
	}
	
	/* No entry in the database so create one now. */
	cur = (rtcp_rr_wrapper*)xmalloc(sizeof(rtcp_rr_wrapper));
	cur->reporter_ssrc = reporter_ssrc;
	cur->rr = rr;
	cur->ts = (struct timeval *) xmalloc(sizeof(struct timeval));
	memcpy(cur->ts, ts, sizeof(struct timeval));
	/* Fix links */
	cur->next       = start->next;
	cur->next->prev = cur;
	cur->prev       = start;
	cur->prev->next = cur;
	
	debug_msg("Created new rr entry for 0x%08lx from source 0x%08lx\n", rr->ssrc, reporter_ssrc);
	return;
}

static void remove_rr(struct rtp *session, uint32_t ssrc)
{
	/* Remove any RRs from "s" which refer to "ssrc" as either   */
	/* reporter or reportee.                                     */
	rtcp_rr_wrapper *start, *cur, *tmp;
	int i;
	
	/* Remove rows, i.e. ssrc == reporter_ssrc                   */
	for(i = 0; i < RTP_DB_SIZE; i++) {
		start = &session->rr[ssrc_hash(ssrc)][i];
		cur   = start->next;
		while (cur != start) {
			if (cur->reporter_ssrc == ssrc) {
				tmp = cur;
				cur = cur->prev;
				tmp->prev->next = tmp->next;
				tmp->next->prev = tmp->prev;
				xfree(tmp->ts);
				xfree(tmp->rr);
				xfree(tmp);
			}
			cur = cur->next;
		}
	}
	
	/* Remove columns, i.e.  ssrc == reporter_ssrc */
	for(i = 0; i < RTP_DB_SIZE; i++) {
		start = &session->rr[i][ssrc_hash(ssrc)];
		cur   = start->next;
		while (cur != start) {
			if (cur->rr->ssrc == ssrc) {
				tmp = cur;
				cur = cur->prev;
				tmp->prev->next = tmp->next;
				tmp->next->prev = tmp->prev;
				xfree(tmp->ts);
				xfree(tmp->rr);
				xfree(tmp);
			}
			cur = cur->next;
		}
	}
}

static void timeout_rr(struct rtp *session, struct timeval *curr_ts)
{
	/* Timeout any reception reports which have been in the database for more than 3 */
	/* times the RTCP reporting interval without refresh.                            */
	rtcp_rr_wrapper *start, *cur, *tmp;
	rtp_event	 event;
	int 		 i, j;
	
	for(i = 0; i < RTP_DB_SIZE; i++) {
		for(j = 0; j < RTP_DB_SIZE; j++) {
			start = &session->rr[i][j];
			cur   = start->next;
			while (cur != start) {
				if (tv_diff(*curr_ts, *(cur->ts)) > (session->rtcp_interval * 3)) {
					/* Signal the application... */
					if (!filter_event(session, cur->reporter_ssrc)) {
						event.ssrc = cur->reporter_ssrc;
						event.type = RR_TIMEOUT;
						event.data = cur->rr;
						event.ts   = curr_ts;
						session->callback(session, &event);
					}
					/* Delete this reception report... */
					tmp = cur;
					cur = cur->prev;
					tmp->prev->next = tmp->next;
					tmp->next->prev = tmp->prev;
					xfree(tmp->ts);
					xfree(tmp->rr);
					xfree(tmp);
				}
				cur = cur->next;
			}
		}
	}
}

static const rtcp_rr* get_rr(struct rtp *session, uint32_t reporter_ssrc, uint32_t reportee_ssrc)
{
	rtcp_rr_wrapper *cur, *start;
	
	start = &session->rr[ssrc_hash(reporter_ssrc)][ssrc_hash(reportee_ssrc)];
	cur   = start->next;
	while (cur != start) {
		if (cur->reporter_ssrc == reporter_ssrc &&
			cur->rr->ssrc      == reportee_ssrc) {
			return cur->rr;
		}
		cur = cur->next;
	}
	return NULL;
}

static inline void 
check_source(source *s)
{
#ifdef DEBUG
	assert(s != NULL);
	assert(s->magic == 0xc001feed);
#else
	UNUSED(s);
#endif
}

static inline void 
check_database(struct rtp *session)
{
	/* This routine performs a sanity check on the database. */
	/* This should not call any of the other routines which  */
	/* manipulate the database, to avoid common failures.    */
#ifdef DEBUG
	source 	 	*s;
	int	 	 source_count;
	int		 chain;
	
	assert(session != NULL);
	assert(session->magic == 0xfeedface);
	/* Check that we have a database entry for our ssrc... */
	/* We only do this check if ssrc_count > 0 since it is */
	/* performed during initialisation whilst creating the */
	/* source entry for my_ssrc.                           */
	if (session->ssrc_count > 0) {
		for (s = session->db[ssrc_hash(session->my_ssrc)]; s != NULL; s = s->next) {
			if (s->ssrc == session->my_ssrc) {
				break;
			}
		}
		assert(s != NULL);
	}
	
	source_count = 0;
	for (chain = 0; chain < RTP_DB_SIZE; chain++) {
		/* Check that the linked lists making up the chains in */
		/* the hash table are correctly linked together...     */
		for (s = session->db[chain]; s != NULL; s = s->next) {
			check_source(s);
			source_count++;
			if (s->prev == NULL) {
				assert(s == session->db[chain]);
			} else {
				assert(s->prev->next == s);
			}
			if (s->next != NULL) {
				assert(s->next->prev == s);
			}
			/* Check that the SR is for this source... */
			if (s->sr != NULL) {
				assert(s->sr->ssrc == s->ssrc);
			}
		}
	}
	/* Check that the number of entries in the hash table  */
	/* matches session->ssrc_count                         */
	assert(source_count == session->ssrc_count);
#else 
	UNUSED(session);
#endif
}

static inline source *
get_source(struct rtp *session, uint32_t ssrc)
{
	source *s;
	
	check_database(session);
	for (s = session->db[ssrc_hash(ssrc)]; s != NULL; s = s->next) {
		if (s->ssrc == ssrc) {
			check_source(s);
			return s;
		}
	}
	return NULL;
}

static source *
create_source(struct rtp *session, uint32_t ssrc, int probation)
{
	/* Create a new source entry, and add it to the database.    */
	/* The database is a hash table, using the separate chaining */
	/* algorithm.                                                */
	rtp_event	 event;
	struct timeval	 event_ts;
	source		*s = get_source(session, ssrc);
	int		 h;
	
	if (s != NULL) {
		/* Source is already in the database... Mark it as */
		/* active and exit (this is the common case...)    */
		gettimeofday(&(s->last_active), NULL);
		return s;
	}
	check_database(session);
	/* This is a new source, we have to create it... */
	h = ssrc_hash(ssrc);
	s = (source *) xmalloc(sizeof(source));
	memset(s, 0, sizeof(source));
	s->magic          = 0xc001feed;
	s->next           = session->db[h];
	s->ssrc           = ssrc;
	if (probation) {
		/* This is a probationary source, which only counts as */
		/* valid once several consecutive packets are received */
		s->probation = -1;
	} else {
		s->probation = 0;
	}
	
	gettimeofday(&(s->last_active), NULL);
	/* Now, add it to the database... */
	if (session->db[h] != NULL) {
		session->db[h]->prev = s;
	}
	session->db[ssrc_hash(ssrc)] = s;
	session->ssrc_count++;
	check_database(session);
	
	debug_msg("Created database entry for ssrc 0x%08lx (%d valid sources)\n", ssrc, session->ssrc_count);
	if (ssrc != session->my_ssrc) {
		/* Do not send during rtp_init since application cannot map the address */
		/* of the rtp session to anything since rtp_init has not returned yet.  */
		if (!filter_event(session, ssrc)) {
			gettimeofday(&event_ts, NULL);
			event.ssrc = ssrc;
			event.type = SOURCE_CREATED;
			event.data = NULL;
			event.ts   = &event_ts;
			session->callback(session, &event);
		}
	}
	
	return s;
}

static void delete_source(struct rtp *session, uint32_t ssrc)
{
	/* Remove a source from the RTP database... */
	source		*s = get_source(session, ssrc);
	int		 h = ssrc_hash(ssrc);
	rtp_event	 event;
	struct timeval	 event_ts;
	
	assert(s != NULL);	/* Deleting a source which doesn't exist is an error... */
	
	gettimeofday(&event_ts, NULL);
	
	check_source(s);
	check_database(session);
	if (session->db[h] == s) {
		/* It's the first entry in this chain... */
		session->db[h] = s->next;
		if (s->next != NULL) {
			s->next->prev = NULL;
		}
	} else {
		assert(s->prev != NULL);	/* Else it would be the first in the chain... */
		s->prev->next = s->next;
		if (s->next != NULL) {
			s->next->prev = s->prev;
		}
	}
	/* Free the memory allocated to a source... */
	if (s->cname != NULL) xfree(s->cname);
	if (s->name  != NULL) xfree(s->name);
	if (s->email != NULL) xfree(s->email);
	if (s->phone != NULL) xfree(s->phone);
	if (s->loc   != NULL) xfree(s->loc);
	if (s->tool  != NULL) xfree(s->tool);
	if (s->note  != NULL) xfree(s->note);
	if (s->priv  != NULL) xfree(s->priv);
	if (s->sr    != NULL) xfree(s->sr);
	
	remove_rr(session, ssrc); 
	
	/* Reduce our SSRC count, and perform reverse reconsideration on the RTCP */
	/* reporting interval (draft-ietf-avt-rtp-new-05.txt, section 6.3.4). To  */
	/* make the transmission rate of RTCP packets more adaptive to changes in */
	/* group membership, the following "reverse reconsideration" algorithm    */
	/* SHOULD be executed when a BYE packet is received that reduces members  */
	/* to a value less than pmembers:                                         */
	/* o  The value for tn is updated according to the following formula:     */
	/*       tn = tc + (members/pmembers)(tn - tc)                            */
	/* o  The value for tp is updated according the following formula:        */
	/*       tp = tc - (members/pmembers)(tc - tp).                           */
	/* o  The next RTCP packet is rescheduled for transmission at time tn,    */
	/*    which is now earlier.                                               */
	/* o  The value of pmembers is set equal to members.                      */
	session->ssrc_count--;
	if (session->ssrc_count < session->ssrc_count_prev) {
		gettimeofday(&(session->next_rtcp_send_time), NULL);
		gettimeofday(&(session->last_rtcp_send_time), NULL);
		tv_add(&(session->next_rtcp_send_time), (session->ssrc_count / session->ssrc_count_prev) 
			   * tv_diff(session->next_rtcp_send_time, event_ts));
		tv_add(&(session->last_rtcp_send_time), - ((session->ssrc_count / session->ssrc_count_prev) 
												   * tv_diff(event_ts, session->last_rtcp_send_time)));
		session->ssrc_count_prev = session->ssrc_count;
	}
	
	/* Reduce our csrc count... */
	if (s->should_advertise_sdes == TRUE) {
		session->csrc_count--;
	}
	if (session->last_advertised_csrc == session->csrc_count) {
		session->last_advertised_csrc = 0;
	}
	
	/* Signal to the application that this source is dead... */
	if (!filter_event(session, ssrc)) {
		event.ssrc = ssrc;
		event.type = SOURCE_DELETED;
		event.data = NULL;
		event.ts   = &event_ts;
		session->callback(session, &event);
	}
	xfree(s);
	check_database(session);
}

static inline void 
init_seq(source *s, uint16_t seq)
{
	/* Taken from draft-ietf-avt-rtp-new-01.txt */
	check_source(s);
	s->base_seq = seq;
	s->max_seq = seq;
	s->bad_seq = RTP_SEQ_MOD + 1;
	s->cycles = 0;
	s->received = 0;
	s->received_prior = 0;
	s->expected_prior = 0;
}

static int update_seq(source *s, uint16_t seq)
{
	/* Taken from draft-ietf-avt-rtp-new-01.txt */
	uint16_t udelta = seq - s->max_seq;
	
	/*
	 * Source is not valid until MIN_SEQUENTIAL packets with
	 * sequential sequence numbers have been received.
	 */
	check_source(s);
	if (s->probation) {
		/* packet is in sequence */
		if (seq == s->max_seq + 1) {
			s->probation--;
			s->max_seq = seq;
			if (s->probation == 0) {
				init_seq(s, seq);
				s->received++;
				return 1;
			}
		} else {
			s->probation = MIN_SEQUENTIAL - 1;
			s->max_seq = seq;
		}
		return 0;
	} else if (udelta < MAX_DROPOUT) {
		/* in order, with permissible gap */
		if (seq < s->max_seq) {
			/*
			 * Sequence number wrapped - count another 64K cycle.
			 */
			s->cycles += RTP_SEQ_MOD;
		}
		s->max_seq = seq;
	} else if (udelta <= RTP_SEQ_MOD - MAX_MISORDER) {
		/* the sequence number made a very large jump */
		if (seq == s->bad_seq) {
			/*
			 * Two sequential packets -- assume that the other side
			 * restarted without telling us so just re-sync
			 * (i.e., pretend this was the first packet).
			 */
			init_seq(s, seq);
		} else {
			s->bad_seq = (seq + 1) & (RTP_SEQ_MOD-1);
			return 0;
		}
	} else {
		/* duplicate or reordered packet */
	}
	s->received++;
	return 1;
}

static double 
rtcp_interval(struct rtp *session)
{
	/* Minimum average time between RTCP packets from this site (in   */
	/* seconds).  This time prevents the reports from `clumping' when */
	/* sessions are small and the law of large numbers isn't helping  */
	/* to smooth out the traffic.  It also keeps the report interval  */
	/* from becoming ridiculously small during transient outages like */
	/* a network partition.                                           */
	double const RTCP_MIN_TIME = 5.0;
	/* Fraction of the RTCP bandwidth to be shared among active       */
	/* senders.  (This fraction was chosen so that in a typical       */
	/* session with one or two active senders, the computed report    */
	/* time would be roughly equal to the minimum report time so that */
	/* we don't unnecessarily slow down receiver reports.) The        */
	/* receiver fraction must be 1 - the sender fraction.             */
	double const RTCP_SENDER_BW_FRACTION = 0.25;
	double const RTCP_RCVR_BW_FRACTION   = (1-RTCP_SENDER_BW_FRACTION);
	/* To compensate for "unconditional reconsideration" converging   */
	/* to a value below the intended average.                         */
	double const COMPENSATION            = 2.71828 - 1.5;
	
	double t;				              /* interval */
	double rtcp_min_time = RTCP_MIN_TIME;
	int n;			        /* no. of members for computation */
	double rtcp_bw = session->rtcp_bw;
	
	/* Very first call at application start-up uses half the min      */
	/* delay for quicker notification while still allowing some time  */
	/* before reporting for randomization and to learn about other    */
	/* sources so the report interval will converge to the correct    */
	/* interval more quickly.                                         */
	if (session->initial_rtcp) {
		rtcp_min_time /= 2;
	}
	
	/* If there were active senders, give them at least a minimum     */
	/* share of the RTCP bandwidth.  Otherwise all participants share */
	/* the RTCP bandwidth equally.                                    */
	if (session->sending_bye) {
		n = session->bye_count;
	} else {
		n = session->ssrc_count;
	}
	if (session->sender_count > 0 && session->sender_count < n * RTCP_SENDER_BW_FRACTION) {
		if (session->we_sent) {
			rtcp_bw *= RTCP_SENDER_BW_FRACTION;
			n = session->sender_count;
		} else {
			rtcp_bw *= RTCP_RCVR_BW_FRACTION;
			n -= session->sender_count;
		}
	}
	
	/* The effective number of sites times the average packet size is */
	/* the total number of octets sent when each site sends a report. */
	/* Dividing this by the effective bandwidth gives the time        */
	/* interval over which those packets must be sent in order to     */
	/* meet the bandwidth target, with a minimum enforced.  In that   */
	/* time interval we send one report so this time is also our      */
	/* average time between reports.                                  */
	t = session->avg_rtcp_size * n / rtcp_bw;
	if (t < rtcp_min_time) {
		t = rtcp_min_time;
	}
	session->rtcp_interval = t;
	
	/* To avoid traffic bursts from unintended synchronization with   */
	/* other sites, we then pick our actual next report interval as a */
	/* random number uniformly distributed between 0.5*t and 1.5*t.   */
	return (t * (drand48() + 0.5)) / COMPENSATION;
}

#define MAXCNAMELEN	255

static char *get_cname(struct rtp *session)
{
	/* Set the CNAME. This is "user@hostname" or just "hostname" if the username cannot be found. */
	const char              *hname = NULL;
	char                    *uname;
	char                    *cname;
	struct passwd           *pwent;
	
	cname = (char *) xmalloc(MAXCNAMELEN + 1);
	cname[0] = '\0';
	
	/* First, fill in the username... */
	uname = NULL;
	pwent = getpwuid(getuid());
	if (pwent != NULL) {
		uname = pwent->pw_name;
	}
	if (uname != NULL) {
		strncpy(cname, uname, MAXCNAMELEN - 1);
		strcat(cname, "@");
	}
	
	/* Now the hostname. Must be dotted-quad IP address. */
	if(session->transport == RTP_TRANSPORT_UDP) {
		hname = udp_host_addr(session->rtp_socket);
	}
	else if(session->transport == RTP_TRANSPORT_TCP) {
		hname = tcp_host_addr(session->rtsp_socket);
	}
	if (hname == NULL) {
		/* If we can't get our IP address we use the loopback address... */
		/* This is horrible, but it stops the code from failing.         */
		hname = "127.0.0.1";
	}
	strncpy(cname + strlen(cname), hname, MAXCNAMELEN - strlen(cname));
	return cname;
}

static void init_opt(struct rtp *session)
{
	/* Default option settings. */
	rtp_set_option(session, RTP_OPT_PROMISC,           FALSE);
	rtp_set_option(session, RTP_OPT_WEAK_VALIDATION,   FALSE);
	rtp_set_option(session, RTP_OPT_FILTER_MY_PACKETS, FALSE);
	rtp_set_option(session, RTP_OPT_REUSE_PACKET_BUFS, FALSE);
}

static void init_rng(const char *s)
{
	static uint32_t seed;
	if (s == NULL) {
		/* This should never happen, but just in case */
		s = "ARANDOMSTRINGSOWEDONTCOREDUMP";
	}
	if (seed == 0) {
		pid_t p = getpid();
		int32_t i=0, n=0;//SV-XXX
		while (*s) {
			seed += (uint32_t)*s++;
			seed = seed * 31 + 1;
		}
		seed = 1 + seed * 31 + (uint32_t)p;
		srand48(seed);
		UNUSED(i);
		UNUSED(n);
	}
}

/* See rtp_init_if(); calling rtp_init() is just like calling
 * rtp_init_if() with a NULL interface argument.
 */

/**
 * rtp_init:
 * @addr: IP destination of this session (unicast or multicast),
 * as an ASCII string.  May be a host name, which will be looked up,
 * or may be an IPv4 dotted quad or IPv6 literal adddress.
 * @rx_port: The port to which to bind the UDP socket
 * @tx_port: The port to which to send UDP packets
 * @ttl: The TTL with which to send multicasts
 * @rtcp_bw: The total bandwidth (in units of bytes per second) that is
 * allocated to RTCP.
 * @callback: See section on #rtp_callback.
 * @userdata: Opaque data associated with the session.  See
 * rtp_get_userdata().
 *
 *
 * Returns: An opaque session identifier to be used in future calls to
 * the RTP library functions, or NULL on failure.
 */
struct rtp *rtp_init_udp(const char *addr, 
					 uint16_t rx_port, uint16_t tx_port, 
					 int ttl, double rtcp_bw, 
                     rtp_callback callback,
                     void *userdata)
{
	return rtp_init_udp_if(addr, NULL, rx_port, tx_port, ttl, rtcp_bw, callback, userdata);
}

/**
 * rtp_init_udp_if:
 * @addr: IP destination of this session (unicast or multicast),
 * as an ASCII string.  May be a host name, which will be looked up,
 * or may be an IPv4 dotted quad or IPv6 literal adddress.
 * @iface: If the destination of the session is multicast,
 * the optional interface to bind to.  May be NULL, in which case
 * the default multicast interface as determined by the system
 * will be used.
 * @rx_port: The port to which to bind the UDP socket
 * @tx_port: The port to which to send UDP packets
 * @ttl: The TTL with which to send multicasts
 * @rtcp_bw: The total bandwidth (in units of ___) that is
 * allocated to RTCP.
 * @callback: See section on #rtp_callback.
 * @userdata: Opaque data associated with the session.  See
 * rtp_get_userdata().
 *
 * Creates and initializes an RTP session.
 *
 * Returns: An opaque session identifier to be used in future calls to
 * the RTP library functions, or NULL on failure.
 */
struct rtp *rtp_init_udp_if(const char *addr, char *iface, 
						uint16_t rx_port, uint16_t tx_port, 
						int ttl, double rtcp_bw, 
                        rtp_callback callback,
                        void *userdata)
{
	struct rtp 	*session;
	int         	 i, j;
	char		*cname;
	
	if (ttl < 0) {
		debug_msg("ttl must be greater than zero\n");
		return NULL;
	}
	if (rx_port % 2) {
		debug_msg("rx_port should be even\n");
	}
	if (tx_port % 2) {
		debug_msg("tx_port should be even\n");
	}
	
	session 		= (struct rtp *) xmalloc(sizeof(struct rtp));
	memset (session, 0, sizeof(struct rtp));
	
	session->magic		= 0xfeedface;
	session->opt		= (options *) xmalloc(sizeof(options));
	session->userdata	= userdata;
	session->transport	= RTP_TRANSPORT_UDP;
	session->addr		= xstrdup(addr);
	session->rx_port	= rx_port;
	session->tx_port	= tx_port;
	session->ttl		= min(ttl, 255);
	session->rtp_socket	= udp_init_if(addr, iface, rx_port, tx_port, ttl);
	session->rtcp_socket = udp_init_if(addr, iface, (uint16_t) (rx_port+1), (uint16_t) (tx_port+1), ttl);
	
	init_opt(session);
	
	if (session->rtp_socket == NULL || session->rtcp_socket == NULL) {
		xfree(session);
		return NULL;
	}
	
	init_rng(udp_host_addr(session->rtp_socket));
	
	session->my_ssrc            = (uint32_t) lrand48();
	session->callback           = callback;
	session->invalid_rtp_count  = 0;
	session->invalid_rtcp_count = 0;
	session->bye_count          = 0;
	session->csrc_count         = 0;
	session->ssrc_count         = 0;
	session->ssrc_count_prev    = 0;
	session->sender_count       = 0;
	session->initial_rtcp       = TRUE;
	session->sending_bye        = FALSE;
	session->avg_rtcp_size      = -1;	/* Sentinal value: reception of first packet starts initial value... */
	session->we_sent            = FALSE;
	session->rtcp_bw            = rtcp_bw;
	session->sdes_count_pri     = 0;
	session->sdes_count_sec     = 0;
	session->sdes_count_ter     = 0;
	session->rtp_seq            = (uint16_t) lrand48();
	session->rtp_pcount         = 0;
	session->rtp_bcount         = 0;
	
//	session->last_update.tv_sec = 0;
//	session->last_update.tv_usec= 0;
//	session->last_rtcp_send_time.tv_sec = 0;
//	session->last_rtcp_send_time.tv_usec= 0;
//	session->next_rtcp_send_time.tv_sec = 0;
//	session->next_rtcp_send_time.tv_usec= 0;
	
	gettimeofday(&(session->last_update), NULL);
	gettimeofday(&(session->last_rtcp_send_time), NULL);
	gettimeofday(&(session->next_rtcp_send_time), NULL);
	
	//    session->encryption_enabled = 0;
	//	session->encryption_algorithm = NULL;
	
	/* Calculate when we're supposed to send our first RTCP packet... */
	tv_add(&(session->next_rtcp_send_time), rtcp_interval(session));
	
	/* Initialise the source database... */
	for (i = 0; i < RTP_DB_SIZE; i++) {
		session->db[i] = NULL;
	}
	session->last_advertised_csrc = 0;
	
	/* Initialize sentinels in rr table */
	for (i = 0; i < RTP_DB_SIZE; i++) {
		for (j = 0; j < RTP_DB_SIZE; j++) {
			session->rr[i][j].next = &session->rr[i][j];
			session->rr[i][j].prev = &session->rr[i][j];
		}
	}
	
	/* Create a database entry for ourselves... */
	create_source(session, session->my_ssrc, FALSE);
	cname = get_cname(session);
	rtp_set_sdes(session, session->my_ssrc, RTCP_SDES_CNAME, cname, strlen(cname));
	xfree(cname);	/* cname is copied by rtp_set_sdes()... */
	
	return session;
}

/**
 * rtp_init_tcp:
 * @socket_fd: The TCP socket discriptor (RTSP socket).
 * @mode: 4 for ip4 or 6 for ip6
 * @interleave_start: The interleave start number.
 * @ttl: The TTL with which to send multicasts
 * @rtcp_bw: The total bandwidth (in units of bytes per second) that is
 * allocated to RTCP.
 * @callback: See section on #rtp_callback.
 * @userdata: Opaque data associated with the session.  See
 * rtp_get_userdata().
 *
 * 
 *
 * Returns: An opaque session identifier to be used in future calls to
 * the RTP library functions, or NULL on failure.
 */
struct rtp *rtp_init_tcp(int socket_fd, int mode,
						 uint8_t interleave_start,
						 int ttl, double rtcp_bw, 
						 rtp_callback callback,
						 void *userdata)
{
	struct rtp 	*session;
	int         	 i, j;
	char		*cname;
	
	if (ttl < 0) {
		debug_msg("ttl must be greater than zero\n");
		return NULL;
	}
	
	session 		= (struct rtp *) xmalloc(sizeof(struct rtp));
	memset (session, 0, sizeof(struct rtp));
	
	session->transport	= RTP_TRANSPORT_TCP;
	session->magic		= 0xfeedface;
	session->opt		= (options *) xmalloc(sizeof(options));
	session->userdata	= userdata;
	//session->addr		= xstrdup(addr);
	session->ttl		= min(ttl, 255);
	session->rtsp_rtp	= interleave_start++;
	session->rtsp_rtcp	= interleave_start;

	
	session->rtsp_socket = tcp_init(socket_fd, ttl, mode);
	
	init_opt(session);
	
	
	init_rng(tcp_host_addr(session->rtsp_socket));
	
	session->my_ssrc            = (uint32_t) lrand48();
	session->callback           = callback;
	session->invalid_rtp_count  = 0;
	session->invalid_rtcp_count = 0;
	session->bye_count          = 0;
	session->csrc_count         = 0;
	session->ssrc_count         = 0;
	session->ssrc_count_prev    = 0;
	session->sender_count       = 0;
	session->initial_rtcp       = TRUE;
	session->sending_bye        = FALSE;
	session->avg_rtcp_size      = -1;	/* Sentinal value: reception of first packet starts initial value... */
	session->we_sent            = FALSE;
	session->rtcp_bw            = rtcp_bw;
	session->sdes_count_pri     = 0;
	session->sdes_count_sec     = 0;
	session->sdes_count_ter     = 0;
	session->rtp_seq            = (uint16_t) lrand48();
	session->rtp_pcount         = 0;
	session->rtp_bcount         = 0;
	
	//	session->last_update.tv_sec = 0;
	//	session->last_update.tv_usec= 0;
	//	session->last_rtcp_send_time.tv_sec = 0;
	//	session->last_rtcp_send_time.tv_usec= 0;
	//	session->next_rtcp_send_time.tv_sec = 0;
	//	session->next_rtcp_send_time.tv_usec= 0;
	
	gettimeofday(&(session->last_update), NULL);
	gettimeofday(&(session->last_rtcp_send_time), NULL);
	gettimeofday(&(session->next_rtcp_send_time), NULL);
	
	//    session->encryption_enabled = 0;
	//	session->encryption_algorithm = NULL;
	
	/* Calculate when we're supposed to send our first RTCP packet... */
	tv_add(&(session->next_rtcp_send_time), rtcp_interval(session));
	
	/* Initialise the source database... */
	for (i = 0; i < RTP_DB_SIZE; i++) {
		session->db[i] = NULL;
	}
	session->last_advertised_csrc = 0;
	
	/* Initialize sentinels in rr table */
	for (i = 0; i < RTP_DB_SIZE; i++) {
		for (j = 0; j < RTP_DB_SIZE; j++) {
			session->rr[i][j].next = &session->rr[i][j];
			session->rr[i][j].prev = &session->rr[i][j];
		}
	}
	
	/* Create a database entry for ourselves... */
	create_source(session, session->my_ssrc, FALSE);
	cname = get_cname(session);
	rtp_set_sdes(session, session->my_ssrc, RTCP_SDES_CNAME, cname, strlen(cname));
	xfree(cname);	/* cname is copied by rtp_set_sdes()... */
	
	return session;
}


/**
 * rtp_set_my_ssrc:
 * @session: the RTP session 
 * @ssrc: the SSRC to be used by the RTP session
 * 
 * This function coerces the local SSRC identifer to be ssrc.  For
 * this function to succeed it must be called immediately after
 * rtp_init or rtp_init_if.  The intended purpose of this
 * function is to co-ordinate SSRC's between layered sessions, it
 * should not be used otherwise.
 *
 * Returns: TRUE on success, FALSE otherwise.  
 */
int rtp_set_my_ssrc(struct rtp *session, uint32_t ssrc)
{
	source *s;
	uint32_t h;
	
	if (session->ssrc_count != 1 && session->sender_count != 0) {
		return FALSE;
	}
	/* Remove existing source */
	h = ssrc_hash(session->my_ssrc);
	s = session->db[h];
	session->db[h] = NULL;
	/* Fill in new ssrc       */
	session->my_ssrc = ssrc;
	s->ssrc          = ssrc;
	h                = ssrc_hash(ssrc);
	/* Put source back        */
	session->db[h]   = s;
	return TRUE;
}

/**
 * rtp_set_option:
 * @session: The RTP session.
 * @optname: The option name, see #rtp_option.
 * @optval: The value to set.
 *
 * Sets the value of a session option.  See #rtp_option for
 * documentation on the options and their legal values.
 *
 * Returns: TRUE on success, else FALSE.
 */
int rtp_set_option(struct rtp *session, rtp_option optname, int optval)
{
	assert((optval == TRUE) || (optval == FALSE));
	
	switch (optname) {
		case RTP_OPT_WEAK_VALIDATION:
			session->opt->wait_for_rtcp = optval;
			break;
		case RTP_OPT_PROMISC:
			session->opt->promiscuous_mode = optval;
			break;
		case RTP_OPT_FILTER_MY_PACKETS:
			session->opt->filter_my_packets = optval;
			break;
		case RTP_OPT_REUSE_PACKET_BUFS:
			session->opt->reuse_bufs = optval;
			break;
		default:
			debug_msg("Ignoring unknown option (%d) in call to rtp_set_option().\n", optname);
			return FALSE;
	}
	return TRUE;
}

/**
 * rtp_get_option:
 * @session: The RTP session.
 * @optname: The option name, see #rtp_option.
 * @optval: The return value.
 *
 * Retrieves the value of a session option.  See #rtp_option for
 * documentation on the options and their legal values.
 *
 * Returns: TRUE and the value of the option in optval on success, else FALSE.
 */
int rtp_get_option(struct rtp *session, rtp_option optname, int *optval)
{
	switch (optname) {
		case RTP_OPT_WEAK_VALIDATION:
			*optval = session->opt->wait_for_rtcp;
			break;
		case RTP_OPT_PROMISC:
			*optval = session->opt->promiscuous_mode;
			break;
		case RTP_OPT_FILTER_MY_PACKETS:
			*optval = session->opt->filter_my_packets;
			break;
		case RTP_OPT_REUSE_PACKET_BUFS:
			*optval = session->opt->reuse_bufs;
			break;
		default:
			*optval = 0;
			debug_msg("Ignoring unknown option (%d) in call to rtp_get_option().\n", optname);
			return FALSE;
	}
	return TRUE;
}

/**
 * rtp_get_userdata:
 * @session: The RTP session.
 *
 * This function returns the userdata pointer that was passed to the
 * rtp_init() or rtp_init_if() function when creating this session.
 *
 * Returns: pointer to userdata.
 */
void* rtp_get_userdata(struct rtp *session)
{
	check_database(session);
	return session->userdata;
}

/**
 * rtp_my_ssrc:
 * @session: The RTP Session.
 *
 * Returns: The SSRC we are currently using in this session. Note that our
 * SSRC can change at any time (due to collisions) so applications must not
 * store the value returned, but rather should call this function each time 
 * they need it.
 */
uint32_t rtp_my_ssrc(struct rtp *session)
{
	check_database(session);
	return session->my_ssrc;
}

static void process_rtp(struct rtp *session, uint32_t curr_rtp_ts, rtp_packet *packet, source *s)
{
	int		 i, d, transit;
	rtp_event	 event;
	struct timeval	 event_ts;
	
	if (packet->fields.cc > 0) {
		for (i = 0; i < packet->fields.cc; i++) {
			create_source(session, packet->meta.csrc[i], FALSE);
		}
	}
	/* Update the source database... */
	if (s->sender == FALSE) {
		s->sender = TRUE;
		session->sender_count++;
	}
	transit    = curr_rtp_ts - packet->fields.ts;
	d      	   = transit - s->transit;
	s->transit = transit;
	if (d < 0) {
		d = -d;
	}
	s->jitter += d - ((s->jitter + 8) / 16);
	
	/* Callback to the application to process the packet... */
	if (!filter_event(session, packet->fields.ssrc)) {
		gettimeofday(&event_ts, NULL);
		event.ssrc = packet->fields.ssrc;
		event.type = RX_RTP;
		event.data = (void *) packet;	/* The callback function MUST free this! */
		event.ts   = &event_ts;
		session->callback(session, &event);
	}
}

static int validate_rtp2(rtp_packet *packet, int len)
{
	/* Check for valid payload types..... 72-76 are RTCP payload type numbers, with */
	/* the high bit missing so we report that someone is running on the wrong port. */
    if (packet->fields.pt >= 72 && packet->fields.pt <= 76) {
		debug_msg("rtp_header_validation: payload-type invalid");
        if (packet->fields.m) {
			debug_msg(" (RTCP packet on RTP port?)");
		}
		debug_msg("\n");
		return FALSE;
	}
	
	/* Check that the length of the packet is sensible... */
	if (len < (12 + (4 * packet->fields.cc))) {
		debug_msg("rtp_header_validation: packet length is smaller than the header\n");
		return FALSE;
	}
	/* Check that the amount of padding specified is sensible. */
	/* Note: have to include the size of any extension header! */
	if (packet->fields.p) {
		int     payload_len = len - 12 - (packet->fields.cc * 4);
		if (packet->fields.x) {
			/* extension header and data */
			payload_len -= 4 * (1 + packet->meta.extn_len);
		}
		if (packet->meta.data[packet->meta.data_len - 1] > payload_len) {
			debug_msg("rtp_header_validation: padding greater than payload length\n");
			return FALSE;
		}
		if (packet->meta.data[packet->meta.data_len - 1] < 1) {
			debug_msg("rtp_header_validation: padding zero\n");
			return FALSE;
		}
	}
	return TRUE;
}

static inline int 
validate_rtp(struct rtp *session, rtp_packet *packet, int len)
{
	/* This function checks the header info to make sure that the packet */
	/* is valid. We return TRUE if the packet is valid, FALSE otherwise. */
	/* See Appendix A.1 of the RTP specification.                        */
	
	/* We only accept RTPv2 packets... */
	
	if (packet->fields.v != 2) {
		debug_msg("rtp_header_validation: v != 2\n");
		return FALSE;
	}
	
	return validate_rtp2(packet, len);
}

static void 
rtp_recv_data_udp(struct rtp *session, uint32_t curr_rtp_ts)
{
	/* This routine preprocesses an incoming RTP packet, deciding whether to process it. */
	static rtp_packet	*packet   = NULL;
	static unsigned char		*buffer	  = NULL;
	//SV-XXX static uint8_t		*buffer   = NULL;
	//SV-XXX static uint8_t		*buffer12 = NULL;
	static unsigned char		*buffer12 = NULL;
	int			 buflen;
	source			*s;
	
	if (!session->opt->reuse_bufs || (packet == NULL)) {
		packet   = (rtp_packet *) xmalloc(RTP_MAX_PACKET_LEN);
		//SV-XXX buffer   = ((uint8_t *) packet) + offsetof(rtp_packet, fields);
		buffer   = ((unsigned char *) packet) + offsetof(rtp_packet, fields);
		buffer12 = buffer + 12;
	}
	
	//SV-XXX buflen = udp_recv(session->rtp_socket, buffer, RTP_MAX_PACKET_LEN - offsetof(rtp_packet, fields));
	buflen = udp_recv(session->rtp_socket, (char *)buffer, RTP_MAX_PACKET_LEN - offsetof(rtp_packet, fields));
	if (buflen > 0) {
		//		if (session->encryption_enabled) {
		//			uint8_t 	 initVec[8] = {0,0,0,0,0,0,0,0};
		//			(session->decrypt_func)(session, buffer, buflen, initVec);
		//		}
		/* Convert header fields to host byte order... */
		packet->fields.seq      = ntohs(packet->fields.seq);
		packet->fields.ts       = ntohl(packet->fields.ts);
		packet->fields.ssrc     = ntohl(packet->fields.ssrc);
		/* Setup internal pointers, etc... */
		if (packet->fields.cc) {
			int	i;
			packet->meta.csrc = (uint32_t *)(buffer12);
			for (i = 0; i < packet->fields.cc; i++) {
				packet->meta.csrc[i] = ntohl(packet->meta.csrc[i]);
			}
		} else {
			packet->meta.csrc = NULL;
		}
		if (packet->fields.x) {
			packet->meta.extn      = buffer12 + (packet->fields.cc * 4);
			packet->meta.extn_len  = (packet->meta.extn[2] << 8) | packet->meta.extn[3];
			packet->meta.extn_type = (packet->meta.extn[0] << 8) | packet->meta.extn[1];
		} else {
			packet->meta.extn      = NULL;
			packet->meta.extn_len  = 0;
			packet->meta.extn_type = 0;
		}
		packet->meta.data     = (char *) buffer12 + (packet->fields.cc * 4);
		//SV-XXX packet->meta.data     = buffer12 + (packet->fields.cc * 4);
		packet->meta.data_len = buflen -  (packet->fields.cc * 4) - 12;
		if (packet->meta.extn != NULL) {
			packet->meta.data += ((packet->meta.extn_len + 1) * 4);
			packet->meta.data_len -= ((packet->meta.extn_len + 1) * 4);
		}
		if (validate_rtp(session, packet, buflen)) {
			if (session->opt->wait_for_rtcp) {
				s = create_source(session, packet->fields.ssrc, TRUE);
			} else {
				s = get_source(session, packet->fields.ssrc);
			}
			if (session->opt->promiscuous_mode) {
				if (s == NULL) {
					create_source(session, packet->fields.ssrc, FALSE);
					s = get_source(session, packet->fields.ssrc);
				}
				process_rtp(session, curr_rtp_ts, packet, s);
				return; /* We don't free "packet", that's done by the callback function... */
			} 
			if (s != NULL) {
				if (s->probation == -1) {
					s->probation = MIN_SEQUENTIAL;
					s->max_seq   = packet->fields.seq - 1;
				}
				if (update_seq(s, packet->fields.seq)) {
					process_rtp(session, curr_rtp_ts, packet, s);
					return;	/* we don't free "packet", that's done by the callback function... */
				} else {
					/* This source is still on probation... */
					debug_msg("RTP packet from probationary source ignored...\n");
				}
			} else {
				debug_msg("RTP packet from unknown source ignored\n");
			}
		} else {
			session->invalid_rtp_count++;
			debug_msg("Invalid RTP packet discarded\n");
		}
	}
	if (!session->opt->reuse_bufs) {
		xfree(packet);
	}
}

static int validate_rtcp(uint8_t *packet, int len)
{
	/* Validity check for a compound RTCP packet. This function returns */
	/* TRUE if the packet is okay, FALSE if the validity check fails.   */
	/*                                                                  */
	/* The following checks can be applied to RTCP packets [RFC1889]:   */
	/* o RTP version field must equal 2.                                */
	/* o The payload type field of the first RTCP packet in a compound  */
	/*   packet must be equal to SR or RR.                              */
	/* o The padding bit (P) should be zero for the first packet of a   */
	/*   compound RTCP packet because only the last should possibly     */
	/*   need padding.                                                  */
	/* o The length fields of the individual RTCP packets must total to */
	/*   the overall length of the compound RTCP packet as received.    */
	
	rtcp_t	*pkt  = (rtcp_t *) packet;
	rtcp_t	*end  = (rtcp_t *) (((char *) pkt) + len);
	rtcp_t	*r    = pkt;
	int	 l    = 0;
	int	 pc   = 1;
	int	 p    = 0;
	
	//printf("len = %d | common.length = %d\n", len, (ntohs(pkt->common.length) + 1) * 4 );
	
	/* All RTCP packets must be compound packets (RFC1889, section 6.1) */
	if (((ntohs(pkt->common.length) + 1) * 4) == len) {
		debug_msg("Bogus RTCP packet: not a compound packet\n");
		return FALSE;
	}
	
	/* Check the RTCP version, payload type and padding of the first in  */
	/* the compund RTCP packet...                                        */
	if (pkt->common.version != 2) {
		debug_msg("Bogus RTCP packet: version number != 2 in the first sub-packet\n");
		return FALSE;
	}
	if (pkt->common.p != 0) {
		debug_msg("Bogus RTCP packet: padding bit is set on first packet in compound\n");
		return FALSE;
	}
	if ((pkt->common.pt != RTCP_SR) && (pkt->common.pt != RTCP_RR)) {
		debug_msg("Bogus RTCP packet: compund packet does not start with SR or RR\n");
		return FALSE;
	}
	
	/* Check all following parts of the compund RTCP packet. The RTP version */
	/* number must be 2, and the padding bit must be zero on all apart from  */
	/* the last packet.                                                      */
	do {
		if (p == 1) {
			debug_msg("Bogus RTCP packet: padding bit set before last in compound (sub-packet %d)\n", pc);
			return FALSE;
		}
		if (r->common.p) {
			p = 1;
		}
		if (r->common.version != 2) {
			debug_msg("Bogus RTCP packet: version number != 2 in sub-packet %d\n", pc);
			return FALSE;
		}
		l += (ntohs(r->common.length) + 1) * 4;
		r  = (rtcp_t *) (((uint32_t *) r) + ntohs(r->common.length) + 1);
		pc++;	/* count of sub-packets, for debugging... */
	} while (r < end);
	
	/* Check that the length of the packets matches the length of the UDP */
	/* packet in which they were received...                              */
	if (l != len) {
		debug_msg("Bogus RTCP packet: RTCP packet length does not match UDP packet length (%d != %d)\n", l, len);
		return FALSE;
	}
	if (r != end) {
		debug_msg("Bogus RTCP packet: RTCP packet length does not match UDP packet length (%p != %p)\n", r, end);
		return FALSE;
	}
	
	return TRUE;
}

static void process_report_blocks(struct rtp *session, rtcp_t *packet, uint32_t ssrc, rtcp_rr *rrp, struct timeval *event_ts)
{
	int i;
	rtp_event	 event;
	rtcp_rr		*rr;
	
	/* ...process RRs... */
	if (packet->common.count == 0) {
		if (!filter_event(session, ssrc)) {
			event.ssrc = ssrc;
			event.type = RX_RR_EMPTY;
			event.data = NULL;
			event.ts   = event_ts;
			session->callback(session, &event);
		}
	} else {
		for (i = 0; i < packet->common.count; i++, rrp++) {
			rr = (rtcp_rr *) xmalloc(sizeof(rtcp_rr));
			rr->ssrc          = ntohl(rrp->ssrc);
			rr->fract_lost    = rrp->fract_lost;	/* Endian conversion handled in the */
			rr->total_lost    = rrp->total_lost;	/* definition of the rtcp_rr type.  */
			rr->last_seq      = ntohl(rrp->last_seq);
			rr->jitter        = ntohl(rrp->jitter);
			rr->lsr           = ntohl(rrp->lsr);
			rr->dlsr          = ntohl(rrp->dlsr);
			
			/* Create a database entry for this SSRC, if one doesn't already exist... */
			create_source(session, rr->ssrc, FALSE);
			
			/* Store the RR for later use... */
			insert_rr(session, ssrc, rr, event_ts);
			
			/* Call the event handler... */
			if (!filter_event(session, ssrc)) {
				event.ssrc = ssrc;
				event.type = RX_RR;
				event.data = (void *) rr;
				event.ts   = event_ts;
				session->callback(session, &event);
			}
		}
	}
}

static void process_rtcp_sr(struct rtp *session, rtcp_t *packet, struct timeval *event_ts)
{
	uint32_t	 ssrc;
	rtp_event	 event;
	rtcp_sr		*sr;
	source		*s;
	
	ssrc = ntohl(packet->r.sr.sr.ssrc);
	s = create_source(session, ssrc, FALSE);
	if (s == NULL) {
		debug_msg("Source 0x%08x invalid, skipping...\n", ssrc);
		return;
	}
	
	/* Mark as an active sender, if we get a sender report... */
	if (s->sender == FALSE) {
		s->sender = TRUE;
		session->sender_count++;
	}
	
	/* Process the SR... */
	sr = (rtcp_sr *) xmalloc(sizeof(rtcp_sr));
	sr->ssrc          = ssrc;
	sr->ntp_sec       = ntohl(packet->r.sr.sr.ntp_sec);
	sr->ntp_frac      = ntohl(packet->r.sr.sr.ntp_frac);
	sr->rtp_ts        = ntohl(packet->r.sr.sr.rtp_ts);
	sr->sender_pcount = ntohl(packet->r.sr.sr.sender_pcount);
	sr->sender_bcount = ntohl(packet->r.sr.sr.sender_bcount);
	
	/* Store the SR for later retrieval... */
	if (s->sr != NULL) {
		xfree(s->sr);
	}
	s->sr = sr;
	s->last_sr = *event_ts;
	
	/* Call the event handler... */
	if (!filter_event(session, ssrc)) {
		event.ssrc = ssrc;
		event.type = RX_SR;
		event.data = (void *) sr;
		event.ts   = event_ts;
		session->callback(session, &event);
	}
	
	process_report_blocks(session, packet, ssrc, packet->r.sr.rr, event_ts);
	
	if (((packet->common.count * 6) + 1) < (ntohs(packet->common.length) - 5)) {
		debug_msg("Profile specific SR extension ignored\n");
	}
}

static void process_rtcp_rr(struct rtp *session, rtcp_t *packet, struct timeval *event_ts)
{
	uint32_t		 ssrc;
	source		*s;
	
	ssrc = ntohl(packet->r.rr.ssrc);
	s = create_source(session, ssrc, FALSE);
	if (s == NULL) {
		debug_msg("Source 0x%08x invalid, skipping...\n", ssrc);
		return;
	}
	
	process_report_blocks(session, packet, ssrc, packet->r.rr.rr, event_ts);
	
	if (((packet->common.count * 6) + 1) < ntohs(packet->common.length)) {
		debug_msg("Profile specific RR extension ignored\n");
	}
}

static void process_rtcp_sdes(struct rtp *session, rtcp_t *packet, struct timeval *event_ts)
{
	int 			count = packet->common.count;
	struct rtcp_sdes_t 	*sd   = &packet->r.sdes;
	rtcp_sdes_item 		*rsp; 
	rtcp_sdes_item		*rspn;
	rtcp_sdes_item 		*end  = (rtcp_sdes_item *) ((uint32_t *)packet + packet->common.length + 1);
	source 			*s;
	rtp_event		 event;
	
	while (--count >= 0) {
		rsp = &sd->item[0];
		if (rsp >= end) {
			break;
		}
		sd->ssrc = ntohl(sd->ssrc);
		s = create_source(session, sd->ssrc, FALSE);
		if (s == NULL) {
			debug_msg("Can't get valid source entry for 0x%08x, skipping...\n", sd->ssrc);
		} else {
			for (; rsp->type; rsp = rspn ) {
				rspn = (rtcp_sdes_item *)((char*)rsp+rsp->length+2);
				if (rspn >= end) {
					rsp = rspn;
					break;
				}
				if (rtp_set_sdes(session, sd->ssrc, rsp->type, rsp->data, rsp->length)) {
					if (!filter_event(session, sd->ssrc)) {
						event.ssrc = sd->ssrc;
						event.type = RX_SDES;
						event.data = (void *) rsp;
						event.ts   = event_ts;
						session->callback(session, &event);
					}
				} else {
					debug_msg("Invalid sdes item for source 0x%08x, skipping...\n", sd->ssrc);
				}
			}
		}
		sd = (struct rtcp_sdes_t *) ((uint32_t *)sd + (((char *)rsp - (char *)sd) >> 2)+1);
	}
	if (count >= 0) {
		debug_msg("Invalid RTCP SDES packet, some items ignored.\n");
	}
}

static void process_rtcp_bye(struct rtp *session, rtcp_t *packet, struct timeval *event_ts)
{
	int		 i;
	uint32_t	 ssrc;
	rtp_event	 event;
	source		*s;
	
	for (i = 0; i < packet->common.count; i++) {
		ssrc = ntohl(packet->r.bye.ssrc[i]);
		/* This is kind-of strange, since we create a source we are about to delete. */
		/* This is done to ensure that the source mentioned in the event which is    */
		/* passed to the user of the RTP library is valid, and simplify client code. */
		create_source(session, ssrc, FALSE);
		/* Call the event handler... */
		if (!filter_event(session, ssrc)) {
			event.ssrc = ssrc;
			event.type = RX_BYE;
			event.data = NULL;
			event.ts   = event_ts;
			session->callback(session, &event);
		}
		/* Mark the source as ready for deletion. Sources are not deleted immediately */
		/* since some packets may be delayed and arrive after the BYE...              */
		s = get_source(session, ssrc);
		s->got_bye = TRUE;
		check_source(s);
		session->bye_count++;
	}
}

static void process_rtcp_app(struct rtp *session, rtcp_t *packet, struct timeval *event_ts)
{
	uint32_t         ssrc;
	rtp_event        event;
	rtcp_app        *app;
	source          *s;
	int              data_len;
	
	/* Update the database for this source. */
	ssrc = ntohl(packet->r.app.ssrc);
	create_source(session, ssrc, FALSE);
	s = get_source(session, ssrc);
	if (s == NULL) {
		/* This should only occur in the event of database malfunction. */
		debug_msg("Source 0x%08x invalid, skipping...\n", ssrc);
		return;
	}
	check_source(s);
	
	/* Copy the entire packet, converting the header (only) into host byte order. */
	app = (rtcp_app *) xmalloc(RTP_MAX_PACKET_LEN);
	app->version        = packet->common.version;
	app->p              = packet->common.p;
	app->subtype        = packet->common.count;
	app->pt             = packet->common.pt;
	app->length         = ntohs(packet->common.length);
	app->ssrc           = ssrc;
	app->name[0]        = packet->r.app.name[0];
	app->name[1]        = packet->r.app.name[1];
	app->name[2]        = packet->r.app.name[2];
	app->name[3]        = packet->r.app.name[3];
	data_len            = (app->length - 2) * 4;
	memcpy(app->data, packet->r.app.data, data_len);
	
	/* Callback to the application to process the app packet... */
	if (!filter_event(session, ssrc)) {
		event.ssrc = ssrc;
		event.type = RX_APP;
		event.data = (void *) app;       /* The callback function MUST free this! */
		event.ts   = event_ts;
		session->callback(session, &event);
	}
}

static void rtp_process_ctrl(struct rtp *session, uint8_t *buffer, int buflen)
{
	/* This routine processes incoming RTCP packets */
	rtp_event	 event;
	struct timeval	 event_ts;
	rtcp_t		*packet;
	uint8_t 	 initVec[8] = {0,0,0,0,0,0,0,0};
	int		 first;
	uint32_t	 packet_ssrc = rtp_my_ssrc(session);
	
	gettimeofday(&event_ts, NULL);
	if (buflen > 0) {
		//		if (session->encryption_enabled)
		//		{
		//			/* Decrypt the packet... */
		//			(session->decrypt_func)(session, buffer, buflen, initVec);
		//			buffer += 4;	/* Skip the random prefix... */
		//			buflen -= 4;
		//		}
		if (validate_rtcp(buffer, buflen)) {
			first  = TRUE;
			packet = (rtcp_t *) buffer;
			while (packet < (rtcp_t *) (buffer + buflen)) {
				switch (packet->common.pt) {
					case RTCP_SR:
						//printf("Processing SR\n");
						if (first && !filter_event(session, ntohl(packet->r.sr.sr.ssrc))) {
							event.ssrc  = ntohl(packet->r.sr.sr.ssrc);
							event.type  = RX_RTCP_START;
							event.data  = &buflen;
							event.ts    = &event_ts;
							packet_ssrc = event.ssrc;
							session->callback(session, &event);
						}
						process_rtcp_sr(session, packet, &event_ts);
						break;
					case RTCP_RR:
						//printf("Processing RR\n");
						if (first && !filter_event(session, ntohl(packet->r.rr.ssrc))) {
							event.ssrc  = ntohl(packet->r.rr.ssrc);
							event.type  = RX_RTCP_START;
							event.data  = &buflen;
							event.ts    = &event_ts;
							packet_ssrc = event.ssrc;
							session->callback(session, &event);
						}
						
						process_rtcp_rr(session, packet, &event_ts);
						break;
					case RTCP_SDES:
						if (first && !filter_event(session, ntohl(packet->r.sdes.ssrc))) {
							event.ssrc  = ntohl(packet->r.sdes.ssrc);
							event.type  = RX_RTCP_START;
							event.data  = &buflen;
							event.ts    = &event_ts;
							packet_ssrc = event.ssrc;
							session->callback(session, &event);
						}
						process_rtcp_sdes(session, packet, &event_ts);
						break;
					case RTCP_BYE:
						if (first && !filter_event(session, ntohl(packet->r.bye.ssrc[0]))) {
							event.ssrc  = ntohl(packet->r.bye.ssrc[0]);
							event.type  = RX_RTCP_START;
							event.data  = &buflen;
							event.ts    = &event_ts;
							packet_ssrc = event.ssrc;
							session->callback(session, &event);
						}
						process_rtcp_bye(session, packet, &event_ts);
						break;
					case RTCP_APP:
						if (first && !filter_event(session, ntohl(packet->r.app.ssrc))) {
							event.ssrc  = ntohl(packet->r.app.ssrc);
							event.type  = RX_RTCP_START;
							event.data  = &buflen;
							event.ts    = &event_ts;
							packet_ssrc = event.ssrc;
							session->callback(session, &event);
						}
						process_rtcp_app(session, packet, &event_ts);
						break;
					default: 
						debug_msg("RTCP packet with unknown type (%d) ignored.\n", packet->common.pt);
						break;
				}
				packet = (rtcp_t *) ((char *) packet + (4 * (ntohs(packet->common.length) + 1)));
				first  = FALSE;
			}
			if (session->avg_rtcp_size < 0) {
				/* This is the first RTCP packet we've received, set our initial estimate */
				/* of the average  packet size to be the size of this packet.             */
				session->avg_rtcp_size = buflen + RTP_LOWER_LAYER_OVERHEAD;
			} else {
				/* Update our estimate of the average RTCP packet size. The constants are */
				/* 1/16 and 15/16 (section 6.3.3 of draft-ietf-avt-rtp-new-02.txt).       */
				session->avg_rtcp_size = (0.0625 * (buflen + RTP_LOWER_LAYER_OVERHEAD)) + (0.9375 * session->avg_rtcp_size);
			}
			/* Signal that we've finished processing this packet */
			if (!filter_event(session, packet_ssrc)) {
				event.ssrc = packet_ssrc;
				event.type = RX_RTCP_FINISH;
				event.data = NULL;
				event.ts   = &event_ts;
				session->callback(session, &event);
			}
		} else {
			debug_msg("Invalid RTCP packet discarded\n");
			event.ssrc = packet_ssrc;
			event.type = RX_RTCP_BAD_PACKET;
			event.data = NULL;
			event.ts   = &event_ts;
			session->callback(session, &event);
			session->invalid_rtcp_count++;
		}
	}
}

/**
 * rtp_udp_recv:
 * @session: the session pointer (returned by rtp_init())
 * @timeout: the amount of time that rtcp_recv() is allowed to block
 * @curr_rtp_ts: the current time expressed in units of the media
 * timestamp.
 *
 * Receive RTP packets and dispatch them.
 *
 * Returns: TRUE if data received, FALSE if the timeout occurred.
 */

int rtp_recv_udp(struct rtp *session, struct timeval *timeout, uint32_t curr_rtp_ts) {
	check_database(session);
	udp_fd_zero();
	udp_fd_set(session->rtp_socket);
	udp_fd_set(session->rtcp_socket);
	if (udp_select(timeout) > 0) {
		if (udp_fd_isset(session->rtp_socket)) {
			printf("Received Data on RTP channel\n");
			rtp_recv_data_udp(session, curr_rtp_ts);
			
		}
		if (udp_fd_isset(session->rtcp_socket)) {
			//SV-XXX uint8_t		 buffer[RTP_MAX_PACKET_LEN];
			char          buffer[RTP_MAX_PACKET_LEN];
			int		 buflen;
			buflen = udp_recv(session->rtcp_socket, buffer, RTP_MAX_PACKET_LEN);
			//SV-XXX rtp_process_ctrl(session, buffer, buflen);
			//printf("Received Data on RTCP channel\n");
			rtp_process_ctrl(session, (unsigned char *)buffer, buflen);
		}
		check_database(session);
		return TRUE;
	}
	check_database(session);
	return FALSE;
}


static void 
rtp_recv_data_tcp(struct rtp *session, uint32_t curr_rtp_ts)
{
	/* This routine preprocesses an incoming RTP packet, deciding whether to process it. */
	static rtp_packet			*packet   = NULL;
	static unsigned char		*buffer	  = NULL;
	static unsigned char		*tcpbuf   = NULL;
	//SV-XXX static uint8_t		*buffer   = NULL;
	//SV-XXX static uint8_t		*buffer12 = NULL;
	static unsigned char		*buffer12 = NULL;
	int			 buflen;
	uint8_t channel;
	source			*s;
	
	if (!session->opt->reuse_bufs || (packet == NULL)) {
		packet   = (rtp_packet *) xmalloc(RTP_MAX_PACKET_LEN + RTP_TCP_HEADER_LEN);
		//SV-XXX buffer   = ((uint8_t *) packet) + offsetof(rtp_packet, fields);
		buffer   = ((unsigned char *) packet) + offsetof(rtp_packet, fields);
		buffer12 = buffer + 12;
		
		//Use the 4 bytes before the RTP packet as temp storage of the interleave header
		tcpbuf	 = buffer - RTP_TCP_HEADER_LEN;
	}
	
	//SV-XXX buflen = udp_recv(session->rtp_socket, buffer, RTP_MAX_PACKET_LEN - offsetof(rtp_packet, fields));
	//buflen = udp_recv(session->rtp_socket, (char *)buffer, RTP_MAX_PACKET_LEN - offsetof(rtp_packet, fields));
	
	//Have TCP read the header into the 4 bites before the RTP packet
	buflen = tcp_recv(session->rtsp_socket, (char *)buffer, RTP_MAX_PACKET_LEN - offsetof(rtp_packet, fields), &channel);
	
	//buflen = tcp_recv(session->rtsp_socket, (char *)tcpbuf, RTP_MAX_PACKET_LEN - offsetof(rtp_packet, fields) + RTP_TCP_HEADER_LEN);
	
	//printf("Received packet on channel %d of len %d\n", channel, buflen);
	if (buflen > 0) {
		
		if(channel == session->rtsp_rtcp) {
			rtp_process_ctrl(session, (unsigned char*) &buffer, buflen);
			if (!session->opt->reuse_bufs) {
				xfree(packet);
			}
			return;
		}
		//At this point we do not care about the TCP interleave header anymore.
		
		//		if (session->encryption_enabled) {
		//			uint8_t 	 initVec[8] = {0,0,0,0,0,0,0,0};
		//			(session->decrypt_func)(session, buffer, buflen, initVec);
		//		}
		/* Convert header fields to host byte order... */
		packet->fields.seq      = ntohs(packet->fields.seq);
		packet->fields.ts       = ntohl(packet->fields.ts);
		packet->fields.ssrc     = ntohl(packet->fields.ssrc);
		/* Setup internal pointers, etc... */
		if (packet->fields.cc) {
			int	i;
			packet->meta.csrc = (uint32_t *)(buffer12);
			for (i = 0; i < packet->fields.cc; i++) {
				packet->meta.csrc[i] = ntohl(packet->meta.csrc[i]);
			}
		} else {
			packet->meta.csrc = NULL;
		}
		if (packet->fields.x) {
			packet->meta.extn      = buffer12 + (packet->fields.cc * 4);
			packet->meta.extn_len  = (packet->meta.extn[2] << 8) | packet->meta.extn[3];
			packet->meta.extn_type = (packet->meta.extn[0] << 8) | packet->meta.extn[1];
		} else {
			packet->meta.extn      = NULL;
			packet->meta.extn_len  = 0;
			packet->meta.extn_type = 0;
		}
		packet->meta.data     = (char *) buffer12 + (packet->fields.cc * 4);
		//SV-XXX packet->meta.data     = buffer12 + (packet->fields.cc * 4);
		packet->meta.data_len = buflen -  (packet->fields.cc * 4) - 12;
		if (packet->meta.extn != NULL) {
			packet->meta.data += ((packet->meta.extn_len + 1) * 4);
			packet->meta.data_len -= ((packet->meta.extn_len + 1) * 4);
		}
		if (validate_rtp(session, packet, buflen)) {
			if (session->opt->wait_for_rtcp) {
				s = create_source(session, packet->fields.ssrc, TRUE);
			} else {
				s = get_source(session, packet->fields.ssrc);
			}
			if (session->opt->promiscuous_mode) {
				if (s == NULL) {
					create_source(session, packet->fields.ssrc, FALSE);
					s = get_source(session, packet->fields.ssrc);
				}
				process_rtp(session, curr_rtp_ts, packet, s);
				return; /* We don't free "packet", that's done by the callback function... */
			} 
			if (s != NULL) {
				if (s->probation == -1) {
					s->probation = MIN_SEQUENTIAL;
					s->max_seq   = packet->fields.seq - 1;
				}
				if (update_seq(s, packet->fields.seq)) {
					process_rtp(session, curr_rtp_ts, packet, s);
					return;	/* we don't free "packet", that's done by the callback function... */
				} else {
					/* This source is still on probation... */
					debug_msg("RTP packet from probationary source ignored...\n");
				}
			} else {
				debug_msg("RTP packet from unknown source ignored\n");
			}
		} else {
			session->invalid_rtp_count++;
			debug_msg("Invalid RTP packet discarded\n");
		}
	}
	if (!session->opt->reuse_bufs) {
		xfree(packet);
	}
}


/**
 * rtp_tcp_recv:
 * @session: the session pointer (returned by rtp_init())
 * @timeout: the amount of time that rtcp_recv() is allowed to block
 * @curr_rtp_ts: the current time expressed in units of the media
 * timestamp.
 *
 * Receive RTP packets and dispatch them.
 *
 * Returns: TRUE if data received, FALSE if the timeout occurred.
 */

int rtp_recv_tcp(struct rtp *session, struct timeval *timeout, uint32_t curr_rtp_ts) {
	//char buffer[RTP_MAX_PACKET_LEN + 4];
	//int pktsize, channel;
	check_database(session);
	tcp_fd_zero(session->rtsp_socket);
	tcp_fd_set(session->rtsp_socket);
	if (tcp_select_read(session->rtsp_socket, timeout) > 0) {
		if (tcp_fd_isset(session->rtsp_socket)) {
			
			rtp_recv_data_tcp(session, curr_rtp_ts);
			
			/*
			pktsize = tcp_recv(session->rtsp_socket, buffer, RTP_MAX_PACKET_LEN + 4);
			
			if(pktsize == -1 || pktsize == 0) return FALSE; //TODO: Handle error
			
			if(buffer[1] == session->rtsp_rtp) {
				
			}
			if(buffer[1] == session->rtsp_rtcp) {
				rtp_process_ctrl(session, (unsigned char*) &buffer[4], pktsize);
			}
			 */
		}
		check_database(session);
		return TRUE;
	}
	check_database(session);
	return FALSE;
}


/**
 * rtp_recv:
 * @session: the session pointer (returned by rtp_init())
 * @timeout: the amount of time that rtcp_recv() is allowed to block
 * @curr_rtp_ts: the current time expressed in units of the media
 * timestamp.
 *
 * Receive RTP packets and dispatch them.
 *
 * Returns: TRUE if data received, FALSE if the timeout occurred.
 */
int rtp_recv(struct rtp *session, struct timeval *timeout, uint32_t curr_rtp_ts)
{
	if(session->transport == RTP_TRANSPORT_UDP) {
		return rtp_recv_udp(session, timeout, curr_rtp_ts);
	}
	else if(session->transport == RTP_TRANSPORT_TCP) {
		return rtp_recv_tcp(session, timeout, curr_rtp_ts);
	}
	return FALSE;
}



/**
 * rtp_add_csrc:
 * @session: the session pointer (returned by rtp_init()) 
 * @csrc: Constributing SSRC identifier
 * 
 * Adds @csrc to list of contributing sources used in SDES items.
 * Used by mixers and transcoders.
 * 
 * Return value: TRUE.
 **/
int rtp_add_csrc(struct rtp *session, uint32_t csrc)
{
	/* Mark csrc as something for which we should advertise RTCP SDES items, */
	/* in addition to our own SDES.                                          */
	source	*s;
	
	check_database(session);
	s = get_source(session, csrc);
	if (s == NULL) {
		s = create_source(session, csrc, FALSE);
		debug_msg("Created source 0x%08x as CSRC\n", csrc);
	}
	check_source(s);
	if (!s->should_advertise_sdes) {
		s->should_advertise_sdes = TRUE;
		session->csrc_count++;
		debug_msg("Added CSRC 0x%08lx as CSRC %d\n", csrc, session->csrc_count);
	}
	return TRUE;
}

/**
 * rtp_del_csrc:
 * @session: the session pointer (returned by rtp_init()) 
 * @csrc: Constributing SSRC identifier
 * 
 * Removes @csrc from list of contributing sources used in SDES items.
 * Used by mixers and transcoders.
 * 
 * Return value: TRUE on success, FALSE if @csrc is not a valid source.
 **/
int rtp_del_csrc(struct rtp *session, uint32_t csrc)
{
	source	*s;
	
	check_database(session);
	s = get_source(session, csrc);
	if (s == NULL) {
		debug_msg("Invalid source 0x%08x\n", csrc);
		return FALSE;
	}
	check_source(s);
	s->should_advertise_sdes = FALSE;
	session->csrc_count--;
	if (session->last_advertised_csrc >= session->csrc_count) {
		session->last_advertised_csrc = 0;
	}
	return TRUE;
}

/**
 * rtp_set_sdes:
 * @session: the session pointer (returned by rtp_init()) 
 * @ssrc: the SSRC identifier of a participant
 * @type: the SDES type represented by @value
 * @value: the SDES description
 * @length: the length of the description
 * 
 * Sets session description information associated with participant
 * @ssrc.  Under normal circumstances applications always use the
 * @ssrc of the local participant, this SDES information is
 * transmitted in receiver reports.  Setting SDES information for
 * other participants affects the local SDES entries, but are not
 * transmitted onto the network.
 * 
 * Return value: Returns TRUE if participant exists, FALSE otherwise.
 **/
int rtp_set_sdes(struct rtp *session, uint32_t ssrc, rtcp_sdes_type type, const char *value, int length)
{
	source	*s;
	char	*v;
	
	check_database(session);
	
	s = get_source(session, ssrc);
	if (s == NULL) {
		debug_msg("Invalid source 0x%08x\n", ssrc);
		return FALSE;
	}
	check_source(s);
	
	v = (char *) xmalloc(length + 1);
	memset(v, '\0', length + 1);
	memcpy(v, value, length);
	
	switch (type) {
		case RTCP_SDES_CNAME: 
			if (s->cname) xfree(s->cname);
			s->cname = v; 
			break;
		case RTCP_SDES_NAME:
			if (s->name) xfree(s->name);
			s->name = v; 
			break;
		case RTCP_SDES_EMAIL:
			if (s->email) xfree(s->email);
			s->email = v; 
			break;
		case RTCP_SDES_PHONE:
			if (s->phone) xfree(s->phone);
			s->phone = v; 
			break;
		case RTCP_SDES_LOC:
			if (s->loc) xfree(s->loc);
			s->loc = v; 
			break;
		case RTCP_SDES_TOOL:
			if (s->tool) xfree(s->tool);
			s->tool = v; 
			break;
		case RTCP_SDES_NOTE:
			if (s->note) xfree(s->note);
			s->note = v; 
			break;
		case RTCP_SDES_PRIV:
			if (s->priv) xfree(s->priv);
			s->priv = v; 
			break;
		default :
			debug_msg("Unknown SDES item (type=%d, value=%s)\n", type, v);
			xfree(v);
			check_database(session);
			return FALSE;
	}
	check_database(session);
	return TRUE;
}

/**
 * rtp_get_sdes:
 * @session: the session pointer (returned by rtp_init()) 
 * @ssrc: the SSRC identifier of a participant
 * @type: the SDES information to retrieve
 * 
 * Recovers session description (SDES) information on participant
 * identified with @ssrc.  The SDES information associated with a
 * source is updated when receiver reports are received.  There are
 * several different types of SDES information, e.g. username,
 * location, phone, email.  These are enumerated by #rtcp_sdes_type.
 * 
 * Return value: pointer to string containing SDES description if
 * received, NULL otherwise.  
 */
const char *rtp_get_sdes(struct rtp *session, uint32_t ssrc, rtcp_sdes_type type)
{
	source	*s;
	
	check_database(session);
	
	s = get_source(session, ssrc);
	if (s == NULL) {
		debug_msg("Invalid source 0x%08x\n", ssrc);
		return NULL;
	}
	check_source(s);
	
	switch (type) {
        case RTCP_SDES_CNAME: 
			return s->cname;
        case RTCP_SDES_NAME:
			return s->name;
        case RTCP_SDES_EMAIL:
			return s->email;
        case RTCP_SDES_PHONE:
			return s->phone;
        case RTCP_SDES_LOC:
			return s->loc;
        case RTCP_SDES_TOOL:
			return s->tool;
        case RTCP_SDES_NOTE:
			return s->note;
		case RTCP_SDES_PRIV:
			return s->priv;	
        default:
			/* This includes RTCP_SDES_PRIV and RTCP_SDES_END */
			debug_msg("Unknown SDES item (type=%d)\n", type);
	}
	return NULL;
}

/**
 * rtp_get_sr:
 * @session: the session pointer (returned by rtp_init()) 
 * @ssrc: identifier of source
 * 
 * Retrieve the latest sender report made by sender with @ssrc identifier.
 * 
 * Return value: A pointer to an rtcp_sr structure on success, NULL
 * otherwise.  The pointer must not be freed.
 **/
const rtcp_sr *rtp_get_sr(struct rtp *session, uint32_t ssrc)
{
	/* Return the last SR received from this ssrc. The */
	/* caller MUST NOT free the memory returned to it. */
	source	*s;
	
	check_database(session);
	
	s = get_source(session, ssrc);
	if (s == NULL) {
		return NULL;
	} 
	check_source(s);
	return s->sr;
}

/**
 * rtp_get_rr:
 * @session: the session pointer (returned by rtp_init())
 * @reporter: participant originating receiver report
 * @reportee: participant included in receiver report
 * 
 * Retrieve the latest receiver report on @reportee made by @reporter.
 * Provides an indication of other receivers reception service.
 * 
 * Return value: A pointer to a rtcp_rr structure on success, NULL
 * otherwise.  The pointer must not be freed.
 **/
const rtcp_rr *rtp_get_rr(struct rtp *session, uint32_t reporter, uint32_t reportee)
{
	check_database(session);
	return get_rr(session, reporter, reportee);
}

/**
 * rtp_send_data:
 * @session: the session pointer (returned by rtp_init())
 * @rtp_ts: The timestamp reflects the sampling instant of the first octet of the RTP data to be sent.  The timestamp is expressed in media units.
 * @pt: The payload type identifying the format of the data.
 * @m: Marker bit, interpretation defined by media profile of payload.
 * @cc: Number of contributing sources (excluding local participant)
 * @csrc: Array of SSRC identifiers for contributing sources.
 * @data: The RTP data to be sent.
 * @data_len: The size @data in bytes.
 * @extn: Extension data (if present).
 * @extn_len: size of @extn in bytes.
 * @extn_type: extension type indicator.
 * 
 * Send an RTP packet.  Most media applications will only set the
 * @session, @rtp_ts, @pt, @m, @data, @data_len arguments.
 *
 * Mixers and translators typically set additional contributing sources 
 * arguments (@cc, @csrc).
 *
 * Extensions fields (@extn, @extn_len, @extn_type) are for including
 * application specific information.  When the widest amount of
 * inter-operability is required these fields should be avoided as
 * some applications discard packets with extensions they do not
 * recognize.
 * 
 * Return value: Number of bytes transmitted.
 **/
int rtp_send_data(struct rtp *session, uint32_t rtp_ts, char pt, int m, 
				  int cc, uint32_t* csrc, 
                  char *data, int data_len, 
				  char *extn, uint16_t extn_len, uint16_t extn_type,
				  struct timeval *timeout)
{
	int		 buffer_len, i, rc, pad, pad_len, tcp_hdr_len = 0;
	//uint8_t		*buffer;
	char		*buffer;
	rtp_packet	*packet;
	uint8_t 	 initVec[8] = {0,0,0,0,0,0,0,0};
	
	check_database(session);
	
	assert(data_len > 0);
	
//	if(session->transport == RTP_TRANSPORT_UDP) {
		buffer_len = data_len + 12 + (4 * cc);
//	}
//	else if(session->transport == RTP_TRANSPORT_TCP) {
//		//Add 4 byte header for interleave
//		tcp_hdr_len = RTP_TCP_HEADER_LEN;
//		buffer_len = data_len + 12 + (4 * cc) + tcp_hdr_len;
//	}
	
	if (extn != NULL) {
		buffer_len += (extn_len + 1) * 4;
	}
	
	/* Do we need to pad this packet to a multiple of 64 bits? */
	/* This is only needed if encryption is enabled, since DES */
	/* only works on multiples of 64 bits. We just calculate   */
	/* the amount of padding to add here, so we can reserve    */
	/* space - the actual padding is added later.              */
	//	if ((session->encryption_enabled) &&
	//	    ((buffer_len % session->encryption_pad_length) != 0)) {
	//		pad         = TRUE;
	//		pad_len     = session->encryption_pad_length - (buffer_len % session->encryption_pad_length);
	//		buffer_len += pad_len; 
	//		assert((buffer_len % session->encryption_pad_length) == 0);
	//	} else {
	pad     = FALSE;
	pad_len = 0;
	//	}
	
	/* Allocate memory for the packet... */
	//SV-XXX buffer     = (uint8_t *) xmalloc(buffer_len + offsetof(rtp_packet, fields));
	
	buffer     = (char *) xmalloc(buffer_len + offsetof(rtp_packet, fields) + tcp_hdr_len);
	
	// For RTSP/TCP interleave the buffer will have 4 extra bytes preceeding the RTP packet.
	// Due to this the buffer layout will be as such
	//
	// [rtp meta pointers][tcp header][rtp packet]
	//
	// This means that the start of [tcp headers] is located at buffer + offsetof(rtp_packet, fields);
//	if(session->transport == RTP_TRANSPORT_TCP) {
//		//Write TCP inteleave heaer
//		char *pb8 = buffer + offsetof(rtp_packet, fields);
//		pb8[0] = '$';
//		pb8[1] = session->rtsp_rtp;
//		uint16_t *pb16 = (uint16_t*) &pb8[2];
//		//printf("bufffer_len - tcp_hder_len = %u", buffer_len - tcp_hdr_len);
//		*pb16 = htons(buffer_len - tcp_hdr_len);
//		
//		//Move packet pointer up by 4 bytes to get to the start of the RTP header
//		packet = (rtp_packet *) pb8 + tcp_hdr_len;
//	}
//	else {
		packet = (rtp_packet *) buffer;
//	}
	
	//This will equal 20
	//printf("offsetof(rtp_packet, fields) = %lu\n", offsetof(rtp_packet, fields));
	
	/* These are internal pointers into the buffer... */
	packet->meta.csrc = (uint32_t *) (buffer + tcp_hdr_len + offsetof(rtp_packet, fields) + 12);
	packet->meta.extn = (uint8_t  *) (buffer + tcp_hdr_len + offsetof(rtp_packet, fields) + 12 + (4 * cc));
	//SV-XXX packet->meta.data = (uint8_t  *) (buffer + offsetof(rtp_packet, fields) + 12 + (4 * cc));
	packet->meta.data = (char  *) (buffer + tcp_hdr_len + offsetof(rtp_packet, fields) + 12 + (4 * cc));
	
	if (extn != NULL) {
		packet->meta.data += (extn_len + 1) * 4;
	}
	
	//printf("RTP TS: %u\n", rtp_ts);
	
	/* ...and the actual packet header... */
	packet->fields.v    = 2;
	packet->fields.p    = pad;
	packet->fields.x    = (extn != NULL);
	packet->fields.cc   = cc;
	packet->fields.m    = m;
	packet->fields.pt   = pt;
	packet->fields.seq  = htons(session->rtp_seq++);
	packet->fields.ts   = htonl(rtp_ts);
	packet->fields.ssrc = htonl(rtp_my_ssrc(session));
	/* ...now the CSRC list... */
	for (i = 0; i < cc; i++) {
		packet->meta.csrc[i] = htonl(csrc[i]);
	}
	
#warning This may not work with TCP transport
	/* ...a header extension? */
	if (extn != NULL) {
		/* We don't use the packet->fields.extn_type field here, that's for receive only... */
		uint16_t *base = (uint16_t *) packet->meta.extn;
		base[0] = htons(extn_type);
		base[1] = htons(extn_len);
		memcpy(packet->meta.extn + 4, extn, extn_len * 4);
	}
	/* ...and the media data... */
	memcpy(packet->meta.data, data, data_len);
	
#warning This may not work with TCP transport
	/* ...and any padding... */
	if (pad) {
		for (i = 0; i < pad_len; i++) {
			buffer[buffer_len + offsetof(rtp_packet, fields) - pad_len + i] = 0;
		}
		buffer[buffer_len + offsetof(rtp_packet, fields) - 1] = (char) pad_len;
	}
	
	/* Finally, encrypt if desired... */
	//	if (session->encryption_enabled)
	//	{
	//		assert((buffer_len % session->encryption_pad_length) == 0);
	//                //SV-XXX (session->encrypt_func)(session, buffer + offsetof(rtp_packet, fields),
	//		//			buffer_len, initVec);
	//                (session->encrypt_func)(session, (unsigned char *) buffer + offsetof(rtp_packet, fields),
	//                                        buffer_len, initVec);
	//	}
	
	if(session->transport == RTP_TRANSPORT_UDP) {
		rc = udp_send(session->rtp_socket, buffer + offsetof(rtp_packet, fields), buffer_len);
	}
	else if(session->transport == RTP_TRANSPORT_TCP) {
		//This causes alot of isses. Prevents the iphone from streaming at more then 1Mbps.
		tcp_fd_zero(session->rtsp_socket);
		tcp_fd_set(session->rtsp_socket);
		if (tcp_select_write(session->rtsp_socket, timeout) > 0) {
			rc = tcp_send(session->rtsp_socket, session->rtsp_rtp, buffer + offsetof(rtp_packet, fields), buffer_len);
		}
		else {
			rc = -1;
		}
	}
	
	xfree(buffer);
	
	/* Update the RTCP statistics... */
	session->we_sent     = TRUE;
	session->rtp_pcount += 1;
	session->rtp_bcount += buffer_len;
	gettimeofday(&session->last_rtp_send_time, NULL);
	
	check_database(session);
	return rc;
}


int rtp_send_data_iov(struct rtp *session, uint32_t rtp_ts, char pt, int m, int cc, uint32_t csrc[], struct iovec *iov, int iov_count, char *extn, uint16_t extn_len, uint16_t extn_type)
{
	int		 buffer_len, i, rc;
	//SV-XXX uint8_t		*buffer;
	char            *buffer;
	rtp_packet	*packet;
	int my_iov_count = iov_count + 1;
	struct iovec *my_iov;
	
	#warning rtp_send_data_iov for TCP not implemented
	
	/* operation not supported on encrypted sessions */
	//	if ((session->encryption_enabled)) {
	//		return -1;
	//	}
	
	check_database(session);
	
	buffer_len = 12 + (4 * cc);
	if (extn != NULL) {
		buffer_len += (extn_len + 1) * 4;
	}
	
	/* Allocate memory for the packet... */
	//SV-XXX buffer     = (uint8_t *) xmalloc(buffer_len + offsetof(rtp_packet, fields));
	buffer     = (char *) xmalloc(buffer_len + offsetof(rtp_packet, fields));
	packet     = (rtp_packet *) buffer;
	
	/* These are internal pointers into the buffer... */
	packet->meta.csrc = (uint32_t *) (buffer + offsetof(rtp_packet, fields) + 12);
	packet->meta.extn = (uint8_t  *) (buffer + offsetof(rtp_packet, fields) + 12 + (4 * cc));
	//SV-XXX packet->meta.data = (uint8_t  *) (buffer + offsetof(rtp_packet, fields) + 12 + (4 * cc));
	packet->meta.data = (char  *) (buffer + offsetof(rtp_packet, fields) + 12 + (4 * cc));
	if (extn != NULL) {
		packet->meta.data += (extn_len + 1) * 4;
	}
	/* ...and the actual packet header... */
	packet->fields.v    = 2;
	packet->fields.p    = 0;
	packet->fields.x    = (extn != NULL);
	packet->fields.cc   = cc;
	packet->fields.m    = m;
	packet->fields.pt   = pt;
	packet->fields.seq  = htons(session->rtp_seq++);
	packet->fields.ts   = htonl(rtp_ts);
	packet->fields.ssrc = htonl(rtp_my_ssrc(session));
	/* ...now the CSRC list... */
	for (i = 0; i < cc; i++) {
		packet->meta.csrc[i] = htonl(csrc[i]);
	}
	/* ...a header extension? */
	if (extn != NULL) {
		/* We don't use the packet->fields.extn_type field here, that's for receive only... */
		uint16_t *base = (uint16_t *) packet->meta.extn;
		base[0] = htons(extn_type);
		base[1] = htons(extn_len);
		memcpy(packet->meta.extn + 4, extn, extn_len * 4);
	}
	
	/* Add the RTP packet header to the beginning of the iov list */
	my_iov = (struct iovec*)xmalloc(my_iov_count * sizeof(struct iovec));
	
	my_iov[0].iov_base = buffer + offsetof(rtp_packet, fields);
	my_iov[0].iov_len = buffer_len;
	
	for (i = 1; i < my_iov_count; i++) {
		my_iov[i].iov_base = iov[i-1].iov_base;
		my_iov[i].iov_len = iov[i-1].iov_len;
		buffer_len += my_iov[i].iov_len;
	}
	
	/* Send the data */
	if(session->transport == RTP_TRANSPORT_UDP) {
		rc = udp_sendv(session->rtp_socket, my_iov, my_iov_count);
	}
	else if(session->transport == RTP_TRANSPORT_TCP) {
		//TODO: implement

	}
	
	/* Update the RTCP statistics... */
	session->we_sent     = TRUE;
	session->rtp_pcount += 1;
	session->rtp_bcount += buffer_len;
	
	check_database(session);
	return rc;
}


static int format_report_blocks(rtcp_rr *rrp, int remaining_length, struct rtp *session)
{
	int nblocks = 0;
	int h;
	source *s;
	struct timeval now;
	
	gettimeofday(&now, NULL);
	
	for (h = 0; h < RTP_DB_SIZE; h++) {
		for (s = session->db[h]; s != NULL; s = s->next) {
			check_source(s);
			if ((nblocks == 31) || (remaining_length < 24)) {
				break; /* Insufficient space for more report blocks... */
			}
			if (s->sender) {
				/* Much of this is taken from A.3 of draft-ietf-avt-rtp-new-01.txt */
				int	extended_max      = s->cycles + s->max_seq;
				int	expected          = extended_max - s->base_seq + 1;
				int	lost              = expected - s->received;
				int	expected_interval = expected - s->expected_prior;
				int	received_interval = s->received - s->received_prior;
				int 	lost_interval     = expected_interval - received_interval;
				int	fraction;
				uint32_t lsr;
				uint32_t dlsr;
				
				s->expected_prior = expected;
				s->received_prior = s->received;
				if (expected_interval == 0 || lost_interval <= 0) {
					fraction = 0;
				} else {
					fraction = (lost_interval << 8) / expected_interval;
				}
				
				if (s->sr == NULL) {
					lsr = 0;
					dlsr = 0;
				} else {
					lsr = ntp64_to_ntp32(s->sr->ntp_sec, s->sr->ntp_frac);
					dlsr = (uint32_t)(tv_diff(now, s->last_sr) * 65536);
				}
				rrp->ssrc       = htonl(s->ssrc);
				rrp->fract_lost = fraction;
				rrp->total_lost = lost & 0x00ffffff;
				rrp->last_seq   = htonl(extended_max);
				rrp->jitter     = htonl(s->jitter / 16);
				rrp->lsr        = htonl(lsr);
				rrp->dlsr       = htonl(dlsr);
				rrp++;
				remaining_length -= 24;
				nblocks++;
				s->sender = FALSE;
				session->sender_count--;
				if (session->sender_count == 0) {
					break; /* No point continuing, since we've reported on all senders... */
				}
			}
		}
	}
	return nblocks;
}

static uint8_t *format_rtcp_sr(uint8_t *buffer, int buflen, struct rtp *session, uint32_t rtp_ts)
{
	/* Write an RTCP SR into buffer, returning a pointer to */
	/* the next byte after the header we have just written. */
	rtcp_t		*packet = (rtcp_t *) buffer;
	int		 remaining_length;
	uint32_t	 ntp_sec, ntp_frac;
	
	assert(buflen >= 28);	/* ...else there isn't space for the header and sender report */
	
	packet->common.version = 2;
	packet->common.p       = 0;
	packet->common.count   = 0;
	packet->common.pt      = RTCP_SR;
	packet->common.length  = htons(1);
	
	ntp64_time(&ntp_sec, &ntp_frac);
	
	packet->r.sr.sr.ssrc          = htonl(rtp_my_ssrc(session));
	packet->r.sr.sr.ntp_sec       = htonl(ntp_sec);
	packet->r.sr.sr.ntp_frac      = htonl(ntp_frac);
	packet->r.sr.sr.rtp_ts        = htonl(rtp_ts);
	packet->r.sr.sr.sender_pcount = htonl(session->rtp_pcount);
	packet->r.sr.sr.sender_bcount = htonl(session->rtp_bcount);
	
	/* Add report blocks, until we either run out of senders */
	/* to report upon or we run out of space in the buffer.  */
	remaining_length = buflen - 28;
	packet->common.count = format_report_blocks(packet->r.sr.rr, remaining_length, session);
	packet->common.length = htons((uint16_t) (6 + (packet->common.count * 6)));
	return buffer + 28 + (24 * packet->common.count);
}

static uint8_t *format_rtcp_rr(uint8_t *buffer, int buflen, struct rtp *session)
{
	/* Write an RTCP RR into buffer, returning a pointer to */
	/* the next byte after the header we have just written. */
	rtcp_t		*packet = (rtcp_t *) buffer;
	int		 remaining_length;
	
	assert(buflen >= 8);	/* ...else there isn't space for the header */
	
	packet->common.version = 2;
	packet->common.p       = 0;
	packet->common.count   = 0;
	packet->common.pt      = RTCP_RR;
	packet->common.length  = htons(1);
	packet->r.rr.ssrc      = htonl(session->my_ssrc);
	
	/* Add report blocks, until we either run out of senders */
	/* to report upon or we run out of space in the buffer.  */
	remaining_length = buflen - 8;
	packet->common.count = format_report_blocks(packet->r.rr.rr, remaining_length, session);
	packet->common.length = htons((uint16_t) (1 + (packet->common.count * 6)));
	return buffer + 8 + (24 * packet->common.count);
}

static int add_sdes_item(uint8_t *buf, int buflen, int type, const char *val)
{
	/* Fill out an SDES item. It is assumed that the item is a NULL    */
	/* terminated string.                                              */
	rtcp_sdes_item *shdr = (rtcp_sdes_item *) buf;
	int             namelen;
	
	if (val == NULL) {
		debug_msg("Cannot format SDES item. type=%d val=%xp\n", type, val);
		return 0;
	}
	shdr->type = type;
	namelen = strlen(val);
	shdr->length = namelen;
	strncpy(shdr->data, val, buflen - 2); /* The "-2" accounts for the other shdr fields */
	return namelen + 2;
}

static uint8_t *format_rtcp_sdes(uint8_t *buffer, int buflen, uint32_t ssrc, struct rtp *session)
{
	/* From draft-ietf-avt-profile-new-00:                             */
	/* "Applications may use any of the SDES items described in the    */
	/* RTP specification. While CNAME information is sent every        */
	/* reporting interval, other items should be sent only every third */
	/* reporting interval, with NAME sent seven out of eight times     */
	/* within that slot and the remaining SDES items cyclically taking */
	/* up the eighth slot, as defined in Section 6.2.2 of the RTP      */
	/* specification. In other words, NAME is sent in RTCP packets 1,  */
	/* 4, 7, 10, 13, 16, 19, while, say, EMAIL is used in RTCP packet  */
	/* 22".                                                            */
	uint8_t		*packet = buffer;
	rtcp_common	*common = (rtcp_common *) buffer;
	const char	*item;
	size_t		 remaining_len;
	int              pad;
	
	assert(buflen > (int) sizeof(rtcp_common));
	
	common->version = 2;
	common->p       = 0;
	common->count   = 1;
	common->pt      = RTCP_SDES;
	common->length  = 0;
	packet += sizeof(common);
	
	*((uint32_t *) packet) = htonl(ssrc);
	packet += 4;
	
	remaining_len = buflen - (packet - buffer);
	item = rtp_get_sdes(session, ssrc, RTCP_SDES_CNAME);
	if ((item != NULL) && ((strlen(item) + (size_t) 2) <= remaining_len)) {
		packet += add_sdes_item(packet, remaining_len, RTCP_SDES_CNAME, item);
	}
	
	remaining_len = buflen - (packet - buffer);
	item = rtp_get_sdes(session, ssrc, RTCP_SDES_NOTE);
	if ((item != NULL) && ((strlen(item) + (size_t) 2) <= remaining_len)) {
		packet += add_sdes_item(packet, remaining_len, RTCP_SDES_NOTE, item);
	}
	
	remaining_len = buflen - (packet - buffer);
	if ((session->sdes_count_pri % 3) == 0) {
		session->sdes_count_sec++;
		if ((session->sdes_count_sec % 8) == 0) {
			/* Note that the following is supposed to fall-through the cases */
			/* until one is found to send... The lack of break statements in */
			/* the switch is not a bug.                                      */
			switch (session->sdes_count_ter % 5) {
				case 0: item = rtp_get_sdes(session, ssrc, RTCP_SDES_TOOL);
					if ((item != NULL) && ((strlen(item) + (size_t) 2) <= remaining_len)) {
						packet += add_sdes_item(packet, remaining_len, RTCP_SDES_TOOL, item);
						break;
					}
				case 1: item = rtp_get_sdes(session, ssrc, RTCP_SDES_EMAIL);
					if ((item != NULL) && ((strlen(item) + (size_t) 2) <= remaining_len)) {
						packet += add_sdes_item(packet, remaining_len, RTCP_SDES_EMAIL, item);
						break;
					}
				case 2: item = rtp_get_sdes(session, ssrc, RTCP_SDES_PHONE);
					if ((item != NULL) && ((strlen(item) + (size_t) 2) <= remaining_len)) {
						packet += add_sdes_item(packet, remaining_len, RTCP_SDES_PHONE, item);
						break;
					}
				case 3: item = rtp_get_sdes(session, ssrc, RTCP_SDES_LOC);
					if ((item != NULL) && ((strlen(item) + (size_t) 2) <= remaining_len)) {
						packet += add_sdes_item(packet, remaining_len, RTCP_SDES_LOC, item);
						break;
					}
				case 4: item = rtp_get_sdes(session, ssrc, RTCP_SDES_PRIV);
					if ((item != NULL) && ((strlen(item) + (size_t) 2) <= remaining_len)) {
						packet += add_sdes_item(packet, remaining_len, RTCP_SDES_PRIV, item);
						break;
					}
			}
			session->sdes_count_ter++;
		} else {
			item = rtp_get_sdes(session, ssrc, RTCP_SDES_NAME);
			if (item != NULL) {
				packet += add_sdes_item(packet, remaining_len, RTCP_SDES_NAME, item);
			}
		}
	}
	session->sdes_count_pri++;
	
	/* Pad to a multiple of 4 bytes... */
	pad = 4 - ((packet - buffer) & 0x3);
	while (pad--) {
		*packet++ = RTCP_SDES_END;
	}
	
	common->length = htons((uint16_t) (((int) (packet - buffer) / 4) - 1));
	
	return packet;
}

static uint8_t *format_rtcp_app(uint8_t *buffer, int buflen, uint32_t ssrc, rtcp_app *app)
{
	/* Write an RTCP APP into the outgoing packet buffer. */
	rtcp_app    *packet       = (rtcp_app *) buffer;
	int          pkt_octets   = (app->length + 1) * 4;
	int          data_octets  =  pkt_octets - 12;
	
	assert(data_octets >= 0);          /* ...else not a legal APP packet.               */
	assert(buflen      >= pkt_octets); /* ...else there isn't space for the APP packet. */
	
	/* Copy one APP packet from "app" to "packet". */
	packet->version        =   RTP_VERSION;
	packet->p              =   app->p;
	packet->subtype        =   app->subtype;
	packet->pt             =   RTCP_APP;
	packet->length         =   htons(app->length);
	packet->ssrc           =   htonl(ssrc);
	memcpy(packet->name, app->name, 4);
	memcpy(packet->data, app->data, data_octets);
	
	/* Return a pointer to the byte that immediately follows the last byte written. */
	return buffer + pkt_octets;
}

static void send_rtcp(struct rtp *session, uint32_t rtp_ts,
					  rtcp_app_callback appcallback)
{
	/* Construct and send an RTCP packet. The order in which packets are packed into a */
	/* compound packet is defined by section 6.1 of draft-ietf-avt-rtp-new-03.txt and  */
	/* we follow the recommended order.                                                */
	uint8_t	   buffer[RTP_MAX_PACKET_LEN + MAX_ENCRYPTION_PAD + RTP_TCP_HEADER_LEN];	/* The +8 is to allow for padding when encrypting */
	uint8_t	  *ptr = buffer;
	uint8_t   *old_ptr;
	uint8_t   *lpt;		/* the last packet in the compound */
	rtcp_app  *app;
	uint8_t    initVec[8] = {0,0,0,0,0,0,0,0};
	
	check_database(session);
	
//	if(session->transport == RTP_TRANSPORT_TCP) {
//		//offset pointer to account for TCP interleave header
//		ptr = buffer + RTP_TCP_HEADER_LEN;
//	}
	
	
	/* If encryption is enabled, add a 32 bit random prefix to the packet */
	//	if (session->encryption_enabled)
	//	{
	//		*((uint32_t *) ptr) = lbl_random();
	//		ptr += 4;
	//	}
	
	/* The first RTCP packet in the compound packet MUST always be a report packet...  */
	if (session->we_sent) {
		ptr = format_rtcp_sr(ptr, RTP_MAX_PACKET_LEN - (ptr - buffer), session, rtp_ts);
	} else {
		ptr = format_rtcp_rr(ptr, RTP_MAX_PACKET_LEN - (ptr - buffer), session);
	}
	/* Add the appropriate SDES items to the packet... This should really be after the */
	/* insertion of the additional report blocks, but if we do that there are problems */
	/* with us being unable to fit the SDES packet in when we run out of buffer space  */
	/* adding RRs. The correct fix would be to calculate the length of the SDES items  */
	/* in advance and subtract this from the buffer length but this is non-trivial and */
	/* probably not worth it.                                                          */
	lpt = ptr;
	ptr = format_rtcp_sdes(ptr, RTP_MAX_PACKET_LEN - (ptr - buffer), rtp_my_ssrc(session), session);
	
	/* If we have any CSRCs, we include SDES items for each of them in turn...         */
	if (session->csrc_count > 0) {
		ptr = format_rtcp_sdes(ptr, RTP_MAX_PACKET_LEN - (ptr - buffer), next_csrc(session), session);
	}
	
	/* Following that, additional RR packets SHOULD follow if there are more than 31   */
	/* senders, such that the reports do not fit into the initial packet. We give up   */
	/* if there is insufficient space in the buffer: this is bad, since we always drop */
	/* the reports from the same sources (those at the end of the hash table).         */
	while ((session->sender_count > 0)  && ((RTP_MAX_PACKET_LEN - (ptr - buffer)) >= 8)) {
		lpt = ptr;
		ptr = format_rtcp_rr(ptr, RTP_MAX_PACKET_LEN - (ptr - buffer), session);
	}
	
	/* Finish with as many APP packets as the application will provide. */
	old_ptr = ptr;
	if (appcallback) {
		while ((app = (*appcallback)(session, rtp_ts, RTP_MAX_PACKET_LEN - (ptr - buffer)))) {
			lpt = ptr;
			ptr = format_rtcp_app(ptr, RTP_MAX_PACKET_LEN - (ptr - buffer), rtp_my_ssrc(session), app);
			assert(ptr > old_ptr);
			old_ptr = ptr;
			assert(RTP_MAX_PACKET_LEN - (ptr - buffer) >= 0);
		}
	}
	
	/* And encrypt if desired... */
	//	if (session->encryption_enabled)
	//	  {
	//		if (((ptr - buffer) % session->encryption_pad_length) != 0) {
	//			/* Add padding to the last packet in the compound, if necessary. */
	//			/* We don't have to worry about overflowing the buffer, since we */
	//			/* intentionally allocated it 8 bytes longer to allow for this.  */
	//			int	padlen = session->encryption_pad_length - ((ptr - buffer) % session->encryption_pad_length);
	//			int	i;
	//
	//			for (i = 0; i < padlen-1; i++) {
	//				*(ptr++) = '\0';
	//			}
	//			*(ptr++) = (uint8_t) padlen;
	//			assert(((ptr - buffer) % session->encryption_pad_length) == 0); 
	//
	//			((rtcp_t *) lpt)->common.p = TRUE;
	//			((rtcp_t *) lpt)->common.length = htons((int16_t)(((ptr - lpt) / 4) - 1));
	//		}
	// 		(session->encrypt_func)(session, buffer, ptr - buffer, initVec); 
	//	}
	//SV-XXX udp_send(session->rtcp_socket, buffer, ptr - buffer);
	//printf("Sending RTCP Report\n");
	
	if(session->transport == RTP_TRANSPORT_UDP) {
		udp_send(session->rtcp_socket, (char *) buffer, ptr - buffer);
	}
	else if(session->transport == RTP_TRANSPORT_TCP) {
//		uint8_t *pb8 = buffer;
//		pb8[0] = '$';
//		pb8[1] = session->rtsp_rtcp;
//		uint16_t *pb16 = (uint16_t*) pb8[2];
//		*pb16 = htons(ptr - buffer - RTP_TCP_HEADER_LEN);
		//printf("Sending RTCP PACKET\n");
		tcp_send(session->rtsp_socket, session->rtsp_rtcp, (char*)buffer, ptr - buffer);
		
	}
	
	/* Loop the data back to ourselves so local participant can */
	/* query own stats when using unicast or multicast with no  */
	/* loopback.                                                */
	rtp_process_ctrl(session, buffer, ptr - buffer);
	check_database(session);
}

/**
 * rtp_send_ctrl:
 * @session: the session pointer (returned by rtp_init())
 * @rtp_ts: the current time expressed in units of the media timestamp.
 * @appcallback: a callback to create an APP RTCP packet, if needed.
 *
 * Checks RTCP timer and sends RTCP data when nececessary.  The
 * interval between RTCP packets is randomized over an interval that
 * depends on the session bandwidth, the number of participants, and
 * whether the local participant is a sender.  This function should be
 * called at least once per second, and can be safely called more
 * frequently.  
 */
void rtp_send_ctrl(struct rtp *session, uint32_t rtp_ts, rtcp_app_callback appcallback)
{
	/* Send an RTCP packet, if one is due... */
	struct timeval	 curr_time;
	
	check_database(session);
	gettimeofday(&curr_time, NULL);
	if (tv_gt(curr_time, session->next_rtcp_send_time)) {
		/* The RTCP transmission timer has expired. The following */
		/* implements draft-ietf-avt-rtp-new-02.txt section 6.3.6 */
		int		 h;
		source		*s;
		struct timeval	 new_send_time;
		double		 new_interval;
		
		new_interval  = rtcp_interval(session) / (session->csrc_count + 1);
		new_send_time = session->last_rtcp_send_time;
		tv_add(&new_send_time, new_interval);
		if (tv_gt(curr_time, new_send_time)) {
			send_rtcp(session, rtp_ts, appcallback);
			session->initial_rtcp        = FALSE;
			session->last_rtcp_send_time = curr_time;
			session->next_rtcp_send_time = curr_time; 
			tv_add(&(session->next_rtcp_send_time), rtcp_interval(session) / (session->csrc_count + 1));
			/* We're starting a new RTCP reporting interval, zero out */
			/* the per-interval statistics.                           */
			session->sender_count = 0;
			for (h = 0; h < RTP_DB_SIZE; h++) {
				for (s = session->db[h]; s != NULL; s = s->next) {
					check_source(s);
					s->sender = FALSE;
				}
			}
		} else {
			session->next_rtcp_send_time = new_send_time;
		}
		session->ssrc_count_prev = session->ssrc_count;
	} 
	check_database(session);
}

/**
 * rtp_update:
 * @session: the session pointer (returned by rtp_init())
 *
 * Trawls through the internal data structures and performs
 * housekeeping.  This function should be called at least once per
 * second.  It uses an internal timer to limit the number of passes
 * through the data structures to once per second, it can be safely
 * called more frequently.
 */
void rtp_update(struct rtp *session)
{
	/* Perform housekeeping on the source database... */
	int	 	 h;
	source	 	*s, *n;
	struct timeval	 curr_time;
	double		 delay;
	
	gettimeofday(&curr_time, NULL);
	if (tv_diff(curr_time, session->last_update) < 1.0) {
		/* We only perform housekeeping once per second... */
		return;
	}
	session->last_update = curr_time;
	
	/* Update we_sent (section 6.3.8 of RTP spec) */
	delay = tv_diff(curr_time, session->last_rtp_send_time);
	if (delay >= 2 * rtcp_interval(session)) {
		session->we_sent = FALSE;
	}
	
	check_database(session);
	
	for (h = 0; h < RTP_DB_SIZE; h++) {
		for (s = session->db[h]; s != NULL; s = n) {
			check_source(s);
			n = s->next;
			/* Expire sources which haven't been heard from for a long time.   */
			/* Section 6.2.1 of the RTP specification details the timers used. */
			
			/* How long since we last heard from this source?  */
			delay = tv_diff(curr_time, s->last_active);
			
			/* Check if we've received a BYE packet from this source.    */
			/* If we have, and it was received more than 2 seconds ago   */
			/* then the source is deleted. The arbitrary 2 second delay  */
			/* is to ensure that all delayed packets are received before */
			/* the source is timed out.                                  */
			if (s->got_bye && (delay > 2.0)) {
				debug_msg("Deleting source 0x%08lx due to reception of BYE %f seconds ago...\n", s->ssrc, delay);
				delete_source(session, s->ssrc);
				continue;
			}
			
			/* Sources are marked as inactive if they haven't been heard */
			/* from for more than 2 intervals (RTP section 6.3.5)        */
			if ((s->ssrc != rtp_my_ssrc(session)) && (delay > (session->rtcp_interval * 2))) {
				if (s->sender) {
					s->sender = FALSE;
					session->sender_count--;
				}
			}
			
			/* If a source hasn't been heard from for more than 5 RTCP   */
			/* reporting intervals, we delete it from our database...    */
			if ((s->ssrc != rtp_my_ssrc(session)) && (delay > (session->rtcp_interval * 5))) {
				debug_msg("Deleting source 0x%08lx due to timeout...\n", s->ssrc);
				delete_source(session, s->ssrc);
			}
		}
	}
	
	/* Timeout those reception reports which haven't been refreshed for a long time */
	timeout_rr(session, &curr_time);
	check_database(session);
}

static void rtp_send_bye_now(struct rtp *session)
{
	/* Send a BYE packet immediately. This is an internal function,  */
	/* hidden behind the rtp_send_bye() wrapper which implements BYE */
	/* reconsideration for the application.                          */
	uint8_t	 	 buffer[RTP_MAX_PACKET_LEN + MAX_ENCRYPTION_PAD + RTP_TCP_HEADER_LEN];	/* + 8 to allow for padding when encrypting */
	uint8_t		*ptr = buffer;
	rtcp_common	*common;
	uint8_t    	 initVec[8] = {0,0,0,0,0,0,0,0};
	
	check_database(session);
	/* If encryption is enabled, add a 32 bit random prefix to the packet */
	//	if (session->encryption_enabled) {
	//		*((uint32_t *) ptr) = lbl_random();
	//		ptr += 4;
	//	}
	
//	if(session->transport == RTP_TRANSPORT_TCP) {
//		//offset pointer to account for TCP interleave header
//		ptr = buffer + RTP_TCP_HEADER_LEN;
//	}
	
	ptr    = format_rtcp_rr(ptr, RTP_MAX_PACKET_LEN - (ptr - buffer), session);    
	common = (rtcp_common *) ptr;
	
	common->version = 2;
	common->p       = 0;
	common->count   = 1;
	common->pt      = RTCP_BYE;
	common->length  = htons(1);
	ptr += sizeof(common);
	
	*((uint32_t *) ptr) = htonl(session->my_ssrc);  
	ptr += 4;
	
	//	if (session->encryption_enabled) {
	//		if (((ptr - buffer) % session->encryption_pad_length) != 0) {
	//			/* Add padding to the last packet in the compound, if necessary. */
	//			/* We don't have to worry about overflowing the buffer, since we */
	//			/* intentionally allocated it 8 bytes longer to allow for this.  */
	//			int	padlen = session->encryption_pad_length - ((ptr - buffer) % session->encryption_pad_length);
	//			int	i;
	//
	//			for (i = 0; i < padlen-1; i++) {
	//				*(ptr++) = '\0';
	//			}
	//			*(ptr++) = (uint8_t) padlen;
	//
	//			common->p      = TRUE;
	//			common->length = htons((int16_t)(((ptr - (uint8_t *) common) / 4) - 1));
	//		}
	//		assert(((ptr - buffer) % session->encryption_pad_length) == 0);
	//		(session->encrypt_func)(session, buffer, ptr - buffer, initVec);
	//	}
	//SV-XXX udp_send(session->rtcp_socket, buffer, ptr - buffer);
	if(session->transport == RTP_TRANSPORT_UDP) {
		udp_send(session->rtcp_socket, (char *) buffer, ptr - buffer);
	}
	else if(session->transport == RTP_TRANSPORT_TCP) {
//		uint8_t *pb8 = buffer;
//		pb8[0] = '$';
//		pb8[1] = session->rtsp_rtcp;
//		uint16_t *pb16 = (uint16_t*) pb8[2];
//		*pb16 = htons(ptr - buffer - RTP_TCP_HEADER_LEN);
		tcp_send(session->rtsp_socket, session->rtsp_rtcp, buffer, ptr - buffer);	
	}
	
	/* Loop the data back to ourselves so local participant can */
	/* query own stats when using unicast or multicast with no  */
	/* loopback.                                                */
	rtp_process_ctrl(session, buffer, ptr - buffer);
	check_database(session);
}

/**
 * rtp_send_bye:
 * @session: The RTP session
 *
 * Sends a BYE message on the RTP session, indicating that this
 * participant is leaving the session. The process of sending a
 * BYE may take some time, and this function will block until 
 * it is complete. During this time, RTCP events are reported 
 * to the application via the callback function (data packets 
 * are silently discarded).
 */
void rtp_send_bye(struct rtp *session)
{
	struct timeval	curr_time, timeout, new_send_time;
	uint8_t		buffer[RTP_MAX_PACKET_LEN];
	int		buflen;
	double		new_interval;
	
	check_database(session);
	
	/* "...a participant which never sent an RTP or RTCP packet MUST NOT send  */
	/* a BYE packet when they leave the group." (section 6.3.7 of RTP spec)    */
	if ((session->we_sent == FALSE) && (session->initial_rtcp == TRUE)) {
		debug_msg("Silent BYE\n");
		return;
	}
	
	/* If the session is small, send an immediate BYE. Otherwise, we delay and */
	/* perform BYE reconsideration as needed.                                  */
	if (session->ssrc_count < 50) {
		rtp_send_bye_now(session);
	} else {
		gettimeofday(&curr_time, NULL);
		session->sending_bye         = TRUE;
		session->last_rtcp_send_time = curr_time;
		session->next_rtcp_send_time = curr_time; 
		session->bye_count           = 1;
		session->initial_rtcp        = TRUE;
		session->we_sent             = FALSE;
		session->sender_count        = 0;
		session->avg_rtcp_size       = 70.0 + RTP_LOWER_LAYER_OVERHEAD;	/* FIXME */
		tv_add(&session->next_rtcp_send_time, rtcp_interval(session) / (session->csrc_count + 1));
		
		debug_msg("Preparing to send BYE...\n");
		while (1) {
			
			/* Schedule us to block in udp_select() until the time we are due to send our */
			/* BYE packet. If we receive an RTCP packet from another participant before   */
			/* then, we are woken up to handle it...                                      */
			timeout.tv_sec  = 0;
			timeout.tv_usec = 0;
			tv_add(&timeout, tv_diff(session->next_rtcp_send_time, curr_time));
			
			if(session->transport == RTP_TRANSPORT_UDP) {
				udp_fd_zero();
				udp_fd_set(session->rtcp_socket);
				if ((udp_select(&timeout) > 0) && udp_fd_isset(session->rtcp_socket)) {
					/* We woke up because an RTCP packet was received; process it... */
					//SV-XXX buflen = udp_recv(session->rtcp_socket, buffer, RTP_MAX_PACKET_LEN);
					buflen = udp_recv(session->rtcp_socket, (char *) buffer, RTP_MAX_PACKET_LEN);
					rtp_process_ctrl(session, buffer, buflen);
				}
			}
			else if(session->transport == RTP_TRANSPORT_TCP) {
				//TODO: Implement
				#warning rtp_send_bye for TCP not implemented
			}
			
			/* Is it time to send our BYE? */
			gettimeofday(&curr_time, NULL);
			new_interval  = rtcp_interval(session) / (session->csrc_count + 1);
			new_send_time = session->last_rtcp_send_time;
			tv_add(&new_send_time, new_interval);
			if (tv_gt(curr_time, new_send_time)) {
				debug_msg("Sent BYE...\n");
				rtp_send_bye_now(session);
				break;
			}
			/* No, we reconsider... */
			session->next_rtcp_send_time = new_send_time;
			debug_msg("Reconsidered sending BYE... delay = %f\n", tv_diff(session->next_rtcp_send_time, curr_time));
			/* ...and perform housekeeping in the usual manner */
			rtp_update(session);
		}
	}
}

int udp_send_raw(struct rtp *session, char *buffer, int buffer_len) {
    return udp_send(session->rtp_socket, buffer, buffer_len);
}

/**
 * rtp_done:
 * @session: the RTP session to finish
 *
 * Free the state associated with the given RTP session. This function does 
 * not send any packets (e.g. an RTCP BYE) - an application which wishes to
 * exit in a clean manner should call rtp_send_bye() first.
 */
void rtp_done(struct rtp *session)
{
	int i;
	source *s, *n;
	
	check_database(session);
	/* In delete_source, check database gets called and this assumes */
	/* first added and last removed is us.                           */
	for (i = 0; i < RTP_DB_SIZE; i++) {
		s = session->db[i];
		while (s != NULL) {
			n = s->next;
			if (s->ssrc != session->my_ssrc) {
				delete_source(session,session->db[i]->ssrc);
			}
			s = n;
		}
	}
	
	delete_source(session, session->my_ssrc);
	
	/*
	 * Introduce a memory leak until we add algorithm-specific
	 * cleanup functions.
	 if (session->encryption_key != NULL) {
	 xfree(session->encryption_key);
	 }
	 */
	
	if(session->transport == RTP_TRANSPORT_UDP) {
		udp_exit(session->rtp_socket);
		udp_exit(session->rtcp_socket);
	}
	else if(session->transport == RTP_TRANSPORT_TCP) {
		tcp_exit(session->rtsp_socket);
	}
	else {
		debug_msg("Unknown transport shutdown");
	}
	xfree(session->addr);
	xfree(session->opt);
	xfree(session);
}


/**
 * rtp_get_addr:
 * @session: The RTP Session.
 *
 * Returns: The session's destination address, as set when creating the
 * session with rtp_init() or rtp_init_if().
 */
char *rtp_get_addr(struct rtp *session)
{
	check_database(session);
	return session->addr;
}

/**
 * rtp_get_rx_port:
 * @session: The RTP Session.
 *
 * Returns: The UDP port to which this session is bound, as set when
 * creating the session with rtp_init() or rtp_init_if().
 */
uint16_t rtp_get_rx_port(struct rtp *session)
{
	check_database(session);
	return session->rx_port;
}

/**
 * rtp_get_tx_port:
 * @session: The RTP Session.
 *
 * Returns: The UDP port to which RTP packets are transmitted, as set
 * when creating the session with rtp_init() or rtp_init_if().
 */
uint16_t rtp_get_tx_port(struct rtp *session)
{
	check_database(session);
	return session->tx_port;
}

/**
 * rtp_get_ttl:
 * @session: The RTP Session.
 *
 * Returns: The session's TTL, as set when creating the session with
 * rtp_init() or rtp_init_if().
 */
int rtp_get_ttl(struct rtp *session)
{
	check_database(session);
	return session->ttl;
}

