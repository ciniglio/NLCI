//
//  NL_interface.m
//  NL_interface
//
//  Created by Alejandro Ciniglio on 11/11/09.
//  Copyright Princeton University 2009. All rights reserved.
//
//  QS Interface template by Vacuous Virtuoso
//

#import <QSEffects/QSWindow.h>
#import <QSInterface/QSSearchObjectView.h>
#import <QSInterface/QSObjectCell.h>
#import <QSCore/QSExecutor.h>
#import <QSCore/QSAction.h>
#import <QSCore/QSLibrarian.h>

#import "NL_interface.h"
#import "NLParser.h"

@implementation NL_interface

- (id)init {
	[self initWithWindowNibName:@"NL_interface"];
	//	[mainField setStringValue@""];
	return self;
}

- (NSArray *) getPossibleActionNames{
  NSMutableArray *acts = [[QSExecutor sharedInstance] actions];
  [self updateActionsNow];
  NSLog(@"Actions = %d", [acts count]);
  int arcount = [acts count];
  int i;
  NSMutableArray *actNames = [[NSMutableArray alloc] init];
  for ( i = 0; i < arcount; i++ ){
    NSLog(@"Object:: %d",[[acts objectAtIndex:i] argumentCount]);
    [actNames addObject:[[[[acts objectAtIndex:i] name] componentsSeparatedByString:@"("] objectAtIndex:0]];
  }
  return actNames;
}

- (NSArray *) getPossibleNouns{
  NSMutableArray *catalogContents = [[[QSLibrarian sharedInstance] catalog] contents];
  NSMutableArray *possibleNouns = [[NSMutableArray alloc] initWithCapacity:10];
  for (NSString* content in catalogContents){
    [possibleNouns addObject:[content name]];
    NSLog(@"Contents: %@", [content name]);
  }
  return possibleNouns;
}

- (void) clearSearchFor:(id)selector{
  [selector clearSearch];
  [selector clearAll];
  [selector clearObjectValue];
  [self clearObjectView:selector];
}

// @TODO Stupidly named change later
- (IBAction) findActions:(id)sender{
	NSString *query = [mainField stringValue];

	NSArray *possibleNouns = [self getPossibleNouns];
	NSMutableArray *possibleActionNames = [self getPossibleActionNames];
	NSMutableArray *possibleActions = [[NSMutableArray alloc] init];
	[possibleActions addObjectsFromArray:[[QSExecutor sharedInstance] actions]];
	NLParser *nlp = [[NLParser alloc] initWithRaw:query 
				    withPossibleNouns:possibleNouns
			       andWithPossibleActions:possibleActionNames];
	if ([nlp handleSynonyms]){
	  NSLog(@"worked");
	  [self hideMainWindow:self];
	  return;
	}
	[possibleActions addObjectsFromArray:[[nlp verbSynonyms] allValues]];
	int likelyIndex = [nlp getMostLikelyAction];
	QSAction *likelyAction = [possibleActions objectAtIndex:likelyIndex];
	//	[nlp parseVerbSynonyms];
	BOOL indirect = [likelyAction argumentCount] == 1 ? NO : YES;
	[nlp findAndSetPreposition];
	[nlp setObjectsWithIndirect:indirect];
	NSLog(@"past LA2");
	// Logging
	NSLog(@"Most Likely: %@ ", [likelyAction name]);
	NSLog(@"Most Likely: %@, %@", [likelyAction name], [nlp actionLocation]);
	NSLog(@"Most Likely: %@, %@, %d", [likelyAction name], [nlp actionLocation], [likelyAction argumentCount]);
	NSLog(@"Preposition: %@", [nlp preposition]);
	NSLog(@"DO: %@ // IO: %@", [nlp directObject], [nlp indirectObject]);
	// /Bunyan
	
	[self clearSearchFor:[self dSelector]];
	[self clearSearchFor:[self aSelector]];
	[self clearSearchFor:[self iSelector]];
	
	NSLog(@"Directobj for search: %@", [nlp directObject]);
	[dSelector performSearchFor:[nlp directObject] from:dSelector];
	

	// [dSelector collect:dSelector];
       	// [dSelector clearSearch];
       	// [dSelector clearAll]; //***
	// [dSelector performSearchFor:@"mail.app" from:dSelector];
	

	[self updateActionsNow];
	NSLog(@"trueAction for search: %@", [nlp trueAction]);
	[aSelector performSearchFor:[nlp trueAction] from:aSelector];
	[self updateIndirectObjects];
	if ([[nlp indirectObject] length] > 0){
	  [iSelector performSearchFor:[nlp indirectObject] from:iSelector];
	}
}

- (QSAction *) getActionFromName:(NSString *)name{
        QSExecutor *qse = [QSExecutor sharedInstance];
	return [qse actionForIdentifier:name];
}

