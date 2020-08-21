

//  Created by Tony Smith on 6 May 2019.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUI.h"
#import "AppDelegateSquinting.h"


@interface AppDelegate(AppDelegateFileHandlers)

// File Opening Methods
- (void)presentOpenFilePanel:(NSInteger)openActionType;
- (void)openFileHandler:(NSArray *)urls :(NSInteger)openActionType;

// Open Squirrel Projects Methods
- (void)openSquirrelProjects:(NSMutableArray *)urls;
- (void)checkFiles:(File *)file :(NSString *)oldPath :(NSString *)type :(Devicegroup *)devicegroup :(BOOL)projectMoved;
- (BOOL)checkProjectPaths:(Project *)byProject :(NSString *)orProjectPath;
- (BOOL)checkProjectNames:(Project *)byProject :(NSString *)orName;

// Add model files to Device Groups Methods
- (IBAction)selectFile:(id)sender;
- (IBAction)newDevicegroupCheckboxHander:(id)sender;
- (IBAction)endSourceTypeSheet:(id)sender;
- (IBAction)cancelSourceTypeSheet:(id)sender;
- (void)processAddedFiles:(NSMutableArray *)urls;
- (void)processAddedFilesStageTwo:(NSMutableArray *)urls :(NSString *)fileType;

// Project Saving Methods
- (IBAction)saveProjectAs:(id)sender;
- (IBAction)saveProject:(id)sender;
- (void)savePrep:(NSURL *)saveDirectory :(NSString *)newFileName;

// Unsaved Changes Sheet Methods
- (IBAction)cancelChanges:(id)sender;
- (IBAction)ignoreChanges:(id)sender;
- (IBAction)saveChanges:(id)sender;

// Save Individual Model Files Methods
- (void)saveModelFiles:(Project *)project;
- (void)saveFiles:(NSMutableArray *)files :(Project *)project;
- (void)showFileSavePanel:(NSString *)path :(NSMutableArray *)files :(Project *)project;
- (void)doneSaving:(Project *)project;


@end
