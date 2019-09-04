

//  Created by Tony Smith
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Project.h"
#import "Devicegroup.h"
#import "Model.h"
#import "File.h"
#import "InspectorDataCellView.h"
#import "TreeNode.h"


@interface InspectorViewController : NSViewController <NSOutlineViewDelegate,
                                                       NSOutlineViewDataSource>
{
    IBOutlet NSOutlineView *deviceOutlineView;
    IBOutlet NSTextField *field;
    IBOutlet NSTextField *subfield;
    IBOutlet NSImageView *image;
    // ADDED 2.3.131
    IBOutlet NSButton *deviceViewButton;
    IBOutlet NSButton *projectViewButton;

    NSMutableArray *projectData, *deviceData;
    NSMutableArray *deviceKeys, *deviceValues;

    NSWorkspace *nswsw;

    NSDateFormatter *inLogDef, *outLogDef;
    
    BOOL isInForeground;
}


- (void)link:(id)sender;
- (void)goToURL:(id)sender;
- (void)setProject:(Project *)aProject;
- (void)setDevice:(NSMutableDictionary *)aDevice;
- (void)setTab:(NSUInteger)aTab;

- (BOOL)isLinkRow:(TreeNode *)node;

- (NSString *)getDisplayPath:(NSString *)path;
- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath;
- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath;
- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath;
- (NSInteger)numberOfFoldersInPath:(NSString *)path;

- (Devicegroup *)getDevicegroupWithID:(NSString *)dgID;
- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back;
- (void)setNilProject;
- (void)setNilDevice;
- (void)showNilItems:(BOOL)shouldShow;

- (CGFloat)renderedHeightOfString:(NSString *)string :(NSInteger)width;
- (IBAction)switchTable:(id)sender;


@property (nonatomic, strong, setter=setProject:) Project *project;
@property (nonatomic, strong, setter=setDevice:) NSMutableDictionary *device;
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) NSMutableArray *projectArray;
@property (nonatomic, strong) NSMutableArray *loggingDevices;
@property (nonatomic, readwrite) NSUInteger tabIndex;
@property (nonatomic, readwrite) NSUInteger pathType;


@end

