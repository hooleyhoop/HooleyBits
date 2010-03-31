//
//  MIDIUtil.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 3/25/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "MIDIUtil.h"
//#import "Song.h"
//#import "Staff.h"
//#import "TimeSignature.h"
//#import "TempoData.h"
//#import "KeySignature.h"
//#import "NoteBase.h"
//#import "Note.h"
//#import "Rest.h"
//#import "Measure.h"
//#import "Chord.h"
#import "SimpleNote.h"
#import "SimpleSong.h"

static const int RESOLUTION = 480;

@implementation MIDIUtil

//+ (void)writeBackwards:(char *)bytes length:(int)length to:(char *)dest{
//	int i;
//	for(i = 0; i < length; i++){
//		dest[i] = bytes[length - 1 - i];
//	}
//}

+ (int)readIntFrom:(NSData *)data offset:(unsigned int)offset length:(unsigned int)length {
    
	// Fixed width = EndianS32_NtoB(IntToFixed([widthNumber intValue]));
	// UInt8
	// 32
	NSRange range = NSMakeRange(offset, length);
	unsigned char *bytes = (unsigned char *)malloc(range.length);
	[data getBytes:bytes range:range];
	int rtn = 0, i = 0;
	for(i = 0; i < range.length; i++){
		rtn = rtn << 8;
		rtn += bytes[i];
	}
	free(bytes);
	return rtn;
}

+ (NSString *)readStringFrom:(NSData *)data range:(NSRange)range{
	char *bytes = (char *)malloc(range.length);
	[data getBytes:bytes range:range];
	NSString *rtn = [NSString stringWithCString:bytes length:range.length];
	free(bytes);
	return rtn;
}
//
//+ (int)writeVariableLength:(unsigned long)data to:(char *)dest{
//	if(data == 0){
//		dest[0] = 0;
//		return 1;
//	}
//	unsigned long buffer = data & 0x7F;
//	
//	while(data >>= 7){
//		buffer <<= 8;
//		buffer |= ((data & 0x7F) | 0x80);
//	}
//	int i;
//	for(i = 0; buffer & 0x80; buffer >>= 8){
//		dest[i++] = buffer & 0xFF;
//	}
//	dest[i++] = buffer & 0xFF;
//	return i;
//}

+ (int)readVariableLengthFrom:(NSData *)data into:(int *)target atOffset:(int)offset{
	char buf = 0x80;
	int size = 0, value = 0;
	while(buf & 0x80){
		[data getBytes:&buf range:NSMakeRange(offset + size, 1)];
        // printf("0x%X.", buf);
		size++;
		value = (value << 7) + (buf & 0x7F);
	}
	*target = value;
	return size;
}

