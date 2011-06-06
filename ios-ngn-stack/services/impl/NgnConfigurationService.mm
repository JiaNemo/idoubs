/* Copyright (C) 2010-2011, Mamadou Diop.
 * Copyright (c) 2011, Doubango Telecom. All rights reserved.
 *
 * Contact: Mamadou Diop <diopmamadou(at)doubango(dot)org>
 *       
 * This file is part of iDoubs Project ( http://code.google.com/p/idoubs )
 *
 * idoubs is free software: you can redistribute it and/or modify it under the terms of 
 * the GNU General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 *       
 * idoubs is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
 * See the GNU General Public License for more details.
 *       
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */
#import "NgnConfigurationService.h"
#import "NgnConfigurationEntry.h"

#import "tinydav.h"
#import "SipStack.h"

#undef TAG
#define kTAG @"NgnConfigurationService///: "
#define TAG kTAG

//
// private implementation
// 

@interface NgnConfigurationService(Private)
- (void)userDefaultsDidChangeNotification:(NSNotification *)note;
- (void)computeCodecs;
@end

@implementation NgnConfigurationService(Private)

- (void)userDefaultsDidChangeNotification:(NSNotification *)note{
	[self computeCodecs];
}

- (void)computeCodecs{
	
	typedef struct codec_value_pair_s {
		NSString* name;
		tdav_codec_id_t _id;
	}
	codec_value_pair_t;
	
	tdav_codec_id_t oldCodecs = (tdav_codec_id_t)[self getIntWithKey:MEDIA_CODECS];
	tdav_codec_id_t newCodecs = tdav_codec_id_none;
	
	codec_value_pair_t codec_value_pairs[] = 
	{
		{ MEDIA_CODEC_USE_G729AB, tdav_codec_id_g729ab },
		{ MEDIA_CODEC_USE_AMR_NB_OA, tdav_codec_id_amr_nb_oa },
		{ MEDIA_CODEC_USE_AMR_NB_BE, tdav_codec_id_amr_nb_be },
		{ MEDIA_CODEC_USE_GSM, tdav_codec_id_gsm },
		{ MEDIA_CODEC_USE_PCMA, tdav_codec_id_pcma },
		{ MEDIA_CODEC_USE_PCMU, tdav_codec_id_pcmu },
		{ MEDIA_CODEC_USE_SPEEX_NB, tdav_codec_id_speex_nb },
		{ MEDIA_CODEC_USE_H263, tdav_codec_id_h263 },
		{ MEDIA_CODEC_USE_H263P, tdav_codec_id_h263p },
		{ MEDIA_CODEC_USE_H264BP10, tdav_codec_id_h264_bp10 },
		{ MEDIA_CODEC_USE_H264BP20, tdav_codec_id_h264_bp20 },
		{ MEDIA_CODEC_USE_H264BP30, tdav_codec_id_h264_bp30 },
		{ MEDIA_CODEC_USE_THEORA, tdav_codec_id_theora },
		{ MEDIA_CODEC_USE_MP4VES, tdav_codec_id_mp4ves_es },
	};
	
	for (int i = 0; i < sizeof(codec_value_pairs)/sizeof(codec_value_pair_t); ++i) {
		if([self getBoolWithKey:codec_value_pairs[i].name]){
			newCodecs = (tdav_codec_id_t)(newCodecs | codec_value_pairs[i]._id);
		}
	}
	
	if(oldCodecs != newCodecs){ // avoid stack overflow
		// write to the settings
		[self setIntWithKey:MEDIA_CODECS andValue:(int)newCodecs];
	}
	
	// configure the stack
	SipStack::setCodecs(newCodecs);
}

@end


//
//	default implementation
//

@implementation NgnConfigurationService

