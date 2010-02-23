/*
 *  Osax.h
 *
 *  Created by François Delyon on Wed Sep 24 2003.
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 */
#ifndef __OSAX__
#define __OSAX__
#include <Carbon/Carbon.h>

struct EventDescription{
    AEEventClass theAEEventClass;
    AEEventID theAEEventID;
    long refCon;
};
extern CFBundleRef additionBundle;
extern EventDescription gEventDescriptionList[];
extern int gEventDescriptionCount;
pascal OSErr OsaxEventHandler(const AppleEvent* message, AppleEvent* reply, long refCon);

#endif

/* Osax.h proposes a basic implementation of a Scripting Addition (osax).
 *
 * Your project must define three quantities:
 * - an array of EventDescription named "gEventDescriptionList", such as:
 *	EventDescription gEventDescriptionList[]={{'SAMP','PROD',0},{'SAMP','SUM ',1}};
 * - an integer named "gEventDescriptionCount" that stores the size of "gEventDescriptionList":
 *	int gEventDescriptionCount=sizeof(gEventDescriptionList)/sizeof(EventDescription);
 * - your AppleEvent handler named "OsaxEventHandler", that you muse declare as:
 *	pascal OSErr OsaxEventHandler(const AppleEvent* message, AppleEvent* reply, long refCon){}
 *
 * Each EventDescription in gEventDescriptionList should contain:
 *	- the class and id of the AppleEvent, that you should declare in your terminology resource
 *	not two AppleEvents should have the same class and id in order to avoid conflicts
 *	- an integer refCon that will be passed to OsaxEventHandler upon call of the corresponding event,
 *	and will allow your OsaxEventHandler to handle more than one AppleEvent.
 */