//+ (NSData *)makeMTrk:(NSData *)data{
//	char header[8] = {'M', 'T', 'r', 'k', 0x00, 0x00, 0x00, 0x00};
//	unsigned length = [data length];
//	[self writeBackwards:&length length:4 to:(header + 4)];
//	NSMutableData *MTrk = [NSMutableData dataWithBytes:header length:8];
//	[MTrk appendData:data];
//	return MTrk;
//}
//
//static char lastStatus = 0x00;
//
//+ (NSData *)dataForEvent:(void *)event ofType:(MusicEventType)type atTimeDelta:(MusicTimeStamp)timeDelta{
//	char bytes[100];
//	int timestampLength = [self writeVariableLength:(long)(timeDelta * ((float)RESOLUTION)) to:bytes];
//	int size = timestampLength;
//	MIDIChannelMessage *channelMsg;
//	MIDINoteMessage *noteMsg;
//	ExtendedTempoEvent *tempoMsg;
//	MIDIMetaEvent *metaMsg;
//	MIDIRawData *rawData;
//	char meta, metaType, length;
//	int lengthLength;
//	switch(type){
//		case kMusicEventType_ExtendedNote:
//			//		kMusicEventType_ExtendedNote			ExtendedNoteOnEvent*
//			// Apple says "non-MIDI"
//			break;
//		case kMusicEventType_ExtendedControl:
//			//		kMusicEventType_ExtendedControl			ExtendedControlEvent*
//			// Apple says "non-MIDI"
//			break;
//		case kMusicEventType_ExtendedTempo:
//			tempoMsg = (ExtendedTempoEvent *)event;
//			unsigned long tempo = (unsigned long)((float)60000000 / (tempoMsg->bpm));
//			meta = 0xFF;
//			metaType = 0x51;
//			length = 0x03;
//			[self writeBackwards:&meta length:1 to:(bytes + timestampLength)];
//			[self writeBackwards:&metaType length:1 to:(bytes + timestampLength + 1)];
//			[self writeBackwards:&length length:1 to:(bytes + timestampLength + 2)];
//			[self writeBackwards:&tempo length:3 to:(bytes + timestampLength + 3)];
//			size += 6;
//			lastStatus = 0x00;
//			break;
//		case kMusicEventType_User:
//			//		kMusicEventType_User					<user-defined-data>*
//			// non-MIDI?
//			break;
//		case kMusicEventType_Meta:
//			metaMsg = (MIDIMetaEvent *)event;
//			meta = 0xFF;
//			[self writeBackwards:&meta length:1 to:(bytes + timestampLength)];
//			[self writeBackwards:&(metaMsg->metaEventType) length:1 to:(bytes + timestampLength + 1)];
//			lengthLength = [self writeVariableLength:&(metaMsg->dataLength) to:(bytes + timestampLength + 2)];
//			[self writeBackwards:&(metaMsg->data) length:(metaMsg->dataLength) to:(bytes + timestampLength + 2 + lengthLength)];
//			size += 2 + lengthLength + metaMsg->dataLength;
//			lastStatus = 0x00;
//			break;
//		case kMusicEventType_MIDINoteMessage:
//			noteMsg = (MIDINoteMessage *)event;
//			char status = 0x90 | noteMsg->channel;
//			if(status == lastStatus){
//				size -= 1;
//				timestampLength -= 1;
//			} else {
//				[self writeBackwards:&status length:1 to:(bytes + timestampLength)];
//			}
//			[self writeBackwards:&(noteMsg->note) length:1 to:(bytes + timestampLength + 1)];
//			[self writeBackwards:&(noteMsg->velocity) length:1 to:(bytes + timestampLength + 2)];
//			size += 3;
//			lastStatus = status;
//			break;
//		case kMusicEventType_MIDIChannelMessage:
//			channelMsg = (MIDIChannelMessage *)event;
//			if(status == lastStatus){
//				size -= 1;
//				timestampLength -= 1;
//			} else {
//				[self writeBackwards:&(channelMsg->status) length:1 to:(bytes + timestampLength)];
//			}
//			[self writeBackwards:&(channelMsg->data1) length:1 to:(bytes + timestampLength + 1)];
//			[self writeBackwards:&(channelMsg->data2) length:1 to:(bytes + timestampLength + 2)];
//			size += 3;
//			lastStatus = status;
//			break;
//		case kMusicEventType_MIDIRawData:
//			rawData = (MIDIRawData *)event;
//			status = 0xF0;
//			if(status == lastStatus){
//				size -= 1;
//				timestampLength -= 1;
//			} else {
//				[self writeBackwards:&status length:1 to:(bytes + timestampLength)];
//			}
//			lengthLength = [self writeVariableLength:&(rawData->length) to:(bytes + timestampLength + 1)];
//			[self writeBackwards:rawData->data length:rawData->length to:(bytes + timestampLength + 1 + lengthLength)];
//			size += 2 + lengthLength + rawData->length;
//			break;
//		case kMusicEventType_Parameter:
//			//		kMusicEventType_Parameter				ParameterEvent*
//			// non-MIDI
//			break;
//		case kMusicEventType_AUPreset:
//			//		kMusicEventType_AUPreset				AUPresetEvent*
//			// non-MIDI
//			break;
//	}
//	NSData *data = [NSData dataWithBytes:bytes length:size];
//	return data;
//}
//
//+ (NSData *)dataForNoteEndEventAtDelta:(MusicTimeStamp)timeDelta channel:(int)channel note:(int)note releaseVelocity:(int)velocity{
//	char bytes[100];
//	int timestampLength = [self writeVariableLength:(long)(timeDelta * ((float)RESOLUTION)) to:bytes];
//	int size = timestampLength;
//	char status = 0x80 | channel;
//	if(status == lastStatus){
//		size -= 1;
//		timestampLength -= 1;
//	} else {
//		[self writeBackwards:&status length:1 to:(bytes + timestampLength)];
//	}
//		[self writeBackwards:&note length:1 to:(bytes + timestampLength + 1)];
//	[self writeBackwards:&velocity length:1 to:(bytes + timestampLength + 2)];
//	size += 3;
//	lastStatus = status;
//	NSData *data = [NSData dataWithBytes:bytes length:size];
//	return data;
//}
//
//+ (NSData *)contentsOfTrack:(MusicTrack)track{
//	NSMutableData *contents = [NSMutableData data];
//	MusicEventIterator iter;
//	NewMusicEventIterator(track, &iter);
//	bool hasCurrent;
//	MusicEventIteratorHasCurrentEvent(iter, &hasCurrent);
//	MusicTimeStamp lastTimeStamp = 0;
//	NSMutableArray *queuedEvents = [NSMutableArray array];
//	while(hasCurrent){
//		MusicTimeStamp timeStamp;
//		MusicEventType eventType;
//		void *data;
//		int size;
//		MusicEventIteratorGetEventInfo(iter, &timeStamp, &eventType, &data, &size);
//		if([queuedEvents count] == 0 || [[[queuedEvents objectAtIndex:0] objectAtIndex:0] floatValue] > timeStamp){
//			[contents appendData:[self dataForEvent:data ofType:eventType atTimeDelta:(timeStamp - lastTimeStamp)]];
//			
//			//for a note start event, queue up the end event
//			if(eventType == kMusicEventType_MIDINoteMessage){
//				MIDINoteMessage *msg = (MIDINoteMessage *)data;
//				MusicTimeStamp endTimeStamp = (timeStamp + msg->duration);
//				int i;
//				for(i = 0; i < [queuedEvents count]; i++){
//					if([[[queuedEvents objectAtIndex:i] objectAtIndex:0] floatValue] >= endTimeStamp){
//						break;
//					}
//				}
//				[queuedEvents insertObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:endTimeStamp],
//					[NSNumber numberWithInt:msg->channel],
//					[NSNumber numberWithInt:msg->note],
//					[NSNumber numberWithInt:msg->releaseVelocity], nil]
//								   atIndex:i];
//			}
//			MusicEventIteratorNextEvent(iter);
//			MusicEventIteratorHasCurrentEvent(iter, &hasCurrent);
//			lastTimeStamp = timeStamp;
//		} else {
//			NSArray *queuedEvent = [queuedEvents objectAtIndex:0];
//			MusicTimeStamp timeStamp = [[queuedEvent objectAtIndex:0] floatValue];
//			[contents appendData:[self dataForNoteEndEventAtDelta:(timeStamp - lastTimeStamp) 
//														  channel:[[queuedEvent objectAtIndex:1] intValue]
//															 note:[[queuedEvent objectAtIndex:2] intValue]
//												  releaseVelocity:[[queuedEvent objectAtIndex:3] intValue]]];
//			lastTimeStamp = timeStamp;
//			[queuedEvents removeObjectAtIndex:0];
//		}
//	}
//
//	MIDIMetaEvent *endTrack = malloc(sizeof(MIDIMetaEvent));
//	endTrack->metaEventType = 0x2F;
//	endTrack->dataLength = 0;
//	[contents appendData:[self dataForEvent:endTrack ofType:kMusicEventType_Meta atTimeDelta:0]];
//	free(endTrack);
//	
//	DisposeMusicEventIterator(iter);
//	return contents;
//}
//
//+ (NSData *)tempoTrackContentsForSequence:(MusicSequence)seq{
//	MusicTrack track;
//	MusicSequenceGetTempoTrack(seq, &track);
//	return [self contentsOfTrack:track];
//}
//
//+ (NSData *)contentsOfTrack:(int)index inSequence:(MusicSequence)seq{
//	MusicTrack track;
//	MusicSequenceGetIndTrack(seq, index, &track);
//	return [self contentsOfTrack:track];
//}

