/*******************************************************************/
/*                                                                 */
/*                      ADOBE CONFIDENTIAL                         */
/*                   _ _ _ _ _ _ _ _ _ _ _ _ _                     */
/*                                                                 */
/* Copyright 2007 Adobe Systems Incorporated                       */
/* All Rights Reserved.                                            */
/*                                                                 */
/* NOTICE:  All information contained herein is, and remains the   */
/* property of Adobe Systems Incorporated and its suppliers, if    */
/* any.  The intellectual and technical concepts contained         */
/* herein are proprietary to Adobe Systems Incorporated and its    */
/* suppliers and may be covered by U.S. and Foreign Patents,       */
/* patents in process, and are protected by trade secret or        */
/* copyright law.  Dissemination of this information or            */
/* reproduction of this material is strictly forbidden unless      */
/* prior written permission is obtained from Adobe Systems         */
/* Incorporated.                                                   */
/*                                                                 */
/*******************************************************************/

/*	Skeleton.cpp	

	This is a compiling husk of a project. Fill it in with interesting
	pixel processing code.
	

	Revision history: 

	1.0 (seemed like a good idea at the time)	bbb		6/1/2002

	1.0 Okay, I'm leaving the version at 1.0,	bbb		2/15/2006
		for obvious reasons; you're going to 
		copy these files directly! This is the
		first XCode version, though.			

*/

#import "AudioFFTRender.h"
#import "PF_Suite_Helper.h"
#import <AE_ChannelSuites.h>
#import "AE_Macros.h"
#import "Param_Utils.h"
#import "AE_EffectCBSuites.h"
#import "AE_EffectCB.h"

////#import "String_Utils.h"
////#import "AE_GeneralPlug.h"
////#import "AEFX_ChannelDepthTpl.h"
////#import "AEGP_SuiteHandler.h"
////#import "AudioFFTRender_Strings.h"

static PF_Err About( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ) {

	PF_SPRINTF( out_data->return_msg, "%s v%d.%d\r%s", "AudioFFTRender", MAJOR_VERSION, MINOR_VERSION, "Fuck you c++" );

//	AEGP_SuiteHandler suites(in_data->pica_basicP);
//	suites.ANSICallbacksSuite1()->sprintf( out_data->return_msg, "%s v%d.%d\r%s", STR(StrID_Name), MAJOR_VERSION, MINOR_VERSION, STR(StrID_Description));
	return PF_Err_NONE;
}

/*
 * Set flags
 */
static PF_Err GlobalSetup( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ) {

	out_data->my_version = PF_VERSION( MAJOR_VERSION, MINOR_VERSION, BUG_VERSION, STAGE_VERSION, BUILD_VERSION );

	// if you change these, update the pipl
	out_data->out_flags =	
//							PF_OutFlag_PIX_INDEPENDENT	|
//							PF_OutFlag_DEEP_COLOR_AWARE	|	// just 16bpc, not 32bpc
							PF_OutFlag_I_USE_AUDIO	|		// visual effects that check out audio data, but don’t modify it.
							PF_OutFlag_AUDIO_EFFECT_TOO;
	
//	out_data->out_flags2 =
			//				PF_OutFlag2_SUPPORTS_QUERY_DYNAMIC_FLAGS |
			//				PF_OutFlag2_SUPPORTS_SMART_RENDER |
			//				PF_OutFlag2_FLOAT_COLOR_AWARE; // |
			//				PF_OutFlag2_REVEALS_ZERO_ALPHA;	// See the test to determine if you need this 

	return PF_Err_NONE;
}

static PF_Err ParamsSetup(	PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ) {

	PF_Err err = PF_Err_NONE;
	PF_ParamDef def;

	AEFX_CLR_STRUCT(def);

	PF_ADD_SLIDER( "AudioFFTRender", SKELETON_AMOUNT_MIN, SKELETON_AMOUNT_MAX, SKELETON_AMOUNT_MIN, SKELETON_AMOUNT_MAX, SKELETON_AMOUNT_DFLT, AMOUNT_DISK_ID);

	AEFX_CLR_STRUCT(def);

	
	PF_ADD_COLOR( "Color", PF_HALF_CHAN8, PF_MAX_CHAN8, PF_MAX_CHAN8, COLOR_DISK_ID);
	
	AEFX_CLR_STRUCT(def);
	
	PF_ADD_CHECKBOX( "Use Downsample Factors", "Correct at all resolutions", FALSE, 0, DOWNSAMPLE_DISK_ID );

	PF_ADD_CHECKBOX( "Use lights and cameras", "", FALSE, 0, THREED_DISK_ID);

	
	out_data->num_params = SKELETON_NUM_PARAMS;

	return err;
}

