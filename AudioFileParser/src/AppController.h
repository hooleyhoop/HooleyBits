//
//  AppController.h
//  AudioFileParser
//
//  Created by steve hooley on 22/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Quartz/Quartz.h>

@class SpectrumResults;

@interface AppController : NSObject {

	NSString					*_in_AudioFilePath, *_out_graphicsDirPath;
	
	IBOutlet IKImageView		*_imageView;
	NSNumber					*_frameLabel;
	
	SpectrumResults				*_spectroResults;
}


@property (retain) NSString *in_AudioFilePath;
@property (retain) NSString *out_graphicsDirPath;
@property (retain) NSNumber *frameLabel;

- (NSString *)in_AudioFilePath;
- (void)setIn_AudioFilePath:(NSString *)value;

- (IBAction)openPath:(id)sender;
- (IBAction)savePath:(id)sender;
- (IBAction)stepperClicked:(id)sender;
- (IBAction)doit:(id)sender;

@end
