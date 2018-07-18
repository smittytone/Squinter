

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017-18 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Project.h"
#import "Devicegroup.h"
#import "Model.h"
#import "File.h"
#import "InspectorDataCellView.h"
#import "TreeNode.h"


@interface InspectorWindow2ViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>

{
    IBOutlet NSOutlineView *deviceOutlineView;
    IBOutlet NSSegmentedControl *panelSelector;
    IBOutlet NSTextField *field;

    NSMutableArray *projectData;
    NSMutableArray *deviceKeys, *deviceValues;

    NSWorkspace *nswsw;

    NSDateFormatter *inLogDef, *outLogDef;
}


- (void)appWillBecomeActive;
- (void)link:(id)sender;
- (void)goToURL:(id)sender;
- (void)setProject:(Project *)aProject;
- (void)setDevice:(NSMutableDictionary *)aDevice;
- (void)positionWindow;
- (void)setTab:(NSUInteger)aTab;

- (BOOL)isLinkRow:(TreeNode *)node;
- (BOOL)isURLRow:(NSInteger)row;

- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath;
- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath;
- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath;
- (NSInteger)numberOfFoldersInPath:(NSString *)path;
- (CGFloat)renderedHeightOfString:(NSString *)string;
- (IBAction)switchTable:(id)sender;


@property (nonatomic, strong, setter=setProject:) Project *project;
@property (nonatomic, strong, setter=setDevice:) NSMutableDictionary *device;
@property (nonatomic, strong) NSMutableArray *products;
//@property (nonatomic, strong) NSMutableArray *devices;
@property (nonatomic, readwrite) NSRect mainWindowFrame;
@property (nonatomic, readwrite) NSUInteger tabIndex;


@end

