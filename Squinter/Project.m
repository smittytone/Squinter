

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-18 Tony Smith. All rights reserved.


#import "Project.h"


@implementation Project


@synthesize name, description, pid, version, updated, devicegroups;
@synthesize path, filename, haschanged, devicegroupIndex, count;


- (instancetype)init
{
    if (self = [super init])
    {
        [self setDefaults];
    }

    return self;
}


- (void)setDefaults
{
    version = kSquinterCurrentVersion;
    name = @"";
    description = @"";
    pid = @"";
    devicegroups = nil;
    path = @"";
    filename = @"";

    haschanged = NO;
    devicegroupIndex = -1;
    count = 0;

    // Set the update time

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-mm-DD'T'hh:mm:ss.sZ"];
    updated = [dateFormatter stringFromDate:[NSDate date]];
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        // Set the loaded project's default values

        [self setDefaults];

        // Read in the saved project version, so check if the project is old and thus needs special handling
        // NOTE Special cases are 'projectVersion' < 3.0 and 'projectVersion' is nil

        NSString *projectVersion = [aDecoder decodeObjectForKey:@"project_version"];
        NSInteger major = 1;
        NSInteger minor = 0;

        if (projectVersion != nil)
        {
            NSArray *parts = [projectVersion componentsSeparatedByString:@"."];
            major = [[parts objectAtIndex:0] integerValue];
            minor = [[parts objectAtIndex:1] integerValue];

            if (major == 3)
            {
                // Project is a 3.x project so load it up

                version = projectVersion;
                name = [aDecoder decodeObjectForKey:@"project_name"];
                description = [aDecoder decodeObjectForKey:@"project_desc"];
                pid = [aDecoder decodeObjectForKey:@"project_pid"];
                devicegroups = [aDecoder decodeObjectForKey:@"project_devicegroups"];
                path = [aDecoder decodeObjectForKey:@"project_path"];
                filename = [aDecoder decodeObjectForKey:@"project_filename"];
                updated = [aDecoder decodeObjectForKey:@"project_updated"];

                // Set up other, unsaved properties

                haschanged = NO;

                // And return the loaded project

                return self;
            }
        }

        // Project is pre-Squinter 3.0, so must be converted.
        // Read in what data we can that makes sense to do so: the agent and device
        // code paths, which can be added to a model as its own code path. The model
        // is added to a new device group

        NSString *projectAgentCodePath = [aDecoder decodeObjectForKey:@"project_agent_path"];
        NSString *projectDeviceCodePath = [aDecoder decodeObjectForKey:@"project_device_path"];

        name = [aDecoder decodeObjectForKey:@"project_name"];
        devicegroups = [[NSMutableArray alloc] init];
        devicegroupIndex = -1;

        NSInteger files = 0;

        if (projectAgentCodePath != nil)
        {
            [devicegroups addObject:projectAgentCodePath];
            files = 2;
        }

        if (projectDeviceCodePath != nil)
        {
            [devicegroups addObject:projectDeviceCodePath];
            files = files + 1;
        }

        description = [NSString stringWithFormat:@"%li", (long)files];
        version = [NSString stringWithFormat:@"%li.%li", (long)major, (long)minor];
        pid = @"old";
    }

    return self;
}



- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:version forKey:@"project_version"];
    [aCoder encodeObject:name forKey:@"project_name"];
    [aCoder encodeObject:description forKey:@"project_desc"];
    [aCoder encodeObject:pid forKey:@"project_pid"];
    [aCoder encodeObject:devicegroups forKey:@"project_devicegroups"];
    [aCoder encodeObject:updated forKey:@"project_updated"];
    [aCoder encodeObject:filename forKey:@"project_filename"];
    [aCoder encodeObject:path forKey:@"project_path"];

}



- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    Project *projectCopy = [[Project allocWithZone:zone] init];

    projectCopy.version = [self.version mutableCopy];
    projectCopy.updated = [self.updated mutableCopy];
    projectCopy.name = [self.name mutableCopy];
    projectCopy.description = [self.description mutableCopy];
    projectCopy.pid = [self.pid mutableCopy];
    projectCopy.path = [self.path mutableCopy];
    projectCopy.devicegroups = [self.devicegroups mutableCopy];
    projectCopy.filename = [self.filename mutableCopy];
    projectCopy.haschanged = self.haschanged;
    projectCopy.devicegroupIndex = self.devicegroupIndex;
    projectCopy.count = self.count;

    return projectCopy;
}


@end
