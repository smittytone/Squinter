

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-17 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>
#include <Security/Security.h>
#include <Foundation/Foundation.h>
#include <Sparkle/Sparkle.h>
#include <math.h>
#import "Constants.h"
#import "StatusLight.h"
#import "Project.h"
#import "Devicegroup.h"
#import "Model.h"
#import "File.h"
#import "BuildAPIAccess.h"
#import "VDKQueue.h"
#import "SquinterToolbarItem.h"
#import "StreamToolbarItem.h"
#import "LoginToolbarItem.h"
#import "PDKeychainBindings.h"


@interface AppDelegate : NSObject <NSApplicationDelegate,
								   NSOpenSavePanelDelegate,
                                   NSFileManagerDelegate,
                                   VDKQueueDelegate,
                                   NSToolbarDelegate,
                                   NSURLSessionDataDelegate,
                                   NSURLSessionTaskDelegate,
                                   NSTextFieldDelegate>
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
	
	IBOutlet NSMenu *fileMenu;
	IBOutlet NSMenuItem *fileSaveMenuItem;
	IBOutlet NSMenuItem *fileSaveAsMenuItem;
	IBOutlet NSMenuItem *fileAddFilesMenuItem;
	IBOutlet NSMenu *openRecentMenu;
    
    // Project Menu outlets

	IBOutlet NSMenu *projectsMenu;
	IBOutlet NSMenu *openProjectsMenu;
	IBOutlet NSMenuItem *renameProjectMenuItem;
	IBOutlet NSMenuItem *syncProjectMenuItem;
	IBOutlet NSMenuItem *showProjectInfoMenuItem;
	IBOutlet NSMenuItem *showProjectFinderMenuItem;
	IBOutlet NSMenu *productsMenu;
	IBOutlet NSMenuItem *downloadProductMenuItem;
	IBOutlet NSMenuItem *linkProductMenuItem;
	IBOutlet NSMenuItem *deleteProductMenuItem;
	IBOutlet NSMenuItem *renameProductMenuItem;

    // Device Groups Menu outlets

	IBOutlet NSMenu *deviceGroupsMainMenu;
	IBOutlet NSMenu *deviceGroupsMenu;
	IBOutlet NSMenuItem *showDeviceGroupInfoMenuItem;
	IBOutlet NSMenuItem *listCommitsMenuItem;
	IBOutlet NSMenuItem *showModelFilesFinderMenuItem;
	IBOutlet NSMenuItem *restartDeviceGroupMenuItem;
	IBOutlet NSMenuItem *deleteDeviceGroupMenuItem;
	IBOutlet NSMenuItem *renameDeviceGroupMenuItem;
	IBOutlet NSMenuItem *compileMenuItem;
	IBOutlet NSMenuItem *uploadMenuItem;
	IBOutlet NSMenuItem *uploadExtraMenuItem;
	IBOutlet NSMenuItem *removeFilesMenuItem;
	IBOutlet NSMenuItem *externalOpenMenuItem;
	IBOutlet NSMenu *externalSourceMenu;
	IBOutlet NSMenuItem *externalOpenDeviceItem;
	IBOutlet NSMenuItem *externalOpenAgentItem;
	IBOutlet NSMenuItem *externalOpenBothItem;
	IBOutlet NSMenuItem *externalOpenLibsItem;
	IBOutlet NSMenu *externalLibsMenu;
	IBOutlet NSMenuItem *externalOpenFileItem;
	IBOutlet NSMenu *externalFilesMenu;
	IBOutlet NSMenu *impLibrariesMenu;
	IBOutlet NSMenuItem *checkImpLibrariesMenuItem;

    // Device Menu outlets

	IBOutlet NSMenu *deviceMenu;
	IBOutlet NSMenuItem *showDeviceInfoMenuItem;
	IBOutlet NSMenuItem *restartDeviceMenuItem;
	IBOutlet NSMenuItem *copyAgentURLMenuItem;
	IBOutlet NSMenuItem *openAgentURLMenuItem;
	IBOutlet NSMenuItem *unassignDeviceMenuItem;
	IBOutlet NSMenuItem *assignDeviceMenuItem;
	IBOutlet NSMenuItem *getLogsMenuItem;
	IBOutlet NSMenuItem *getHistoryMenuItem;
	IBOutlet NSMenuItem *streamLogsMenuItem;
	IBOutlet NSMenuItem *renameDeviceMenuItem;
	IBOutlet NSMenuItem *updateDeviceStatusMenuItem;
	IBOutlet NSMenuItem *deleteDeviceMenuItem;
	IBOutlet NSMenu *unassignedDevicesMenu;

	// Account Menu Outlets

	IBOutlet NSMenuItem *loginMenuItem;

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
	IBOutlet SquinterToolbarItem *newDevicegroupItem;
	IBOutlet SquinterToolbarItem *devicegroupInfoItem;
	IBOutlet LoginToolbarItem *loginAndOutItem;
	IBOutlet SquinterToolbarItem *uploadCodeExtraItem;
	IBOutlet SquinterToolbarItem *listCommitsItem;
	IBOutlet SquinterToolbarItem *downloadProductItem;

	// Sheets, dialogs and windows

	// Login

	IBOutlet NSPanel *loginSheet;
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSSecureTextField *passwordTextField;
	IBOutlet NSSecureTextFieldCell *passwordTextFieldCell;
	IBOutlet NSButton *saveDetailsCheckbox;
	IBOutlet NSButton *showPassCheckbox;
    
    // Open
    
    NSOpenPanel *openDialog;
    IBOutlet NSView *accessoryView;
    IBOutlet NSButton *accessoryViewNewProjectCheckbox;

    IBOutlet NSView *projectFromFilesAccessoryView;
	IBOutlet NSButton *projectFromFilesAccessoryViewCheckbox;
	IBOutlet NSButton *projectFromFilesAccessoryViewLocCheckbox;
    
    // Save
    
    NSSavePanel *saveProjectDialog;
    IBOutlet id saveChangesSheet;
    IBOutlet NSTextField *saveChangesSheetLabel;
	IBOutlet NSView *saveDevicegroupFilesAccessoryView;
	IBOutlet NSButton *saveDevicegroupFilesAccessoryViewCheckbox;
    
    // New Project
    
    IBOutlet NSPanel *newProjectSheet;
    IBOutlet NSTextField *newProjectNameTextField;
	IBOutlet NSTextField *newProjectNameCountField;
	IBOutlet NSTextField *newProjectDescTextField;
	IBOutlet NSTextField *newProjectDescCountField;
    IBOutlet NSTextField *newProjectLabel;
	IBOutlet NSButton *newProjectAssociateCheckbox;
	IBOutlet NSButton *newProjectNewProductCheckbox;

	// Rename Project/Device Group

	IBOutlet NSPanel *renameProjectSheet;
	IBOutlet NSTextField *renameProjectLabel;
	IBOutlet NSTextField *renameProjectTextField;
	IBOutlet NSTextField *renameProjectCountField;
	IBOutlet NSTextField *renameProjectDescTextField;
	IBOutlet NSTextField *renameProjectDescCountField;
	IBOutlet NSButton *renameProjectLinkCheckbox;
	IBOutlet NSTextField *renameProjectHintField;

	// Sync Project

	IBOutlet NSPanel *syncProjectSheet;
	IBOutlet NSProgressIndicator *syncProjectProgress;
	IBOutlet NSTextField *syncProjectLabel;

	// New Device Group

	IBOutlet NSPanel *newDevicegroupSheet;
	IBOutlet NSTextField *newDevicegroupLabel;
	IBOutlet NSTextField *newDevicegroupNameTextField;
	IBOutlet NSTextField *newDevicegroupNameCountField;
	IBOutlet NSTextField *newDevicegroupDescTextField;
	IBOutlet NSTextField *newDevicegroupDescCountField;
	IBOutlet NSButton *newDevicegroupCheckbox;
	IBOutlet NSPopUpButton *newDevicegroupTypeMenu;
	IBOutlet NSTextField *targetAccessoryLabel;
	IBOutlet NSPopUpButton *targetAccessoryPopup;
    
    // About
    
    IBOutlet id aboutSheet;
    IBOutlet id aboutVersionLabel;
    
    // Prefs
    
    IBOutlet id preferencesSheet;
    IBOutlet NSTextField *workingDirectoryField;
    IBOutlet NSButton *preserveCheckbox;
	IBOutlet NSButton *autoCompileCheckbox;
	IBOutlet NSButton *loadModelsCheckbox;
	IBOutlet NSButton *loadDevicesCheckbox;
    IBOutlet NSPopUpButton *fontsMenu;
    IBOutlet NSPopUpButton *sizeMenu;
    IBOutlet NSColorWell *textColorWell;
    IBOutlet NSColorWell *backColorWell;
	IBOutlet NSButton *autoUpdateCheckCheckbox;
	IBOutlet NSButton *autoLoadListsCheckbox;
	IBOutlet NSButton *boldTestCheckbox;
	IBOutlet NSPopUpButton *locationMenu;
	IBOutlet NSPopUpButton *recentFilesCountMenu;
	IBOutlet NSPopUpButton *maxLogCountMenu;
	IBOutlet NSButton *azureCheckbox;

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
	IBOutlet NSTextField *renameNameLength;

	// Agent or Device?

	IBOutlet NSPanel *sourceTypeSheet;
	IBOutlet NSTextField *sourceTypeLabel;
	IBOutlet NSButton *sourceTypeAgentButton;
	IBOutlet NSButton *sourceTypeDeviceButton;

	// Upload Code

	IBOutlet NSPanel *uploadSheet;
	IBOutlet NSTextField *uploadDevicegroupTextField;
	IBOutlet NSTabView *uploadTab;
	IBOutlet NSTextField *uploadCommitTextField;
	IBOutlet NSTextField *uploadCommitCountField;
	IBOutlet NSTextField *uploadOriginTextField;
	IBOutlet NSTextField *uploadOriginCountField;
	IBOutlet NSTextField *uploadTagsTextField;
	IBOutlet NSTextField *uploadTagsCountField;

	// Connection Variables
    
    BuildAPIAccess *ide;

    // Update Tracking
	
	IBOutlet SUUpdater *sparkler; 

	Project *currentProject, *creatingProject, *savingProject;
	Devicegroup *currentDevicegroup;

	VDKQueue *fileWatchQueue;

	NSOperatingSystemVersion sysVer;

	NSWorkspace *nswsw;
	NSFileManager *nsfm;
	NSNotificationCenter *nsncdc;
	NSUserDefaults *defaults;

	NSDateFormatter *def, *logDef;

	NSOperationQueue *extraOpQueue;

	NSMenu *dockMenu;

	NSMutableArray *projectArray, *devicesArray, *productsArray, *downloads, *recentFiles;
	NSMutableArray *foundLibs, *foundFiles, *foundEILibs, *colors, *logColors, *saveUrls;

	NSMutableDictionary *selectedProduct, *selectedDevice;

	NSURLSessionTask *eiLibListTask;
	NSMutableData *eiLibListData;
	NSDate *eiLibListTime;

	NSColor *backColour, *textColour;

	NSString *workingDirectory, *listString, *newDevicegroupName;

	NSUInteger syncItemCount, logPaddingLength;

	BOOL closeProjectFlag, noProjectsFlag, newDevicegroupFlag, deviceSelectFlag;
	BOOL loginFlag, renameProjectFlag, saveAsFlag, stale;
}


