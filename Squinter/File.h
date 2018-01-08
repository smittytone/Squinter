

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-18 Tony Smith. All rights reserved.


#import <Foundation/Foundation.h>


@interface File : NSObject <NSCoding>

// Data structure for Projects, which is NSCoding-compliant for saving

// Properties that ARE saved

@property (nonatomic, strong) NSString *path;               // The location of the source file
@property (nonatomic, strong) NSString *filename;           // The name of the source file
@property (nonatomic, strong) NSString *version;            // The version of the source file, using static VERSION =
                                                            // "x.y.z"
@property (nonatomic, strong) NSString *type;               // The source code type: "file" or "library"

// Properties that are NOT saved

@property (nonatomic, readwrite) BOOL hasMoved;             // The file has moved (detected during compilation)


@end
