

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>
#include <Security/Security.h>
#include <Foundation/Foundation.h>
#include <Sparkle/Sparkle.h>
#include <math.h>
#import "Constants.h"
#import "StatusLight.h"
#import "Project.h"
#import "BuildAPIAccess.h"
#import "VDKQueue.h"
#import "SquinterToolbarItem.h"
#import "StreamToolbarItem.h"
#import "PDKeychainBindings.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, NSOpenSavePanelDelegate, NSFileManagerDelegate, VDKQueueDelegate, NSToolbarDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
{
    // Main UI element outlets
    
    IBOutlet NSTextView *logTextView;
    IBOutlet NSClipView *logClipView;
    IBOutlet NSScrollView *logScrollView;
    IBOutlet StatusLight *saveLight;
    IBOutlet NSProgressIndicator *connectionIndicator;
	IBOutlet NSPopUpButton *projectsPopUp;
	IBOutlet NSPopUpButton *devicesPopUp;

	// File Menu outlets
	
	IBOutlet NSMenuItem *fileSaveMenuItem;
	IBOutlet NSMenuItem *fileSaveAsMenuItem;
    
    // Project Menu outlets

    IBOutlet NSMenu *projectMenu;
    IBOutlet NSMenuItem *squintMenuItem;
    IBOutlet NSMenuItem *uploadMenuItem;
    IBOutlet NSMenuItem *cleanMenuItem;
    IBOutlet NSMenuItem *projectLinkMenuItem;
    IBOutlet NSMenuItem *externalOpenMenuItem;
    IBOutlet NSMenuItem *externalOpenDeviceItem;
    IBOutlet NSMenuItem *externalOpenAgentItem;
    IBOutlet NSMenuItem *externalOpenBothItem;
    IBOutlet NSMenuItem *externalOpenLibItem;
    IBOutlet NSMenuItem *externalOpenFileItem;
    IBOutlet NSMenu *projectsMenu;
    IBOutlet NSMenu *externalLibsMenu;
    IBOutlet NSMenu *externalCodeMenu;
    IBOutlet NSMenu *externalFilesMenu;
	IBOutlet NSMenuItem *copyAgentCodeItem;
	IBOutlet NSMenuItem *copyDeviceCodeItem;
	IBOutlet NSMenuItem *checkElectricImpLibrariesItem;

    // Models Menu

    IBOutlet NSMenu *mainModelsMenu;
    IBOutlet NSMenu *modelsMenu;
    IBOutlet NSMenuItem *showModelInfoMenuItem;
    IBOutlet NSMenuItem *showModelCodeMenuItem;
    IBOutlet NSMenuItem *deleteModelMenuItem;
    IBOutlet NSMenuItem *saveModelProjectMenuItem;
    IBOutlet NSMenuItem *linkMenuItem;
    IBOutlet NSMenuItem *renameModelMenuItem;
    IBOutlet NSMenuItem *assignDeviceModelMenuItem;
	IBOutlet NSMenuItem *restartDevicesModelMenuItem;

    // Device Menu outlet

    IBOutlet NSMenu *deviceMenu;
    IBOutlet NSMenuItem *streamLogsMenuItem;
    IBOutlet NSMenuItem *refreshMenuItem;
    IBOutlet NSMenuItem *showSelectedMenuItem;
    IBOutlet NSMenuItem *copySelectedMenuItem;
    IBOutlet NSMenuItem *unassignSelectedMenuItem;
    IBOutlet NSMenuItem *removeSelectedMenuItem;
    IBOutlet NSMenuItem *getLogsSelectedMenuItem;
    IBOutlet NSMenuItem *restartSelectedMenuItem;
	IBOutlet NSMenuItem *renameDeviceMenuItem;
	IBOutlet NSMenuItem *openAgentURLMenuItem;

    // View Menu outlets
    
    IBOutlet NSMenuItem *logDeviceCodeMenuItem;
    IBOutlet NSMenuItem *logAgentCodeMenuItem;
    IBOutlet NSMenuItem *showHideToolbarMenuItem;

    // File Menu outlets
    
    IBOutlet NSMenuItem *closeAllMenuItem;

    // Help Menu

    IBOutlet NSMenuItem *author01;
    IBOutlet NSMenuItem *author02;
    IBOutlet NSMenuItem *author03;
    IBOutlet NSMenuItem *author04;
	IBOutlet NSMenuItem *author05;
	IBOutlet NSMenuItem *author06;
    
    // Toolbar outlets
    
    IBOutlet NSToolbar *squinterToolbar;
	IBOutlet SquinterToolbarItem *squintItem;
	IBOutlet SquinterToolbarItem *newProjectItem;
	IBOutlet SquinterToolbarItem *infoItem;
	IBOutlet SquinterToolbarItem *openAllItem;
	IBOutlet SquinterToolbarItem *viewDeviceCode;
	IBOutlet SquinterToolbarItem *viewAgentCode;
	IBOutlet SquinterToolbarItem *uploadCodeItem;
	IBOutlet SquinterToolbarItem *restartDevicesItem;
	IBOutlet SquinterToolbarItem *clearItem;
	IBOutlet SquinterToolbarItem *copyDeviceItem;
	IBOutlet SquinterToolbarItem *copyAgentItem;
	IBOutlet SquinterToolbarItem *printItem;
    IBOutlet SquinterToolbarItem *openDeviceCode;
    IBOutlet SquinterToolbarItem *openAgentCode;
    IBOutlet StreamToolbarItem *streamLogsItem;
	IBOutlet SquinterToolbarItem *refreshModelsItem;

	// Sheets, dialogs and windows
    
    // Open
    
    NSOpenPanel *openDialog;
    IBOutlet NSView *accessoryView;
    IBOutlet NSButton *accessoryViewNewProjectCheckbox;

    IBOutlet NSButton *newProjectAccessoryViewFilesCheckbox;
    IBOutlet NSButton *newProjectAccessoryViewOpenCheckbox;
    IBOutlet NSButton *newProjectAccessoryViewAssociateCheckbox;
    IBOutlet NSButton *newProjectAccessoryViewNewModel;

	IBOutlet NSView *projectFromFilesAccessoryView;
	IBOutlet NSButton *projectFromFilesAccessoryViewCheckbox;
	IBOutlet NSButton *projectFromFilesAccessoryViewLocCheckbox;
    
    // Save
    
    NSSavePanel *saveProjectDialog;
    IBOutlet id saveChangesSheet;
    IBOutlet NSTextField *saveChangesSheetLabel;
	BOOL closeProjectFlag;
    
    // New Project
    
    IBOutlet NSPanel *newProjectSheet;
    IBOutlet NSTextField *newProjectTextField;
    IBOutlet NSTextField *newProjectLabel;
    IBOutlet NSTextField *newProjectDirLabel;

	IBOutlet NSPanel *renameProjectSheet;
	IBOutlet NSTextField *renameProjectTextField;
	IBOutlet NSTextField *renameProjectLabel;
    
    // About
    
    IBOutlet id aboutSheet;
    IBOutlet id aboutVersionLabel;
    
    // Prefs
    
    IBOutlet id preferencesSheet;
    IBOutlet NSTextField *workingDirectoryField;
    NSString *workingDirectory;
    IBOutlet NSButton *preserveCheckbox;
	IBOutlet NSButton *autoCompileCheckbox;
	IBOutlet NSSecureTextField *akTextField;
	IBOutlet NSButton *loadModelsCheckbox;
    IBOutlet NSPopUpButton *fontsMenu;
    IBOutlet NSPopUpButton *sizeMenu;
    IBOutlet NSColorWell *textColorWell;
    IBOutlet NSColorWell *backColorWell;
	IBOutlet NSButton *autoSelectDeviceCheckbox;
	IBOutlet NSButton *autoUpdateCheckCheckbox;
	IBOutlet NSButton *boldTestCheckbox;
	IBOutlet NSPopUpButton *locationMenu;

	// Assign Device

	IBOutlet NSPanel *assignDeviceSheet;
	IBOutlet NSPopUpButton *assignDeviceMenuDevices;
	IBOutlet NSPopUpButton *assignDeviceMenuModels;
	
    NSOpenPanel *choosePanel;

    // Rename

    IBOutlet NSPanel *renameSheet;
    IBOutlet NSTextField *renameLabel;
    IBOutlet NSPopUpButton *renameMenu;
    IBOutlet NSTextField *renameName;

	// OaO

	IBOutlet NSPanel *oaoSheet;

	// Connection Variables
    
    BuildAPIAccess *ide;
    NSString *errorMessage;
    NSString *statusMessage;

    // File tracking

    VDKQueue *fileWatchQueue;

	// Models

	NSInteger currentModel, currentDevice;
	Project *savingProject;
	
	// Update Tracking
	
	IBOutlet SUUpdater *sparkler; 

	// Project variables

	NSMutableArray *projectArray;
	NSMutableDictionary *projectDefines;
	Project *currentProject;
	NSString *currentAgentCode, *currentDeviceCode, *toDelete, *itemToCreate;
    NSInteger currentDeviceLibCount, currentAgentLibCount;
    
	// Misc
	
	NSUInteger reDeviceIndex, reModelIndex;
    NSUInteger filesMenuAgentStart, filesMenuDevStart, logPaddingLength;

	BOOL noProjectsFlag, noLibsFlag, sureSheetResult, newModelFlag, autoRenameFlag, showCodeFlag;
	BOOL streamFlag, menuValid, restartFlag, fromDeviceSelectFlag, saveProjectSubFilesFlag;
    BOOL isLightThemeFlag, unassignDeviceFlag, requiresAllowedAnywhereFlag;
	BOOL checkModelsFlag, newProjectFlag;

    NSMutableArray *foundLibs, *foundFiles, *foundEILibs, *colors, *logColors;

    NSDateFormatter *def;

    NSColor *backColour, *textColour;

	NSOperationQueue *extraOpQueue;
	NSString *listString;

	NSDictionary *cDevice, *cModel;

	NSURLSessionTask *eiLibListTask;
	NSMutableData *eiLibListData;
	NSDate *eiLibListTime;

	NSOperatingSystemVersion sysVer;
}


