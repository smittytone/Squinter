

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-17 Tony Smith. All rights reserved.


#import "AppDelegate.h"

@interface AppDelegate(AppDelegateUtilities)


// File Path Methods

- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath;
- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath;
- (NSInteger)numberOfFoldersInPath:(NSString *)path;
- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath;
- (NSString *)getPrintPath:(NSString *)projectPath :(NSString *)filePath;
- (NSData *)bookmarkForURL:(NSURL *)url;
- (NSURL *)urlForBookmark:(NSData *)bookmark;

// Progress Indicator Methods

- (void)startProgress;
- (void)stopProgress;

// Logging Utility Methods

- (void)parseLog;
- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold;
- (void)setColours;
- (void)setLoggingColours;

// Preferences Panel Subsidiary Methods

- (void)showPanelForText;
- (void)showPanelForBack;
- (void)showPanelForDev1;
- (void)showPanelForDev2;
- (void)showPanelForDev3;
- (void)showPanelForDev4;
- (void)showPanelForDev5;

// Utility Methods

- (id)getValueFrom:(NSDictionary *)apiDict withKey:(NSString *)key;
- (void)updateDevicegroup:(Devicegroup	 *)devicegroup;
- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back;
- (Project *)getParentProject:(Devicegroup *)devicegroup;
- (NSDate *)convertTimestring:(NSString *)dateString;
- (NSString *)formatTimestamp:(NSString *)timestamp;
- (NSString *)getErrorMessage:(NSUInteger)index;
- (NSArray *)displayDescription:(NSString *)description :(NSInteger)maxWidth :(NSString *)spaces;
- (void)setDevicegroupDevices:(Devicegroup *)devicegroup;
- (void)setWorkingDirectory:(NSArray *)urls;
- (NSString *)getFontName:(NSInteger)index;
- (NSInteger)perceivedBrightness:(NSColor *)colour;

@end
