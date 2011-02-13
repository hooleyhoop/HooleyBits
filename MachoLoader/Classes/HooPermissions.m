//
//  HooPermissions.m
//  MachoLoader
//
//  Created by Steven Hooley on 10/02/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

#import "HooPermissions.h"


@implementation HooPermissions

+ (int)acquireTaskportRight {

    OSStatus status;
    AuthorizationItem taskport_item[] = {{"system.privilege.taskport"}};
    AuthorizationRights rights = {1, taskport_item}, *out_rights = NULL;
    AuthorizationRef author;
    AuthorizationFlags authorizationFlags = kAuthorizationFlagExtendRights
    
    | kAuthorizationFlagPreAuthorize
    | kAuthorizationFlagInteractionAllowed
    | (1 << 5);
    
    status = AuthorizationCreate(NULL,
                                 kAuthorizationEmptyEnvironment,
                                 authorizationFlags,
                                 &author);
    if (status != errAuthorizationSuccess) {
        return 0;
    }
    
    status = AuthorizationCopyRights(author,
                                     &rights,
                                     kAuthorizationEmptyEnvironment,
                                     authorizationFlags,
                                     &out_rights);
    if (status != errAuthorizationSuccess) {
        return 1;
    }
    
    return 0;
}

@end
