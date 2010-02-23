//
//  NSSayWhateverCommand.m
//  InAppTests
//
//  Created by steve hooley on 21/01/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "NSSayWhateverCommand.h"


@implementation NSSayWhateverCommand
- (id)sayFuck {
	NSLog(@"w");
}

- (id)sayFuck:(id)fuck {
	NSLog(@"w");
}
- (id)subjectsSpecifier
{
    id objects = nil;
    NSAppleEventDescriptor *subjDesc = [[self appleEvent] attributeDescriptorForKeyword: 'subj'];
    if (subjDesc)
    {
        NSScriptObjectSpecifier *subjSpec = [NSScriptObjectSpecifier _objectSpecifierFromDescriptor: subjDesc
																	   inCommandConstructionContext: nil];
        objects = [subjSpec objectsByEvaluatingSpecifier];
    }
    return objects;
}

- (id)evaluatedDirectParameters {
	
    id param = [self directParameter];
//    if ([param isKindOfClass: [NSScriptObjectSpecifier class]])
//    {
//        NSScriptObjectSpecifier *spec = (NSScriptObjectSpecifier *)param;
//        id container = [[spec containerSpecifier] objectsByEvaluatingSpecifier];
//        param = [spec objectsByEvaluatingWithContainers: container];
//    }
    return param;
}

- (id)performDefaultImplementation {
	
	SInt32	theError = noErr;
	id directParameter = [self directParameter];
	NSLog(@"You whay wahateveve %@", directParameter);
	
	NSMutableArray *returnValue = [NSMutableArray array];
	
	if( [directParameter isKindOfClass:[NSArray class]] != NO )
	{
		NSLog(@"ohh matron");
		//		NSEnumerator*	objectEnumerator = [directParameter objectEnumerator];
		//		id anObject = nil;
		//
		//		while ( ( anObject = [objectEnumerator nextObject] ) != nil )
		//		{
		//			if ( [anObject isKindOfClass:[NSScriptObjectSpecifier class]] != NO )
		//			{
		//				id	resolvedObject = [anObject objectsByEvaluatingSpecifier];
		//
		//				myLog2(@"ME SKTAlignCommand performDefaultImplementation resolvedObject = %@",resolvedObject);
		//
		//				if ( [resolvedObject isKindOfClass:[NSArray class]] != NO )
		//				{
		//					[returnValue addObjectsFromArray:resolvedObject];
		//				}
		//				else
		//				{
		//					[returnValue addObject:resolvedObject];
		//				}
		//			}
		//		}
	}
	
	NSDictionary *theArgs = [self evaluatedArguments];
	//	NSNumber*		theEdgeObject = [theArgs objectForKey:@"toEdge"];
	//	
	//	if ( [theEdgeObject isKindOfClass:[NSNumber class]] != NO )
	//	{
	//		long	theEdgeValue = [theEdgeObject longValue];
	//		
	//		unsigned	j, m;
	//		NSRect		firstBounds = [[returnValue objectAtIndex:0] bounds];
	//		
	//		switch ( theEdgeValue )
	//		{
	//			case	kSKTAlignCommandEdgeTop:
	//				
	//				for ( j = 0, m = [returnValue count]; m > 0; j++, m-- )
	//				{
	//					SKTGraphic*	curGraphic = [returnValue objectAtIndex:j];
	//					NSRect		curBounds = [curGraphic bounds];
	//					
	//					if ( curBounds.origin.y != firstBounds.origin.y )
	//					{
	//						curBounds.origin.y = firstBounds.origin.y;
	//						[curGraphic setBounds:curBounds];
	//					}
	//				}
	//				break;
	//				
	//			case	kSKTAlignCommandEdgeBottom:
	//				
	//				for ( j = 0, m = [returnValue count]; m > 0; j++, m-- )
	//				{
	//					SKTGraphic*	curGraphic = [returnValue objectAtIndex:j];
	//					NSRect		curBounds = [curGraphic bounds];
	//					
	//					if ( NSMaxY( curBounds ) != NSMaxY( firstBounds ) )
	//					{
	//						curBounds.origin.y = NSMaxY( firstBounds ) - curBounds.size.height;
	//						[curGraphic setBounds:curBounds];
	//					}
	//				}
	//				break;
	//				
	//			case	kSKTAlignCommandEdgeVertical:
	//				
	//				for ( j = 0, m = [returnValue count]; m > 0; j++, m-- )
	//				{
	//					SKTGraphic*	curGraphic = [returnValue objectAtIndex:j];
	//					NSRect		curBounds = [curGraphic bounds];
	//					
	//					if ( NSMidY( curBounds ) != NSMidY( firstBounds ) )
	//					{
	//						curBounds.origin.y = NSMidY( firstBounds ) - ( curBounds.size.height / 2.0 );
	//						[curGraphic setBounds:curBounds];
	//					}
	//				}
	//				break;
	//				
	//			case	kSKTAlignCommandEdgeLeft:
	//				
	//				for ( j = 0, m = [returnValue count]; m > 0; j++, m-- )
	//				{
	//					SKTGraphic*	curGraphic = [returnValue objectAtIndex:j];
	//					NSRect		curBounds = [curGraphic bounds];
	//					
	//					if ( curBounds.origin.x != firstBounds.origin.x )
	//					{
	//						curBounds.origin.x = firstBounds.origin.x;
	//						[curGraphic setBounds:curBounds];
	//					}
	//				}
	//				break;
	//				
	//			case	kSKTAlignCommandEdgeRight:
	//				
	//				for ( j = 0, m = [returnValue count]; m > 0; j++, m-- )
	//				{
	//					SKTGraphic*	curGraphic = [returnValue objectAtIndex:j];
	//					NSRect		curBounds = [curGraphic bounds];
	//					
	//					if ( NSMaxX( curBounds ) != NSMaxX( firstBounds ) )
	//					{
	//						curBounds.origin.x = NSMaxX( firstBounds ) - curBounds.size.width;
	//						[curGraphic setBounds:curBounds];
	//					}
	//				}
	//				break;
	//				
	//			case	kSKTAlignCommandEdgeHorizontal:
	//				
	//				for ( j = 0, m = [returnValue count]; m > 0; j++, m-- )
	//				{
	//					SKTGraphic*	curGraphic = [returnValue objectAtIndex:j];
	//					NSRect		curBounds = [curGraphic bounds];
	//					
	//					if ( NSMidX( curBounds ) != NSMidX( firstBounds ) )
	//					{
	//						curBounds.origin.x = NSMidX( firstBounds ) - ( curBounds.size.width / 2.0 );
	//						[curGraphic setBounds:curBounds];
	//					}
	//				}
	//				break;
	//				
	//			default:
	//				theError = errAECoercionFail;
	//				break;
	//		}
	//	}
	//	
	//	if ( theError != noErr )
	//	{
	//		//ME	report the error, if any
	//		[self setScriptErrorNumber:theError];
	//	}
	return	returnValue;
}

@end
