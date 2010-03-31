//
//  Logger.h
//  BBExtras
//
//  Created by Jonathan del Strother on 07/03/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>

void BBLog(NSString* message,...);

@interface Logger : NSObject <GrowlApplicationBridgeDelegate> {

}

+ (id)sharedLogger;
-(void)logXMLError:(NSString*)error;
-(void)log:(NSString*)message arguments:(va_list)args;
@end