static PF_Err FrameSetup( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ) {

	// Output buffer resizing may only occur during PF_Cmd_FRAME_SETUP. 

	double border_x = 0, border_y = 0, border = params[SKELETON_AMOUNT]->u.sd.value;
	
	if (params[SKELETON_DOWNSAMPLE]->u.bd.value) {
		// shrink the border to accomodate decreased resolutions.
		border_x = border * ((double)in_data->downsample_x.num / (double)in_data->downsample_x.den);
		border_y = border * ((double)in_data->downsample_y.num / (double)in_data->downsample_y.den);
	} else {
		border_x = border_y = border;
	}
	
	// add 2 times the border width and height to the input width and
	// height to get the output size.
	 
	out_data->width  = 2 * (long)border_x + params[0]->u.ld.width;
	out_data->height = 2 * (long)border_y + params[0]->u.ld.height;
	
	// The origin of the input buffer corresponds to the (border_x, 
	// border_y) pixel in the output buffer.
	 
	out_data->origin.h = (short)border_x;
	out_data->origin.v = (short)border_y;

	out_data->out_flags &= PF_OutFlag_I_USE_AUDIO;
	
	return PF_Err_NONE;
}

static PF_Err Render( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ) {

	PF_Err err = PF_Err_NONE;
//	AEGP_SuiteHandler suites(in_data->pica_basicP);

	/* Put interesting code here. */
	PF_LayerAudio audio = NULL;
	ERR( PF_CHECKOUT_LAYER_AUDIO( in_data, 0, in_data->start_sampL, in_data->dur_sampL, in_data->time_scale, SND_RATE_44100, PF_SSS_4, PF_Channels_MONO, PF_SIGNED_FLOAT, &audio ));
	
	PF_SndSamplePtr data0 = NULL;
	A_long num_samples_bufferL = 0;
	ERR( PF_GET_AUDIO_DATA( in_data, audio, &data0, &num_samples_bufferL, NULL, NULL, NULL, NULL));  
	
	// Premiere Pro/Elements doesn't support the PF World Transform Suite,
	// but it does support many of the callbacks in utils
	if (in_data->appl_id != 'PrMr') {
//		ERR(suites.WorldTransformSuite1()->copy(in_data->effect_ref, &params[SKELETON_INPUT]->u.ld, output, NULL, NULL));
	} else {
		ERR( PF_COPY( &params[SKELETON_INPUT]->u.ld, output, NULL, NULL));
	}

	return err;
}

static PF_Err DescribeDependencies( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], void *extra ) {

	PF_Err err = PF_Err_NONE;
	PF_ExtDependenciesExtra *extraP = (PF_ExtDependenciesExtra*)extra;
	PF_Handle msgH	= NULL;

//	AEGP_SuiteHandler suites(in_data->pica_basicP);
		
		switch (extraP->check_type) 
		{

			case PF_DepCheckType_ALL_DEPENDENCIES:

//				msgH = suites.HandleSuite1()->host_new_handle(strlen(STR(StrID_DependString1)) + 1);
//				suites.ANSICallbacksSuite1()->strcpy(reinterpret_cast<char*>(DH(msgH)),STR(StrID_DependString1));
				break;

			case PF_DepCheckType_MISSING_DEPENDENCIES:
				
				// about one ninth of the time, something's missing 

				if (rand() % 9)	{
//					msgH = suites.HandleSuite1()->host_new_handle(strlen(STR(StrID_DependString2)) + 1);
//					suites.ANSICallbacksSuite1()->strcpy(reinterpret_cast<char*>(DH(msgH)),STR(StrID_DependString2));
				}
				break;

			default:
//				msgH = suites.HandleSuite1()->host_new_handle(strlen(STR(StrID_NONE)) + 1);
				if (msgH){
//					suites.ANSICallbacksSuite1()->strcpy(reinterpret_cast<char*>(DH(msgH)),STR(StrID_NONE));
				}
				break;

		}

		extraP->dependencies_strH = msgH;

		return err;
}

