

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
- (void)positionWindow;
- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath;
- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath;
- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath;
- (NSInteger)numberOfFoldersInPath:(NSString *)path;
- (CGFloat)widthOfString:(NSString *)string;


@property (nonatomic, strong, setter=setProject:) Project *project;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, readwrite) NSRect mainWindowFrame;


@end