//+ (NSData *)contentsForSequence:(MusicSequence)seq{
//	NSMutableData *contents = [NSMutableData dataWithData:[self makeMTrk:[self tempoTrackContentsForSequence:seq]]];
//	int tracks;
//	MusicSequenceGetTrackCount(seq, &tracks);
//	int i;
//	for(i = 0; i < tracks; i++){
//		[contents appendData:[self makeMTrk:[self contentsOfTrack:i inSequence:seq]]];
//	}
//	return contents;
//}

//+ (NSData *)writeSequenceToData:(MusicSequence)seq{
//	char header[14] = {
//		'M', 'T', 'h', 'd', 0x00, 0x00, 0x00, 0x06,
//		0x00, 0x01, 0x00, 0x00, 0x00, 0x00
//	};
//	int tracks;
//	MusicSequenceGetTrackCount(seq, &tracks);
//	tracks += 1; //tempo track
//	[self writeBackwards:&tracks length:2 to:(header + 10)];
//	[self writeBackwards:&RESOLUTION length:2 to:(header + 12)];
//	NSMutableData *data = [NSMutableData dataWithBytes:header length:14];
//	NSData *contents = [self contentsForSequence:(MusicSequence)seq];
//	[data appendData:contents];
//	return data;
//}
 



/* it seems my midi file has missed out param 2 for controller messages */

