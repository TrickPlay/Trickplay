#ifndef _TRICKPLAY_AUDIO_SAMPLING_H
#define _TRICKPLAY_AUDIO_SAMPLING_H

#include "trickplay/audio-sampler.h"

TPAudioSampler* tp_context_get_audio_sampler( TPContext* context );

void tp_audio_sampler_submit_buffer( TPAudioSampler* sampler , TPAudioBuffer* buffer );

void tp_audio_sampler_source_changed( TPAudioSampler* sampler );

#endif // _TRICKPLAY_AUDIO_SAMPLING_H
