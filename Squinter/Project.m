

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-16 Tony Smith. All rights reserved.


#import "Project.h"


@implementation Project


@synthesize projectName, projectPath, projectAgentCodePath, projectDeviceCodePath;
@synthesize projectDeviceLibraries, projectAgentLibraries;
@synthesize projectDeviceFiles, projectAgentFiles;
@synthesize projectDeviceCode, projectAgentCode, projectVersion;
@synthesize projectSquinted, projectHasChanged, projectModelID, projectImpLibs;
@synthesize oldProjectPath;


- (instancetype)init
{
    if (self = [super init])
    {
        projectSquinted = 0;
        projectHasChanged = NO;
        projectVersion = @"2.1";
		projectModelID = nil;
    }

    return self;
}



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
	{
        projectVersion = [aDecoder decodeObjectForKey:@"project_version"];
        if (projectVersion == nil) projectVersion = @"1.0";

		projectName = [aDecoder decodeObjectForKey:@"project_name"];
        projectAgentCodePath = [aDecoder decodeObjectForKey:@"project_agent_path"];
        projectDeviceCodePath = [aDecoder decodeObjectForKey:@"project_device_path"];
        projectDeviceLibraries = [aDecoder decodeObjectForKey:@"project_device_libraries"];
        projectAgentLibraries = [aDecoder decodeObjectForKey:@"project_agent_libraries"];
		projectDeviceFiles = [aDecoder decodeObjectForKey:@"project_device_files"];
		projectAgentFiles = [aDecoder decodeObjectForKey:@"project_agent_files"];
		projectModelID = [aDecoder decodeObjectForKey:@"project_model_number"];
        projectImpLibs = [aDecoder decodeObjectForKey:@"project_imp_libraries"];

		// Add Version 2.1+ entities

		if (projectVersion.floatValue > 2.0)
		{
			oldProjectPath = [aDecoder decodeObjectForKey:@"project_old_path"];
		}

		// Set up other, unsaved properties
		
		projectSquinted = 0;
        projectDeviceCode = nil;
        projectAgentCode = nil;
        projectHasChanged = NO;
    }
    
    return self;
}



- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:projectVersion forKey:@"project_version"];
    [aCoder encodeObject:projectName forKey:@"project_name"];
    [aCoder encodeObject:projectAgentCodePath forKey:@"project_agent_path"];
    [aCoder encodeObject:projectDeviceCodePath forKey:@"project_device_path"];
    [aCoder encodeObject:projectDeviceLibraries forKey:@"project_device_libraries"];
    [aCoder encodeObject:projectAgentLibraries forKey:@"project_agent_libraries"];
	[aCoder encodeObject:projectDeviceFiles forKey:@"project_device_files"];
	[aCoder encodeObject:projectAgentFiles forKey:@"project_agent_files"];
	[aCoder encodeObject:projectModelID forKey:@"project_model_number"];
	[aCoder encodeObject:projectImpLibs forKey:@"project_imp_libraries"];

	// Add Version 2.1+ entities

	if (projectVersion.floatValue > 2.0)
	{
		[aCoder encodeObject:oldProjectPath forKey:@"project_old_path"];
	}
}



- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    Project *projectCopy = [[Project allocWithZone:zone] init];
    
    projectCopy.projectName = [self.projectName mutableCopy];
    projectCopy.projectVersion = [self.projectVersion mutableCopy];
    projectCopy.projectPath = [self.projectPath mutableCopy];
    projectCopy.projectAgentCodePath = [self.projectAgentCodePath mutableCopy];
    projectCopy.projectDeviceCodePath = [self.projectDeviceCodePath mutableCopy];
    projectCopy.projectDeviceLibraries = [self.projectDeviceLibraries mutableCopy];
    projectCopy.projectAgentLibraries = [self.projectAgentLibraries mutableCopy];
    projectCopy.projectDeviceFiles = [self.projectDeviceFiles mutableCopy];
    projectCopy.projectAgentFiles = [self.projectAgentFiles mutableCopy];
    projectCopy.projectAgentCode = [self.projectAgentCode mutableCopy];
    projectCopy.projectDeviceCode = [self.projectDeviceCode mutableCopy];
	projectCopy.projectImpLibs = [self.projectImpLibs mutableCopy];
    projectCopy.projectSquinted = self.projectSquinted;
    projectCopy.projectHasChanged = self.projectHasChanged;
	projectCopy.projectModelID = self.projectModelID;

	// Add Version 2.1+ entities
	
	if (projectVersion.floatValue > 2.0)
	{
		projectCopy.oldProjectPath = [self.oldProjectPath mutableCopy];
	}
    
    return projectCopy;
}


@end
