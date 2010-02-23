//
//  BBStringRendererUI.h
//  BBExtras
//
//  Created by Jonathan del Strother on 29/08/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import "QCClasses.h"


@interface BBStringRendererUI : QCInspector {
	NSButton* colorButton;
	NSButton* htmlButton;
}
-(void)setColorEnabled:(id)sender;
-(void)setHTMLEnabled:(id)sender;
@end
