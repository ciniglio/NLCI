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
	NSString *actionRemainder;
	NSString *verb;
	NSString *directObject;
	NSString *preposition;
	NSString *indirectObject;
	
	NSMutableDictionary *nounSynonyms;
	NSMutableArray *possibleNouns;

	int actionLocation;
	int directObjectLocation;
	int prepositionLocation;
	int indirectObjectLocation;
}

@property (nonatomic, copy) NSString *raw;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *actionRemainder;
@property (nonatomic, copy) NSString *verb;
@property (nonatomic, copy) NSString *directObject;
@property (nonatomic, copy) NSString *preposition;
@property (nonatomic, copy) NSString *indirectObject;
	
@property (nonatomic, retain) NSMutableDictionary *nounSynonyms;
@property (nonatomic, retain) NSMutableArray *possibleNouns;


@property int actionLocation;
@property int directObjectLocation;
@property int prepositionLocation;
@property int indirectObjectLocation;

- (NSString *) getMostLikelyActionFromActions:(NSArray *)actions;
- (void)setObjectsWithIndirect:(BOOL)indirect;
- (NSString *)cleanupWhitespaceIn:(NSString *)str;
- (id) initWithRaw:(NSString *)raw;

@end

