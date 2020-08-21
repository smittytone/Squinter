

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import "TreeNode.h"

@implementation TreeNode

@synthesize key, value, children, flag, expanded, dg;


- (instancetype)init
{
    if (self = [super init])
    {
        key = @"";
        value = @"";
        children = nil;
        flag = NO;
        expanded = NO;
        dg = nil;
    }

    return self;
}


@end
