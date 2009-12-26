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
@synthesize trueAction;
@synthesize directObject;
@synthesize preposition;
@synthesize indirectObject;

@synthesize actionLocation;
@synthesize directObjectLocation;
@synthesize nounSynonyms;
@synthesize verbSynonyms;

@synthesize possibleNouns;
@synthesize possibleActions;
@synthesize possibleVerbs;

-(id)initWithRaw:(NSString *)rawInput 
withPossibleNouns:(NSMutableArray *)pNouns
andWithPossibleActions:(NSMutableArray *)pActions{
        self = [super init];
        if (self) {
                raw = [[rawInput retain] lowercaseString];
                nounSynonyms = [[NSMutableDictionary alloc] initWithCapacity:10];
                verbSynonyms = [[NSMutableDictionary alloc] initWithCapacity:10];
                possibleNouns = [pNouns retain];
                possibleActions = [pActions retain];
		possibleVerbs = [[NSMutableArray alloc] initWithArray:[pActions retain]];
                [self setActionLocation:-1];
                action = nil;
                actionRemainder = nil;
                trueAction = nil;
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

// Helper method to make strings uniform (we are assuming unique strings anyways, so lowercase is fine)
-(NSString *)makeLowercaseAndPunctuationFree:(NSString *)ugly {
        NSString *up = [[ugly componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "];
        NSString *spaced = [up stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *pretty = [spaced lowercaseString];
        return pretty;
}

-(float)actionProbable{
  NSLog(@"started actionProbable: %@", action);
  int correct = 0;
  NSString *cleanAction = [self cleanupWhitespaceIn:[self makeLowercaseAndPunctuationFree:action]];
  NSArray *parts = [cleanAction componentsSeparatedByString:@" "];
  
  int possible = [parts count];
  for (NSString *part in parts){
    NSRange range = [raw rangeOfString:part];
    if (range.location != NSNotFound) {
      correct++;
    }
  }
  NSLog(@"out of actionProbable loop");
  return ((float) correct) / ((float) possible);
}

// Method that scores the similiarity of a string to $raw
// Based on number of matched words as well as the percentage of raw that is correctly matched
-(float)getMatchScoreUsing:(NSString *)match {
        int correct = 0;
        int rawTotal = [[raw componentsSeparatedByString:@" "] count];
        int matchTotal = [[match componentsSeparatedByString:@" "] count];
        NSArray *parts = [[self makeLowercaseAndPunctuationFree:match] componentsSeparatedByString:@" "];
	NSArray *rawParts = [[self makeLowercaseAndPunctuationFree:raw] componentsSeparatedByString:@" "];
        for (NSString *part in parts){
                 //NSLog(@"Scoring %@", part);
                 NSRange range = [raw rangeOfString:part];
                 if ([rawParts containsObject:part]) {
                   //      NSLog(@"Found: %@", part);
                   correct++;
                 }
        }
	NSLog(@"getMatchScoreUsing:%@ -- %f", match, ((float) correct) / (((float) rawTotal + (float) matchTotal)));
	NSLog(@"\t correct:  %d", correct);
        return ((float) correct) / (((float) rawTotal + (float) matchTotal));
}

// Here, given a preposition for a verb, will try to find it in $raw
-(void *)findAndSetPreposition{
        NSString *prep = [self getPrepositionIfAny];
        if ([prep length] == 0)
          return;
        NSRange range = [raw rangeOfString:prep];
        if (range.location != NSNotFound) {
                preposition = prep;
                prepositionLocation = range.location;
        }
}

// Given an action string, will find the preposition if one is attached
// e.g. Open With... returns @"with"
-(NSString *)getPrepositionIfAny {
        NSString *cleanAction = [self makeLowercaseAndPunctuationFree:action];
        NSArray *cleanParts = [cleanAction componentsSeparatedByString:@" "];
        if ([cleanParts count] == 1)
          return @"";
        NSString *prep = [cleanParts objectAtIndex:[cleanParts count] - 1];
        return prep;
}

// Searches through a given array to find most likely action in raw, 
// using the scoring function from above
- (int)getMostLikelyAction {
        int min = NSIntegerMax;
        float bestScore = 0;
        int i,ret;
        NSArray *actions = [self possibleActions];
	NSMutableArray *verbs = [self possibleVerbs];
        [verbs addObjectsFromArray:[[self verbSynonyms] allKeys]];
        NSInteger numActions = [actions count];
	NSInteger numVerbs = [verbs count];
	NSLog(@"verbSynCount: %d", [verbSynonyms count]);
        NSLog(@"ACount: %d, vcount: %d", [verbs count], [actions count]);
        // iterate through each possible action
        for (i=0;i < numVerbs; i++){
                NSString *actName = [verbs objectAtIndex:i];
                NSString *act = [[self makeLowercaseAndPunctuationFree:actName] retain];
                NSArray *actionParts = [act componentsSeparatedByString:@" "];
                NSString *mainAct = [actionParts objectAtIndex:0]; // assumes the verb is the first word in the action
                NSRange range = [raw rangeOfString:mainAct];

                if ([self getMatchScoreUsing:act] > bestScore && range.location != NSNotFound) {
                        if (range.location <= min){
                                ret = i;
                                action = [actName retain];
                                verb = [mainAct retain];
                                min = range.location;
                                actionLocation = min;   
                                bestScore = [self getMatchScoreUsing:act];
                                actionRemainder = [[self cleanupWhitespaceIn:[raw substringFromIndex:(min + [mainAct length])]] retain];
                        }
                }
        }
	if (ret > numActions - 1){
	  trueAction = [verbSynonyms objectForKey:action];
	  NSLog(@"Used synonym! -- %@", trueAction);
	  ret = [actions indexOfObject:trueAction];
	} else {
	  trueAction = action;
	}
        NSLog(@"Actionscore email: %f", [self getMatchScoreUsing:@"email"]);
        NSLog(@"Actionscore email with: %f", [self getMatchScoreUsing:@"email with"]);
        NSLog(@"ActionLocation : %d", actionLocation);
        NSLog(@"Action remainder: %@", actionRemainder);
        if ([self actionProbable] > .7){
          NSLog(@"actionprobable done");
          return ret;
        }
        return -1;
}

// Removes trailing and leading whitespace
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

// finds the given objects on either side of the preposition
- (void)setObjectsWithIndirect:(BOOL)indirect {
        if (indirect) {
                if (prepositionLocation > 0) {
   		        NSLog(@"ind and prep");
                        NSArray *rawArray = [raw componentsSeparatedByString:@" "];
                        NSRange doRange;
                        NSString *mainAct = [[action componentsSeparatedByString:@" "] objectAtIndex:0];
                        NSInteger mainActLength = [mainAct length];
                        NSInteger actionLoc = actionLocation;

                        NSLog(@"sowi: actionLoc: %d", [self actionLocation] + mainActLength);
                        doRange.location = actionLocation + mainActLength;
                        NSLog(@"sowi: doRangeLoc: %d", doRange.location);
                        NSLog(@"sowi: prerpLoc: %d", prepositionLocation);
                        doRange.length = prepositionLocation - doRange.location;
                        NSLog(@"sowi: doranglen: %d", doRange.length);
			NSString *possibleDO = [self cleanupWhitespaceIn:[raw substringWithRange:doRange]];
                        directObject = [self nounMatch:possibleDO];
                        directObjectLocation = doRange.location + 1;
                        
                        NSRange ioRange;
                        ioRange.location = prepositionLocation + [preposition length];
                        ioRange.length = [raw length] - ioRange.location;
			NSString *possibleIO = [self cleanupWhitespaceIn:[raw substringWithRange:ioRange]];
                        indirectObject = [self nounMatch:possibleIO];
                        indirectObjectLocation = ioRange.location + 1;
                }
        
                else {
                  NSLog(@"ind and No preposition");
                  [self doubleObjectParser];
                }
        }
        else {
	  NSString *possibleDO = [self cleanupWhitespaceIn:actionRemainder];
          directObject = [self nounMatch:possibleDO];
          directObjectLocation = actionLocation 
                               + [[[action componentsSeparatedByString:@" "] objectAtIndex:0] length] 
                               + 1;
        }

}

- (NSString *)nounMatch:(NSString *)n{
  /*FIND NOUN

stirng [] nouns
dictionary n_synonyms

given n
if n in nouns:
   return n
if n in n_synonyms.keys:
   return n_synonyms[n]
   error "$n not found" */
  NSLog(@"Noun match with %@", n);
  for(NSString *noun in possibleNouns){
    noun = [noun lowercaseString];
    if ([n isEqualToString:noun]){
      NSLog(@"Found Noun: %@", noun);
      return noun;
    }
  }
  if([nounSynonyms objectForKey:n] != nil){
    return [nounSynonyms objectForKey:n];
  }
        //      if ([nounSynonyms valueForKey:n]) return [nounSynonyms valueForKey:n];
  return @"";
}

- (BOOL)doubleObjectParser{
  /*        OBJECT MATCHING / FINDING

            VERB OBJ1a OBJ1b OBJ2a

            for words in sentence:
                verb, remainder = findverb
                if (preposition in remainder):
                    easycase (find DO and IO)
                else:
                    len := remainder.words.length       
                    for i=1 ; i<len ; i++
                        if (match(remainder.words[:i]) AND match(remainder.words[i:]))
                            got DO and IO
                            doit
                            found = true
                            break
                    if (!found) error "please specify more stuff"
*/
  NSArray *inWords = [actionRemainder componentsSeparatedByString:@" "];
  int len = [[actionRemainder componentsSeparatedByString:@" "] count];
  NSLog(@"Action remainder len: %d", len);
  int i = 0; int j = 0;
  NSMutableString *part1 = [[NSMutableString alloc] initWithString:@""];
  NSMutableString *part2 = [[NSMutableString alloc] initWithString:@""];
  for (i = 0; i < len; i++){
    [part1 appendFormat:@" %@", [inWords objectAtIndex:i]];
    NSString *tmp = part1;
    [part1 setString:[self cleanupWhitespaceIn:tmp]];
    NSLog(@"part1 : %@", part1);
    [part2 setString:@""];
    for (j = i + 1; j < len; j++){
      [part2 appendFormat:@" %@", [inWords objectAtIndex:j]];
      tmp = part2;
      [part2 setString:[self cleanupWhitespaceIn:tmp]];
      NSLog(@"part2 : %@", part2);
      NSString *match1 = [self nounMatch:part1];
      NSString *match2 = [self nounMatch:part2];
      if ([match1 length] && [match2 length]){
	directObject = part2;
	indirectObject = part1;
	return YES;
      }
    }
  }
  
  return NO;
  

}

- (BOOL) handleSynonyms {
  [self unarchiveDicts];
  NSLog(@"Number of nounSynonyms: %d", [nounSynonyms count]);
  NSLog(@"Number of verbSynonyms: %d", [verbSynonyms count]);
  NSArray *parts = [raw componentsSeparatedByString:@"is"];
  for (NSString *key in [nounSynonyms allKeys]){
    NSLog(@"Nsynonyms %@::%@", key, [nounSynonyms objectForKey:key]);
  }
  if ([parts count] == 1)
    return NO;
  NSString *cleanPart1 = [self cleanupWhitespaceIn:[[parts objectAtIndex:0] lowercaseString]];
  NSString *cleanPart2 = [self cleanupWhitespaceIn:[[parts objectAtIndex:1] lowercaseString]];
  BOOL noun = NO; BOOL verbB = NO;
  noun = [self nSynonymous:cleanPart1
		      with:cleanPart2];
  if (noun != YES){
    verbB = [self vSynonymous:cleanPart1
			with:cleanPart2];
  }
  NSLog(@"Number of nounSynonyms: %d", [nounSynonyms count]);
  NSLog(@"Number of verbSynonyms: %d", [verbSynonyms count]);

  [self archiveDicts];
  return (noun || verbB);
}

- (void) parseVerbSynonyms {
  NSString *targetString = [raw substringToIndex:actionLocation];
  NSLog (@"target: %@", targetString);
}

- (NSString *) pathForSynonymsDataFile
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
    
  NSString *folder = @"~/Library/Application Support/NatLangCI/";
  folder = [folder stringByExpandingTildeInPath];

  if ([fileManager fileExistsAtPath:folder] == NO)
  {
    [fileManager createDirectoryAtPath:folder attributes: nil];
  }
    
  NSString *fileName = @"syns.nlci";
  return [folder stringByAppendingPathComponent: fileName];    
}

- (void)archiveDicts{
  //NSLog(@"Check ff: %@", [nounSynonyms objectForKey:@"ff"]);
  NSString *path = [self pathForSynonymsDataFile];
  NSMutableDictionary *rootObject;
  rootObject = [[NSMutableDictionary alloc] initWithCapacity:3];
  NSMutableDictionary *tester = [[NSMutableDictionary alloc] initWithCapacity:1];
  [tester setObject:@"ale" forKey:@"susan"];
  NSLog(@"tester: %@", [tester objectForKey:@"susan"]);
  [rootObject setValue:tester forKey:@"test"];
  [rootObject setValue:[self nounSynonyms] forKey:@"Nouns"];
  [rootObject setValue:[self verbSynonyms] forKey:@"Verbs"];
  [NSKeyedArchiver archiveRootObject:rootObject toFile:path];
}

- (void)unarchiveDicts {
  NSString *path = [self pathForSynonymsDataFile];
  NSDictionary *rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
  NSLog(@"unarchive ncount: %d", [[rootObject objectForKey:@"Nouns"] count]);
  NSLog(@"unarchive totalCount: %d", [rootObject count]);
  if ([[rootObject objectForKey:@"test"] count] > 0){
    [self setNounSynonyms:[[rootObject objectForKey:@"test"] retain]];
  }
  if ([[rootObject objectForKey:@"Nouns"] count] > 0){
    [self setNounSynonyms:[[rootObject objectForKey:@"Nouns"] retain]];
  }
  if ([[rootObject objectForKey:@"Verbs"] count] > 0){
    [self setVerbSynonyms:[[rootObject objectForKey:@"Verbs"] retain]];
  }
}

- (BOOL)nSynonymous:(NSString *)p1 with:(NSString *)p2 {
 /*     SYNONYMS:

N1 is N2

global dictionary n_synonyms
global array Nouns

for words in sentence:
   if (word == is)
       assignment = true;
        break;

part1 = sentence.split("is")[0]
part2 = sentence.split("is")[1]

if part1 in nouns:
  n_synonyms[part2] = part1
else if part2 in nouns:
  n_synonyms[part1] = part2
else if part1 in synonyms.keys():
  n_synonyms[part1] = part2
else if part2 in synonyms.keys():
  n_synonyms[part2] = part1
else: 
  error("I don't know what $part1 or $part2 are")
  return;
n_synonyms.save()
        */
  BOOL p1Main = NO;
  BOOL p2Main = NO;
  NSLog(@"Setting synonyms: %@, %@", p1, p2);
  for (NSString *noun in possibleNouns){
    NSString *lNoun = [noun lowercaseString];
    //NSLog(@"Checking against: %@", lNoun);
    //if ([p1 isEqualToString:@"firefox.app"])
    //NSLog(@"found ff");
    if ([p1 isEqualToString:lNoun]){
      NSLog(@"p1 is equal to noun");
      p1Main = YES;
    }
    if ([p2 isEqualToString:lNoun]){
      NSLog(@"p2 is equal to noun");
      p2Main = YES;
    }
  }
  NSLog(@"Done searching: %d, %d", p1Main, p2Main);
  if (p1Main == YES && p2Main == YES){
    return YES;
  }
  if (p1Main == YES) {
    NSLog(@"p1 main");
    [[self nounSynonyms] setObject:p1 forKey:p2];
    return YES;
  }
  else if (p2Main == YES) {
    NSLog(@"p2 main");
    [nounSynonyms setObject:p2 forKey:p1];
    return YES;
  }
  NSLog(@"Now looking at existing syns");
  for (NSString *key in [nounSynonyms allKeys]){
    NSLog(@"HOAT: %@, %@, %@", key, p1, p2);
    if ([p1 isEqualToString:key]){
      NSLog(@"P1 was already there...-- %@", [nounSynonyms objectForKey:p1]);
      [nounSynonyms setObject:[nounSynonyms objectForKey:p1] forKey:p2];
      return YES;
    }
    if ([p2 isEqualToString:key]){
      NSLog(@"p2 was already there...");
      [nounSynonyms setObject:[nounSynonyms objectForKey:p2] forKey:p1];
      return YES;
    }
  }
  return NO; 
}
- (BOOL)vSynonymous:(NSString *)p1 with:(NSString *)p2 {
 /*     SYNONYMS:

N1 is N2

global dictionary n_synonyms
global array Nouns

for words in sentence:
   if (word == is)
       assignment = true;
        break;

part1 = sentence.split("is")[0]
part2 = sentence.split("is")[1]

if part1 in nouns:
  n_synonyms[part2] = part1
else if part2 in nouns:
  n_synonyms[part1] = part2
else if part1 in synonyms.keys():
  n_synonyms[part1] = part2
else if part2 in synonyms.keys():
  n_synonyms[part2] = part1
else: 
  error("I don't know what $part1 or $part2 are")
  return;
n_synonyms.save()
        */
  BOOL p1Main = NO;
  BOOL p2Main = NO;
  NSString *fullVerbName;
  NSLog(@"Setting vsynonyms: %@, %@", p1, p2);
  for (NSString *v in possibleActions){
    NSString *lVerb = [self makeLowercaseAndPunctuationFree:[v lowercaseString]];
    //NSLog(@"Checking against: %@", lNoun);
    //if ([p1 isEqualToString:@"firefox.app"])
    //NSLog(@"found ff");
    if ([p1 isEqualToString:lVerb]){
      NSLog(@"p1 is equal to vb");
      fullVerbName = v;
      p1Main = YES;
    }
    if ([p2 isEqualToString:lVerb]){
      NSLog(@"p2 is equal to vb");
      fullVerbName = v;
      p2Main = YES;
    }
  }
  NSLog(@"Done searching: %d, %d", p1Main, p2Main);
  if (p1Main == YES && p2Main == YES){
    NSLog(@"both YES");
    return YES;
  }
  if (p1Main == YES) {
    NSLog(@"p1 main");
    [[self verbSynonyms] setObject:fullVerbName forKey:p2];
    return YES;
  }
  else if (p2Main == YES) {
    NSLog(@"p2 main");
    [[self verbSynonyms] setObject:fullVerbName forKey:p1];
    return YES;
  }
  NSLog(@"Now looking at existing syns");
  for (NSString *key in [verbSynonyms allKeys]){
    NSLog(@"HOAT: %@, %@, %@", key, p1, p2);
    if ([p1 isEqualToString:key]){
      NSLog(@"P1 was already there...-- %@", [verbSynonyms objectForKey:p1]);
      [verbSynonyms setObject:[verbSynonyms objectForKey:p1] forKey:p2];
      return YES;
    }
    if ([p2 isEqualToString:key]){
      NSLog(@"p2 was already there...");
      [verbSynonyms setObject:[verbSynonyms objectForKey:p2] forKey:p1];
      return YES;
    }
  }
  return NO; 
}


@end
