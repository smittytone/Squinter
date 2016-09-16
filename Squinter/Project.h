

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-16 Tony Smith. All rights reserved.


#import <Foundation/Foundation.h>


@interface Project : NSObject <NSCoding>

// Data structure for Projects which is NSCoding-compliant for saving

// Properties that ARE saved

@property (nonatomic, strong) NSString *projectVersion;                     // Project Object Version (used for release checking)
@property (nonatomic, strong) NSString *projectName;                        // Project's name
@property (nonatomic, strong) NSString *projectAgentCodePath;               // Location of the core agent code file
@property (nonatomic, strong) NSString *projectDeviceCodePath;              // Location of the core device code file
@property (nonatomic, strong) NSString *projectModelID;                     // ID of project's associated model
@property (nonatomic, strong) NSMutableDictionary *projectDeviceLibraries;  // Names, paths of local libraries #imported into device code
@property (nonatomic, strong) NSMutableDictionary *projectAgentLibraries;   // Names, paths of local libraries #imported into agent code
@property (nonatomic, strong) NSMutableDictionary *projectDeviceFiles;      // Names, paths of local files #imported into device code
@property (nonatomic, strong) NSMutableDictionary *projectAgentFiles;       // Names, paths of local files #imported into agent code
@property (nonatomic, strong) NSMutableArray *projectImpLibs;               // Names of EI libraries #required by either agent or device

// Properties that are NOT saved

@property (nonatomic, strong) NSString *projectPath;                        // Project’s location on local storage
@property (nonatomic, strong) NSString *projectAgentCode;                   // Compiled agent code
@property (nonatomic, strong) NSString *projectDeviceCode;                  // Compiled device code
@property (nonatomic, assign) char projectSquinted;                         // Bitfield indicating compilation status
@property (nonatomic, assign) bool projectHasChanged;                       // Has the project changed in any way, ie. does it need saving?


@end