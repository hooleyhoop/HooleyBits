/*
 Copyright (c) 2009 Alex Wiltschko
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */
//
//  OouraFFT.m
//  oScope
//

#import "OouraFFT.h"
#define MAX_INT 32767

// Two arrays that the FFT algorithm requires.
// You won't interact with these outside of this class,
// or even outside of a call to the FFT algorithm.
int *ip; // This is scratch space. 
float *w; // cos/sin table. 

// dataIsFrequency should be private to this class.
@interface OouraFFT () 
@property BOOL dataIsFrequency;
@property int oldestDataIndex;
@end


@implementation OouraFFT

@synthesize inputData;
@synthesize dataLength;
@synthesize numFrequencies;
@synthesize dataIsFrequency;

@synthesize spectrumData;
@synthesize allWindowedFFTs;

@synthesize window;
@synthesize windowType;
//putback@synthesize numWindows;
@synthesize oldestDataIndex;

# pragma mark - Visible Objective-C Methods

- (id)initForSignalsOfLength:(int)numPoints andNumWindows:(int)numberOfWindows {

	if ((self = [super init])) {
		
		[self checkDataLength:numPoints];
		self.dataLength = numPoints;
		self.numFrequencies = numPoints/2;
//putback		self.numWindows = numberOfWindows;
		
		// Initialize helper arrays the FFT algorithm requires.
		ip = (int *)malloc((2 + sqrt(numFrequencies)) * sizeof(int));
		w  = (float *)malloc((numFrequencies - 1) * sizeof(float));
		ip[0] = 0; // Need to set this before the first time we run the FFT
		
		// Initialize the raw input and output data arrays
		// In use, when calculating periodograms, outputData will not generally
		// be used. Look to realFrequencyData for that.
		self.inputData = (float *)malloc(self.dataLength*sizeof(float));
		
		// Initialize the data we'd actually display
		self.spectrumData = (float *)malloc(self.numFrequencies*sizeof(float));
		
		// Initialize the array of arrays holding all of the past computed frequency data.
//		self.allWindowedFFTs = (float **)malloc(numberOfWindows*sizeof(float *));
//		for (int i=0; i < numberOfWindows; ++i) {
//			self.allWindowedFFTs[i] = (float *)malloc(numFrequencies*sizeof(float));
//		}
//		
		// Allocate the windowing function
		self.window = (float *)malloc(self.dataLength*sizeof(float));
		
		// And then set the window type with our custom setter.
		self.windowType = kWindow_Hamming;
		
		// Start the oldestDataIndex at 0. 
		// This'll track which data needs to be cycled out and forgotten.
		self.oldestDataIndex = 0; 
	}
	
	return self;
}


- (void)calculateWelchPeriodogramWithNewSignalSegment {	
	
//	for (int i=0; i<self.numFrequencies; ++i) {
//		NSLog(@"%f", self.inputData[i*2]);
//	}
	
	// Apply a window to the signal segment
//	[self windowSignalSegment];
	
	// Do the FFT
	rdft( self.dataLength, 1, self.inputData, ip, w );
	
	// Get the real modulus of the FFT, and scale it
//	for (int i=0; i<self.numFrequencies; ++i) {		
//		self.inputData[i*2] = 20. * log10(2.f *sqrtf(self.inputData[i*2]*self.inputData[i*2] + self.inputData[i*2+1]*self.inputData[i*2+1])/1024.0f);
//putback		self.inputData[i*2] /= self.numWindows;
//	}
	
	// Remove the oldest FFT segment from the moving average,
	// Add in the newest FFT segment
	// and then replace the old segment with the new
	for (int i=0; i<self.numFrequencies; ++i) {
//putback		self.spectrumData[i] -= self.allWindowedFFTs[self.oldestDataIndex][i];
//putback			self.spectrumData[i] += self.inputData[i*2];
//putback		self.allWindowedFFTs[self.oldestDataIndex][i] = self.inputData[i*2];

self.spectrumData[i] = self.inputData[i];
	}
	
//putback	self.oldestDataIndex += 1; 
//putback	if (self.oldestDataIndex >= self.numWindows) { 
//putback		self.oldestDataIndex = 0; };
	
}

- (void)windowSignalSegment {
	for (int i=0; i<self.dataLength; ++i) {
		float debugVal = self.inputData[i] * self.window[i];
		self.inputData[i] = debugVal;
	}
}

- (void)setWindowType:(int)inWindowType {
	windowType = inWindowType;
	float N = self.dataLength;
	float windowval, tmp;
	float pi = 3.14159265359;
	
	NSLog(@"Set up all values, about to init window type %d", inWindowType);
	
	// Source: http://en.wikipedia.org/wiki/Window_function
	
	for (int i=0; i < self.dataLength; ++i) {
		switch (self.windowType) {
			case kWindow_Rectangular:
				windowval = 1.0;
				break;
			case kWindow_Hamming:
				windowval = 0.54 - 0.46*cos((2*pi*i)/(N - 1));
				break;
			case kWindow_Hann:
				windowval = 0.5*(1 - cos((2*pi*i)/(N - 1)));
				break;
			case kWindow_Bartlett:
				windowval  = (N-1)/2;
				tmp = i - ((N-1)/2);
				if (tmp < 0.0) {tmp = -tmp;} 
				windowval -= tmp;
				windowval *= (2/(N-1));
				break;
			case kWindow_Triangular:
				tmp = i - ((N-1.0)/2.0);
				if (tmp < 0.0) {tmp = -tmp;} 
				windowval = (2/N)*((N/2) - tmp);
				break;
		}
		self.window[i] = windowval;
	}	
	
}

- (int)getWindowType {
	return self.windowType;
}

- (BOOL)checkDataLength:(int)inDataLength {
	// Check that inDataLength is a power of two.
	// Thanks StackOverflow! (Q 600293, answered by Greg Hewgill)
	BOOL isPowerOfTwo = (inDataLength & (inDataLength - 1)) == 0;	
	// and that it's not too long. INT OVERFLOW BAD.
	BOOL isWithinIntRange = inDataLength < MAX_INT;
	
	NSAssert(isPowerOfTwo, @"The length of provided data must be a power of two");
	// 	NSAssert(inDataLength <= MAX_INT, @"At this juncture, can't do an FFT on a signal longer than the maximum value for int = 32767");
	
	NSLog(@"Everything checks out for %d samples of data", inDataLength);
	return isPowerOfTwo & isWithinIntRange;
}




- (void)doFFT {
	rdft(self.dataLength, 1, self.inputData, ip, w);
}

- (void)doIFFT {
	rdft(self.dataLength, -1, self.inputData, ip, w);
	self.dataIsFrequency = NO;
}


#pragma mark - The End
- (void)dealloc {
	//i am not sure if all of these steps are neccessary. or if you just call DisposeAUGraph
	// TODO: stop audio unit and deallocate it in the dealloc method...
    [super dealloc];
}


@end