-(NgnConfigurationService*)init{
	if((self = [super init])){
		defaults = [NSUserDefaults standardUserDefaults];
		
		// FIXME: First time for Simulator
		NSDictionary *defaults_ = [NSDictionary dictionaryWithObjectsAndKeys:
								  
								  
								  /* === IDENTITY === */
								  DEFAULT_IDENTITY_DISPLAY_NAME, IDENTITY_DISPLAY_NAME,
								  DEFAULT_IDENTITY_IMPI, IDENTITY_IMPI,
								  DEFAULT_IDENTITY_IMPU, IDENTITY_IMPU,
								  DEFAULT_IDENTITY_PASSWORD, IDENTITY_PASSWORD,
								  
								  /* === NETWORK === */
								  [NSNumber numberWithBool:DEFAULT_NETWORK_USE_EARLY_IMS], NETWORK_USE_EARLY_IMS,
								  DEFAULT_NETWORK_IP_VERSION, NETWORK_IP_VERSION,
								  DEFAULT_NETWORK_PCSCF_HOST, NETWORK_PCSCF_HOST,
								  [NSNumber numberWithInt:DEFAULT_NETWORK_PCSCF_PORT], NETWORK_PCSCF_PORT,
								  DEFAULT_NETWORK_REALM, NETWORK_REALM,
								  [NSNumber numberWithBool:DEFAULT_NETWORK_USE_SIGCOMP], NETWORK_USE_SIGCOMP,
								  [NSNumber numberWithBool:DEFAULT_NETWORK_USE_3G], NETWORK_USE_3G,
								  [NSNumber numberWithBool:DEFAULT_NETWORK_USE_WIFI], NETWORK_USE_WIFI,
								  DEFAULT_NETWORK_TRANSPORT, NETWORK_TRANSPORT,
								  
								  /* === MEDIA === */
								  [NSNumber numberWithInt:DEFAULT_MEDIA_CODECS], MEDIA_CODECS,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_G729AB], MEDIA_CODEC_USE_G729AB,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_AMR_NB_OA], MEDIA_CODEC_USE_AMR_NB_OA,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_AMR_NB_BE], MEDIA_CODEC_USE_AMR_NB_BE,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_GSM], MEDIA_CODEC_USE_GSM,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_PCMA], MEDIA_CODEC_USE_PCMA,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_PCMU], MEDIA_CODEC_USE_PCMU,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_SPEEX_NB], MEDIA_CODEC_USE_SPEEX_NB,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_H263], MEDIA_CODEC_USE_H263,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_H263P], MEDIA_CODEC_USE_H263P,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_H264BP10], MEDIA_CODEC_USE_H264BP10,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_H264BP20], MEDIA_CODEC_USE_H264BP20,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_H264BP30], MEDIA_CODEC_USE_H264BP30,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_THEORA], MEDIA_CODEC_USE_THEORA,
								  [NSNumber numberWithBool:DEFAULT_MEDIA_CODEC_USE_MP4VES], MEDIA_CODEC_USE_MP4VES,
								  
								  /* === NATT === */
								  [NSNumber numberWithBool:DEFAULT_NATT_USE_STUN], NATT_USE_STUN,
								  [NSNumber numberWithBool:DEFAULT_NATT_STUN_DISCO], NATT_STUN_DISCO,
								  DEFAULT_NATT_STUN_SERVER, NATT_STUN_SERVER,
								  [NSNumber numberWithInt:DEFAULT_NATT_STUN_PORT], NATT_STUN_PORT,
								  
								  /* === SECURITY === */
								  DEFAULT_SECURITY_IMSAKA_OPID, SECURITY_IMSAKA_OPID,
								  
								  /* === RCS === */
								  [NSNumber numberWithBool:DEFAULT_RCS_AUTO_ACCEPT_PAGER_MODE_IM], RCS_AUTO_ACCEPT_PAGER_MODE_IM,
								  
								  nil];
		
		[defaults registerDefaults:defaults_];
		
		[self computeCodecs];
	}
	return self;
}

-(void)dealloc{
	[self stop];
	
	[super dealloc];
}

//
// INgnBaseService
//

-(BOOL) start{
	NgnNSLog(TAG, @"Start()");
	[self computeCodecs];
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(userDefaultsDidChangeNotification:) name: NSUserDefaultsDidChangeNotification object: nil];
	return YES;
}

-(BOOL) stop{
	NgnNSLog(TAG, @"Stop()");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	return YES;
}


//
//	INgnConfigurationService
//

-(NSString*)getStringWithKey: (NSString*)key{
	return [defaults stringForKey:key];
}

-(int)getIntWithKey: (NSString*)key{
	return [defaults integerForKey:key];
}


-(float)getFloatWithKey: (NSString*)key{
	return [defaults floatForKey:key];
}


-(BOOL)getBoolWithKey: (NSString*)key{
	return [defaults boolForKey:key];
}

-(void)setStringWithKey: (NSString*)key andValue:(NSString*)value{
	[defaults setObject:value forKey:key];
}

-(void)setIntWithKey: (NSString*)key andValue:(int)value{
	[defaults setInteger:value forKey:key];
}

-(void)setFloatWithKey: (NSString*)key andValue:(float)value{
	[defaults setFloat:value forKey:key];
}

-(void)setBoolWithKey: (NSString*)key andValue:(BOOL)value{
	[defaults setBool:value forKey:key];
}

@end
