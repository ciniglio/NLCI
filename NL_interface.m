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

#import "NL_interface.h"

@implementation NL_interface

- (id)init {
	return [self initWithWindowNibName:@"NL_interface"];
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
    [[self window]setFrame:constrainRectToRect([[self window]frame],[[[self window]screen]visibleFrame]) display:NO];


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
