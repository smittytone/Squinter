

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-17 Tony Smith. All rights reserved.


#import <Foundation/Foundation.h>
#import "Constants.h"


@interface Project : NSObject <NSCoding>


- (void)setDefaults;


// Data structure for Projects, which is NSCoding-compliant for saving

// Properties that ARE saved

@property (nonatomic, strong) NSString *name;                       // Project's name
@property (nonatomic, strong) NSString *description;                // Project description
@property (nonatomic, strong) NSString *pid;                        // ID of project's parent Product
@property (nonatomic, strong) NSString *version;                    // Project version number
@property (nonatomic, strong) NSString *updated;                    // The project was created/updated at...
@property (nonatomic, strong) NSMutableArray *devicegroups;         // The project's device groups
@property (nonatomic, strong) NSString *path;                       // Project’s ABSOLUTE location on local storage
@property (nonatomic, strong) NSString *filename;                   // Project’s filename on local storage
                                                                    // NOTE path + / + filename = full path string

// Properties that are NOT saved

@property (nonatomic, assign) NSInteger devicegroupIndex;           // Currently selected devicegroup
@property (nonatomic, assign) BOOL haschanged;                      // Has the project changed in any way, ie. does it need saving?
@property (nonatomic, assign) NSInteger count;                      // Used for uploading/downloading projects

@end
