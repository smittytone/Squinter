//
//  HelpWindowViewController.h
//  Squinter
//
//  Created by Tony Smith on 21/06/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface HelpWindowViewController : NSViewController <WKUIDelegate, NSWindowDelegate>
{
    IBOutlet WKWebView *helpView;
    
    bool catchResize;
}


- (void)prepSheet;


@property (nonatomic, readwrite) NSRect initialFrame;
@property (nonatomic, readwrite) bool isOnScreen;


@end

NS_ASSUME_NONNULL_END
