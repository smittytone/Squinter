

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUtilities.h"
#import "AppDelegateUI.h"


@interface AppDelegate(AppDelegateSquinting)


// Code compilation methods

// Start the process
- (void)compile:(Devicegroup *)devicegroup :(BOOL)justACheck;

// Examine source code for imports and other items
- (NSString *)processSource:(NSDictionary *)source;
- (NSString *)processImports:(NSDictionary *)source;
- (void)processRequires:(NSString *)sourceCode;
- (void)processLibraries:(Model *)model;

// Ancillary methods
- (NSUInteger)getLineNumber:(NSString *)code :(NSInteger)index;
- (NSString *)getLibraryVersionNumber:(NSString *)libcode;


@end
