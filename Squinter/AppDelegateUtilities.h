

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import "AppDelegate.h"


@interface AppDelegate(AppDelegateUtilities)


// File Path Manipulation and Presentation Methods
- (NSString *)getDisplayPath:(NSString *)filePath;
- (NSString *)getPrintPath:(NSString *)projectPath :(NSString *)filePath;
- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath;
- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath;
- (NSInteger)numberOfFoldersInPath:(NSString *)path;
- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath;

// File Watch Methods
- (BOOL)checkAndWatchFile:(NSString *)filePath;
- (void)watchfiles:(Project *)project;

// Bookmark Handling Methods
- (NSData *)bookmarkForURL:(NSURL *)url;
- (NSURL *)urlForBookmark:(NSData *)bookmark;

// Network Activity Progress Indicator Methods
- (void)startProgress;
- (void)stopProgress;

// Logging Utility Methods
- (void)parseLog;
- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold;
- (void)setColours;

// Preferences Panel Subsidiary Methods
- (void)showPanelForText;
- (void)showPanelForBack;
- (void)showPanelForDev1;
- (void)showPanelForDev2;
- (void)showPanelForDev3;
- (void)showPanelForDev4;
- (void)showPanelForDev5;
- (void)showPanelForDev6;
- (void)showPanelForDev7;
- (void)showPanelForDev8;
- (void)setWorkingDirectory:(NSArray *)urls;
- (NSString *)getFontName:(NSInteger)index;
- (NSInteger)perceivedBrightness:(NSColor *)colour;

// Sleep/wake Methods
- (void)receiveSleepNote:(NSNotification *)note;
- (void)receiveWakeNote:(NSNotification *)note;

// API Data Extraction Methods
- (id)getValueFrom:(NSDictionary *)apiDict withKey:(NSString *)key;
- (id)checkForNull:(id)value;

// Device Group Utility Methods
- (void)updateDevicegroup:(Devicegroup	 *)devicegroup;
- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back;
- (bool)checkDevicegroupName:(NSString *)name;
- (BOOL)checkDevicegroupNames:(Devicegroup *)byDevicegroup :(NSString *)orName;
- (Project *)getParentProject:(Devicegroup *)devicegroup;
- (NSArray *)displayDescription:(NSString *)description :(NSInteger)maxWidth :(NSString *)spaces;
- (void)setDevicegroupDevices:(Devicegroup *)devicegroup;

// FROM 2.3.130
// Device Utility Methods
- (NSDictionary *)deviceWithID:(NSString *)devID;

// Date and Time Conversion Methods
- (NSDate *)convertTimestring:(NSString *)dateString;
- (NSString *)convertDate:(NSDate *)date;
- (NSString *)formatTimestamp:(NSString *)timestamp;

// Alert Methods
- (void)projectAccountAlert:(Project *)project :(NSString *)action :(NSWindow *)sheetWindow;
- (void)devicegroupAccountAlert:(Devicegroup *)devicegroup :(NSString *)action :(NSWindow *)sheetWindow;
- (void)accountAlert:(NSString *)head :(NSString *)body :(NSWindow *)sheetWindow;
- (void)unsavedAlert:(NSString *)name :(NSString *)message :(NSWindow *)sheetWindow;

// Misc Methods
- (NSString *)getErrorMessage:(NSUInteger)index;
- (NSString *)getCloudName:(NSInteger)cloudCode;
- (NSString *)recodeLogTags:(NSString *)string;
- (BOOL)isCorrectAccount:(Project *)project;


@end
