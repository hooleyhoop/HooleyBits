#import "AEConfig.h"
#import "AE_EffectVers.h"

#ifndef AE_OS_WIN
	#import <AE_General.r>
#endif
	
resource 'PiPL' (16000) {
	{	/* array properties: 12 elements */
		/* [1] */
		Kind {
			AEEffect
		},
		/* [2] */
		Name {
			"AudioFFTRender"
		},
		/* [3] */
		Category {
			"Sample Plug-ins"
		},
#ifdef AE_OS_WIN
		CodeWin32X86 {"EntryPointFunc"},
#else
	#ifdef AE_OS_MAC
		CodeMachOPowerPC {"EntryPointFunc"},
		CodeMacIntel32 {"EntryPointFunc"},
	#endif
#endif
		/* [6] */
		AE_PiPL_Version {
			2,
			0
		},
		/* [7] */
		AE_Effect_Spec_Version {
			PF_PLUG_IN_VERSION,
			PF_PLUG_IN_SUBVERS
		},
		/* [8] */
		AE_Effect_Version {
			524289	/* 1.0 */
		},
		/* [9] */
		AE_Effect_Info_Flags {
			0
		},
		/* [10] */
		AE_Effect_Global_OutFlags {
			0x40100000
		},
//		AE_Effect_Global_OutFlags_2 {
//			0x1000
//		},
		/* [11] */
		AE_Effect_Match_Name {
			"ADBE AudioFFTRender"
		},
		/* [12] */
		AE_Reserved_Info {
			0
		}
	}
};

