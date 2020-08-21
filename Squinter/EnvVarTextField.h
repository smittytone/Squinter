
//  Created by Tony Smith on 21/08/2019.
//  Copyright © 2020 Tony Smith. All rights reserved.
//  ADDED 2.3.131

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnvVarTextField : NSTextField

// This is a simple sub-class that provides two extra properties:

@property (nonatomic, readwrite) NSUInteger type;
@property (nonatomic, readwrite) NSUInteger tableRow;


@end

NS_ASSUME_NONNULL_END
