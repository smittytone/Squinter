
//  Created by Tony Smith on 14/08/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//  ADDED 2.3.131


#import <Cocoa/Cocoa.h>
#import "EnvVarTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface EnvVarWindowController : NSViewController <NSTableViewDelegate,
                                                      NSTableViewDataSource,
                                                      NSTextFieldDelegate>
{
    IBOutlet NSTableView *variablesTableView;
    IBOutlet NSTextField *headerTextField;
    IBOutlet NSTextField *dataSizeTextField;
    
    NSMutableArray *envKeys, *envValues;
    
    NSString *json;
}


- (void)prepSheet;
- (void)updateData;
- (IBAction)doAddItem:(id)sender;
- (IBAction)doRemoveItem:(id)sender;
- (void)textDidEndEditing:(NSNotification *)notification;


@property (nonatomic, strong) NSString *devicegroup;
@property (nonatomic, strong) NSDictionary *envVars;


@end

NS_ASSUME_NONNULL_END
