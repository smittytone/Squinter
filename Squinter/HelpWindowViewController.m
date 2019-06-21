//
//  HelpWindowViewController.m
//  Squinter
//
//  Created by Tony Smith on 21/06/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//

#import "HelpWindowViewController.h"

@interface HelpWindowViewController ()

@end

@implementation HelpWindowViewController

@synthesize initialFrame, isOnScreen;


- (void)viewDidLoad
{
    isOnScreen = NO;
}



- (void)prepSheet
{
    // Point the WKWebView at the help index page and the folder it's located in
    
    NSString *dirPath = [[NSBundle mainBundle] resourcePath];
    dirPath = [dirPath stringByAppendingString:@"/help"];
    NSURL *helpDirectory = [NSURL fileURLWithPath:dirPath isDirectory:YES];
    
    NSString *filePath = [dirPath stringByAppendingString:@"/index.html"];
    NSURL *helpPage = [NSURL fileURLWithPath:filePath];
    
    // Load up the URL
    
    [helpView loadFileURL:helpPage allowingReadAccessToURL:helpDirectory];
}



- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.view.window makeKeyAndOrderFront:self];
    
    isOnScreen = YES;
}



#pragma mark - NSWindowDelegate Methods


- (void)windowWillClose:(NSNotification *)notification
{
    isOnScreen = NO;
}






@end
