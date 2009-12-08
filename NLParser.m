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
		raw = rawInput;
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

-(NSString *)getMostLikelyActionFromActions:(NSArray *)actions {
	int min = NSIntegerMax;
	NSLog(@"ActionCount: %d", [actions count]);
	int i;
	for (i=0;i < [actions count]; i++){
		NSString *act = [actions objectAtIndex:i];
		NSArray *actionParts = [act componentsSeparatedByString:@" "];
		NSString *mainAct = [actionParts objectAtIndex:0];
		NSLog(@"looking for %@ (%@)", mainAct, act);
		NSRange range = [raw rangeOfString:mainAct];
		if (range.location != NSNotFound) {
			if (range.location < min && [actionParts count] == 1) {
				action = act;
				verb = mainAct;
				min = range.location;
				actionLocation = min;	
			}
			else if (range.location <= min && [actionParts count] > 1) {
			        NSString* rawPrep = [actionParts objectAtIndex:([actionParts count] - 1)];
				NSString* prep = [[rawPrep componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
				NSLog(@"ElseIf : %@", prep);
				NSRange pRange = [raw rangeOfString:prep];
				if (pRange.location != NSNotFound) {
					action = act;
					actionLocation = range.location;
					preposition = prep;
					prepositionLocation = pRange.location;
					break;
				}
			}
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