static PF_Err QueryDynamicFlags( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], void *extra ) {

	PF_Err err = PF_Err_NONE, err2 = PF_Err_NONE;
	PF_ParamDef def;

	AEFX_CLR_STRUCT(def);
	
	/*	The parameter array passed with PF_Cmd_QUERY_DYNAMIC_FLAGS
		contains invalid values; use PF_CHECKOUT_PARAM() to obtain
		real values.
	*/
	
	ERR(PF_CHECKOUT_PARAM( in_data, SKELETON_USE_3D, in_data->current_time, in_data->time_step, in_data->time_scale, &def));
	if (!err){
		// if it's checked
//		if (def.u.bd.value)	{	
//			out_data->out_flags2 |= PF_OutFlag2_I_USE_3D_LIGHTS;
//			out_data->out_flags2 |= PF_OutFlag2_I_USE_3D_CAMERA;
//		} else {
//			out_data->out_flags2 &= ~PF_OutFlag2_I_USE_3D_LIGHTS;
//			out_data->out_flags2 &= ~PF_OutFlag2_I_USE_3D_CAMERA;
//		}
	}
	ERR2(PF_CHECKIN_PARAM(in_data, &def));
	return err;
}

static PF_Err Audio_Setup( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ) {
	
	PF_Err err = PF_Err_NONE;

	out_data->start_sampL = in_data->total_sampL - in_data->dur_sampL - in_data->start_sampL; // calculate new sample
	out_data->dur_sampL = in_data->dur_sampL;
	
	if( out_data->start_sampL<0 ){	
		out_data->start_sampL = 0;
	}
	
	if( out_data->dur_sampL > in_data->total_sampL ){
		out_data->dur_sampL	= in_data->total_sampL;
	}
	return err;
}

// Render the entire audio track, probably before the video, eh?
static PF_Err Audio_Render( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ) {

	PF_Err	err = PF_Err_NONE;
	printf("Holey Render");

	return	err;
} 

static PF_Err SequenceSetup( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output) {

	PF_Err	err	=	PF_Err_NONE;
	
	printf("SequenceSetup");

//	if ((out_data->sequence_data = PF_NEW_HANDLE(sizeof(SmartyPantsData)))) {
//		((SmartyPantsData *)DH(out_data->sequence_data))->channel = -1L;
//		out_data->flat_sdata_size = sizeof(SmartyPantsData);
//		
//	} else {
//		PF_STRCPY(out_data->return_msg, STR(StrID_Err_LoadSuite));
//		out_data->out_flags |= PF_OutFlag_DISPLAY_ERROR_MESSAGE;
//		err = PF_Err_INTERNAL_STRUCT_DAMAGED;
//	}
	return err;
}

static PF_Err SequenceSetdown( PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ){

	if (in_data->sequence_data) {
		PF_DISPOSE_HANDLE(in_data->sequence_data);
		in_data->sequence_data = out_data->sequence_data = NULL;
	}
	return PF_Err_NONE;
}

static PF_Err SequenceResetup( register PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output ){

	if (in_data->sequence_data) {
		PF_DISPOSE_HANDLE(in_data->sequence_data);
	}
	return SequenceSetup(in_data, out_data, params, output);
}

// An effect cannot access pixels it has not checked out during PF_Cmd_SMART_PRE_RENDER
// If an effect might need pixels (or other parameter values), they must be checked out now, even if they are not actually used during rendering.
// Note that no parameter array is passed to SmartFX during PF_Cmd_SMART_PRE_RENDER or PF_Cmd_SMART_RENDER; all values must be checked out using checkout_layer. 
// All non-layer parameters must be accessed through PF_CHECKOUT_PARAM
static PF_Err PreRender( PF_InData *in_data, PF_OutData *out_data, PF_PreRenderExtra *extra ) {

	PF_Err err = PF_Err_NONE;
		
	// what does after effects want rendered?
	PF_RenderRequest req = extra->input->output_request;

	// check out the input:pixels. (index 0). Indexes 1 to ..n are out parameters. 
	PF_CheckoutResult in_result;
	NSUInteger uid = 0;
	ERR( extra->cb->checkout_layer( in_data->effect_ref, 0, uid, &req, in_data->current_time, in_data->time_step, in_data->time_scale, &in_result ));

	// YOU MUST SET THESE CORRECTLY
	extra->output->result_rect = in_result.result_rect;
	extra->output->max_result_rect = in_result.max_result_rect; // ie MAX EVER! ie must be the same regardless of which bit AE has requested, can depend on params etc, but ie can ask for a zero request_rect -- ie it is trying to find out maxRsultRect and the fact that request_rect is empty must not change max_result_rect
	
	// Every layer input has a max_result_rect
	
	// Note that the ref_width/height and max_result_rect for an input may be obtained without rendering, by calling checkout_layer with an empty request_rect. This is fairly efficient, and can be useful if the layer “size” is needed first to determine exactly which pixels are required for rendering. This is an example of requesting a layer in pre-render and then never calling checkout_layer (in this case, there are none).
	
	return	err;
}

