

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017-18 Tony Smith. All rights reserved.


#import "TreeNode.h"

@implementation TreeNode

@synthesize key, value, children, flag;


- (instancetype)init
{
    if (self = [super init])
    {
        key = @"";
        value = @"";
        children = nil;
        flag = NO;
    }

    return self;
}


@end
