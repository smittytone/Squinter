

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-17 Tony Smith. All rights reserved.


#import <Foundation/Foundation.h>


@interface Model : NSObject <NSCoding>

// Data structure for Projects, which is NSCoding-compliant for saving

// Properties that ARE saved

@property (nonatomic, strong) NSString *path;               // The location of the source file
@property (nonatomic, strong) NSString *filename;           // The name of the source file
@property (nonatomic, strong) NSString *type;               // The source code type: "agent" or "device"
@property (nonatomic, strong) NSMutableArray *files;        // The source code's included files as of the last compile
@property (nonatomic, strong) NSMutableArray *libraries;    // The source code's required libs as of the last compile

@property (nonatomic, strong) NSString *sha;                // The deployment SHA (NOTE shared between agent and device)
@property (nonatomic, strong) NSString *updated;            // The UTC timestamp returned by the server

// Properties that ARE NOT saved

@property (nonatomic, strong) NSString *code;               // Model's loaded/compiled source
@property (nonatomic, readwrite) BOOL squinted;             // The model's compilation status
@property (nonatomic, strong) NSMutableArray *impLibraries; // The source code's required libs as of the last compile
@property (nonatomic, readwrite) BOOL hasMoved;             // The source code file has moved / project has moved

@end