@property (assign) IBOutlet NSWindow *window;


// New Project Methods

- (IBAction)newProject:(id)sender;
- (IBAction)newProjectSheetCancel:(id)sender;
- (IBAction)newProjectSheetCreate:(id)sender;

// Choose and Open Project Methods

- (void)chooseProject:(id)sender;
- (IBAction)pickProject:(id)sender;
- (IBAction)openProject:(id)sender;
- (IBAction)selectFile:(id)sender;
- (IBAction)selectFileForProject:(id)sender;
- (void)presentOpenFilePanel:(NSInteger)openActionType;

- (void)openFileHandler:(NSArray *)urls :(NSInteger)openActionType;
- (void)processAddedFiles:(NSArray *)urls :(NSUInteger)count;
- (void)processAddedDeviceFile:(NSString *)filePath;
- (void)processAddedAgentFile:(NSString *)filePath;
- (void)processAddedNewProject;
- (void)processAddedNewProjectStageTwo;
- (void)renameProject;
- (IBAction)closeRenameProjectSheet:(id)sender;
- (IBAction)saveRenameProjectSheet:(id)sender;

- (void)openSquirrelProjects:(NSArray *)urls :(NSInteger)count;
- (NSInteger)compareVersion:(NSString *)newVersion :(NSString *)oldVersion;
- (BOOL)checkProjectNames:(Project *)byProject :(NSString *)orProjectName;
- (BOOL)checkProjectPaths:(Project *)byProject :(NSString *)orProjectPath;
- (BOOL)checkFile:(NSString *)filePath;
- (void)presentUpdateAlert:(NSArray *)urls :(NSInteger)count :(Project *)aProject;