@property (assign) IBOutlet NSWindow *window;

// Dock Menu Methods

- (void)dockMenuAction:(id)sender;

// Login Methods

- (IBAction)loginOrOut:(id)sender;
- (void)autoLogin;
- (void)showLoginWindow;
- (void)setLoginCreds;
- (IBAction)cancelLogin:(id)sender;
- (IBAction)login:(id)sender;
- (void)loginAlert:(NSString *)extra;
- (IBAction)setSecureEntry:(id)sender;

// New Project Methods

- (IBAction)newProject:(id)sender;
- (IBAction)newProjectSheetCancel:(id)sender;
- (IBAction)newProjectSheetCreate:(id)sender;
- (IBAction)newProjectCheckboxStateHandler:(id)sender;

// Existing Project Methods

- (IBAction)pickProject:(id)sender;
- (void)chooseProject:(id)sender;
- (IBAction)openProject:(id)sender;
- (IBAction)closeProject:(id)sender;
- (IBAction)renameCurrentProject:(id)sender;
- (void)renameProject:(id)sender;
- (IBAction)closeRenameProjectSheet:(id)sender;
- (IBAction)saveRenameProjectSheet:(id)sender;
- (IBAction)doSync:(id)sender;
- (void)uploadProject:(Project *)project;
- (void)syncProject:(Project *)project;
- (IBAction)cancelSync:(id)sender;
- (IBAction)openRecent:(id)sender;
- (void)openRecentAll;
- (IBAction)clearRecent:(id)sender;
- (void)addToRecentMenu:(NSString *)filename :(NSString *)path;

