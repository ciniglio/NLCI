//
//  NLParser.h
//  NL_interface
//
//  Created by Alejandro Ciniglio on 11/23/09.
//  Copyright 2009 Princeton University. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NLParser : NSObject {
	NSString *raw;
	NSString *action;
	NSString *verb;
	NSString *directObject;
	NSString *preposition;
	NSString *indirectObject;
	
	int actionLocation;
	int directObjectLocation;
	int prepositionLocation;
	int indirectObjectLocation;
}

@property (retain) NSString *raw;
@property (retain) NSString *action;
@property (retain) NSString *directObject;
@property (retain) NSString *preposition;
@property (retain) NSString *indirectObject;

@property int actionLocation;
@property int directObjectLocation;
@property int prepositionLocation;
@property int indirectObjectLocation;

- (NSString *) getMostLikelyActionFromActions:(NSArray *)actions;
- (void)setObjectsWithIndirect:(BOOL)indirect;
- (NSString *)cleanupWhitespaceIn:(NSString *)str;
- (id) initWithRaw:(NSString *)raw;

@end
