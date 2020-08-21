//  Created by Tony Smith on 29/11/2019.
//  Copyright © 2020 Tony Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>


NS_ASSUME_NONNULL_BEGIN


@interface InspectorToolbarItem : NSToolbarItem <NSCopying>
{
    BOOL isForeground;
}


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


// Properties are used to set the names of the image files used to represent
// the toolbar item's show/hide state ('show' or 'hide')
@property (nonatomic, strong) NSString *activeShowImageName;
@property (nonatomic, strong) NSString *activeHideImageName;
@property (nonatomic, strong) NSString *inactiveShowImageName;
@property (nonatomic, strong) NSString *inactiveHideImageName;
@property (nonatomic, assign) BOOL isShown;


@end


NS_ASSUME_NONNULL_END