// Product Methods

- (void)chooseProduct:(id)sender;
- (IBAction)getProductsFromServer:(id)sender;
- (IBAction)deleteProduct:(id)sender;
- (IBAction)downloadProduct:(id)sender;
- (IBAction)linkProjectToProduct:(id)sender;

// New Device Group Mehods

- (IBAction)newDevicegroup:(id)sender;
- (IBAction)newDevicegroupSheetCancel:(id)sender;
- (IBAction)newDevicegroupSheetCreate:(id)sender;
- (void)createFilesForDevicegroup:(NSString *)filename :(NSString *)filetype;
- (void)saveDevicegroupfiles:(NSURL *)saveDirectory :(NSString *)newFileName :(NSInteger)action;
- (IBAction)chooseType:(id)sender;

// Existing Device Group Methods

- (void)chooseDevicegroup:(id)sender;
- (IBAction)deleteDevicegroup:(id)sender;
- (IBAction)renameDevicegroup:(id)sender;
- (IBAction)uploadCode:(id)sender;
- (IBAction)uploadCodeExtraCancel:(id)sender;
- (IBAction)uploadCodeExtraSkip:(id)sender;
- (IBAction)uploadCodeExtraUpload:(id)sender;
- (IBAction)removeSource:(id)sender;
- (IBAction)getCommits:(id)sender;
- (IBAction)updateCode:(id)sender;