static PF_Err _actuallyRender( PF_InData *in_data, PF_EffectWorld *input, PF_ParamDef *blend_paramP, PF_ParamDef *channel_paramP, PF_OutData *out_data, PF_EffectWorld *output ) {
	
	PF_Err err = PF_Err_NONE, err2 = PF_Err_NONE;

//	SmartyPantsData *id;
//	SmartyPantsDataPlus	idp;
//	PF_Point origin;
//	PF_Rect src_rect, areaR;
//	
//	AEGP_SuiteHandler suites(in_data->pica_basicP);
//	
//	src_rect.left = -in_data->output_origin_x;
//	src_rect.top = -in_data->output_origin_y;
//	src_rect.bottom = src_rect.top + output->height;
//	src_rect.right = src_rect.left + output->width;
//	
	PF_WorldSuite2 *wsP	= NULL;
	ERR( AEFX_AcquireSuite( in_data, out_data, kPFWorldSuite, kPFWorldSuiteVersion2, "Couldn't load suite.", (void**)&wsP) );
	
	
//	if (!in_data->sequence_data) {
//		PF_COPY(input, output, &src_rect, NULL);
//		err = PF_Err_INTERNAL_STRUCT_DAMAGED;
//	}
//	
//	if (!err){
//		id = (SmartyPantsData*)*(in_data->sequence_data);
//		
//		id->blend = (A_short)(2.56 * blend_paramP->u.fs_d.value);
//		
//		idp.id 			= id;
//		idp.in_data 	= in_data;
//		idp.RGBtoYIQcb 	= ((PF_UtilCallbacks*)(in_data->utils))->colorCB.RGBtoYIQ;
//		idp.RGBtoHLScb 	= ((PF_UtilCallbacks*)(in_data->utils))->colorCB.RGBtoHLS;
//		idp.HLStoRGBcb 	= ((PF_UtilCallbacks*)(in_data->utils))->colorCB.HLStoRGB;
//		idp.YIQtoRGBcb 	= ((PF_UtilCallbacks*)(in_data->utils))->colorCB.YIQtoRGB;
//		idp.outputP 	= output;
//		
//		if (id->blend == 256) {
//			err = PF_COPY(input, output, &src_rect, NULL);
//		} else {
//			if (id->channel != channel_paramP->u.pd.value) {
//				id->channel = channel_paramP->u.pd.value;
//			}
//			
//			origin.h = in_data->output_origin_x;
//			origin.v = in_data->output_origin_y;
//			
//			areaR.top		= 
//			areaR.left 		= 0;
//			areaR.right		= 1;
//			areaR.bottom	= output->height;
//			
//dodo			PF_PixelFormat format =	PF_PixelFormat_INVALID;
//dodo			ERR( wsP->PF_GetPixelFormat(input, &format) );			
//dodo			switch(format) {
//					
//				case PF_PixelFormat_ARGB128:
//					
//					ERR(suites.IterateFloatSuite1()->iterate_origin(in_data,
//																	0,
//																	output->height,
//																	input,
//																	&areaR,
//																	&origin,
//																	(A_long)(&idp),
//																	InvertPixelFloat,
//																	output));
//					break;
//					
//				case PF_PixelFormat_ARGB64:
//					
//					ERR(suites.Iterate16Suite1()->iterate_origin(	in_data,
//																 0,
//																 output->height,
//																 input,
//																 &areaR,
//																 &origin,
//																 (A_long)(&idp),
//																 InvertPixel16,
//																 output));
//					break;
//					
//				case PF_PixelFormat_ARGB32:
//					
//					
//					ERR(suites.Iterate8Suite1()->iterate_origin(	in_data,
//																0,
//																output->height,
//																input,
//																&areaR,
//																&origin,
//																(A_long)(&idp),
//																InvertPixel8,
//																output));
//					break;
//					
//				default:
//					err = PF_Err_BAD_CALLBACK_PARAM;
//					break;
//			}
//		}
//dodo	}
//dodo	ERR2( AEFX_ReleaseSuite( in_data, out_data, kPFWorldSuite, kPFWorldSuiteVersion2, "Couldn't release suite.") );
	return err;
}

