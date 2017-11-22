

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-17 Tony Smith. All rights reserved.


#import "Model.h"


@implementation Model


@synthesize code, type, libraries, files, impLibraries, squinted, path, filename, sha, updated, hasMoved;


- (instancetype)init
{
    if (self = [super init])
    {
        code = @"";
        type = @"";
        path = @"";
        filename = @"";
        sha = @"";
        updated = @"";
        libraries = nil;
        files = nil;
        impLibraries = nil;
        squinted = NO;
        hasMoved = NO;
    }

    return self;
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        filename = [aDecoder decodeObjectForKey:@"mod_name"];
        path = [aDecoder decodeObjectForKey:@"mod_path"];
        type = [aDecoder decodeObjectForKey:@"mod_type"];
        sha = [aDecoder decodeObjectForKey:@"mod_sha"];
        updated = [aDecoder decodeObjectForKey:@"mod_time"];
        libraries = [aDecoder decodeObjectForKey:@"mod_libs"];
        files = [aDecoder decodeObjectForKey:@"mod_files"];

        // Set up other, unsaved properties

        squinted = NO;
        hasMoved = NO;
        code = @"";
    }

    return self;
}



- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:type forKey:@"mod_type"];
    [aCoder encodeObject:filename forKey:@"mod_name"];
    [aCoder encodeObject:path forKey:@"mod_path"];
    [aCoder encodeObject:sha forKey:@"mod_sha"];
    [aCoder encodeObject:updated forKey:@"mod_time"];
    [aCoder encodeObject:libraries forKey:@"mod_libs"];
    [aCoder encodeObject:files forKey:@"mod_files"];
}



- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    Model *modcopy = [[Model allocWithZone:zone] init];

    modcopy.type = [self.type mutableCopy];
    modcopy.filename = [self.filename mutableCopy];
    modcopy.code = [self.code mutableCopy];
    modcopy.path = [self.path mutableCopy];
    modcopy.sha = [self.sha mutableCopy];
    modcopy.updated = [self.updated mutableCopy];
    modcopy.libraries = [self.libraries mutableCopy];
    modcopy.files = [self.files mutableCopy];
    modcopy.impLibraries = [self.impLibraries mutableCopy];
    modcopy.squinted = self.squinted;
    modcopy.hasMoved = self.hasMoved;

    return modcopy;
}


@end
