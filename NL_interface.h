//
//  NL_interface.h
//  NL_interface
//
//  Created by Alejandro Ciniglio on 11/11/09.
//  Copyright Princeton University 2009. All rights reserved.
//
//  QS Interface template by Vacuous Virtuoso
//

#import <Cocoa/Cocoa.h>
#import "QSInterface/QSResizingInterfaceController.h"


@interface NL_interface : QSResizingInterfaceController
{
	IBOutlet NSTextField *tf1;
	IBOutlet NSTextField *tf2;
	IBOutlet NSTextField *mainField;
}
- (IBAction) search1:(id)sender;
- (IBAction) search2:(id)sender;
- (IBAction) findActions:(id)sender;
-(void)updateDetailsString;
@end