// Existing Device Methods

- (void)selectDevice;
- (IBAction)updateDevicesStatus:(id)sender;
- (IBAction)restartDevice:(id)sender;
- (IBAction)restartDevices:(id)sender;
- (IBAction)unassignDevice:(id)sender;
- (IBAction)assignDevice:(id)sender;
- (IBAction)assignDeviceSheetCancel:(id)sender;
- (IBAction)assignDeviceSheetAssign:(id)sender;
- (IBAction)renameDevice:(id)sender;
- (IBAction)closeRenameSheet:(id)sender;
- (IBAction)saveRenameSheet:(id)sender;
- (IBAction)chooseDevice:(id)sender;
- (IBAction)deleteDevice:(id)sender;
- (IBAction)getLogs:(id)sender;
- (IBAction)streamLogs:(id)sender;

// File Location and Opening Methods

- (void)presentOpenFilePanel:(NSInteger)openActionType;
- (void)openFileHandler:(NSArray *)urls :(NSInteger)openActionType;
- (void)openSquirrelProjects:(NSMutableArray *)urls;
- (void)watchfiles:(Project *)project;
- (BOOL)checkProjectPaths:(Project *)byProject :(NSString *)orProjectPath;
- (BOOL)checkProjectNames:(Project *)byProject :(NSString *)orName;
- (BOOL)checkDevicegroupNames:(Devicegroup *)byDevicegroup :(NSString *)orName;
- (BOOL)checkFile:(NSString *)filePath;
- (IBAction)selectFile:(id)sender;
- (IBAction)newDevicegroupCheckboxHander:(id)sender;
- (void)processAddedFiles:(NSMutableArray *)urls;
- (IBAction)endSourceTypeSheet:(id)sender;
- (IBAction)cancelSourceTypeSheet:(id)sender;
- (void)processAddedFilesStageTwo:(NSMutableArray *)urls :(NSString *)fileType;

// Save Project Methods