+ (void)addChanmessage:(int)status param1:(int)c1 param2:(int)c2 time:(NSUInteger)t1 toSong:(SimpleSong *)song {
	
	int eventType = status & 0xF0;		// first nibble
	int channel = status & 0x0F;		// second nibble
	
	switch(eventType)
	{
		case 0x80: // Note Off
			NSLog(@"Note Off %i", t1 );
			// pitch = c1
			// velocity = c2
			break;
		case 0x90: // Note On
			NSLog(@"Note On %i", t1 );
			SimpleNote *note = [SimpleNote noteWithPitch:c1 velocity:c2];
			[song addNote:note atTime:t1];
			break;
		case 0xA0: // Note Aftertouch (Pressure?)
			NSLog(@"Note Aftertouch");
			break;
		case 0xB0: // Controller
			NSLog(@"Controller");
			break;
		case 0xC0: // Program Change
			NSLog(@"Program Change");
			break;
		case 0xD0: // Channel Aftertouch (Pressure?)
			NSLog(@"Channel Aftertouch!");
			break;
		case 0xE0: // Pitch Bend
			NSLog(@"Pitch bend!");
			break;
		default:
			[NSException raise:@"MIDIException" format:@"Unknown Midi event - reading is screwed, there are no unknown midi events"];
	}
}


// see http://www.sonicspot.com/guide/midifiles.html
// http://253.ccarh.org/assignment/midifile/

