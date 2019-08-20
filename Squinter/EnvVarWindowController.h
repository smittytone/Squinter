
//  Created by Tony Smith on 14/08/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//  ADDED 2.3.131


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnvVarWindowController : NSViewController <NSTableViewDelegate,
                                                      NSTableViewDataSource>
{
    IBOutlet NSTableView *envVarTableView;
    
    NSMutableDictionary *envData;
    NSMutableArray *envKeys;
    
    
}


@property (nonatomic, strong) NSString *jsonString;


@end

NS_ASSUME_NONNULL_END
