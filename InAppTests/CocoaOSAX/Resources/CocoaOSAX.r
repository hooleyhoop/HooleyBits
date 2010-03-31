#include <Carbon/Carbon.r>

#define Reserved8   reserved, reserved, reserved, reserved, reserved, reserved, reserved, reserved
#define Reserved12  Reserved8, reserved, reserved, reserved, reserved
#define Reserved13  Reserved12, reserved
#define dp_none__   noParams, "", directParamOptional, singleItem, notEnumerated, Reserved13
#define reply_none__   noReply, "", replyOptional, singleItem, notEnumerated, Reserved13
#define synonym_verb__ reply_none__, dp_none__, { }
#define plural__    "", {"", kAESpecialClassProperties, cType, "", reserved, singleItem, notEnumerated, readOnly, Reserved8, noApostrophe, notFeminine, notMasculine, plural}, {}

resource 'aete' (0, "Dictionary") {
	0x1,  // major version
	0x0,  // minor version
	english,
	roman,
	{
		"CocoaOSAX",
		"What?",
		'IaPt',
		1,
		1,
		{
			/* Events */

			"monkeeeeeeey",
			"",
			'EeEe', 'eeEE',
			reply_none__,
			dp_none__,
			{

			},

			"mouseClickAt",
			"",
			'EeEe', 'eeEG',
			reply_none__,
			'long',
			"",
			directParamRequired,
			listOfItems, notEnumerated, Reserved13,
			{
				"using", 'x$$3', 'HMdK',
				"",
				required,
				singleItem, enumerated, Reserved13
			},

			"mouseDoubleClickAt",
			"",
			'EeEe', 'eeEF',
			reply_none__,
			'long',
			"",
			directParamRequired,
			listOfItems, notEnumerated, Reserved13,
			{

			},

			"mouseDownAt",
			"",
			'EeEe', 'eeEH',
			reply_none__,
			'long',
			"",
			directParamRequired,
			listOfItems, notEnumerated, Reserved13,
			{
				"upAt", 'x$$$', 'long',
				"",
				required,
				listOfItems, notEnumerated, Reserved13
			}
		},
		{
			/* Classes */

		},
		{
			/* Comparisons */
		},
		{
			/* Enumerations */
			'HMdK',
			{
				"ModKey_SHIFT", 'LHrn', "",
				"ModKey_COMMAND", 'RHrn', ""
			}
		}
	}
};
