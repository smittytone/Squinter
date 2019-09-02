
//  Created by Tony Smith on 22/08/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//  ADDED 2.3.131


#import "EnvVarValueCell.h"


@implementation EnvVarValueCell

@synthesize isString;



- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Initialise the images we may use
    
    numberImage = [NSImage imageNamed:@"env_var_icon_number"];
    stringImage = [NSImage imageNamed:@"env_var_icon_string"];
    
    // Set the default data type
    
    isString = YES;
}



- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Set the icon according to value type
    
    typeIcon.image = isString ? stringImage : numberImage;
}


@end
