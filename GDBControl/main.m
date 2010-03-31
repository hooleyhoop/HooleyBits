//
//  main.m
//  GDBControl
//
//  Created by Steven Hooley on 06/12/2007.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
// #include <stdio.h>
#include "expect.h"

void timedout()
{
	fprintf(stderr,"timed out\n");
	exit(-1);
}


int main(int argc, char *argv[])
{
	int	fd;
	FILE *fp	;

	exp_loguser = 0;
	exp_timeout = 3600;

	if (NULL == (fd = exp_spawnl("ftp","ftp","-V","your.ftp.server",NULL))) {
		perror("ftp");
		exit(-1);
	}
	if (NULL == (fp = fdopen(fd,"r+")))
		return(0);
	setbuf(fp,(char *)0);

	if (EXP_TIMEOUT == exp_fexpectl(fp, exp_regexp,"Name.*:",0, exp_end)) {
		timedout();
	}

	fprintf(fp,"your_login\r\n");

	if (EXP_TIMEOUT == exp_fexpectl(fp, exp_glob,"Password:",0, exp_end)) {
		timedout();
	}

	fprintf(fp,"your_password\n");
	fprintf(fp,"%c",0x03);	// disconnect

    return NSApplicationMain(argc,  (const char **) argv);
}
