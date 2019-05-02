

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUtilities.h"
#import "AppDelegateUI.h"


@interface AppDelegate(AppDelegateSquinting)


- (void)compile:(Devicegroup *)devicegroup :(BOOL)justACheck;
- (NSString *)processSource:(NSString *)codePath :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode;
- (NSString *)processImports:(NSString *)sourceCode :(NSString *)searchString :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode;
- (void)processRequires:(NSString *)sourceCode;
- (void)processLibraries:(Model *)model;
- (NSUInteger)getLineNumber:(NSString *)code :(NSInteger)index;
- (NSString *)getLibraryVersionNumber:(NSString *)libcode;


@end