static PF_Err SmartRender( PF_InData *in_data, PF_OutData *out_data, PF_SmartRenderExtra *extra) {
	
	PF_Err err = PF_Err_NONE, err2 = PF_Err_NONE;

	// checkout input & output buffers.
	PF_EffectWorld *input_worldP = NULL, *output_worldP = NULL;
	NSUInteger uid = 0;
//	ERR( (extra->cb->checkout_layer_pixels(	in_data->effect_ref, uid, &input_worldP)) );
//	ERR( extra->cb->checkout_output( in_data->effect_ref, &output_worldP) );
	
	ERR( _actuallyRender( in_data, input_worldP, NULL, NULL, out_data, output_worldP));
	
	return	err;
}

DllExport PF_Err EntryPointFunc( PF_Cmd cmd, PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output, void *extra ) {

	PF_Err err = PF_Err_NONE;
	
//	try {
		switch (cmd) {
			case PF_Cmd_ABOUT:
				err = About( in_data, out_data, params, output );
				break;
			case PF_Cmd_GLOBAL_SETUP:
				err = GlobalSetup( in_data, out_data, params, output );
				break;
			case PF_Cmd_PARAMS_SETUP:
				err = ParamsSetup( in_data, out_data, params, output );
				break;
			case PF_Cmd_FRAME_SETUP:
				err = FrameSetup( in_data, out_data, params, output );
				break;
			case PF_Cmd_FRAME_SETDOWN:
				break;
			case PF_Cmd_RENDER:
				err = Render( in_data, out_data, params, output );
				break;
			case PF_Cmd_GET_EXTERNAL_DEPENDENCIES:
				err = DescribeDependencies( in_data, out_data, params, extra );
				break;
			case PF_Cmd_QUERY_DYNAMIC_FLAGS:
				err = QueryDynamicFlags( in_data, out_data, params, extra );
				break;
				
			case PF_Cmd_SEQUENCE_SETUP:
				err = SequenceSetup(in_data,out_data,params,output);
				break;
			case PF_Cmd_SEQUENCE_RESETUP:
				err = SequenceResetup(in_data,out_data,params,output);
				break;
			case PF_Cmd_SEQUENCE_SETDOWN:
				err = SequenceSetdown(in_data,out_data,params,output);
				break;
	
			case PF_Cmd_SMART_PRE_RENDER:
				err = PreRender(in_data, out_data, (PF_PreRenderExtra *)extra);
				break;
			case PF_Cmd_SMART_RENDER:
				err = SmartRender(in_data, out_data, (PF_SmartRenderExtra *)extra);
				break;
				
			case PF_Cmd_AUDIO_RENDER:
				err = Audio_Render(in_data, out_data, params, output);
				break;
				
			// allocate memory
			case PF_Cmd_AUDIO_SETUP:
				err = Audio_Setup(in_data, out_data, params, output);
				break;
				
			// free memory
			case PF_Cmd_AUDIO_SETDOWN:

				break;
				
				
				
			default:
				printf("fuck\n"); //21
		}
//	}
//	catch(PF_Err &thrown_err){
//		err = thrown_err;
//	}
	return err;
}


//PF_Err err=PF_Err_NONE, err2=PF_Err_NONE;

//	PF_ChannelSuite1 *csP = NULL;
//	ERR( AEFX_AcquireSuite( in_data, out_data, kPFChannelSuite1, kPFChannelSuiteVersion1, "Couldn't load suite.", (void**)&csP));
//	ERR(csP->PF_GetLayerChannelCount( in_data->effect_ref, 0, &num_channelsL));

//PF_ANSICallbacksSuite1 *csP = NULL;
//ERR( AEFX_AcquireSuite( in_data, out_data, kPFANSISuite, kPFANSISuiteVersion1, "Couldn't load suite.", (void**)&csP ));
//ERR2( AEFX_ReleaseSuite( in_data, out_data, kPFANSISuite, kPFANSISuiteVersion1, "Couldn't release suite."));