+ (int)readTrackFrom:(NSData *)data into:(SimpleSong *)song atOffset:(int)offset withResolution:(int)resolution {

	/* This array is indexed by the high half of a status byte.  It's */
    /* value is either the number of bytes needed (1 or 2) for a channel */
    /* message, or 0 (meaning it's not  a channel message). */
    static int chantype[] = {
        0, 0, 0, 0, 0, 0, 0, 0,       /* 0x00 through 0x70 */
        2, 2, 2, 2, 1, 1, 2, 0        /* 0x80 through 0xf0 */
    };
	int sysexcontinue = 0;  /* 1 if last message was an unfinished sysex */
    int running = 0;        /* 1 when running status used */
    int status = 0;         /* (possibly running) status byte */
    int needed;
    int param1, param2;
	
	const char bytes_4[4];
	[data getBytes:&bytes_4 range:NSMakeRange(offset, 4)]; // 4d 54 72 6b - "MTrk"
    if( strncmp( (const char *)&bytes_4, (const char *)"MTrk", 4 )){
        NSLog(@"Not the start of track");
        return -1;
    }
    offset+=4;

	int trackSize = [self readIntFrom:data offset:offset length:4]; //	trackSize should be ignored as is wrong in a lot of files
	offset += 4;
	int runningTime=0;
	while( true )
	{
        int deltaTime;
//		CGFloat deltaBeats;
        /* deltaTime is relative time since previous event */

		offset += [self readVariableLengthFrom:data into:&deltaTime atOffset:offset];
		runningTime = runningTime+deltaTime;
//		deltaBeats = deltaBeats + ((float)deltaTime / (float)resolution);
  //      NSLog(@"deltaBeats is %f - time is %i", deltaBeats, deltaTime);
        
		int eventTypeAndChannel = [self readIntFrom:data offset:offset length:1];
		offset++;
        
        if ( sysexcontinue && eventTypeAndChannel != 0xf7 ) {
            NSLog(@"didn't find expected continuation of a sysex");
            return -1;
        }
        if ( (eventTypeAndChannel & 0x80) == 0 ) {	/* running status? */
            if ( status == 0 ) {
                NSLog(@"unexpected running status");
                return -1;
            }
            running = 1;
		} else {
            status = eventTypeAndChannel;
            running = 0;
        }
		
		// useful - tells you how many you need for a channel msg
        needed = chantype[ (status>>4) & 0xf ];

		if ( needed ) {        /* ie. is it a channel message? */
            if ( running ){
                param1 = eventTypeAndChannel;
			} else {
				param1 = [self readIntFrom:data offset:offset length:1];
				offset++;
            }
			if(needed>1){
				param2 = [self readIntFrom:data offset:offset length:1];
				offset++;
			} else  {
				param2=0;
			}
            [self addChanmessage:status param1:param1 param2:param2 time:runningTime toSong:song];
            continue;
        }
		
        /* There are 3 types of event… MIDI Control Events, System Exclusive Events and Meta Events */
		if(eventTypeAndChannel==0xFF)
        {
            /* meta event */
			int metaType = [self readIntFrom:data offset:(offset) length:1];
			offset++;
			int eventLength;
			offset += [self readVariableLengthFrom:data into:&eventLength atOffset:offset];
            switch(metaType){
				case 0x00: // seq number
					break;
				case 0x01: // text event
					break;
				case 0x02: // copyright
					break;
				case 0x03: // track name
 //what?                    name = [self readStringFrom:data range:NSMakeRange(offset, eventLength)];
 //what?					[staff setName:name];
					break;
				case 0x04: // instrument name
					break;
				case 0x05: // lyrics
					break;
				case 0x06: // marker
					break;
				case 0x07: // cue point
					break;
				case 0x20: // midi channel prefix
					break;
				case 0x2F: // end of track
                    return offset;
                    
				case 0x51: // tempo change
 //what?                   mpqn = [self readIntFrom:data offset:(offset) length:eventLength];
 //what?					bpm = ((float)60000000 / mpqn);
					//TODO - get the right one based on the current time
 //what?					[[[song tempoData] lastObject] setTempo:round(bpm)];
					break;
				case 0x54: // SMPTE offset
					break;
				case 0x58: // time signature
                    //TODO: end the current measure (by changing its time signature)
					//this will be weird - what does it mean to change time signatures in the middle of a measure?
					//we will need to change the current measure's time signature to make it end where it is,
					//set the next measure's time signature so it ends where it should end, then set the specified
					//time signature in the following measure.
 //what?					num = [self readIntFrom:data offset:(offset) length:1];
 //what?					denomPower = [self readIntFrom:data offset:(offset + 1) length:1];
 //what?					denom = pow(2, denomPower);
 //what?					[song setTimeSignature:[TimeSignature timeSignatureWithTop:num bottom:denom] atIndex:([staff.measures count] - 1)];
					break;
				case 0x59: // key signature
                    //TODO: end the current measure (by changing its time signature)
 //what?					sharpsOrFlats = [self readIntFrom:data offset:(offset) length:1];
 //what?					minor = [self readIntFrom:data offset:(offset + 1) length:1];
 //what?					if(sharpsOrFlats >= 0){
 //what?						[[staff.measures lastObject] setKeySignature:[KeySignature getSignatureWithSharps:sharpsOrFlats minor:(minor > 0)]];
 //what?					} else {
 //what?						[[staff.measures lastObject] setKeySignature:[KeySignature getSignatureWithFlats:-sharpsOrFlats minor:(minor > 0)]];
 //what?					}
					break;                    
                case 0x7F: // sequencer specific
                    break;
				default:
					[NSException raise:@"MIDIException" format:@"Unknown Midi event - reading is screwed, there are no unknown midi events"];
			}
 			offset += eventLength;
           
        } else if( eventTypeAndChannel==0xF0 ){  
            /* start of system exclusive */
			int eventLength;
			offset += [self readVariableLengthFrom:data into:&eventLength atOffset:offset];
            NSLog(@"whoo hoo - SYSEX event - fucked");
			offset += eventLength;
            
        } else if( eventTypeAndChannel==0xF7 ){  
			/* sysex continuation or arbitrary stuff */
			
        } else {
            NSLog(@"badByte");
		}
    }
    
	offset += 8;
	int trackEnd = offset + trackSize;
//doneproperly	NSMutableDictionary *staffs = [NSMutableDictionary dictionary];
//doneproperly	Staff *extraStaff = nil;
//doneproperly	NSMutableDictionary *openNotes = [NSMutableDictionary dictionary];
//doneproperly	NSMutableDictionary *lastEventTimes = [NSMutableDictionary dictionary];
	int type, channel;
	float deltaBeats = 0;
	while( offset<trackEnd)
    {
		NSUInteger deltaTime;
        /* deltaTime is relative time since previous event */
		offset += [self readVariableLengthFrom:data into:&deltaTime atOffset:offset]; // the end of the variable length is indicated by the msb
		deltaBeats += (float)deltaTime / (float)resolution;
 //doneproperly       NSLog(@"deltaBeats is %f - time is %i", deltaBeats, deltaTime);
		int eventTypeAndChannel = [self readIntFrom:data offset:(offset) length:1];
		offset++;
        /* There are 3 types of event… MIDI Control Events, System Exclusive Events and Meta Events */
		if(eventTypeAndChannel == 0xFF)
        {
			//meta event
			int metaType = [self readIntFrom:data offset:(offset) length:1];
			offset++;
			int eventLength;
			offset += [self readVariableLengthFrom:data into:&eventLength atOffset:offset];
			//TODO: process delta time
			NSString *name;
			int mpqn, num, denomPower, denom, sharpsOrFlats, minor;
			float bpm;
//doneproperly			Staff *staff;
//doneproperly			if([staffs count] == 0)
//doneproperly            {
//doneproperly				if(extraStaff == nil){
//doneproperly					extraStaff = [song addStaff];
//doneproperly				}
//doneproperly				staff = extraStaff;
//doneproperly			} else {
//doneproperly				staff = [[staffs allValues] objectAtIndex:0];
//doneproperly			}
//doneproperly			switch(metaType){
//doneproperly				case 0x03: //track name
//doneproperly					break;
//doneproperly				case 0x51: //tempo change
//doneproperly					break;
//doneproperly				case 0x58: //time signature
//doneproperly					break;
//doneproperly				case 0x59: //key signature
//doneproperly					break;
//doneproperly            }
			offset += eventLength;
		} else {
			//MIDI event
			int param1;
			if(eventTypeAndChannel & 0x80){
				type = eventTypeAndChannel & 0xF0;
				channel = eventTypeAndChannel & 0x0F;
				param1 = [self readIntFrom:data offset:(offset) length:1];
				offset++;
			} else {
				param1 = eventTypeAndChannel;
			}
			NSNumber *ch = [NSNumber numberWithInt:channel];
			int param2 = [self readIntFrom:data offset:(offset) length:1];
			offset++;
			if(type == 0x80 || type == 0x90) {
//doneproperly				Staff *staff;
//doneproperly				if([staffs count] == 0 && extraStaff != nil) {
//doneproperly					staff = extraStaff;
//doneproperly					[staff setChannel:(channel + 1)];
//doneproperly					[staffs setObject:staff forKey:ch];
//doneproperly				} else {
//doneproperly					staff = [staffs objectForKey:ch];
//doneproperly					if(staff == nil){
//doneproperly						staff = [song addStaff];
//doneproperly						[staff setChannel:(channel + 1)];
//doneproperly						[staffs setObject:staff forKey:ch];
//doneproperly					}
//doneproperly				}
//doneproperly				NSMutableArray *openNoteArray = [openNotes objectForKey:ch];
//doneproperly				if(openNoteArray == nil){
//doneproperly					openNoteArray = [NSMutableArray array];
//doneproperly					[openNotes setObject:openNoteArray forKey:ch];
//doneproperly				}
//doneproperly				Note *newNote;
//doneproperly				Measure *measure;
//doneproperly				KeySignature *keySig;
				int pitch, octave, acc;
				NSNumber *prevAcc;
				NSEnumerator *openNotesEnum;
				NSDictionary *accidentals;
				id openNote;
//doneproperly				NSNumber *lastEventTime = [lastEventTimes objectForKey:ch];
				float lastEvent;
//doneproperly				if(lastEventTime == nil){
//doneproperly					[lastEventTimes setObject:[NSNumber numberWithFloat:0] forKey:ch];
//doneproperly					lastEvent = 0;
//doneproperly				} else {
//doneproperly					lastEvent = [lastEventTime floatValue];
//doneproperly				}
//doneproperly				measure = [staff getLastMeasure];
//doneproperly				if(deltaBeats > 0){
//doneproperly					if([openNoteArray count] == 0){
						//add rests
//doneproperly						float restsToCreate = deltaBeats * 3 / 4;
//doneproperly						while(restsToCreate > 0){
//doneproperly							Rest *rest = [[[Rest alloc] initWithDuration:0 dotted:NO onStaff:staff] autorelease];
//doneproperly							if(![rest tryToFill:restsToCreate]){
//doneproperly								break;
//doneproperly							}
//doneproperly							restsToCreate -= [rest getEffectiveDuration];
//doneproperly							[measure addNote:rest atIndex:([[measure notes] count] - 0.5) tieToPrev:NO];
//doneproperly							measure = [staff getLastMeasure];
//doneproperly						}
//doneproperly					} else {
						//increase duration of open notes
//doneproperly						openNotesEnum = [[openNoteArray copy] objectEnumerator];
//doneproperly						while(openNote = [openNotesEnum nextObject]){
//doneproperly							[openNote tryToFill:([openNote getEffectiveDuration] + deltaBeats * 3 / 4)];
//doneproperly						}
//doneproperly					}
//doneproperly					deltaBeats = 0;
//doneproperly				}
//doneproperly				keySig = [measure getEffectiveKeySignature];
//doneproperly				switch(type) {
//doneproperly					case 0x80: //note off
//doneproperly						openNotesEnum = [[openNoteArray copy] objectEnumerator];
//doneproperly						while(openNote = [openNotesEnum nextObject]){
//doneproperly							if([openNote getEffectivePitchWithKeySignature:keySig priorAccidentals:[measure getAccidentalsAtPosition:[[measure notes] count]]] == param1){
//doneproperly								[openNoteArray removeObject:openNote];
//doneproperly							}
//doneproperly						}
//doneproperly							break;
//doneproperly					case 0x90: //note on
//doneproperly						pitch = [keySig positionForPitch:(param1 % 12) preferAccidental:0];
//doneproperly						NSLog(@"note on at time %i, pitch, %i", offset, pitch);

//doneproperly						octave = (param1 / 12);
//doneproperly						acc = [keySig accidentalForPitch:(param1 % 12) atPosition:pitch];
//doneproperly						if(acc == NO_ACC){
//doneproperly							accidentals = [measure getAccidentalsAtPosition:[[measure notes] count]];
//doneproperly							prevAcc = [accidentals objectForKey:[NSNumber numberWithInt:(octave * 7 + pitch)]];
//doneproperly							if(prevAcc != nil && [prevAcc intValue] != NO_ACC){
//doneproperly								acc = NATURAL;
//doneproperly							}						
//doneproperly						}
//doneproperly						newNote = [[[Note alloc] initWithPitch:pitch octave:octave duration:0 dotted:NO accidental:acc onStaff:staff] autorelease];
//doneproperly						if([openNoteArray count] != 0)
//doneproperly                        {
//doneproperly							Chord *newChord = [[[Chord alloc] initWithStaff:staff withNotes:[NSMutableArray arrayWithObject:newNote]] autorelease];
//doneproperly							openNotesEnum = [openNoteArray objectEnumerator];
//doneproperly							BOOL replacing = NO;
//doneproperly							while(openNote = [openNotesEnum nextObject]){
//doneproperly								if([openNote getDuration] > 0){
//doneproperly									NSArray *notes;
//doneproperly									if([openNote respondsToSelector:@selector(notes)]){
//doneproperly										notes = [openNote notes];
//doneproperly									} else {
//doneproperly										notes = [NSArray arrayWithObject:openNote];
//doneproperly									}
//doneproperly									NSEnumerator *openNoteEnum = [notes objectEnumerator];
//doneproperly									id subnote;
//doneproperly									while(subnote = [openNoteEnum nextObject]){
//doneproperly										Note *noteCopy = [subnote copy];
//doneproperly										[noteCopy setDuration:0];
//										[noteCopy setDottedSilently:NO];
//doneproperly										[subnote tieTo:noteCopy];
//doneproperly										[noteCopy tieFrom:subnote];
//doneproperly										[newChord addNote:subnote];
//doneproperly									}
//doneproperly								} else {
//doneproperly									replacing = YES;
//doneproperly									[newChord addNote:openNote];
//doneproperly								}
//doneproperly							}
//doneproperly							[openNoteArray addObject:newNote];
//doneproperly							newNote = newChord;
//doneproperly							if(replacing) {
//doneproperly								[staff removeLastNote];
//doneproperly							}
//doneproperly						} else {
//doneproperly							[openNoteArray addObject:newNote];
//doneproperly						}
//doneproperly						[measure addNote:newNote atIndex:([[measure notes] count] - 0.5) tieToPrev:NO];
//doneproperly						break;
//doneproperly				}
//doneproperly				[lastEventTimes setObject:[NSNumber numberWithFloat:(lastEvent + deltaBeats)] forKey:ch];
				}
			}
	}

//doneproperly	Staff *staff;
//doneproperly    NSMutableArray *songStaffs = [[song staffs] copy];
//doneproperly	for( staff in songStaffs )
//doneproperly    {
//doneproperly		NSArray *measures = staff.measures;
//doneproperly		if([measures count] > 1 || ([measures count] == 1 && [[[measures objectAtIndex:0] notes] count] > 0))
//doneproperly        {
//			NSEnumerator *measuresEnum = [measures objectEnumerator];
//			id measure;
//			while(measure = [measuresEnum nextObject]){
//				[measure grabNotesFromNextMeasure];
//				[measure refreshNotes:nil];
//			}
//doneproperly		} else {
//doneproperly			[song removeStaff:staff];
//doneproperly		}
//doneproperly	}
	return trackSize + 8;
}

