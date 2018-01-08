

//  Created by Tony Smith on 05/04/2017.
//  Copyright (c) 2014-18 Tony Smith. All rights reserved.
//

#import "File.h"

@implementation File

@synthesize path, filename, type, version, hasMoved;


- (instancetype)init
{
    if (self = [super init])
    {
        path = @"";
        filename = @"";
        type = @"";
        version = @"";
        hasMoved = NO;
    }

    return self;
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        filename = [aDecoder decodeObjectForKey:@"file_name"];
        path = [aDecoder decodeObjectForKey:@"file_path"];
        type = [aDecoder decodeObjectForKey:@"file_type"];
        version = [aDecoder decodeObjectForKey:@"file_version"];
    }

    return self;
}



- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:type forKey:@"file_type"];
    [aCoder encodeObject:filename forKey:@"file_name"];
    [aCoder encodeObject:path forKey:@"file_path"];
    [aCoder encodeObject:version forKey:@"file_version"];
}



- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    File *filecopy = [[File allocWithZone:zone] init];

    filecopy.type = [self.type mutableCopy];
    filecopy.filename = [self.filename mutableCopy];
    filecopy.path = [self.path mutableCopy];
    filecopy.version = [self.version mutableCopy];
    filecopy.hasMoved = self.hasMoved;

    return filecopy;
}


@end
