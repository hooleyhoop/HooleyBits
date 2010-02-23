#include <Carbon/Carbon.r>

#define Reserved8   reserved, reserved, reserved, reserved, reserved, reserved, reserved, reserved
#define Reserved12  Reserved8, reserved, reserved, reserved, reserved
#define Reserved13  Reserved12, reserved
#define dp_none__   noParams, "", directParamOptional, singleItem, notEnumerated, Reserved13
#define reply_none__   noReply, "", replyOptional, singleItem, notEnumerated, Reserved13
#define synonym_verb__ reply_none__, dp_none__, { }
#define plural__    "", {"", kAESpecialClassProperties, cType, "", reserved, singleItem, notEnumerated, readOnly, Reserved8, noApostrophe, notFeminine, notMasculine, plural}, {}

resource 'aete' (0, "") {
	0x1,  // major version
	0x0,  // minor version
	english,
	roman,
	{
		"Type Names Suite",
		"Hidden terms",
		kASTypeNamesSuite,
		1,
		1,
		{
			/* Events */

		},
		{
			/* Classes */

			"array of real", 'Lido',
			"",
			{
			},
			{
			},
			"arrays of real", 'Lido', plural__,

			"matrix", 'Matr',
			"",
			{
			},
			{
			},
			"matrices", 'Matr', plural__
		},
		{
			/* Comparisons */
		},
		{
			/* Enumerations */
		},

		"Sample Additions",
		"This is a sample by Satimage to be used within Smile. Check www.satimage-software.com for additionnal informations.",
		'SAMP',
		1,
		1,
		{
			/* Events */

			"mandelbrot",
			"compute a fractal set associated to the iterations of the analytic function  f(z)=z*z+c",
			'SAMP', 'MAND',
			'Matr',
			"a matrix containing for each value of c the number of iterations necessary to reach abs(f(z))>2",
			replyRequired, singleItem, notEnumerated, Reserved13,
			'long',
			"maximum number of iterations. Default: 2556.",
			directParamOptional,
			singleItem, notEnumerated, Reserved13,
			{
				"xdata", 'x$$$', 'Lido',
				"real part of c",
				required,
				singleItem, notEnumerated, Reserved13,
				"ydata", 'y$$$', 'Lido',
				"imaginary part of c",
				required,
				singleItem, notEnumerated, Reserved13
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
		}
	}
};