// Save Project Methods

- (IBAction)saveProjectAs:(id)sender;
- (IBAction)saveProject:(id)sender;
- (void)savePrep:(NSURL *)saveDirectory :(NSString *)newFileName;
- (IBAction)cancelChanges:(id)sender;
- (IBAction)ignoreChanges:(id)sender;
- (IBAction)saveChanges:(id)sender;

// Close Project Methods

- (IBAction)closeProject:(id)sender;

// Squint Methods

- (IBAction)squint:(id)sender;
- (void)squintr;
- (void)processLibraries;
- (void)addFileWatchPaths:(NSArray *)paths;
- (NSString *)processSource:(NSString *)codePath :(NSUInteger)codeType :(BOOL)willReturnCode;
- (void)processRequires:(NSString *)sourceCode;
- (NSString *)processImports:(NSString *)sourceCode :(NSString *)searchString :(NSUInteger)codeType :(BOOL)willReturnCode;
- (NSString *)processDefines:(NSString *)sourceCode :(NSInteger)codeType;
- (NSUInteger)getLineNumber:(NSString *)code :(NSInteger)index;
- (NSString *)getLibraryVersionNumber:(NSString *)libcode;

// Library and Project Menu Methods

- (IBAction)cleanProject:(id)sender;
- (void)cleanProjectTwo;
- (void)updateLibraryMenu;
- (void)libAdder:(NSArray *)keyArray;
- (void)addLibraryToMenu:(NSString *)libName :(BOOL)isEILib;
- (void)updateFilesMenu;
- (void)fileAdder:(NSArray *)keyArray;
- (void)addFileToMenu:(NSString *)filename;
- (NSString *)getLibraryTitle:(id)item;
- (void)launchLibsPage;
- (BOOL)addProjectMenuItem:(NSString *)menuItemTitle :(Project *)aProject;

// Pasteboard Methods

- (IBAction)copyDeviceCodeToPasteboard:(id)sender;
- (IBAction)copyAgentCodeToPasteboard:(id)sender;
- (IBAction)copyAgentURL:(id)sender;

// Model and Device Methods

