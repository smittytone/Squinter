

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-19 Tony Smith. All rights reserved.


#import "Devicegroup.h"


@implementation Devicegroup


@synthesize name, description, did, squinted, isExpanded;
@synthesize models, data, type, history, mdid, cdid;


- (instancetype)init
{
    if (self = [super init])
    {
        name = @"";
        description = @"";
        did = @"";
        type = @"development_devicegroup";
        models = nil;
        data = nil;
        history = nil;
        mdid = nil;
        cdid = nil;
        squinted = 0;
        isExpanded = YES;
    }

    return self;
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        name = [aDecoder decodeObjectForKey:@"dg_name"];
        description = [aDecoder decodeObjectForKey:@"dg_desc"];
        did = [aDecoder decodeObjectForKey:@"dg_did"];
        type = [aDecoder decodeObjectForKey:@"dg_type"];
        models = [aDecoder decodeObjectForKey:@"dg_models"];

        // Set up other, unsaved properties
        
        isExpanded = YES;
        squinted = 0;
        data = nil;
        history = nil;
        mdid = nil;
        cdid = nil;
    }

    return self;
}



- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:type forKey:@"dg_type"];
    [aCoder encodeObject:name forKey:@"dg_name"];
    [aCoder encodeObject:description forKey:@"dg_desc"];
    [aCoder encodeObject:did forKey:@"dg_did"];
    [aCoder encodeObject:models forKey:@"dg_models"];
}



- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    Devicegroup *dgcopy = [[Devicegroup allocWithZone:zone] init];

    dgcopy.type = [self.type mutableCopy];
    dgcopy.name = [self.name mutableCopy];
    dgcopy.description = [self.description mutableCopy];
    dgcopy.did = [self.did mutableCopy];
    dgcopy.models = [self.models mutableCopy];
    dgcopy.data = [self.data mutableCopy];
    dgcopy.history = [self.history mutableCopy];
    dgcopy.squinted = self.squinted;
    dgcopy.mdid = self.mdid;
    dgcopy.cdid = self.cdid;
    dgcopy.isExpanded = self.isExpanded;
    return dgcopy;
}


@end
