

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUtilities.h"
#import "AppDelegateUI.h"


@interface AppDelegate(AppDelegateSquinting)


// Code compilation methods

// Start the process
- (void)compile:(Devicegroup *)devicegroup :(BOOL)justACheck;

// Examine source code for imports and other items
- (NSString *)processSource:(NSString *)codePath :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode;
- (NSString *)processImports:(NSString *)sourceCode :(NSString *)searchString :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode;
- (void)processRequires:(NSString *)sourceCode;
- (void)processLibraries:(Model *)model;

// Ancillary methods
- (NSUInteger)getLineNumber:(NSString *)code :(NSInteger)index;
- (NSString *)getLibraryVersionNumber:(NSString *)libcode;


@end