- (IBAction)getProjectsFromServer:(id)sender;
- (void)getApps;
- (void)listModels;
- (void)chooseModel:(id)sender;
- (IBAction)modelToProjectStageOne:(id)sender;
- (void)modelToProjectStageTwo;
- (void)createdModel;
- (IBAction)uploadCode:(id)sender;
- (void)uploadCodeStageTwo;
- (IBAction)refreshDevices:(id)sender;
- (void)listDevices;
- (IBAction)chooseDevice:(id)sender;
// - (void)setCurrentDeviceFromSelection:(id)sender;
- (IBAction)restartDevice:(id)sender;
- (IBAction)restartDevices:(id)sender;
- (void)restarted;
- (IBAction)assignProject:(id)sender;
- (IBAction)assignDevice:(id)sender;
- (IBAction)assignDeviceSheetCancel:(id)sender;
- (IBAction)assignDeviceSheetAssign:(id)sender;
- (void)reassigned;
- (IBAction)deleteModel:(id)sender;
- (void)deleteModelStageTwo;
- (IBAction)deleteDevice:(id)sender;
- (void)deleteDeviceStageTwo;
- (IBAction)renameModel:(id)sender;
- (void)renameModelStageTwo;
- (IBAction)renameDevice:(id)sender;
- (IBAction)closeRenameSheet:(id)sender;
- (IBAction)saveRenameSheet:(id)sender;
- (void)renameDeviceStageTwo;
- (IBAction)unassignDevice:(id)sender;

// API Log methods

- (IBAction)getLogs:(id)sender;
- (void)listLogs:(NSNotification *)note;
- (void)logLogs:(NSString *)logLine;
- (void)parseLog;
- (IBAction)printLog:(id)sender;
- (void)printDone;
- (IBAction)streamLogs:(id)sender;
- (void)presentLogEntry:(NSNotification *)note;
- (void)endLogging:(NSNotification *)note;
- (IBAction)showAppCode:(id)sender;
- (void)listCode:(NSString *)code :(NSInteger)from :(NSInteger)to :(NSInteger)at;
- (void)logCode;

// Squinter Log Methods

- (IBAction)getProjectInfo:(id)sender;
- (NSString *)getDisplayPath:(NSString *)path;
- (IBAction)showDeviceInfo:(id)sender;
- (void)printInfoInLog:(NSMutableArray *)lines;
- (IBAction)showModelInfo:(id)sender;
- (IBAction)logDeviceCode:(id)sender;
- (IBAction)logAgentCode:(id)sender;
- (void)writeToLog:(NSString *)string :(BOOL)addTimestamp;
- (void)writeStreamToLog:(NSAttributedString *)string;
- (IBAction)clearLog:(id)sender;
- (void)displayError;
- (void)listCodeErrors:(NSString *)code :(NSString *)codeKind;

// Model and Device ID Look-up Methods

- (NSString *)getDeviceID:(NSInteger)index;
- (NSString *)getModelID:(NSInteger)index;

// External Editor Methods

- (IBAction)externalOpen:(id)sender;
- (IBAction)externalLibOpen:(id)sender;
- (IBAction)externalFileOpen:(id)sender;
- (IBAction)externalOpenAll:(id)sender;
- (IBAction)openAgentURL:(id)sender;

// Preferences Methods

- (IBAction)showPrefs:(id)sender;
- (IBAction)cancelPrefs:(id)sender;
- (IBAction)setPrefs:(id)sender;
- (IBAction)chooseWorkingDirectory:(id)sender;
- (void)setWorkingDirectory:(NSArray *)urls;
- (NSString *)getFontName:(NSInteger)index;
- (void)showPanelForText;
- (void)showPanelForBack;

// About and Help Sheet Methods

- (IBAction)showAboutSheet:(id)sender;
- (IBAction)closeAboutSheet:(id)sender;
- (IBAction)showHideToolbar:(id)sender;
- (IBAction)showAuthor:(id)sender;

// UI Update Methods

- (void)updateMenus;
- (void)setDeviceMenu;
- (void)setModelsMenu;
- (void)setProjectMenu;
- (void)setViewMenu;
- (void)setProjectLists;
- (void)updateDeviceLists;
- (NSString *)menuString:(NSString *)deviceID;
- (void)setToolbar;
- (void)setColours;
- (void)setLoggingColours;
- (NSInteger)perceivedBrightness:(NSColor *)colour;
- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold;

// Progress Methods

- (void)startProgress;
- (void)stopProgress;

// Misc

- (NSData *)bookmarkForURL:(NSURL *)url;
- (NSURL *)urlForBookmark:(NSData *)bookmark;

// Library Checking

- (IBAction)checkElectricImpLibraries:(id)sender;
- (void)checkElectricImpLibs;
- (void)compareElectricImpLibs;

// File Path Methods

- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath;
- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath;
- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath;
- (void)updateProject:(Project *)project;
- (void)updatePaths:(NSMutableDictionary *)set :(NSString *)relPath;

// OaO

- (void)openOaO;
- (IBAction)closeOaO:(id)sender;

@end
