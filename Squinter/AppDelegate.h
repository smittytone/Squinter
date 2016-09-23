

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>
#include <Security/Security.h>
#include <Foundation/Foundation.h>
#include <Sparkle/Sparkle.h>
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
    IBOutlet NSButton *accessoryViewCheckbox;

    IBOutlet NSButton *newProjectAccessoryViewFilesCheckbox;
    IBOutlet NSButton *newProjectAccessoryViewOpenCheckbox;
    IBOutlet NSButton *newProjectAccessoryViewAssociateCheckbox;
    IBOutlet NSButton *newProjectAccessoryViewNewModel;
    
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

	NSMutableArray *projectArray, *projectIncludes;
	NSMutableDictionary *projectDefines;
	Project *currentProject;
	NSString *currentAgentCode, *currentDeviceCode, *toDelete, *itemToCreate;
    NSInteger currentDeviceLibCount, currentAgentLibCount;
    
	// Misc
	
	NSUInteger reDeviceIndex, reModelIndex;
    NSUInteger filesMenuAgentStart, filesMenuDevStart, logPaddingLength;
	BOOL noProjectsFlag, noLibsFlag, sureSheetResult, newModelFlag, autoRenameFlag, showCodeFlag;
	BOOL streamFlag, menuValid, restartFlag, fromDeviceSelectFlag, saveProjectSubFilesFlag;
    BOOL isLightThemeFlag, selectDeviceFlag, unassignDeviceFlag, requiresAllowedAnywhereFlag;
	BOOL checkModelsFlag;

    NSMutableArray *foundLibs, *foundFiles, *colors, *logColors;

    NSDateFormatter *def;

    NSColor *backColour, *textColour;

	NSOperationQueue *extraOpQueue;
	NSString *listString;

	NSDictionary *cDevice, *cModel;

	NSURLSessionTask *listTask;
	NSMutableData *listData;
}


@property (assign) IBOutlet NSWindow *window;


// New Project Methods

- (IBAction)newProject:(id)sender;
- (IBAction)newProjectSheetCancel:(id)sender;
- (IBAction)newProjectSheetCreate:(id)sender;

// Choose and Open Project Methods

- (void)chooseProject:(id)sender;
- (IBAction)pickProject:(id)sender;
- (IBAction)selectFile:(id)sender;
- (IBAction)openProject:(id)sender;
- (IBAction)selectFileForProject:(id)sender;
- (void)openFile:(NSInteger)operationType;
- (BOOL)openFileHandler:(NSArray *)urls :(NSInteger)openActionType;

// Save Project Methods

- (IBAction)saveProject:(id)sender;
- (IBAction)saveProjectAs:(id)sender;
- (void)savePrep:(NSURL *)saveDirectory :(NSString *)newFileName;

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

// Library and Project Menu Methods

- (IBAction)cleanProject:(id)sender;
- (void)cleanProjectTwo;
- (void)updateLibraryMenu;
- (void)libAdder:(NSArray *)keyArray;
- (void)addLibraryToMenu:(NSString *)libName :(BOOL)isEILib;
- (void)updateFilesMenu;
- (void)fileAdder:(NSArray *)keyArray;
- (void)addFileToMenu:(NSString *)filename;
- (BOOL)addProjectMenuItem:(NSString *)menuItemTitle;
- (void)launchLibsPage;
- (NSString *)getLibraryTitle:(id)item;

// Pasteboard Methods

- (IBAction)copyDeviceCodeToPasteboard:(id)sender;
- (IBAction)copyAgentCodeToPasteboard:(id)sender;

// Model and Device Methods

- (IBAction)getProjectsFromServer:(id)sender;
- (void)getApps;
- (void)listModels;
- (void)chooseModel:(id)sender;
- (IBAction)modelToProjectStageOne:(id)sender;
- (void)modelToProjectStageTwo;
- (void)uploadCodeStageTwo;
- (IBAction)uploadCode:(id)sender;
- (IBAction)refreshDevices:(id)sender;
- (void)listDevices;
- (IBAction)chooseDevice:(id)sender;
- (void)setCurrentDeviceFromSelection:(id)sender;
- (IBAction)restartDevices:(id)sender;
- (IBAction)restartDevice:(id)sender;
- (void)restarted;
- (IBAction)assignProject:(id)sender;
- (IBAction)assignDevice:(id)sender;
- (IBAction)assignDeviceSheetCancel:(id)sender;
- (IBAction)assignDeviceSheetAssign:(id)sender;
- (void)reassigned;
- (IBAction)deleteDevice:(id)sender;
- (void)deleteDeviceStageTwo;
- (IBAction)deleteModel:(id)sender;
- (void)deleteModelStageTwo;
- (IBAction)renameModel:(id)sender;
- (void)renameModelStageTwo;
- (void)createdModel;
- (IBAction)renameDevice:(id)sender;
- (void)renameDeviceStageTwo;
- (IBAction)unassignDevice:(id)sender;

// API Log methods

- (IBAction)getLogs:(id)sender;
- (void)listLogs:(NSNotification *)note;

// Squinter Log Methods

- (IBAction)getProjectInfo:(id)sender;
- (IBAction)showDeviceInfo:(id)sender;
- (IBAction)showModelInfo:(id)sender;
- (IBAction)copyAgentURL:(id)sender;
- (IBAction)logDeviceCode:(id)sender;
- (IBAction)logAgentCode:(id)sender;
- (void)writeToLog:(NSString *)string :(BOOL)addTimestamp;
- (void)writeStreamToLog:(NSAttributedString *)string;
- (IBAction)clearLog:(id)sender;
- (void)displayError;
- (IBAction)printLog:(id)sender;
- (void)printDone;
- (IBAction)streamLogs:(id)sender;
- (void)presentLogEntry:(NSNotification *)note;
- (void)endLogging:(NSNotification *)note;
- (IBAction)showAppCode:(id)sender;
- (void)listCode:(NSString *)code :(NSInteger)from :(NSInteger)to :(NSInteger)at;
- (void)logCode;
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
- (IBAction)setPrefs:(id)sender;
- (IBAction)cancelPrefs:(id)sender;
- (IBAction)chooseWorkingDirectory:(id)sender;
- (void)setWorkingDirectory:(NSArray *)urls;
- (NSString *)getFontName:(NSInteger)index;
- (void)showPanelForBack;
- (void)showPanelForText;

// About and Help Sheet Methods

- (IBAction)showAboutSheet:(id)sender;
- (IBAction)closeAboutSheet:(id)sender;
// - (IBAction)showHelpSheet:(id)sender;
- (IBAction)showHideToolbar:(id)sender;
- (IBAction)showAuthor:(id)sender;

// UI Update Methods

- (void)updateMenus;
- (void)setDeviceMenu;
- (void)setModelsMenu;
- (void)setProjectMenu;
- (void)setViewMenu;
- (void)setProjectLists;
- (void)setToolbar;
- (void)updateDeviceLists;
- (NSString *)menuString:(NSString *)deviceID;
- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold;

// Progress Methods

- (void)startProgress;
- (void)stopProgress;

// Application Quit Methods

- (IBAction)ignoreChanges:(id)sender;
- (IBAction)saveChanges:(id)sender;
- (IBAction)cancelChanges:(id)sender;

// Misc

- (void)setLoggingColours;
- (void)setColours;
- (NSInteger)perceivedBrightness:(NSColor *)colour;


@end