- (void)savePrep:(NSURL *)saveDirectory :(NSString *)newFileName;
- (IBAction)saveProjectAs:(id)sender;
- (IBAction)saveProject:(id)sender;
- (IBAction)cancelChanges:(id)sender;
- (IBAction)ignoreChanges:(id)sender;
- (IBAction)saveChanges:(id)sender;
- (void)saveModelFiles:(Project *)project;
- (void)saveFiles:(NSMutableArray *)files;

// Squint Methods

- (IBAction)squint:(id)sender;
- (void)compile:(Devicegroup *)devicegroup :(BOOL)justACheck;
- (NSString *)processSource:(NSString *)codePath :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode;
- (NSString *)processImports:(NSString *)sourceCode :(NSString *)searchString :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode ;
- (void)processRequires:(NSString *)sourceCode;
- (void)processLibraries:(Model *)model;
- (NSUInteger)getLineNumber:(NSString *)code :(NSInteger)index;
- (NSString *)getLibraryVersionNumber:(NSString *)libcode;

// BuildAPIAccess Response Handler Methods

- (void)listProducts:(NSNotification *)note;
- (void)productToProjectStageTwo:(NSNotification *)note;
- (void)productToProjectStageThree:(NSNotification *)note;
- (void)productToProjectStageFour:(Project *)project;
- (void)createProductStageTwo:(NSNotification *)note;
- (void)deleteProductStageTwo:(NSMutableDictionary *)dict;
- (void)deleteProductStageThree:(NSNotification *)note;
- (void)updateProductStageTwo:(NSNotification *)note;
- (void)createDevicegroupStageTwo:(NSNotification *)note;
- (void)deleteDevicegroupStageTwo:(NSNotification *)note;
- (void)updateDevicegroupStageTwo:(NSNotification *)note;
- (void)uploadCodeStageTwo:(NSNotification *)note;
- (void)updateCodeStageTwo:(NSNotification *)note;
- (void)uploadProjectStageThree:(Project *)project;
- (void)listDevices:(NSNotification *)note;
- (void)restarted:(NSNotification *)note;
- (void)reassigned:(NSNotification *)note;
- (void)renameDeviceStageTwo:(NSNotification *)note;
- (void)deleteDeviceStageTwo:(NSNotification *)note;
- (void)loggedIn:(NSNotification *)note;

// Log and Logging Methods

