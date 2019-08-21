
//  Created by Tony Smith on 14/08/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//  ADDED 2.3.131


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnvVarWindowController : NSViewController <NSTableViewDelegate,
                                                      NSTableViewDataSource,
                                                      NSTextFieldDelegate>
{
    IBOutlet NSTableView *envVarTableView;
    IBOutlet NSTextField *headerTextField;
    
    NSMutableArray *envKeys, *envValues;
    
    
}


- (void)prepSheet;
- (void)updateData;
- (IBAction)doAddItem:(id)sender;
- (IBAction)doRemoveItem:(id)sender;


@property (nonatomic, strong) NSString *jsonString;
@property (nonatomic, strong) NSString *devicegroup;


@end

NS_ASSUME_NONNULL_END