+ (void)readHeaderFrom:(NSData *)data atOffset:(int)offset {

}

+ (void)parseMidiData:(NSData *)data intoSong:(SimpleSong *)song {
	[MIDIUtil readSong:song fromMIDI:data];
}

+ (void)readSong:(SimpleSong *)song fromMIDI:(NSData *)data {

    int offset=0, numTracks=0;
	
	const char bytes_4[4];
	[data getBytes:&bytes_4 range:NSMakeRange(offset, 4)]; // 4d 54 68 64 - "MThd"
    if( strncmp( (const char *)&bytes_4, (const char *)"MThd", 4 )){
        NSLog(@"Not a midi file");
        return;
    }
    offset+=4;
    
	int midiHeaderSize = [self readIntFrom:data offset:offset length:4]; // 00 00 00 06 - size of standard midi header
    if(midiHeaderSize!=6){
        NSLog(@"Midi file has a non-standard header size");
        return;
    }
    offset+=4;
    
	int format = [self readIntFrom:data offset:offset length:2];
	if(format > 1){
		[NSException raise:@"MIDIException" format:@"MIDI file was an unsupported format type, must be 0 or 1."];
	}
    offset+=2;
    
	numTracks = [self readIntFrom:data offset:offset length:2];
    offset+=2;
    
	int ticksPerQuarterNote = [self readIntFrom:data offset:offset length:2]; // ticks per quarter note (1 beat == quarter note?)
	if(!(ticksPerQuarterNote & 0x8000)){
		NSLog(@"ticks per beat is %i", ticksPerQuarterNote);
	} else {
		[NSException raise:@"MIDIException" format:@"MIDI file specifies resolution in frames per second.  Import of this type of file has not yet been implemented."];
	}
    offset+=2;
	/* end of midi header */

	for(int i=0; i<numTracks; i++){
		NSLog(@"Parsing track %i", i);
		offset = [self readTrackFrom:data into:song atOffset:offset withResolution:ticksPerQuarterNote];
	}
//notneeded	while([[song staffs] count] > 1){
//notneeded		[song removeStaff:[[song staffs] lastObject]];
//notneeded	}
}

@end
