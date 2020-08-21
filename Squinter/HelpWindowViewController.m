

//  Created by Tony Smith on 21/06/2019.
//  Copyright (c) 2020 Tony Smith. All rights reserved.
//  ADDED 2.3.130


#import "HelpWindowViewController.h"

@interface HelpWindowViewController ()

@end

@implementation HelpWindowViewController

@synthesize initialFrame, isOnScreen;


- (void)viewDidLoad
{
    // Assume the help panel is not on screen at launch

    isOnScreen = NO;
    
    [super viewDidLoad];
}



- (void)prepSheet
{
    // Ready the window for viewing

    // Point the WKWebView at the help index page and the folder it's located in
    
    NSString *dirPath = [[NSBundle mainBundle] resourcePath];
    dirPath = [dirPath stringByAppendingString:@"/help"];
    NSURL *helpDirectory = [NSURL fileURLWithPath:dirPath isDirectory:YES];
    
    NSString *filePath = [dirPath stringByAppendingString:@"/index.html"];
    NSURL *helpPage = [NSURL fileURLWithPath:filePath];
    
    // Load up the URL
    
    [helpView loadFileURL:helpPage allowingReadAccessToURL:helpDirectory];
}



#pragma mark - WKWebView Delegate Methods


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    // This is called when the WKWebView has loaded its content. Now we can make
    // the window visible and record that it's on screen (so the main app doesn't
    // resize it every time it's brought forward)

    [self.view.window makeKeyAndOrderFront:self];
    
    isOnScreen = YES;
}



#pragma mark - NSWindowDelegate Methods


- (void)windowWillClose:(NSNotification *)notification
{
    // Make sure we record that the window is off the screen when the user
    // hits the close button
    
    isOnScreen = NO;
}






@end