- (IBAction) search1: (id)sender{
	
	// Resets searches... likely just clearAll?
	[[self dSelector] clearSearch];
	[dSelector clearAll];
	[dSelector clearObjectValue];
	[self clearObjectView:[self dSelector]];
	
	
	QSSearchObjectView *sov = [self dSelector];
	//[sov performSearchFor:@"" from:sov];
	NSString *st = [tf1 stringValue];
	NSLog(@"Search for d: %@", st);
	[dSelector performSearchFor:st from:dSelector];
	
	// Uncomment for collections
	//[dSelector collect:dSelector];
	//[[self dSelector] clearAll];
	//[dSelector performSearchFor:@"Chess" from:dSelector];
	
	[self updateActionsNow];
	NSString *st2 = [tf2 stringValue];
	[aSelector performSearchFor:st2 from:aSelector];
	
	[self updateIndirectObjects];
	[iSelector performSearchFor:@"Orlando" from:iSelector];
}

- (IBAction) search2: (id)sender{
	[self executeCommand:self];
}

- (void) windowDidLoad {

	[super windowDidLoad];

	QSWindow *window=(QSWindow *)[self window];

    [[self window] setLevel:NSModalPanelWindowLevel];
    [[self window] setFrameAutosaveName:@"qs11_10_09Window"];

	// If it's off the screen, bring it back in
	//   [[self window]setFrame:constrainRectToRect([[self window]frame],[[[self window]screen]visibleFrame]) display:NO];


// How much the interface moves when it's showing / hiding
// Tip: set "hide offset" = -"show offset" so the window doesn't gradually get displaced from its original position
	[window setHideOffset:NSMakePoint(0,0)];
	[window setShowOffset:NSMakePoint(0,0)];

	[window setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"show",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]];
//	[window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSShrinkEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:.25],@"duration",nil]];

	// setWindowProperty returns an error, unfortunately... ignore it
	[window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSExplodeEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.2],@"duration",nil] forKey:kQSWindowExecEffect];

    NSArray *theControls=[NSArray arrayWithObjects:dSelector,aSelector,iSelector,nil];
    foreach(theControl,theControls){

		[theControl setPreferredEdge:NSMinYEdge];
		[theControl setResultsPadding:NSMinY([dSelector frame])];

		NSCell *theCell=[theControl cell];
//		[(QSObjectCell *)theCell setTextColor:[NSColor whiteColor]];
//		[(QSObjectCell *)theCell setHighlightColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0.4]];
//		[(QSObjectCell *)theCell setAlignment:NSCenterTextAlignment];
		// If yes, will show info under the title (eg. path)
		[(QSObjectCell *)theCell setShowDetails:NO];

	}

/* Example bindings. */
/*	[[[self window] contentView] bind:@"highlightColor"
							 toObject:[NSUserDefaultsController sharedUserDefaultsController]
						  withKeyPath:@"values.interface.glassColor"
							  options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
																  forKey:@"NSValueTransformerName"]];
	[[[self window] contentView] bind:@"borderWidth"
							 toObject:[NSUserDefaultsController sharedUserDefaultsController]
						  withKeyPath:@"values.interface.borderWidth"
							  options:nil];*/
	
// Just a reminder that you can do normal NSWindow-ey things...
//    [[self window]setMovableByWindowBackground:NO];

}

- (NSSize)maxIconSize{
    return NSMakeSize(128,128);
}

- (void)showMainWindow:(id)sender{
	if ([[self window]isVisible])[[self window]pulse:self];
	[mainField setStringValue:@""];
	[super showMainWindow:sender];
}

- (void)hideMainWindow:(id)sender{
	[[self window] saveFrameUsingName:@"qs11_10_09Window"];
	[super hideMainWindow:sender];
}

/*
*  If you want an effect such as an animation
*  when the indirect selector shows up,
*  the next three methods are for you to subclass.
*/

- (void)showIndirectSelector:(id)sender{
    [super showIndirectSelector:sender];
}

- (void)expandWindow:(id)sender{ 
    [super expandWindow:sender];
}

- (void)contractWindow:(id)sender{
    [super contractWindow:sender];
}

// When something changes, update the command string
- (void)firstResponderChanged:(NSResponder *)aResponder{
	[super firstResponderChanged:aResponder];
	[self updateDetailsString];
}
- (void)searchObjectChanged:(NSNotification*)notif{
	[super searchObjectChanged:notif];	
	[self updateDetailsString];
}

// The method to update the command string
// Get rid of it if you're not having a commandView outlet
-(void)updateDetailsString{
	NSString *command=[[self currentCommand]description];
	[commandView setStringValue:command?command:@""];
}

// Uncomment if you're having a customize button + pref pane
/*- (IBAction)customize:(id)sender{
	[[NSClassFromString(@"QSPreferencesController") sharedInstance]showPaneWithIdentifier:@"QSFumoInterfacePrefPane"];
}*/


- (void)actionActivate:(id)sender{
	[super actionActivate:sender];
}
- (void)updateViewLocations{
    [super updateViewLocations];
}

@end
