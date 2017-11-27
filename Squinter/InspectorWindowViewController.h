

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Project.h"
#import "Devicegroup.h"
#import "Model.h"
#import "File.h"


@interface InspectorWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

{
	IBOutlet NSTableView *infoTable;

	NSMutableArray *keys, *values;
}


- (void)setProject:(Project *)aProject;
- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath;


@property (nonatomic, strong, setter=setProject:) Project *project;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) NSMutableArray *devices;


@end
