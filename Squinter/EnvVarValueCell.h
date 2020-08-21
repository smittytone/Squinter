
//  Created by Tony Smith on 22/08/2019.
//  Copyright © 2020 Tony Smith. All rights reserved.
//  ADDED 2.3.131


#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN


@interface EnvVarValueCell : NSTableCellView
{
    IBOutlet NSImageView *typeIcon;
    
    NSImage *numberImage;
    NSImage *stringImage;
}


@property (nonatomic, readwrite) BOOL isString;


@end


NS_ASSUME_NONNULL_END