- (void)listCommits:(NSNotification *)note;
- (void)listLogs:(NSNotification *)note;
- (void)logLogs:(NSString *)logLine;
- (void)parseLog;
- (IBAction)printLog:(id)sender;
- (void)printDone:(NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(void *)contextInfo;
- (void)loggingStarted:(NSNotification *)note;
- (void)loggingStopped:(NSNotification *)note;
- (void)presentLogEntry:(NSNotification *)note;
- (void)endLogging:(NSNotification *)note;
- (IBAction)showProjectInfo:(id)sender;
- (IBAction)showDeviceGroupInfo:(id)sender;
- (void)compileDevicegroupInfo:(Devicegroup *)devicegroup :(NSUInteger)inset :(NSMutableArray *)otherLines;
- (void)compileModelInfo:(Model *)model :(NSUInteger)inset :(NSMutableArray *)otherLines;
- (IBAction)showDeviceInfo:(id)sender;
- (IBAction)logDeviceCode:(id)sender;
- (IBAction)logAgentCode:(id)sender;
- (IBAction)clearLog:(id)sender;
- (void)printInfoInLog:(NSMutableArray *)lines;
- (void)writeStringToLog:(NSString *)string :(BOOL)addTimestamp;
- (void)writeErrorToLog:(NSString *)string :(BOOL)addTimestamp;
- (void)writeWarningToLog:(NSString *)string :(BOOL)addTimestamp;
- (void)writeNoteToLog:(NSString *)string :(NSColor *)colour :(BOOL)addTimestamp;
- (void)writeStyledStringToLog:(NSAttributedString *)string :(BOOL)addTimestamp;
- (NSString *)getDisplayPath:(NSString *)path;
- (void)showCodeErrors:(NSNotification *)note;
- (void)listCode:(NSString *)code :(NSUInteger)from :(NSUInteger)to :(NSUInteger)at :(NSUInteger)col;
- (void)logCode;
- (void)writeStreamToLog:(NSAttributedString *)string;
- (void)displayError:(NSNotification *)note;

// External Editor Methods

- (IBAction)externalOpen:(id)sender;
- (void)switchToEditor:(Model *)model;
- (IBAction)externalLibOpen:(id)sender;
- (IBAction)externalFileOpen:(id)sender;
- (IBAction)externalOpenAll:(id)sender;
- (IBAction)openAgentURL:(id)sender;
- (IBAction)showProjectInFinder:(id)sender;
- (IBAction)showModelFilesInFinder:(id)sender;
- (void)launchLibsPage;

// UI Update Methods

- (void)refreshProjectsMenu;
- (void)refreshOpenProjectsMenu;
- (BOOL)addProjectMenuItem:(NSString *)menuItemTitle :(Project *)aProject;
- (void)refreshProductsMenu;
- (void)refreshDevicegroupMenu;
- (void)refreshMainDevicegroupsMenu;
- (void)defaultExternalMenus;
- (void)refreshDevicesMenus;
- (void)refreshDeviceMenu;
- (void)refreshDevicesPopup;
- (NSImage *)menuImage:(NSMutableDictionary *)device;
- (NSString *)menuString:(NSMutableDictionary *)device;
- (void)refreshUnassignedDevicesMenu;
- (void)refreshViewMenu;
- (void)refreshRecentFilesMenu;
- (IBAction)showHideToolbar:(id)sender;
- (void)refreshLibraryMenus;
- (void)libAdder:(NSMutableArray *)libs :(BOOL)isEILib;
- (void)addLibraryToMenu:(File *)lib :(BOOL)isEILib :(BOOL)isActive;
- (void)refreshFilesMenu;
- (void)fileAdder:(NSMutableArray *)models;
- (void)addFileToMenu:(NSString *)filename :(BOOL)isActive;
- (void)setToolbar;

// Logging Area Methods

- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold;
- (void)setColours;
- (void)setLoggingColours;
- (NSInteger)perceivedBrightness:(NSColor *)colour;

// Progress Methods

- (void)startProgress;
- (void)stopProgress;

// About Sheet Methods

- (IBAction)showAboutSheet:(id)sender;
- (IBAction)viewSquinterSite:(id)sender;
- (IBAction)closeAboutSheet:(id)sender;

// Help Menu Methods

- (IBAction)showAuthor:(id)sender;

// Preferences Sheet Methods

- (IBAction)showPrefs:(id)sender;
- (IBAction)cancelPrefs:(id)sender;
- (IBAction)setPrefs:(id)sender;
- (IBAction)chooseWorkingDirectory:(id)sender;
- (void)setWorkingDirectory:(NSArray *)urls;
- (NSString *)getFontName:(NSInteger)index;
- (void)showPanelForText;
- (void)showPanelForBack;

// File Watching Methods

- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath;

// File Path Methods

- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath;
- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath;
- (NSInteger)numberOfFoldersInPath:(NSString *)path;
- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath;
- (NSString *)getPrintPath:(NSString *)projectPath :(NSString *)filePath;
- (NSData *)bookmarkForURL:(NSURL *)url;
- (NSURL *)urlForBookmark:(NSData *)bookmark;

// Check Electric Imp Libraries Methods

- (IBAction)checkElectricImpLibraries:(id)sender;
- (void)checkElectricImpLibs;
- (void)compareElectricImpLibs;

// Pasteboard Methods

- (IBAction)copyDeviceCodeToPasteboard:(id)sender;
- (IBAction)copyAgentCodeToPasteboard:(id)sender;
- (IBAction)copyAgentURL:(id)sender;

// Utilty Methods

- (id)getValueFrom:(NSDictionary *)apiDict withKey:(NSString *)key;
- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back;
- (Project *)getParentProject:(Devicegroup *)devicegroup;
- (NSDate *)convertTimestring:(NSString *)dateString;
- (NSString *)getErrorMessage:(NSUInteger)index;
- (NSArray *)displayDescription:(NSString *)description :(NSInteger)maxWidth :(NSString *)spaces;
- (void)setDevicegroupDevices:(Devicegroup *)devicegroup;


@end
