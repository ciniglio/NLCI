//
//  NLParser.m
//  NL_interface
//
//  Created by Alejandro Ciniglio on 11/23/09.
//  Copyright 2009 Princeton University. All rights reserved.
//

#import "NLParser.h"


@implementation NLParser

@synthesize raw;
@synthesize action;
@synthesize directObject;
@synthesize preposition;
@synthesize indirectObject;

@synthesize actionLocation;
@synthesize directObjectLocation;

-(id)initWithRaw:(NSString *)rawInput{
	self = [super init];
	if (self) {
		raw = [rawInput lowercaseString];
		actionLocation = -1;
		action = nil;
		verb = nil;
		directObjectLocation = -1;
		directObject = nil;
		prepositionLocation = -1;
		preposition = nil;
		indirectObjectLocation = -1;
		indirectObject = nil;
		NSLog(@"NLParser initialized w/ raw: %@", raw);
	}
	return self;
}

-(NSString *)makeLowercaseAndPunctuationFree:(NSString *)ugly {
        NSString *up = [[ugly componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "];
        NSString *spaced = [up stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString *pretty = [spaced lowercaseString];
	return pretty;
}

-(float)getMatchScoreUsing:(NSString *)match {
        int correct = 0;
        int rawTotal = [[raw componentsSeparatedByString:@" "] count];
	int matchTotal = [[match componentsSeparatedByString:@" "] count];
        NSArray *parts = [[self makeLowercaseAndPunctuationFree:match] componentsSeparatedByString:@" "];
	for (NSString *part in parts){
	         //NSLog(@"Scoring %@", part);
	         NSRange range = [raw rangeOfString:part];
		 if (range.location != NSNotFound) {
		   //	   NSLog(@"Found: %@", part);
		   correct++;
		 }
	}
	return ((float) correct) / (((float) rawTotal + (float) matchTotal));
}

-(void *)findAndSetPreposition{
        NSString *prep = [self getPrepositionIfAny];
        NSRange range = [raw rangeOfString:prep];
        if (range.location != NSNotFound) {
                preposition = prep;
				prepositionLocation = range.location;
        }
}

-(NSString *)getPrepositionIfAny {
        NSString *cleanAction = [self makeLowercaseAndPunctuationFree:action];
    	NSArray *cleanParts = [cleanAction componentsSeparatedByString:@" "];
        NSString *prep = [cleanParts objectAtIndex:[cleanParts count] - 1];
        return prep;
}

-(NSString *)getMostLikelyActionFromActions:(NSArray *)actions {
	int min = NSIntegerMax;
	float bestScore = 0;
	int i;
   
	NSLog(@"ActionCount: %d", [actions count]);

	for (i=0;i < [actions count]; i++){
                NSString *actName = [actions objectAtIndex:i];
	        NSString *act = [self makeLowercaseAndPunctuationFree:[actions objectAtIndex:i]];
		NSArray *actionParts = [act componentsSeparatedByString:@" "];
		NSString *mainAct = [actionParts objectAtIndex:0];
		//		NSLog(@"looking for %@ (%@)", mainAct, act);
		//		NSLog(@"Score %f", [self getMatchScoreUsing:act]);
		NSRange range = [raw rangeOfString:mainAct];
		if ([self getMatchScoreUsing:act] > bestScore && range.location != NSNotFound) {
          		NSLog (@"inside conditional");
		        if (range.location <= min){// && [actionParts count] == 1) {
				action = actName;
				verb = mainAct;
				min = range.location;
				actionLocation = min;	
				bestScore = [self getMatchScoreUsing:act];
			}
			// else if (range.location <= min && [actionParts count] > 1) {
			//         NSString* rawPrep = [actionParts objectAtIndex:([actionParts count] - 1)];
			// 	NSString* prep = [[rawPrep componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
			// 	NSLog(@"ElseIf : %@", prep);
			// 	NSRange pRange = [raw rangeOfString:prep];
			// 	if (pRange.location != NSNotFound) {
			// 		action = act;
			// 		actionLocation = range.location;
			// 		preposition = prep;
			// 		prepositionLocation = pRange.location;
			// 		bestScore = [self getMatchScoreUsing:act];
			// 	}
			// }
		}
	}
	return action;
}

- (NSString *)cleanupWhitespaceIn:(NSString *)str {
	NSArray *arr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSMutableArray *ret = [NSMutableArray array];
	for(NSString *comp in arr){
		if ([comp length] > 0) {
			[ret addObject:comp];
		}
	}
	return [ret componentsJoinedByString:@" "];
}

- (void)setObjectsWithIndirect:(BOOL)indirect {
	if (indirect) {
		if (prepositionLocation > 0) {
			NSArray *rawArray = [raw componentsSeparatedByString:@" "];
			NSRange doRange;
			doRange.location = actionLocation + [[[action componentsSeparatedByString:@" "] objectAtIndex:0] length];
			doRange.length = prepositionLocation - doRange.location;
			directObject = [self cleanupWhitespaceIn:[raw substringWithRange:doRange]];//[[rawArray subarrayWithRange:doRange] componentsJoinedByString:@""];
			directObjectLocation = actionLocation + 1;
			
			NSRange ioRange;
			ioRange.location = prepositionLocation + [preposition length];
			ioRange.length = [raw length] - ioRange.location;
			indirectObject = [self cleanupWhitespaceIn:[raw substringWithRange:ioRange]];
			indirectObjectLocation = prepositionLocation + 1;
		}
	}
}


@end
